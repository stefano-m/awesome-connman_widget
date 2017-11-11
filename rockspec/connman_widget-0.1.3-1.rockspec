package = "connman_widget"
version = "0.1.3-1"
source = {
  url = "git://github.com/stefano-m/awesome-connman_widget",
  tag = "v0.1.3"
}
description = {
  summary = "A Connman widget for the Awesome Window Manager",
  detailed = [[
    Monitor your network devices in Awesome with Connman and DBus.
    ]],
  homepage = "https://github.com/stefano-m/awesome-connman_widget",
  license = "GPL v3"
}
dependencies = {
  "lua >= 5.1",
  "connman_dbus >= 0.1.0, < 0.2",
}
supported_platforms = { "linux" }
build = {
  type = "builtin",
  modules = { connman_widget = "connman_widget.lua" },
}
