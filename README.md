# A widget for the Awesome Window Manager to monitor the network with Connman

This widget uses the
[`connman_dbus`](https://luarocks.org/modules/stefano-m/connman_dbus)
library.

# Requirements

In addition to the requirements listed in the `rockspec` file, you will need
the [Awesome Window Manager](https://awesomewm.org)
and Connman (for more information about this, see the
[`connman_dbus`](https://luarocks.org/modules/stefano-m/connman_dbus)
documentation).

# Installation

Probably, the easiest way to install this widget is to use `luarocks`:

    luarocks install connman_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.

Note that if you install with `--local` you will have to make sure that the
`LUA_PATH` environment variable includes the local luarocks path. This can be
achieved by `eval`ing the command `luarocks path --bin` **before** Awesome is
started.

For example, if you start Awesome from the Linux console (e.g. `xinit
awesome`) and you use `zsh`, you can add the following lines to your
`~/.zprofile`:

``` shell
if (( $+commands[luarocks] )); then
    eval `luarocks path --bin`
fi
```

If you use `bash`, you can add the following lines to your `~/.bash_profile`:

``` shell
if [[ -n "`which luarocks 2>/dev/null`" ]]; then
    eval `luarocks path --bin`
fi
```

If you use
an [X Display Manager](https://en.wikipedia.org/wiki/Display_manager) you will
need to do what explained above in your `~/.xprofile` or `~/.xinitrc`. See the
documentation of your display manager of choice for more information.

# Configuration

The widget displays network icons that are searched in the folders defined
in the table `beautiful.connman_icon_theme_dirs` with extensions defined
in the table `beautiful.connman_icon_extensions`.
The default is to look into `"/usr/share/icons/Adwaita/scalable/devices/"`
and  `"/usr/share/icons/Adwaita/scalable/status/"`for
icons whose extension is `"svg"`. Note that the directory paths *must* end
with a slash and that the extensions *must not* contain a dot.
The icons are searched using Awesome's
[`awful.util.geticonpath` function](https://awesomewm.org/doc/api/modules/awful.util.html#geticonpath).

Depending on your network devices, you may need some or all of the icons
whose name starts with `network-`.

You can specify a GUI client to be launched when the widget is right-clicked.
This can be done by changing the `gui_client` field of the widget.  A list
of
[Desktop clients is also available on the Arch wiki](https://wiki.archlinux.org/index.php/Connman#Desktop_clients).

# Mouse controls

When the widget is focused:

* Right button: launches GUI client (defined by the `gui_client` field)

# Tooltip

The tooltip shows the currently connected network, its status and - if
applicable - the signal strength.

# Usage

Add the following to your `~/.config/awesome/rc.lua`:

Require the module:

```lua
-- require *after* `beautiful.init` or the theme will be inconsistent!
local connman = require("connman_widget")
-- set the GUI client.
connman.gui_client = "wicd"
```

Add the widget to your layout:

- Awesome 4.x

``` lua
-- Add widgets to the wibox
s.mywibox:setup {

  -- more setup

  { -- Right widgets
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.systray(),
    connman, -- <- connman widget
    mytextclock,
    s.mylayoutbox,
  },
}
```

- Awesome 3.x

```lua
right_layout:add(connman)
```

# Limitations

Currently, only wired (ethernet) and WiFi connections are supported.

# Contributing

This project is developed in the author's spare time. Contributions in the form
of issues, patches and pull requests are welcome.
