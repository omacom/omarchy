local move = dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/scrolling-window-move.lua")
local active, windows, monitor, dispatched
local monitors = { {}, {} }
local fallback = true
hl = {
  get_active_window = function() return active end,
  get_monitors = function() return monitors end,
  get_config = function() return fallback end,
  get_windows = function(filter)
    local result = {}
    for _, w in ipairs(windows) do
      if tostring(w.workspace.id) == filter.workspace and not w.floating and w.mapped then
        table.insert(result, w)
      end
    end
    return result
  end,
  get_monitor = function() return monitor end,
  dispatch = function(action) table.insert(dispatched, action) end,
  dsp = { window = {
    swap = function(args) return { kind = "swap", args = args } end,
    move = function(args) return { kind = "move", args = args } end,
  } },
}
local function window(x, id, opts)
  local w = { address = tostring(x) .. ":" .. tostring(id), at = { x = x, y = 0 }, size = { x = 100, y = 100 }, layout = { column = { index = math.floor(x / 100) } }, workspace = { id = id or 1, tiled_layout = "scrolling" }, mapped = true }
  for k, v in pairs(opts or {}) do w[k] = v end
  return w
end
local function check(direction, expected)
  dispatched = {}
  move(direction)
  assert(#dispatched == (expected and 1 or 0))
  if expected then
    assert(dispatched[1].kind == expected)
    if expected == "swap" then assert(dispatched[1].args.direction == direction) end
    if expected == "move" then
      assert(dispatched[1].args.monitor == monitor.name)
      assert(dispatched[1].args.follow == true)
    end
  end
end
active = window(100, 1)
windows = { active, window(200, 1) }
monitor = { name = "DP-2" }
check("r", "swap") -- Includes a column beyond the visible viewport.
monitors = { {} }
check("l", "swap") -- A single monitor keeps the original dispatcher, including wrap behavior.
monitors = { {}, {} }
check("l", "move") -- Empty destination monitor requires no target window.
windows = { active, window(0, 1) }
check("l", "swap")
check("r", "move")
windows = { active, window(200, 2), window(200, 1, { floating = true }), window(200, 1, { hidden = true }), window(200, 1, { mapped = false }) }
check("r", "move")
local stacked = window(120, 1)
stacked.layout.column.index = active.layout.column.index
windows = { active, stacked }
check("r", "move") -- Unequal widths inside a column are not another column.
active.layout = nil
check("r", "swap") -- Missing layout metadata keeps native behavior.
active.layout = { column = { index = 1 } }
windows = { active }
fallback = false
check("r", nil)
fallback = 0
check("r", nil)
fallback = true
monitors = { {}, { is_mirror = true } }
check("r", "swap") -- A mirrored display does not make this a multiple monitor layout.
monitors = { {}, {} }
active.group = {}
check("r", "swap")
active.group = nil
active.fullscreen = 1
check("r", "swap")
active.fullscreen = 0
active.workspace.has_fullscreen = true
check("r", "swap")
active.workspace.has_fullscreen = false
check("r", "move") -- Other workspaces and non-tiled/hidden windows cannot block an edge.
monitor = nil
check("r", nil)
check("r", nil) -- Repeated outward presses do not dispatch invalid monitor moves.
active.workspace.tiled_layout = "dwindle"
monitor = { name = "DP-2" }
windows = { active, window(200, 1) }
check("r", "swap")
check("l", "move")
local above = window(100, 1)
above.address = "above"
above.at.y = -100
windows = { active, above }
check("u", "swap")
check("d", "move")
local diagonal = window(300, 1)
diagonal.at.y = -200
windows = { active, diagonal }
check("u", "move") -- A tile that does not overlap horizontally is not an above neighbor.
check("r", "move") -- A tile that does not overlap vertically is not a right neighbor.
monitors = { {} }
check("r", "swap")
monitors = { {}, {} }
monitor = nil
check("l", nil)
active.workspace.tiled_layout = "floating"
check("r", "swap")
active.workspace.tiled_layout = "scrolling"
check("u", "swap") -- Scrolling vertical bindings keep their original behavior.
active.workspace.special = true
check("r", "swap")
active.workspace.special = false
active.floating = true
check("r", "swap")
active = nil
check("r", nil)
print("scrolling window movement regression cases passed")
