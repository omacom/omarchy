local active_border_color = {{ hypr_gradient hyprland_active_border accent }}
local inactive_border_color = {{ hypr_gradient hyprland_inactive_border rgba(595959aa) }}
local theme_path = (os.getenv("HOME") or "") .. "/.local/state/omarchy/current/theme/"
local screen_shader = ""
local screen_shader_path
local screen_shader_file

for _, shader_name in ipairs({ "screen-shader.frag", "screen-shader.glsl" }) do
  screen_shader_file = io.open(theme_path .. shader_name, "r")
  if screen_shader_file then
    screen_shader_path = theme_path .. shader_name
    break
  end
end

if screen_shader_file then
  local size = screen_shader_file:seek("end")
  screen_shader_file:close()
  if size and size <= 262144 then
    screen_shader = screen_shader_path
  end
end

local debug_config = {}
if screen_shader ~= "" then
  debug_config.damage_tracking = false
end

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    screen_shader = screen_shader,
  },

  debug = debug_config,

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})
