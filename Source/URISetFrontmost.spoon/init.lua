-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === URISetFrontmost ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/URISetFrontmost.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/URISetFrontmost.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "URISetFrontmost"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- URISetFrontmost.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('URISetFrontmost')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- We can trigger Hammerspoon tasks from the command line.
--
-- - E.g.,
--
--     open -g hammerspoon://sensible-open?url=https://google.com
--
--   Using:
--
--     hs.urlevent.bind("sensible-open", function(eventName, params)
--       chromeWithProfile("Default", params['url'])
--     end)

-- Wire a Hammerspoon URI action to setFrontmost the specified app.
--
-- - One user of this function is `sensible-open`:
--
--   https://github.com/landonb/sh-sensible-open#☔
--
-- `sensible-open` is used to open URLs from the command line, and by some
-- shell apps (like git-open). But that call might not always front Chrome
-- (i.e., it'll open a new Chrome window behind the active window; and
-- once that starts happening, only quitting and restarting Chrome seems
-- to make it work again).
-- 
-- - `sensible-open` relies on the `open` command, e.g.,
--
--     open -na 'Google Chrome' --args --new-window <URL>
--
--   but that function will sometimes open the new window *behind* the
--   active window, as described above.
--
-- - So here we offer the Hammerspoon setFrontmost function, which will
--   always bring the new window (and only the new window) to the front.
--
--   - Now `sensible-open` can check if Hammerspoon and this config is
--     installed, and can hook this function to fix the problem.
--
-- - MAYBE: We could eventually wire URLDispatcher and offer that to
--   sensible-open, for an even more powerful and customizable user
--   experience.

-- USAGE:
--
--   $ open -g "hammerspoon://setFrontmost?app=${browser_app}"

-- Note that is not an object:method, more of a class.function.
-- - ALTLY: Instead of:
--     hs.urlevent.bind("setFrontmost", self.uriSetFrontmost)
--   We could define an object:method:
--     function obj:uriSetFrontmost(eventName, params)
--   and call it thusly
--     hs.urlevent.bind(
--       "setFrontmost",
--       function(eventName, params)
--         self:uriSetFrontmost(eventName, params)
--       end
--     )

obj.uriSetFrontmost = function(eventName, params)
  print("eventName: " .. hs.inspect(eventName))
  print("params: " .. hs.inspect(params))
  local app = hs.application(params['app'])

  if app then
    -- DUNNO: Is this similar to `front_win:raise():focus()`?
    app:setFrontmost()
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- URISetFrontmost:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * None
function obj:start()
  hs.urlevent.bind("setFrontmost", self.uriSetFrontmost)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

