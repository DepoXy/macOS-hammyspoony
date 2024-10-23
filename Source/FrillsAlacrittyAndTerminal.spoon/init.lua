-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AlacrittyAndTerminalConveniences ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AlacrittyAndTerminalConveniences"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AlacrittyAndTerminalConveniences.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AlacrittyAndTerminalConveniences')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- USAGE: Use this boolean to control window fronters 1 through 9 togglability.
obj.togglable = true

--- Internal variable: Key binding for unminimze all Alacritty windows.
obj.keyUnminimzeAllAlacrittyWindows = nil

--- Internal variable: Key binding prefix for Alacritty window fronters,
--- paired with keys '1' through '9', to raise Alacritty window titled
--- with the corresponding number.
obj.keysAlacrittyWindowFronters1Through9 = nil

--- Variable: Key binding for new Alacritty window.
obj.keyAlacrittyNewWindow = nil

--- Internal variable: Key binding for front/open Alacritty.
obj.keyAlacrittyForegrounderOpener = nil

--- Internal variable: Key binding for new Terminal.app window.
obj.keyTerminalNewWindow = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Unminimize all Alacritty windows.
-- - DUNNO: When I first tested this, it was fast, like, it would
--   instantaneously unminimize all windows. But now it's slow, like
--   how minimize is also slow, and acts on each window sequentially.
-- - Note this doesn't front or focus any of these windows, unless an
--   Alacritty window is already front, then maybe another one comes
--   into focus.

function obj:unminimzeAllAlacrittyWindows()
  local alacritty_app = hs.application.get("Alacritty")

  local app_wins = alacritty_app:allWindows()

  for key in pairs(app_wins) do
    local app_win = app_wins[key]

    app_win:unminimize()
  end

  -- SAVVY: Until you click one of the unminimized windows, the
  -- 'allButFrontmost' binding (from MinimizeAndHideWindows.spoon,
  -- which Hammyspoony defaults to <Shift-Ctrl-Cmd-W>) won't minimize
  -- Alacritty windows. Nor will the 'alacrittyWindowFronters1Through9Prefix'
  -- bindings (e.g., <Cmd-1>, <Cmd-2>, etc.) work. It's as though the windows
  -- don't know they're unminimized yet! But activate (or setFrontmost) seems
  -- to do the trick.
  alacritty_app:activate()
  -- Also works:
  --   alacritty_app:setFrontmost()
end

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
--
--     local wins = wf_terminals:getWindows()
--
--     -- for k,v in pairs(wins) do
--     --   hs.alert.show("k — " .. k .. " / title — " .. v:title())
--     -- end
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

function obj:terminal_by_number_using_post_filter(win_num, win_hint, toggle)
  local found_win

  if type(win_hint) == "boolean" then
    toggle = win_hint
    win_hint = nil
  end

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
        found_win = win

        break
      end
    end

    -- If no terminal window matched, use any application window that matches.
    if not found_win then
      found_win = wins and wins[1]
    end
  end

  if found_win then
    local front_win = nil

    if toggle then
      front_win = hs.window.frontmostWindow()
    end

    if front_win ~= found_win then
      found_win:raise():focus()
    else
      front_win:minimize()
    end

    return true
  end

  return false
end

-- The win_hint arg lets user override these bindings in their
-- own private config, using a backup window title pattern.
function obj:alacritty_by_window_number_prefix(win_num, win_hint, toggle)
  return self:terminal_by_number_using_post_filter(win_num, win_hint, toggle)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

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

function obj:alacrittyNewWindow()
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
end

-- Alacritty foregrounder/opener

function obj:alacrittyForegrounderOpener()
  hs.application.launchOrFocus("Alacritty")
end

-- Terminal.app — New Window
-- - For the rare time you want to test Apple Terminal.app

function obj:terminalNewWindow()
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
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeyUnminimzeAllAlacrittyWindows(mapping)
  if mapping["unminimzeAllAlacrittyWindows"] then
    if (self.keyUnminimzeAllAlacrittyWindows) then
      self.keyUnminimzeAllAlacrittyWindows:delete()
    end

    self.keyUnminimzeAllAlacrittyWindows = hs.hotkey.bindSpec(
      mapping["unminimzeAllAlacrittyWindows"],
      function()
        self:unminimzeAllAlacrittyWindows()
      end
    )
  end
end

function obj:bindHotkeysAlacrittyWindowFronters1Through9(mapping)
  if mapping["alacrittyWindowFronters1Through9Prefix"] then
    if (self.keysAlacrittyWindowFronters1Through9) then
      tableUtils:tableForEach(
        self.keysAlacrittyWindowFronters1Through9,
        function (key, val) val:delete() end
      )
    end
  end

  self.keysAlacrittyWindowFronters1Through9 = {}

  for key in pairs({1, 2, 3, 4, 5, 6, 7, 8, 9}) do
    table.insert(
      self.keysAlacrittyWindowFronters1Through9,
      -- MAYBE: Use hs.hotkey.bindSpec instead?
      hs.hotkey.bind(
        mapping["alacrittyWindowFronters1Through9Prefix"],
        tostring(key),
        function()
          self:alacritty_by_window_number_prefix(key, obj.togglable)
        end
      )
    )
  end
end

function obj:bindHotkeysAlacrittyNewWindow(mapping)
  if mapping["alacrittyNewWindow"] then
    if (self.keyAlacrittyNewWindow) then
      self.keyAlacrittyNewWindow:delete()
    end

    self.keyAlacrittyNewWindow = hs.hotkey.bindSpec(
      mapping["alacrittyNewWindow"],
      function()
        self:alacrittyNewWindow()
      end
    )
  end
end

function obj:bindHotkeysAlacrittyForegrounderOpener(mapping)
  if mapping["alacrittyForegrounderOpener"] then
    if (self.keyAlacrittyForegrounderOpener) then
      self.keyAlacrittyForegrounderOpener:delete()
    end

    self.keyAlacrittyForegrounderOpener = hs.hotkey.bindSpec(
      mapping["alacrittyForegrounderOpener"],
      function()
        self:alacrittyForegrounderOpener()
      end
    )
  end
end

function obj:bindHotkeysTerminalNewWindow(mapping)
  if mapping["terminalNewWindow"] then
    if (self.keyTerminalNewWindow) then
      self.keyTerminalNewWindow:delete()
    end

    self.keyTerminalNewWindow = hs.hotkey.bindSpec(
      mapping["terminalNewWindow"],
      function()
        self:terminalNewWindow()
      end
    )
  end
end

--- AlacrittyAndTerminalConveniences:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for AlacrittyAndTerminalConveniences
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * unminimzeAllAlacrittyWindows — unminimize all Alacritty windows
---   * alacrittyWindowFronters1Through9Prefix — Hotkey prefix, paired with keys '1' through '9'
---   * alacrittyNewWindow — open new Alacritty window
---   * alacrittyForegrounderOpener — front Alacritty, or open new Alacritty window if not running
---   * terminalNewWindow — open new Terminal.app window
function obj:bindHotkeys(mapping)
  self:bindHotkeyUnminimzeAllAlacrittyWindows(mapping)
  self:bindHotkeysAlacrittyWindowFronters1Through9(mapping)
  self:bindHotkeysAlacrittyNewWindow(mapping)
  self:bindHotkeysAlacrittyForegrounderOpener(mapping)
  self:bindHotkeysTerminalNewWindow(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

