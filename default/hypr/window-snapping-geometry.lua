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
