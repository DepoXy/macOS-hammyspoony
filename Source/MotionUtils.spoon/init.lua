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
-- - Both <Ctrl-Left>/<Ctrl-Right> and <Shift-Ctrl-Left>/<Shift-Ctrl-Right>
--   are same as <Left>/<Right> in LibreOffice;
--   - In Chrome edit input, <Ctrl-Left>/<Ctrl-Right> is line-wise beg/end.
-- - <Cmd-Left>/<Cmd-Right> is line-wise beg/end. With <Shift>, selects text.
--   - Same behavior in LibreOffice and Chrome.
--   - In Chrome when edit input is not active, <Cmd-Left>/<Cmd-Right> is
--     history Back/Forward. (When edit active, it's line-wise beg/end.)
--     - (Otherwise in Chrome, <Cmd-[> and <Cmd-]> are also Back/Forward,
--        and they always work, regardless of what's active.)
-- - <Alt-Left>/<Alt-Right> is word-wise beg/end. With <Shift>, selects text.
--   - Same behavior in LibreOffice and Chrome.
--   - In Linux, regardless if edit input active or not,
--     <Alt-Left>/<Alt-Right> is always history Back/Forward.
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

-- Normal macOS <Home>/<End> goes to document beg/end in LibreOffice,
-- but on Linux and in Vim, <Home>/<End> are line-wise.
-- - So map <Home>/<End> to macOS <Cmd-Left>/<Cmd-Right>.
--
-- Normal macOS <Ctrl-Home>/<Ctrl-End> does nothing, but on Linux
-- and in Vim, <Ctrl-Home>/<Ctrl-End> go to document beg/end.
-- - So map <Ctrl-Home>/<Ctrl-End> to macOS <Home>/<End> (remember
--   that newKeyEvent bypasses Hammerspoon and NSUserKeyEquivalents).
--
-- <Shift-Ctrl-Home>/<Shift-Ctrl-End> does nothing.
-- <Shift-Cmd-Home>/<Shift-Cmd-End> is same as <Shift-Home>/<Shift-End>.
-- <Shift-Alt-Home>/<Shift-Alt-End> does nothing.
--
-- Also map same bindings with <Shift> to select text across the
-- same motion.
--
-- In macOS Chrome AXComboBox:
-- - <Home>/<End> first scrolls combobox up/down, and then pressing
--   again scrolls the browser window up/down; and in neither instance
--   does it move the cursor.
--
-- - <Ctrl-Home>/<Ctrl-End> is same as <Home>/<End>.
-- - <Cmd-Home>/<Cmd-End> does nothing.
-- - <Alt-Home>/<Alt-End> does nothing.
--
-- - <Shift-Home>/<Shift-End> selects from cursor to combobox bed/end.
-- - <Shift-Ctrl|Cmd|Alt-Home>/<Shift-Ctrl|Cmd|Alt-End> does nothing.
--
-- In both LibreOffice and in Chrome AXComboBox:
-- - <Up>/<Down> moves cursor one line up/down.
-- - <Ctrl-Up>/<Ctrl-Down> move cursor one line up/down.
-- - <Cmd-Up>/<Cmd-Down> moves doc-wise to beg/end.
-- - <Alt-Up>/<Alt-Down> moves line-wise to beg/end.
--
-- In Chrome AXComboBox:
-- - <PageUp>/<PageDown> scrolls combobox by the pageful, and after
--   top/bottom of the combobox is visible, pressing again pages the
--   browser window, all without moving the cursor.
--
-- - <Ctrl-PageUp>/<Ctrl-PageDown> changes tabs backward/forward.
-- - <Cmd-PageUp>/<Cmd-PageDown> does nothing.
-- - <Alt-PageUp>/<Alt-PageDown> moves the cursor by the pageful.
--   When top/bottom of the combobox reached, nothing more happens
--   (and neither is the browser window is scrolled).
--
-- - <Shift-Ctrl-PageUp>/<Shift-Ctrl-PageDown> moves (reorders) current
--   tab backward/forward.
-- - <Shift-Cmd-PageUp>/<Shift-Cmd-PageDown> does nothing.
-- - <Shift-Alt-PageUp>/<Shift-Alt-PageDown> is same as
--   <Alt-PageUp>/<Alt-PageDown> (and does not select text).

function obj:newKeyEventForHomeEnd(keyCode, eventFlags)
  if (keyCode == hs.keycodes.map["home"]
    or keyCode == hs.keycodes.map["end"])
  then
    if eventFlags:containExactly({"fn"})
      or eventFlags:containExactly({"shift", "fn"})
    then
      local leftOrRight
      if keyCode == hs.keycodes.map["home"] then
        leftOrRight = hs.keycodes.map["left"]
      elseif keyCode == hs.keycodes.map["end"] then
        leftOrRight = hs.keycodes.map["right"]
      end

      local newFlags = tableUtils:tableKeys(tableUtils:tableMerge(eventFlags, {["cmd"] = true}))

      return true, {hs.eventtap.event.newKeyEvent(newFlags, leftOrRight, true)}
    else
      -- Works in LibreOffice, but not in Chrome:
      --   return true, {hs.eventtap.event.newKeyEvent({"fn"}, keyCode, true)}
      -- Same for:
      --   return true, {hs.eventtap.event.newKeyEvent({"shift", "fn"}, keyCode, true)}
      -- So use <Cmd-Up>/<Cmd-Down>
      local upOrDown
      if keyCode == hs.keycodes.map["home"] then
        upOrDown = hs.keycodes.map["up"]
      elseif keyCode == hs.keycodes.map["end"] then
        upOrDown = hs.keycodes.map["down"]
      end

      if eventFlags:containExactly({"ctrl", "fn"}) then
        return true, {hs.eventtap.event.newKeyEvent({"cmd", "fn"}, upOrDown, true)}
      elseif eventFlags:containExactly({"shift", "ctrl", "fn"}) then
        return true, {hs.eventtap.event.newKeyEvent({"shift", "cmd", "fn"}, upOrDown, true)}
      end
    end
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

