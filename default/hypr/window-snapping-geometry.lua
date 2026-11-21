-- The geometry of window snapping on floating workspaces (window-snapping.lua):
-- pure functions, no Hyprland calls, so every rule can be checked on its own
-- (test/shell.d/hyprland-floating-workspaces-test.sh). Coordinates are logical
-- pixels.
--
-- A tile is one of: "left", "right", "top", "bottom", "top-left", "top-right",
-- "bottom-left", "bottom-right", or "max". Internally it is a horizontal part
-- (left/right/none) and a vertical part (top/bottom/none).

local G = {}

-- KWin's quick-tile zones, measured against the usable area (below the bar).
G.SIDE = 20      -- px from a side edge: a half
G.TOP = 5        -- px from the top edge: maximize
G.CORNER = 0.25  -- of the height, at the top or bottom of a side edge: a quarter

local function round(v)
  return math.floor(v + 0.5)
end

local function parts(tile)
  if not tile or tile == "max" then
    return nil, nil
  end
  local h = tile:match("left") or tile:match("right")
  local v = tile:match("top") or tile:match("bottom")
  return h, v
end

local function join(h, v)
  if h and v then
    return v .. "-" .. h
  end
  return h or v
end

G.parts, G.join = parts, join

G.TILES = { "left", "right", "top", "bottom", "top-left", "top-right", "bottom-left", "bottom-right", "max" }

-- The part of a monitor windows may use: its logical size (scale and rotation
-- applied) minus what the bar and other panels reserve.
-- monitor: { x, y, width, height, scale, transform, reserved = { left, top, right, bottom } }
function G.usable(monitor)
  local w, h = monitor.width / monitor.scale, monitor.height / monitor.scale
  if (monitor.transform or 0) % 2 == 1 then
    w, h = h, w
  end
  local r = monitor.reserved or {}
  local left, top, right, bottom = r.left or 0, r.top or 0, r.right or 0, r.bottom or 0
  return { x = monitor.x + left, y = monitor.y + top, w = w - left - right, h = h - top - bottom }
end

-- The box a tile fills, outer edges included (border, titlebar), with gaps like
-- tiled windows: `outer` from the usable area's edges, twice `inner` between
-- two tiles. Edges are rounded, not sizes, so neighbours meet exactly.
-- gaps: { outer = { left, top, right, bottom }, inner = number }
function G.tile_box(area, tile, gaps)
  local go, gi = gaps.outer, gaps.inner
  local x0, x3 = area.x + go.left, area.x + area.w - go.right
  local y0, y3 = area.y + go.top, area.y + area.h - go.bottom
  local h, v = parts(tile)
  local xm, ym = (x0 + x3) / 2, (y0 + y3) / 2
  local left, right, top, bottom = x0, x3, y0, y3
  if h == "left" then right = xm - gi elseif h == "right" then left = xm + gi end
  if v == "top" then bottom = ym - gi elseif v == "bottom" then top = ym + gi end
  left, right, top, bottom = round(left), round(right), round(top), round(bottom)
  return { x = left, y = top, w = right - left, h = bottom - top }
end

-- Client area inside an outer box, and back. extents: what decorations and the
-- border add on each side ({ left, top, right, bottom }).
function G.client_box(box, e)
  return { x = box.x + e.left, y = box.y + e.top, w = box.w - e.left - e.right, h = box.h - e.top - e.bottom }
end

function G.outer_box(client, e)
  return { x = client.x - e.left, y = client.y - e.top, w = client.w + e.left + e.right, h = client.h + e.top + e.bottom }
end

-- Which tile an outer box fills, if any (within a pixel).
function G.tile_of(box, area, gaps)
  for _, tile in ipairs(G.TILES) do
    if tile ~= "max" then
      local t = G.tile_box(area, tile, gaps)
      if math.abs(t.x - box.x) <= 1 and math.abs(t.y - box.y) <= 1 and math.abs(t.w - box.w) <= 1 and math.abs(t.h - box.h) <= 1 then
        return tile
      end
    end
  end
  return nil
end

-- The quarters of the screen each tile covers.
local CELLS = {
  left = { "top-left", "bottom-left" }, right = { "top-right", "bottom-right" },
  top = { "top-left", "top-right" }, bottom = { "bottom-left", "bottom-right" },
  ["top-left"] = { "top-left" }, ["top-right"] = { "top-right" },
  ["bottom-left"] = { "bottom-left" }, ["bottom-right"] = { "bottom-right" },
}
local QUARTERS = { "top-left", "top-right", "bottom-left", "bottom-right" }

-- The one tile the snapped tiles leave free, for a new window to open into:
-- the right half beside a left half, the last quarter beside three. Nil when
-- the free space is no single tile (two diagonal quarters, nothing free), or
-- when the snapped windows overlap and there is no layout to complete.
function G.fill(tiles)
  local used, any = {}, false
  for _, tile in ipairs(tiles) do
    local cells = CELLS[tile]
    if not cells then
      return nil
    end
    for _, cell in ipairs(cells) do
      if used[cell] then
        return nil
      end
      used[cell], any = true, true
    end
  end
  if not any then
    return nil
  end
  local free = {}
  for _, cell in ipairs(QUARTERS) do
    if not used[cell] then
      free[cell] = true
    end
  end
  for _, tile in ipairs(G.TILES) do
    local cells = CELLS[tile]
    if cells then
      local count = 0
      for _ in pairs(free) do count = count + 1 end
      local matches = #cells == count
      for _, cell in ipairs(cells) do
        matches = matches and free[cell] == true
      end
      if matches then
        return tile
      end
    end
  end
  return nil
end

-- Whether tiles fill the whole screen, each quarter exactly once.
function G.full(tiles)
  local used = {}
  for _, tile in ipairs(tiles) do
    for _, cell in ipairs(CELLS[tile] or {}) do
      if used[cell] then
        return false
      end
      used[cell] = true
    end
  end
  for _, cell in ipairs(QUARTERS) do
    if not used[cell] then
      return false
    end
  end
  return true
end

-- How a half makes room for one more window: the window there keeps the first
-- quarter, the new one takes the second. Nil for anything but a half.
local SPLITS = {
  left = { "top-left", "bottom-left" }, right = { "top-right", "bottom-right" },
  top = { "top-left", "top-right" }, bottom = { "bottom-left", "bottom-right" },
}

function G.split(tile)
  local split = SPLITS[tile]
  if split then
    return split[1], split[2]
  end
end

-- What a quarter leaves when its window closes, in a layout that filled the
-- screen: the quarter sharing its half, same column first (the way halves
-- split), grows back into that half, as long as the half then holds only it.
-- Returns the quarter that grows and the half it grows into, or nil.
local PARTNERS = {
  ["top-left"] = { { "bottom-left", "left" }, { "top-right", "top" } },
  ["bottom-left"] = { { "top-left", "left" }, { "bottom-right", "bottom" } },
  ["top-right"] = { { "bottom-right", "right" }, { "top-left", "top" } },
  ["bottom-right"] = { { "top-right", "right" }, { "bottom-left", "bottom" } },
}

function G.merge(closed, remaining)
  -- Only a layout that filled the screen exactly, never one with stacked windows.
  local before = { closed }
  for _, tile in ipairs(remaining) do table.insert(before, tile) end
  if not G.full(before) then
    return nil
  end
  for _, option in ipairs(PARTNERS[closed] or {}) do
    local partner, half = option[1], option[2]
    local holders, crowded = 0, false
    for _, tile in ipairs(remaining) do
      if tile == partner then
        holders = holders + 1
      else
        for _, cell in ipairs(CELLS[tile] or {}) do
          for _, mine in ipairs(CELLS[half]) do
            if cell == mine then
              crowded = true
            end
          end
        end
      end
    end
    if holders == 1 and not crowded then
      return partner, half
    end
  end
  return nil
end

local OPPOSITE = { left = "right", right = "left", top = "bottom", bottom = "top" }
local AXIS = { left = "h", right = "h", top = "v", bottom = "v" }

-- Super + arrows, KWin's quick tiling with one difference. Pressing a direction:
--   towards an edge the window is against already -> maximize (top half + up,
--                            left half + left, a quarter towards either of its edges)
--   the opposite side     -> with the other part set, drop this part (top-left + right = top);
--                            otherwise switch sides (left + right = right)
--   this part not set     -> set it (left + up = top-left; none + left = left; max + left = left)
-- KWin moves a window to the next monitor instead of maximizing; Omarchy has
-- Super + Shift + Ctrl + arrows for that.
function G.press(tile, dir)
  local h, v = parts(tile)
  local axis = AXIS[dir]
  local mine, other
  if axis == "h" then mine, other = h, v else mine, other = v, h end

  local new_mine
  if mine == dir then
    return "max"
  elseif mine == OPPOSITE[dir] then
    -- (not `other and nil or dir`: `x and nil` is always nil in Lua)
    if other then
      new_mine = nil
    else
      new_mine = dir
    end
  else
    new_mine = dir
  end

  if axis == "h" then
    return join(new_mine, v)
  end
  return join(h, new_mine)
end

-- The drag zone under the pointer: a tile, "max", or nil.
function G.zone(cursor, area)
  local h
  if cursor.x <= area.x + G.SIDE then
    h = "left"
  elseif cursor.x >= area.x + area.w - G.SIDE then
    h = "right"
  end
  if h then
    if cursor.y < area.y + area.h * G.CORNER then
      return "top-" .. h
    elseif cursor.y > area.y + area.h * (1 - G.CORNER) then
      return "bottom-" .. h
    end
    return h
  end
  if cursor.y <= area.y + G.TOP then
    return "max"
  end
  return nil
end

-- Whether the pointer, in a zone, is on a part of the monitor's edge that
-- touches another monitor: there a drag only snaps after a pause, so a window
-- can still be dragged across. Monitors of different sizes share only part of
-- an edge, so it is the spot just across from the pointer that counts.
-- monitor_box: this monitor's logical box; others: the other monitors' boxes.
function G.shared_side(zone, monitor_box, others, cursor)
  local h, v = parts(zone)
  local b = monitor_box
  local probes = {}
  if h == "left" then probes[#probes + 1] = { x = b.x - 1, y = cursor.y } end
  if h == "right" then probes[#probes + 1] = { x = b.x + b.w, y = cursor.y } end
  if zone == "max" or v == "top" then probes[#probes + 1] = { x = cursor.x, y = b.y - 1 } end
  if v == "bottom" then probes[#probes + 1] = { x = cursor.x, y = b.y + b.h } end
  for _, p in ipairs(probes) do
    for _, o in ipairs(others) do
      if p.x >= o.x and p.x < o.x + o.w and p.y >= o.y and p.y < o.y + o.h then
        return true
      end
    end
  end
  return false
end

-- Restore tag: the size to return to, and the size the window was snapped to.
G.TAG = "snap-restore:"

function G.tag(restore_w, restore_h, snapped_w, snapped_h)
  return string.format("%s%dx%d/%dx%d", G.TAG, round(restore_w), round(restore_h), round(snapped_w), round(snapped_h))
end

function G.parse_tag(tag)
  local w, h, sw, sh = tag:match("^snap%-restore:(%d+)x(%d+)/(%d+)x(%d+)$")
  if w then
    return { w = tonumber(w), h = tonumber(h), snapped_w = tonumber(sw), snapped_h = tonumber(sh) }
  end
end

return G
