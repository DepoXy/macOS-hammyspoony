-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === BrowserWindowFronters ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/BrowserWindowFronters.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/BrowserWindowFronters.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "BrowserWindowFronters"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- BrowserWindowFronters.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('BrowserWindowFronters')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- Internal variables: Key bindings
obj.keyFrontEmail = nil
obj.keyFrontChats = nil
obj.keyFrontPowerThesaurus = nil
obj.keyFrontRegexDict = nil
obj.keyFrontDevTools = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Open URL in new Chrome window.
--
-- SAVVY: This unhides other hidden Chrome windows (though not
-- minimized Chrome windows). I'm not sure there's a way not to.
-- - I.e., I'm now sure we can open a new Chrome without unhiding
--   other Chrome windows.
--
-- COPYD/THANX: https://news.ycombinator.com/item?id=29535518
function obj:chromeWithProfile(profile, url)
  local task = hs.task.new(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    nil,
    function() return false end,
    { "--profile-directory=" .. profile, "--new-window", url }
  )
  task:start()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Bring front and focus specific Chrome window,
-- or open URL if no matching window is found.
--
-- CXREF:
--   https://www.hammerspoon.org/docs/hs.window.html#raise
--   https://www.hammerspoon.org/docs/hs.window.html#focus

-- INERT/2024-07-20: Add support to open URLs using different profiles,
-- e.g.,
--
--   open -a "Google Chrome" --args --profile-directory=$NAME
--
-- where $NAME for your current Chrome profile can be found by looking
-- at Profile Path in chrome://version
-- - REFER: https://news.ycombinator.com/item?id=29535518
--
-- See also zzamboni's innovative approach to ensuring URLs
-- are opened by a specific Chrome profile, or even by different
-- browsers depending on the URL path, using their own config and
-- the powerful URLDispatcher spoon:
--
--   https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#url-dispatching-to-site-specific-browsers

-- SPIKE: Do we need to keep function reference so doesn't get
-- garbage-collected?
--
-- - I.e., not this?:
-- 
--     function browser_window_front_or_open(url, matches)
--       ...
--     end

function obj:browserWindowFrontOrOpen(url, profile, matches)
  local win

  if not matches then
    matches = profile
    profile = "Default"
  elseif not profile then
    profile = "Default"
  end

  for i = 1, #matches do
    win = hs.window(matches[i])
    if win then break end
  end

  if win then
    win:raise():focus()
  elseif url ~= "" then
    self:chromeWithProfile(profile, url)
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Bring front/focus browser email window.
--
-- - Opens first window found with the following text:
--   - Gmail prefix
--       "Inbox "
--   - Google Calendar [author keeps Gmail and Cal tabs in same window]
--       "Google Calendar - "
--   - Outlook prefix [for when you use Outlook on a host and not Gmail]
--       "Mail - "
--   - Outlook, when you've been logged off (/srsly)
--       "Sign in to Outlook"
--   - Outlook, when you've been signed out (ugh, more timeout plz)
--       "Sign out"
--
-- - If you wanted to strictly only open Gmail, you could look
--   for user's email addy, e.g.,
--     "first.last@gmail.com"

function obj:frontEmail()
  self:browserWindowFrontOrOpen(
    "https://mail.google.com/mail/u/0/#inbox",
    {
      "@gmail.com",
      "Inbox ",
      "Google Calendar - ",
      "Mail - ",
      "Sign in to Outlook",
      "Sign out",
    }
  )
end

-------

-- Messenger or Assorted Chat tab foregrounder
--
-- - Opens first window found with the following text:
--   - Android SMS
--       "Messages for web"
--       "Google Messages for web"
--   - Facebook Messenger
--       "Messenger"
--   - Insta
--       "Inbox • Chats"
--   - Author's local BM index
--       "🗨️         Chat & Social"

function obj:frontChats()
  self:browserWindowFrontOrOpen(
    "https://www.messenger.com/",
    {
      "Messages for web",
      "Google Messages for web",
      "Messenger",
      "Inbox • Chats",
      "🗨️         Chat & Social",
    }
  )
end

-------

-- PowerThesaurus [browser window]

function obj:frontPowerThesaurus()
  self:browserWindowFrontOrOpen(
    "https://www.powerthesaurus.org/",
    {
      "Power Thesaurus",
    }
  )
end

-------

-- Regex Dictionary by Lou Hevly [browser window]

function obj:frontRegexDict()
  self:browserWindowFrontOrOpen(
    "https://www.visca.com/regexdict/",
    {
      "Regex Dictionary by Lou Hevly",
    }
  )
end

-------

-- Google Chrome — Raise *Inspect* Window
--
-- - You must pop DevTools out into a separate window for this to work.

function obj:frontDevTools()
  self:browserWindowFrontOrOpen(
    "",
    {
      "DevTools",
      "Inspect with Chrome Developer Tools",
      "devtools://",
    }
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:bindHotkeyFrontEmail(mapping)
  if mapping["frontEmail"] then
    if (self.keyFrontEmail) then
      self.keyFrontEmail:delete()
    end

    self.keyFrontEmail = hs.hotkey.bindSpec(
      mapping["frontEmail"],
      function()
        self:frontEmail()
      end
    )
  end
end

function obj:bindHotkeyFrontChats(mapping)
  if mapping["frontChats"] then
    if (self.keyFrontChats) then
      self.keyFrontChats:delete()
    end

    self.keyFrontChats = hs.hotkey.bindSpec(
      mapping["frontChats"],
      function()
        self:frontChats()
      end
    )
  end
end

function obj:bindHotkeyFrontPowerThesaurus(mapping)
  if mapping["frontPowerThesaurus"] then
    if (self.keyFrontPowerThesaurus) then
      self.keyFrontPowerThesaurus:delete()
    end

    self.keyFrontPowerThesaurus = hs.hotkey.bindSpec(
      mapping["frontPowerThesaurus"],
      function()
        self:frontPowerThesaurus()
      end
    )
  end
end

function obj:bindHotkeyFrontRegexDict(mapping)
  if mapping["frontRegexDict"] then
    if (self.keyFrontRegexDict) then
      self.keyFrontRegexDict:delete()
    end

    self.keyFrontRegexDict = hs.hotkey.bindSpec(
      mapping["frontRegexDict"],
      function()
        self:frontRegexDict()
      end
    )
  end
end

function obj:bindHotkeyFrontDevTools(mapping)
  if mapping["frontDevTools"] then
    if (self.keyFrontDevTools) then
      self.keyFrontDevTools:delete()
    end

    self.keyFrontDevTools = hs.hotkey.bindSpec(
      mapping["frontDevTools"],
      function()
        self:frontDevTools()
      end
    )
  end
end

--- FrillsChrome:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for FrillsChrome
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * frontEmail — 
---   * frontChats — 
---   * frontPowerThesaurus — 
---   * frontRegexDict — 
---   * frontDevTools — 
function obj:bindHotkeys(mapping)
  self:bindHotkeyFrontEmail(mapping)
  self:bindHotkeyFrontChats(mapping)
  self:bindHotkeyFrontPowerThesaurus(mapping)
  self:bindHotkeyFrontRegexDict(mapping)
  self:bindHotkeyFrontDevTools(mapping)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

