-- vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=lua
-- Author: Landon Bouma <https://tallybark.com/>
-- Project: https://github.com/DepoXy/macOS-Hammyspoony#🥄
-- License: MIT

--- === AppTapChrome ===
---
--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapChrome.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppTapChrome.spoon.zip)

local obj = {}
obj.__index = obj

--- Metadata
obj.name = "AppTapChrome"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppTapChrome.logger
--- Variable
--- - Logger object used within the Spoon. Can be accessed to set
---   the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppTapChrome')

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapChrome feature flags
--- Variables
--- - USAGE: To disable a feature, set its feature flag to false.
---   - E.g.,
---
---       appTapAttach = hs.loadSpoon("AppTapAttach")
---       appTapAttach:start()
---
---       local appTapChrome = hs.loadSpoon("AppTapChrome")
---       appTapChrome.enable["DeleteBackwardUsingCtrlW"] = false
---       appTapChrome:start(appTapAttach)

obj.enable = {}
obj.enable["DeleteBackwardUsingCtrlW"] = true
obj.enable["ReloadThisPageUsingF5"] = true
obj.enable["AlwaysOnBackForwardUsingCmdLeftRight"] = true
obj.enable["LinuxlikeLeftRightMotions"] = true
-- ISOFF: The AppleScript (sussRoleOfElement) takes a half-second or second
-- to run, which is annoying. So suggesting to leave this off and to rewire
-- your brain to use <Alt-Left>/<Alt-Right> instead of <Home>/<End>, to jump
-- to line beg/end; and to use <Cmd-Up>/<Cmd-Down>, not <Ctrl-Home>/<Ctrl-End>,
-- to jump to doc beg/eng.
obj.enable["LinuxlikeHomeEndMotions"] = false
obj.enable["SometimesOnBackForwardUsingAltLeftRight"] = true
obj.enable["OpenLinkInNewTabUsingCtrlClick"] = true

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:chromeRwdFwdGetEventtap()
  return hs.eventtap.new(
    {
      hs.eventtap.event.types.keyDown,
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.leftMouseUp,
    },
    function(e)
      return self:chromeRwdFwdGetEventtapCallback(e)
    end
  )
end

function obj:chromeRwdFwdGetEventtapCallback(e)
  local eventType = e:getType()
  -- SAVVY: Flags contain "fn" when non-character pressed.
  -- - E.g., <Left>, <Right>, <Home>, <End>, etc.
  local eventFlags = e:getFlags()

  -- Process Key down events.
  if eventType == hs.eventtap.event.types.keyDown then
    local keyCode = e:getKeyCode()

    -- USAGE: Uncomment to debug/pry:
    --   print("e:getType(): " .. hs.inspect(eventType))
    --   print("e:getFlags(): " .. tableUtils:tableJoin(eventFlags, ", "))
    --   print("e:getKeyCode(): " .. hs.inspect(keyCode))
    --   local unmodified = false
    --   print("e:getCharacters(false): " .. hs.inspect(e:getCharacters(unmodified)))

    -- Delete backward on <Ctrl-W>
    if keyCode == hs.keycodes.map["w"] then
      if self.enable["DeleteBackwardUsingCtrlW"]
        and eventFlags:containExactly({"ctrl"})
      then
        -- SAVVY: <Ctrl-Backspace> works in location but not text input;
        --        <Alt-Backspace> works in any edit control, incl. locat.

        -- Emit <Alt-Backspace>
        return true, {hs.eventtap.event.newKeyEvent({"alt"}, hs.keycodes.map["delete"], true)}
      else
        return false
      end
    end

    -- Google Sheets has its own bindings, which you cannot customize.
    -- - So rather than rely on System Settings Keyboard Shortcuts for
    --   Chrome, e.g.,
    --     defaults write com.google.Chrome NSUserKeyEquivalents '{ ... }'
    --   we'll use the event tap for those Google Sheets bindings that we
    --   care about, and that won't interfere with normal Chrome bindings.
    if eventFlags:containExactly({"ctrl"}) then
      if false then

      -- Edit > Undo
      elseif keyCode == hs.keycodes.map["z"] then
        return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["z"], true)}

        -- Edit > Redo
      elseif keyCode == hs.keycodes.map["y"] then
        return true, {hs.eventtap.event.newKeyEvent({"cmd"}, hs.keycodes.map["y"], true)}

      end
    end

    -- Short-circuit now if we know we don't care about the event,
    -- just to be expeditious.
    if not eventFlags["fn"] then
      -- We know that special character has *not* been pressed.

      return false
    end

    -- Reload on <F5>/<Shift-F5>
    if keyCode == hs.keycodes.map["F5"] then
      if self.enable["ReloadThisPageUsingF5"]
        and (eventFlags:containExactly({"fn"})
          or eventFlags:containExactly({"shift", "fn"})
        )
      then
        -- <F5>/<Shift-F5> → <Ctrl-R>/<Shift-Ctrl-R> (View > *Reload This Page*)
        local withCtrl = tableUtils:tableMerge(eventFlags, {["ctrl"] = true})
        -- "Delete" the "fn" key (it goes with "F5", but not normal characters).
        withCtrl["fn"] = nil
        local newFlags = tableUtils:tableKeys(withCtrl)

        -- Emit <Ctrl-R> or <Shift-Ctrl-R>
        return true, {hs.eventtap.event.newKeyEvent(newFlags, hs.keycodes.map["r"], true)}
      else
        return false
      end
    end

    -- BWARE: See note above: Avoid race condition with other events
    -- caused by sussRoleOfElement() running slowly b/c AppleScript.
    if true
      and keyCode ~= hs.keycodes.map["left"]
      and keyCode ~= hs.keycodes.map["right"]
      and keyCode ~= hs.keycodes.map["home"]
      and keyCode ~= hs.keycodes.map["end"]
    then

      return false
    end

    -- Process <Left>/<Right> and <Home>/<End> combinations.
    local deleteEvent
    local newEvents

    -- Map <Cmd-Left>/<Cmd-Right> to history Back/Forward, always,
    -- and not just when edit input is not active.
    if self.enable["AlwaysOnBackForwardUsingCmdLeftRight"] then
      deleteEvent = self:processEventForLeftRight("cmd", keyCode, eventFlags)
      if deleteEvent then
        -- hs.alert.show("processEventForLeftRight/cmd")

        return deleteEvent
      end
    end

    if not (
      self.enable["LinuxlikeLeftRightMotions"]
      or self.enable["LinuxlikeHomeEndMotions"]
      or self.enable["SometimesOnBackForwardUsingAltLeftRight"]
    ) then

      return false
    end

    -- When edit control active, <Left>/<Right> and <Home>/<End> combos move
    -- the cursor.
    local roleOfElement = self:sussRoleOfElement()

    if self.textInputRoles[roleOfElement] then
      -- Remap modifier + <Left>/<Right> combinations to be more Linux-like.
      if self.enable["LinuxlikeLeftRightMotions"] then
        -- CXREF: ~/.kit/mOS/macOS-Hammyspoony/Source/MotionUtils.spoon/init.lua
        deleteEvent, newEvents = motionUtils:newKeyEventForLeftRight(keyCode, eventFlags)
        if deleteEvent then
          -- hs.alert.show("newKeyEventForLeftRight")

          return deleteEvent, newEvents
        end
      end

      -- Remap <Home>/<End> from doc beg/end to line-wise beg/end;
      -- use <Ctrl-Home>/<Ctrl-End> for doc beg/end;
      -- and don't scroll browser window when at combobox beg/end.
      if self.enable["LinuxlikeHomeEndMotions"] then
        -- CXREF: ~/.kit/mOS/macOS-Hammyspoony/Source/MotionUtils.spoon/init.lua
        deleteEvent, newEvents = motionUtils:newKeyEventForHomeEnd(keyCode, eventFlags)
        if deleteEvent then
          -- hs.alert.show("newKeyEventForHomeEnd")

          return deleteEvent, newEvents
        end
      end
    else
      -- Wire <Alt-Left>/<Alt-Right> to Backward/Forward like in Linux,
      -- but unlike in Linux, only when *not* in an edit control (in
      -- Linux, <Alt-Left>/<Alt-Right> always changes location, even
      -- when an edit control is active (which is my only gripe about
      -- the Linux behavior)).
      if self.enable["SometimesOnBackForwardUsingAltLeftRight"] then
        deleteEvent = self:processEventForLeftRight("alt", keyCode, eventFlags)
        if deleteEvent then
          -- hs.alert.show("processEventForLeftRight/alt")

          return deleteEvent
        end
      end
    end
  end  -- eventType == hs.eventtap.event.types.keyDown

  -- Process Mouse down/Mouse up events
  if eventType == hs.eventtap.event.types.leftMouseDown
    or eventType == hs.eventtap.event.types.leftMouseUp
  then

    -- Map <Ctrl-Click> to <Cmd-Click>, i.e., open link in new tab.
    -- - SAVVY: <Shift-Click> opens link in new window.
    if self.enable["OpenLinkInNewTabUsingCtrlClick"] then
      if eventFlags:containExactly({"ctrl"}) then

        -- Emit <Cmd-Click> at event location.
        return true, {hs.eventtap.event.newMouseEvent(eventType, e:location(), {"cmd"})}
      end
    end
  end

  -- Return false to propagate event.
  return false
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Edit input roles:
--
--   AXTextField  — e.g., Chrome location input
--   AXTextArea   — e.g., GitHub multi-line edit box
--   AXComboBox   — e.g., Google search box

obj.textInputRoles = {
  ["AXTextField"] = true,
  ["AXTextArea"] = true,
  ["AXComboBox"] = true,
}

-- I don't know AppleScript well and couldn't find decent docs,
-- but somehow after an hour of digging I found that these work:
--
--   'attribute "AXFocusedUIElement"'
--   'properties of attribute "AXFocusedUIElement"'
--   'value of attribute "AXFocusedUIElement"'

function obj:sussRoleOfElement()
  local _success, roleOfElement, _rawOutOrErrorDict = hs.osascript.applescript(
    "tell application \"System Events\"\n" ..
    "  tell process \"Google Chrome\"\n" ..
    "    role of value of attribute \"AXFocusedUIElement\"\n" ..
    "  end tell\n" ..
    "end tell\n"
  )
  -- print("roleOfElement: " .. hs.inspect(roleOfElement))
  -- print("_rawOutOrErrorDict: " .. hs.inspect(_rawOutOrErrorDict))
  -- hs.alert.show("roleOfElement: " .. hs.inspect(roleOfElement))

  -- Note that if nothing is selected/focused/active, this is nil.
  --   if not roleOfElement then
  --     hs.alert.show("ALERT: No roleOfElement!")
  --   end

  return roleOfElement
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- On Linux, <Alt-Left>/<Alt-Right> *always* calls history Back/Forward.
-- On macOS, <Cmd-Left>/<Cmd-Right> only calls Back/Forward if an edit
-- control is not active (<Cmd-[>/<Cmd-]> also B/F, but always work.)

-- Note that sending keystroke to command that's redefined using
-- `defaults write com.google.Chrome NSUserKeyEquivalents` does
-- not work. (You can send keystroke for the original binding,
-- though).
--
-- So here we pick the command from the menu instead.

function obj:processEventForLeftRight(cmdOrAlt, keyCode, eventFlags)
  if eventFlags:containExactly({cmdOrAlt, "fn"})
    and (keyCode == hs.keycodes.map["left"]
      or keyCode == hs.keycodes.map["right"])
  then
    local app = hs.application.find("Google Chrome")

    if keyCode == hs.keycodes.map["left"] then
      app:selectMenuItem({"History", "Back"})
    elseif keyCode == hs.keycodes.map["right"] then
      app:selectMenuItem({"History", "Forward"})
    end

    return true
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapChrome:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
  appTapAttach:registerApptap(
    "Google Chrome",
    function()
      return self:chromeRwdFwdGetEventtap()
    end
  )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

