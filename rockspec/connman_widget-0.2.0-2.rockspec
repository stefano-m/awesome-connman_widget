package = "connman_widget"
version = "0.2.0-2"
source = {
   url = "git://github.com/stefano-m/awesome-connman_widget",
   tag = "v0.2.0"
}
description = {
   summary = "A Connman widget for the Awesome Window Manager",
   detailed = [[
    Monitor your network devices in Awesome with Connman and DBus.
    ]],
   homepage = "https://github.com/stefano-m/awesome-connman_widget",
   license = "GPL v3"
}
supported_platforms = {
   "linux"
}
dependencies = {
   "lua >= 5.1",
   "connman_dbus >= 0.3.0, < 0.5"
}
build = {
   type = "builtin",
   modules = {
      ["connman_widget.init"] = "src/connman_widget/init.lua"
   }
}
