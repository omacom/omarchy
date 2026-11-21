local paths = require("default.hypr.paths")

local vmwgfx = paths.omarchy_path .. "/bin/omarchy-hw-vmwgfx"

-- VMware Workstation and Fusion present the SVGA adapter, VirtualBox's default
-- VMSVGA controller emulates it, and vmwgfx drives both.
--
-- vmwgfx imports client dmabufs as TTM surface handles that Hyprland cannot
-- close: drmCloseBufferHandle() fails with EINVAL, Hyprland rejects the
-- buffer, and every GPU-rendering client dies on its first frame with
-- "invalid arguments for wl_surface.attach" (hyprwm/aquamarine#360). On
-- llvmpipe clients use wl_shm instead and work.
--
-- The variable is set from the start handler, not at parse time. A top-level
-- hl.env() reaches aquamarine before it creates the DRM renderer and puts
-- Hyprland itself on software GL ("CDRMRenderer(drm): Can't create renderer,
-- no matching devices found"). At runtime hl.env() is inherited by every
-- exec that follows, which is why omarchy.lua requires this module before
-- autostart: handlers fire in registration order, and autostart's handler
-- imports the environment into systemd and launches the shell.
--
-- The detector forks once here, for both of the quirks below; the handler only
-- sets the variable.
if not o.shell_succeeds(o.shell_quote(vmwgfx)) then
  return
end

hl.on("hyprland.start", function()
  hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
end)

-- Host monitor layout.
--
-- In full-screen "Use Multiple Monitors" mode the guest tools push the host
-- layout into vmwgfx. The kernel marks one Virtual-N connector per host monitor
-- connected, makes that monitor's size the connector's preferred mode and
-- exposes the host offset as the DRM "suggested X"/"suggested Y" connector
-- properties. VMware's absolute pointer reports coordinates in that topology,
-- so the guest layout has to match it exactly, or the cursor lands on the
-- wrong output, or on none: the only output parked at x=3840 while the pointer
-- maps into 0..1920 is a desktop that has stopped answering input.
--
-- Hyprland ignores the offsets (position = "auto" places outputs left to right
-- in connector order), aquamarine re-probes the modes of only the connector
-- that hotplugged, a push that adds no connector (a window resize, a removal
-- that moves the survivors, leaving full screen) raises no Lua event at all,
-- and a reload puts the catch-all rule back. So the kernel's layout is read
-- through omarchy-hyprland-monitor-vmwgfx-layout and each output pinned to it
-- by a named rule, which beats the output = "" catch-all whatever the order.
--
-- The read is a fork. It runs here, at config load, and from hyprctl eval when
-- omarchy-hyprland-monitor-vmwgfx-sync sees a DRM hotplug: 1.5 s and 250 ms
-- budgets. An event or timer callback gets 50 ms, which a fork can overrun,
-- and the watchdog then aborts the callback before the rules are written.
--
-- omarchy_vmwgfx_layout = false in hyprland.lua leaves the outputs alone.

if _G.omarchy_vmwgfx_layout == false then
  return
end

local layout_helper = paths.omarchy_path .. "/bin/omarchy-hyprland-monitor-vmwgfx-layout"

-- A reload throws the Lua state away, timers and subscriptions included, and
-- runs this file again from scratch. So nothing here survives a reload: the
-- topology VMware has been shown is forgotten, and a blink in flight is cut
-- short. The forgotten topology costs one missed blink, which the next push
-- makes good; the interrupted blink would leave the screens off, so it is
-- marked by a file that outlives the state.
o.vmwgfx_layout = { shown = nil }
local state = o.vmwgfx_layout

-- Per compositor instance: two Hyprland sessions for one user share a runtime
-- directory, and one must not clear or trip the other's marker.
local blink_marker = (os.getenv("XDG_RUNTIME_DIR") or paths.state_home)
  .. "/omarchy-vmwgfx-blink"
  .. (os.getenv("HYPRLAND_INSTANCE_SIGNATURE") and ("-" .. os.getenv("HYPRLAND_INSTANCE_SIGNATURE")) or "")

local function mark_blink(active)
  if active then
    local file = io.open(blink_marker, "w")
    if file then
      file:close()
    end
  else
    os.remove(blink_marker)
  end
end

local function blink_interrupted()
  local file = io.open(blink_marker, "r")
  if not file then
    return false
  end
  file:close()
  return true
end

-- Only a plain connector name goes into a rule: the check every bin/ script
-- applies before writing a monitor name into Lua, applied again here.
local function plain_name(name)
  return name:match("^[A-Za-z0-9._%-]+$") ~= nil
end

local function read_host_layout()
  local layout = {}
  local pipe = io.popen(o.shell_quote(layout_helper) .. " 2>/dev/null")
  if not pipe then
    return layout
  end

  for line in pipe:lines() do
    local name, x, y, width, height = line:match("^(%S+) (%d+) (%d+) (%d+)x(%d+)$")
    if name and plain_name(name) then
      layout[name] = { x = tonumber(x), y = tonumber(y), width = tonumber(width), height = tonumber(height) }
    end
  end
  pipe:close()

  return layout
end

local function sorted_names(layout)
  local names = {}
  for name in pairs(layout) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

-- Scale 1 is deliberate: the virtual display reports 0 mm, which "auto" reads
-- as an impossibly dense panel and answers with 2x, and host offsets are
-- physical pixels. A rule of the user's own for the same output merges over
-- this one, so a transform or vrr set there survives; mode, position and
-- scale are the host's.
local function pin(layout, names)
  for _, name in ipairs(names) do
    local output = layout[name]
    hl.monitor({
      output = name,
      mode = output.width .. "x" .. output.height,
      position = output.x .. "x" .. output.y,
      scale = 1,
    })
  end
end

-- The topology is the set of outputs and their offsets. Sizes are left out so
-- a resize of the VMware window, which changes one mode and nothing else, is
-- not taken for a rearrangement.
local function topology_of(layout, names)
  local parts = {}
  for _, name in ipairs(names) do
    table.insert(parts, name .. "@" .. layout[name].x .. "," .. layout[name].y)
  end
  return table.concat(parts, " ")
end

local function dpms(status)
  for _, monitor in ipairs(hl.get_monitors()) do
    -- A monitor handle whose output has gone away answers nil to every field,
    -- and a topology change is exactly when that happens.
    local name = monitor.name
    if name then
      hl.dispatch(hl.dsp.dpms({ action = status, monitor = name }))
    end
  end
end

-- VMware only spans its host monitors once it has seen the guest redefine its
-- screens some time after the push (vmware/open-vm-tools#805); until then it
-- logs "guestScreens not congruent with hostScreens" and presents the whole
-- desktop on one monitor with scrollbars. A DPMS off/on is the modeset that
-- redefines them. A push during the blink can swallow the "on" and leave the
-- screens dark until a key press, so it is repeated, each time for whatever
-- outputs exist by then.
local ON_RETRIES = { 250, 1200, 2500 }

-- A second blink can start while these are still pending. Only the newest set
-- of retries may clear the marker; an older set finishing in the middle of a
-- newer blink would leave a reload with nothing to recover from.
local blink_generation = 0

local function retry_on()
  blink_generation = blink_generation + 1
  local generation = blink_generation

  for index, delay in ipairs(ON_RETRIES) do
    hl.timer(function()
      dpms("enable")
      if index == #ON_RETRIES and generation == blink_generation then
        mark_blink(false)
      end
    end, { timeout = delay, type = "oneshot" })
  end
end

local function blink()
  mark_blink(true)
  dpms("disable")
  retry_on()
end

-- The topology a scheduled blink will show, or nil while none is scheduled.
-- Pushes inside the settle window replace it rather than queue another blink.
local pending = nil

local function nudge(layout, names)
  if #names == 0 then
    return
  end

  local topology = topology_of(layout, names)
  if topology == state.shown then
    return
  end

  -- The outputs' own modesets show the first layout, and a single screen has
  -- nothing to be incongruent with.
  if state.shown == nil or #names < 2 then
    state.shown = topology
    return
  end

  if pending then
    pending = topology
    return
  end

  pending = topology
  hl.timer(function()
    state.shown = pending
    pending = nil
    blink()
  end, { timeout = 800, type = "oneshot" })
end

-- What omarchy-hyprland-monitor-vmwgfx-sync runs through hyprctl eval.
function state.sync()
  local layout = read_host_layout()
  local names = sorted_names(layout)
  pin(layout, names)
  nudge(layout, names)
end

-- A reload that lands mid-blink cancels the timers that would have turned the
-- screens back on, so the marker left by that blink re-arms them. Reading the
-- outputs' own dpms state instead would also catch a lock screen or idle
-- blanking the displays and turn them back on. A reload inside the 800 ms
-- settle window loses that one pending blink; the topology is then treated as
-- the first layout seen, and the next push blinks as usual.

-- Rules are cleared by a reload, and on a reload Hyprland applies what it has
-- before config.reloaded is emitted, so the pins are declared twice: here, to
-- be in the rule set for that pass, and again from config.reloaded, which is
-- the one that lands after the user's monitors.lua has had its say. The layout
-- was read above; the handler has 50 ms and does not fork.
local layout = read_host_layout()
local names = sorted_names(layout)

pin(layout, names)

hl.on("config.reloaded", function()
  pin(layout, names)
  nudge(layout, names)
  if blink_interrupted() then
    retry_on()
  end
end)

hl.on("hyprland.start", function()
  hl.exec_cmd(o.launch("omarchy-hyprland-monitor-vmwgfx-sync"))
end)
