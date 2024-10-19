-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === LinuxlikeCutCopyPaste ===
---
--- (Mostly) Systemwide: — Wire Edit Command Bindings
---
--- - USAGE: Use <Ctrl-X>, <Ctrl-C>, <Ctrl-V>, and <Ctrl-A>
---   as you would the conventional macOS bindings.
---
---   - Note that the macOS bindings are not modified herein,
---     so <Cmd-X>, <Cmd-C>, <Cmd-V>, and <Cmd-A> continue to
---     work, as well.
---
--- - OMITD: This Spoon *does not* wire the bindings for terminal
---   applications, where (at least) <Ctrl-C> has a special behavior
---   (i.e., generates SIGINT).
---
--- - HSRTY: A former Karabiner-Elements ruleset the author used swapped
---   both ways, i.e., Ctrl-key → Cmd-key, and also Cmd-key → Ctrl-key.
---
---   - But the Cmd- bindings are so macOS-universal, we probably want
---     to avoid reusing the Cmd-key bindings for anything else, anyway:
---
---     - So we'll just *mirror* the edit bindings via <Ctrl>,
---       and we'll leave the original <Cmd> bindings active.
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/LinuxlikeCutCopyPaste.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "LinuxlikeCutCopyPaste"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- LinuxlikeCutCopyPaste.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('LinuxlikeCutCopyPaste')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- LinuxlikeCutCopyPaste.frontmostApplicationUnless
--- Variable
--- - Table of apps to which to *not* change the key stroke.
--- - Named after Karabiner-Elements' `frontmost_application_unless`.

obj.frontmostApplicationUnless = {
  ["iTerm2"] = true,
  ["Terminal"] = true,
  ["Alacritty"] = true,
}

--- TRACK/2024-10-09: If any app already wires some behavior from any
--- of the <Ctrl> bindings we override, we'll need to use hs.event.tap.new
--- and hs.eventtap.event.newKeyEvent to *replace* the <Ctrl> keypress.
---
--- - Currently this Spoon lets the <Ctrl> key stroke pass through, and
---   it only adds an additional <Cmd> key stroke.

function obj:emitCommandKeyEquivalent(char)
  local app = hs.application.frontmostApplication()

  if not self.frontmostApplicationUnless[app:name()] then
    hs.eventtap.keyStroke({"cmd"}, char, app)
  else
    hs.eventtap.keyStroke({"ctrl"}, char, app)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- LinuxlikeCutCopyPaste:start()
--- Method
--- Starts the Spoon: Wires the keybindings.
---
--- Parameters:
---  * None
function obj:start()
  for _, char in ipairs({"X", "C", "V", "A"}) do
    hs.hotkey.bind({"ctrl"}, char, function()
      self:emitCommandKeyEquivalent(char)
    end)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

