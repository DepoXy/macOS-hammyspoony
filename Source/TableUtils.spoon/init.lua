-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === TableUtils ===
---
--- Just a collection of some Lua table utility functions.
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip)

-- MAYBE/2024-10-12: Should this not be a Spoon?

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "TableUtils"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- TableUtils.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('TableUtils')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- USAGE: Use in debug/trace output to pry table keys (see usages below).
-- - Not used "in production" and would ideally be commented but for Devs:
--   Whenever author uncomments trace code that calls it, and then its absense
--   silently breaks bindings, I get annoyed. So leaving live. Live with it.
--   ("Silently": Keybinding press no-ops, but Hammerspoon Console shows err.)

-- MAYBE/2024-10-12: Find third-party Lua util file to include, rather than
-- baking your own functions that I'm sure more than one other person has
-- already figured out and published.

function obj:tableCopy(tbl)
   local newTbl = {}

   for key, val in pairs(tbl) do
     newTbl[key] = val
   end

   return newTbl
end

function obj:tableForEach(tbl, callback)
   for key, val in pairs(tbl) do
     callback(key, val)
   end
end

function obj:tableJoin(table, sep)
   local keys = ""

   for k, _ in pairs(table) do
      if keys ~= "" then
         keys = keys .. sep
      end
      keys = keys .. k
   end

   return keys
end

function obj:tableKeys(tbl)
   local keys = {}

   for key,_ in pairs(tbl) do
      table.insert(keys, key)
   end

   return keys
end

function obj:tableLen(tbl)
   local count = 0

   for _ in pairs(tbl) do
      count = count + 1
   end

   return count
end

function obj:tableMerge(lhs, rhs)
   local newTbl = self:tableCopy(lhs)

   for key, val in pairs(rhs) do
      if type(val) == "table"
         and type(newTbl[key] or false) == "table"
      then
         newTbl = tableMerge(newTbl[key] or {}, rhs[key] or {})
      else
         newTbl[key] = val
      end
   end

   return newTbl
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

