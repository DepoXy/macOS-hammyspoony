-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === FrillsChrome ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/FrillsChrome.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/FrillsChrome.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "FrillsChrome"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- FrillsChrome.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('FrillsChrome')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- Internal variable: Key binding for open new Chrome window.
obj.keyNewChromeWindow = nil

--- Internal variable: Key binding for front MRU Chrome window.
obj.keyFrontChromeWindow = nil

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

function obj:makeNewChromeWindow(profile)
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Bring MRU Chrome window to the front, or start Chrome.
-- - If all Chrome windows are minimized, this activates Chrome
--   app but won't actually show any window.

function obj:frontMRUChromeWindow()
   local chrome_app = hs.application.get("Google Chrome")

   if not chrome_app then
      hs.application.launchOrFocus("Google Chrome")
   else
      if chrome_app:isHidden() then
         chrome_app:unhide()
      end

      chrome_app:setFrontmost()
   end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeyNewChromeWindow(mapping)
   if mapping["newChromeWindow"] then
      if (self.keyNewChromeWindow) then
         self.keyNewChromeWindow:delete()
      end

      self.keyNewChromeWindow = hs.hotkey.bindSpec(
         mapping["newChromeWindow"],
         function()
            self:makeNewChromeWindow("Default")
         end
      )
   end
end

function obj:bindHotkeyFrontChromeWindow(mapping)
   if mapping["frontChromeWindow"] then
      if (self.keyFrontChromeWindow) then
         self.keyFrontChromeWindow:delete()
      end

      self.keyFrontChromeWindow = hs.hotkey.bindSpec(
         mapping["frontChromeWindow"],
         function()
            self:frontMRUChromeWindow()
         end
      )
   end
end

--- FrillsChrome:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for FrillsChrome
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * newChromeWindow — open new Chrome window
---   * frontChromeWindow — bring MRU Chrome window to the front, or start Chrome
function obj:bindHotkeys(mapping)
   self:bindHotkeyNewChromeWindow(mapping)
   self:bindHotkeyFrontChromeWindow(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

