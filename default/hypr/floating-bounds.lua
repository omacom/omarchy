-- A floating window's titlebar stays where it can be grabbed, as on Windows:
-- a window dropped with its titlebar under the top bar, or above the top of
-- the screen, slides down until all of it shows. The other edges are left
-- alone, so a window can still sit under the dock or partly off screen. And as
-- on Windows, one dropped with the pointer on the top bar, or in the top few
-- pixels of a screen without one, maximizes, and one dropped with the pointer
-- against the left or right edge of a screen fills that half of it.
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

-- A window snapped to a half is marked too, so the dock hides for it as for a
-- maximized one, until it is moved or resized. No Hyprland event follows a
-- tag, so the dock is asked to read its windows again.
local SNAPPED_TAG = require("default.hypr.floating-marks").snapped

local function set_snapped(window, on)
  hl.dispatch(hl.dsp.window.tag({ tag = (on and "+" or "-") .. SNAPPED_TAG, window = window }))
  hl.exec_cmd("omarchy-shell -q omarchy.dock refreshWindows")
end

-- Where the last snap put its window, so the next check does not take the
-- snap itself for the user moving or resizing it.
local snapped_box = nil

-- A snapped window can also be moved or resized from the keyboard, which no
-- click or focus change follows, so while any window is snapped its box is
-- read twice a second, and one that has changed loses the mark. The box is
-- taken once the snap has landed, so a window that cannot shrink that far
-- keeps its mark.
local KEEP_EVERY = 500
local snapped_frames = {}
local keeping = false

local function keep_tick()
  local frames = {}
  for _, window in ipairs(hl.get_windows({ tag = SNAPPED_TAG }) or {}) do
    local box = { x = window.at.x, y = window.at.y, width = window.size.x, height = window.size.y }
    local was = snapped_frames[window.address]
    if was and (was.x ~= box.x or was.y ~= box.y or was.width ~= box.width or was.height ~= box.height) then
      set_snapped(window, false)
    else
      frames[window.address] = box
    end
  end
  snapped_frames = frames
  keeping = next(frames) ~= nil
  if keeping then
    hl.timer(keep_tick, { timeout = KEEP_EVERY, type = "oneshot" })
  end
end

local function keep_snapped(window)
  if window then
    snapped_frames[window.address] = nil
  end
  if not keeping then
    keeping = true
    hl.timer(keep_tick, { timeout = KEEP_EVERY, type = "oneshot" })
  end
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

-- How close to a screen's left or right edge the pointer has to be to snap a
-- window to that half.
local SIDE_MARGIN = 12

-- What a window fills in each snap zone, frame included, against its screen:
-- all that the bars leave of it to maximize, or its left or right half.
local function snap_frame(monitor, zone)
  local _, _, width, height = logical_box(monitor)
  local reserved = monitor.reserved or {}
  local left, top = reserved.left or 0, reserved.top or 0
  local box = { x = left, y = top, width = width - left - (reserved.right or 0), height = height - top - (reserved.bottom or 0) }
  if zone == "left" then
    box.width = math.floor(box.width / 2)
  elseif zone == "right" then
    local half = math.floor(box.width / 2)
    box.x, box.width = box.x + half, box.width - half
  end

  return box
end

-- The screen that continues from this one across its left or right side, at
-- the pointer's height, if any.
local function screen_beyond(monitor, side, y)
  local mx, _, width = logical_box(monitor)
  local edge = side == "left" and mx or mx + width
  for _, other in ipairs(hl.get_monitors()) do
    if other.id ~= monitor.id and other.scale and other.scale > 0 then
      local ox, oy, owidth, oheight = logical_box(other)
      local touching = (side == "left" and ox + owidth == edge) or (side == "right" and ox == edge)
      if touching and y >= oy and y < oy + oheight then
        return other
      end
    end
  end

  return nil
end

-- The side whose snap margin the pointer is in, on the screen under it.
local function side_at(monitor, cursor)
  local mx, _, width = logical_box(monitor)
  if cursor.x < mx + SIDE_MARGIN then
    return "left"
  elseif cursor.x >= mx + width - SIDE_MARGIN then
    return "right"
  end

  return nil
end

-- Where a drop would land, as a zone and the screen it is on: "maximize" on
-- the top bar of the screen the window belongs to, or "left" or "right"
-- against an edge; nil to keep the window's size. A window dropped only partly
-- under the bar, with the pointer below it, keeps its size.
--
-- Where two screens meet, the pointer crosses the margins on both sides of the
-- edge before it is through, so both belong to the screen it came from: a
-- window pulled to the left edge of the right screen snaps there even when
-- the pointer overshoots into the screen beside it, or when most of the window
-- already hangs over that screen. `home` is the id of the screen the pointer
-- was last on outside such margins.
local function snap_target(window, cursor, home)
  local monitor = monitor_at(cursor.x, cursor.y)
  if not monitor then
    return nil
  end

  if cursor.y < math.max(top_edge(monitor), monitor.y + 8) then
    if window.monitor and monitor.id == window.monitor.id then
      return "maximize", monitor
    end
    return nil
  end

  local side = side_at(monitor, cursor)
  if not side then
    return nil
  end

  local beyond = screen_beyond(monitor, side, cursor.y)
  if beyond and home == beyond.id then
    return side == "left" and "right" or "left", beyond
  end

  return side, monitor
end

-- The screen the pointer is on, unless it is in the margins of an edge shared
-- with another screen, where it is still on its way from one to the other.
local function home_at(cursor)
  local monitor = monitor_at(cursor.x, cursor.y)
  if not monitor then
    return nil
  end

  local side = side_at(monitor, cursor)
  if side and screen_beyond(monitor, side, cursor.y) then
    return nil
  end

  return monitor.id
end

-- Snaps a window to a half: its frame fills the box, titlebar and border
-- inside it.
local function snap_to_half(window, monitor, zone)
  -- Hyprland puts a dropped window on the screen most of it covers, which
  -- need not be the one it snaps on.
  local workspace = monitor.active_workspace
  if workspace and window.monitor and window.monitor.id ~= monitor.id then
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace.id), follow = false, window = window }))
  end

  local frame = snap_frame(monitor, zone)
  local border = hl.get_config("general.border_size") or 0
  local bar = titlebar_height(window)
  local x = math.floor(monitor.x + frame.x + border)
  local y = math.floor(monitor.y + frame.y + bar + border)
  hl.dispatch(hl.dsp.window.resize({ x = math.floor(frame.width - 2 * border), y = math.floor(frame.height - bar - 2 * border), relative = false, window = window }))
  hl.dispatch(hl.dsp.window.move({ x = x, y = y, relative = false, window = window }))
  snapped_box = { x = x, y = y, width = math.floor(frame.width - 2 * border), height = math.floor(frame.height - bar - 2 * border) }
  if not tagged(window, SNAPPED_TAG) then
    set_snapped(window, true)
  end
  keep_snapped(window)
  return y
end

local function settle(window, cursor, home)
  local zone, monitor = nil, nil
  if M.drop_maximize then
    zone, monitor = snap_target(window, cursor, home)
  end
  if zone == "maximize" then
    -- Brought into reach first, so leaving the maximized state later restores
    -- a window whose titlebar can still be grabbed.
    local y = keep_title_bar_visible(window)
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", window = window }))
    return y
  elseif zone then
    return snap_to_half(window, monitor, zone)
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

-- While a window is dragged with the pointer on the top bar, the shell shows
-- the box it will fill if dropped there (shell/plugins/window-snap), growing
-- out of the window's own frame, as Windows does when snapping. Hyprland has
-- no event for a drag going on, so from the moment a window is taken up the
-- pointer is read every 30ms, until the window has stood still for a while.
-- The shell is told only when the answer changes.
local SNAP_PREVIEW = "omarchy-shell -q omarchy.window-snap "
local WATCH_EVERY = 30
local WATCH_IDLE_TICKS = 40
-- Hyprland does not say whether the button is still held, so a window that
-- stands still with the pointer on it may be a drag paused over it. It is
-- read four times a second for up to 30 seconds more, so a drag that carries
-- on gets its preview back.
local WATCH_PAUSED_EVERY = 250
local WATCH_PAUSED_TICKS = 120
local preview_zone = nil
local preview_monitor = nil
local watch = nil
local watch_generation = 0

local function box_json(box)
  return string.format('{"x":%d,"y":%d,"width":%d,"height":%d}',
    math.floor(box.x), math.floor(box.y), math.floor(box.width), math.floor(box.height))
end

-- The window's frame, titlebar and border included, against its screen.
local function frame_box(window, monitor)
  local border = hl.get_config("general.border_size") or 0
  local top = frame_top(window)
  return {
    x = window.at.x - border - monitor.x,
    y = top - monitor.y,
    width = window.size.x + 2 * border,
    height = window.at.y + window.size.y + border - top,
  }
end

local function show_preview(window, monitor, zone)
  preview_zone, preview_monitor = zone, monitor.id
  local payload = string.format('{"monitor":"%s","from":%s,"to":%s}',
    tostring(monitor.name), box_json(frame_box(window, monitor)), box_json(snap_frame(monitor, zone)))
  hl.exec_cmd(SNAP_PREVIEW .. "show '" .. payload .. "'")
end

local function hide_preview()
  if preview_zone then
    preview_zone, preview_monitor = nil, nil
    hl.exec_cmd(SNAP_PREVIEW .. "hide")
  end
end

local function watch_tick(generation)
  if generation ~= watch_generation then
    return
  end

  local window = hl.get_active_window()
  local cursor = hl.get_cursor_pos()
  if not (M.drop_maximize and watch and managed(window) and window.address == watch.address and cursor) then
    hide_preview()
    watch = nil
    return
  end

  watch.home = home_at(cursor) or watch.home
  if window.at.x ~= watch.x or window.at.y ~= watch.y then
    watch.x, watch.y, watch.idle, watch.dragged = window.at.x, window.at.y, 0, true
  else
    watch.idle = watch.idle + 1
  end

  local wanted, target = nil, nil
  if watch.dragged and pointer_on(window, cursor) then
    wanted, target = snap_target(window, cursor, watch.home)
  end
  if wanted and (wanted ~= preview_zone or target.id ~= preview_monitor) then
    show_preview(window, target, wanted)
  elseif not wanted then
    hide_preview()
  end

  local every = WATCH_EVERY
  if not wanted and watch.idle >= WATCH_IDLE_TICKS then
    if watch.idle >= WATCH_IDLE_TICKS + WATCH_PAUSED_TICKS or not pointer_on(window, cursor) then
      watch = nil
      return
    end
    every = WATCH_PAUSED_EVERY
  end

  hl.timer(function()
    watch_tick(generation)
  end, { timeout = every, type = "oneshot" })
end

-- A drag starts by making the window active, or with the left button going
-- down on it; either starts the watch over, which also ends any before it.
local function start_watch()
  watch_generation = watch_generation + 1
  local window = hl.get_active_window()
  if not (M.drop_maximize and managed(window)) then
    hide_preview()
    watch = nil
    return
  end

  local cursor = hl.get_cursor_pos()
  watch = { address = window.address, x = window.at.x, y = window.at.y, idle = 0, dragged = false,
    home = cursor and home_at(cursor) or (window.monitor and window.monitor.id) }
  local generation = watch_generation
  hl.timer(function()
    watch_tick(generation)
  end, { timeout = WATCH_EVERY, type = "oneshot" })
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
  if (moved or resized) and tagged(window, SNAPPED_TAG) then
    set_snapped(window, false)
  end
  local cursor = hl.get_cursor_pos()
  if not moved or resized or not cursor or not pointer_on(window, cursor) then
    return
  end

  -- Dropped: whatever the preview showed has happened now, or will not.
  hide_preview()

  -- Remember where the window was put, so the next check does not take the
  -- correction itself for another drop.
  snapped_box = nil
  local y = settle(window, cursor, watch and watch.address == window.address and watch.home or nil)
  if snapped_box then
    last.x, last.y, last.width, last.height = snapped_box.x, snapped_box.y, snapped_box.width, snapped_box.height
  elseif y then
    last.y = y
  end
end

-- Read once Hyprland has finished with the event, so the window is where it
-- landed and the click has focused it.
local function check_soon()
  hl.timer(function()
    check()
    start_watch()
  end, { timeout = 1, type = "oneshot" })
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

-- Windows snapped before a reload are still watched after it.
keep_snapped()

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
