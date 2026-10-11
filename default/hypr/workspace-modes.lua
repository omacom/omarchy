-- Workspace modes for omarchy-hyprland-workspace-layout-toggle.
--
-- Hyprland has dwindle and scrolling as tiled layouts, but nothing that floats a
-- whole workspace: it reports a workspace's `tiledLayout` and takes an unknown
-- layout name in silence, falling back to dwindle. So floating is applied to the
-- windows themselves.
--
-- Ending the mode has to tile the windows the mode floated and only those, so
-- each one is tagged. The tag lives on the window: it dies with it, follows it
-- between workspaces, and survives the config reload that a monitor being
-- plugged in performs, none of which a table on this side would do.
--
-- Every window on a floating workspace also carries a second tag, whether the
-- mode floated it or it was floating already. Titlebars, edge snapping, shadows,
-- and full opacity follow that tag, so a dialog on a floating workspace can be
-- dragged by its titlebar too, and a window carried out to a tiled one loses it.

require("default.hypr.helpers")
local paths = require("default.hypr.paths")

local FLOATED_TAG = "omarchy-mode-floated"
local WORKSPACE_TAG = "omarchy-floating-workspace"
local RESTORING_TAG = "omarchy-shelf-restoring"
local TITLEBARS = "/usr/lib/omarchy-hyprland-titlebars/titlebars.so"

local M = {}

local modes = {}
local default_mode = nil
local watching = false
local cascade = 0

local function set_floating(window, floating)
  hl.dispatch(hl.dsp.window.float({ action = floating and "on" or "off", window = window }))
end

local function set_claimed(window, claimed)
  hl.dispatch(hl.dsp.window.tag({ tag = (claimed and "+" or "-") .. FLOATED_TAG, window = window }))
end

local function set_on_floating_workspace(window, on)
  hl.dispatch(hl.dsp.window.tag({ tag = (on and "+" or "-") .. WORKSPACE_TAG, window = window }))
end

local function claimed()
  local addresses = {}

  for _, window in ipairs(hl.get_windows({ tag = FLOATED_TAG })) do
    addresses[window.address] = true
  end

  return addresses
end

local function tagged(window, tag)
  for _, held in ipairs(window.tags or {}) do
    -- hyprctl marks a tag added at runtime with a trailing "*".
    if held == tag or held == tag .. "*" then
      return true
    end
  end

  return false
end

-- Special workspaces -- the Shelf, the scratchpad -- and named ones, which report
-- a negative id, keep whatever state a window arrived with. Restoring from the
-- Shelf puts a window back itself, and the mode must not undo that halfway.
local function floating_workspace(id)
  id = tonumber(id)

  if not id or id < 1 then
    return false
  end

  local mode = modes[tostring(id)]
  if mode then
    return mode == "floating"
  end

  return default_mode == "floating"
end

local function anything_floats()
  if default_mode == "floating" then
    return true
  end

  for _, mode in pairs(modes) do
    if mode == "floating" then
      return true
    end
  end

  return false
end

-- A window the mode floats opens at a comfortable size in the middle of its
-- monitor, each one stepped from the last so a workspace floated all at once does
-- not leave every window stacked exactly on the one beneath it.
local function place(window)
  local monitor = window.monitor
  if not monitor or not monitor.width then
    return
  end

  local width = math.floor(monitor.width / monitor.scale)
  local height = math.floor(monitor.height / monitor.scale)

  if (monitor.transform or 0) % 2 == 1 then
    width, height = height, width
  end

  local reserved = monitor.reserved or {}
  width = width - (reserved.left or 0) - (reserved.right or 0)
  height = height - (reserved.top or 0) - (reserved.bottom or 0)

  hl.dispatch(hl.dsp.window.resize({
    x = math.min(1100, math.floor(width * 0.64)),
    y = math.min(760, math.floor(height * 0.68)),
    relative = false,
    window = window,
  }))
  hl.dispatch(hl.dsp.window.center({ window = window }))

  cascade = (cascade + 1) % 5
  hl.dispatch(hl.dsp.window.move({ x = cascade * 24 - 48, y = cascade * 24 - 48, relative = true, window = window }))
end

-- A window already floating on its own account -- an app with a float rule of
-- its own, a dialog, one popped out with SUPER + T -- is left unclaimed, so it
-- is still floating when the mode ends. A fullscreen window is left as it is.
--
-- Every tiled window is claimed before any of them is floated: floating one
-- member of a group floats the rest, and a single pass would then find those
-- already floating and leave them to be stranded when the mode ends.
local function float_for_mode(windows)
  local claiming = {}

  for _, window in ipairs(windows) do
    set_on_floating_workspace(window, true)

    if not window.floating and (window.fullscreen or 0) == 0 then
      set_claimed(window, true)
      table.insert(claiming, window)
    end
  end

  for _, window in ipairs(claiming) do
    set_floating(window, true)
    place(window)
  end
end

-- A pinned window is one the user asked to keep above everything, and tiling it
-- would unpin it as well, so the mode leaves it be.
local function tile_for_mode(window, mine)
  set_on_floating_workspace(window, false)

  if not mine[window.address] or window.pinned then
    return
  end

  set_claimed(window, false)
  set_floating(window, false)
end

-- The workspace is passed in when a window is still on its way to it.
local function arrange(windows, workspace)
  local floating = {}
  local mine = claimed()

  for _, window in ipairs(windows) do
    local id = tonumber(workspace and workspace.id or (window.workspace and window.workspace.id))

    if id and id >= 1 and not tagged(window, RESTORING_TAG) then
      if floating_workspace(id) then
        table.insert(floating, window)
      else
        tile_for_mode(window, mine)
      end
    end
  end

  float_for_mode(floating)
end

-- Overlapping windows are placed with the pointer, so a floating workspace
-- focuses on click rather than on hover, and its windows resize from their
-- edges. The grab zone around an edge is kept narrow, or the window in front
-- takes the click meant for the titlebar of the one cascaded behind it. Every
-- other workspace keeps the user's own settings.
local input = {}

local function update_input()
  local workspace = hl.get_active_workspace()
  local active = workspace ~= nil and floating_workspace(workspace.id)

  if active == input.floating then
    return
  end

  input.floating = active

  hl.config({
    input = { follow_mouse = active and 0 or input.follow_mouse },
    general = {
      resize_on_border = active or input.resize_on_border,
      extend_border_grab_area = active and 8 or input.extend_border_grab_area,
      hover_icon_on_border = active or input.hover_icon_on_border,
    },
  })
end

-- Windows arrive by opening and by being carried in, and a window rule only ever
-- fires for the first. One carried back out gives up the floating the mode gave
-- it rather than staying floating somewhere that tiles.
local function watch()
  if watching then
    return
  end

  watching = true

  input.follow_mouse = hl.get_config("input.follow_mouse")
  input.resize_on_border = hl.get_config("general.resize_on_border")
  input.extend_border_grab_area = hl.get_config("general.extend_border_grab_area")
  input.hover_icon_on_border = hl.get_config("general.hover_icon_on_border")

  hl.on("window.open", function(window)
    arrange({ window })
  end)

  -- A move is still being committed when this fires, and changing the window's
  -- floating state underneath it loses the move. Let it land first. Restoring
  -- from the Shelf tags the window before moving it, so that is checked now.
  hl.on("window.move_to_workspace", function(window, workspace)
    if tagged(window, RESTORING_TAG) then
      return
    end

    hl.timer(function()
      arrange({ window }, workspace)
    end, { type = "oneshot", timeout = 1 })
  end)

  -- A fullscreen window is left as it is, so it is arranged once it comes back
  -- out: a tiled one leaving fullscreen on a floating workspace floats then.
  hl.on("window.fullscreen", function(window)
    if tagged(window, RESTORING_TAG) then
      return
    end

    hl.timer(function()
      arrange({ window })
    end, { type = "oneshot", timeout = 1 })
  end)

  hl.on("workspace.active", update_input)
  hl.on("monitor.focused", update_input)
end

function o.workspace_mode(spec)
  watch()

  -- The default for every workspace that has no mode of its own, set by Float
  -- All Workspaces. It is applied once the saved modes have all loaded.
  if spec.default then
    default_mode = spec.default
    return
  end

  local workspace = tostring(spec.workspace)

  -- Floating keeps whatever tiled layout the workspace had, so nothing has to be
  -- chosen for it on the way back out.
  if spec.mode ~= "floating" then
    hl.workspace_rule({ workspace = workspace, layout = spec.mode })
  end

  modes[workspace] = spec.mode

  arrange(hl.get_workspace_windows(workspace))
  update_input()
end

local function theme_colors()
  local colors = {}
  -- omarchy-theme-set writes the current theme under ~/.local/state whatever
  -- XDG_STATE_HOME says, and Hyprland loads the theme's own config from there.
  local file = io.open(paths.home .. "/.local/state/omarchy/current/theme/colors.toml", "r")

  if file then
    for line in file:lines() do
      local key, value = line:match('^%s*([%w_]+)%s*=%s*"#(%x%x%x%x%x%x)"')
      if key then
        colors[key] = "rgb(" .. value .. ")"
      end
    end

    file:close()
  end

  local background = colors.background or "rgb(1a1b26)"
  -- A titlebar in the window's own background color runs into the window, so it
  -- takes the theme's raised surface. Themes that make that the background too
  -- fall back to their selection color.
  local titlebar = colors.lighter_background
  if not titlebar or titlebar == background then
    titlebar = colors.selection or background
  end

  return {
    background = background,
    foreground = colors.foreground or "rgb(c0caf5)",
    titlebar = titlebar,
  }
end

-- Titlebars come from omarchy-hyprland-titlebars. Hyprland loads a plugin only
-- while the config asks for it, and unloads it at the first reload that does
-- not, so asking only while something floats keeps it out of tiling sessions.
-- The plugin reloads the config once it is in, which is the pass that finds its
-- options here.
local function titlebars()
  local file = io.open(TITLEBARS, "r")
  if not file then
    return
  end
  file:close()

  hl.plugin.load(TITLEBARS)

  if not hl.plugin.hyprbars then
    return
  end

  local colors = theme_colors()
  local window = [[window = "address:%WINDOW%"]]

  hl.config({
    plugin = {
      hyprbars = {
        enabled = true,
        workspace_tag = WORKSPACE_TAG,
        bar_height = 30,
        bar_color = colors.titlebar,
        col = { text = colors.foreground },
        bar_text_font = "monospace",
        bar_text_size = 12,
        bar_text_weight = "normal",
        bar_text_align = "left",
        bar_buttons_alignment = "right",
        bar_part_of_window = true,
        bar_precedence_over_border = true,
        bar_padding = 10,
        bar_button_padding = 8,
        button_rounding = 0,
        icon_on_hover = false,
        inactive_button_color = colors.titlebar,
        on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " .. window .. " })'",
        edge_snap = true,
        edge_threshold = 24,
        snap_gap = 10,
      },
    },
  })

  for _, button in ipairs({
    { icon = "×", action = "hyprctl dispatch 'hl.dsp.window.close({ " .. window .. " })'" },
    { icon = "□", action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " .. window .. " })'" },
    { icon = "−", action = "omarchy-hyprland-window-minimize %WINDOW%" },
  }) do
    hl.plugin.hyprbars.add_button({
      bg_color = colors.titlebar,
      fg_color = colors.foreground,
      size = 20,
      icon = button.icon,
      action = button.action,
    })
  end
end

-- Runs once every saved mode has loaded. A reload is a fresh start on this side
-- but not for the windows, so each one is brought in line with the modes as they
-- now stand: turning Float All Workspaces off has to give back what it floated,
-- even though nothing names those workspaces any more.
function M.apply()
  -- Turning Float All Workspaces off can leave no saved mode at all to start
  -- the watchers, while the windows it floated still carry its tags.
  local leftovers = #hl.get_windows({ tag = FLOATED_TAG }) > 0 or #hl.get_windows({ tag = WORKSPACE_TAG }) > 0

  if anything_floats() or leftovers then
    watch()
  end

  if watching then
    arrange(hl.get_windows())
    update_input()
  end

  if not anything_floats() then
    return
  end

  -- Overlapping windows need depth to tell apart, and a translucent window over
  -- another is hard to read.
  if not hl.get_config("decoration.shadow.enabled") then
    hl.config({ decoration = { shadow = { enabled = true, range = 16, render_power = 3, color = "rgba(00000035)" } } })
    o.window(".*", { no_shadow = true })
    o.window({ tag = WORKSPACE_TAG }, { no_shadow = false })
  end

  o.window({ tag = WORKSPACE_TAG }, { opacity = "1.0 override 1.0 override" })

  titlebars()
end

return M
