-- Original mpv controller, using Hype's compact surfaces and Omarchy palette.
local assdraw = require 'mp.assdraw'
local input = require 'mp.input'
-- Palette glyph adapted from the omarchy.org SVG supplied by Miguel.
local appearance_path=[[m 2 12 b 2 6.71457 6.51697 2.5 12 2.5 b 17.483 2.5 22 6.71457 22 12 b 22 13.8878 21.4937 15.1519 20.4345 15.8123 b 19.4491 16.4266 18.2002 16.3605 17.1496 16.2236 b 16.7813 16.1757 16.397 16.1121 16.0307 16.0515 b 15.8617 16.0235 15.6965 15.9962 15.5384 15.9713 b 15.0184 15.8895 14.5499 15.8295 14.1335 15.8234 b 13.298 15.8112 12.8925 16.0091 12.671 16.4526 b 12.539 16.7171 12.5395 17.0363 12.6858 17.4705 b 12.8149 17.8538 13.0214 18.2277 13.2435 18.63 b 13.2828 18.7012 13.3226 18.7734 13.3626 18.8465 b 13.4857 19.0721 13.6169 19.3217 13.7077 19.5624 b 13.7926 19.7875 13.8875 20.117 13.8161 20.466 b 13.7303 20.8858 13.4434 21.1713 13.0891 21.3241 b 12.7768 21.4588 12.3992 21.5 12 21.5 b 6.51697 21.5 2 17.2854 2 12 m 10.25 6.25 b 9.42157 6.25 8.75 6.92157 8.75 7.75 b 8.75 8.57843 9.42157 9.25 10.25 9.25 b 11.0784 9.25 11.75 8.57843 11.75 7.75 b 11.75 6.92157 11.0784 6.25 10.25 6.25 m 7.25 10.5 b 6.42157 10.5 5.75 11.1716 5.75 12 b 5.75 12.8284 6.42157 13.5 7.25 13.5 b 8.07843 13.5 8.75 12.8284 8.75 12 b 8.75 11.1716 8.07843 10.5 7.25 10.5 m 15.25 7.75 b 14.4216 7.75 13.75 8.42157 13.75 9.25 b 13.75 10.0784 14.4216 10.75 15.25 10.75 b 16.0784 10.75 16.75 10.0784 16.75 9.25 b 16.75 8.42157 16.0784 7.75 15.25 7.75]]
local opts = {font='JetBrainsMono Nerd Font', hide_timeout=2.5, corner_radius=-1, visibility='auto', reveal_mode='separate',
  surface_mode='gradient', surface_opacity=.55, gradient_inner_opacity=.05, gradient_outer_opacity=.55,
  light_surface_opacity=.92, light_gradient_inner_opacity=.82, light_gradient_outer_opacity=.97, debug=false}
require('mp.options').read_options(opts, 'omarchy-controls')
local modes={'solid','translucent','gradient'}
local reveal_mode=opts.reveal_mode == 'together' and 'together' or 'separate'
local surface_mode=opts.surface_mode
if surface_mode ~= 'solid' and surface_mode ~= 'translucent' and surface_mode ~= 'gradient' then surface_mode='solid' end
local overlay = mp.create_osd_overlay('ass-events')
local palette = {background='#1a1b26', foreground='#c0caf5', accent='#7aa2f7',
  panel='#1e202c', button='#24283b', hover='#293a52', border='#3f4355',
  muted='#838aa8', error='#f7768e'}
local corner_radius = math.max(0, opts.corner_radius)
local surface_cache={}
local W, H, scale = 960, 620, 1
local regions, seekbar, volume_slider = {}, nil, nil
local mx, my, inside = -1, -1, false
local dragging, pressed, focused, keyboard = false, nil, 1, false
local focused_id='play'
local last_move, visible = mp.get_time(), true
local visibility_mode='auto'
local reveal_until, milliseconds, show_total = mp.get_time()+3, false, true
local volume_feedback_until, seek_feedback_until=0, 0
local render, request_render, deadline_timer, set_visibility, appearance_menu
local render_count,seek_requests=0,0
local last_drag_seek
local input_top, input_bottom, input_width, input_height
local sub_margin_base=mp.get_property_number('sub-margin-y',34)
local applied_sub_margin
local file_active=false
local file_generation=0

local function prop(name, fallback) return mp.get_property_native(name, fallback) end
local function number(name, fallback) return mp.get_property_number(name, fallback or 0) end
local function color(hex) return hex:sub(6,7) .. hex:sub(4,5) .. hex:sub(2,3) end
local function escape(text) return mp.command_native({'escape-ass', tostring(text)}) end
local function light_theme()
  if palette.mode then return palette.mode == 'light' end
  -- Older generated palettes do not carry Omarchy's resolved mode yet.
  local hex=palette.background
  local r,g,b=tonumber(hex:sub(2,3),16),tonumber(hex:sub(4,5),16),tonumber(hex:sub(6,7),16)
  return (r*.2126+g*.7152+b*.0722)/255 > .5
end
local function format_time(t)
  t = math.max(0, math.floor(t or 0))
  if t >= 3600 then return string.format('%d:%02d:%02d', math.floor(t/3600), math.floor(t/60)%60, t%60) end
  return string.format('%02d:%02d', math.floor(t/60), t%60)
end
local function format_speed(s)
  return string.format('%.2fx', math.floor((s or 1)*100 + 1e-9)/100)
end
local function hit(r) return mx >= r.x and mx <= r.x+r.w and my >= r.y and my <= r.y+r.h end
local function menu(name)
  keyboard=false; reveal_until=0; last_move=0
  mp.disable_key_bindings('omarchy-keyboard')
  if name == 'appearance' then appearance_menu()
  else mp.commandv('script-binding','select/'..name) end
end
local function wake() last_move = mp.get_time(); render() end
-- A duration can be a buffered estimate, not proof that the source can seek.
local function seek_window()
  local duration=number('duration')
  if prop('seekable',false) and duration > 0 and duration < math.huge then
    return {start=0, finish=duration}
  end
  local ranges={}
  for _,range in ipairs(prop('demuxer-cache-state',{})['seekable-ranges'] or {}) do
    if type(range.start)=='number' and type(range['end'])=='number' and
     range.start >= 0 and range['end'] > range.start and range['end'] < math.huge then
      ranges[#ranges+1]={start=range.start,finish=range['end']}
    end
  end
  if #ranges == 0 then return nil end
  table.sort(ranges,function(a,b) return a.start < b.start end)
  local finish=ranges[1].finish
  for _,range in ipairs(ranges) do finish=math.max(finish,range.finish) end
  return {start=ranges[1].start,finish=finish,ranges=ranges}
end
local function clamp_seek(target,window)
  target=math.max(window.start,math.min(window.finish,target))
  if not window.ranges then return target end
  local closest,distance
  for _,range in ipairs(window.ranges) do
    if target >= range.start and target <= range.finish then return target end
    for _,edge in ipairs({range.start,range.finish}) do
      local delta=math.abs(target-edge)
      if not distance or delta < distance then closest,distance=edge,delta end
    end
  end
  return closest
end
local function seek_mouse(final)
  local window=seek_window()
  if seekbar and window then
    local ratio=math.max(0,math.min(1,(mx-seekbar.x)/seekbar.w))
    local target=clamp_seek(window.start+ratio*(window.finish-window.start),window)
    -- Coarse drag previews avoid decoding every intermediate exact position.
    -- Release always commits the selected position exactly.
    if final or not last_drag_seek or math.abs(target-last_drag_seek) >= .05 then
      seek_requests=seek_requests+1
      if opts.debug then
        mp.set_property_native('user-data/omarchy/seek-requests',seek_requests)
        mp.set_property_native('user-data/omarchy/seek-target',target)
      end
      mp.commandv('seek',target,final and 'absolute+exact' or 'absolute+keyframes')
      last_drag_seek=target
    end
  end
end
local function relative_seek(step)
  local window=seek_window()
  if window then mp.commandv('seek',clamp_seek(number('time-pos')+step,window),'absolute+exact') end
end
local function reset_pointer()
  dragging,pressed=false,nil
  last_drag_seek=nil
  mp.set_property_native('user-data/omarchy/dragging',false)
end
local function volume_mouse()
  if volume_slider then
    local ratio=math.max(0,math.min(1,(mx-volume_slider.x)/volume_slider.w))
    mp.set_property_number('volume',ratio*number('volume-max',130))
  end
end
local function update_drag()
  if dragging == 'seek' then seek_mouse()
  elseif dragging == 'volume-slider' then volume_mouse() end
end
local function select_region()
  for i, r in ipairs(regions) do if hit(r) then return i, r end end
end
local function update_pointer()
  local x,y = mp.get_mouse_pos()
  mx,my = x/scale,y/scale
end
local function down()
  update_pointer()
  keyboard = false
  local i, r = select_region()
  pressed = r and r.id or nil
  last_drag_seek=nil
  if r and r.action and (r.id == 'seek' or r.id == 'volume-slider') then
    dragging=r.id; update_drag()
    mp.set_property_native('user-data/omarchy/dragging',dragging)
  end
  wake()
end
local function up()
  update_pointer()
  local i, r = select_region()
  if not dragging and r and r.id == pressed and r.action then r.action() end
  if dragging == 'seek' then seek_mouse(true) end
  reset_pointer()
  wake()
end
local function active_binding(key,bindings,skip_controls)
  local best
  for _,binding in ipairs(bindings) do
    if binding.key == key and type(binding.priority)=='number' and binding.priority >= 0 and
     not (skip_controls and (binding.section or ''):match('^omarchy%-')) then
      if not best or binding.priority > best.priority or
       binding.priority == best.priority and best.is_weak and not binding.is_weak then best=binding end
    end
  end
  return best
end
local function pass_wheel(key)
  local binding=active_binding(key,prop('input-bindings',{}),true)
  if binding and binding.cmd then mp.command(binding.cmd) end
end
local hint_bindings,hints_checked={},-1
local function key_hint(key,expected,label)
  if mp.get_time()-hints_checked > .5 then
    hint_bindings=prop('input-bindings',{}); hints_checked=mp.get_time()
  end
  local binding=active_binding(key,hint_bindings,false)
  if binding and binding.cmd and binding.cmd:find(expected,1,true) then return ' · '..(label or key) end
  return ''
end
local function scroll(direction)
  update_pointer()
  local _, r = select_region()
  if r and r.id == 'audio' then mp.commandv('cycle','audio', direction > 0 and 'up' or 'down')
  elseif r and r.id == 'subtitles' then mp.commandv('cycle','sub', direction > 0 and 'up' or 'down')
  elseif r and (r.id == 'volume' or r.id == 'volume-slider') then mp.commandv('add', 'volume', direction*5)
  elseif r and r.id == 'speed' then mp.commandv('add', 'speed', direction*.1)
  elseif r and r.id == 'seek' and seek_window() then relative_seek(direction*5)
  else pass_wheel(direction > 0 and 'WHEEL_UP' or 'WHEEL_DOWN') end
  wake()
end
local function alternate(kind)
  update_pointer()
  local _,r = select_region()
  if not r then return end
  if r.id == 'play' then mp.commandv('cycle-values',kind == 'middle' and 'loop-playlist' or 'loop-file','inf','no')
  elseif r.id == 'volume' or r.id == 'volume-slider' then menu('select-audio-device')
  elseif r.id == 'fullscreen' then mp.commandv('cycle','window-maximized')
  elseif r.id == 'title' then
    if kind == 'middle' then mp.osd_message(mp.get_property('path',''))
    else menu('select-watch-history') end
  elseif r.id == 'prev' or r.id == 'next' or r.id == 'playlist' then menu('select-playlist')
  elseif r.id == 'chapter-prev' or r.id == 'chapter-next' then menu('select-chapter')
  elseif r.id == 'audio' then mp.commandv('cycle','audio','down')
  elseif r.id == 'subtitles' then mp.commandv('cycle','sub','down')
  elseif r.id == 'seek' then
    local window=seek_window()
    if not window then return end
    local target=window.start+(window.finish-window.start)*math.max(0,math.min(1,(mx-seekbar.x)/seekbar.w))
    local best,distance
    for _,chapter in ipairs(prop('chapter-list',{})) do
      local delta=math.abs(chapter.time-target)
      if clamp_seek(chapter.time,window) == chapter.time and (not distance or delta < distance) then best,distance=chapter.time,delta end
    end
    if best then mp.commandv('seek',best,'absolute+exact') end
  end
  wake()
end
local mouse_keys = {
  {'MBTN_LEFT', up, down},
  {'MBTN_RIGHT', function() alternate('right') end},
  {'MBTN_MID', function() alternate('middle') end},
  {'MBTN_LEFT_DBL','ignore'},
  {'Shift+MBTN_LEFT_DBL','ignore'},
  {'MBTN_RIGHT_DBL','ignore'},
  {'Shift+MBTN_LEFT', function() alternate('middle') end},
  {'WHEEL_UP', function() scroll(1) end},
  {'WHEEL_DOWN', function() scroll(-1) end},
}
for _, section in ipairs({'omarchy-footer','omarchy-header'}) do
  mp.set_key_bindings(mouse_keys, section, 'force')
end

local function navigation(step)
  keyboard = true
  if visibility_mode == 'never' then set_visibility('auto') end
  for i,r in ipairs(regions) do if r.id == focused_id then focused=i; break end end
  focused = (focused - 1 + step) % math.max(1, #regions) + 1
  if regions[focused] then focused_id=regions[focused].id end
  wake()
end
local function focused_region()
  for _,r in ipairs(regions) do if r.id == focused_id then return r end end
end
local function adjust_focused(direction)
  local r=focused_region()
  if r and (r.id == 'volume' or r.id == 'volume-slider') then mp.commandv('add','volume',direction*5)
  elseif r and r.id == 'speed' then mp.commandv('add','speed',direction*.1)
  else relative_seek(direction*5) end
  wake()
end
local function activate()
  local r = focused_region()
  if r and r.action then r.action() end
  wake()
end
mp.set_key_bindings({
  {'TAB', function() navigation(1) end},
  {'Shift+TAB', function() navigation(-1) end},
  {'ENTER', activate},
  {'LEFT',function() adjust_focused(-1) end},
  {'RIGHT',function() adjust_focused(1) end},
  {'ESC', function() keyboard=false; wake() end},
}, 'omarchy-keyboard', 'force')
mp.add_key_binding('a','audio-tracks',function() menu('select-aid') end)
mp.add_key_binding('TAB', 'focus-controls', function()
  keyboard=true; focused=1; focused_id='play'
  if visibility_mode == 'never' then set_visibility('auto') end
  for i,r in ipairs(regions) do if r.id == 'play' then focused=i; break end end
  mp.enable_key_bindings('omarchy-keyboard')
  wake()
end)
mp.set_property('osd-font',opts.font)
-- Use this controller's themed sliders instead of mpv's text-colored OSD bar.
mp.set_property_bool('osd-bar',false)
local surface_labels={solid='Opaque',translucent='Translucent',gradient='Gradient'}
local function set_surface_mode(mode,quiet)
  if not surface_labels[mode] then return end
  surface_mode=mode
  reveal_until=mp.get_time()+3
  if not quiet then mp.osd_message('Toolbar background: '..surface_labels[mode],1.5) end
  wake()
end
local function transparency_menu()
  local items,selected={},1
  for i,mode in ipairs(modes) do
    items[i]=surface_labels[mode]..(mode == surface_mode and ' (current)' or '')
    if mode == surface_mode then selected=i end
  end
  input.select({prompt='Toolbar background:',items=items,default_item=selected,
    submit=function(index) set_surface_mode(modes[index],true) end})
end
local reveal_labels={separate='Separate · hover each toolbar',together='Together · show both toolbars'}
local function set_reveal_mode(mode)
  if mode ~= 'separate' and mode ~= 'together' then return end
  reveal_mode=mode
  mp.set_property_native('user-data/omarchy/reveal-mode',mode)
  wake()
end
local function reveal_menu()
  local modes={'separate','together'}
  local items={}
  for i,mode in ipairs(modes) do
    items[i]=reveal_labels[mode]..(mode == reveal_mode and ' (current)' or '')
  end
  input.select({prompt='Toolbar reveal:',items=items,
    default_item=reveal_mode == 'together' and 2 or 1,
    submit=function(index) set_reveal_mode(modes[index]) end})
end
mp.register_script_message('set-omarchy-reveal',set_reveal_mode)
mp.set_property_native('user-data/omarchy/reveal-mode',reveal_mode)
appearance_menu=function()
  local theme=prop('user-data/omarchy/theme-selection','automatic')
  input.select({prompt='Appearance:',keep_open=true,default_item=1,
    items={'Theme · '..(theme == 'automatic' and 'Automatic' or theme),
      'Toolbar background · '..surface_labels[surface_mode]..' · Ctrl+F9',
      'Toolbar reveal · '..(reveal_mode == 'together' and 'Together' or 'Separate')},
    submit=function(index)
      if index == 1 then mp.commandv('script-message-to','omarchy_theme','select-omarchy-theme')
      elseif index == 2 then transparency_menu()
      elseif index == 3 then reveal_menu() end
    end})
end
mp.add_key_binding(nil,'controls-menu',function() menu('menu') end)
mp.add_key_binding(nil,'appearance-menu',function() menu('appearance') end)
mp.add_key_binding(nil,'transparency-menu',transparency_menu)
mp.add_key_binding('Ctrl+F9','cycle-transparency',function()
  for i,mode in ipairs(modes) do
    if mode == surface_mode then set_surface_mode(modes[i%#modes+1]); break end
  end
end)
set_visibility=function(mode)
  if mode == 'cycle' then
    mode=visibility_mode == 'never' and 'auto' or visibility_mode == 'auto' and 'always' or 'never'
  end
  if mode ~= 'never' and mode ~= 'auto' and mode ~= 'always' then return end
  visibility_mode=mode
  if mode == 'never' then keyboard=false; reset_pointer() end
  mp.set_property_native('user-data/osc/visibility',mode)
  mp.set_property_native('user-data/omarchy/visibility-mode',mode)
  wake()
end
mp.add_key_binding('DEL','visibility',function() set_visibility('cycle') end)
mp.add_key_binding('F10','toggle-controls',function() set_visibility(visibility_mode == 'always' and 'auto' or 'always') end)
mp.register_script_message('osc-visibility',set_visibility)
local function restore_sub_margin()
  if applied_sub_margin and number('sub-margin-y') == applied_sub_margin then
    applied_sub_margin=nil
    mp.set_property_number('sub-margin-y',sub_margin_base)
  else applied_sub_margin=nil end
end
local function update_sub_margin(raised,height,reserved_pixels)
  local current=number('sub-margin-y',34)
  if current ~= applied_sub_margin then sub_margin_base=current end
  local factor=prop('sub-scale-by-window',true) and 720/height or 1
  -- mpv stores this option as an integer. Keep ownership comparisons in
  -- that same domain so fractional DPI does not compound our adjustment.
  local desired=math.max(0,math.min(2147483647,math.floor(sub_margin_base+(raised and reserved_pixels*factor or 0)+.5)))
  if math.abs(current-desired) > .001 then
    applied_sub_margin=desired
    mp.set_property_number('sub-margin-y',desired)
  end
  if opts.debug then mp.set_property_native('user-data/omarchy/subtitle-margin-base',sub_margin_base) end
end
local function schedule_deadline(near_controls)
  local now=mp.get_time()
  local next_time
  local function consider(time)
    if time > now and (not next_time or time < next_time) then next_time=time end
  end
  if visibility_mode ~= 'never' then
    consider(volume_feedback_until)
    if visibility_mode == 'auto' then
      consider(reveal_until)
      if near_controls then consider(last_move+math.max(0,opts.hide_timeout)) end
    end
  end
  if deadline_timer then
    deadline_timer:kill()
    if next_time then deadline_timer.timeout=math.max(.01,next_time-now+.01); deadline_timer:resume() end
  end
end

render = function()
  local width, height = mp.get_osd_size()
  if width <= 0 or height <= 0 then return end
  render_count=render_count+1
  if opts.debug then
    mp.set_property_native('user-data/omarchy/render-count',render_count)
    mp.set_property_native('user-data/omarchy/file-active',file_active)
  end
  local old_scale = scale
  scale = math.max(.75, math.min(1.6, height/720))
  W, H = width/scale, height/scale
  if scale ~= old_scale then reset_pointer(); mx,my=-1,-1 end
  local paused = prop('pause', false)
  local header, footer = 48, 112
  local bottom = H-footer
  if opts.debug then mp.set_property_native('user-data/omarchy/layout',{width=W,height=H,scale=scale}) end
  local near_top = inside and my <= header+12
  local near_bottom = inside and my >= bottom-24
  local near_controls = near_top or near_bottom
  local allowed = visibility_mode ~= 'never' and not prop('user-data/mpv/console/open',false)
  local shared = keyboard or visibility_mode == 'always' or prop('idle-active',false)
  local pointer_awake = mp.get_time()-last_move < opts.hide_timeout
  local top_visible = allowed and (shared or near_top and pointer_awake)
  local bottom_visible = allowed and (shared or (not not dragging) or near_bottom and pointer_awake or
    mp.get_time() < seek_feedback_until or mp.get_time() < volume_feedback_until or
    not near_top and mp.get_time() < reveal_until)
  if reveal_mode == 'together' and (top_visible or bottom_visible) then
    top_visible, bottom_visible = true, true
  end
  visible = top_visible or bottom_visible
  if prop('user-data/omarchy/top-visible') ~= top_visible then mp.set_property_native('user-data/omarchy/top-visible',top_visible) end
  if prop('user-data/omarchy/bottom-visible') ~= bottom_visible then mp.set_property_native('user-data/omarchy/bottom-visible',bottom_visible) end
  update_sub_margin(file_active and bottom_visible and number('sub-pos',100) >= 95 and prop('sub-align-y','bottom') == 'bottom',height,footer*scale)
  schedule_deadline(near_controls)
  if prop('user-data/omarchy/surface-mode') ~= surface_mode then
    mp.set_property_native('user-data/omarchy/surface-mode',surface_mode)
  end
  local focus=keyboard and focused_id or ''
  if prop('user-data/omarchy/focused-control') ~= focus then
    mp.set_property_native('user-data/omarchy/focused-control',focus)
  end
  if prop('user-data/omarchy/controls-visible') ~= visible then
    mp.set_property_native('user-data/omarchy/controls-visible',visible)
  end
  if input_width ~= width or input_height ~= height then
    mp.set_mouse_area(0, bottom*scale, width, height, 'omarchy-footer')
    mp.set_mouse_area(0, 0, width, header*scale, 'omarchy-header')
    input_width, input_height = width, height
  end
  if input_top ~= top_visible then
    if top_visible then mp.enable_key_bindings('omarchy-header', 'allow-hide-cursor')
    else mp.disable_key_bindings('omarchy-header') end
    input_top = top_visible
  end
  if input_bottom ~= bottom_visible then
    if bottom_visible then mp.enable_key_bindings('omarchy-footer', 'allow-hide-cursor')
    else mp.disable_key_bindings('omarchy-footer') end
    input_bottom = bottom_visible
  end
  regions, seekbar, volume_slider = {}, nil, nil
  if not keyboard then mp.disable_key_bindings('omarchy-keyboard') end
  if not visible then
    if overlay.data ~= '' then overlay:remove(); overlay.data='' end
    return
  end
  local a = assdraw.ass_new()
  local function box(x,y,w,h,fill,radius,border,opacity,border_opacity)
    radius=math.max(0,math.min(radius or 0,w/2,h/2))
    local alpha=math.floor((1-math.max(0,math.min(1,opacity or 1)))*255+.5)
    a:new_event(); a:append('{\\pos(0,0)\\an7\\bord0\\shad0\\1c&H'..color(fill)..'&\\1a&H'..string.format('%02X',alpha)..'&}')
    a:draw_start()
    if radius and radius > 0 then a:round_rect_cw(x,y,x+w,y+h,radius)
    else a:rect_cw(x,y,x+w,y+h) end
    a:draw_stop()
    if border then
      -- Thin inset border keeps small buttons crisp at any scale.
      local ba=math.floor((1-math.max(0,math.min(1,border_opacity or 1)))*255+.5)
      a:new_event(); a:append('{\\pos(0,0)\\an7\\bord0\\shad0\\1c&H'..color(border)..'&\\1a&H'..string.format('%02X',ba)..'&}')
      a:draw_start(); a:round_rect_cw(x,y,x+w,y+h,radius or 0)
      a:round_rect_ccw(x+1,y+1,x+w-1,y+h-1,math.max(0,(radius or 0)-1)); a:draw_stop()
    end
  end
  local light=light_theme()
  local uniform_opacity=light and opts.light_surface_opacity or opts.surface_opacity
  local inner_opacity=light and opts.light_gradient_inner_opacity or opts.gradient_inner_opacity
  local outer_opacity=light and opts.light_gradient_outer_opacity or opts.gradient_outer_opacity
  local function surface_opacity(y)
    if surface_mode == 'solid' then return 1 end
    if surface_mode == 'translucent' then return uniform_opacity end
    local fraction=y <= header and 1-y/header or (y-bottom)/footer
    fraction=math.max(0,math.min(1,fraction))
    return inner_opacity+(outer_opacity-inner_opacity)*fraction
  end
  -- Reuse gradient geometry when only the playback clock or slider changes.
  local function cached_surface(slot,key,draw)
    local entry=surface_cache[slot]
    if not entry or entry.key ~= key then
      local target=a
      a=assdraw.ass_new()
      draw()
      entry={key=key,data=a.text}
      surface_cache[slot]=entry
      a=target
    end
    a:new_event(); a:append(entry.data)
  end
  local function gradient_rect(x,y,w,h,fill,radius)
    radius=math.max(0,math.min(radius or 0,w/2,h/2))
    -- Clip a full rectangle into adjacent bands. Drawing one-pixel shapes
    -- anti-aliases their edges and makes light backgrounds unexpectedly dim.
    local steps=math.ceil(h/2)
    for i=0,steps-1 do
      local y1=math.floor(y+i*h/steps+.5)
      local y2=math.floor(y+(i+1)*h/steps+.5)
      local opacity=surface_opacity((y1+y2)/2)
      local alpha=math.floor((1-math.max(0,math.min(1,opacity)))*255+.5)
      a:new_event()
      a:append(string.format('{\\pos(0,0)\\an7\\bord0\\shad0\\clip(%d,%d,%d,%d)\\1c&H%s&\\1a&H%02X&}',
        math.floor(x),y1,math.ceil(x+w),y2,color(fill),alpha))
      a:draw_start()
      if radius > 0 then a:round_rect_cw(x,y,x+w,y+h,radius)
      else a:rect_cw(x,y,x+w,y+h) end
      a:draw_stop()
    end
  end
  local function panel(y,h)
    local key=table.concat({W,H,scale,y,h,palette.panel,surface_mode,
      uniform_opacity,inner_opacity,outer_opacity},':')
    cached_surface(y == 0 and 'top' or 'footer',key,function()
      if surface_mode ~= 'gradient' then
        box(0,y,W,h,palette.panel,nil,nil,surface_opacity(y+h/2))
      else
        gradient_rect(0,y,W,h,palette.panel)
      end
    end)
  end
  local function text(x,y,label,size,fg,align,clip)
    a:new_event(); a:pos(x,y); a:an(align or 4)
    a:append('{\\fn'..opts.font..'\\fs'..size..'\\bord'..((light or surface_mode == 'solid') and '0' or '.6')..'\\3c&H'..color(palette.background)..'&\\shad0\\1a&H00&\\1c&H'..color(fg)..'&}')
    if clip then a:append(string.format('{\\clip(%d,%d,%d,%d)}',math.floor(clip[1]),math.floor(clip[2]),math.ceil(clip[3]),math.ceil(clip[4]))) end
    a:append(escape(label))
  end
  local function lines(x,y,segments,fg)
    a:new_event(); a:append('{\\pos(0,0)\\an7\\bord0\\shad0\\1c&H'..color(fg)..'&}')
    a:draw_start()
    for _, seg in ipairs(segments) do
      local x1,y1,x2,y2 = x+seg[1],y+seg[2],x+seg[3],y+seg[4]
      local dx,dy=x2-x1,y2-y1
      local length=math.sqrt(dx*dx+dy*dy)
      if length > 0 then
        local nx,ny=-dy/length*.8,dx/length*.8
        a:move_to(x1+nx,y1+ny); a:line_to(x2+nx,y2+ny)
        a:line_to(x2-nx,y2-ny); a:line_to(x1-nx,y1-ny)
      end
    end
    a:draw_stop()
  end
  local function icon(x,y,name,fg)
    if name == 'play' then
      a:new_event(); a:append('{\\pos(0,0)\\an7\\bord0\\shad0\\1c&H'..color(fg)..'&}'); a:draw_start()
      a:move_to(x-5,y-7); a:line_to(x+7,y); a:line_to(x-5,y+7); a:draw_stop()
    elseif name == 'pause' then lines(x,y,{{-4,-7,-4,7},{4,-7,4,7}},fg)
    elseif name == 'fullscreen' then lines(x,y,{{-7,-2,-7,-7},{-7,-7,-2,-7},{2,-7,7,-7},{7,-7,7,-2},{7,2,7,7},{7,7,2,7},{-2,7,-7,7},{-7,7,-7,2}},fg)
    elseif name == 'appearance' then
      a:new_event()
      a:append(string.format('{\\pos(%.3f,%.3f)\\an7\\bord.9\\shad0\\fscx83.333\\fscy83.333\\1a&HFF&\\3a&H00&\\3c&H%s&}',x-10,y-10,color(fg)))
      a:append('{\\p1}'..appearance_path..'{\\p0}')
    elseif name == 'more' then
      for dx=-6,6,6 do box(x+dx-1,y-1,2,2,fg) end
    elseif name == 'prev' or name == 'next' then
      local dir=name == 'prev' and 1 or -1
      lines(x,y,{{dir*4,-6,dir*-3,0},{dir*-3,0,dir*4,6},{dir*-6,-6,dir*-6,6}},fg)
    elseif name == 'playlist' then lines(x,y,{{-7,-5,7,-5},{-7,0,7,0},{-7,5,7,5}},fg)
    elseif name == 'speaker' or name == 'muted' then
      lines(x,y,{{-6,-4,-2,-4},{-2,-4,3,-8},{3,-8,3,8},{3,8,-2,4},{-2,4,-6,4},{-6,4,-6,-4},{7,-4,9,0},{9,0,7,4}},fg)
      if name == 'muted' then lines(x,y,{{-9,9,10,-9}},fg) end
    elseif name == 'audio' then
      lines(x,y,{{-8,3,-8,-2},{-8,-2,-6,-6},{-6,-6,-3,-8},{-3,-8,3,-8},{3,-8,6,-6},{6,-6,8,-2},{8,-2,8,3},
        {-8,1,-4,1},{-4,1,-4,8},{-4,8,-8,8},{-8,8,-8,1},
        {4,1,8,1},{8,1,8,8},{8,8,4,8},{4,8,4,1}},fg)
    elseif name == 'subtitles' then
      lines(x,y,{{-8,-6,8,-6},{8,-6,8,6},{8,6,-8,6},{-8,6,-8,-6},{-5,2,-1,2},{2,2,5,2}},fg)
    elseif name == 'back' or name == 'forward' then
      local dir=name == 'back' and 1 or -1
      lines(x,y,{{dir*5,-5,dir*-2,0},{dir*-2,0,dir*5,5}},fg)
    end
  end
  local function button_surface(id,x,y,w,h,fill,border,hot)
    local key=table.concat({x,y,w,h,scale,fill,border,tostring(hot),corner_radius,
      surface_mode,uniform_opacity,inner_opacity,outer_opacity},':')
    cached_surface('button-'..id,key,function()
      local opacity=surface_opacity(y+h/2)
      local border_opacity=surface_mode == 'solid' and 1 or hot and .9 or math.max(.25,opacity)
      if surface_mode == 'gradient' and not hot then
        gradient_rect(x,y,w,h,fill,corner_radius)
        box(x,y,w,h,fill,corner_radius,border,0,border_opacity)
      else
        box(x,y,w,h,fill,corner_radius,border,hot and math.max(.65,opacity) or opacity,border_opacity)
      end
    end)
  end
  regions={}
  local function button(id,x,y,w,label,glyph,action,active,enabled)
    local r={id=id,x=x,y=y,w=w,h=34,action=enabled ~= false and action or nil}
    regions[#regions+1]=r
    local hot=inside and hit(r) or keyboard and focused_id==id
    local fg=enabled == false and palette.muted or active and palette.accent or palette.foreground
    button_surface(id,x,y,w,34,hot and palette.hover or palette.button,hot and palette.accent or palette.border,hot)
    if glyph then icon(x+(label ~= '' and 18 or w/2),y+17,glyph,fg) end
    if label ~= '' then text(x+(glyph and 33 or w/2),y+17,label,15,fg,glyph and 4 or 5) end
    if hot then
      local help={menu='Menu · history, devices, key bindings, help',
        appearance='Appearance · theme and toolbar background',
        prev='Previous playlist entry'..key_hint('<','playlist-prev'),
        next='Next playlist entry'..key_hint('>','playlist-next'),
        play='Play / pause'..key_hint('SPACE','cycle pause','Space'),
        back='Back 10 seconds'..key_hint('LEFT','seek -5','Left: 5 seconds'),
        forward='Forward 10 seconds'..key_hint('RIGHT','seek 5','Right: 5 seconds'),
        audio='Audio tracks'..key_hint('a','audio-tracks'),
        subtitles='Subtitles'..key_hint('j','cycle sub'),
        playlist='Playlist'..key_hint('F8','show-text'),
        speed='Playback speed'..key_hint('[','multiply speed','[ / ]'),
        volume='Mute'..key_hint('m','cycle mute')..' · scroll to adjust volume',
        fullscreen='Fullscreen'..key_hint('f','cycle fullscreen')}
      if help[id] then
        local tw=math.min(W-24,#help[id]*7.4+20)
        local tooltip_y = y < header and header+6 or bottom-34
        box((W-tw)/2,tooltip_y,tw,28,palette.panel,corner_radius,palette.border)
        text(W/2,tooltip_y+14,help[id],12,palette.foreground,5)
      end
    end
  end
  if top_visible then
    panel(0,header)
    if surface_mode ~= 'gradient' then box(0,header-1,W,1,palette.border) end
    local title_right=W-104
    text(18,header/2,prop('filename',prop('media-title','Drop a video to play')),16,palette.foreground,4,{18,0,title_right,header})
    regions[#regions+1]={id='title',x=18,y=0,w=title_right-18,h=header,action=function() mp.commandv('script-binding','stats/display-page-5') end}
    button('appearance',W-91,7,34,'','appearance',function() menu('appearance') end)
    button('menu',W-49,7,34,'','more',function() menu('menu') end)
  end
  if bottom_visible then
    panel(bottom,footer)
    if surface_mode ~= 'gradient' then box(0,bottom,W,1,palette.border) end
    local duration=number('duration')
    local window=seek_window()
    if prop('user-data/omarchy/seek-enabled') ~= (window ~= nil) then mp.set_property_native('user-data/omarchy/seek-enabled',window ~= nil) end
    if opts.debug then mp.set_property_native('user-data/omarchy/seek-window',window or false) end
    local time=number('time-pos')
    local sy=bottom+28
    text(18,sy,milliseconds and string.format('%s.%03d',format_time(time),math.floor(time%1*1000)) or format_time(time),13,palette.foreground)
    regions[#regions+1]={id='elapsed',x=0,y=sy-12,w=90,h=24,action=function() milliseconds=not milliseconds end}
    text(W-18,sy,duration > 0 and prop('seekable',false) and (show_total and format_time(duration) or '-'..format_time(duration-time)) or 'LIVE',13,palette.muted,6)
    regions[#regions+1]={id='remaining',x=W-90,y=sy-12,w=90,h=24,action=function() show_total=not show_total end}
    local x1,x2=104,W-104
    seekbar={id='seek',x=x1,y=sy-10,w=x2-x1,h=20}
    box(x1,sy-4,x2-x1,8,palette.button,4,nil,surface_opacity(sy))
    local position=window and math.max(0,math.min(1,(time-window.start)/(window.finish-window.start))) or 0
    if position > 0 then box(x1,sy-4,(x2-x1)*position,8,palette.accent,4) end
    for _, chapter in ipairs(prop('chapter-list',{})) do
      if window and chapter.time >= window.start and chapter.time <= window.finish then box(x1+(x2-x1)*(chapter.time-window.start)/(window.finish-window.start),sy-6,1,12,palette.muted) end
    end
    if window then
      box(x1+(x2-x1)*position-5,sy-9,10,18,palette.accent,3)
      seekbar.action=seek_mouse; regions[#regions+1]=seekbar
      if inside and hit(seekbar) then text(mx,sy-22,format_time(clamp_seek(window.start+(mx-x1)/(x2-x1)*(window.finish-window.start),window)),12,palette.foreground,5) end
    end
    local by=bottom+55
    button('play',18,by,42,'',paused and 'play' or 'pause',function() mp.commandv('cycle','pause') end,true)
    if W >= 620 then
    button('back',68,by,56,'10','back',function() relative_seek(-10) end,false,window ~= nil)
    button('forward',132,by,56,'10','forward',function() relative_seek(10) end,false,window ~= nil)
    end
    local playlist_count=number('playlist-count')
    if playlist_count > 1 and W >= 980 then
      button('prev',196,by,34,'','prev',function() mp.commandv('playlist-prev') end,false,number('playlist-pos')>0)
      button('next',238,by,34,'','next',function() mp.commandv('playlist-next') end,false,number('playlist-pos')<playlist_count-1)
    end
    if #prop('chapter-list',{}) > 1 and W >= 1200 then
      button('chapter-prev',280,by,34,'','prev',function() mp.commandv('add','chapter',-1) end,false,window ~= nil and not window.ranges)
      button('chapter-next',322,by,34,'','next',function() mp.commandv('add','chapter',1) end,false,window ~= nil and not window.ranges)
    end
    local compact=W < 850
    local right=W-18-34-8
    local fw=34
    right=right-fw
    button('playlist',right,by,fw,'','playlist',function() menu('select-playlist') end)
    right=right-8-34
    button('subtitles',right,by,34,'','subtitles',function() menu('select-sid') end)
    right=right-8-34
    button('audio',right,by,34,'','audio',function() menu('select-aid') end)
    if W >= 460 then
    right=right-8-64
    button('speed',right,by,64,format_speed(number('speed',1)),nil,function()
      local speed=number('speed',1); mp.set_property_number('speed',speed>=2 and .5 or speed+.25)
    end)
    end
    local vy=by+17
    local vw=compact and 64 or 88
    local vx=right-8-vw
    local mute_x=W >= 420 and vx-12-34 or right-8-34
    button('volume',mute_x,by,34,'',prop('mute',false) and 'muted' or 'speaker',
      function() mp.commandv('cycle','mute') end,prop('mute',false))
    if W >= 420 then
      volume_slider={id='volume-slider',x=vx,y=by,w=vw,h=34,action=function() mp.commandv('cycle','mute') end}
      regions[#regions+1]=volume_slider
      local ratio=math.max(0,math.min(1,number('volume')/math.max(1,number('volume-max',130))))
      box(vx,vy-2,vw,4,palette.button,1,nil,surface_opacity(vy))
      if ratio > 0 then box(vx,vy-2,vw*ratio,4,palette.accent,1) end
      box(vx+vw*ratio-3,vy-5,6,10,palette.accent,corner_radius)
      if mp.get_time() < volume_feedback_until or dragging == 'volume-slider' or inside and hit(volume_slider) or keyboard and focused_id=='volume-slider' then
        box(vx-8,by-27,vw+16,22,palette.panel,corner_radius,palette.border)
        text(vx+vw/2,by-16,string.format('%d%%',number('volume')),12,palette.foreground,5)
      end
    else volume_slider=nil end
    button('fullscreen',W-52,by,34,'','fullscreen',function() mp.commandv('cycle','fullscreen') end)
  end
  if prop('idle-active',false) then
    text(W/2,H/2-18,'Drop a video or URL here',21,palette.foreground,5)
    text(W/2,H/2+18,'Space to play · f for fullscreen · Tab for controls',13,palette.muted,5)
  end
  if opts.debug then
    local debug_regions={}
    for _,r in ipairs(regions) do debug_regions[#debug_regions+1]={id=r.id,x=r.x,y=r.y,w=r.w,h=r.h,enabled=r.action ~= nil} end
    mp.set_property_native('user-data/omarchy/control-regions',debug_regions)
  end
  overlay.res_x,overlay.res_y=W,H
  if overlay.data ~= a.text then overlay.data=a.text; overlay:update() end
end

mp.observe_property('mouse-pos','native',function(_,pos)
  if not pos then return end
  local x,y=pos.x/scale,pos.y/scale
  if x ~= mx or y ~= my then last_move=mp.get_time() end
  mx,my,inside=x,y,pos.hover
  if dragging then update_drag() end
  if visibility_mode ~= 'never' or dragging then render() end
end)
mp.observe_property('user-data/omarchy/corner-radius','number',function(_,radius)
  if opts.corner_radius < 0 and radius and radius >= 0 and radius < math.huge then
    corner_radius=radius
  end
  if opts.debug then mp.set_property_native('user-data/omarchy/control-corner-radius',corner_radius) end
  render()
end)
mp.observe_property('user-data/omarchy/theme','native',function(_,colors)
  if colors then
    palette.mode=colors.mode
    for key,value in pairs(colors) do palette[key]=value end
  end
  render()
end)
-- Coalesce property notifications; hidden playback clocks do not need redraws.
local render_timer=mp.add_timeout(.016,function() render() end)
render_timer:kill()
request_render=function()
  if not render_timer:is_enabled() then render_timer.timeout=.016; render_timer:resume() end
end
deadline_timer=mp.add_timeout(1,function() render() end)
deadline_timer:kill()
mp.observe_property('time-pos','number',function() if visible then request_render() end end)
for _, name in ipairs({'pause','duration','seekable','volume-max','mute','speed','fullscreen','media-title','filename',
  'idle-active','chapter-list','track-list','playlist-pos','playlist-count','user-data/mpv/console/open',
  'sub-pos','sub-align-y','sub-scale-by-window'}) do
  mp.observe_property(name,'native',request_render)
end
mp.observe_property('demuxer-cache-state','native',function() if visible then request_render() end end)
mp.observe_property('osd-dimensions','native',function() reset_pointer(); input_width=nil; request_render() end)
mp.observe_property('focused','bool',function(_,value) if value == false then reset_pointer(); request_render() end end)
mp.observe_property('sub-margin-y','number',function(_,value)
  -- Ignore stale queued notifications and our own adjustment.
  if value and value == number('sub-margin-y') and value ~= applied_sub_margin then
    sub_margin_base=value
    request_render()
  end
end)
mp.register_event('seek',function()
  seek_feedback_until=mp.get_time()+1.5
  reveal_until=seek_feedback_until
  request_render()
end)
local previous_volume
mp.observe_property('volume','number',function(_,value)
  if previous_volume ~= nil and value ~= previous_volume then
    volume_feedback_until=mp.get_time()+1.5
    reveal_until=volume_feedback_until
  end
  previous_volume=value
  request_render()
end)
mp.register_event('end-file',function()
  file_active=false; reset_pointer(); restore_sub_margin(); request_render()
end)
mp.register_event('file-loaded',function()
  file_active=true; file_generation=file_generation+1
  if opts.debug then mp.set_property_native('user-data/omarchy/file-generation',file_generation) end
  reset_pointer(); keyboard=false; focused_id='play'
  reveal_until=mp.get_time()+3; request_render()
end)
mp.register_event('shutdown',restore_sub_margin)
set_visibility((opts.visibility == 'never' or opts.visibility == 'always') and opts.visibility or 'auto')
render()
