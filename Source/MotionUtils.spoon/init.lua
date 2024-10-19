-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === MotionUtils ===
---
--- Just a collection of some Lua table utility functions.
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip)

-- MAYBE/2024-10-12: Should this not be a Spoon?

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "MotionUtils"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- MotionUtils.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('MotionUtils')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Normal macOS motions:
-- - <Ctrl-Left>/<Ctrl-Right> is same as <Left>/<Right>
-- - <Cmd-Left>/<Cmd-Right> is line-wise beg/end.
-- - <Alt-Left>/<Alt-Right> is word-wise beg/end.
--
-- On Linux and in (author's) Vim:
-- - <Ctrl-Left>/<Ctrl-Right> is word-wise beg/end.
-- - <Cmd-Left>/<Cmd-Right> is same as <Left>/<Right>.
-- - <Alt-Left>/<Alt-Right> is line-wise beg/end.
--
-- Here we swap <Ctrl-Left>/<Ctrl-Right> and <Alt-Left>/<Alt-Right>
-- to be more Linux-like; selecting text, too, if <Shift> involved.

-- SAVVY: "Seeing the fn flag is expected for most non-character keys"
--   https://github.com/Hammerspoon/hammerspoon/issues/3101

function obj:newKeyEventForLeftRight(keyCode, eventFlags)
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

  return false
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Normal macOS <Home>/<End> goes to document beg/end,
-- but on Linux and in Vim, <Home>/<End> are line-wise.
-- - So map <Home>/<End> to macOS <Cmd-Left>/<Cmd-Right>.
--
-- Normal macOS <Ctrl-Home>/<Ctrl-End> does nothing, bit on Linux
-- and in Vim, <Ctrl-Home>/<Ctrl-End> go to document beg/end.
-- - So map <Ctrl-Home>/<Ctrl-End> to macOS <Home>/<End> (remember
--   that newKeyEvent bypasses Hammerspoon and NSUserKeyEquivalents).
--
-- Also map same bindings with <Shift> to select text across the
-- same motion.

function obj:newKeyEventForHomeEnd(keyCode, eventFlags)
  if (keyCode == hs.keycodes.map["home"]
    or keyCode == hs.keycodes.map["end"])
  then
    if eventFlags:containExactly({"fn"})
      or eventFlags:containExactly({"shift", "fn"})
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

