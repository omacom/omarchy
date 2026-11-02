-- Run the real controller and decoder without a desktop window. Only the
-- window geometry, pointer delivery and OSD surface are supplied by this driver.
local mp = require 'mp'
local mouse = {x=0,y=0,hover=true}
local bindings, mouse_observer, seeks = {}, nil, {}
local observe_property, commandv = mp.observe_property, mp.commandv
local get_property_number = mp.get_property_number
local stale_time
mp.get_osd_size = function() return 960,620 end
mp.get_mouse_pos = function() return mouse.x,mouse.y end
mp.get_property_number = function(name,...)
  if name == 'time-pos' and stale_time then return stale_time end
  return get_property_number(name,...)
end
mp.observe_property = function(name,kind,callback)
  if name == 'mouse-pos' then mouse_observer=callback
  else return observe_property(name,kind,callback) end
end
mp.set_key_bindings = function(keys,section) bindings[section]=keys end
mp.set_mouse_area = function() end
mp.enable_key_bindings = function() end
mp.disable_key_bindings = function() end
mp.create_osd_overlay = function()
  return {data='',update=function() end,remove=function() end}
end
mp.commandv = function(...)
  local args={...}
  if args[1] == 'seek' then
    seeks[#seeks+1]={target=args[2],flags=args[3]}
    mp.set_property_native('user-data/test/seeks',seeks)
  end
  return commandv(...)
end
dofile(assert(os.getenv('MPV_SEEK_CONTROLLER')))
local completions={}
mp.register_event('playback-restart',function()
  if not mp.get_property_native('seeking') then
    completions[#completions+1]=get_property_number('time-pos')
    mp.set_property_native('user-data/test/completions',completions)
  end
end)
local step=0
mp.register_script_message('pointer',function(action,x,y)
  mouse.x,mouse.y=tonumber(x),tonumber(y)
  mouse_observer('mouse-pos',mouse)
  local key=bindings['omarchy-footer'][1]
  if action == 'down' then key[3]()
  elseif action == 'up' then key[2]() end
  step=step+1
  mp.set_property_number('user-data/test/step',step)
end)
mp.register_script_message('stale-time',function(value)
  stale_time=tonumber(value)
  mp.set_property_native('user-data/test/stale-time',stale_time or false)
end)
