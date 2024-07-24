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

-- - Most of these bindings started out in a `skhdrc` file:
--
--     https://github.com/DepoXy/macOS-skhibidirc#👤
--
--   But it's easier to front a single window in Hammerspoon without
--   also bringing all the other app windows forward, too.
--
--   CXREF: You can see the original `skhd` bindings (and comments)
--   in the `skhdrc.OFF`, on path in a DepoXy environment at:
--
--     ~/.kit/mOS/macOS-skhibidirc/.config/skhd/skhdrc.OFF

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

-- ALTLY: See also macOS <Cmd-Alt-h>, which hides all *other* app windows.

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

hs.hotkey.bind({"shift", "ctrl", "alt"}, "W", function()
  hide_osa = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/lib/hide-all-windows.osa"

  hs.osascript.applescriptFromFile(hide_osa)
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

-- Alacritty (terminal) window fronters.
-- - DPNDS: Requires that the terminal window titles starts with a unique number,
--   e.g., suppose the current directory is user home, the title might be "1. ~".
--   - CXREF: Homefries has a terminal window titler that numbers windows
--     for Alacritty, mate-terminal, and iTerm2:
--       https://github.com/landonb/home-fries#🍟
--         https://github.com/landonb/home-fries/blob/release/lib/term/show-command-name-in-window-title.sh
--           ~/.kit/sh/home-fries/lib/term/show-command-name-in-window-title.sh

-- SAVVY: Alacritty windows don't always behave properly
--
-- - Alacritty is technically "not scriptable", i.e., you cannot use AppleScript
--   to loop over it's window with the familiar tell-application, e.g.,
--
--     tell application "Alacritty"
--       repeat with w in windows
--         ...
--
--   doesn't work.
--
--   - But alternative approaches work, e.g.,
--
--       tell application "System Events"
--         tell processes whose name is "Alacritty"
--           repeat with w in windows
--             ...
--
-- - Furthermore — and unsure if this is related, but seems like it is —
--   AppleScript and hs.window.filter will sometimes not see all of the
--   Alacritty windows.
--
--   - E.g., consider you have a "1. foo" window visible.
--
--     - Two of the functions below won't always find it
--       (they normally do, but occasionally Alacritty
--       windows will stop being findable by these functions).
--
--       - `terminal_by_number_using_filter`, which uses hs.window.filter,
--         might not see all the Alacritty windows.
--
--       - `alacritty_by_number_using_osascript`, which calls an AppleScript
--         script, also might not see all the Alacritty windows.
--
--     - Fortunately, `terminal_by_number_using_post_filter` does always
--       seem to work. It calls hs.window.find and then inspects the
--       application object associated with each window to identify a
--       term window (to weed out other apps, e.g., in case a Chrome
--       window has a matching number prefix, for whatever reason).
--
--   - I don't know enough about macOS Apps and Windows to have
--     a good clue as to why Alacritty windows are sometimes less
--     findable. And I'm also not positive that the selected function,
--     `terminal_by_number_using_post_filter` won't fail in the future.

-- TRACE: I've left log code commented so it's easier to add
--        again if you need it.
--        - Also some hs.alert.show trace.
--
-- hs.logger.defaultLogLevel = "verbose"

-- The following (commented) function uses hs.window.filter(),
-- which is a powerful tool, and probably overkill for our purposes.
--
-- - Oddly, hs.window.filter() will sometimes not pick up all
--   Alacritty windows (hence it's commented, and not used).
--
-- - Also, hs.window.find() (aka hs.window()) can be used similarly
--   to hs.window.filter(), if we examine the application object
--   attached to each window object (which seems to be more reliable
--   than hs.window.filter(), at least for finding Alacritty windows;
--   see the function below, `terminal_by_number_using_post_filter`).
--
--
--   local terminal_by_number_using_filter = function(win_num)
--     -- local log = hs.logger.new('term_num_raise')
--     -- log:d("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/0")
--
--     -- Filter terminal windows for matching title pattern
--     local name_filter = { allowTitles = "^" .. win_num .. ". ", }
--
--     -- Note that we pass a complete filter table, and not just app names.
--     -- - A close, but not equivalent call, is
--     --     hs.window.filter.new({'Alacritty', 'iTerm2', 'Terminal'}):setOverrideFilter(name_filter)
--     --   but when passing a list of app names (without the filter table),
--     --   hs.window.filter will only look for visible windows.
--     --   - But we want to find minimized or hidden windows, too.
--     local wf_terminals = hs.window.filter.new({
--       ["Alacritty"] = name_filter,
--       ["iTerm2"] = name_filter,
--       ["Terminal"] = name_filter,
--     })
--
--     -- local app_filters = wf_terminals:getFilters()["Alacritty"]
--     -- for k,v in pairs(app_filters) do
--     --   -- Shows "k — allowTitles"
--     --   hs.alert.show("k — " .. k)
--     --   -- WRONG: "attempt to concatenate a table value":
--     --   --   hs.alert.show("k — " .. k .. " / v — " .. v)
--     --   -- - Because v is a list, and in Lua, lists are indexed tables.
--     --   -- Shows, e.g., "^1 ."
--     --   hs.alert.show("k — " .. k .. " / v — " .. v[1])
--     --   -- This also works, shows same, e.g., "^1 ."
--     --   hs.alert.show("k — " .. k .. " / v — " .. table.concat(v, "/"))
--     -- end
--     -- log:d("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/2")
--
--     local wins = wf_terminals:getWindows()
--
--     -- for k,v in pairs(wins) do
--     --   hs.alert.show("k — " .. k .. " / title — " .. v:title())
--     -- end
--     -- log:d("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/3")
--
--     if #wins > 0 then
--       wins[1]:raise():focus()
--
--       return true
--     end
--
--     return false
--   end

-- This AppleScript behaves similar to `terminal_by_number_using_filter`
-- and won't always find all Alacritty windows, if any of them have
-- "disassociated".
--
-- - CXREF: ~/.kit/mOS/macOS-Hammyspoony/lib/alacritty-front-window-number.osa
--
--
--   local alacritty_by_number_using_osascript = function(win_num)
--     local task = hs.task.new(
--       "/usr/bin/osascript",
--       nil,
--       {
--         os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/lib/alacritty-front-window-number.osa",
--         tostring(win_num),
--       }
--     )
--     task:start()
--   end

-- This always seems to work with Alacritty windows, even when they're
-- not found by hs.window.filter or AppleScript (see the two previous
-- (commented) functions).
--
local terminal_by_number_using_post_filter = function(win_num)
  prefix_pattern = "^" .. win_num .. ". "
  -- SAVVY: hs.window.find returns zero, one, or more windows,
  -- but you'll only capture one window with this basic call:
  --   local win = hs.window.find(prefix_pattern)
  -- To capture all windows, convert return values to a table:
  local wins = { hs.window.find(prefix_pattern) }
  -- table.pack also works:
  --   local win = table.pack(hs.window.find(prefix_pattern))
  -- What's happening is illustrated by this call (but don't do this):
  --   local win1, win2, win3 = hs.window.find(prefix_pattern)

  local term_apps = { Alacritty = true, iTerm2 = true, Terminal = true, }

  for _, win in pairs(wins) do
    local app_title = win:application():title()
    -- hs.alert.show("win — " .. win:title() .. " / app — " .. app_title)
    if term_apps[app_title] then
      win:raise():focus()

      return true
    end
  end

  -- If no terminal window matched, use any application window that matches.
  if wins then
    wins[1]:raise():focus()

    return true
  end

  return false
end

local alacritty_by_window_number_prefix = function(win_num)
  terminal_by_number_using_post_filter(win_num)
end

hs.hotkey.bind({"cmd"}, "1", function()
  alacritty_by_window_number_prefix(1)
end)

hs.hotkey.bind({"cmd"}, "2", function()
  alacritty_by_window_number_prefix(2)
end)

hs.hotkey.bind({"cmd"}, "3", function()
  alacritty_by_window_number_prefix(3)
end)

hs.hotkey.bind({"cmd"}, "4", function()
  alacritty_by_window_number_prefix(4)
end)

hs.hotkey.bind({"cmd"}, "5", function()
  alacritty_by_window_number_prefix(5)
end)

hs.hotkey.bind({"cmd"}, "6", function()
  alacritty_by_window_number_prefix(6)
end)

hs.hotkey.bind({"cmd"}, "7", function()
  alacritty_by_window_number_prefix(7)
end)

hs.hotkey.bind({"cmd"}, "8", function()
  alacritty_by_window_number_prefix(8)
end)

hs.hotkey.bind({"cmd"}, "9", function()
  alacritty_by_window_number_prefix(9)
end)

-------

-- Alacritty — New Window

hs.hotkey.bind({"cmd"}, "0", function()
  local task = hs.task.new(
    "/usr/bin/open",
    nil,
    function() return false end,
    { "-na", "alacritty" }
  )
  task:start()
end)

-- Alacritty foregrounder/opener

hs.hotkey.bind({"shift", "cmd"}, "0", function()
  hs.application.launchOrFocus("Alacritty")
end)

-- Terminal.app — New Window
-- - For the rare time you want to test Apple Terminal.app

hs.hotkey.bind({"ctrl", "cmd"}, "0", function()
  local task = hs.task.new(
    "/usr/bin/osascript",
    nil,
    function() return false end,
    {
      '-e', 'tell app "Terminal"',
        '-e', 'do script ""',
        '-e', 'activate',
      '-e', 'end tell',
    }
  )
  task:start()
end)

-------

-- Opens a new Google Chrome window.
--
-- SAVVY:
-- - If Chrome is visible, the `make new window` AppleScript
--   will create a new window in front of the current window
--   without also brinding all other Chrome windows in front
--   of the current window.
-- - If Chrome is hidden, unhide it, which won't front the
--   newly visible windows in front of the current window.
-- - Avoid using `open`, e.g.,:
--     open -na "Google Chrome" --args --new-window
--   - If you haven't called that command in a while, it'll literally
--     take ~5s to run. Which is very disruptive to one's flow!
--   - It also fronts all the other Chrome windows on top of your
--     other windows — even though Alt-Tab will still take you
--     back to whatever app you were just on.
-- - Note that closing the new Chrome window will nonetheless
--   bring another Chrome window to the front (if one is visible),
--   rather than returning you to whatever window you were using
--   before opening the new Chrome window.

hs.hotkey.bind({"cmd"}, "T", function()
  local chrome_app = hs.application.get("Google Chrome")

  if not chrome_app then
    hs.application.launchOrFocus("Google Chrome")
  else
    if chrome_app:isHidden() then
      chrome_app:unhide()
    end

    local task = hs.task.new(
      "/usr/bin/osascript",
      function() chrome_app:setFrontmost() end,
      function() return false end,
      {
        '-e', 'tell application "Google Chrome"',
          '-e', 'make new window',
        '-e', 'end tell',
      }
    )
    task:start()
  end
end)

-------

-- Bring MRU Chrome window to the front, or start Chrome.
-- - If all Chrome windows are minimized, this activates Chrome
--   app but won't actually show any window.

hs.hotkey.bind({"shift", "cmd"}, "T", function()
  local chrome_app = hs.application.get("Google Chrome")

  if not chrome_app then
    hs.application.launchOrFocus("Google Chrome")
  else
    if chrome_app:isHidden() then
      chrome_app:unhide()
    end

    chrome_app:setFrontmost()
  end
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

-- Wire a Hammerspoon URI action to setFrontmost the specified app.
--
-- - One user of this function is `sensible-open`:
--
--   https://github.com/landonb/sh-sensible-open#☔
--
-- `sensible-open` is used to open URLs from the command line, and by some
-- shell apps (like git-open). But that call might not always front Chrome
-- (i.e., it'll open a new Chrome window behind the active window; and
-- once that starts happening, only quitting and restarting Chrome seems
-- to make it work again).
-- 
-- - `sensible-open` relies on the `open` command, e.g.,
--
--     open -na 'Google Chrome' --args --new-window <URL>
--
--   but that function will sometimes open the new window *behind* the
--   active window, as described above.
--
-- - So here we offer the Hammerspoon setFrontmost function, which will
--   always bring the new window (and only the new window) to the front.
--
--   - Now `sensible-open` can check if Hammerspoon and this config is
--     installed, and can hook this function to fix the problem.
--
-- - MAYBE: We could eventually wire URLDispatcher and offer that to
--   sensible-open, for an even more powerful and customizable user
--   experience.

hs.urlevent.bind("setFrontmost", function(eventName, params)
  local app = hs.application(params['app'])

  if app then
    -- DUNNO: Is this similar to `front_win:raise():focus()`?
    app:setFrontmost()
  end
end)

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

-- Create Meld window filter to disable certain hotkeys.
--
-- - Because Meld doesn't let us remap its menu keys, and we don't
--   want to block certain menu bindings, like <Cmd-F> Find.
--   (Otherwise I would've liked to change <Cmd-F> to <Ctrl-F>.)
--
-- - The author doesn't use Meld very often, so disabling certain
--   hotkeys while it runs is not a big deal.
--
-- - Note that checking the active app doesn't work, because hotkey
--   is still bound, e.g., <Cmd-F> won't run Meld Edit > Find if we
--   did the following:
--
--     hs.hotkey.bind({"cmd"}, "F", function()
--       local fmost_app = hs.application.frontmostApplication()
--
--       if fmost_app:title() ~= "Meld" then
--         hs.application.launchOrFocus("Finder")
--       end
--     end)
--
-- - So we'll use a window.filter instead. Note that application.watcher
--   might also work.
--
--     https://www.hammerspoon.org/docs/hs.window.filter.html
--     https://www.hammerspoon.org/docs/hs.application.watcher.html
--
-- - THANX: https://stackoverflow.com/a/64095788

-- Toggle hotkey enablement when window is focused and unfocused.
local filter_ignore_hotkey = function(win_filter, hotkey)
  -- DUNNO: Hotkey doesn't seem to work at first, unless
  -- explicitly enabled.
  hotkey:enable()

  win_filter
    :subscribe(hs.window.filter.windowFocused, function()
      -- Disable hotkey in app
      hotkey:disable()
    end)
    :subscribe(hs.window.filter.windowUnfocused, function()
      -- Enable hotkey when focusing out of app
      hotkey:enable()
    end)
end

-- Prepare a Meld window filter and hotkey subscriber
local meld_filter = hs.window.filter.new("Meld")

ignore_hotkey_meld = function(hotkey)
  filter_ignore_hotkey(meld_filter, hotkey)
end

-- Prepare a similar LibreOffice window filter (not used herein
-- but used by some client-hs.lua, so defined here).
local libreoffice_filter = hs.window.filter.new("LibreOffice")

ignore_hotkey_libreoffice = function(hotkey)
  filter_ignore_hotkey(libreoffice_filter, hotkey)
end

-------

-- Finder foregrounder/opener

local cmd_f = hs.hotkey.new({"cmd"}, "F", function()
  hs.application.launchOrFocus("Finder")
end)

ignore_hotkey_meld(cmd_f)

-------

-- MacVim foregrounder/opener

hs.hotkey.bind({"cmd"}, "`", function()
  hs.application.launchOrFocus("MacVim")
end)

-------

-- Slack foregrounder/opener

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "F", function()
  hs.application.launchOrFocus("Slack")
end)

-------

-- Spotify foregrounder/๏קєภer

hs.hotkey.bind({"shift", "ctrl", "cmd"}, "X", function()
  hs.application.launchOrFocus("Spotify")
end)

-------

-- <Cmd-Minus> — Put YYYY-MM-DD into clipboard.
-- - Note the printf avoids newline injection.
--   - Though below we also use `tr -d`...
-- - CALSO: Homefries `$(TTT)` function, and Dubs-Vim 'TTT' alias, etc.
--    https://github.com/landonb/home-fries/blob/release/lib/datetime_now_TTT.sh#L45
--    https://github.com/landonb/dubs_edit_juice/blob/release/plugin/dubs_edit_juice.vim#L1513

hs.hotkey.bind({"cmd"}, "-", function()
  local task = hs.task.new(
    "/bin/dash",
    nil,
    function() return false end,
    { "-c", 'printf "%s" "$(date "+%Y-%m-%d")" | pbcopy' }
  )
  task:start()
end)

-- <Ctrl-Cmd-Semicolon> — Put normal date plus:time into clipboard.
-- - HSTRY: Named after erstwhile Homefries $(TTTtt:) command.

hs.hotkey.bind({"ctrl", "cmd"}, ";", function()
  local task = hs.task.new(
    "/bin/dash",
    nil,
    function() return false end,
    { "-c", 'printf "%s" "$(date "+%Y-%m-%d %H:%M")" | tr -d "\n" | pbcopy' }
  )
  task:start()
end)

-- <Ctrl-Cmd-Apostrophe(Quote)> — Put dashed date-plus-time into clipboard.
-- - CALSO: Homefries $(TTTtt-) command.

hs.hotkey.bind({"ctrl", "cmd"}, "'", function()
  local task = hs.task.new(
    "/bin/dash",
    nil,
    function() return false end,
    { "-c", 'printf "%s" "$(date "+%Y-%m-%d-%H-%M")" | tr -d "\n" | pbcopy' }
  )
  task:start()
end)

-------

-- <Cmd-Space> opens an FZF-style browser window switcher.
--
-- - This menu is inspired by Contexts.
--
--     https://contexts.co/
--
--   - Contexts' <Cmd-Space> menu shows a similar FZF switcher.
--
--   - (Though I'm sure Contexts was inspired by something else;
--      in fact, its <Cmd-Space> menu looks surprisingly similar
--      to the Hammerspoon hs.chooser menu! It's even positioned
--      similarly and has the same background color.)
--
-- - See comments below re: hs.window.switcher
--
--   - I demoed hs.window.switcher first before landing on
--     hs.chooser for this feature.
--
--   - And I left lots of comments below, too.
--
-- - When I think of a window switcher, I often think of Linux
--   (or Windows) <Alt-Tab>, or the elegant macOS AltTab app.
--
--   - AltTab is great. It shows window thumbnails organized
--     horizontally.
--
--   - But if you have dozens of browser windows open, you
--     might find it quicker to find the window you're after
--     using its title, rather than hunting for its thumbnail
--     (or trying to read the small window title text above
--     each icon).
--
--     - That is, AltTab is great for switching between the
--       active window and a recently used window.
--
--       And it can work well for finding other windows in
--       certain circumstances.
--
--       But it becomes more difficult (or at least slower)
--       to use as the number of open windows increases.
--
--     - So if you have dozens of browser windows open and
--       visible (as this author sometimes does), AltTab
--       is not necessarily the best tool for finding the
--       window you want.
--
-- - So this binding offers an alternative window switcher
--   approach, using a top-down (vertical) window title
--   list.
--
--   - You can click the title of the window you want to
--     front;
--
--   - Or you can <Up>/<Down> and <Enter> to front it;
--
--   - Or you can enter its title into the query input.
--
-- - Most importantly, this widget is title-centric, and
--   not icon- (or MRU-) centric like AltTab.
--
--   - You're basically looking at an alphabetized list
--     of window titles and picking the one you want.
--
--     And not hunting visually through a list of window
--     icons trying to find what looks like what you want.
--
-- REFER: See the hs.window.switcher demo below, which is
--        what I demoed first before discovering hs.chooser
--
-- BOOYA: I've been using Hammerspoon for five days, and it
-- continues to amaze me! I thought about this feature over
-- dinner, and then it took me 1-1/2 hours to (a) scan the
-- Hammerspoon API to find an appropriate library to use, and
-- (b) to code the solution! (And then it's taken me another
-- 1-1/2 hours to comment about it, but that's normal for me!)
--
-- REFER: https://www.hammerspoon.org/docs/hs.chooser.html
--
--    https://evantravers.com/articles/2020/06/12/hammerspoon-handling-windows-and-layouts/
--
--    - It was inspired by https://github.com/chipsenkbeil/choose
--
-- - An example 'choices' table generator, if you need something
--   to test with your next hs.chooser feature idea:
--
--     local refresh_choices = function()
--       return {
--         {
--          ["text"] = "First Choice",
--          ["subText"] = "This is the subtext of the first choice",
--          -- "uuid" shows how you can use arbitrary keys in the table
--          ["uuid"] = "0001",
--         },
--         { ["text"] = "Second Option",
--           ["subText"] = "I wonder what I should type here?",
--           ["uuid"] = "Bbbb",
--         },
--         -- This example shows how you can stylize text
--         { ["text"] = hs.styledtext.new("Third Possibility", {
--             font = {size = 18},
--             color = hs.drawing.color.definedCollections.hammerspoon.green}
--           ),
--           ["subText"] = "What a lot of choosing there is going on here!",
--           ["uuid"] = "III3",
--         },
--       }
--     end

-- local log = hs.logger.new('refresh_choices')
-- log:w("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/0")

-- Sort table by object attribute.
-- - Use comp_fcn to compare objects (or leave nil and
--   sorts by object comparison).
-- - We use this function to sort by hs.window:title(),
--   though this really is a generic library function.
--
-- THANX: https://www.lua.org/pil/19.3.html
function pairsByKeys(list, comp_fcn)
  local sorted = {}

  for index, _ in pairs(list) do
    table.insert(sorted, index)
  end

  table.sort(sorted, comp_fcn)

  -- Create an iterator
  local index = 0

  local iter = function()
    index = index + 1
    if sorted[index] == nil then
      return nil
    else
      return sorted[index], list[sorted[index]]
    end
  end

  return iter
end

-- REFER: https://www.hammerspoon.org/docs/hs.chooser.html#choices
local refresh_choices = function(app_name)
  local choices = {}

  -- FIXME: See comment below: Unsure how to let user pick app.
  -- - For now defaults Chrome, because that's app author cares about.
  app_name = app_name or "Google Chrome"

  local app = hs.application.get(app_name)

  -- SAVVY: Use empty filter with hs.window.filter.new() so that
  -- it includes minimized and hidden windows, and doesn't restrict
  -- itself to only visible windows.
  local empty_filter = {}
  local win_filter = hs.window.filter.new({[app_name] = empty_filter,})

  -- REFER: getWindows([sortOrder]) allows hs.window.filter constants:
  --   .sortByCreated|.sortByCreatedLast|.sortByFocused|.sortByFocusedLast
  -- But we want to sort by window title!
  -- - [I guess this is a good excuse to learn Lua table.sort (because
  --    author is very new to Lua, despite some toe-dipping in 2017,
  --    Hammerspoon 2024 is my new gateway drug).]
  local app_windows = win_filter:getWindows()
  local sorted_wins = pairsByKeys(app_windows,
    function(lhs, rhs)
      return app_windows[lhs]:title():lower() < app_windows[rhs]:title():lower()
    end
  )

  for _, win in sorted_wins do
    local choice = {
      -- ["text"] = win:title(),
      ["text"] = hs.styledtext.new(win:title(), {
        -- font = { size = 18, },
        font = { size = 14, },
        -- REFER: https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/drawing/color/drawing_color.lua#L170
        -- color = hs.drawing.color.definedCollections.hammerspoon.white,
        -- color = hs.drawing.color.definedCollections.x11.whitesmoke,
        -- color = hs.drawing.color.definedCollections.x11.oldlace,
        color = hs.drawing.color.definedCollections.x11.linen,
      }),
      -- ["subText"] = "This is the subtext",
      -- It could be fragile to attach the win object, but works in practice
      ["win"] = win,
      ["image"] = hs.image.imageFromAppBundle(app:bundleID()),
    }
    table.insert(choices, choice)
  end

  return choices
end

local ctrlSpaceCompletionFn = function(chosen)
  if chosen then
    chosen.win:raise():focus()
  end
end

local win_chooser = hs.chooser.new(ctrlSpaceCompletionFn)

-- The placeholderText is what's shown in the query text field
-- until the user types a query. So there's not really any reason
-- to have it say anything; it should be obvious to user what to do.
--
--   win_chooser:placeholderText('bruh')

-- Modal width defaults to '40.0' [%]:
--   log:w("win_chooser:width(): " .. win_chooser:width())
-- which feels a little too wide (at least on author's 2560x1440
-- display).
-- - MAYBE: Adjust this based on user's display size.
win_chooser:width(27.0)

-- OWELL: The first 9 choices are assigned a <Cmd-1>..<Cmd-9>
-- binding, but there's no option to disable those bindings.
-- - And they don't work, anyway, because of the Terminal window
--   bindings defined above.

-- <Ctrl-Space>, as inspired by Contexts.
hs.hotkey.bind({"ctrl"}, "Space", function()
  if not win_chooser:isVisible() then
    -- Note that hs.chooser:choices() can be passed a table or a function,
    -- but when passed a function, the fcn is only called once. So it's up
    -- to us to refresh as necessary, which we must do before every :show().
    -- So we'll call the choices fcn. ourselves each time and pass the table.
    -- - We also want to adjust rows() each time to size the popup
    --   appropriately (otherwise it'll have too much empty space,
    --   or the user might have to scroll), which is another reason
    --   to pre-process choices.
    --
    -- FIXME/2024-07-24: How should we choose the app?
    -- - For now I've hardcoded Chrome, because that's my main browser.
    local app_name = "Google Chrome"
    local choices = refresh_choices(app_name)

    -- Without measuring *your* screen, 30 or more is generally too many
    -- (given a 1440-tall display, i.e., 2560x1440).
    -- - Defaults to '10':
    --     log:w("win_chooser:rows(): " .. win_chooser:rows())
    if #choices < 30 then
      -- DUNNO: Using the table(list) count adds more padding than we need,
      -- so substract 1.
      win_chooser:rows(#choices - 1)
    else
      win_chooser:rows(30)
    end

    win_chooser:choices(choices)

    win_chooser:show()
  else
    -- <Esc> also hides. (I love when <Esc> just works how you'd expect!)
    win_chooser:hide()
  end
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

-- hs.window.switcher is an interesting Alt-Tab alternative:
--
--     switcher_space = hs.window.switcher.new(
--       hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}
--     )
--     hs.hotkey.bind('alt', 'tab', function() switcher_space:next() end)
--     hs.hotkey.bind('alt-shift', 'tab', function() switcher_space:previous() end)
--
-- But I'm not sure how it's any better than the (free) AltTab app.
--
-- - I really like the AltTab app and use it daily.
--
--   - AltTab is very polished. It's not something I think you could
--     easily replicate in Hammerspoon (like, not if a user's init.lua
--     and not without a lot of custom drawing).
--
--     - hs.window.switcher feels like a visually less-polished AltTab.
--
--   - I also think both tools have similarly powerful window filtering
--     options (though I didn't do a deep-dive to compare for differences,
--     but I think you can equally filter by app, Space, visiblity,
--     minimized state, hiddenness, etc.).
--
--   - So I'm not sure how hs.window.switcher is better. (Other than
--     that you can easily make it your own in your Hammerspoon config.)
--
-- HSTRY/2024-07-23: I took another look at hs.window.switcher today
-- because I wanted to recreate a Contexts.app feature that I really
-- like: Seeing a vertical list of application window names.
--
-- - Specifically, Contexts has a <Cmd-Space> menu, and also a similar
--   tray menu that pops-out from the side of the screen when you mouse
--   there, that shows a vertical list of application window titles,
--   ordered alphabetically (and in the tray, grouped by app; but not
--   grouped by app in the <Ctrl-Space> FZF menu, though there's probably
--   an app setting for that, but I didn't check before uninstalling it).
--
--   - This widget is useful to me because I often have lots (dozens or
--     more) of browser windows open, and AltTab doesn't really make it
--     easy to find the browser window I'm looking for.
--
--     - For many windows, I've created keybindings (see above) that
--       front specific browser windows, e.g., Email, Chats, Music, etc.
--
--     - But when I'm coding and have lots of *temporary* browser
--       windows open (API refs, Stack Overflow topics, etc.), I
--       often want to return to a specific window that doesn't
--       have a global keybinding, and that's where AltTab, Contexts,
--       or some other solution comes in handy.
--
--     So what I like about the Contexts menu is that it shows me a
--     vertical list of alphabetized window titles, and it makes it
--     easy for me to pick the one I'm looking for.
--
-- - So that's what I'm looking for, basically: a list of window titles.
--
--   - I don't need a window thumbnail (screenshot) or anything, just
--     a list of window titles.
--
--   - Because when I have dozens (and dozens) of browser windows open,
--     using something like AltTab — or anything that shows window icons
--     — isn't as useful as just a basic top-down list of window titles.
--
-- - Fortunately I found an easy solution using hs.chooser, which you'll
--   find implemented above.
--
--   - See above for the <Ctrl-Space> hs.chooser feature.
-- 
-- - But before I toyed around with hs.chooser, I demoed hs.window.switcher,
--   which is captured here, for reference, and so you can easily uncomment
--   and demo for yourself.
--
--   - Note that the Hammerspoon docs don't use any screenshots or
--     otherwise try to illustrate how exactly the API functions or
--     Spoons work.
--
--     It's really up to you to wire and demo their API or the Spoons.
--
--     So I like to capture code I've used to demo Hammerspooon, so
--     it's easy to revisit what I discovered earlier.
--
--   - So here's an example hs.window.switcher that shows some of the
--     UI options you can choose (and illustrates its limitations, too).
--
-- - REFER: Options for hs.window.switcher.ui:
--
--     https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/window/window_switcher.lua#L53
--
-- - HSTRY/2024-07-23: My goal was to make a list of Chrome window names,
--   ordered top to bottom, but no dice with hs.window.switcher.
--
--   - Which is what led me to the hs.chooser implementation you'll find
--     above (I figured if I scanned the Hammerspoon API, I might find
--     something more appropriate for the feature I had in mind, and I
--     did find an awesomely powerful and polished widget class, ready-
--     made for exactly what I want!).
--
--   - In any case, here's what I tried in hs.window.switcher, for reference.
--
-- - Here's an hs.window.switcher example that shows Chrome windows.
--
--   - hs.window.switcher shows a left-to-right list of square icons with
--     a truncated window title written in small font above the icon.
--
--     - There's no option to show icons top-to-bottom, or to increase
--       the title text beyond the width of the icon.
--
--   - Showing the title with small icons isn't very useful, at least
--     not with browser windows, because the title is truncated, and
--     it's in a small font.
--
--   - Even if you increase the thumbnail size, it doesn't help much
--     with long browser window titles.
--
--   - So this switcher is not what I was looking for, at least not
--     for finding a specific Chrome window in a sea of Chrome windows.
--
--   - But here it is:
--
--     -- Use an { app_name = filter } table parameter so that
--     -- hs.window.filter.new() includes hidden and minimized
--     -- windows (all the other hs.window.filter.new() variants
--     -- restrict to visible windows).
--     local empty_filter = {}
--     local gc_windows = hs.window.filter.new({
--       ["Google Chrome"] = empty_filter,
--     })
--     switcher_space = hs.window.switcher.new(
--       gc_windows,
--       {                              -- Default:
--         showTitles = true,           -- true
--         showThumbnails = true,       -- true
--         thumbnailSize = 32,          -- 128
--         selectedThumbnailSize = 32,  -- 384
--         showSelectedTitle = true,    -- true
--       }
--     )
--     hs.hotkey.bind('alt', 'tab', function() switcher_space:next() end)
--     hs.hotkey.bind({"alt"}, 'Q', function() switcher_space:previous() end)

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
