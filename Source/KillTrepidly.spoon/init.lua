-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === KillTrepidly ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/KillTrepidly.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/KillTrepidly.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "KillTrepidly"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- KillTrepidly.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('KillTrepidly')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- Internal variable: Key binding for kill trepidation.
obj.keyKill = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Hold <Cmd-Q> to quit apps.
--
-- - CXREF:
--   ~/.kit/mOS/hammerspoons/Source/HoldToQuit.spoon/init.lua
--
-- - I did not test... but I might if I find myself quiting
--   apps unexpectedly/accidentally.
--
--  holdToQuit = hs.loadSpoon("HoldToQuit")
--  holdToQuit:init()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Map <Ctrl-Q> to app:kill().
--
-- - I.e., make <Ctrl-Q> like <Cmd-Q>, for my Linux-addled brain.
--
-- SAVVY: Note that sending key stroke doesn't work without the app,
--        e.g., this doesn't have any effect:
--
--          hs.eventtap.keyStroke({"cmd"}, "Q")
--
--        - But this works:
--
--          hs.eventtap.keyStroke({"cmd"}, "Q", app)
--
--        So where does Hammerspoon send the key stroke if no app
--        is specified? (I don't know and I don't really care.)
--
-- In any case, we'll be pedantic and kill, which
-- "tries to terminate the app gracefully".
--
-- - I.e., <Ctrl-Q> always kills the active app, regardless...

obj.inhibitCtrlQBinding = {
  ["MacVim"] = true,
}

function obj:killTrepidation()
  local app = hs.application.frontmostApplication()

  if not self.inhibitCtrlQBinding[app:name()] then
    -- CALSO: app:kill()
    hs.eventtap.keyStroke({"cmd"}, "Q", app)
  else
    hs.eventtap.keyStroke({"ctrl"}, "Q", app)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeyKillTrepidly(mapping)
  if mapping["kill"] then
    if (self.keyKill) then
      self.keyKill:delete()
    end

    self.keyKill = hs.hotkey.bindSpec(
      mapping["kill"],
      function()
        self:killTrepidation()
      end
    )
  end
end

--- KillTrepidly:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for KillTrepidly
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * kill - kill application
function obj:bindHotkeys(mapping)
  self:bindHotkeyKillTrepidly(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

