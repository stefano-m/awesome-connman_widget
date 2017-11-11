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

local string = string

-- Connman network widget
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local ConnectionManager = require("connman_dbus")

local spawn_with_shell = awful.spawn.with_shell or awful.util.spawn_with_shell

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
      transmit_receive = "network-transmit-receive-symbolic",
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

local function get_status_icon(manager)
  local current_service = manager.services[1]

  if current_service then
    local f = service_types[current_service.Type]
    if type(f) == "function" then
      return f(current_service)
    end
  end
  return build_icon_path(
    icon_statuses.unspecified[manager.State] or icon_statuses.unspecified.err)
end

local widget = wibox.widget.imagebox()
widget.tooltip = awful.tooltip({ objects = { widget },})
widget.gui_client = ""

function widget:update_tooltip(manager)
  local current_service = manager.services[1]
  if current_service then
    local msg = string.format(
      "%s - %s",
      current_service.Name,
      current_service.State == "failure" and current_service.Error or current_service.State)
    if current_service.Type == "wifi" and show_signal[current_service.State] then
      msg = string.format("%s (%d%%)", msg, current_service.Strength)
    end
    self.tooltip:set_text(msg)
  else
    self.tooltip:set_text(manager.State)
  end
end

function widget:update(manager)
  self:set_image(get_status_icon(manager))
  self:update_tooltip(manager)
end

widget:buttons(awful.util.table.join(
                 awful.button({ }, 3,
                   function ()
                     spawn_with_shell(widget.gui_client)
                   end
)))

ConnectionManager:connect_signal(
  function (self)
    widget:update(self)
  end,
  "PropertyChanged"
)

ConnectionManager:connect_signal(
  function (self)
    widget:update(self)
  end,
  "ServicesChanged"
)

widget:update(ConnectionManager)

return widget
