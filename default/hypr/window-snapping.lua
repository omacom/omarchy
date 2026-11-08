-- Window snapping on floating workspaces, the way KDE and Windows do it.
--
--   Super + arrows   halves, then quarters (left, then up = top-left); towards
--                    an edge the window is against already, it maximizes.
--                    Anywhere but a floating workspace, they move focus as ever.
--   Drag to an edge  (by the titlebar, Super + drag, or an app's own titlebar):
--                    a side edge snaps to that half, the top or bottom quarter
--                    of a side edge to a quarter, the top edge maximizes. On an
--                    edge shared with another monitor it snaps after a pause, so
--                    a window can still be dragged across.
--   Drag away        a snapped window gets back the size it had before.
--   Open a window    beside snapped ones, it fills the tile they leave free (the
--                    right half next to a left half); with none free, it shares
--                    the half used last (the third terminal takes a quarter).
--   Close a window   that held a quarter: the window sharing its half grows back.
--   Super + L        into floating, windows keep the places tiling gave them.
--                    Only snapped windows are arranged; nothing else moves.
--
-- The tile maths is in window-snapping-geometry.lua. The drags come from the
-- titlebars plugin (omarchy-hyprland-titlebars): its hyprbars.drag_* events,
-- the size it gives back on pickup, and the size of a window's decorations and
-- limits. Without it, Super + arrows still snap and drags just move.
--
-- The tile a drag would drop into is announced as a Hyprland event for the
-- shell to draw (shell/plugins/snap-preview):
--   custom>>snap-preview <monitor> <x> <y> <w> <h>   (layout coordinates)
--   custom>>snap-preview none

local G = require("default.hypr.window-snapping-geometry")
local workspace_modes = require("default.hypr.workspace-modes")

local M = {}

-- How long a drag rests on an edge shared with another monitor before it snaps.
local SHARED_EDGE_PAUSE_MS = 250

-- The titlebars plugin, when it carries the drag events (hl.plugin.hyprbars).
-- Checked by type: the config is also read by tools that stub out hl.
local function plugin()
  local plugins = hl.plugin
  local titlebars = type(plugins) == "table" and plugins.hyprbars or nil
  if type(titlebars) == "table" and type(titlebars.extents) == "function" then
    return titlebars
  end
end

-- A window snaps when it floats on a floating workspace, not pinned above
-- every workspace and not fullscreen.
local function snappable(window)
  if not window or not window.floating or window.pinned or (window.fullscreen or 0) == 2 then
    return false
  end
  return window.workspace ~= nil and workspace_modes.floating(window.workspace.id)
end

local function side(value, key)
  if type(value) == "table" then
    return value[key] or value.left or 0
  end
  return tonumber(value) or 0
end

local function gaps()
  local outer, inner = hl.get_config("general.gaps_out"), hl.get_config("general.gaps_in")
  return {
    outer = { left = side(outer, "left"), top = side(outer, "top"), right = side(outer, "right"), bottom = side(outer, "bottom") },
    inner = side(inner, "left"),
  }
end

-- What the titlebar and border add around a window's client area.
local function extents(window)
  local titlebars = plugin()
  local ok, found = pcall(function() return titlebars and titlebars.extents(window) end)
  if ok and found then
    return found
  end
  local border = tonumber(hl.get_config("general.border_size")) or 0
  return { left = border, top = border, right = border, bottom = border }
end

-- Whether a window takes a client size: true, false, or nil when that can't be
-- told without the titlebars plugin. Hyprland would clamp it to its limits.
local function fits(window, client)
  local titlebars = plugin()
  local ok, limits = pcall(function() return titlebars and titlebars.limits(window) end)
  if not ok or type(limits) ~= "table" then
    return nil
  end
  local min, max = limits.min or {}, limits.max or {}
  return not ((min.x and client.w < min.x - 1) or (min.y and client.h < min.y - 1)
    or (max.x and client.w > max.x + 1) or (max.y and client.h > max.y + 1))
end

local function area(monitor)
  return G.usable({
    x = monitor.x, y = monitor.y, width = monitor.width, height = monitor.height,
    scale = monitor.scale, transform = monitor.transform, reserved = monitor.reserved,
  })
end

local function monitor_box(monitor)
  return G.usable({
    x = monitor.x, y = monitor.y, width = monitor.width, height = monitor.height,
    scale = monitor.scale, transform = monitor.transform, reserved = {},
  })
end

local function monitors()
  local list, boxes = {}, {}
  for _, monitor in ipairs(hl.get_monitors()) do
    table.insert(list, monitor)
    table.insert(boxes, monitor_box(monitor))
  end
  return list, boxes
end

local function client_of(window)
  return { x = window.at.x, y = window.at.y, w = window.size.x, h = window.size.y }
end

local function restore_of(window)
  for _, tag in ipairs(window.tags or {}) do
    local restore = G.parse_tag(tag)
    if restore then
      return restore, tag
    end
  end
end

local function by_address(address)
  return hl.get_window("address:" .. address)
end

-- The latest placement of each window. A placement's later steps run only
-- while it is still the latest: a second Super + arrow, or a drag, supersedes it.
local placing = {}

-- A window keeps one snap-restore tag: the size to go back to, and the size it
-- was snapped to.
local function retag(window, restore_w, restore_h, snapped_w, snapped_h)
  for _, tag in ipairs(window.tags or {}) do
    if G.parse_tag(tag) then
      hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag, window = window }))
    end
  end
  hl.dispatch(hl.dsp.window.tag({ tag = "+" .. G.tag(restore_w, restore_h, snapped_w, snapped_h), window = window }))
end

-- Whether a window can take a tile on a monitor ("max" always can). Asked
-- before anything moves, so a tile it can't take changes nothing at all.
local function takes(window, tile, monitor)
  if tile == "max" then
    return true
  end
  return fits(window, G.client_box(G.tile_box(area(monitor), tile, gaps()), extents(window))) ~= false
end

-- Put a window into a tile on a monitor. Its size from before the first snap is
-- kept in a snap-restore tag, with the size it was snapped to, for the
-- titlebars plugin to give back when it is dragged away.
function M.place(window, tile, monitor)
  local address = window.address
  if not takes(window, tile, monitor) then
    return
  end
  local token = {}
  placing[address] = token
  -- A drop on another monitor: Hyprland gives a dropped window the workspace
  -- under its centre, which can be the monitor it came from.
  local workspace = monitor.active_workspace
  if window.monitor and window.monitor.name ~= monitor.name and workspace then
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace.id), follow = true, window = window }))
  end
  if tile == "max" then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", window = window }))
    return
  end

  local function apply()
    local current = by_address(address)
    if not current or placing[address] ~= token then
      return
    end
    local before = client_of(current)
    local restore_w, restore_h = before.w, before.h
    -- Snapped already: keep the size from before the first snap, unless it was
    -- resized by hand since; then the size it has now is the one to go back to.
    local restore = restore_of(current)
    if restore and math.abs(before.w - restore.snapped_w) <= 1 and math.abs(before.h - restore.snapped_h) <= 1 then
      restore_w, restore_h = restore.w, restore.h
    end

    local client = G.client_box(G.tile_box(area(monitor), tile, gaps()), extents(current))
    -- Resize first: a floating resize keeps the window's center, then the move
    -- places it.
    hl.dispatch(hl.dsp.window.resize({ x = client.w, y = client.h, relative = false, window = current }))
    hl.dispatch(hl.dsp.window.move({ x = client.x, y = client.y, relative = false, window = current }))
    retag(current, restore_w, restore_h, client.w, client.h)

    -- An app that turns the size down without having said so (or any app,
    -- without the titlebars plugin to ask) would overlap its neighbour: undo.
    hl.timer(function()
      if placing[address] ~= token then
        return
      end
      placing[address] = nil
      local now = by_address(address)
      if not now or (math.abs(now.size.x - client.w) <= 1 and math.abs(now.size.y - client.h) <= 1) then
        return
      end
      for _, tag in ipairs(now.tags or {}) do
        if G.parse_tag(tag) then
          hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag, window = now }))
        end
      end
      hl.dispatch(hl.dsp.window.resize({ x = restore_w, y = restore_h, relative = false, window = now }))
      hl.dispatch(hl.dsp.window.move({ x = before.x, y = before.y, relative = false, window = now }))
    end, { type = "oneshot", timeout = 60 })
  end

  if (window.fullscreen or 0) == 1 then
    -- A maximized window can't move until it has its own size back.
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset", window = window }))
    hl.timer(apply, { type = "oneshot", timeout = 60 })
  else
    apply()
  end
end

local FOCUS = { left = "l", right = "r", top = "u", bottom = "d" }

-- Super + arrow.
function M.key(direction)
  local window = hl.get_active_window()
  if not snappable(window) then
    hl.dispatch(hl.dsp.focus({ direction = FOCUS[direction] }))
    return
  end
  local monitor = window.monitor
  local tile = (window.fullscreen or 0) == 1 and "max" or G.tile_of(G.outer_box(client_of(window), extents(window)), area(monitor), gaps())
  local new = G.press(tile, direction)
  if new ~= tile then
    M.place(window, new, monitor)
  end
end

-- A bind's action, which `hyprctl dispatch 'o.snap.action("left")'` runs as the
-- key does; the keybindings menu replays a bind through that expression.
function M.action(direction)
  local fn = function() M.key(direction) end
  o.bind_expressions[fn] = string.format("o.snap.action(%q)", direction)
  return fn
end

-- Dragging.
local drag
local last_preview

local function announce(monitor, box)
  -- Whole pixels: a usable area need not be (1366 px at scale 1.25).
  local function whole(v) return math.floor(v + 0.5) end
  local message = box and string.format("snap-preview %s %d %d %d %d", monitor.name, whole(box.x), whole(box.y), whole(box.w), whole(box.h)) or "snap-preview none"
  if message ~= last_preview then
    last_preview = message
    hl.dispatch(hl.dsp.event(message))
  end
end

local function show(current)
  if not current or not current.zone then
    return announce(nil)
  end
  local monitor = hl.get_monitor(current.monitor)
  if not monitor then
    return announce(nil)
  end
  announce(monitor, current.zone == "max" and area(monitor) or G.tile_box(area(monitor), current.zone, gaps()))
end

local function begin(window)
  placing[window.address] = nil -- a drag supersedes a placement still settling
  drag = { address = window.address, snaps = snappable(window), generation = 0 }
end

local function moved(window, x, y)
  if not drag or drag.address ~= window.address then
    begin(window) -- a config reload in the middle of a drag
  end
  if not drag.snaps then
    return
  end
  local monitor = hl.get_monitor_at(x, y)
  local zone = monitor and G.zone({ x = x, y = y }, area(monitor)) or nil
  if zone and not workspace_modes.floating(monitor.active_workspace and monitor.active_workspace.id) then
    zone = nil
  end
  if zone and zone ~= drag.candidate and not takes(window, zone, monitor) then
    zone = nil -- no outline for a tile it can't fill
  end
  if zone == drag.candidate and (not monitor or monitor.name == drag.candidate_monitor) then
    return
  end

  drag.candidate, drag.candidate_monitor = zone, monitor and monitor.name
  drag.generation = drag.generation + 1
  drag.zone = nil
  if zone then
    local list, boxes = monitors()
    local others = {}
    for i, other in ipairs(list) do
      if other.name ~= monitor.name then
        table.insert(others, boxes[i])
      end
    end
    if G.shared_side(zone, monitor_box(monitor), others, { x = x, y = y }) then
      local current, generation = drag, drag.generation
      hl.timer(function()
        if drag == current and current.generation == generation then
          current.zone, current.monitor = zone, monitor.name
          show(current)
        end
      end, { type = "oneshot", timeout = SHARED_EDGE_PAUSE_MS })
    else
      drag.zone, drag.monitor = zone, monitor.name
    end
  end
  show(drag)
end

local function dropped(window)
  local current = drag
  drag = nil
  announce(nil)
  if not current or not current.snaps or not current.zone or current.address ~= window.address then
    return
  end
  -- After Hyprland's own drop handling.
  hl.timer(function()
    local target, monitor = by_address(current.address), hl.get_monitor(current.monitor)
    if target and monitor then
      M.place(target, current.zone, monitor)
    end
  end, { type = "oneshot", timeout = 1 })
end

-- Opening a window. When the windows snapped on its workspace and monitor leave
-- exactly one tile free, it opens there: beside a window on the left half, in
-- the right half. When they fill the screen, the half used most recently makes
-- room, keeping its top (or left) quarter. Only a window the floating mode
-- opened (its open rule tags it), not a dialog or an app that floats on its own.
local OPENED_TAG = "omarchy-mode-opened"

local function opened_by_mode(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == OPENED_TAG then
      return true
    end
  end
  return false
end

local function join(window, side)
  if not snappable(window) or (window.fullscreen or 0) ~= 0 then
    return
  end
  local monitor = window.monitor
  local tiles, halves = {}, {}
  for _, other in ipairs(hl.get_workspace_windows(tostring(window.workspace.id)) or {}) do
    if other.address ~= window.address and snappable(other) and other.monitor and other.monitor.name == monitor.name then
      if (other.fullscreen or 0) ~= 0 then
        return -- a maximized window has the workspace to itself
      end
      local tile = G.tile_of(G.outer_box(client_of(other), extents(other)), area(monitor), gaps())
      if tile then
        table.insert(tiles, tile)
        if G.split(tile) then
          table.insert(halves, { window = other, tile = tile })
        end
      end
    end
  end

  local tile = G.fill(tiles)
  if tile then
    M.place(window, tile, monitor)
    return
  end

  -- Nothing free: when the snapped windows fill the screen exactly, the half
  -- used most recently makes room, keeping its first quarter.
  if #halves == 0 or not G.full(tiles) then
    return
  end
  local function recency(entry)
    local id = entry.window.focus_history_id
    return (type(id) == "number" and id >= 0) and id or math.huge
  end
  -- A window that comes from one side (a scrolling column off the screen) goes
  -- to the half on that side; otherwise the half used most recently.
  table.sort(halves, function(a, b)
    if (a.tile == side) ~= (b.tile == side) then
      return a.tile == side
    end
    return recency(a) < recency(b)
  end)
  local half = halves[1]
  local keep, give = G.split(half.tile)
  if takes(half.window, keep, monitor) and takes(window, give, monitor) then
    M.place(half.window, keep, monitor)
    M.place(window, give, monitor)
  end
end

function M.opened(window)
  if opened_by_mode(window) then
    join(window)
  end
end

-- Closing a window that held a quarter of a layout filling the screen gives its
-- space back: the window in the same half grows back into the half.
function M.closed(window)
  if not snappable(window) then
    return
  end
  local monitor = window.monitor
  local remaining, holders, decorations = {}, {}, nil
  for _, other in ipairs(hl.get_workspace_windows(tostring(window.workspace.id)) or {}) do
    if other.address ~= window.address and snappable(other) and other.monitor and other.monitor.name == monitor.name then
      local around = extents(other)
      local tile = G.tile_of(G.outer_box(client_of(other), around), area(monitor), gaps())
      if tile then
        table.insert(remaining, tile)
        holders[tile] = other
        decorations = decorations or around
      end
    end
  end
  -- A closing window has lost its titlebar already, so its tile is measured
  -- with a snapped neighbour's: they share the same decorations.
  if not decorations then
    return
  end
  local closed = G.tile_of(G.outer_box(client_of(window), decorations), area(monitor), gaps())
  if not closed then
    return
  end
  local partner, half = G.merge(closed, remaining)
  if partner then
    M.place(holders[partner], half, monitor)
  end
end

-- A window the floating mode has just floated keeps the place tiling gave it,
-- instead of joining a pile in the middle: a box close to a tile snaps to it
-- (within 5% of the screen: a scrolling layout's columns are near halves), any
-- other box on screen stays as it is. `tiled` is its client box while tiled,
-- read before anything floated. Dragged away, it takes
-- `restore_w` x `restore_h`, the mode's comfortable size. False when the box is
-- off screen or too small for the window: the mode places it as before.
function M.adopt(window, tiled, restore_w, restore_h)
  local monitor = window.monitor
  if not monitor or not tiled or tiled.w < 1 or tiled.h < 1 then
    return false
  end
  local usable = area(monitor)
  local border = tonumber(hl.get_config("general.border_size")) or 0
  local outer = { x = tiled.x - border, y = tiled.y - border, w = tiled.w + 2 * border, h = tiled.h + 2 * border }
  if outer.x < usable.x - 1 or outer.y < usable.y - 1 or outer.x + outer.w > usable.x + usable.w + 1 or outer.y + outer.h > usable.y + usable.h + 1 then
    return false
  end
  local tile = G.near_tile(outer, usable, gaps(), math.floor(math.min(usable.w, usable.h) * 0.05))
  if tile then
    outer = G.tile_box(usable, tile, gaps())
  end
  -- The titlebar arrives with the floating: it takes the top of the box.
  local decorations = extents(window)
  local bar = plugin() and tonumber(hl.get_config("plugin.hyprbars.bar_height")) or 0
  if decorations.top <= decorations.left and bar > 0 then
    decorations = { left = decorations.left, top = decorations.top + bar, right = decorations.right, bottom = decorations.bottom }
  end
  local client = G.client_box(outer, decorations)
  if fits(window, client) == false then
    return false
  end
  hl.dispatch(hl.dsp.window.resize({ x = client.w, y = client.h, relative = false, window = window }))
  hl.dispatch(hl.dsp.window.move({ x = client.x, y = client.y, relative = false, window = window }))
  retag(window, restore_w, restore_h, client.w, client.h)
  return true
end

-- Windows a workspace switching to floating could not keep in place (a
-- scrolling column off the screen) join the snapped ones as a new window would,
-- one at a time, once the kept ones are in their tiles. Each entry is a window's
-- address and its client box while tiled, which says the side it comes from.
function M.join(entries)
  hl.timer(function()
    for _, entry in ipairs(entries) do
      local window = by_address(entry.address)
      if window and window.monitor then
        local side = nil
        if entry.box then
          local usable = area(window.monitor)
          side = (entry.box.x + entry.box.w / 2 < usable.x + usable.w / 2) and "left" or "right"
        end
        join(window, side)
      end
    end
  end, { type = "oneshot", timeout = 1 })
end

hl.on("window.close", function(window)
  M.closed(window)
end)

-- After Omarchy's own handling of the new window (workspace-modes.lua).
hl.on("window.open", function(window)
  local address = window.address
  hl.timer(function()
    local current = by_address(address)
    if current then
      M.opened(current)
    end
  end, { type = "oneshot", timeout = 1 })
end)

-- Once the titlebars plugin is in. Hyprland loads it after the config pass that
-- asks for it and reloads, and this module runs again on that reload.
if plugin() then
  hl.on("hyprbars.drag_start", function(window) begin(window) end)
  hl.on("hyprbars.drag_move", function(window, x, y) moved(window, x, y) end)
  hl.on("hyprbars.drag_end", function(window) dropped(window) end)
end

-- A reload in the middle of a drag must not leave an outline behind.
announce(nil)

M.geometry = G
o.snap = M

return M
