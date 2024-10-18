-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapMeld ===
---
--- For most accelerators, you can change the binding in source
--- and rebuild Meld. But not for the Quit Meld binding, if you
--- can that in source, e.g., from <Primary>Q to <Control>Q,
--- then neither binding works (not <Ctrl-Q>, not <Cmd-Q>), and
--- you can then only quit Meld via the window close button (×).
---
--- - This Spoon simply wires <Ctrl-Q> to emit <Cmd-Q> (so then
---   either binding can be used to quit Meld).
---
--- - REFER:
---
---   - The Meld source file where you can change most (all but
---     one) of the bindings:
---
---       https://gitlab.gnome.org/GNOME/meld/-/blob/main/meld/accelerators.py?ref_type=heads
---
---   - The author's edited Meld accelerators file, which gives
---     Meld Linux-like bindings on macOS:
---
---       https://github.com/landonb/meld/blob/ref/control-key-accelerators/meld/accelerators.py
---
---   - If you use DepoXy you'll find this file locally at:
---
---       ~/.kit/py/meld/meld/accelerators.py
---
---     As well as the OMR (Oh! myrepos) build wrapper at:
---
---       ~/.depoxy/ambers/home/.kit/py/_mrconfig--meld
---
---     See DepoXy sources for more:
---
---       https://github.com/DepoXy/depoxy#🍯
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapMeld.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapMeld.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapMeld"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapMeld.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapMeld')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:meldGetEventtap()
  return hs.eventtap.new(
    {
      hs.eventtap.event.types.keyDown,
    },
    function(e)
      -- SAVVY: Return true as first table value to delete original event.
      if e:getFlags():containExactly({"ctrl"}) then
        if false then

        -- *** Meld

        -- python3 > Quit Meld
        elseif e:getKeyCode() == hs.keycodes.map["q"] then
          return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["q"], true)}

        end
      end

      -- Return false to propagate event.
      return false
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapMeld:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
  appTapAttach:registerApptap(
    -- Note the application is "python3", nor "Meld"
    "python3",
    self.meldGetEventtap
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

