package = "connman_widget"
version = "devel-1"
source = {
  url = "git://github.com/stefano-m/awesome-connman_widget",
  tag = "master"
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
  "connman_dbus",
}
supported_platforms = { "linux" }
build = {
  type = "builtin",
  modules = {
    ["connman_widget.init"] = "src/connman_widget/init.lua"
  },
}
