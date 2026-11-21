local picker
require('mp.input').select=function(options) picker=options end
local mouse_handler
local original_observe=mp.observe_property
mp.observe_property=function(name,kind,callback)
  if name=='mouse-pos' then mouse_handler=callback end
  return original_observe(name,kind,callback)
end
local keys, enabled={},{}
mp.set_key_bindings=function(list,name) keys[name]=list end
mp.enable_key_bindings=function(name) enabled[name]=true end
mp.disable_key_bindings=function(name) enabled[name]=false end
local x,y=0,0
mp.get_mouse_pos=function() return x,y end
mp.get_osd_size=function() return 960,720 end
local drawing=''
mp.create_osd_overlay=function()
  return {update=function(self) drawing=self.data end,remove=function() drawing='' end}
end
dofile(os.getenv('MPV_REVEAL_CONTROLLER'))
local function p(name) return mp.get_property_native('user-data/omarchy/'..name) end
local function mouse(px,py) x,y=px,py;mouse_handler(nil,{x=x,y=y,hover=true}) end
local function state(top,bottom)
  assert(p('top-visible')==top and p('bottom-visible')==bottom,'Unexpected top/bottom reveal')
  assert(enabled['omarchy-header']==top and enabled['omarchy-footer']==bottom,'Hidden input bindings active')
end
local function region(name)
  for _,r in ipairs(p('control-regions') or {}) do if r.id==name then return r end end
end
local steps={
function()
  mouse(500,20);state(true,false)
  assert(region('appearance') and not region('play'))
  assert(drawing:find('\\1a&HFF&\\3a&H00&'),'Palette icon should be outline-only')
  assert(mp.get_property_number('sub-margin-y')==34,'Top hover should not raise subtitles')
end,
function()
  mouse(500,680);state(false,true)
  assert(region('play') and not region('appearance'))
  for _,id in ipairs({'audio','subtitles','playlist'}) do assert(region(id).w==34,id..' must be icon-only') end
  assert(mp.get_property_number('sub-margin-y')==146,'Bottom hover should raise subtitles')
end,
function() mouse(500,350);state(false,false) end,
function()
  mouse(500,640);state(false,true)
  keys['omarchy-footer'][1][3]() -- begin seek drag
  mouse(500,350);state(false,true) -- retain controls across the video while dragging
end,
function() keys['omarchy-footer'][1][2]();mouse(500,20);state(true,true) end,
function() mp.commandv('script-message','osc-visibility','always') end,
function() mouse(500,350);state(true,true) end,
function() mp.commandv('script-message','osc-visibility','never') end,
function() mouse(500,680);state(false,false) end,
function() mp.commandv('script-message','osc-visibility','auto') end,
function() mouse(500,20);state(true,false);mp.commandv('seek',.1,'relative+exact') end,
function() state(true,true) end,
function() mp.commandv('script-message','osc-visibility','never') end,
function() state(false,false);mp.commandv('script-message','osc-visibility','auto');mp.commandv('keypress','TAB') end,
function() state(true,true); assert(region('play') and region('appearance')) end,
function()
  keys['omarchy-keyboard'][6][2]() -- leave keyboard focus
  mp.commandv('script-binding',mp.get_script_name()..'/appearance-menu')
end,
function()
  assert(picker.prompt=='Appearance:' and picker.items[3]:find('Separate'))
  picker.submit(3)
  assert(picker.prompt=='Toolbar reveal:' and picker.default_item==1)
  picker.submit(2)
  assert(p('reveal-mode')=='together')
  mouse(500,20);state(true,true)
end,
function() mouse(500,680);state(true,true) end,
function() mouse(500,350);state(false,false);mp.commandv('script-message','set-omarchy-reveal','invalid') end,
function()
  assert(p('reveal-mode')=='together','Invalid mode must retain last choice')
  mp.commandv('script-binding',mp.get_script_name()..'/appearance-menu')
end,
function()
  assert(picker.items[3]:find('Together'))
  picker.submit(3)
  assert(picker.default_item==2)
  picker.submit(1)
  mouse(500,20);state(true,false)
  mouse(500,680);state(false,true)
end,
function()
  print('PASS: separate reveals, hidden hitboxes, outline icon, icon-only controls, drag, subtitle margins, pin, hidden mode, keyboard')
  mp.commandv('quit')
end
}
local function run(i)
  local ok,err=pcall(steps[i])
  if not ok then print('FAIL: step '..i..': '..tostring(err));mp.commandv('quit',1);return end
  if i<#steps then mp.add_timeout((i==5 or i==15) and 1.6 or .15,function() run(i+1) end) end
end
mp.add_timeout(3.3,function() run(1) end)
