-- Apply the look a theme describes in hyprland.toml.
--
-- A theme's hyprland.lua is code Hyprland runs, so omarchy-theme-set drops it
-- from a theme cloned from a git repo. hyprland.toml is the data-only way for
-- any theme to set how Hyprland looks: gaps, rounding, shadows, blur, window
-- opacity, blur behind the Omarchy shell, and animations. The file is parsed
-- here, never run, and every value is checked against a fixed list of options
-- with Hyprland's own ranges before Hyprland sees it. Hyprland reports a bad
-- value as a config error even from inside pcall, so a value that fails a
-- check is skipped rather than passed on.

local paths = require("default.hypr.paths")

local M = {}

-- Matches where omarchy-theme-set stages the current theme.
M.theme_file = paths.home .. "/.local/state/omarchy/current/theme/hyprland.toml"

-- A theme is a few hundred bytes of settings, so anything far larger is not one.
local MAX_FILE_SIZE = 64 * 1024

-- Hyprland options a theme may set, with the type and range Hyprland itself
-- publishes in `hyprctl descriptions`. Gaps and the shadow offset publish no
-- range, so they get a generous one. Only look-and-feel options belong here.
local OPTIONS = {
  ["general.gaps_in"] = { "int", 0, 100 },
  ["general.gaps_out"] = { "int", 0, 100 },
  ["general.border_size"] = { "int", 0, 20 },

  ["decoration.rounding"] = { "int", 0, 20 },
  ["decoration.rounding_power"] = { "float", 2, 10 },
  ["decoration.active_opacity"] = { "float", 0, 1 },
  ["decoration.inactive_opacity"] = { "float", 0, 1 },
  ["decoration.fullscreen_opacity"] = { "float", 0, 1 },
  ["decoration.dim_inactive"] = { "bool" },
  ["decoration.dim_strength"] = { "float", 0, 1 },
  ["decoration.dim_special"] = { "float", 0, 1 },
  ["decoration.dim_around"] = { "float", 0, 1 },

  ["decoration.shadow.enabled"] = { "bool" },
  ["decoration.shadow.range"] = { "int", 0, 100 },
  ["decoration.shadow.render_power"] = { "int", 1, 4 },
  ["decoration.shadow.sharp"] = { "bool" },
  ["decoration.shadow.color"] = { "color" },
  ["decoration.shadow.color_inactive"] = { "color" },
  ["decoration.shadow.offset"] = { "vec2", -100, 100 },
  ["decoration.shadow.scale"] = { "float", 0, 1 },

  ["decoration.blur.enabled"] = { "bool" },
  ["decoration.blur.size"] = { "int", 0, 100 },
  ["decoration.blur.passes"] = { "int", 0, 10 },
  ["decoration.blur.ignore_opacity"] = { "bool" },
  ["decoration.blur.new_optimizations"] = { "bool" },
  ["decoration.blur.xray"] = { "bool" },
  ["decoration.blur.noise"] = { "float", 0, 1 },
  ["decoration.blur.contrast"] = { "float", 0, 2 },
  ["decoration.blur.brightness"] = { "float", 0, 2 },
  ["decoration.blur.vibrancy"] = { "float", 0, 1 },
  ["decoration.blur.vibrancy_darkness"] = { "float", 0, 1 },
  ["decoration.blur.special"] = { "bool" },
  ["decoration.blur.popups"] = { "bool" },
  ["decoration.blur.popups_ignorealpha"] = { "float", 0, 1 },
  ["decoration.blur.input_methods"] = { "bool" },
  ["decoration.blur.input_methods_ignorealpha"] = { "float", 0, 1 },
}

-- [opacity] sets window opacity through the tags Omarchy already gives windows
-- in default/hypr/windows.lua and default/hypr/apps, so the apps that opt out
-- of default-opacity (video players, games, PiP, ...) stay opted out.
local OPACITY_TAGS = {
  { key = "opacity.windows", tags = { "default-opacity" } },
  { key = "opacity.browsers", tags = { "chromium-based-browser", "firefox-based-browser" } },
  { key = "opacity.terminals", tags = { "terminal" } },
}

-- The shell's own layer surfaces that [shell] blur frosts. Left out on purpose:
-- the wallpaper itself, the bar's drag ghosts, the keyboard panel's invisible
-- click catcher, and the lock preview, which blurs its own wallpaper.
-- test/shell.d/hyprland-theme-looknfeel-test.sh fails on a shell namespace
-- that is in neither list.
M.shell_blur_namespaces = {
  "omarchy-bar",
  "omarchy-clipboard",
  "omarchy-disk-speedtest",
  "omarchy-emojis",
  "omarchy-image-selector",
  "omarchy-keyboard-panel",
  "omarchy-menu",
  "omarchy-network-qr",
  "omarchy-network-speedtest",
  "omarchy-notifications",
  "omarchy-osd",
  "omarchy-polkit",
  "omarchy-reminders",
  "omarchy-speed-test",
}

-- Every animation leaf Hyprland knows, in its own tree order with parents before
-- children, so the result never depends on the order of lines in the file.
-- Hyprland rejects any other leaf name, and each family accepts its own styles.
local ANIMATIONS = {
  { "global" },
  { "windows", "window" },
  { "windowsIn", "window" },
  { "windowsOut", "window" },
  { "windowsMove", "window" },
  { "layers", "layer" },
  { "layersIn", "layer" },
  { "layersOut", "layer" },
  { "fade" },
  { "fadeIn" },
  { "fadeOut" },
  { "fadeSwitch" },
  { "fadeShadow" },
  { "fadeDim" },
  { "fadeLayers" },
  { "fadeLayersIn" },
  { "fadeLayersOut" },
  { "fadePopups" },
  { "fadePopupsIn" },
  { "fadePopupsOut" },
  { "fadeDpms" },
  { "border" },
  { "borderangle", "borderangle" },
  { "workspaces", "workspace" },
  { "workspacesIn", "workspace" },
  { "workspacesOut", "workspace" },
  { "specialWorkspace", "workspace" },
  { "specialWorkspaceIn", "workspace" },
  { "specialWorkspaceOut", "workspace" },
  { "zoomFactor" },
  { "monitorAdded" },
}

local SIDES = { "", " top", " bottom", " left", " right" }

local function style_set(...)
  local set = {}
  for _, style in ipairs({ ... }) do
    set[style] = true
  end
  return set
end

local STYLES = {
  window = style_set("slidevert", "popin", "gnomed"),
  layer = style_set("popin", "fade"),
  workspace = style_set("slidevert", "fade", "slidefade", "slidefadevert"),
  borderangle = style_set("once", "loop"),
}

for _, family in ipairs({ "window", "layer", "workspace" }) do
  for _, side in ipairs(SIDES) do
    STYLES[family]["slide" .. side] = true
  end
end

-- Styles that take a percentage, like "popin 80%".
local PERCENT_STYLES = {
  window = style_set("popin"),
  layer = style_set("popin"),
  workspace = style_set("slidefade", "slidefadevert"),
}

-- ---------------------------------------------------------------- parsing

local function trailing_ok(rest)
  return rest:match("^%s*$") ~= nil or rest:match("^%s*#") ~= nil
end

local function parse_number(token)
  if not (token:match("^[+-]?%d+$") or token:match("^[+-]?%d+%.%d+$") or token:match("^[+-]?%.%d+$")) then
    return nil
  end
  return tonumber(token)
end

-- The TOML this needs: strings, numbers, booleans and flat arrays of numbers.
local function parse_value(text)
  local value, rest = text:match('^"([^"\\]*)"(.*)$')
  if not value then
    value, rest = text:match("^'([^']*)'(.*)$")
  end
  if value then
    return value, rest
  end

  local inner
  inner, rest = text:match("^%[([^%]]*)%](.*)$")
  if inner then
    local list = {}
    for raw_item in (inner .. ","):gmatch("([^,]*),") do
      local item = raw_item:match("^%s*(.-)%s*$")
      if item ~= "" then
        local number = parse_number(item)
        if number == nil then
          return nil
        end
        list[#list + 1] = number
      end
    end
    return list, rest
  end

  local word
  word, rest = text:match("^([^%s#]+)(.*)$")
  if word == "true" then
    return true, rest
  elseif word == "false" then
    return false, rest
  elseif word then
    local number = parse_number(word)
    if number ~= nil then
      return number, rest
    end
  end

  return nil
end

-- Flatten hyprland.toml into dotted keys, so `[decoration.blur]` plus
-- `size = 20`, or a top-level `decoration.blur.size = 20`, becomes
-- values["decoration.blur.size"] = 20. Lines it cannot read are skipped;
-- nothing in the file is ever evaluated.
function M.parse(text)
  local values = {}
  local section = ""

  for raw_line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local line = raw_line:match("^%s*(.-)%s*$")

    if line ~= "" and line:sub(1, 1) ~= "#" then
      local header, after = line:match("^%[%s*([%w_%-%.]+)%s*%](.*)$")

      if header and trailing_ok(after) then
        section = header .. "."
      else
        local key, text_value = line:match("^([%w_%-%.]+)%s*=%s*(.-)$")
        if key then
          local value, rest = parse_value(text_value)
          if value ~= nil and trailing_ok(rest) then
            values[section .. key] = value
          end
        end
      end
    end
  end

  return values
end

-- ---------------------------------------------------------------- checks

local function in_range(number, min, max)
  return type(number) == "number" and number == number and number >= min and number <= max
end

local function byte_color(text)
  local number = tonumber(text)
  return number ~= nil and in_range(number, 0, 255)
end

local function valid_color(value)
  if type(value) ~= "string" then
    return false
  end

  if value:match("^#%x%x%x%x%x%x$")
    or value:match("^#%x%x%x%x%x%x%x%x$")
    or value:match("^0x%x%x%x%x%x%x%x%x$")
    or value:match("^rgb%(%x%x%x%x%x%x%)$")
    or value:match("^rgba%(%x%x%x%x%x%x%x%x%)$")
  then
    return true
  end

  local r, g, b = value:match("^rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$")
  if r then
    return byte_color(r) and byte_color(g) and byte_color(b)
  end

  local a
  r, g, b, a = value:match("^rgba%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*([%d%.]+)%s*%)$")
  if r then
    local alpha = parse_number(a)
    return byte_color(r) and byte_color(g) and byte_color(b) and alpha ~= nil and in_range(alpha, 0, 1)
  end

  return false
end

-- Hyprland refuses a float for an integer option, even 10.0, so integers are
-- handed over as Lua integers.
local function checked(value, spec)
  local kind, min, max = spec[1], spec[2], spec[3]

  if kind == "bool" then
    if type(value) == "boolean" then
      return value
    end
  elseif kind == "int" then
    local integer = type(value) == "number" and math.tointeger(value)
    if integer and in_range(integer, min, max) then
      return integer
    end
  elseif kind == "float" then
    if type(value) == "number" and in_range(value, min, max) then
      return value
    end
  elseif kind == "color" then
    if valid_color(value) then
      return value
    end
  elseif kind == "vec2" then
    if type(value) == "table" and #value == 2 and in_range(value[1], min, max) and in_range(value[2], min, max) then
      return { value[1], value[2] }
    end
  end

  return nil
end

local function opacity_rule(value)
  if type(value) ~= "table" or #value < 1 or #value > 3 then
    return nil
  end

  local parts = {}
  for index, number in ipairs(value) do
    if not in_range(number, 0, 1) then
      return nil
    end
    parts[index] = string.format("%g", number)
  end

  return table.concat(parts, " ")
end

local function valid_style(family, style)
  if type(style) ~= "string" or not family then
    return false
  end

  if STYLES[family][style] then
    return true
  end

  local name, percent = style:match("^(%a+) (%d+)%%$")
  return name ~= nil
    and PERCENT_STYLES[family] ~= nil
    and PERCENT_STYLES[family][name] == true
    and in_range(tonumber(percent), 0, 100)
end

local function valid_curve(points)
  return type(points) == "table"
    and #points == 4
    and in_range(points[1], 0, 1)
    and in_range(points[2], -10, 10)
    and in_range(points[3], 0, 1)
    and in_range(points[4], -10, 10)
end

-- ---------------------------------------------------------------- applying

local function set_path(tree, path, value)
  local node = tree
  local parts = {}

  for part in path:gmatch("[^%.]+") do
    parts[#parts + 1] = part
  end

  for index = 1, #parts - 1 do
    node[parts[index]] = node[parts[index]] or {}
    node = node[parts[index]]
  end

  node[parts[#parts]] = value
end

local function apply_options(values)
  local tree = {}
  local any = false

  for path, spec in pairs(OPTIONS) do
    if values[path] ~= nil then
      local value = checked(values[path], spec)
      if value ~= nil then
        set_path(tree, path, value)
        any = true
      end
    end
  end

  if any then
    hl.config(tree)
  end
end

local function apply_opacity(values)
  for _, entry in ipairs(OPACITY_TAGS) do
    local opacity = opacity_rule(values[entry.key])
    if opacity then
      for _, tag in ipairs(entry.tags) do
        o.window({ tag = tag }, { opacity = opacity })
      end
    end
  end
end

local function apply_shell_blur(values)
  if values["shell.blur"] ~= true then
    return
  end

  local ignore_alpha = checked(values["shell.blur_ignore_alpha"], { "float", 0, 1 }) or 0

  hl.layer_rule({
    name = "omarchy-theme-shell-blur",
    match = { namespace = "^(" .. table.concat(M.shell_blur_namespaces, "|") .. ")$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = ignore_alpha,
  })
end

-- Theme curves are registered under a theme_ prefix so they can never replace
-- a curve Omarchy's own animations use.
local function apply_animations(values)
  local curves = {}

  for key, points in pairs(values) do
    local name = key:match("^curves%.(%a[%w_]*)$")
    if name and valid_curve(points) then
      curves[name] = "theme_" .. name
      hl.curve(curves[name], { type = "bezier", points = { { points[1], points[2] }, { points[3], points[4] } } })
    end
  end

  for _, animation in ipairs(ANIMATIONS) do
    local leaf, family = animation[1], animation[2]
    local prefix = "animations." .. leaf .. "."
    local enabled = values[prefix .. "enabled"]

    if enabled == false then
      hl.animation({ leaf = leaf, enabled = false })
    elseif enabled == nil or enabled == true then
      local speed = values[prefix .. "speed"]
      local curve = values[prefix .. "curve"]
      local style = values[prefix .. "style"]
      local bezier = curve == "default" and "default" or curves[curve]

      if type(speed) == "number" and in_range(speed, 0.01, 100) and bezier then
        local spec = { leaf = leaf, enabled = true, speed = speed, bezier = bezier }
        if valid_style(family, style) then
          spec.style = style
        end
        hl.animation(spec)
      end
    end
  end
end

function M.apply(values)
  apply_options(values)
  apply_opacity(values)
  apply_shell_blur(values)
  apply_animations(values)
end

function M.apply_file(path)
  local file = io.open(path or M.theme_file, "r")
  if not file then
    return
  end

  local text = file:read(MAX_FILE_SIZE + 1) or ""
  file:close()

  if #text <= MAX_FILE_SIZE then
    M.apply(M.parse(text))
  end
end

-- Exposed so test/shell.d/hyprland-theme-looknfeel-test.sh can hand every
-- accepted option and style to Hyprland's own config check.
M.options = OPTIONS
M.animations = ANIMATIONS
M.styles = STYLES
M.percent_styles = PERCENT_STYLES

return M
