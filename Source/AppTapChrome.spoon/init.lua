-- vim:tw=0:ts=3:sw=3:et:norl:nospell:ft=lua
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

obj.chromeWindowFilter = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- KLUGE: When Chrome Save dialog is open, prevent
--        <Ctrl-Left>/<Ctrl-Right> from changing location
--        of web page in the background.
-- - This design choice baffles me!
--   - Use case: I was saving a receipt and editing the filename
--     but hit a familiar keybinding to move the cursor,
--     <Ctrl-Left>, and I didn't notice that it moved the background
--     page backward in history. So I hit <Ctrl-Right> again, to look
--     for the cursor. Then I noticed the browser location had changed.
--     And after saving the document, the browser page had lost the
--     order confirmation, and instead it was scolding me for
--     resubmitting the order. Ha!
--   - I also disabled KE bindings to ensure it's not something funky
--     in my environment (though I'd be curious to test this on stock
--     macOS just to be sure).
--
-- - This watcher hooks Chrome windows and waits for
--   <Ctrl-Left>/<Ctrl-Right> events.
--   - If Chrome has a secondary window open, we assume it's
--     the Save dialog, and we replace the event with an event
--     to move the cursor, <Cmd-Left>/<Cmd-Right>.
-- - Note that if you use KE to swap <Ctrl-Left>/<Ctrl-Right> and
--   <Alt-Left>/<Alt-Right>, it's <Alt-Left>/<Alt-Right> wired to
--   location back/forward, but this binding still sees the
--   unadultered keybindings, <Ctrl-Left>/<Ctrl-Right>.
--   - I'm unsure if this is always the case, or if there's, e.g.,
--     a race condition between Hammerspoon and Karabiner Elements
--     and maybe this isn't always the case. But appears to work
--     this way so far in author's experience.

function obj:chromeRwdFwdGetEventtap()
   return hs.eventtap.new(
      {
         hs.eventtap.event.types.keyDown,
         hs.eventtap.event.types.leftMouseDown,
         hs.eventtap.event.types.leftMouseUp,
      },
      function(e)
         -- USAGE: Uncomment to debug/pry:
         --   local unmodified = false
         --   hs.alert.show("CHARS: " .. e:getCharacters(unmodified))
         --   hs.alert.show("FLAGS: " .. tableUtils:tableJoin(e:getFlags(), ", "))
         -- Note that modifiers includes "fn" when arrow key pressed.
         -- Note if you have KE swapping bindings, to you this is "alt", not "ctrl",
         -- i.e., <Alt-Left>/<Alt-Right>
         -- - But this still works (and problem still exists) when I disable
         --   KE bindings.
         -- - DUNNO: I'm not aware of any race condition here.
         --   - BWARE: But maybe there's a case where Hammerspoon gets the
         --     event after it's manipulated by KE, and what you see is "alt"
         --     instead? Just be on the lookout, in case this stops working.
         local keyCode = e:getKeyCode()
         local eventFlags = e:getFlags()
         local eventType = e:getType()

         if (eventType == hs.eventtap.event.types.keyDown)
            and (eventFlags:containExactly({"ctrl", "fn"})
            and (keyCode == hs.keycodes.map["left"]
               or keyCode == hs.keycodes.map["right"])
         ) then
            suc, _parsed_out, _raw_out_or_error_dict = hs.osascript.applescript(
               "tell application \"System Events\"\n" ..
               "  tell process \"Google Chrome\"\n" ..
               "    tell window 1\n" ..
               "      properties of sheet 1\n" ..
               "    end tell\n" ..
               "  end tell\n" ..
               "end tell\n"
            )
            -- ALTLY: Call via file path rather than passing AppleScript string.
            -- - DUNNO: Is there a performance difference between the two approaches?
            --
            --  probe_osa = os.getenv("HOME") ..
            --    "/.kit/mOS/macOS-Hammyspoony/lib/probe-chrome-sheet-1-of-window-1.osa"
            --  suc, _parsed_out, _raw_out_or_error_dict = hs.osascript.applescriptFromFile(probe_osa)

            if suc then
               hs.alert.show("TOTAL BAM") -- XXX
               -- Return true to delete the event
               --  return true
               -- Or better yet, replace with alt. keycode, <Cmd-Left>/<Cmd-Right>,
               -- which has same effect: jump cursor to start/end of filename input.

               return true, {hs.eventtap.event.newKeyEvent({"alt", "fn"}, keyCode, true)}
            end
         end

         -- Map <Ctrl-Click> to <Cmd-Click>, i.e., open link in new tab.
         if eventFlags:containExactly({"ctrl"}) then
            if eventType == hs.eventtap.event.types.leftMouseDown
               or eventType == hs.eventtap.event.types.leftMouseUp
            then
               return true, {hs.eventtap.event.newMouseEvent(eventType, e:location(), {"cmd"})}
            end
         end

         -- Delete Back-Word like readline (Cmd-w)
         -- SAVVY: Ctrl-Backspace works in location but not text input;
         --        Option-Backspace works in both.
         if eventType == hs.eventtap.event.types.keyDown then
            if eventFlags:containExactly({"ctrl"})
               and keyCode == hs.keycodes.map["w"]
            then
               return true, {hs.eventtap.event.newKeyEvent({"alt"}, hs.keycodes.map["delete"], true)}
            elseif keyCode == hs.keycodes.map["F5"]
               and (eventFlags:containExactly({"fn"}) or eventFlags:containExactly({"shift", "fn"}))
            then
               local withCtrl = tableUtils:tableMerge(eventFlags, {["ctrl"] = true})
               -- "Delete" the "fn" key (it goes with "F5", but not normal characters)
               withCtrl["fn"] = nil
               local newFlags = tableUtils:tableKeys(withCtrl)

               return true, {hs.eventtap.event.newKeyEvent(newFlags, hs.keycodes.map["r"], true)}
            end
         end

         -- Return false to propagate event.
         return false
      end
   )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppTapChrome:start()
--- Method
--- Starts the Spoon: Wires the eventtap.
---
--- Parameters:
---  * appTapAttach
function obj:start(appTapAttach)
   self.chromeWindowFilter = hs.window.filter.new("Google Chrome")

   appTapAttach:filterAttachEventtap(
      self.chromeWindowFilter,
      self.chromeRwdFwdGetEventtap
   )
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

