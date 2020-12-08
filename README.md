# Switchboard User Accounts Plug
[![Translation status](https://l10n.elementary.io/widgets/switchboard/-/switchboard-plug-useraccounts/svg-badge.svg)](https://l10n.elementary.io/engage/switchboard/?utm_source=widget)

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libaccountsservice-dev
* libgirepository1.0-dev 
* libgnome-desktop-3-dev
* libgranite-dev
* libhandy-1-dev >= 0.90.0
* libpolkit-gobject-1-dev
* libpwquality-dev
* libswitchboard-2.0-dev
* meson >= 0.46.1
* policykit-1
* valac

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build --prefix=/usr 
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
