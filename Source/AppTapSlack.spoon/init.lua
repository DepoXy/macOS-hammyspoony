-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapSlack ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapSlack.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapSlack.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapSlack"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapSlack.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapSlack')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

obj.slackWindowFilter = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:slackShortcutsGetEventtap()
   return hs.eventtap.new(
      {hs.eventtap.event.types.keyDown},
      function(e)
         -- USAGE: Uncomment to debug/pry:
            --   local unmodified = false
            --   hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
            --   hs.alert.show("FLAGS: " .. tableUtils:tableJoin(e:getFlags(), ", "))
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapSlack:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
   self.slackWindowFilter = hs.window.filter.new("Slack")

   appTapAttach:filterAttachEventtap(
      self.slackWindowFilter,
      self.slackShortcutsGetEventtap
   )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

