-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapDisableHotkeys ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapDisableHotkeys.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapDisableHotkeys.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapDisableHotkeys"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapDisableHotkeys.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapDisableHotkeys')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

obj.hotkeys = {}

function obj:registerHotkeys(hotkeys)
  for _, val in pairs(hotkeys) do
    table.insert(self.hotkeys, val)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:start()
  for _, hotkey in pairs(self.hotkeys) do
    -- print("AppTapDisableHotkeys: DISABLE: hotkey: " .. hotkey.msg)
    hotkey:disable()
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:stop()
  for _, hotkey in pairs(self.hotkeys) do
    -- print("AppTapDisableHotkeys: ENABLE: hotkey: " .. hotkey.msg)
    hotkey:enable()
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapDisableHotkeys:start()
--- Method
--- Starts the Spoon: Wires the not-really-an-eventtap.
--- - AppTapAttach was created for wiring hs.eventtap objects,
---   but we're abusing (getting creative?) or repurposing for
---   a slightly different purpose — to disable or enable hotkeys
---   en masse. And we're using the AppTapAttach infrastruture,
---   which uses an hs.application.watcher to call start() and
---   stop() on the object we pass it (which is our obj/self).
---
--- Parameters:
---  * appTapAttach
function obj:disableAllHotkeysForApp(appTapAttach, appName)
  appTapAttach:registerApptap(
    appName,
    function()
      return self
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

