-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === MinimizeAndHideWindows ===
---
--- Two bindings:
---
--- - Hide or Minimize all but the frontmost window.
---
--- - Hide or Minimize all windows.
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "MinimizeAndHideWindows"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- MinimizeAndHideWindows.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('MinimizeAndHideWindows')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- Internal variable: Key binding for hide/minimze all but frontmost.
obj.keyAllButFrontmost = nil

--- Internal variable: Key binding for hide all windows.
obj.keyAllWindows = nil

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

function obj:hideMinimzeAllButFrontmost()
   local front_win = hs.window.frontmostWindow()

   -- Minimize Alacritty windows first.
   -- - Note that I tried calling minimize from the task callback,
   --   but I couldn't get it to work. My hope was to minimize
   --   hidden windows so user didn't have to see all the animation
   --   happening. Oh, well.
   local appWins = hs.application.get("Alacritty"):allWindows()
   for key, _ in pairs(appWins) do
      local appWin = appWins[key]

      appWin:minimize()
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
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:hideAllWindows()
   hide_osa = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/lib/hide-all-windows.osa"

   hs.osascript.applescriptFromFile(hide_osa)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeyAllButFrontmost(mapping)
   if mapping["allButFrontmost"] then
      if (self.keyAllButFrontmost) then
         self.keyAllButFrontmost:delete()
      end

      self.keyAllButFrontmost = hs.hotkey.bindSpec(
         mapping["allButFrontmost"],
         function()
            self:hideMinimzeAllButFrontmost()
         end
      )
   end
end

function obj:bindHotkeyAllWindows(mapping)
   if mapping["allWindows"] then
      if (self.keyAllWindows) then
         self.keyAllWindows:delete()
      end

      self.keyAllWindows = hs.hotkey.bindSpec(
         mapping["allWindows"],
         function()
            self:hideAllWindows()
         end
      )
   end
end

--- MinimizeAndHideWindows:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for MinimizeAndHideWindows
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * allButFrontmost - hide/minimize all windows except frontmost
---   * allWindows - hide all windows
function obj:bindHotkeys(mapping)
   self:bindHotkeyAllButFrontmost(mapping)
   self:bindHotkeyAllWindows(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

