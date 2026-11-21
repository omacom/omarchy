-- A floating window's titlebar stays where it can be grabbed, as on Windows:
-- a window dropped with its titlebar under the top bar, or above the top of
-- the screen, slides down until all of it shows. The other edges are left
-- alone, so a window can still sit under the dock or partly off screen. And as
-- on Windows, one dropped with the pointer on the top bar, or in the top few
-- pixels of a screen without one, maximizes.
--
-- Both are off unless chosen: the floating-title-bar-visible and
-- floating-drop-maximize toggles load this and switch each on, from
-- Appearance > Windows.
--
-- Hyprland reports no end to a drag. A drag by the titlebar, which the client
-- runs itself, never reaches the mouse binds, but both kinds of drag make the
-- window active again as they start and as they end. So the focused window is
-- checked then, and on each left click: one that moved since the last check,
-- at the same size and with the pointer still on it, was just dropped there.
-- Keyboard moves, resizes and windows that place themselves do not count.

local M = { keep_title_bar = false, drop_maximize = false }

local FLOATING_TAG = "omarchy-floating-workspace"
local SELF_FRAMED_TAG = "omarchy-self-framed"
-- A window kept at full size behind another one maximized over it, so the
-- dock hides for it as it would for a maximized one, until it is moved,
-- resized or maximized itself.
local BEHIND_TAG = require("default.hypr.floating-marks").behind

-- The size a window kept at full size behind a maximized one had before, by
-- address, for when it is maximized and restored itself.
local own_sizes = {}

-- A tag a window rule adds is reported with a trailing "*".
local function tagged(window, name)
  for _, tag in ipairs(window.tags or {}) do
    if tag == name or tag == name .. "*" then
      return true
    end
  end

  return false
end

local function set_behind(window, on)
  hl.dispatch(hl.dsp.window.tag({ tag = (on and "+" or "-") .. BEHIND_TAG, window = window }))
end

-- A monitor's box in the layout's logical coordinates, which window positions
-- and the reserved edges share. The odd transforms are the quarter turns.
local function logical_box(monitor)
  local width = monitor.width / monitor.scale
  local height = monitor.height / monitor.scale
  if (monitor.transform or 0) % 2 == 1 then
    width, height = height, width
  end

  return monitor.x, monitor.y, width, height
end

local function monitor_at(x, y)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.scale and monitor.scale > 0 then
      local mx, my, width, height = logical_box(monitor)
      if x >= mx and x < mx + width and y >= my and y < my + height then
        return monitor
      end
    end
  end

  return nil
end

-- Where the top bar ends, or the top of the screen without one.
local function top_edge(monitor)
  return monitor.y + ((monitor.reserved or {}).top or 0)
end

-- Floating workspaces draw a titlebar above the window itself, unless the app
-- draws its own header (see the hyprbars rules in workspace-modes.lua).
local function titlebar_height(window)
  if tagged(window, SELF_FRAMED_TAG) or not (hl.plugin and hl.plugin.hyprbars) then
    return 0
  end

  return hl.get_config("plugin.hyprbars.bar_height") or 0
end

-- The top of what is drawn for the window: its titlebar and the border above.
local function frame_top(window)
  local border = hl.get_config("general.border_size") or 0
  return window.at.y - titlebar_height(window) - border
end

-- Only windows on a floating workspace: tiled, fullscreen and maximized ones
-- are placed by the layout, and the scratchpad's special workspace by its own
-- rules.
local function managed(window)
  return window and window.floating and (window.fullscreen or 0) == 0
    and window.workspace and window.workspace.id >= 1
    and tagged(window, FLOATING_TAG)
end

-- Moves a window whose titlebar is out of reach down to just below the top bar
-- of the screen it is on, and answers the new position, or nil if it was fine.
local function keep_title_bar_visible(window)
  if not managed(window) then
    return nil
  end

  -- With its middle off every screen, above them or pushed out to the side,
  -- it is measured against the screen it belongs to, so a sideways drag
  -- with the titlebar in reach leaves it where it is.
  local top = frame_top(window)
  local monitor = monitor_at(window.at.x + window.size.x / 2, top) or window.monitor
  if not monitor or not monitor.y or top >= top_edge(monitor) then
    return nil
  end

  local y = math.floor(top_edge(monitor) + window.at.y - top)
  hl.dispatch(hl.dsp.window.move({ x = math.floor(window.at.x), y = y, relative = false, window = window }))
  return y
end

-- The pointer holds the titlebar, so where it lets go decides, on the screen
-- the window belongs to. A window dropped only partly under the bar, with the
-- pointer below it, keeps its size.
local function dropped_on_top_bar(window, cursor)
  local monitor = monitor_at(cursor.x, cursor.y)
  if not monitor or not window.monitor or monitor.id ~= window.monitor.id then
    return false
  end

  return cursor.y < math.max(top_edge(monitor), monitor.y + 8)
end

local function settle(window, cursor)
  if M.drop_maximize and dropped_on_top_bar(window, cursor) then
    -- Brought into reach first, so leaving the maximized state later restores
    -- a window whose titlebar can still be grabbed.
    local y = keep_title_bar_visible(window)
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", window = window }))
    return y
  end

  if M.keep_title_bar then
    return keep_title_bar_visible(window)
  end

  return nil
end

local function pointer_on(window, cursor)
  return cursor.x >= window.at.x and cursor.x <= window.at.x + window.size.x
    and cursor.y >= frame_top(window) and cursor.y <= window.at.y + window.size.y
end

local last = nil

local function check()
  local window = hl.get_active_window()
  if not managed(window) then
    last = nil
    return
  end

  local was = last
  last = { address = window.address, x = window.at.x, y = window.at.y, width = window.size.x, height = window.size.y }
  if not was or was.address ~= window.address then
    return
  end

  local moved = was.x ~= window.at.x or was.y ~= window.at.y
  local resized = was.width ~= window.size.x or was.height ~= window.size.y
  -- Moved or resized, it is an ordinary window again, and the size it had
  -- before is no longer the one to go back to.
  if (moved or resized) and tagged(window, BEHIND_TAG) then
    set_behind(window, false)
    own_sizes[window.address] = nil
  end
  local cursor = hl.get_cursor_pos()
  if not moved or resized or not cursor or not pointer_on(window, cursor) then
    return
  end

  -- Remember where the window was put, so the next check does not take the
  -- correction itself for another drop.
  local y = settle(window, cursor)
  if y then
    last.y = y
  end
end

-- Read once Hyprland has finished with the event, so the window is where it
-- landed and the click has focused it.
local function check_soon()
  hl.timer(check, { timeout = 1, type = "oneshot" })
end

hl.on("window.active", check_soon)

-- Hyprland keeps one maximized window per workspace, and maximizing a second
-- one takes the state from the first, which drops back to its own size behind
-- it. As on Windows, a window another one is maximized over keeps its full
-- size instead: it is given the maximized box as a plain floating window, and
-- the size it had before is kept for when it is maximized and restored again.
-- A window un-maximized by Omarchy because another one opened is not covered,
-- as nothing is maximized over it then.
local maximized_boxes = {}


local function place(window, box)
  hl.dispatch(hl.dsp.window.resize({ x = math.floor(box.width), y = math.floor(box.height), relative = false, window = window }))
  hl.dispatch(hl.dsp.window.move({ x = math.floor(box.x), y = math.floor(box.y), relative = false, window = window }))
end

local function box_of(window)
  return { x = window.at.x, y = window.at.y, width = window.size.x, height = window.size.y }
end

local function track_maximized(workspace_id)
  local windows = hl.get_workspace_windows(tostring(workspace_id)) or {}
  local holder = nil
  for _, window in ipairs(windows) do
    if (window.fullscreen or 0) >= 1 then
      holder = window
    end
  end

  for _, window in ipairs(windows) do
    local fullscreen = window.fullscreen or 0
    local was = maximized_boxes[window.address]

    if fullscreen == 1 and tagged(window, FLOATING_TAG) then
      maximized_boxes[window.address] = box_of(window)
      if tagged(window, BEHIND_TAG) then
        set_behind(window, false)
      end
    elseif fullscreen == 0 and was then
      maximized_boxes[window.address] = nil

      if M.drop_maximize and holder and holder.address ~= window.address then
        -- A maximized window on a floating workspace keeps its titlebar, so
        -- its box already clears the top bar. Only a box that would put the
        -- titlebar under the bar is brought down, losing that much height.
        local monitor = window.monitor
        local lowest = monitor and monitor.y
          and top_edge(monitor) + titlebar_height(window) + (hl.get_config("general.border_size") or 0)
        local drop = lowest and math.max(0, lowest - was.y) or 0
        -- Handed over again, it is at the full size it was given last time:
        -- the size from before the first hand-over is still the one to keep.
        own_sizes[window.address] = own_sizes[window.address] or box_of(window)
        place(window, { x = was.x, y = was.y + drop, width = was.width, height = was.height - drop })
        set_behind(window, true)
      elseif own_sizes[window.address] then
        place(window, own_sizes[window.address])
        own_sizes[window.address] = nil
      end
    end
  end
end

hl.on("window.fullscreen", function(window)
  local workspace_id = window and window.workspace and window.workspace.id
  if not workspace_id or workspace_id < 1 then
    return
  end

  hl.timer(function()
    track_maximized(workspace_id)
  end, { timeout = 1, type = "oneshot" })
end)

-- Transparent and non-consuming, so the click still reaches the window.
local passthrough = { transparent = true, non_consuming = true, ignore_mods = true }

hl.bind("mouse:272", check_soon, passthrough)
hl.bind("mouse:272", check_soon, {
  release = true,
  transparent = passthrough.transparent,
  non_consuming = passthrough.non_consuming,
  ignore_mods = passthrough.ignore_mods,
})

return M
