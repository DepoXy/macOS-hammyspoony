-- === AppWindowChooser ===

-- Opens an FZF-style browser window switcher.
--
-- - This menu is inspired by Contexts.
--
--     https://contexts.co/
--
--   - Contexts' <Cmd-Space> menu shows a similar FZF switcher.
--
--   - (Though I'm sure Contexts was inspired by something else;
--      in fact, its <Cmd-Space> menu looks surprisingly similar
--      to the Hammerspoon hs.chooser menu! It's even positioned
--      similarly and has the same background color.)
--
-- - See comments below re: hs.window.switcher
--
--   - I demoed hs.window.switcher first before landing on
--     hs.chooser for this feature.
--
--   - And I left lots of comments below, too.
--
-- - When I think of a window switcher, I often think of Linux
--   (or Windows) <Alt-Tab>, or the elegant macOS AltTab app.
--
--   - AltTab is great. It shows window thumbnails organized
--     horizontally.
--
--   - But if you have dozens of browser windows open, you
--     might find it quicker to find the window you're after
--     using its title, rather than hunting for its thumbnail
--     (or trying to read the small window title text above
--     each icon).
--
--     - That is, AltTab is great for switching between the
--       active window and a recently used window.
--
--       And it can work well for finding other windows in
--       certain circumstances.
--
--       But it becomes more difficult (or at least slower)
--       to use as the number of open windows increases.
--
--     - So if you have dozens of browser windows open and
--       visible (as this author sometimes does), AltTab
--       is not necessarily the best tool for finding the
--       window you want.
--
-- - So this binding offers an alternative window switcher
--   approach, using a top-down (vertical) window title
--   list.
--
--   - You can click the title of the window you want to
--     front;
--
--   - Or you can <Up>/<Down> and <Enter> to front it;
--
--   - Or you can enter its title into the query input.
--
-- - Most importantly, this widget is title-centric, and
--   not icon- (or MRU-) centric like AltTab.
--
--   - You're basically looking at an alphabetized list
--     of window titles and picking the one you want.
--
--     And not hunting visually through a list of window
--     icons trying to find what looks like what you want.
--
-- REFER: See the hs.window.switcher demo below, which is
--        what I demoed first before discovering hs.chooser
--
-- BOOYA: I've been using Hammerspoon for five days, and it
-- continues to amaze me! I thought about this feature over
-- dinner, and then it took me 1-1/2 hours to (a) scan the
-- Hammerspoon API to find an appropriate library to use, and
-- (b) to code the solution! (And then it's taken me another
-- 1-1/2 hours to comment about it, but that's normal for me!)
--
-- REFER: https://www.hammerspoon.org/docs/hs.chooser.html
--
--    https://evantravers.com/articles/2020/06/12/hammerspoon-handling-windows-and-layouts/
--
--    - It was inspired by https://github.com/chipsenkbeil/choose
--
-- - An example 'choices' table generator, if you need something
--   to test with your next hs.chooser feature idea:
--
--     local refreshChoices = function()
--       return {
--         {
--          ["text"] = "First Choice",
--          ["subText"] = "This is the subtext of the first choice",
--          -- "uuid" shows how you can use arbitrary keys in the table
--          ["uuid"] = "0001",
--         },
--         { ["text"] = "Second Option",
--           ["subText"] = "I wonder what I should type here?",
--           ["uuid"] = "Bbbb",
--         },
--         -- This example shows how you can stylize text
--         { ["text"] = hs.styledtext.new("Third Possibility", {
--             font = {size = 18},
--             color = hs.drawing.color.definedCollections.hammerspoon.green}
--           ),
--           ["subText"] = "What a lot of choosing there is going on here!",
--           ["uuid"] = "III3",
--         },
--       }
--     end

--- Download: [https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppWindowChooser.spoon.zip](https://github.com/DepoXy/macOS-Hammyspoony/raw/release/Spoons/AppWindowChooser.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppWindowChooser"
obj.version = "1.0.0"
obj.author = "Landon Bouma <https://tallybark.com/>"
obj.homepage = "https://github.com/DepoXy/macOS-Hammyspoony#🥄"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppWindowChooser.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default
---   log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('AppWindowChooser')

-- Internal variable: Key binding for showing the chooser
obj.key_show_chooser = nil

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- USAGE: Set the appName to what you want. Defaults Chrome.
obj.appName = "Google Chrome"

obj.maxTitleLength = 70

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Sort table by object attribute.
-- - Use comp_fcn to compare objects (or leave nil and
--   sorts by object comparison).
-- - We use this function to sort by hs.window:title(),
--   though this really is a generic library function.
--
-- THANX: https://www.lua.org/pil/19.3.html
function obj:pairsByKeys(list, comp_fcn)
  local sorted = {}

  for index, _ in pairs(list) do
    table.insert(sorted, index)
  end

  table.sort(sorted, comp_fcn)

  -- Create an iterator
  local index = 0

  local iter = function()
    index = index + 1
    if sorted[index] == nil then
      return nil
    else
      return sorted[index], list[sorted[index]]
    end
  end

  return iter
end

-- SAVVY: Sometimes when all Chrome windows are minimized, the
-- window filter returns no windows. But not always. Then you
-- open a new Chrome window or unminimize one, and the window
-- filter works again.
--
-- - So use app:allWindows(), and not a window filter like this:
--
--     -- SAVVY: Use empty filter with hs.window.filter.new() so that
--     -- it includes minimized and hidden windows, and doesn't restrict
--     -- itself to only visible windows.
--     local empty_filter = {}
--     local win_filter = hs.window.filter.new({[app_name] = empty_filter,})
--     local app_windows = win_filter:getWindows()

-- REFER: https://www.hammerspoon.org/docs/hs.chooser.html#choices
function obj:refreshChoices()
  local choices = {}

  local app = hs.application.get(self.appName)

  if not app then

    return nil
  end

  self:cacheAppIcon(app)

  local app_windows = app:allWindows()

  local sorted_wins = self:pairsByKeys(
    app_windows,
    function(lhs, rhs)
      return self:cmpWindowTitles(lhs, rhs, app_windows)
    end
  )

  self:addChoice(choices, "» New Window", nil)

  for _, win in sorted_wins do
    self:addChoice(choices, win:title(), win)
  end

  return choices
end

function obj:cmpWindowTitles(lhs, rhs, app_windows)
  local do_sort_emoji_before_ascii = true
  -- REFER: https://www.charset.org/utf-8
  local ascii_threshold = 127

  local lhs_lower = app_windows[lhs]:title():lower()
  local rhs_lower = app_windows[rhs]:title():lower()

  -- REFER: UTF-8 Support
  --   https://www.lua.org/manual/5.4/manual.html#6.5
  local lhs_is_emoji = lhs_lower ~= "" and utf8.codepoint(lhs_lower) > ascii_threshold
  local rhs_is_emoji = rhs_lower ~= "" and utf8.codepoint(rhs_lower) > ascii_threshold

  if lhs_is_emoji and not rhs_is_emoji then
    return do_sort_emoji_before_ascii
  elseif rhs_is_emoji and not lhs_is_emoji then
    return not do_sort_emoji_before_ascii
  else
    return lhs_lower < rhs_lower
  end
end

-- Note that setSize does nothing, e.g.,
--   app_icon = self.app_icon:setSize({w = 32, h = 32,})
-- is ignored by hs.chooser
-- - The problem is that long window titles will wrap around
--   the control, and the icon image will grow to match the
--   larger height.
--   - And then you see different sized images in the FZF window.
-- - So here we'll try to keep the window title to one line, so
--   it doesn't wrap. It should also be faster to read:
--   - Remove common window postfix.
--   - Truncate if longer than some length.
function obj:prepareTitle(title)
  -- Strip " - Google Chrome - <User>" postfix.
  -- REFER: Lua 20.2 — Patterns: https://www.lua.org/pil/20.2.html
  title = title:gsub(" %- Google Chrome %- .*", "")

  -- Truncate string if it's too long.
  -- - Otherwise it'll wrap around and enlarge the item's icon image.
  local _, title_len = title:gsub(".", "")

  if title_len > self.maxTitleLength then
    title = title:sub(1, self.maxTitleLength) .. "…"
  end

  return title
end

function obj:addChoice(choices, title, win)
  title = self:prepareTitle(title)

  local choice = {
    -- ["text"] = win:title(),
    ["text"] = hs.styledtext.new(title, {
      -- font = { size = 18, },
      font = { size = 14, },
      -- REFER: https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/drawing/color/drawing_color.lua#L170
      -- color = hs.drawing.color.definedCollections.hammerspoon.white,
      -- color = hs.drawing.color.definedCollections.x11.whitesmoke,
      -- color = hs.drawing.color.definedCollections.x11.oldlace,
      color = hs.drawing.color.definedCollections.x11.linen,
    }),
    -- ["subText"] = "This is the subtext",
    -- It could be fragile to attach the win object, but works in practice
    ["win"] = win,
    ["image"] = self.appIcon,
  }
  table.insert(choices, choice)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:ctrlSpaceCompletionFn(chosen)
  if chosen then
    if chosen.win then
      chosen.win:raise():focus()
    else
      make_new_chrome_window()
    end
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function obj:toggleChooser()
  if not self.winChooser:isVisible() then
    -- Note that hs.chooser:choices() can be passed a table or a function,
    -- but when passed a function, the fcn is only called once. So it's up
    -- to us to refresh as necessary, which we must do before every :show().
    -- So we'll call the choices fcn. ourselves each time and pass the table.
    -- - We also want to adjust rows() each time to size the popup
    --   appropriately (otherwise it'll have too much empty space,
    --   or the user might have to scroll), which is another reason
    --   to pre-process choices.
    local choices = self:refreshChoices()

    if not choices then
      hs.alert.show(self.appName .. " is not running")

      return
    end

    -- Without measuring *your* screen, 30 or more is generally too many
    -- (given a 1440-tall display, i.e., 2560x1440).
    -- - Defaults to '10':
    --     log:w("winChooser:rows(): " .. winChooser:rows())
    if #choices < 30 then
      -- DUNNO: Using the table(list) count adds more padding than we need,
      -- so substract 1.
      self.winChooser:rows(#choices - 1)
    else
      self.winChooser:rows(30)
    end

    self.winChooser:choices(choices)

    self.winChooser:show()
  else
    -- <Esc> also hides. (I love when <Esc> just works how you'd expect!)
    self.winChooser:hide()
  end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--- AppWindowChooser:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for AppWindowChooser
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * show_chooser - show the app window chooser
function obj:bindHotkeys(mapping)
  if mapping["show_chooser"] then
    if (self.key_show_chooser) then
      self.key_show_chooser:delete()
    end

  self.key_show_chooser = hs.hotkey.bindSpec(
    mapping["show_chooser"],
    function()
      self:toggleChooser()
    end
  )
  end
end

function obj:cacheAppIcon(app)
  if not self.appIcon and app then
    self.appIcon = hs.image.imageFromAppBundle(app:bundleID())
  end
end

--- AppWindowChooser:start()
--- Method
--- "Starts" the Spoon.
---
--- Parameters:
---  * None
function obj:start()
  self.winChooser = hs.chooser.new(
    function(chosen)
      self:ctrlSpaceCompletionFn(chosen)
    end
  )

  -- The placeholderText is what's shown in the query text field
  -- until the user types a query. So there's not really any reason
  -- to have it say anything; it should be obvious to user what to do.
  --
  --   winChooser:placeholderText('bruh')

  -- Modal width defaults to '40.0' [%]:
  --   log:w("winChooser:width(): " .. winChooser:width())
  -- which feels a little too wide (at least on author's 2560x1440
  -- display).
  -- - MAYBE: Adjust this based on user's display size.
  self.winChooser:width(27.0)

  self.appIcon = nil
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return obj

