You call that a knife? This is a Hammerspoon config
===================================================

## DESCRIPTION

  Opinionated [Hammerspoon](https://www.hammerspoon.org/) config.

  - You'll find a number of bindings to front or open specific apps
    or windows by using a global binding.

  - E.g., &lt;`Shift-Ctrl-Cmd-A`&gt; brings forward the browser
    window with an active email tab.

  - This project is not really designed to be used directly,
    except by the author:

    - It's intended instead for other devs to reference, copy, or to fork.

  - Specifically, many of the keybindings are more Linux-y.

    - The author uses
      [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
      and a number of modifications (published as
      [Karabiner-Elephants](https://github.com/DepoXy/Karabiner-Elephants))
      to swap most default `Ctrl-` and `Cmd-` key combos, so that
      their macOS behaves more like Linux Mint MATE (the author's
      other main development environment).

  See also a related [`skhd`](https://github.com/koekeishiya/skhd) config
  that I still use for simpler bindings:

  https://github.com/DepoXy/macOS-skhibidirc#👤

  - (Had I learned Hammerspoon first, I'm not sure I would have
    created that project. While I appreciate that `skhdrc` bindings
    are generally more concise than Hammerspoon bindings, Hammerspoon
    is definitely more feature-rich.)

## USAGE

  Make a symlink at `~/.hammerspoon/init.lua` to this project's
  `init.lua`, and it'll be wired (see instructions below).

  You can also add your own `client-hs.lua` file to add
  your own bindings (or just fork this repo and make it
  your own, or copy-paste what you need for yourself).
  See [Private config](#private-config) below for more details.

  But first, be aware this project uses absolute paths:

  - Because Hammerspoon runs on its own, it won't have access to
    your local shell environment, and because this project doesn't
    "install" itself anywhere, it just assumes a particular
    path to the AppleScript files:

        ~/.kit/mOS/macOS-Hammyspoony/lib

  - Feel free to fork this repo and change the path prefix to match
    your own environment, otherwise you'll want to clone this project
    at the appropriate path:

        mkdir -p ~/.kit/mOS
        cd ~/.kit/mOS
        git clone https://github.com/DepoXy/macOS-Hammyspoony.git

  - (FYI, the `~/.kit` directory is a [DepoXy](https://github.com/DepoXy/depoxy)
    convention, which is the primary user of this project.)

  Once cloned, you can wire this app very simply by symlinking
  the config file, [`.hammerspoon`](.config/skhd/skhdrc),
  from `~/.hammerspoon/init.lua`:

      mkdir -p ~/.hammerspoon
      ln -sn ~/.kit/mOS/macOS-Hammyspoony/.hammerspoon/init.lua \
        ~/.hammerspoon/init.lua

## COMMANDS

### Generic commands

  `<Shift-Ctrl-Cmd-W>`: Hide or minimize all windows except the active window

  - This command minimizes [Alacritty](https://alacritty.org/) windows so you
    can raise individual terminal windows without making them all visible again.

  - And it'll hide all other apps' windows.

  `<Shift-Ctrl-Cmd-T>`: Unminimize all Alacritty windows

### Browser foregrounders

  `<Shift-Ctrl-Cmd-A>`: Bring the Email or Calendar browser window to
  the front, or open Gmail

  `<Shift-Ctrl-Cmd-S>`: Bring the Messaging browser window to
  the front, or open Messenger

  `<Shift-Ctrl-Cmd-P>`: Bring the [Power Thesaurus](https://www.powerthesaurus.org/)
  browser window to the front, or open it

  `<Shift-Ctrl-Cmd-8>`: Bring the
  [Regex Dictionary by Lou Hevly](https://www.visca.com/regexdict/)
  browser window to the front, or open it

  `<Shift-Ctrl-Cmd-R>`: Bring the browser DevTools window to the front

### Application foregrounder-openers

  `<Cmd-Alt-C>`: Briefly show a digital clock in the center of the screen
  (using the [AClock](https://www.hammerspoon.org/Spoons/AClock.html) Spoon)

### Private config

  The config finishes by loading an optional "private" config
  from your DepoXy Client (see the [DepoXy](https://github.com/DepoXy/depoxy)
  project):

      ~/.depoxy/running/home/.hammerspoon/client-hs.lua

## DEPENDENCIES

  As mentioned above, this project assumes it's cloned to a particular path:

      ~/.kit/mOS/macOS-Hammyspoony

  The Browser foregrounders specifically call `/Applications/Google Chrome.app`
  with the "Default" user profile.

  - Though see notes inline how you might use the powerful
    [URLDispatcher](https://www.hammerspoon.org/Spoons/URLDispatcher.html)
    Spoon to chose the profile or even browser app depending on the URL.

## SEE ALSO

  This project complements a collection of Karabiner-Elements
  modifications that add bindings beyond the reach of Hammerspoon

  https://github.com/DepoXy/Karabiner-Elephants#🐘

  This project complements a collection of simpler `skhd` bindings
  that don't rely upon the Hammerspoon API for more advanced features

  https://github.com/DepoXy/macOS-skhibidirc#👤

  This project is one part of a larger dev stack bound together
  by the DepoXy Development Environment Orchestrator

  https://github.com/DepoXy/depoxy#🍯

## AUTHOR

Copyright (c) 2024 Landon Bouma &lt;depoxy@tallybark.com&gt;

This software is released under the MIT license (see `LICENSE` file for more)

## REPORTING BUGS

&lt;https://github.com/DepoXy/macOS-Hammyspoony/issues&gt;

