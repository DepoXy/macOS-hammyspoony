--- === NeverLoseFocus ===
---
--- A new Sample Spoon
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/NeverLoseFocus.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/NeverLoseFocus.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "NeverLoseFocus"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- NeverLoseFocus.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('NeverLoseFocus')

--- Some internal variable
obj.key_hello = nil

--- NeverLoseFocus.some_config_param
--- Variable
--- Some configuration parameter
obj.some_config_param = true

--- NeverLoseFocus:sayHello()
--- Method
--- Greet the user
function obj:sayHello()
   hs.alert.show("Hello!")
   return self
end

--- NeverLoseFocus:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for NeverLoseFocus
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * hello - Say Hello
function obj:bindHotkeys(mapping)
   if mapping["hello"] then
      if (self.key_hello) then
         self.key_hello:delete()
      end
      self.key_hello = hs.hotkey.bindSpec(mapping["hello"], function() self:sayHello() end)
   end
end

return obj
