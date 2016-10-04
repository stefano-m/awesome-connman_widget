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

You will also need the DBus headers (`dbus.h`) installed.
For example, Debian and Ubuntu provide the DBus headers with the `libdbus-1-dev`
package, Fedora, RedHad and CentOS provide them with the `dbus-devel` package,
while Arch provides them (alongside the binaries) with the `libdbus` package.

# Installation

## Using Luarocks

Probably, the easiest way to install this widget is to use `luarocks`:

    luarocks install connman_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.

### A note about ldbus

This module depends on the [`ldbus`](https://github.com/daurnimator/ldbus)
module that provides the low-level DBus bindings

    luarocks install --server=http://luarocks.org/manifests/daurnimator \
        ldbus \
        DBUS_INCDIR=/usr/include/dbus-1.0/ \
        DBUS_ARCH_INCDIR=/usr/lib/dbus-1.0/include

As usual, you can use the `--local` option if you don't want or can't install
it system-wide.

## From source

Alternatively, you can copy the `connman_widget.lua` file in your
`~/.config/awesome` folder. You will have to install all the dependencies
manually though (see the `rockspec` file for more information).

# Configuration

The widget displays network icons that are searched in the folder defined
by `beautiful.connman_icon_theme_dir` with extension
`beautiful.connman_icon_extension`.
The default is to look into `"/usr/share/icons/Adwaita/scalable"` for
icons whose extension is `".svg"`.

Depending on your network devices, you may need some or all of the icons
whose name starts with `network-`.

You can specify a GUI client to be launched when the widget is right-clicked.
This can be done by changing the `gui_client` field of the widget. The default
is [econnman-bin](https://git.enlightenment.org/apps/econnman.git/) that needs
the [EFL libraries and their Python bindings](https://www.enlightenment.org/);
other [Desktop clients are also available](https://wiki.archlinux.org/index.php/Connman#Desktop_clients).

# Mouse controls

When the widget is focused:

* Right button: launches GUI client (defined by the `gui_client` field; defaults to `econnman-bin`)

# Tooltip

A tooltip with the currently connected network is shown. It will simply
say `Wired` for a wired connection, or it will show the WiFi SSID and signal
strenght for a wireless connection.

# Usage

Add the following to your `~/.config/awesome/rc.lua`:

Require the module:

    -- require *after* `beautiful.init` or the theme will be inconsistent!
    local connman = require("connman_widget")

Add the widget to your layout:

    right_layout:add(connman)

# Limitations

Currently, only wired (ethernet) and WiFi connections are supported.
