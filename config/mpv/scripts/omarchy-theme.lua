-- Reload Omarchy's generated palette without restarting playback.
-- The custom controller observes user-data; built-in menus observe script-opts.
local msg = require 'mp.msg'
local utils = require 'mp.utils'
local input = require 'mp.input'
local options = {theme_file = '~/.local/state/omarchy/current/theme/mpv-theme.conf'}
require('mp.options').read_options(options, 'omarchy-theme')
local path = mp.command_native({'expand-path', options.theme_file})
local last_contents, last_warning
local selected_theme, selection_generation = 'automatic', 0
local omarchy_path = os.getenv('OMARCHY_PATH') or '/usr/share/omarchy'
local user_themes = mp.command_native({'expand-path', '~/.config/omarchy/themes'})
mp.set_property_native('user-data/omarchy/theme-selection', selected_theme)
local palette_keys = {background=true, foreground=true, accent=true, panel=true,
  button=true, hover=true, border=true, muted=true, error=true}
local native_colors = {
  ['osd-color'] = true,
  ['osd-back-color'] = true,
  ['osd-outline-color'] = true,
  ['osd-selected-color'] = true,
  ['osd-selected-outline-color'] = true,
}

local script_color_keys = {
  ['console-menu_outline_color'] = true,
  ['console-focused_color'] = true,
  ['console-focused_back_color'] = true,
  ['console-match_color'] = true,
  ['context_menu-menu_outline_color'] = true,
  ['context_menu-focused_color'] = true,
  ['context_menu-focused_back_color'] = true,
  ['context_menu-disabled_color'] = true,
  ['stats-font_color'] = true,
  ['stats-border_color'] = true,
  ['stats-shadow_color'] = true,
  ['stats-plot_color'] = true,
  ['stats-plot_bg_color'] = true,
  ['stats-plot_bg_border_color'] = true,
}

local function warn_once(message)
  if message ~= last_warning then msg.warn(message) end
  last_warning = message
end

local function apply_palette(contents, source)
  local script_colors, osd_colors, palette = {}, {}, {}
  for line in contents:gmatch('[^\r\n]+') do
    if not line:match('^%s*#') and not line:match('^%s*$') then
      local key, value = line:match('^%s*([%w_%-]+)%s*=%s*(%S+)%s*$')
      local script = key and key:match('^([%w_]+)%-[%w_]+$')
      if key == 'mode' and (value == 'light' or value == 'dark') then
        palette.mode=value
      elseif not value or not value:match('^#%x%x%x%x%x%x$') then
        warn_once('Ignoring incomplete or invalid Omarchy palette: ' .. source)
        return
      elseif palette_keys[key] then
        palette[key] = value
      elseif native_colors[key] then
        osd_colors[key] = value
      elseif script_color_keys[key] then
        script_colors[key] = script == 'stats' and
          (value:sub(6,7)..value:sub(4,5)..value:sub(2,3)) or value
      else
        warn_once('Ignoring incomplete or invalid Omarchy palette: ' .. source)
        return
      end
    end
  end
  for key in pairs(palette_keys) do
    if not palette[key] then
      warn_once('Ignoring incomplete Omarchy palette: ' .. source)
      return
    end
  end
  for key in pairs(native_colors) do
    if not osd_colors[key] then
      warn_once('Ignoring incomplete Omarchy palette: ' .. source)
      return
    end
  end

  for key in pairs(script_color_keys) do
    if not script_colors[key] then
      warn_once('Ignoring incomplete Omarchy palette: ' .. source)
      return
    end
  end

  -- Preserve layout settings and options belonging to other scripts.
  local script_opts = mp.get_property_native('script-opts', {})
  for key, value in pairs(script_colors) do script_opts[key] = value end
  mp.set_property_native('script-opts', script_opts)
  mp.set_property_native('user-data/omarchy/theme', palette)
  for key, value in pairs(osd_colors) do mp.set_property(key, value) end
  last_contents, last_warning = contents, nil
  msg.verbose('Applied Omarchy palette from ' .. source)
  return true
end

local function read_file(filename)
  local file = io.open(filename, 'r')
  if not file then return end
  local contents = file:read('*a')
  file:close()
  return contents
end

local function reload_theme()
  if selected_theme ~= 'automatic' then return end
  -- Keep the previous palette during Omarchy's atomic theme-directory swap.
  local contents = read_file(path)
  if contents and contents ~= last_contents then apply_palette(contents, path) end
end

-- Match the shell's Style.cornerRadius source, including user overrides.
-- Keep geometry separate from color selection: a player-only palette never
-- changes the desktop's window/control shape.
local rounding_request, rounding_timeout
local function reload_rounding()
  if rounding_request then return end
  rounding_request = mp.command_native_async({name='subprocess',
    args={'hyprctl', '-j', 'getoption', 'decoration:rounding'},
    capture_stdout=true, capture_stderr=true, playback_only=false}, function(success, result)
    rounding_request = nil
    if rounding_timeout then rounding_timeout:kill() end
    if not success or not result or result.status ~= 0 then return end
    local data = utils.parse_json(result.stdout)
    local radius = type(data) == 'table' and data.int
    if type(radius) ~= 'number' or radius < 0 or radius == math.huge then return end
    if mp.get_property_native('user-data/omarchy/corner-radius') ~= radius then
      mp.set_property_native('user-data/omarchy/corner-radius', radius)
    end
  end)
  rounding_timeout = mp.add_timeout(1.5, function()
    if rounding_request then mp.abort_async_command(rounding_request) end
  end)
end
reload_rounding()
mp.add_periodic_timer(2, reload_rounding)
mp.register_script_message('reload-omarchy-rounding', reload_rounding)
mp.register_event('shutdown', function()
  if rounding_request then mp.abort_async_command(rounding_request) end
end)

local function theme_file(slug, name)
  for _, directory in ipairs({user_themes, omarchy_path and omarchy_path..'/themes' or ''}) do
    if directory ~= '' then
      local filename = directory..'/'..slug..'/'..name
      if utils.file_info(filename) then return filename end
    end
  end
end

local function mix(start, finish, fraction)
  local rgb = {}
  for i = 2, 6, 2 do
    rgb[#rgb+1] = math.floor(tonumber(start:sub(i,i+1),16)*(1-fraction) +
      tonumber(finish:sub(i,i+1),16)*fraction + .5)
  end
  return string.format('#%02x%02x%02x', rgb[1], rgb[2], rgb[3])
end

local function render_palette(template, colors)
  -- The mpv template is color data. Support its named colors and mix tokens;
  -- unknown expressions stay unresolved and are rejected by apply_palette.
  return template:gsub('{{%s*(.-)%s*}}', function(expression)
    if colors[expression] then return colors[expression] end
    local start, finish, amount = expression:match('^mix%s+(%w+)%s+(%w+)%s+([%d.]+%%?)$')
    if not start or not colors[start] or not colors[finish] or
      not colors[start]:match('^#%x%x%x%x%x%x$') or
      not colors[finish]:match('^#%x%x%x%x%x%x$') then return end
    local fraction = tonumber((amount:gsub('%%','')))
    if not fraction then return end
    if amount:find('%%') or fraction > 1 then fraction = fraction/100 end
    return mix(colors[start], colors[finish], math.max(0,math.min(1,fraction)))
  end)
end

local function select_theme(slug)
  if not slug or not slug:match('^[%w][%w_%-]*$') then return end
  selection_generation = selection_generation + 1
  local generation = selection_generation
  if slug == 'automatic' then
    selected_theme, last_contents = slug, nil
    mp.set_property_native('user-data/omarchy/theme-selection', slug)
    reload_theme()
    return
  end
  local function apply(contents, source)
    if generation ~= selection_generation then return end
    if contents and apply_palette(contents, source) then
      selected_theme = slug
      mp.set_property_native('user-data/omarchy/theme-selection', slug)
    else
      mp.osd_message('Could not load theme: '..slug, 2)
    end
  end
  local generated = theme_file(slug, 'mpv-theme.conf')
  if generated then apply(read_file(generated), generated); return end
  local colors_file = theme_file(slug, 'colors.toml')
  local template_file = mp.command_native({'expand-path', '~/.config/omarchy/themed/mpv-theme.conf.tpl'})
  local template = read_file(template_file)
  if not template and omarchy_path then
    template = read_file(omarchy_path..'/default/themed/mpv-theme.conf.tpl')
  end
  if not colors_file or not template then
    mp.osd_message('No mpv palette available for theme: '..slug, 2)
    return
  end
  -- Resolve Omarchy aliases and light/dark mode through its native helper.
  -- An argument array never evaluates theme names as shell commands.
  mp.command_native_async({name='subprocess', args={'omarchy-theme-color', '--file', colors_file, '--all'},
    capture_stdout=true, capture_stderr=true, playback_only=false}, function(success, result)
    if generation ~= selection_generation then return end
    if not success or not result or result.status ~= 0 then apply(nil, colors_file); return end
    local colors = {}
    for key, value in result.stdout:gmatch('([^\t\r\n]+)\t([^\r\n]+)') do colors[key] = value end
    apply(render_palette(template, colors), colors_file)
  end)
end

local function theme_menu()
  local slugs, seen = {}, {}
  for _, directory in ipairs({user_themes, omarchy_path and omarchy_path..'/themes' or ''}) do
    for _, slug in ipairs(utils.readdir(directory, 'dirs') or {}) do
      if slug:match('^[%w][%w_%-]*$') and not seen[slug] and
        (theme_file(slug, 'colors.toml') or theme_file(slug, 'mpv-theme.conf')) then
        seen[slug] = true
        slugs[#slugs+1] = slug
      end
    end
  end
  table.sort(slugs)
  table.insert(slugs, 1, 'automatic')
  local items, selected = {}, 1
  for i, slug in ipairs(slugs) do
    local label = slug == 'automatic' and 'Automatic · follow desktop' or
      slug:gsub('%-',' '):gsub('(%f[%w]%l)', string.upper)
    items[i] = label..(slug == selected_theme and ' (current)' or '')
    if slug == selected_theme then selected = i end
  end
  input.select({prompt='Player theme:', items=items, default_item=selected,
    submit=function(index) select_theme(slugs[index]) end})
end

mp.register_script_message('set-omarchy-theme', select_theme)
mp.register_script_message('select-omarchy-theme', theme_menu)

reload_theme()
-- mpv has no portable file-watcher API. Read this small local file once per
-- second, even while paused, and update properties only when it changes.
mp.add_periodic_timer(1, reload_theme)
mp.register_event('file-loaded', reload_theme)
mp.register_script_message('reload-omarchy-theme', reload_theme)
