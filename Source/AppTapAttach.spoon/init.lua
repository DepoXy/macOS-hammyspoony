-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapAttach ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapAttach.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapAttach.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapAttach"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapAttach.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapAttach')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:filterAttachEventtap(win_filter, get_eventtap)
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
            hs.alert.show("GAFFE: Unexpected path: filterAttachEventtap")

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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapAttach:start()
--- Method
--- Starts the Spoon.
---
--- Parameters:
---  * (none)
function obj:start()
   return
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

