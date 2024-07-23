-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- REFER: Here are some excellent resources on Hammerspoon, Lua, and beyond:

-- - Getting Started with Hammerspoon
--
--     https://www.hammerspoon.org/go/

-- - Learn Lua in Y minutes
--
--     https://learnxinyminutes.com/docs/lua/

-- - Hammerspoon Spoon Plugins Documentation
--
--     https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md

-- - [Diego Zamboni's] Hammerspoon config file
--
--     https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org
--
--   is an excellent resource, for more than just Hammerspoon.
--
--   - It also shows you the power of Emacs Org mode, and gives you a
--     peek at zzamboni's other dev environment infrastructure.

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Update `hs.loadSpoon()` search path to include Spoons repo.
--
-- SETUP: Note this assumes you have
--
--          https://github.com/Hammerspoon/Spoons
--
--        cloned at
--
--          ~/.kit/mOS/hammerspoons
--
--        which is where DepoXy clones it.
--
--        (Not that we need all the Spoons,
--         but this is just too easy.)

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.kit/mOS/hammerspoons/Source/?.spoon/init.lua"

-------

-- USAGE: Change the log level if you want more scrawl in the Hammerspoon Console, e.g.:
--
--   hs.logger.defaultLogLevel = "info"
--
-- REFER: https://github.com/Hammerspoon/hammerspoon/blob/56b5835/extensions/logger/logger.lua#L13
--
--   local LEVELS={nothing=0,error=ERROR,warning=WARNING,info=INFO,debug=DEBUG,verbose=VERBOSE}
--
-- SAVVY: For reference, log level defaults 'warning' (2):
--
--   require("hs.logger")
--   hs.hotkey.bind({"ctrl", "cmd"}, "A", function()
--     -- Shows: "LogLevel: warning"
--     hs.alert.show("LogLevel: " .. hs.logger.defaultLogLevel)
--   end)

-------

-- Hot-reload config file changes using ReloadConfiguration Spoon:
--
--   ~/.kit/mOS/hammerspoons/Source/ReloadConfiguration.spoon/init.lua
--
-- Note this won't reload a symlimk (which is what DepoXy creates at
-- ~/.hammerspoon/init.lua) so we plumb all the directory paths to watch.
--
-- - The reloader tracks the directories for these files:
--
--    ~/.kit/mOS/macOS-Hammyspoony/.hammerspoon/init.lua
--    ~/.depoxy/ambers/home/.hammerspoon/depoxy-hs.lua
--    ~/.depoxy/running/home/.hammerspoon/client-hs.lua
--
-- USAGE: Obvi, if you install this project to an alt. path (e.g., `~/src`),
-- you'll want to change the first path. (And you probably won't care about
-- the other two paths).
-- - INERT: If you're a DepoXy user trying to use an alternative path,
--   e.g., DOPP_KIT=~/src, that's not plumbed here (though could be).
--   - We'd have to source the Client depoxyrc and read DOPP_KIT from it:
--       ~/.depoxy/running/home/.config/depoxy/depoxyrc
--   - But for now it's just easier to fork this project, or to use
--     git-put-wise to make a "PRIVATE" commit that modifies these paths.

-- See the bottom of this file for where we load the DepoXy and Client configs.
hmy_cfg_dir = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/.hammerspoon"
dxy_cfg_dir = os.getenv("HOME") .. "/.depoxy/ambers/home/.hammerspoon"
dxc_cfg_dir = os.getenv("HOME") .. "/.depoxy/running/home/.hammerspoon"

reloadConfig = hs.loadSpoon("ReloadConfiguration")
reloadConfig.watch_paths = { hs.configdir, hmy_cfg_dir, dxy_cfg_dir, dxc_cfg_dir }
reloadConfig:start()

-------

-- THANX: zzamboni (see above) defines meta-key combo aliases, like these.
-- - For readability, this file chooses not to use them.
-- - But it's an interesting approach, so captured here.
-- - Also it reminds me of the uber-modifier, the jargon term "hyper" key.
--    - Technically includes all 4 modifiers, including shift key:
--        https://deskthority.net/wiki/Hyper_key
--    - Originated on a keyboard for MIT Lisp machines, the Space-cadet:
--        https://deskthority.net/wiki/images/e/e2/Space-cadet_guts.jpg
--        https://deskthority.net/wiki/Space-cadet_keyboard
--        https://en.wikipedia.org/wiki/Space-cadet_keyboard
--        - Haha, <RUB OUT>, such a great key.
--            https://en.wikipedia.org/wiki/Space-cadet_keyboard#/media/File:Space-cadet.jpg
--          And <HOLD OUTPUT>, innuendos abound.
--          Ha, wow, a <TOP> key also.
--          I'll <ABORT> now, time to <BREAK> this quasi-comedic,
--          quasi-cringe <ALT MODE> comment. If it's <GREEK> to you
--          and you want to <HELP>, please <CALL> my <LINE>!
--  - Also <Hyper> isn't a binding that I prefer.
--    - If I want to press three modifier keys, I find that
--      <Shift-Ctrl-Cmd> is easier to press on US English
--      keyboards (three keys in a corner) than pressing
--      <Ctrl-Cmd-Alt> (three keys horizontally).
--
-- hyper           = { "ctrl", "cmd", "alt" }
-- shift_hyper     = { "ctrl", "cmd", "alt", "shift" }
-- ctrl_cmd        = { "ctrl", "cmd" }
-- ctrl_alt        = { "ctrl", "alt" }
-- shift_ctrl_cmd  = { "ctrl", "cmd", "shift" }
-- shift_ctrl_alt  = { "ctrl", "alt", "shift" }

-------

-- Hide or Minimize all but the frontmost window.
--
-- - This function minimizes Alacritty windows,
--   then it hides all other windows, and then
--   finally it brings back the original window.
--
-- - We minimize Alacritty windows so that bringing one back into
--   focus doesn't make them all visible.
--
--   - When you *hide* an application's windows, bringing just one
--     of those windows back into focus will make all of its hidden
--     windows visible.
--
--   - But if we *minimize* an application's windows instead,
--     we can focus just one of those windows with unminimizing
--     them all.
--
-- - Note the odd behavior here:
--
--   - macOS supports an easy way to *hide* all windows using
--     AppleScript, e.g.,
--
--       tell application "System Events"
--         set visible of processes where name is not "Finder" to false
--       end tell
--
--   - But there is no similar mechanism to *minimize* windows.
--
--     In fact, AFAIK, you have to simulate a mouse click on the minimize
--     button, e.g.,
--
--       -- So slow! Minimizes one-by-one, waiting for animation on each.
--       tell application "System Events"
--         repeat with theProcess in processes
--           if not background only of theProcess then
--             try
--               click (first button of (every window of (theProcess)) whose role description contains "minimize")
--             end try
--           end if
--         end repeat
--       end tell
--
--     Note that using hs.window:minimize is similarly slow, e.g.,
--
--       hs.hotkey.bind({"shift", "ctrl", "cmd"}, "W", function()
--         local front_win = hs.window.frontmostWindow()
--         local visible_wins = hs.window.visibleWindows()
--         for key in pairs(visible_wins) do
--           local visible_win = visible_wins[key]
--           if visible_win ~= front_win then
--             visible_win:minimize()
--           end
--         end
--       end)
--
--    - Because of this, and because you cannot disable the minimize
--      animation (though you can choose the Scale Effect, which is
--      slightly faster than the Genie Effect), the minimize operation
--      is somewhat slow.
--
--      - You'll watch as each Alacritty window is minimized one-by-one!
--
--    - (I also tried variations of `set miniaturized of windows to true`,
--      but I couldn't get `set miniaturized` to work.)
--
-- - Note there's a Hammerspoon animation duration setting, e.g.,
--
--     -- Defaults to 0.2.
--     hs.window.animationDuration = 0
--
--   - But this is for Hammerspoon animations only (like move, setFrame).
--   - Unfortunately, macOS controls minimize/unminimize animations,
--     which cannot be disabled.
--     - Although during testing, every once in a while, minimizing or
--       unminimized all Alacritty windows happens instantaneously,
--       but this rarely happens and seems unpredictable.

-- - We don't similarly minimize browser windows because of a particular
--   workflow the author uses: I like to minimize long-running Chrome
--   windows (one for Gmail and Calendar tabs, one for chat tabs, one
--   for radio and music tabs, one for Sheets tabs, etc.). And I like
--   to keep short-lived windows visible (e.g., something I just
--   googled, or Stack Overflow tabs, etc.). This ensures I close
--   browser windows I no longer need. Especially because macOS will
--   front another visible browser window after closing a window (and
--   not return you the app you Alt-Tabbed from, e.g., if I Alt-Tab
--   from GVim to Chrome, and then close the Chrome window, rather
--   than returning focus to the GVim window (as you'd expect on
--   most Linux desktops, or Windows), macOS will front another
--   visible Chrome window). So here we choose to hide, not minimize,
--   Chrome windows, to keep all the short-living windows together,
--   and so that bringing one back into focus will also make the
--   other short-living windows visible.

-- Minimize each Alacritty window, then hide all other windows.
-- - The idea here is to minimize Alacritty windows so that the
--   <Cmd-1>, <Cmd-2>, etc. bindings raise and show a *single*
--   Alacritty window. Because without *minimizing* them first —
--   that is, if we just *hide* them all — then raising just one
--   window (i.e., <Cmd-1>) *shows them all*.
--   - Note that the <Cmd-1>, <Cmd-2>, etc., bindings are currently
--     managed by the `skhdrc` config:
--       https://github.com/DepoXy/macOS-skhibidirc#👤
--     Though we might someday relocate them to macOS-Hammyspoony.
-- - Note that we don't do this for Chrome windows for a specific
--   workflow, as discussed above.
--  - SAVVY: You can click an app icon in the Dock to re-raise
--    hidden (but not minimized) windows.
--    - This is useful for showing all the Chrome windows hidden
--      by this action.
--    - DUNNO: You can click the Chrome icon in the Dock to raise
--      the Chromes windows that were hidden — but it also raises
--      (almost always, but not always, like 90% of the time) *one*
--      of the minimized windows!
--      - And it's always the same window for me, regardless of
--        alphabetical title order, or which window I minimized
--        first, or last; like I don't get *why* this particular
--        minimized window is always raised and not any other!
--      - (If macOS window management just behaved in a predicatable
--        manner, maybe I wouldn't have to write such long-winded
--        comments! =)

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "W", function()
  local front_win = hs.window.frontmostWindow()

  -- Minimize Alacritty windows first.
  -- - Note that I tried calling minimize from the task callback,
  --   but I couldn't get it to work. My hope was to minimize
  --   hidden windows so user didn't have to see all the animation
  --   happening. Oh, well.
  app_wins = hs.application.get("Alacritty"):allWindows()
  for key, _ in pairs(app_wins) do
    local app_win = app_wins[key]
    app_win:minimize()
  end

  -- ALTLY: hs.osascript.applescriptFromFile(fileName)
  local task = hs.task.new(
    "/usr/bin/osascript",
    -- Wait until the script finishes, then re-raise what was the active window
    -- Note this may unhide the frontmost window's app's other windows, too.
    -- - E.g., if a Chrome window is active, showing it later will make
    --   other hidden Chrome windows visible.
    -- - But if you run this command on GVim or Alacritty, it'll hide or
    --   minimize all other windows, and then only one window will be
    --   visible at the end.
    function()
      front_win:raise():focus()
    end,
    { os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/lib/hide-all-windows.osa" }
  )
  task:start()
end)

-- ***

-- Unminimize all Alacritty windows.
-- - DUNNO: When I first tested this, it was fast, like, it would
--   instantaneously unminimize all windows. But now it's slow, like
--   minimize, and acts on one window at a time.
-- - Note this doesn't front or focus any of these windows, unless an
--   Alacritty window is already front, then maybe another one comes
--   into focus.

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "T", function()
  local alacritty_app = hs.application.get("Alacritty")

  local app_wins = alacritty_app:allWindows()

  for key in pairs(app_wins) do
    local app_win = app_wins[key]

    app_win:unminimize()
  end

  -- SAVVY: Until you click one of the unminimized windows,
  -- the previous <Shift-Ctrl-Cmd-W> binding won't minimize
  -- Alacritty windows, nor will the <Cmd-1>, <Cmd-2>, etc.
  -- bindings work. It's as though the windows don't know
  -- they're unminimized yet! But activate (or setFrontmost)
  -- seems to do the trick.
  alacritty_app:activate()
  -- Also works:
  --   alacritty_app:setFrontmost()
end)

-------

-- Open URL in new Chrome window.
--
-- SAVVY: This unhides other hidden Chrome windows (though not
-- minimized Chrome windows). I'm not sure there's a way not to.
-- - I.e., I'm now sure we can open a new Chrome without unhiding
--   other Chrome windows.
--
-- COPYD/THANX: https://news.ycombinator.com/item?id=29535518
function chromeWithProfile(profile, url)
  local task = hs.task.new(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    nil,
    function() return false end,
    { "--profile-directory=" .. profile, "--new-window", url }
  )
  task:start()
end

-------

-- We can trigger Hammerspoon tasks from the command line.
--
-- - E.g.,
--
--     open -g hammerspoon://sensible-open?url=https://google.com
--
--   Using:
--
--     hs.urlevent.bind("sensible-open", function(eventName, params)
--       chromeWithProfile("Default", params['url'])
--     end)

-------

-- Bring front and focus specific Chrome window,
-- or open URL if no matching window is found.
--
-- CXREF:
--   https://www.hammerspoon.org/docs/hs.window.html#raise
--   https://www.hammerspoon.org/docs/hs.window.html#focus

-- INERT/2024-07-20: Add support to open URLs using different profiles,
-- e.g.,
--
--   open -a "Google Chrome" --args --profile-directory=$NAME
--
-- where $NAME for your current Chrome profile can be found by looking
-- at Profile Path in chrome://version
-- - REFER: https://news.ycombinator.com/item?id=29535518
--
-- See also zzamboni's innovative approach to ensuring URLs
-- are opened by a specific Chrome profile, or even by different
-- browsers depending on the URL path, using their own config and
-- the powerful URLDispatcher spoon:
--
--   https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#url-dispatching-to-site-specific-browsers

-- SPIKE: Do we need to keep function reference so doesn't get
-- garbage-collected?
--
-- - I.e., not this?:
-- 
--     function browser_window_front_or_open(url, matches)
--       ...
--     end

browser_window_front_or_open = function(url, matches)
  local win

  for i = 1, #matches do
    win = hs.window(matches[i])
    if win then break end
  end

  if win then
    win:raise():focus()
  elseif url ~= "" then
    chromeWithProfile("Default", url)
  end
end

-------

-- Bring front/focus browser email window.
--
-- - Opens first window found with the following text:
--   - Gmail prefix
--       "Inbox "
--   - Google Calendar [author keeps Gmail and Cal tabs in same window]
--       "Google Calendar - "
--   - Outlook prefix [for when you use Outlook on a host and not Gmail]
--       "Mail - "
--   - Outlook, when you've been logged off (/srsly)
--       "Sign in to Outlook"
--   - Outlook, when you've been signed out (ugh, more timeout plz)
--       "Sign out"
--
-- - If you wanted to strictly only open Gmail, you could look
--   for user's email addy, e.g.,
--     "first.last@gmail.com"

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "A", function()
  browser_window_front_or_open(
    "https://mail.google.com/mail/u/0/#inbox",
    {
      "Inbox ",
      "Google Calendar - ",
      "Mail - ",
      "Sign in to Outlook",
      "Sign out",
    }
  )
end)

-------

-- Messenger or Assorted Chat tab foregrounder
--
-- - Opens first window found with the following text:
--   - Android SMS
--       "Messages for web"
--       "Google Messages for web"
--   - Facebook Messenger
--       "Messenger"
--   - Insta
--       "Inbox • Chats"
--   - Author's local BM index
--       "🗨️         Chat & Social"

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "S", function()
  browser_window_front_or_open(
    "https://www.messenger.com/",
    {
      "Messages for web",
      "Google Messages for web",
      "Messenger",
      "Inbox • Chats",
      "🗨️         Chat & Social",
    }
  )
end)

-------

-- PowerThesaurus [browser window]

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "P", function()
  browser_window_front_or_open(
    "https://www.powerthesaurus.org/",
    {
      "Power Thesaurus",
    }
  )
end)

-------

-- Regex Dictionary by Lou Hevly [browser window]

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "8", function()
  browser_window_front_or_open(
    "https://www.visca.com/regexdict/",
    {
      "Regex Dictionary by Lou Hevly",
    }
  )
end)

-------

-- Google Chrome — Raise *Inspect* Window
--
-- - You must pop DevTools out into a separate window for this to work.

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "R", function()
  browser_window_front_or_open(
    "",
    {
      "DevTools",
      "Inspect with Chrome Developer Tools",
      "devtools://",
    }
  )
end)

-------

-- Nice! 4-second (or shorter, if you hotkey again, or <Esc>) clock overlay.
--  ~/.kit/mOS/hammerspoons/Source/AClock.spoon/init.lua
--
aClock = hs.loadSpoon("AClock")
hs.hotkey.bind({"cmd", "alt"}, "c", function()
  aClock:toggleShow()
end)

-------

-- Meh. Analog clock, absolutely positioned below notifications area.
--  ~/.kit/mOS/hammerspoons/Source/CircleClock.spoon/init.lua
--
--  circleClock = hs.loadSpoon("CircleClock")
--  circleClock:init()

-------

-- Cute, puts Cherry emoji in menu bar, then shows 25:00 countdown when run.
--  ~/.kit/mOS/hammerspoons/Source/Cherry.spoon/init.lua
-- 
--  cherry = hs.loadSpoon("Cherry")
--  -- Calling `init` creates a second cherry menu:
--  --   --cherry:init()

-------

-- Toast notification examples.
--
--  -- Toast using Hammerspoon screen overlay,
--  -- basically screen-centered text with oval outline.
--  hs.hotkey.bind({"ctrl", "cmd"}, "A", function()
--    hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
--  end)
--
--  -- Toast using native macOS terminal-notifier
--  hs.hotkey.bind({"ctrl", "cmd"}, "A", function()
--    hs.alert.show("Hello World!")
--  end)

-------

-- Interesting Alt-Tab alternative:
--
--   switcher_space = hs.window.switcher.new(
--     hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}
--   )
--   hs.hotkey.bind('alt', 'tab', function() switcher_space:next() end)
--   hs.hotkey.bind('alt-shift', 'tab', function() switcher_space:previous() end)

-------

-- Interesting window placement feature using a Grid popup.
-- - You might like this better than Rectangle if you don't
--   want to remember all the individual Rectangle bindings.
--
--     myGrid = { w = 2, h = 3 }
--     windowGrid = hs.loadSpoon("WindowGrid")
--     windowGrid.gridGeometries = { { myGrid.w .. "x" .. myGrid.h } }
--     windowGrid:start()
--
--     hs.hotkey.bind({"ctrl", "cmd"}, "G", function()
--       hs.grid.toggleShow()
--     end)

-------

-- -- SAVVY: The MoveSpaces Spoon is deprecated. Use hs.spaces instead.
-- -- REFER: https://www.hammerspoon.org/docs/hs.spaces.html
--
-- require("hs.spaces")
-- require("hs.window")
-- hs.hotkey.bind({"ctrl", "cmd"}, "A", function()
--   -- Main Desktop is '1', other Spaces are whatever, e.g., '1105'...
--   --
--   -- -- This call doesn't work for me though:
--   --  hs.spaces.moveWindowToSpace(hs.window.frontmostWindow(), 1105)
--   --
--   -- -- WORKS: But shows Mission Control interaction:
--   --  hs.spaces.removeSpace(1105)
--   --
--   -- -- Show Space ID:
--   --  hs.notify.new({title="Hammerspoon", informativeText="Space: " .. hs.spaces.focusedSpace()}):send()
-- end)

-------

-- Hold <Cmd-Q> to quit apps.
--  ~/.kit/mOS/hammerspoons/Source/HoldToQuit.spoon/init.lua
--
-- - I did not test... but I might if I find myself quiting
--   apps unexpectedly/accidentally.
--
--  holdToQuit = hs.loadSpoon("HoldToQuit")
--  holdToQuit:init()

-------

-- Load optional configs.
--
-- - This project, while stand-alone, serves for DepoXy (and for the
--   general public, either as something to fork, or as something to
--   reference, like you would anyone's dot-files).
--
--   So here we load DepoXy's config, where DepoXy-specific bindings live.
--
--   And we also load DepoXy Client config, which is private user config.
--
-- - But we do so carefully, because `require` fails if the file is absent.
--
--   - Note we could use `pcall` to ignore errors, e.g.,
--
--       package.path = package.path ...
--       pcall(require, "depoxy-hs")
--
--     but that would mask errors in the downstream config.
--
--     So we'll confirm paths first, and then call `require` directly.

-- Note that Lua doesn't include a full suite of filesystem utilities.
--
-- - With stock Lua, we can try to open the file to see if it exists.
--
-- - INERT: Perhaps someday we'll add Lua modules, like `luaposix`, which
--   provides POSIX bindings we could use to improve the file-exists check,
--   e.g.:
--
--   - Install luaposix module:
--
--       brew install lua
--       brew install luarocks
--       luarocks install luaposix
--
--   - Check file exists without explicitly opening it:
--
--       -- https://lunarmodules.github.io/luafilesystem/
--       require "lfs"
--
--       function load_config(cfg_dir)
--         local cfg_file = cfg_dir .. "/init.lua"
--
--         if lfs.attributes(cfg_file) then
--           require(cfg_file)
--         end
--       end

file_exists = function(path)
  if type(path) ~= "string" then return false end

  local file = io.open(path, "r")

  return file ~= nil and io.close(file)
end

load_config = function(dir, base)
  local sep = sep or package.config:sub(1,1)

  local path = dir..sep..base..".lua"

  if file_exists(path) then
    package.path = package.path .. ";" .. dir..sep.."?.lua"

    require(base)
  end
end

load_configs = function(sep)
  local sep = sep or package.config:sub(1,1)

  -- CXREF: ~/.depoxy/ambers/home/.hammerspoon/depoxy-hs.lua
  load_config(dxy_cfg_dir, "depoxy-hs")

  -- CXREF: ~/.depoxy/running/home/.hammerspoon/client-hs.lua
  load_config(dxc_cfg_dir, "client-hs")
end

load_configs()

-------

