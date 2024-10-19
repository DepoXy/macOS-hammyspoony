-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
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

-- SAVVY: This tedious menu shortcut remapping because
-- GnuCash ignores the normal Keyboard Shortcuts you'd
-- otherwise manage from System Settings, i.e.,
--   defaults write org.gnucash.Gnucash NSUserKeyEquivalents '{ ... }'
-- doesn't change anything.

function obj:gnucashShortcutsGetEventtap()
  return hs.eventtap.new(
    {hs.eventtap.event.types.keyDown},
    function(e)
      -- USAGE: Uncomment to debug/pry:
      --    local unmodified = false
      --    hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
      --    hs.alert.show("FLAGS: " .. tableUtils:tableJoin(e:getFlags(), ", "))
      --    hs.alert.show("KEYCD: " .. e:getKeyCode())

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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapSlack:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
  -- SAVVY: Its Application name is "Gnucash" and not "GnuCash"
  -- like the window title, its documentation, or website, etc.
  appTapAttach:registerApptap(
    "Gnucash",
    self.gnucashShortcutsGetEventtap
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

