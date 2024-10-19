-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapLibreoffice ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapLibreoffice.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapLibreoffice.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapLibreoffice"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapLibreoffice.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapLibreoffice')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- NTRST: While LibreOffice shows Home/End bound to To Line Begin/To End of Line,
-- macOS itself wires Home/End to document start/document end.
--
-- - *Windows keys on a Mac keyboard*
--   https://support.apple.com/en-nz/guide/mac-help/cpmh0152/mac
--
-- - BEGET: *Map home and end keys to beginning/end of line on macOS*
--   https://ask.libreoffice.org/t/map-home-and-end-keys-to-beginning-end-of-line-on-macos/51969/4
--
-- - An old Stack Exchange Q/A suggests using ~/Library/KeyBindings/DefaultKeyBinding.dict,
--   but that's a decade's old approach, and some comments suggest that many modern apps do
--   not honor its bindings.
--
--   - *Remap "Home" and "End" to beginning and end of line*
--     https://apple.stackexchange.com/questions/16135/remap-home-and-end-to-beginning-and-end-of-line
--
-- - So perhaps using Hammerspoon is not a bad approach, even it it's more
--   complicated than using DefaultKeyBinding.dict [and I've never tried to
--   use DefaultKeyBinding.dict, so why start now].

function obj:libreofficeGetEventtap()
  return hs.eventtap.new(
    {
      hs.eventtap.event.types.keyDown,
    },
    function(e)
      -- USAGE: Uncomment to debug/pry:
      --   local unmodified = false
      --   hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
      --   hs.alert.show("FLAGS: " .. tableUtils:tableJoin(e:getFlags(), ", "))
      if e:getType() == hs.eventtap.event.types.keyDown then
        local keyCode = e:getKeyCode()
        local eventFlags = e:getFlags()

        if (keyCode == hs.keycodes.map["left"]
          or keyCode == hs.keycodes.map["right"])
        then
          -- Note that modifiers includes "fn" when arrow key pressed.
          if eventFlags:containExactly({"ctrl", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"alt", "fn"}, keyCode, true)}
          elseif eventFlags:containExactly({"shift", "ctrl", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"shift", "alt", "fn"}, keyCode, true)}
          elseif eventFlags:containExactly({"alt", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"cmd", "fn"}, keyCode, true)}
          elseif eventFlags:containExactly({"shift", "alt", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd", "fn"}, keyCode, true)}
          end
        end

        if (keyCode == hs.keycodes.map["home"]
          or keyCode == hs.keycodes.map["end"])
        then
          if eventFlags:containExactly({"fn"}) or eventFlags:containExactly({"shift", "fn"}) then
            local newFlags = tableUtils:tableKeys(tableUtils:tableMerge(eventFlags, {["cmd"] = true}))

            if keyCode == hs.keycodes.map["home"] then
              return true, {hs.eventtap.event.newKeyEvent(newFlags, hs.keycodes.map["left"], true)}
            elseif keyCode == hs.keycodes.map["end"] then
              return true, {hs.eventtap.event.newKeyEvent(newFlags, hs.keycodes.map["right"], true)}
            end
          elseif eventFlags:containExactly({"ctrl", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"fn"}, keyCode, true)}
          elseif eventFlags:containExactly({"shift", "ctrl", "fn"}) then
            return true, {hs.eventtap.event.newKeyEvent({"shift", "fn"}, keyCode, true)}
          end
        end
      end

      -- Return false to propagate event.
      return false
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapLibreoffice:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
  appTapAttach:registerApptap(
    "LibreOffice",
    self.libreofficeGetEventtap
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

