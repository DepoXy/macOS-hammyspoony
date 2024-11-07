-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapFirefox ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapFirefox.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapFirefox.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapFirefox"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapFirefox.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapFirefox')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapFirefox feature flags
--- Variables
--- - USAGE: To disable a feature, set its feature flag to false.
---   - E.g.,
---
---       appTapAttach = hs.loadSpoon("AppTapAttach")
---       appTapAttach:start()
---
---       local appTapFirefox = hs.loadSpoon("AppTapFirefox")
---       appTapFirefox.enable["DeleteBackwardUsingCtrlW"] = false
---       appTapFirefox:start(appTapAttach)

obj.enable = {}
obj.enable["DeleteBackwardUsingCtrlW"] = true

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:firefoxGetEventtap()
  return hs.eventtap.new(
    {
      hs.eventtap.event.types.keyDown,
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.leftMouseUp,
    },
    function(e)
      return self:firefoxGetEventtapCallback(e)
    end
  )
end

function obj:firefoxGetEventtapCallback(e)
  local eventType = e:getType()
  -- SAVVY: Flags contain "fn" when non-character pressed.
  -- - E.g., <Left>, <Right>, <Home>, <End>, etc.
  local eventFlags = e:getFlags()

  -- Process Key down events.
  if eventType == hs.eventtap.event.types.keyDown then
    local keyCode = e:getKeyCode()

    -- USAGE: Uncomment to debug/pry:
    --   print("e:getType(): " .. hs.inspect(eventType))
    --   print("e:getFlags(): " .. tableUtils:tableJoin(eventFlags, ", "))
    --   print("e:getKeyCode(): " .. hs.inspect(keyCode))
    --   local unmodified = false
    --   print("e:getCharacters(false): " .. hs.inspect(e:getCharacters(unmodified)))

    -- Delete backward on <Ctrl-W>
    if keyCode == hs.keycodes.map["w"] then
      if self.enable["DeleteBackwardUsingCtrlW"]
        and eventFlags:containExactly({"ctrl"})
      then
        -- Emit <Alt-Backspace> (command macOS delete back-word)
        return true, {hs.eventtap.event.newKeyEvent({"alt"}, hs.keycodes.map["delete"], true)}
      else
        return false
      end
    end
  end  -- eventType == hs.eventtap.event.types.keyDown

  -- Return false to propagate event.
  return false
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapFirefox:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
  appTapAttach:registerApptap(
    "Firefox",
    function()
      return self:firefoxGetEventtap()
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

