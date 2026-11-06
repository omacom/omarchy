local order = dofile(arg[1])
local focused
local swaps = 0
hl = {
  dsp = {
    window = { tag = function(s) s.kind = "tag" return s end, swap = function(s) s.kind = "swap" return s end },
    focus = function(s) s.kind = "focus" return s end,
  },
  get_active_window = function() return focused end,
  exec_scheduled_prop_refresh_immediately = function() end,
}
local all = {}
function hl.dispatch(s)
  if s.kind == "tag" then
    local tag = s.tag:sub(2)
    if s.tag:sub(1,1) == "+" then table.insert(s.window.tags, tag)
    else for i = #s.window.tags, 1, -1 do if s.window.tags[i] == tag then table.remove(s.window.tags, i) end end end
  elseif s.kind == "swap" then
    local target
    for _, w in ipairs(all) do if "address:" .. w.address == s.target then target = w end end
    assert(target, "swap target exists")
    s.window.at, target.at = target.at, s.window.at
    focused = target
    swaps = swaps + 1
  else focused = s.window end
end
local function window(id, x, y)
  local w = { address = id, at = {x=x,y=y or 0}, tags={}, mapped=true, floating=false }
  table.insert(all,w)
  return w
end
local a,b,c = window("a",0),window("b",100),window("c",100,100)
local natural = window("natural",20); natural.floating=true
local pinned = window("pinned",30); pinned.pinned=true
local hidden = window("hidden",40); hidden.hidden=true
local full = window("full",50); full.fullscreen=2
local before=order.capture(all,"9",{},false)
assert(#before==3 and before[1].window==a and before[2].window==b and before[3].window==c)
focused=b
b.at,c.at=c.at,b.at
order.restore(before)
assert(a.at.x==0 and b.at.y==0 and c.at.y==100 and focused==b and swaps==1, "restores order and focus")
order.remember(before,"9")
a.floating,b.floating,c.floating=true,true,true
a.at,b.at,c.at={x=100,y=0},{x=0,y=0},{x=50,y=0}
order=dofile(arg[1])
local restored=order.capture(all,"9",{a=true,b=true,c=true},true)
assert(#restored==3 and restored[1].window==a and restored[2].window==b and restored[3].window==c, "ranks survive reload and cascade positions")
local d=window("d",-100)
local with_new=order.capture(all,"9",{a=true,b=true,c=true},true)
assert(with_new[4].window==d,"new windows follow remembered windows")
assert(#order.capture({a,b,c},"10",{},true)==0,"natural floating windows stay excluded")
for _,w in ipairs({a,b,c}) do order.clear(w); assert(#w.tags==0,"rank tags are removed") end
a.tags={"user-tag", "omarchy-layout-order-9-1", "omarchy-layout-order-10-2"}
order.clear(a)
assert(#a.tags==1 and a.tags[1]=="user-tag","all old ranks are removed without touching user tags")
local count=swaps
order.restore({})
assert(swaps==count,"empty workspace is unchanged")
local g1,g2=window("g1",0),window("g2",0)
local group={current=g2,members={g1,g2}}
g1.group,g2.group=group,group
local grouped=order.capture({g1,g2},"9",{},true)
assert(#grouped==1 and grouped[1].window==g2,"a group occupies one ordering slot")
order.remember(grouped,"9")
group.current=g1
g1.floating,g2.floating=true,true
grouped=order.capture({g1,g2,d},"9",{g1=true,g2=true},true)
assert(grouped[1].window==g1,"changing a group's active member keeps its rank")
order.clear(g1);order.clear(g2)
print("ok - order, focus, reload, new windows and floating exclusions")
