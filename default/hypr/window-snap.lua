-- Drag-to-snap for floating windows, loaded by the window-snap toggle.
--
-- Dropping a floating window with the cursor against a monitor edge snaps it:
-- the left or right edge to that half, the top edge to the whole screen, and a
-- corner to that quarter. Dropping a snapped window anywhere else gives it back
-- the size it had before it was snapped.
--
-- Hyprland reports no end to a drag, so the drop is found two ways:
--
-- * SUPER + drag: watcher binds on the same chord fire on press and release,
--   and the window that moved with the cursor in between is the one dropped.
--   They have to come before the drag bind, which would otherwise swallow the
--   click, so the drag bind is put back after them.
-- * Titlebar drag: the titlebars plugin takes the press and the release itself,
--   so no bind ever sees one. While the focused window is floating, a watcher
--   checks whether it moves in lockstep with the cursor; once the cursor moves
--   and the window stays, the button is up and the last lockstep point is the
--   drop. That is polling, the last resort for state with no change signal, so
--   it runs only while a floating window has focus. A titlebar drop is seen on
--   the first motion after the release rather than at the release itself.

local EDGE = 6
local CORNER = 160
local MIN_DRAG = 8
local POLL_MS = 40

local press = nil
local watch = nil
local watching = false
local restore = {}

local function monitor_box(monitor)
  local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
  if (monitor.transform or 0) % 2 == 1 then
    width, height = height, width
  end
  return monitor.x, monitor.y, width, height
end

local function monitor_at(x, y)
  for _, monitor in ipairs(hl.get_monitors()) do
    local mx, my, mw, mh = monitor_box(monitor)
    if x >= mx and x < mx + mw and y >= my and y < my + mh then
      return monitor
    end
  end
  return hl.get_monitor_at_cursor()
end

local function gaps_out()
  local gaps = hl.get_config("general.gaps_out")
  if type(gaps) == "table" then
    return gaps.top or gaps[1] or 0
  end
  return tonumber(gaps) or 0
end

local function place(window, x, y, width, height)
  hl.dispatch(hl.dsp.window.resize({ x = math.floor(width), y = math.floor(height), relative = false, window = window }))
  hl.dispatch(hl.dsp.window.move({ x = math.floor(x), y = math.floor(y), relative = false, window = window }))
end

local function zone_at(monitor, x, y)
  local mx, my, mw, mh = monitor_box(monitor)
  local left, right = x <= mx + EDGE, x >= mx + mw - 1 - EDGE
  local top, bottom = y <= my + EDGE, y >= my + mh - 1 - EDGE
  local near_top, near_bottom = y <= my + CORNER, y >= my + mh - CORNER
  local near_left, near_right = x <= mx + CORNER, x >= mx + mw - CORNER

  if (left and near_top) or (top and near_left) then return "top_left" end
  if (right and near_top) or (top and near_right) then return "top_right" end
  if (left and near_bottom) or (bottom and near_left) then return "bottom_left" end
  if (right and near_bottom) or (bottom and near_right) then return "bottom_right" end
  if left then return "left" end
  if right then return "right" end
  if top then return "maximize" end
end

-- The cell sits inside the bar's reserved space and the outer gaps, with an
-- inner gap between halves. Window geometry leaves out the border.
local function snap(window, monitor, zone)
  local mx, my, mw, mh = monitor_box(monitor)
  local reserved = monitor.reserved or {}
  local gap = gaps_out()
  local border = tonumber(hl.get_config("general.border_size")) or 0

  local x = mx + (reserved.left or 0) + gap
  local y = my + (reserved.top or 0) + gap
  local width = mw - (reserved.left or 0) - (reserved.right or 0) - 2 * gap
  local height = mh - (reserved.top or 0) - (reserved.bottom or 0) - 2 * gap
  local half_width, half_height = (width - gap) / 2, (height - gap) / 2

  if zone:find("right") then x = x + half_width + gap end
  if zone:find("bottom") then y = y + half_height + gap end
  if zone ~= "maximize" then width = half_width end
  if zone:find("_") then height = half_height end

  place(window, x + border, y + border, width - 2 * border, height - 2 * border)
end

-- A drag of the window ended with the cursor at (x, y) and the window at (wx, wy).
local function dropped(window, x, y, wx, wy)
  local monitor = monitor_at(x, y)
  if not monitor then
    return
  end

  local zone = zone_at(monitor, x, y)
  if zone then
    restore[window.address] = restore[window.address] or { width = window.size.x, height = window.size.y }
    snap(window, monitor, zone)
  elseif restore[window.address] then
    -- Unsnapped: the old size, with the point it was grabbed by still under the cursor.
    local old = restore[window.address]
    restore[window.address] = nil
    local grab_x = (x - wx) / math.max(window.size.x, 1)
    local grab_y = math.min(y - wy, old.height - 1)
    place(window, x - grab_x * old.width, y - grab_y, old.width, old.height)
  end
end

local function floating(window)
  return window and window.floating and (window.fullscreen or 0) == 0
end

local function watch_tick()
  local window = hl.get_active_window()
  if not floating(window) then
    watching, watch = false, nil
    return
  end
  hl.timer(watch_tick, { timeout = POLL_MS, type = "oneshot" })

  -- A SUPER drag is the binds' to finish.
  if press then
    watch = nil
    return
  end

  local cursor = hl.get_cursor_pos()
  local wx, wy = window.at.x, window.at.y
  local last = watch

  if not last or last.address ~= window.address then
    watch = { address = window.address, wx = wx, wy = wy, x = cursor.x, y = cursor.y }
    return
  end

  local window_moved = wx ~= last.wx or wy ~= last.wy
  local cursor_moved = cursor.x ~= last.x or cursor.y ~= last.y
  local lockstep = window_moved
    and math.abs((cursor.x - wx) - (last.x - last.wx)) <= 2
    and math.abs((cursor.y - wy) - (last.y - last.wy)) <= 2

  if lockstep then
    last.drop = { x = cursor.x, y = cursor.y, wx = wx, wy = wy }
  elseif last.drop and (cursor_moved or window_moved) then
    local drop = last.drop
    watch = nil
    dropped(window, drop.x, drop.y, drop.wx, drop.wy)
    return
  end

  last.wx, last.wy, last.x, last.y = wx, wy, cursor.x, cursor.y
end

local function start_watching()
  if not watching and floating(hl.get_active_window()) then
    watching = true
    hl.timer(watch_tick, { timeout = POLL_MS, type = "oneshot" })
  end
end

local function on_press()
  local cursor = hl.get_cursor_pos()
  local windows = {}
  for _, window in ipairs(hl.get_windows()) do
    if floating(window) then
      windows[window.address] = { x = window.at.x, y = window.at.y }
    end
  end
  press = { x = cursor.x, y = cursor.y, windows = windows }
end

local function on_release()
  local started = press
  press, watch = nil, nil
  if not started then
    return
  end

  local cursor = hl.get_cursor_pos()
  local dx, dy = cursor.x - started.x, cursor.y - started.y
  if math.abs(dx) < MIN_DRAG and math.abs(dy) < MIN_DRAG then
    return
  end

  local dragged, best = nil, 6
  for _, window in ipairs(hl.get_windows()) do
    local before = started.windows[window.address]
    if before and window.floating then
      local drift = math.abs((window.at.x - before.x) - dx) + math.abs((window.at.y - before.y) - dy)
      if drift < best then
        dragged, best = window, drift
      end
    end
  end

  if dragged then
    dropped(dragged, cursor.x, cursor.y, dragged.at.x, dragged.at.y)
  end
end

-- Without Omarchy's bindings there is no SUPER drag of ours to reorder, so a
-- user's own drag bind is left alone and its drops are found by the watcher.
if _G.omarchy_default_bindings ~= false then
  hl.unbind("SUPER + mouse:272")
  hl.bind("SUPER + mouse:272", on_press, { transparent = true, non_consuming = true })
  hl.bind("SUPER + mouse:272", on_release, { transparent = true, ignore_mods = true, non_consuming = true, release = true })
  o.bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
end

hl.on("window.active", start_watching)
hl.on("window.update_rules", start_watching)
hl.on("window.destroy", function(window)
  if window and window.address then
    restore[window.address] = nil
  end
end)

start_watching()
