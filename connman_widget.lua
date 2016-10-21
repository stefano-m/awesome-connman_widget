--[[
  Copyright 2016 Stefano Mazzucco <stefano AT curso DOT re>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

-- Connman network widget
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")

-- Awesome DBus C API
local cdbus = dbus -- luacheck: ignore

local Manager = require("connman_dbus")
local spawn_with_shell = awful.util.spawn_with_shell or awful.spawn.with_shell

local icon_theme_dirs = { -- The trailing slash is mandatory!
  "/usr/share/icons/Adwaita/scalable/status/",
  "/usr/share/icons/Adwaita/scalable/devices/"}
local icon_theme_extensions = {"svg"}
icon_theme_dirs = beautiful.connman_icon_theme_dirs or icon_theme_dirs
icon_theme_extensions = beautiful.connman_icon_theme_extension or icon_theme_extensions

local function default_table(t, default_value)
  t = t or {}
  local mt = {
    __index = function (tbl, key)
      if type(default_value) == "table" then
        -- create a new table for each new key
        default_value = {}
      end
      rawset(tbl, key, default_value)
      return default_value
    end
  }
  setmetatable(t, mt)
  return t
end

local icon_statuses = default_table(
  {
    cellular = {
      three_g = "network-cellular-3g-symbolic",
      four_g = "network-cellular-4g-symbolic",
      acquiring = "network-cellular-acquiring-symbolic",
      connected = "network-cellular-connected-symbolic",
      edge = "network-cellular-edge-symbolic",
      gprs  = "network-cellular-gprs-symbolic",
      hspa  = "network-cellular-hspa-symbolic",
      no_route  = "network-cellular-no-route-symbolic",
      offline  = "network-cellular-offline-symbolic",
      signal = {
        excellent = "network-cellular-signal-excellent-symbolic",
        good = "network-cellular-signal-good-symbolic",
        none = "network-cellular-signal-none-symbolic",
        ok = "network-cellular-signal-ok-symbolic",
        weak = "network-cellular-signal-weak-symbolic",
      }
    },
    unspecified = {
      err = "network-error-symbolic",
      idle = "network-idle-symbolic",
      no_route = "network-no-route-symbolic",
      offline = "network-offline-symbolic",
      receive = "network-receive-symbolic",
      transmis_receive = "network-transmit-receive-symbolic",
      transmit = "network-transmit-symbolic",
    },
    vpn = {
      acquiring = "network-vpn-acquiring-symbolic",
      connected = "network-vpn-symbolic",
    },
    ethernet = {
      acquiring =  "network-wired-acquiring-symbolic",
      disconnected = "network-wired-disconnected-symbolic",
      no_route = "network-wired-no-route-symbolic",
      offline = "network-wired-offline-symbolic",
      connected = "network-wired-symbolic",
    },
    wifi = {
      acquiring = "network-wireless-acquiring-symbolic",
      connected  = "network-wireless-connected-symbolic",
      encrypted  = "network-wireless-encrypted-symbolic",
      hotspot = "network-wireless-hotspot-symbolic",
      no_route = "network-wireless-no-route-symbolic",
      offline = "network-wireless-offline-symbolic",
      signal = {
        excellent = "network-wireless-signal-excellent-symbolic",
        good = "network-wireless-signal-good-symbolic",
        ok = "network-wireless-signal-ok-symbolic",
        weak = "network-wireless-signal-weak-symbolic",
        none = "network-wireless-signal-none-symbolic",
      },
    },
  },
  {})

local show_signal = {ready = true, online = true}

local function build_icon_path(name)
  if name then
  return awful.util.geticonpath(
    name,
    icon_theme_extensions,
    icon_theme_dirs)
  end
  return ""
end

local function get_wifi_icon(service)
  local states = {
    idle = "no_route", -- is this correct?
    failure = "offline",
    association = "acquiring",
    configuration = "acquiring",
    disconnect = "offline",
  }
  if show_signal[service.State] then
    local s = service.Strength
    local v
    if s <= 0 then
      v = "none"
    elseif s <= 25 then
      v = "weak"
    elseif s <= 50 then
      v = "ok"
    elseif s <= 75 then
      v = "good"
    else
      v = "excellent"
    end
    return build_icon_path(icon_statuses.wifi.signal[v])
  else
    return build_icon_path(icon_statuses.wifi[states[service.State]])
  end
end

local function get_wired_icon(service)
  local states = {
    idle = "no_route", -- is this correct?
    failure = "offline",
    association = "acquiring",
    configuration = "acquiring",
    ready = "connected",
    disconnect = "disconnected",
    online = "connected",
  }
  return build_icon_path(icon_statuses.ethernet[states[service.State]])
end

local service_types = {
  ethernet = get_wired_icon,
  wifi = get_wifi_icon
}

local function update_tooltip(tooltip, mgr)
  if mgr.current_service.dbus.path ~= "/invalid" then
    local service = mgr.current_service
    local msg = tostring(service.Name)
    if service.Type == "wifi" and show_signal[service.State] then
      msg = msg .. "::" .. service.Strength .. "%"
    end
    tooltip:set_text(msg)
  else
    tooltip:set_text(mgr.State)
  end
end

local function get_status_icon(mgr)
  if mgr.State == "offline" then
    return build_icon_path(icon_statuses.unspecified.offline)
  elseif mgr.State == "idle" then
    return build_icon_path(icon_statuses.unspecified.idle)
  elseif mgr.current_service then
    local service = mgr.current_service
    local f = service_types[service.Type]
    if type(f) == "function" then
      return f(service)
    end
  end
  return build_icon_path(icon_statuses.unspecified.err)
end

local widget = wibox.widget.imagebox()
widget.tooltip = awful.tooltip({ objects = { widget },})
widget.gui_client = "econnman-bin"

function widget:update(mgr)
    self:set_image(get_status_icon(mgr))
    update_tooltip(self.tooltip, mgr)
end

widget:buttons(awful.util.table.join(
                 awful.button({ }, 3,
                   function ()
                     spawn_with_shell(widget.gui_client)
                   end
)))

local function get_manager()
  return Manager:init()
end

local status, manager = pcall(get_manager)

if not status then
  naughty.notify({preset=naughty.config.presets.critical,
                  title="Could not initialize connman",
                  text=manager})
  return widget
end

widget:update(manager)

cdbus.add_match("system", "type=signal,interface=" .. manager.dbus.interface)

cdbus.add_match(
  "system",
  "type=signal"..
    ",interface=" .. manager.current_service.dbus.interface ..
    ",path=" .. manager.current_service.dbus.path ..
    ",member=PropertyChanged")

cdbus.connect_signal(manager.current_service.dbus.interface,
                     function (info)
                       if info.member == "PropertyChanged" and info.path == manager.current_service.dbus.path then
                         -- Strength is uint8 but Awesome returns a string
                         -- so I cannot use the name/value pair passed to the function.
                         -- Instead, I have to update all services again :-(
                         manager:update_services()
                         widget:update(manager)
                       end
end)

cdbus.connect_signal(
  manager.dbus.interface,
  function (info)
    -- for some reasone Awesome does not return the object path
    -- of the services with the signal but it sets it to nil :-(
    if info.member == "ServicesChanged" then
      local path_before = manager.current_service.dbus.path
      manager:update_services()
      local path_after = manager.current_service.dbus.path
      if path_before ~= path_after then
        cdbus.remove_match(
          "system",
          "type=signal,interface=" ..
            manager.current_service.dbus.interface .. ",path=" ..
            path_before .. ",member=PropertyChanged")

        cdbus.add_match(
          "system",
          "type=signal,interface=" ..
            manager.current_service.dbus.interface .. ",path=" ..
            path_after .. ",member=PropertyChanged")
      end
    elseif info.member == "PropertyChanged" then
      manager:update_properties()
    end
    widget:update(manager)
end)

return widget
