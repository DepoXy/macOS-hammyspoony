You call that a knife? This is a Hammerspoon config
===================================================

## DESCRIPTION

  Opinionated [Hammerspoon](https://www.hammerspoon.org/) config.

  - You'll find a number of bindings to front or open specific apps
    or windows by using a global binding.

  - For example, &lt;`Shift-Ctrl-Cmd-A`&gt; brings forward the browser
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

    - In that vein, most `<Ctrl-key>` bindings are mapped to application
      menu items, and most `<Cmd-key>` bindings are free for us to use.

## USAGE

  Make a symlink at `~/.hammerspoon/init.lua` to this project's
  `init.lua`, and it'll be wired (see the `ln` snippet, below).

  You can also add your own `client-hs.lua` file to add
  your own bindings (or just fork this repo and make it
  your own, or copy-paste what you need for yourself).
  See [Private config](#private-config) below for more details.

  But first, be aware this project uses absolute paths:

  - Because Hammerspoon runs on its own, it won't have access to
    your local shell environment, and because this project doesn't
    "install" itself anywhere, it just assumes a particular
    path to the few AppleScript files it uses:

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
      ln -s ~/.kit/mOS/macOS-Hammyspoony/.hammerspoon/init.lua \
        ~/.hammerspoon/init.lua

## COMMANDS

### Generic commands

  `<Shift-Ctrl-Cmd-W>`: Hide or minimize all windows except the active window

  - This command *minimizes* [Alacritty](https://alacritty.org/) windows so you
    can raise individual terminal windows without making them all visible again.

  - And it'll *hide* all other apps' windows. (I.e., when you unhide on app's
    window, you'll unhide all that app's hidden windows.)

  `<Shift-Ctrl-Cmd-T>`: Unminimize all Alacritty windows

  `<Shift-Ctrl-Alt-W>`: Hide or minimize all windows (including the active window)

### Terminal window foregrounders

  `<Cmd-1>`: Bring to front any terminal window whose title starts with "1. "

  `<Cmd-2>`: Bring to front any terminal window whose title starts with "2. "

  ...

  `<Cmd-9>`: Bring to front any terminal window whose title starts with "9. "

  - The [Homefries](https://github.com/landonb/home-fries) project
    includes a `PS1` setup that numbers new terminal windows when
    they're opened. It works for Alacritty, mate-terminal, and iTerm2
    terminal windows. See:

    https://github.com/landonb/home-fries/blob/release/lib/term/show-command-name-in-window-title.sh

  `<Cmd-0>`: Open a new Alacritty window

  `<Shift-Cmd-0>`: Bring Alacritty to front

  `<Ctrl-Cmd-0>`: Open a new Terminal.app window (for those rare instances
  that you need to run or try something in the built-in macOS terminal)

### Browser foregrounders

  `<Cmd-T>`: Open a new Chrome window

  `<Shift-Cmd-T>`: Bring Chrome to the front

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

  `<Ctrl-Space>`: Shows browser window picker

  - Shows FZF-list of Chrome browser windows ordered alphabetically
    by window title that you can Click, or select with Up/Down, or
    Query to open

  - Download `AppWindowChooser` Spoon: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppWindowChooser.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppWindowChooser.spoon.zip)

### Application foregrounder-openers

  `<Cmd-F>`: Bring any Finder window to front, or open Finder

  `<Cmd-Grave(Backtick)>` (``<Cmd-`>``): Bring MacVim to the front

  `<Shift-Ctrl-Cmd-F>`: Bring Slack to the front, or open it

  `<Shift-Ctrl-Cmd-X>`: Bring Spotify to the front, or open it

### Time and date clipboard fillers

  `<Cmd-Minus>` (`<Cmd-->`): Put YYYY-MM-DD into clipboard, e.g., "2024-07-08"

  `<Ctrl-Cmd-Semicolon>` (`<Ctrl-Cmd-;>`): Put dashed date and normal time
  into clipboard, e.g., "2024-07-08 17:14"

  `<Ctrl-Cmd-Apostrophe(Quote)>` (`<Ctrl-Cmd-'>`): Put dashed date-plus-time
  into clipboard, e.g., "2024-07-08-17-14"

### Hammyspoony Spoons

  The author hacked most of Hammyspoony together while transitioning from
  Linux to macOS, and it all ended up in a single `init.lua` file that
  grew from a few hundred lines to a few thousand lines of Lua.

  I've since started gradually migrating separate features to their
  individual Spoon files.

  Hopefully-eventually all the features listed above will be available
  as their own Spoons. But until then, you may need to dissect `init.lua`
  to incorporate what you want into your own environment.

### Event subscribers

  `NeverLoseFocus`: This Hammyspoony Spoon ensures you're never without focus!

  - Whenever you close or minimize the last visible window of a macOS
    application, that application is still active, even though some
    other application's window might now be the frontmost window.

  - This Spoon tracks window focus and unfocus events so that when the
    last visible window of an application is closed or minimized, this
    Spoon will focus the next most recently used and still-visible
    application's window.

  - Download `NeverLoseFocus` Spoon: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/NeverLoseFocus.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/NeverLoseFocus.spoon.zip)

### Hammerspoon Spoons bindings

  `<Cmd-Alt-C>`: Briefly show a digital clock in the center of the screen
  (using the [AClock](https://www.hammerspoon.org/Spoons/AClock.html) Spoon)

## PRIVATE CONFIG

  The config finishes by loading an optional "private" config
  from your DepoXy Client (see the [DepoXy](https://github.com/DepoXy/depoxy)
  project):

  `~/.depoxy/running/home/.hammerspoon/client-hs.lua`

## DEPENDENCIES

  - As mentioned above, this project assumes it's cloned to a particular path:

    `~/.kit/mOS/macOS-Hammyspoony`

  - The `<Cmd-1>` through `<Cmd-9>` bindings expect terminal window titles
    to be numbered.

    - See [Homefries](https://github.com/landonb/home-fries) for a
      `PS1` prompt that titles window, specifically:

      https://github.com/landonb/home-fries/blob/release/lib/term/set-shell-prompt-and-window-title.sh
      https://github.com/landonb/home-fries/blob/release/lib/term/show-command-name-in-window-title.sh

  - The Browser foregrounders specifically call `/Applications/Google Chrome.app`
    with the "Default" user profile.

    - Though see notes inline how you might use the powerful
      [URLDispatcher](https://www.hammerspoon.org/Spoons/URLDispatcher.html)
      Spoon to chose the profile or even browser app depending on the URL.

## SEE ALSO

  This project complements a collection of Karabiner-Elements
  modifications that does keyboard trickery beyond the reach of Hammerspoon

  https://github.com/DepoXy/Karabiner-Elephants#🐘

  This project subsumed a collection of simpler `skhd` bindings
  that the author originally developed before learning about the
  more feature-rich Hammerspoon project

  https://github.com/DepoXy/macOS-skhibidirc#👤

  This project is one part of a larger dev stack bound together
  by the DepoXy Development Environment Orchestrator

  https://github.com/DepoXy/depoxy#🍯

## AUTHOR

Copyright (c) 2024 Landon Bouma &lt;depoxy@tallybark.com&gt;

This software is released under the MIT license (see `LICENSE` file for more)

## REPORTING BUGS

&lt;https://github.com/DepoXy/macOS-Hammyspoony/issues&gt;

