-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === NeverLoseFocus ===
---
--- Whenever you close or minimize the last visible window of a macOS
--- application, that application is still active, even though some
--- other application's window might now be the frontmost window.
---
--- - This Spoon tracks window focus and unfocus events to ensure
---   that you're never without focus!
---
--- - When the last visible window of an application is closed or
---   minimized, this Spoon will focus the next most recently used
---   and still-visible application's window.
---
--- - This Spoon's behavior emulates the window-centric behaviour of
---   Linux and Windows, and eschews the app-centric macOS paradigm.
---
---   - The Apple approach, in this author's opinion, is a remnant of
---     System 6 and before's single-tasking model. That is, early
---     macOS won't switch apps unless you quit one app and start another;
---     and with System 7 onwards, macOS won't switch apps even when
---     you close the last application window — indeed, you'll still
---     see the application's menu bar, sans application windows
---     (though some other app's window might now be the frontmost
---     window, albeit without focus... which I still find strange!).
---
---     Which I sorta get, because macOS attaches the menu bar to the
---     top of the display, disconnected from any application window.
---
---     This is in contrast to Linux or Windows, where each application
---     window has its own menu bar.
---
---   - But if you like to hide the macOS menu bar (I do!), it can be
---     confusing when you close the last app window, some other app's
---     window is now topmost, yet you cannot interact with it! (FYI,
---     I use a GeekTool geeklet to display the time on my Desktop, in
---     the exact position where the macOS menu bar clock would appear;
---     and otherwise I almost exclusively use keyboard shortcuts to
---     interact with my apps, so that I rarely use the menu bar.) (Also
---     I hide the Dock and mostly use Hammerspoon bindings and the
---     occassional Spotlight Search to switch between apps and windows.)
---
---   - So here you have it, just one culty Linux dev's Spoon to help
---     make their macOS host basically just another Linux distro.
---
---     - See also my other Hammerspoon and Karabiner Elements config,
---       and `defaults write ... NSUserKeyEquivalents` project,
---       in furtherance of the same goal:
---
---         https://github.com/DepoXy/macOS-onboarder#🏂
---         https://github.com/DepoXy/macOS-Hammyspoony#🥄
---         https://github.com/DepoXy/Karabiner-Elephants#🐘
---
--- - ALTLY: Without this Spoon, another approach is to <Cmd-H> hide
---   the app after closing/minimizing last visible window, thereby
---   focusing whatever window is topmost (but that doesn't have focus).
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/NeverLoseFocus.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/NeverLoseFocus.spoon.zip)

--- DUNNO/2024-10-01: Sometimes when I open and close Chrome windows fastly,
--- the events don't register, or visibleWindows() reports multiple when
--- there are non, and focus won't switch.
--- - I'm not quite sure how to fix this, other than maybe trying to listen on
---   other or additional events (albeit looking at the list of subscribable
---   events, I'm not sure what else I could hook, e.g., hiding an app (which
---   should signal windowHidden) will also trigger windowUnfocused, which we
---   listen on below).
---   - Fortunately, if you actually linger on a window for a little before
---     closing it (and don't open-close it immediately), this doesn't seem
---     to happen.

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "NeverLoseFocus"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- NeverLoseFocus.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default
---   log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('NeverLoseFocus')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

obj.trace = false
-- USAGE: Enable obj.trace for popup messaging.
--
--   obj.trace = true

-- Shows a brief popup, and logs to the Hammerspoon Console.
-- - Callers can use hs.inspect() to convert tables and more complex
--   objects to text.
-- - Uses print and not the logger b/c logger adds a lot of indentation:
--     obj.logger.setLogLevel("debug")
--     obj.logger.d(msg)
function obj:debug(msg, force)
  if (self.trace or force) then
    -- You could also/instead show an overlay alert:
    --  hs.alert.show(msg)
    print(msg)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- USAGE: Set true to see a[n] (inspirational?) quote when nothing focused
--- (when the last visible window is closed/minimized/hidden).
obj.inspireMe = false

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Ensure user is never (when possible) without focus!
--
-- - This window filter ensures (or at least tries to ensure) that
--   you're never left trying to interact with a window that's not
--   actually focused after closing or minimizing the last window
--   for an application.

-- This table is an ordered list of most recently used applications, so
-- we can find the most appropriate window to focus after user closes
-- or minimizes the last visible window for a particular application.
-- - WORDS: "MRU": Most Recently Used (pretty obvi., but I'm pedantic).
obj.mru_apps = {}

-- Window filter that tracks all apps' windows (via the "true" arg).
--   https://www.hammerspoon.org/docs/hs.window.filter.html#new
obj.all_windows_filter = hs.window.filter.new(true)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- SAVVY: Lua uses 1-based counters, not 0-based.
-- - From what I've read, this is because Lua was developed (as a
--   successor to Sol) as a language for non-CSCI engineers (for
--   the Brazilian oil co., PETROBRAS), to be easier to learn...
--   so I'll comment this as such, because I'll probably
--   forget this in the future (at least the "why" part).
--   - REFER: https://www.lua.org/history.html
--     - Sol: https://en.wikipedia.org/wiki/Secure_Operations_Language
-- - Some other langs index similarly from 1, including COBOL, Fortran,
--   Julia, MATLAB, Sass, etc.
--   - REFER:
-- https://en.wikipedia.org/wiki/Comparison_of_programming_languages_%28array%29#Array_system_cross-reference_list
obj.lua_array_first_element = 1

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Whenever an app's window is focused, make that app the MRU app.
-- - Args:
--   _win is unimportant
--   _app_name we'll track
--   _event is a string: "windowFocused"
function obj:mruAppsTrackFocused(_win, app_name, _event)
  self:debug("INFOCUS: " .. app_name)

  -- - Remove app from previous position, if previously recorded.
  local idx = self:indexOf(self.mru_apps, app_name)
  if idx then
    table.remove(self.mru_apps, idx)
  end

  -- User focused this app, so make it the most-recently-used app.
  -- - Except ignore Hammerspoon, it's... different (it reports multiple
  --   (unnamed) visibleWindows(), even when its Console window is closed).
  if not self:isAppExcluded(app_name) then
    -- - Insert app at the first position.
    table.insert(self.mru_apps, self.lua_array_first_element, app_name)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Whenever an app's window is unfocused, focus another app's window
-- if that was the last "visible" window for the active app.
--
-- - BWARE: Note that `hs.application.get(<App name>):visibleWindows()`
--   is non-empty when called immediately, even when <App name> has no
--   truly visible windows.
--
--   - So we'll delay before probing... though even with 200ms sleep,
--     I still sometimes see visibleWindows() report windows that
--     were recently closed. E.g., open 5 Chrome windows, then close
--     them all, and #viz_wins is still 5....

function obj:mruAppsTrackUnfocused(win, app_name, event)
  self:debugReportApp("UNFOCUS", app_name, event, "")

  -- Not so fast! (See comment above.)
  local delay_secs = 0.2

  hs.timer.doAfter(
    delay_secs,
    function()
      self:mruAppsTrackUnfocusedCallback(win, app_name, event)
    end
  )
end

function obj:mruAppsTrackUnfocusedCallback(win, app_name, event)
  self:debugReportApp("UNFOCUS", app_name, "200ms later", "")

  local the_app = hs.application.get(app_name)

  local viz_wins = the_app and the_app:visibleWindows() or {}

  -- IDGIT: Hammerspoon reports different numbers of #viz_wins after you
  -- close the Conole window. 10. 29. 25. 35. All over the place.
  -- - So ignore the visibleWindows() count for Hammerspoon.
  if ((#viz_wins > 0) and not (self:isAppExcluded(app_name))) then
    self:debug("- App still has visible windows")
  else
    -- The app has no more visible windows, so it's no longer
    -- a most-recently-used-and-still-visible application.
    local idx = self:indexOf(self.mru_apps, app_name)
    if idx then
      table.remove(self.mru_apps, idx)
    end

    -- Now look for another application's window to promote to focus.
    local mru_app = self.mru_apps[self.lua_array_first_element]

    while mru_app do
      self:debugReportApp("PROBING", mru_app, "", "  ")

      local the_app = hs.application.get(mru_app)

      local focused_win = the_app and the_app:focusedWindow()

      -- TRACK: Just curious if visibleWindows XOR focusedWindow.
      self:debugCompare_visibleWindows_And_focusedWindow(the_app)

      if ((focused_win == nil) or self:isAppExcluded(mru_app)) then
        table.remove(self.mru_apps, self.lua_array_first_element)
        mru_app = self.mru_apps[self.lua_array_first_element]
      else
        break
      end
    end

    if mru_app then
      self:debug("- Focusing: " .. mru_app)
      hs.application.get(mru_app):setFrontmost()
    else
      self:debug("- Nothing to focus")

      if self.inspireMe then
        local quotes = {
          "You have no focus!",
          "Clarity affords focus",  -- Thomas Leonard [who?]
          "Never lose focus",
          "If you're going through hell,\nkeep going",  -- Winston Churchill
          -- "Concentrate all your thoughts upon the work in hand" /
          "The sun’s rays do not burn\nuntil brought to a focus",  -- Alexander Graham Bell
          "If you want to make your dreams come true,\nthe first thing you have to do is wake up",  -- J.M. Power
          "Concentrate: You can’t have it all",  -- Twyla Tharp
          "Concentration is a fine antidote to anxiety",  -- Jack Nicklaus
          "It is during our darkest moments\nthat we must focus to see the light", -- Aristotle Onassis
          "You can't depend on your eyes\nwhen your imagination is out of focus", -- Mark Twain
          "The ego is nothing other than\nthe focus of conscious attention",  -- Alan Watts
          "Planets move in ellipses\nwith the Sun at one focus",  -- Johannes Kepler
          "The focus of subjectivity\nis a distorting mirror",  -- Hans-Georg Gadamer
          "If you just focus\non the smallest details,\nyou never get\nthe big picture right",  -- Leroy Hood
          "Focus 90% of your time on solutions and\nonly 10% of your time on problems",  -- Anthony J. D'Angelo
          -- "Rage has such focus.\nIt can't go on forever,\nbut it's invigorating",  -- Siri Hustvedt
          "Focus on doing the right things\ninstead of a bunch of things",  -- Mike Krieger
          "If you want to survive\nthe zombie apocalypse,\nyou need to focus on\nincreasing your stamina",  -- Tom Payne
          "Who cares about winning?\nWe should focus on serving",  -- Justin Trudeau
          "The more you focus,\nthe more that focus\nbecomes a habit",  -- Charles Duhigg
          "There's nothing like desperation\nto sharpen your sense of focus",  -- Thomas Newman
          "Our focus is on outputs\nrather than inputs",  -- Stephen Cambone
          "Shoot a few scenes out of focus.\nI want to win the foreign film award",  -- Billy Wilder
          "Selective amnesia is a good thing to have.\nSo is good focus",  -- Adam Vinatieri
          -- "Each feature I make is my focus at that time",  -- Richard King
        }
        local randQuote = math.random(#quotes)
        local showSecs = 2.718

        hs.alert.show(quotes[randQuote], showSecs)
      end
    end
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:isAppExcluded(app_name)
  local is_excluded = (false
    or (app_name == "Hammerspoon")
    -- What Hammerspoon sometimes reports for the Console window,
    -- but not always... hrmm.
    or (app_name == "Notification Center")
  )

  return is_excluded
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- NTRST: When you close the Hammerspoon Console window, isFrontmost()
--        is still true, but for other apps (Google Chrome and MacVim,
--        at least), it's false when you close their last visible window.
--        - Also Hammerspoon reports lots (tens) of unnamed windows,
--          even after closing the "Hammerspoon Console" window.

function obj:debugReportApp(context, app_name, event, spacing)
  local the_app = hs.application.get(app_name)

  local event_parenthetical = ""
  -- A Lua'ism: ~= is not equals (and not '!=', nor '<>').
  if event ~= "" then
    event_parenthetical = " (" .. event .. ")"
  end

  self:debug(spacing .. context .. ": " .. app_name .. event_parenthetical)
  if the_app then
    local viz_wins = the_app:visibleWindows()
    local isFrontmost = the_app:isFrontmost()
    local isHidden = the_app:isHidden()
    local focusedWindow = the_app:focusedWindow()
    self:debug(spacing .. "- #viz_wins:    " .. #viz_wins)
    self:debug(spacing .. "- isFrontmost:  " .. hs.inspect(isFrontmost))
    self:debug(spacing .. "- isHidden:     " .. hs.inspect(isHidden))
    self:debug(spacing .. "- focusedWindow: " .. (focusedWindow and focusedWindow:title() or "nil"))
  else
    self:debug(spacing .. "- App has since been closed")
  end
end

-- TRACK: I had issues with visibleWindows() early in development, but I
-- think that was before I added the 200ms sleep to mruAppsTrackUnfocused.
-- - But I'm still curious if these 2 fcns. ever disagree.
function obj:debugCompare_visibleWindows_And_focusedWindow(the_app)
  if not the_app then
    return
  end

  local viz_wins = the_app:visibleWindows()
  local focused_win = the_app:focusedWindow()

  if (
    ((#viz_wins == 0) and (focused_win ~= nil))
    or ((#viz_wins > 0) and (focused_win == nil))
  ) then
    local always_print = true

    self:debug("GAFFE: focusedWindow and visibleWindows mismatch:", always_print)
    self:debug(" - focusedWindow: " .. (focusedWindow and focusedWindow:title() or "nil"), always_print)
    self:debug(" - visibleWindows: " .. hs.inspect(viz_wins), always_print)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Return the first index with the given value, or nil if not found.
function obj:indexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then

      return i
    end
  end

  return nil
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:start()
  self.all_windows_filter:subscribe(
    hs.window.filter.windowUnfocused,
    function(win, app_name, event)
      self:mruAppsTrackUnfocused(win, app_name, event)
    end
  )

  self.all_windows_filter:subscribe(
    hs.window.filter.windowFocused,
    function(win, app_name, event)
      self:mruAppsTrackFocused(win, app_name, event)
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

