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
--
-- - Lua PIL:
--
--     https://www.lua.org/pil/contents.html

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

-- CXREF: Currently just this one Spoon, but the rest of this file
--        will ideally be promoted to their own Spoons:
--   ~/.kit/mOS/macOS-Hammyspoony/Source/NeverLoseFocus.spoon/init.lua
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/Source/?.spoon/init.lua"

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
hmy_spn_dir = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/Source"
dxy_cfg_dir = os.getenv("HOME") .. "/.depoxy/ambers/home/.hammerspoon"
dxc_cfg_dir = os.getenv("HOME") .. "/.depoxy/running/home/.hammerspoon"

reloadConfig = hs.loadSpoon("ReloadConfiguration")
reloadConfig.watch_paths = {
  hs.configdir,
  hmy_cfg_dir,
  hmy_spn_dir,
  dxy_cfg_dir,
  dxc_cfg_dir,
}
reloadConfig:start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- USAGE: Use in debug/trace output to pry table keys (see usages below).
-- - Not used "in production" and would ideally be commented but for Devs:
--   Whenever author uncomments trace code that calls it, and then its absense
--   silently breaks bindings, I get annoyed. So leaving live. Live with it.
--   ("Silently": Keybinding press no-ops, but Hammerspoon Console shows err.)
table_join = function(table, sep)
  local keys = ""

  for k, _ in pairs(table) do
    if keys ~= "" then
      keys = keys .. sep
    end
    keys = keys .. k
  end

  return keys
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

-- BNDNG: <Shift-Ctrl-Cmd-W>
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

-- BNDNG: <Shift-Ctrl-Alt-W>
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

-- BNDNG: <Shift-Ctrl-Cmd-0>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "0", function()
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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
local terminal_by_number_using_post_filter = function(win_num, win_hint)
  local found_win

  -- Or if user provided a hint, look for a matching window
  if win_hint then
    found_win = hs.window.find(win_hint)
  end

  if not found_win then
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
    found_win = wins and wins[1]
  end

  if found_win then
    found_win:raise():focus()

    return true
  end

  return false
end

-- The win_hint arg lets user override these bindings in their
-- own private config, using a backup window title pattern.
alacritty_by_window_number_prefix = function(win_num, win_hint)
  return terminal_by_number_using_post_filter(win_num, win_hint)
end

-- BNDNG: <Cmd-1>
hs.hotkey.bind({"cmd"}, "1", function()
  alacritty_by_window_number_prefix(1)
end)

-- BNDNG: <Cmd-2>
hs.hotkey.bind({"cmd"}, "2", function()
  alacritty_by_window_number_prefix(2)
end)

-- BNDNG: <Cmd-3>
hs.hotkey.bind({"cmd"}, "3", function()
  alacritty_by_window_number_prefix(3)
end)

-- BNDNG: <Cmd-4>
hs.hotkey.bind({"cmd"}, "4", function()
  alacritty_by_window_number_prefix(4)
end)

-- BNDNG: <Cmd-5>
hs.hotkey.bind({"cmd"}, "5", function()
  alacritty_by_window_number_prefix(5)
end)

-- BNDNG: <Cmd-6>
hs.hotkey.bind({"cmd"}, "6", function()
  alacritty_by_window_number_prefix(6)
end)

-- BNDNG: <Cmd-7>
hs.hotkey.bind({"cmd"}, "7", function()
  alacritty_by_window_number_prefix(7)
end)

-- BNDNG: <Cmd-8>
hs.hotkey.bind({"cmd"}, "8", function()
  alacritty_by_window_number_prefix(8)
end)

-- BNDNG: <Cmd-9>
hs.hotkey.bind({"cmd"}, "9", function()
  alacritty_by_window_number_prefix(9)
end)

-------

-- Alacritty — New Window

-- NTRST: Some caveats re: creating a new Alacritty window:
-- - Note that using `open -a` only starts or fronts Alacritty,
--   but doesn't create a new window unless it's the first one.
-- - Note that using `open -na` creates a new Alacritty instance
--   (and then you end up with multiple app icons in the Dock),
--   e.g., avoid this: `open -na alacritty`.
-- - This command also opens a new instance:
--     /Applications/Alacritty.app/Contents/MacOS/alacritty
-- - Our only sol'n (that author knows of) is to send a key stroke
--   event to the app to run the (hidden) New Window <Cmd-N> menu item.

-- BNDNG: <Cmd-0>
local cmd_0 = hs.hotkey.bind({"cmd"}, "0", function()
  local task = hs.task.new(
    "/usr/bin/open",
    function(exit_code, stdout, stderr)
      -- Default timeout, opt. 3rd arg, is 200000 microsecs (200 msec).
      hs.eventtap.keyStroke({"cmd"}, "N", hs.application.get("Alacritty"))
    end,
    function() return false end,
    { "-a", "alacritty" }
  )
  task:start()
end)

-- Alacritty foregrounder/opener

-- BNDNG: <Shift-Cmd-0>
hs.hotkey.bind({"shift", "cmd"}, "0", function()
  hs.application.launchOrFocus("Alacritty")
end)

-- Terminal.app — New Window
-- - For the rare time you want to test Apple Terminal.app

-- BNDNG: <Ctrl-Cmd-0>
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

filter_attach_eventtap = function(win_filter, get_eventtap)
  local eventtap
  local prev_app_name

  win_filter
    -- Callback receives 3 parameters:
    --   hs.window                            [object]
    --   window:application():name()          [string]
    --   hs.window.filter.window(Unf|F)ocused [string]
    :subscribe(hs.window.filter.windowFocused, function(win, app_name)
      -- Enable eventtap in app

      -- - SAVVY: HMS calls windowFocused again for current app when app
      --   opens a new window.
      --   - E.g., when user <C-O> Opens file-finder, or opens new browser
      --     window, etc., this event is sent.
      --   - I.e., windowFocused and windowUnfocused events are not 1:1.
      --   - So track current application.
      --   - This avoids runnning multiple eventtap's, and avoids losing
      --     track of one eventtap, which then continues to run and to
      --     change events *for other apps.*
      if app_name == prev_app_name then

        return
      end
      prev_app_name = app_name
      if eventtap then
        -- This is unexpected
        hs.alert.show("GAFFE: Unexpected path: filter_attach_eventtap")

        return
      end

      eventtap = get_eventtap()
      eventtap:start()
    end)
    :subscribe(hs.window.filter.windowUnfocused, function()
      -- Disable eventtap when focusing out of app
      prev_app_name = nil
      if eventtap then
        eventtap:stop()
        eventtap = nil
      end
    end)
end

-------

-- SAVVY: This tedious menu shortcut remapping because
-- GnuCash ignores the normal Keyboard Shortcuts you'd
-- otherwise manage from System Settings, i.e.,
--   defaults write org.gnucash.Gnucash NSUserKeyEquivalents '{ ... }'
-- doesn't change anything.

local gnucash_shortcuts_get_eventtap = function()
  return hs.eventtap.new(
    {hs.eventtap.event.types.keyDown},
    function(e)
      -- USAGE: Uncomment to debug/pry (also table_join def, above):
      --    local unmodified = false
      --    hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
      --    hs.alert.show("FLAGS: " .. table_join(e:getFlags(), ", "))

      -- For each menu item, returns true to delete original event,
      -- followed by the new event.
      if e:getFlags():containExactly({"ctrl"}) then
        if false then

        -- -- Gnucash > Quit Gnucash
        -- elseif e:getKeyCode() == hs.keycodes.map["q"] then
        --   return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["q"], true)}

        -- File > New File
        elseif e:getKeyCode() == hs.keycodes.map["n"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["n"], true)}

        -- File > Open...
        elseif e:getKeyCode() == hs.keycodes.map["o"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["o"], true)}

        -- File > Save
        elseif e:getKeyCode() == hs.keycodes.map["s"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["s"], true)}

        -- File > "Print...
        elseif e:getKeyCode() == hs.keycodes.map["p"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["p"], true)}

        -- File > Close
        elseif e:getKeyCode() == hs.keycodes.map["w"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["w"], true)}

        -- Edit > Edit Account
        elseif e:getKeyCode() == hs.keycodes.map["e"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["e"], true)}

        -- Edit > Find Account
        elseif e:getKeyCode() == hs.keycodes.map["i"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["i"], true)}

        -- Edit > Find ...
        elseif e:getKeyCode() == hs.keycodes.map["f"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["f"], true)}

        -- View > Refresh
        elseif e:getKeyCode() == hs.keycodes.map["r"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["r"], true)}

        -- Action > Transfer...
        elseif e:getKeyCode() == hs.keycodes.map["t"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["t"], true)}

        end
      elseif e:getFlags():containExactly({"shift", "ctrl"}) then
        if false then

        -- File > Save As...
        elseif e:getKeyCode() == hs.keycodes.map["s"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["s"], true)}

        -- File > Print Setup
        elseif e:getKeyCode() == hs.keycodes.map["p"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["p"], true)}

        end
      end

      -- Return false to propagate event.
      return false
    end
  )
end

-- SAVVY: First arg to new() is Application name, which is
-- "Gnucash", and not window title name, which says "GnuCash".
local gnucash_filter = hs.window.filter.new("Gnucash")

filter_attach_eventtap(gnucash_filter, gnucash_shortcuts_get_eventtap)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local slack_shortcuts_get_eventtap = function()
  return hs.eventtap.new(
    {hs.eventtap.event.types.keyDown},
    function(e)
      -- USAGE: Uncomment to debug/pry (also table_join def, above):
         --   local unmodified = false
         --   hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
         --   hs.alert.show("FLAGS: " .. table_join(e:getFlags(), ", "))
         --   hs.alert.show("KEYCD: " .. e:getKeyCode())
      -- For each menu item, returns true to delete original event,
      -- followed by the new event.
      if e:getFlags():containExactly({"ctrl"}) then
        if false then

        -- *** Slack

        -- Slack > Quit Slack
        elseif e:getKeyCode() == hs.keycodes.map["q"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["q"], true)}

        -- *** File

        -- File > New Message
        elseif e:getKeyCode() == hs.keycodes.map["n"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["n"], true)}

        -- *** Edit

        -- Edit > Undo
        elseif e:getKeyCode() == hs.keycodes.map["z"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["z"], true)}

        -- CXREF: Cut/Copy/Paste/Select All done via KE:
        --   https://github.com/DepoXy/Karabiner-Elephants#🐘
        --     ~/.kit/mOS/Karabiner-Elephants/complex_modifications/0150-system-cmd-2-ctl-cxva.json
        --
        -- -- Edit > Cut
        -- elseif e:getKeyCode() == hs.keycodes.map["x"] then
        --   return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["x"], true)}
        --
        -- -- Edit > Copy
        -- elseif e:getKeyCode() == hs.keycodes.map["c"] then
        --   return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["c"], true)}
        --
        -- -- Edit > Paste
        -- elseif e:getKeyCode() == hs.keycodes.map["v"] then
        --   return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["v"], true)}
        --
        -- -- Edit > Select All
        -- elseif e:getKeyCode() == hs.keycodes.map["a"] then
        --   return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["a"], true)}

        -- Edit > Search
        elseif e:getKeyCode() == hs.keycodes.map["g"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["g"], true)}

        -- Edit > Find...
        elseif e:getKeyCode() == hs.keycodes.map["f"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["f"], true)}

        -- *** View

        -- View > Reload
        elseif e:getKeyCode() == hs.keycodes.map["r"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["r"], true)}

        -- View > Actual Size
        elseif e:getKeyCode() == hs.keycodes.map["0"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["0"], true)}

        -- View > Zoom In
        elseif e:getKeyCode() == hs.keycodes.map["="] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["="], true)}

        -- View > Zoom Out
        -- - Note the Slack binding is Shift-Cmd-_, which we send as shift+cmd+-.
        elseif e:getKeyCode() == hs.keycodes.map["-"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["-"], true)}

        -- *** Go

        -- Go > Switch to Channel
        elseif e:getKeyCode() == hs.keycodes.map["k"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["k"], true)}

        -- Go > History > Back
        elseif e:getKeyCode() == hs.keycodes.map["["] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["["], true)}

        -- Go > History > Forward
        elseif e:getKeyCode() == hs.keycodes.map["]"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["]"], true)}

        -- *** Author Special

        -- "Delete Back-Word like readline" (Cmd-w)
        elseif e:getKeyCode() == hs.keycodes.map["w"] then
          return true, {hs.eventtap.event.newKeyEvent({"alt"}, hs.keycodes.map["delete"], true)}

        end
      elseif e:getFlags():containExactly({"alt"}) then
        if false then

        -- *** File

        -- File > Close Window
        elseif e:getKeyCode() == hs.keycodes.map["w"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["w"], true)}

        end
      elseif e:getFlags():containExactly({"shift", "ctrl"}) then
        if false then

        -- *** File

        -- File > New Canvas
        elseif e:getKeyCode() == hs.keycodes.map["n"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["n"], true)}

        -- File > Workspace > Select Next Workspace
        elseif e:getKeyCode() == hs.keycodes.map["]"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["]"], true)}

        -- File > Workspace > Select Previous Workspace
        elseif e:getKeyCode() == hs.keycodes.map["["] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["["], true)}

        -- *** Edit

        -- Edit > Redo
        elseif e:getKeyCode() == hs.keycodes.map["z"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["z"], true)}

        -- Edit > Paste and Match Style
        elseif e:getKeyCode() == hs.keycodes.map["v"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["v"], true)}

        -- *** View

        -- View > Force Reload
        elseif e:getKeyCode() == hs.keycodes.map["r"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["r"], true)}

        -- View > Toggle Full Screen
        elseif e:getKeyCode() == hs.keycodes.map["f"] then
          return true, {hs.eventtap.event.newKeyEvent({"ctrl", "cmd"}, hs.keycodes.map["f"], true)}

        -- View > Hide Sidebar
        elseif e:getKeyCode() == hs.keycodes.map["d"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["d"], true)}

        -- *** Go

        -- Go > All Unreads
        elseif e:getKeyCode() == hs.keycodes.map["a"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["a"], true)}

        -- Go > Threads
        elseif e:getKeyCode() == hs.keycodes.map["t"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["t"], true)}

        -- Go > All DMs
        elseif e:getKeyCode() == hs.keycodes.map["k"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["k"], true)}

        -- Go > Activity
        elseif e:getKeyCode() == hs.keycodes.map["m"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["m"], true)}

        -- Go > Channel Browser
        elseif e:getKeyCode() == hs.keycodes.map["l"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["l"], true)}

        -- Go > People & User Groups
        elseif e:getKeyCode() == hs.keycodes.map["e"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["e"], true)}

        -- Go > Downloads
        elseif e:getKeyCode() == hs.keycodes.map["j"] then
          return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd"}, hs.keycodes.map["j"], true)}

        end
      end

      -- Return false to propagate event.
      return false
    end
  )
end

local slack_filter = hs.window.filter.new("Slack")

filter_attach_eventtap(slack_filter, slack_shortcuts_get_eventtap)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Opens a new Google Chrome window, using the Default Profile.
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
-- - Here's an AppleScript take that runs fast, but it doesn't
--   let us specify the profile (that I know of):
--     local task = hs.task.new(
--       "/usr/bin/osascript",
--       function() chrome_app:setFrontmost() end,
--       function() return false end,
--       {
--         '-e', 'tell application "Google Chrome"',
--           '-e', 'make new window',
--         '-e', 'end tell',
--       }
--     )
--     task:start()
-- - Note that closing the new Chrome window will nonetheless
--   bring another Chrome window to the front (if one is visible),
--   rather than returning you to whatever window you were using
--   before opening the new Chrome window.

make_new_chrome_window = function(profile)
  local chrome_app = hs.application.get("Google Chrome")

  if chrome_app and chrome_app:isHidden() then
    chrome_app:unhide()
  end

  local profile_dir = ""
  if profile then
    profile_dir = "--profile-directory=" .. profile
  end

  local task = hs.task.new(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    function()
      local chrome_app = hs.application.get("Google Chrome")
      if chrome_app then
        chrome_app:setFrontmost()
      end
    end,
    function() return false end,
    {
      "--new-window",
      profile_dir,
    }
  )
  task:start()
end

-- BNDNG: <Cmd-T>
local cmd_t = hs.hotkey.bind({"cmd"}, "T", function()
  make_new_chrome_window("Default")
end)

-------

-- Bring MRU Chrome window to the front, or start Chrome.
-- - If all Chrome windows are minimized, this activates Chrome
--   app but won't actually show any window.

-- BNDNG: <Shift-Cmd-T>
local shift_cmd_t = hs.hotkey.bind({"shift", "cmd"}, "T", function()
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

-- USAGE:
--
--   $ open -g "hammerspoon://setFrontmost?app=${browser_app}"

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

browser_window_front_or_open = function(url, profile, matches)
  local win

  if not matches then
    matches = profile
    profile = "Default"
  elseif not profile then
    profile = "Default"
  end

  for i = 1, #matches do
    win = hs.window(matches[i])
    if win then break end
  end

  if win then
    win:raise():focus()
  elseif url ~= "" then
    chromeWithProfile(profile, url)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

-- BNDNG: <Shift-Ctrl-Cmd-A>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "A", function()
  browser_window_front_or_open(
    "https://mail.google.com/mail/u/0/#inbox",
    {
      "@gmail.com",
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

-- BNDNG: <Shift-Ctrl-Cmd-S>
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

-- BNDNG: <Shift-Ctrl-Cmd-P>
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

-- BNDNG: <Shift-Ctrl-Cmd-8>
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

-- BNDNG: <Shift-Ctrl-Cmd-R>
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

-- Prepare app window filters and hotkey subscribers for apps that don't
-- use native macOS windows (or whatever it is they do different; the
-- author doesn't know Cocoa or macOS apps well enough to know exact
-- reason why some apps ignore Keyboard Shortcuts > App Shortcuts, aka
--     defaults write <bundle-ID> NSUserKeyEquivalents
-- - Use case: Note that setting `NSUserKeyEquivalents` will update the
--   shortcuts listed in the menu drop-downs, so you might want to use
--   both NSUserKeyEquivalent and an eventtap, so the UX reflects the
--   Hammerspoon tap.

-- Prepare an Adobe Acrobat Reader window filter and hotkey subscriber.
-- - Not used herein but used by some client-hs.lua, so defined here.
local acrobat_reader_filter = hs.window.filter.new("Acrobat Reader")

ignore_hotkey_acrobat_reader = function(hotkey)
  filter_ignore_hotkey(acrobat_reader_filter, hotkey)
end

-- Prepare a GIMP window filter and hotkey subscriber.
local gimp_filter = hs.window.filter.new("GIMP")

ignore_hotkey_gimp = function(hotkey)
  filter_ignore_hotkey(gimp_filter, hotkey)
end

ignore_hotkey_gimp(cmd_t)

-- Prepare GnuCash window filter.
--
-- - See also above: gnucash_shortcuts_get_eventtap

ignore_hotkey_gnucash = function(hotkey)
  filter_ignore_hotkey(gnucash_filter, hotkey)
end

-- Prepare a similar LibreOffice window filter.
-- - Not used herein but used by some client-hs.lua, so defined here.
local libreoffice_filter = hs.window.filter.new("LibreOffice")

ignore_hotkey_libreoffice = function(hotkey)
  filter_ignore_hotkey(libreoffice_filter, hotkey)
end

-- Prepare a Meld window filter and hotkey subscriber.
-- - Not used herein but used by some client-hs.lua, so defined here.
local meld_filter = hs.window.filter.new("Meld")

ignore_hotkey_meld = function(hotkey)
  filter_ignore_hotkey(meld_filter, hotkey)
end

-- Prepare a Slack window filter and hotkey subscriber.
local slack_filter = hs.window.filter.new("Slack")

ignore_hotkey_slack = function(hotkey)
  filter_ignore_hotkey(slack_filter, hotkey)
end

ignore_hotkey_slack(cmd_0)

ignore_hotkey_slack(shift_cmd_t)

-------

-- Finder foregrounder/opener

-- BNDNG: <Cmd-F>
local cmd_f = hs.hotkey.bind({"cmd"}, "F", function()
  hs.application.launchOrFocus("Finder")
end)

ignore_hotkey_gnucash(cmd_f)
ignore_hotkey_meld(cmd_f)
ignore_hotkey_slack(cmd_f)

-------

-- MacVim foregrounder/opener

-- BNDNG: <Cmd-Backtick> (<Cmd-`>)
hs.hotkey.bind({"cmd"}, "`", function()
  hs.application.launchOrFocus("MacVim")
end)

-------

-- Slack foregrounder/opener

-- BNDNG: <Shift-Ctrl-Cmd-F>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "F", function()
  hs.application.launchOrFocus("Slack")
end)

-------

-- GnuCash foregrounder/opener

-- BNDNG: <Shift-Ctrl-Cmd-G>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "G", function()
  hs.application.launchOrFocus("GnuCash")
end)

-------

-- Spotify foregrounder/๏קєภer

-- BNDNG: <Shift-Ctrl-Cmd-X>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "X", function()
  hs.application.launchOrFocus("Spotify")
end)

-------

-- LibreOffice foregrounder/opener
-- - Mnemonic: *Edit* (I know, "edit" could mean so many things! Esp. text "editor").

-- BNDNG: <Shift-Ctrl-Cmd-E>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "E", function()
  hs.application.launchOrFocus("LibreOffice")
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- <Cmd-Minus> — Put YYYY-MM-DD into clipboard.
-- - Note the printf avoids newline injection.
--   - Though below we also use `tr -d`...
-- - CALSO: Homefries `$(TTT)` function, and Dubs-Vim 'TTT' alias, etc.
--    https://github.com/landonb/home-fries/blob/release/lib/datetime_now_TTT.sh#L45
--    https://github.com/landonb/dubs_edit_juice/blob/release/plugin/dubs_edit_juice.vim#L1513

-- BNDNG: <Cmd-Minus> (<Cmd-->)
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

-- BNDNG: <Ctrl-Cmd-Semicolon> (<Ctrl-Cmd-;>)
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

-- BNDNG: <Ctrl-Cmd-Quote> (<Ctrl-Cmd-SingleQuote>, <Ctrl-Cmd-Apostrophe>, <Ctrl-Cmd-'>)
hs.hotkey.bind({"ctrl", "cmd"}, "'", function()
  local task = hs.task.new(
    "/bin/dash",
    nil,
    function() return false end,
    { "-c", 'printf "%s" "$(date "+%Y-%m-%d-%H-%M")" | tr -d "\n" | pbcopy' }
  )
  task:start()
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppWindowChooser.spoon/init.lua

local appWindowChooser = hs.loadSpoon("AppWindowChooser")

appWindowChooser.appName = "Google Chrome"

-- OWELL: The first 9 choices are assigned a <Cmd-1>..<Cmd-9> binding
-- by hs.chooser, but there's no option to disable those bindings.
-- - And they don't work, anyway, because of the Terminal window
--   bindings defined above.

-- <Ctrl-Space>, as inspired by Contexts.
-- BNDNG: <Ctrl-Space> (<Ctrl- >)
appWindowChooser:bindHotkeys({show_chooser={{"ctrl"}, "Space"}})

appWindowChooser:start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- KLUGE: When Chrome Save dialog is open, prevent
--        <Ctrl-Left>/<Ctrl-Right> from changing location
--        of web page in the background.
-- - This design choice baffles me!
--   - Use case: I was saving a receipt and editing the filename
--     but hit a familiar keybinding to move the cursor,
--     <Ctrl-Left>, and I didn't notice that it moved the background
--     page backward in history. So I hit <Ctrl-Right> again, to look
--     for the cursor. Then I noticed the browser location had changed.
--     And after saving the document, the browser page had lost the
--     order confirmation, and instead it was scolding me for
--     resubmitting the order. Ha!
--   - I also disabled KE bindings to ensure it's not something funky
--     in my environment (though I'd be curious to test this on stock
--     macOS just to be sure).
--
-- - This watcher hooks Chrome windows and waits for
--   <Ctrl-Left>/<Ctrl-Right> events.
--   - If Chrome has a secondary window open, we assume it's
--     the Save dialog, and we replace the event with an event
--     to move the cursor, <Cmd-Left>/<Cmd-Right>.
-- - Note that if you use KE to swap <Ctrl-Left>/<Ctrl-Right> and
--   <Alt-Left>/<Alt-Right>, it's <Alt-Left>/<Alt-Right> wired to
--   location back/forward, but this binding still sees the
--   unadultered keybindings, <Ctrl-Left>/<Ctrl-Right>.
--   - I'm unsure if this is always the case, or if there's, e.g.,
--     a race condition between Hammerspoon and Karabiner Elements
--     and maybe this isn't always the case. But appears to work
--     this way so far in author's experience.

local chrome_rwd_fwd_get_eventtap = function()
  return hs.eventtap.new(
    {hs.eventtap.event.types.keyDown},
    function(e)
      -- USAGE: Uncomment to debug/pry (also table_join def, above):
      --   local unmodified = false
      --   hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
      --   hs.alert.show("FLAGS: " .. table_join(e:getFlags(), ", "))
      -- Note that modifiers includes "fn" when arrow key pressed.
      -- Note if you have KE swapping bindings, to you this is "alt", not "ctrl",
      -- i.e., <Alt-Left>/<Alt-Right>
      -- - But this still works (and problem still exists) when I disable
      --   KE bindings.
      -- - DUNNO: I'm not aware of any race condition here.
      --   - BWARE: But maybe there's a case where Hammerspoon gets the
      --     event after it's manipulated by KE, and what you see is "alt"
      --     instead? Just be on the lookout, in case this stops working.
      if (e:getFlags():containExactly({"ctrl", "fn"})
        and (e:getKeyCode() == hs.keycodes.map["left"]
          or e:getKeyCode() == hs.keycodes.map["right"])
      ) then
        suc, _parsed_out, _raw_out_or_error_dict = hs.osascript.applescript(
          "tell application \"System Events\"\n" ..
          "  tell process \"Google Chrome\"\n" ..
          "    tell window 1\n" ..
          "      properties of sheet 1\n" ..
          "    end tell\n" ..
          "  end tell\n" ..
          "end tell\n"
        )
        --
        -- ALTLY: Call via file path rather than passing AppleScript string.
        -- - DUNNO: Is there a performance difference between the two approaches?
        --
        --  probe_osa = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/lib/probe-chrome-sheet-1-of-window-1.osa"
        --  suc, _parsed_out, _raw_out_or_error_dict = hs.osascript.applescriptFromFile(probe_osa)

        if suc then
          -- Return true to delete the event
          --  return true
          -- Or better yet, replace with alt. keycode, <Cmd-Left>/<Cmd-Right>,
          -- which has same effect: jump cursor to start/end of filename input.
          if e:getKeyCode() == hs.keycodes.map["left"] then
            return true, {hs.eventtap.event.newKeyEvent({"cmd", "fn"}, hs.keycodes.map["left"], true)}
          elseif e:getKeyCode() == hs.keycodes.map["right"] then
            return true, {hs.eventtap.event.newKeyEvent({"cmd", "fn"}, hs.keycodes.map["right"], true)}
          end
        end
      end

      -- Return false to propagate event.
      return false
    end
  )
end

local chrome_filter = hs.window.filter.new("Google Chrome")

filter_attach_eventtap(chrome_filter, chrome_rwd_fwd_get_eventtap)

-- Not used herein, but defined for client usage.
ignore_hotkey_chrome = function(hotkey)
  filter_ignore_hotkey(chrome_filter, hotkey)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/NeverLoseFocus.spoon/init.lua

hs.loadSpoon("NeverLoseFocus"):start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Nice! 4-second (or shorter, if you hotkey again, or <Esc>) clock overlay.
--  ~/.kit/mOS/hammerspoons/Source/AClock.spoon/init.lua
--
aClock = hs.loadSpoon("AClock")
-- BNDNG: <Cmd-Alt-C>
hs.hotkey.bind({"cmd", "alt"}, "c", function()
  aClock:toggleShow()
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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
--
-- - CXREF:
--   ~/.kit/mOS/hammerspoons/Source/HoldToQuit.spoon/init.lua
--
-- - I did not test... but I might if I find myself quiting
--   apps unexpectedly/accidentally.
--
--  holdToQuit = hs.loadSpoon("HoldToQuit")
--  holdToQuit:init()

-------

-- Map <Ctrl-Q> to app:kill().
--
-- - I.e., make <Ctrl-Q> like <Cmd-Q>, for my Linux-addled brain.
--
-- SAVVY: Note that sending key stroke doesn't seem to work, at least not in
-- any app I've tried (incl. "System Settings", "LibreOffice", and "Meld").
--
-- - E.g., this doesn't have any effect:
--
--     hs.eventtap.keyStroke({"cmd"}, "Q")
--
-- So kill instead, which "tries to terminate the app gracefully".

local cmd_q = hs.hotkey.bind({"ctrl"}, "Q", function()
  local app = hs.application.frontmostApplication()

  app:kill()
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

