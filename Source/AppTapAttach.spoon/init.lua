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

obj.appEventtaps = {}

function obj:registerApptap(appName, getEventtap)
   obj.appEventtaps[appName] = getEventtap()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- REFER: Posisible event types:
--    hs.application.watcher.activated
--    hs.application.watcher.deactivated
--    hs.application.watcher.hidden
--    hs.application.watcher.launched
--    hs.application.watcher.launching
--    hs.application.watcher.terminated
--    hs.application.watcher.unhidden

obj.activeEventtap = nil

function obj.appWatcherWatch(appName, eventType, theApp)
   -- print("appName: " .. appName .. " / eventType: " .. eventType)

   if eventType ~= hs.application.watcher.activated then
      return
   end

   if obj.activeEventtap then
      obj.activeEventtap:stop()
      obj.activeEventtap = nil
   end

   if obj.appEventtaps[appName] then
      obj.activeEventtap = obj.appEventtaps[appName]
      obj.activeEventtap:start()
   end
end

--- AppTapAttach:start()
--- Method
--- Starts the Spoon.
---
--- Parameters:
---  * (none)
function obj:start()
   self.appWatcher = hs.application.watcher.new(self.appWatcherWatch)

   self.appWatcher:start()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

