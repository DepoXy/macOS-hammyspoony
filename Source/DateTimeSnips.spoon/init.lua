-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === DateTimeSnips ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/DateTimeSnips.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/DateTimeSnips.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "DateTimeSnips"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- DateTimeSnips.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('DateTimeSnips')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- Internal variables: Key bindings
obj.keySnipISODateToday = nil
obj.keySnipISODateTimeNormal = nil
obj.keySnipISODateTimeDashed = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- <Cmd-Minus> — Put YYYY-MM-DD into clipboard.
-- - Note the printf avoids newline injection.
--   - Though below we also use `tr -d`...
-- - CALSO: Homefries `$(TTT)` function, and Dubs-Vim 'TTT' alias, etc.
--    https://github.com/landonb/home-fries/blob/release/lib/datetime_now_TTT.sh#L45
--    https://github.com/landonb/dubs_edit_juice/blob/release/plugin/dubs_edit_juice.vim#L1513

function obj:snipISODateToday()
   local task = hs.task.new(
      "/bin/dash",
      nil,
      function() return false end,
      { "-c", 'printf "%s" "$(date "+%Y-%m-%d")" | pbcopy' }
   )
   task:start()
end

-- <Ctrl-Cmd-Semicolon> — Put normal date plus:time into clipboard.
-- - HSTRY: Named after erstwhile Homefries $(TTTtt:) command.

function obj:snipISODateTimeNormal()
   local task = hs.task.new(
      "/bin/dash",
      nil,
      function() return false end,
      { "-c", 'printf "%s" "$(date "+%Y-%m-%d %H:%M")" | tr -d "\n" | pbcopy' }
   )
   task:start()
end

-- <Ctrl-Cmd-Apostrophe(Quote)> — Put dashed date-plus-time into clipboard.
-- - CALSO: Homefries $(TTTtt-) command.

function obj:snipISODateTimeDashed()
   local task = hs.task.new(
      "/bin/dash",
      nil,
      function() return false end,
      { "-c", 'printf "%s" "$(date "+%Y-%m-%d-%H-%M")" | tr -d "\n" | pbcopy' }
   )
   task:start()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeySnipISODateToday(mapping)
   if mapping["snipISODateToday"] then
      if (self.keySnipISODateToday) then
         self.keySnipISODateToday:delete()
      end

      self.keySnipISODateToday = hs.hotkey.bindSpec(
         mapping["snipISODateToday"],
         function()
            self:snipISODateToday()
         end
      )
   end
end

function obj:bindHotkeySnipISODateTimeNormal(mapping)
   if mapping["snipISODateTimeNormal"] then
      if (self.keySnipISODateTimeNormal) then
         self.keySnipISODateTimeNormal:delete()
      end

      self.keySnipISODateTimeNormal = hs.hotkey.bindSpec(
         mapping["snipISODateTimeNormal"],
         function()
            self:snipISODateTimeNormal()
         end
      )
   end
end

function obj:bindHotkeySnipISODateTimeDashed(mapping)
   if mapping["snipISODateTimeDashed"] then
      if (self.keySnipISODateTimeDashed) then
         self.keySnipISODateTimeDashed:delete()
      end

      self.keySnipISODateTimeDashed = hs.hotkey.bindSpec(
         mapping["snipISODateTimeDashed"],
         function()
            self:snipISODateTimeDashed()
         end
      )
   end
end


--- DateTimeSnips:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for DateTimeSnips
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * snipISODateToday — 
---   * snipISODateTimeNormal — 
---   * snipISODateTimeDashed — 
function obj:bindHotkeys(mapping)
   self:bindHotkeySnipISODateToday(mapping)
   self:bindHotkeySnipISODateTimeNormal(mapping)
   self:bindHotkeySnipISODateTimeDashed(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

