-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- REFER: Here are some excellent resources on Hammerspoon, Lua, and beyond:

-- - Getting Started with Hammerspoon
--
--     https://www.hammerspoon.org/go/

-- - Learn Lua in Y minutes
--
--     https://learnxinyminutes.com/docs/lua/

-- - Hammerspoon Spoon Plugins Documentation
--
--     https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md

-- - [Diego Zamboni's] Hammerspoon config file
--
--     https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org
--
--   is an excellent resource, for more than just Hammerspoon.
--
--   - It also shows you the power of Emacs Org mode, and gives you a
--     peek at zzamboni's other dev environment infrastructure.

-- - Most of these bindings started out in a `skhdrc` file:
--
--     https://github.com/DepoXy/macOS-skhibidirc#👤
--
--   But it's easier to front a single window in Hammerspoon without
--   also bringing all the other app windows forward, too.
--
--   CXREF: You can see the original `skhd` bindings (and comments)
--   in the `skhdrc.OFF`, on path in a DepoXy environment at:
--
--     ~/.kit/mOS/macOS-skhibidirc/.config/skhd/skhdrc.OFF
--
-- - Lua PIL:
--
--     https://www.lua.org/pil/contents.html
--
-- - *Understanding Lua's tables*
--
--    https://stackoverflow.com/a/73445264

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Update `hs.loadSpoon()` search path to include Spoons repo.
--
-- SETUP: Note this assumes you have
--
--          https://github.com/Hammerspoon/Spoons
--
--        cloned at
--
--          ~/.kit/mOS/hammerspoons
--
--        which is where DepoXy clones it.
--
--        (Not that we need all the Spoons,
--         but this is just too easy.)

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.kit/mOS/hammerspoons/Source/?.spoon/init.lua"

-- CXREF: For reusability, this core init.lua is mostly limited to defining
-- the keybindings, while most of the relevant functionality is implemented
-- by these individual Spoons:
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapAttach.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapChrome.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapGnucash.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapLibreoffice.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapMeld.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapSlack.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/AppWindowChooser.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/BrowserWindowFronters.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/DateTimeSnips.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/FrillsAlacrittyAndTerminal.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/FrillsChrome.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/KillTrepidly.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/LinuxlikeCutCopyPaste.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/MinimizeAndHideWindows.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/NeverLoseFocus.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/TableUtils.spoon/init.lua
--   ~/.kit/mOS/macOS-Hammyspoony/Source/URISetFrontmost.spoon/init.lua
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/Source/?.spoon/init.lua"

-------

-- USAGE: Change the log level if you want more scrawl in the Hammerspoon Console, e.g.:
--
--   hs.logger.defaultLogLevel = "info"
--
-- REFER: https://github.com/Hammerspoon/hammerspoon/blob/56b5835/extensions/logger/logger.lua#L13
--
--   local LEVELS={nothing=0,error=ERROR,warning=WARNING,info=INFO,debug=DEBUG,verbose=VERBOSE}
--
-- SAVVY: For reference, log level defaults 'warning' (2):
--
--   require("hs.logger")
--   hs.hotkey.bind({"ctrl", "cmd"}, "A", function()
--     -- Shows: "LogLevel: warning"
--     hs.alert.show("LogLevel: " .. hs.logger.defaultLogLevel)
--   end)

-------

-- Hot-reload config file changes using ReloadConfiguration Spoon.
--
-- Note this won't reload a symlimk (which is what DepoXy creates at
-- ~/.hammerspoon/init.lua) so we plumb all the directory paths to watch.
--
-- - The reloader tracks the directories for these files:
--
--    ~/.kit/mOS/macOS-Hammyspoony/.hammerspoon/init.lua
--    ~/.depoxy/ambers/home/.hammerspoon/depoxy-hs.lua
--    ~/.depoxy/running/home/.hammerspoon/client-hs.lua
--
-- USAGE: Obvi, if you install this project to an alt. path (e.g., `~/src`),
-- you'll want to change the first path. (And you probably won't care about
-- the other two paths).
-- - INERT: If you're a DepoXy user trying to use an alternative path,
--   e.g., DOPP_KIT=~/src, that's not plumbed here (though could be).
--   - We'd have to source the Client depoxyrc and read DOPP_KIT from it:
--       ~/.depoxy/running/home/.config/depoxy/depoxyrc
--   - But for now it's just easier to fork this project, or to use
--     git-put-wise to make a "PRIVATE" commit that modifies these paths.

-- See the bottom of this file for where we load the DepoXy and Client configs.
local hmy_cfg_dir = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/.hammerspoon"
local hmy_spn_dir = os.getenv("HOME") .. "/.kit/mOS/macOS-Hammyspoony/Source"
local dxy_cfg_dir = os.getenv("HOME") .. "/.depoxy/ambers/home/.hammerspoon"
local dxc_cfg_dir = os.getenv("HOME") .. "/.depoxy/running/home/.hammerspoon"

-- CXREF:
-- ~/.kit/mOS/hammerspoons/Source/ReloadConfiguration.spoon/init.lua

local reloadConfig = hs.loadSpoon("ReloadConfiguration")
reloadConfig.watch_paths = {
  hs.configdir,
  hmy_cfg_dir,
  hmy_spn_dir,
  dxy_cfg_dir,
  dxc_cfg_dir,
}
reloadConfig:start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Load table utility fcns.

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/TableUtils.spoon/init.lua

tableUtils = hs.loadSpoon("TableUtils")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/MinimizeAndHideWindows.spoon/init.lua

local minimizeAndHideWindows = hs.loadSpoon("MinimizeAndHideWindows")

minimizeAndHideWindows:bindHotkeys({
  -- BNDNG: <Shift-Ctrl-Cmd-W>
  allButFrontmost={{"shift", "ctrl", "cmd"}, "W"},
  -- BNDNG: <Shift-Ctrl-Alt-W>
  allWindows={{"shift", "ctrl", "alt"}, "W"},
})

-- local shift_ctrl_cmd_w = minimizeAndHideWindows.keyAllButFrontmost
-- local shift_ctrl_alt_w = minimizeAndHideWindows.keyAllWindows

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/FrillsAlacrittyAndTerminal.spoon/init.lua

frillsAlacrittyAndTerminal = hs.loadSpoon("FrillsAlacrittyAndTerminal")

frillsAlacrittyAndTerminal:bindHotkeys({
  -- BNDNG: <Shift-Ctrl-Cmd-0>
  unminimzeAllAlacrittyWindows={{"shift", "ctrl", "cmd"}, "0"},
  -- BNDNG/s: <Cmd-1>, <Cmd-2>, ..., <Cmd-9>
  alacrittyWindowFronters1Through9Prefix={"cmd"},
  -- BNDNG: <Cmd-0>
  alacrittyNewWindow={{"cmd"}, "0"},
  -- BNDNG: <Shift-Cmd-0>
  alacrittyForegrounderOpener={{"shift", "cmd"}, "0"},
  -- BNDNG: <Ctrl-Cmd-0>
  terminalNewWindow={{"ctrl", "cmd"}, "0"},
})

-- local shift_ctrl_cmd_0 = frillsAlacrittyAndTerminal.keyUnminimzeAllAlacrittyWindows
-- local cmd_1 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[1]
-- local cmd_2 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[2]
-- local cmd_3 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[3]
-- local cmd_4 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[4]
-- local cmd_5 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[5]
-- local cmd_6 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[6]
-- local cmd_7 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[7]
-- local cmd_8 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[8]
-- local cmd_9 = frillsAlacrittyAndTerminal.keysAlacrittyWindowFronters1Through9[9]
local cmd_0 = frillsAlacrittyAndTerminal.keyAlacrittyNewWindow
-- local shift_cmd_0 = frillsAlacrittyAndTerminal.keyAlacrittyForegrounderOpener
-- local ctrl_cmd_0 = frillsAlacrittyAndTerminal.keyTerminalNewWindow

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapAttach.spoon/init.lua

-- Define registerApptap, which the AppTap* Spoons use to wire their
-- eventtap subscribers to specific applications.
appTapAttach = hs.loadSpoon("AppTapAttach")

appTapAttach:start()

-------

local appTapGnucash = hs.loadSpoon("AppTapGnucash")

appTapGnucash:start(appTapAttach)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapAttach.spoon/init.lua

local appTapSlack = hs.loadSpoon("AppTapSlack")

appTapSlack:start(appTapAttach)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/FrillsChrome.spoon/init.lua

frillsChrome = hs.loadSpoon("FrillsChrome")

frillsChrome:bindHotkeys({
  -- BNDNG: <Cmd-T>
  newChromeWindow={{"cmd"}, "T"},
  -- BNDNG: <Shift-Cmd-T>
  frontChromeWindow={{"shift", "cmd"}, "T"},
})

local cmd_t = frillsChrome.keyNewChromeWindow
local shift_cmd_t = frillsChrome.keyFrontChromeWindow

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/URISetFrontmost.spoon/init.lua

local uriSetFrontmost = hs.loadSpoon("URISetFrontmost")

uriSetFrontmost:start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/BrowserWindowFronters.spoon/init.lua

browserWindowFronters = hs.loadSpoon("BrowserWindowFronters")

browserWindowFronters:bindHotkeys({
  -- BNDNG: <Shift-Ctrl-Cmd-A>
  frontEmail={{"shift", "ctrl", "cmd"}, "A"},
  -- BNDNG: <Shift-Ctrl-Cmd-S>
  frontChats={{"shift", "ctrl", "cmd"}, "S"},
  -- BNDNG: <Shift-Ctrl-Cmd-P>
  frontPowerThesaurus={{"shift", "ctrl", "cmd"}, "P"},
  -- BNDNG: <Shift-Ctrl-Cmd-8>
  frontRegexDict={{"shift", "ctrl", "cmd"}, "8"},
  -- BNDNG: <Shift-Ctrl-Cmd-R>
  frontDevTools={{"shift", "ctrl", "cmd"}, "R"},
})

-- local shift_ctrl_cmd_a = browserWindowFronters.keyFrontEmail
-- local shift_ctrl_cmd_s = browserWindowFronters.keyFrontChats
-- local shift_ctrl_cmd_p = browserWindowFronters.keyFrontPowerThesaurus
-- local shift_ctrl_cmd_8 = browserWindowFronters.keyFrontRegexDict
-- local shift_ctrl_cmd_r = browserWindowFronters.keyFrontDevTools

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Create Meld window filter to disable certain hotkeys.
--
-- - Because Meld doesn't let us remap its menu keys, and we don't
--   want to block certain menu bindings, like <Cmd-F> Find.
--   (Otherwise I would've liked to change <Cmd-F> to <Ctrl-F>.)
--
-- - The author doesn't use Meld very often, so disabling certain
--   hotkeys while it runs is not a big deal.
--
-- - Note that checking the active app doesn't work, because hotkey
--   is still bound, e.g., <Cmd-F> won't run Meld Edit > Find if we
--   did the following:
--
--     hs.hotkey.bind({"cmd"}, "F", function()
--       local fmost_app = hs.application.frontmostApplication()
--
--       if fmost_app:title() ~= "Meld" then
--         hs.application.launchOrFocus("Finder")
--       end
--     end)
--
-- - So we'll use a window.filter instead. Note that application.watcher
--   might also work.
--
--     https://www.hammerspoon.org/docs/hs.window.filter.html
--     https://www.hammerspoon.org/docs/hs.application.watcher.html
--
-- - THANX: https://stackoverflow.com/a/64095788

-- Toggle hotkey enablement when window is focused and unfocused.
local filter_ignore_hotkey = function(win_filter, hotkey)
  -- DUNNO: Hotkey doesn't seem to work at first, unless
  -- explicitly enabled.
  hotkey:enable()

  win_filter
    :subscribe(hs.window.filter.windowFocused, function()
      -- Disable hotkey in app
      hotkey:disable()
    end)
    :subscribe(hs.window.filter.windowUnfocused, function()
      -- Enable hotkey when focusing out of app
      hotkey:enable()
    end)
end

-------

-- Prepare app window filters and hotkey subscribers for apps that don't
-- use native macOS windows (or whatever it is they do different; the
-- author doesn't know Cocoa or macOS apps well enough to know exact
-- reason why some apps ignore Keyboard Shortcuts > App Shortcuts, aka
--     defaults write <bundle-ID> NSUserKeyEquivalents
-- - Use case: Note that setting `NSUserKeyEquivalents` will update the
--   shortcuts listed in the menu drop-downs, so you might want to use
--   both NSUserKeyEquivalent and an eventtap, so the UX reflects the
--   Hammerspoon tap.

-- Prepare an Adobe Acrobat Reader window filter and hotkey subscriber.
-- - Not used herein but used by some client-hs.lua, so defined here.
local acrobat_reader_filter = hs.window.filter.new("Acrobat Reader")

ignore_hotkey_acrobat_reader = function(hotkey)
  filter_ignore_hotkey(acrobat_reader_filter, hotkey)
end

-------

-- Prepare a GIMP window filter and hotkey subscriber.
local gimp_filter = hs.window.filter.new("GIMP")

ignore_hotkey_gimp = function(hotkey)
  filter_ignore_hotkey(gimp_filter, hotkey)
end

ignore_hotkey_gimp(cmd_t)

-------

-- Prepare GnuCash window filter.

local gnucashWindowFilter = hs.window.filter.new("Gnucash")

ignore_hotkey_gnucash = function(hotkey)
  filter_ignore_hotkey(gnucashWindowFilter, hotkey)
end

-- Prepare a similar LibreOffice window filter.
-- - Not used herein but used by some client-hs.lua, so defined here.
local libreoffice_filter = hs.window.filter.new("LibreOffice")

ignore_hotkey_libreoffice = function(hotkey)
  filter_ignore_hotkey(libreoffice_filter, hotkey)
end

-------

-- Prepare a Meld window filter and hotkey subscriber.
-- - Not used herein but used by some client-hs.lua, so defined here.
local meld_filter = hs.window.filter.new("Meld")

ignore_hotkey_meld = function(hotkey)
  filter_ignore_hotkey(meld_filter, hotkey)
end

-------

-- Prepare a Slack window filter and hotkey subscriber.
local slack_filter = hs.window.filter.new("Slack")

ignore_hotkey_slack = function(hotkey)
  filter_ignore_hotkey(slack_filter, hotkey)
end

ignore_hotkey_slack(cmd_0)

ignore_hotkey_slack(shift_cmd_t)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapLibreoffice.spoon/init.lua

local appTapLibreoffice = hs.loadSpoon("AppTapLibreoffice")

appTapLibreoffice:start(appTapAttach)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapMeld.spoon/init.lua

local appTapMeld = hs.loadSpoon("AppTapMeld")

appTapMeld:start(appTapAttach)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Finder foregrounder/opener

-- BNDNG: <Cmd-F>
local cmd_f = hs.hotkey.bind({"cmd"}, "F", function()
  hs.application.launchOrFocus("Finder")
end)

ignore_hotkey_gnucash(cmd_f)
ignore_hotkey_meld(cmd_f)
ignore_hotkey_slack(cmd_f)

-------

-- MacVim foregrounder/opener

-- BNDNG: <Cmd-Backtick> (<Cmd-`>)
hs.hotkey.bind({"cmd"}, "`", function()
  hs.application.launchOrFocus("MacVim")
end)

-------

-- Slack foregrounder/opener

-- BNDNG: <Shift-Ctrl-Cmd-F>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "F", function()
  hs.application.launchOrFocus("Slack")
end)

-------

-- GnuCash foregrounder/opener

-- BNDNG: <Shift-Ctrl-Cmd-G>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "G", function()
  hs.application.launchOrFocus("GnuCash")
end)

-------

-- Spotify foregrounder/๏קєภer

-- BNDNG: <Shift-Ctrl-Cmd-X>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "X", function()
  hs.application.launchOrFocus("Spotify")
end)

-------

-- LibreOffice foregrounder/opener
-- - Mnemonic: *Edit* (I know, "edit" could mean so many things! Esp. text "editor").

-- BNDNG: <Shift-Ctrl-Cmd-E>
hs.hotkey.bind({"shift", "ctrl", "cmd"}, "E", function()
  hs.application.launchOrFocus("LibreOffice")
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/DateTimeSnips.spoon/init.lua

dateTimeSnips = hs.loadSpoon("DateTimeSnips")

dateTimeSnips:bindHotkeys({
  -- BNDNG: <Cmd-Minus> (<Cmd-->)
  snipISODateToday={{"cmd"}, "-"},
  -- BNDNG: <Ctrl-Cmd-Semicolon> (<Ctrl-Cmd-;>)
  snipISODateTimeNormal={{"ctrl", "cmd"}, ";"},
  -- BNDNG: <Ctrl-Cmd-Quote> (<Ctrl-Cmd-SingleQuote>, <Ctrl-Cmd-Apostrophe>, <Ctrl-Cmd-'>)
  snipISODateTimeDashed={{"ctrl", "cmd"}, "'"},
})

-- local cmd_hyphen = dateTimeSnips.keySnipISODateToday
-- local ctrl_cmd_colon = dateTimeSnips.keySnipISODateTimeNormal
-- local ctrl_cmd_apostrophe = dateTimeSnips.keySnipISODateTimeDashed

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppWindowChooser.spoon/init.lua

local appWindowChooser = hs.loadSpoon("AppWindowChooser")

appWindowChooser.appName = "Google Chrome"

-- OWELL: The first 9 choices are assigned a <Cmd-1>..<Cmd-9> binding
-- by hs.chooser, but there's no option to disable those bindings.
-- - And they don't work, anyway, because of the Terminal window
--   bindings defined above.

appWindowChooser:bindHotkeys({
  -- BNDNG: <Ctrl-Space> (<Ctrl- >) (as inspired by Contexts)
  show_chooser={{"ctrl"}, "Space"}
})

appWindowChooser:start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/AppTapChrome.spoon/init.lua

local appTapChrome = hs.loadSpoon("AppTapChrome")

appTapChrome:start(appTapAttach)

chromeWindowFilter = hs.window.filter.new("Google Chrome")

-- Not used herein, but defined for client usage.
ignore_hotkey_chrome = function(hotkey)
  filter_ignore_hotkey(chromeWindowFilter, hotkey)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/NeverLoseFocus.spoon/init.lua

hs.loadSpoon("NeverLoseFocus"):start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Nice! 4-second (or shorter, if you hotkey again, or <Esc>) clock overlay.
--
-- CXREF:
-- ~/.kit/mOS/hammerspoons/Source/AClock.spoon/init.lua

aClock = hs.loadSpoon("AClock")

-- BNDNG: <Ctrl-Alt-C>
-- - Complements <Ctrl-Alt-D> Show Desktop, which might reveal GeekTool
--   geeklet(s), if you put any there (as suggested by DepoXy setup docs).
hs.hotkey.bind({"ctrl", "alt"}, "c", function()
  -- ALTLY: spoon.AClock:toggleShow()
  aClock:toggleShow()
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/KillTrepidly.spoon/init.lua

local killTrepidation = hs.loadSpoon("KillTrepidly")

killTrepidation:bindHotkeys({
  -- BNDNG: <Ctrl-Q>
  kill={{"ctrl"}, "Q"},
})

-- local ctrl_q = killTrepidation.keyKill

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Wire Cut, Copy, Paste, and Select All accelerator aliases
-- from <Ctrl>.

-- CXREF:
-- ~/.kit/mOS/macOS-Hammyspoony/Source/LinuxlikeCutCopyPaste.spoon/init.lua

-- BNDNGs: <Ctrl-X>, <Ctrl-C>, <Ctrl-V>, <Ctrl-A>
hs.loadSpoon("LinuxlikeCutCopyPaste"):start()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Load optional configs.
--
-- - This project, while stand-alone, serves for DepoXy (and for the
--   general public, either as something to fork, or as something to
--   reference, like you would anyone's dot-files).
--
--   So here we load DepoXy's config, where DepoXy-specific bindings live.
--
--   And we also load DepoXy Client config, which is private user config.
--
-- - But we do so carefully, because `require` fails if the file is absent.
--
--   - Note we could use `pcall` to ignore errors, e.g.,
--
--       package.path = package.path ...
--       pcall(require, "depoxy-hs")
--
--     but that would mask errors in the downstream config.
--
--     So we'll confirm paths first, and then call `require` directly.

-- Note that Lua doesn't include a full suite of filesystem utilities.
--
-- - With stock Lua, we can try to open the file to see if it exists.
--
-- - INERT: Perhaps someday we'll add Lua modules, like `luaposix`, which
--   provides POSIX bindings we could use to improve the file-exists check,
--   e.g.:
--
--   - Install luaposix module:
--
--       brew install lua
--       brew install luarocks
--       luarocks install luaposix
--
--   - Check file exists without explicitly opening it:
--
--       -- https://lunarmodules.github.io/luafilesystem/
--       require "lfs"
--
--       function load_config(cfg_dir)
--         local cfg_file = cfg_dir .. "/init.lua"
--
--         if lfs.attributes(cfg_file) then
--           require(cfg_file)
--         end
--       end

file_exists = function(path)
  if type(path) ~= "string" then return false end

  local file = io.open(path, "r")

  return file ~= nil and io.close(file)
end

load_config = function(dir, base)
  local sep = sep or package.config:sub(1,1)

  local path = dir..sep..base..".lua"

  if file_exists(path) then
    package.path = package.path .. ";" .. dir..sep.."?.lua"

    require(base)
  end
end

load_configs = function(sep)
  local sep = sep or package.config:sub(1,1)

  -- CXREF: ~/.depoxy/ambers/home/.hammerspoon/depoxy-hs.lua
  load_config(dxy_cfg_dir, "depoxy-hs")

  -- CXREF: ~/.depoxy/running/home/.hammerspoon/client-hs.lua
  load_config(dxc_cfg_dir, "client-hs")
end

load_configs()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

