#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# A scratch OMARCHY_PATH: the real default/ tree next to a bin/ of stubs, so
# the module under test forks the stubs by the path it computes itself.
mkdir -p "$tmp_dir/root/bin"
ln -s "$ROOT/default" "$tmp_dir/root/default"

cat >"$tmp_dir/root/bin/omarchy-hw-vmware" <<'EOF'
#!/bin/bash
exit "${OMARCHY_TEST_VMWARE:-1}"
EOF

cat >"$tmp_dir/root/bin/omarchy-hyprland-monitor-vmware-layout" <<'EOF'
#!/bin/bash
echo "layout" >>"$OMARCHY_TEST_FORK_LOG"
cat "$OMARCHY_TEST_LAYOUT"
EOF

chmod +x "$tmp_dir/root/bin/"*

# The mocked hl records every call and runs nothing on its own; timers fire
# only when a scenario asks for them, so each step's effect can be asserted.
cat >"$tmp_dir/mock.lua" <<'EOF'
rules, dispatches, handlers, timers, envs, execs, monitors = {}, {}, {}, {}, {}, {}, {}

hl = {
  dsp = {
    dpms = function(options)
      -- Hyprland reads the action, not a state, so a module that sends the
      -- wrong key would toggle instead and could not pass this.
      return { kind = "dpms", action = options.action, monitor = options.monitor }
    end,
    exec_cmd = function(command)
      return { kind = "exec", command = command }
    end,
  },
  monitor = function(rule)
    table.insert(rules, rule)
  end,
  dispatch = function(dispatcher)
    table.insert(dispatches, dispatcher)
  end,
  on = function(event, callback)
    handlers[event] = handlers[event] or {}
    table.insert(handlers[event], callback)
  end,
  timer = function(callback, options)
    table.insert(timers, { callback = callback, timeout = options.timeout, type = options.type })
  end,
  get_monitors = function()
    return monitors
  end,
  env = function(name, value)
    table.insert(envs, name .. "=" .. value)
  end,
  exec_cmd = function(command)
    table.insert(execs, command)
  end,
}

function fire(event)
  for _, callback in ipairs(handlers[event] or {}) do
    callback()
  end
end

function handler_count(event)
  return #(handlers[event] or {})
end

-- Runs and removes the timers due at the given timeout, or all of them.
-- Timers a callback schedules are appended and left for a later call.
function run_timers(timeout)
  local due, rest = {}, {}
  for _, timer in ipairs(timers) do
    if timeout == nil or timer.timeout == timeout then
      table.insert(due, timer)
    else
      table.insert(rest, timer)
    end
  end
  timers = rest
  for _, timer in ipairs(due) do
    timer.callback()
  end
end

function timeouts()
  local list = {}
  for _, timer in ipairs(timers) do
    table.insert(list, timer.timeout)
  end
  table.sort(list)
  local parts = {}
  for _, timeout in ipairs(list) do
    table.insert(parts, tostring(timeout))
  end
  return table.concat(parts, " ")
end

function reset_recording()
  rules, dispatches, timers, envs, execs = {}, {}, {}, {}, {}
end

-- What Hyprland does on a reload: the whole Lua state is thrown away (timers,
-- subscriptions, and o with it) and the config runs again from the top.
function load_config()
  handlers = {}
  o = nil
  reset_recording()
  dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
  require("default.hypr.helpers")
  require("default.hypr.vmware")
end

function set_layout(text)
  local file = assert(io.open(os.getenv("OMARCHY_TEST_LAYOUT"), "w"))
  file:write(text)
  file:close()
end

function forks()
  local file = io.open(os.getenv("OMARCHY_TEST_FORK_LOG"), "r")
  if not file then
    return 0
  end
  local count = 0
  for _ in file:lines() do
    count = count + 1
  end
  file:close()
  return count
end

function rule_lines()
  local lines = {}
  for _, rule in ipairs(rules) do
    table.insert(lines, rule.output .. " " .. rule.mode .. " " .. rule.position .. " " .. tostring(rule.scale))
  end
  return table.concat(lines, "\n")
end

function dpms_calls(status)
  local names = {}
  for _, dispatcher in ipairs(dispatches) do
    if dispatcher.kind == "dpms" and dispatcher.action == status then
      table.insert(names, dispatcher.monitor)
    end
  end
  return table.concat(names, " ")
end

-- A monitor handle whose output has gone away: nil for every field.
function expired_monitor()
  return setmetatable({}, { __index = function() return nil end })
end

function check(condition, description, detail)
  if condition then
    print("ok - " .. description)
  else
    if detail ~= nil then
      io.stderr:write(tostring(detail) .. "\n")
    end
    io.stderr:write("not ok - " .. description .. "\n")
    os.exit(1)
  end
end

function check_equal(actual, expected, description)
  check(actual == expected, description, "expected: " .. tostring(expected) .. "\nactual:   " .. tostring(actual))
end
EOF

# Runs one scenario in a fresh Lua state under the mock, with the detector
# exiting as given (0 is a VMware guest). The scenario prints its own ok
# lines; any failure inside it fails this file.
run_scenario() {
  local name="$1"
  local detector_status="${2:-0}"

  rm -f "$tmp_dir/forks.log"
  : >"$tmp_dir/layout.txt"

  local body
  body=$(cat)

  HOME="$tmp_dir" OMARCHY_PATH="$tmp_dir/root" OMARCHY_TEST_VMWARE="$detector_status" OMARCHY_TEST_FORK_LOG="$tmp_dir/forks.log" OMARCHY_TEST_LAYOUT="$tmp_dir/layout.txt" \
    lua - <<LUA || fail "$name"
dofile("$tmp_dir/mock.lua")
$body
LUA
}

run_scenario "a machine that is not a VMware guest" 1 <<'LUA'
load_config()
check_equal(forks(), 0, "a non-VMware machine does not read the host layout")
check_equal(handler_count("config.reloaded") + handler_count("hyprland.start"), 0, "a non-VMware machine registers no handlers")
check_equal(#rules + #timers, 0, "a non-VMware machine writes no rules and sets no timers")
check_equal(o.vmware_layout, nil, "a non-VMware machine leaves o.vmware_layout unset")
LUA

run_scenario "omarchy_vmware_layout = false" <<'LUA'
omarchy_vmware_layout = false
set_layout("Virtual-1 0 0 1920x1080\n")
load_config()
check_equal(forks(), 0, "omarchy_vmware_layout = false does not read the host layout")
check_equal(handler_count("config.reloaded"), 0, "omarchy_vmware_layout = false registers no config.reloaded handler")
fire("hyprland.start")
check_equal(table.concat(envs, " "), "LIBGL_ALWAYS_SOFTWARE=1", "omarchy_vmware_layout = false still sets LIBGL_ALWAYS_SOFTWARE on start")
check_equal(#execs, 0, "omarchy_vmware_layout = false does not launch the sync daemon")
check_equal(o.vmware_layout, nil, "omarchy_vmware_layout = false leaves o.vmware_layout unset")
LUA

run_scenario "a VMware guest with two host monitors" <<'LUA'
set_layout("Virtual-1 1920 0 1920x1080\nVirtual-2 0 0 1920x1080\n")
load_config()
check_equal(forks(), 1, "config load reads the host layout once")
check_equal(#rules, 0, "config load writes no rules before config.reloaded")
check_equal(#timers, 0, "config load sets no timers")

fire("config.reloaded")
check_equal(rule_lines(), "Virtual-1 1920x1080 1920x0 1\nVirtual-2 1920x1080 0x0 1", "config.reloaded pins each output to the host offset at scale 1")
check_equal(forks(), 1, "config.reloaded does not fork")
check_equal(#timers + #dispatches, 0, "the first layout is shown without a blink")
check_equal(o.vmware_layout.shown, "Virtual-1@1920,0 Virtual-2@0,0", "the first layout is recorded as shown")

fire("hyprland.start")
check_equal(#execs, 1, "hyprland.start launches one command")
check(execs[1]:find("omarchy-hyprland-monitor-vmware-sync", 1, true) and execs[1]:find("uwsm-app -- ", 1, true), "hyprland.start launches the sync daemon through uwsm-app", execs[1])
check_equal(table.concat(envs, " "), "LIBGL_ALWAYS_SOFTWARE=1", "hyprland.start still sets LIBGL_ALWAYS_SOFTWARE")

-- A window resize changes one mode and nothing else.
reset_recording()
set_layout("Virtual-1 1920 0 1600x900\nVirtual-2 0 0 1920x1080\n")
o.vmware_layout.sync()
check_equal(forks(), 2, "sync reads the host layout")
check_equal(rule_lines(), "Virtual-1 1600x900 1920x0 1\nVirtual-2 1920x1080 0x0 1", "sync re-pins the resized output")
check_equal(#timers, 0, "a resize schedules no blink")

-- The host monitors swap places.
reset_recording()
set_layout("Virtual-1 0 0 1600x900\nVirtual-2 1600 0 1920x1080\n")
o.vmware_layout.sync()
check_equal(rule_lines(), "Virtual-1 1600x900 0x0 1\nVirtual-2 1920x1080 1600x0 1", "sync re-pins the rearranged outputs")
check_equal(timeouts(), "800", "a rearrangement schedules one 800 ms blink")
check_equal(o.vmware_layout.shown, "Virtual-1@1920,0 Virtual-2@0,0", "the shown topology waits for the blink")

-- Another push inside the settle window.
set_layout("Virtual-1 0 0 1600x900\nVirtual-2 1600 100 1920x1080\n")
o.vmware_layout.sync()
check_equal(timeouts(), "800", "a push inside the settle window coalesces into the pending blink")

monitors = { { name = "Virtual-1" }, expired_monitor(), { name = "Virtual-2" } }
run_timers(800)
check_equal(dpms_calls("disable"), "Virtual-1 Virtual-2", "the blink turns off the live outputs and skips expired handles")
check_equal(o.vmware_layout.blinking, true, "the blink is recorded on o")
check_equal(o.vmware_layout.shown, "Virtual-1@0,0 Virtual-2@1600,100", "the blink shows the latest topology")
check_equal(timeouts(), "250 1200 2500", "the blink schedules three on retries")

table.insert(monitors, { name = "Virtual-3" })
run_timers(250)
check_equal(dpms_calls("enable"), "Virtual-1 Virtual-2 Virtual-3", "an output that appears during the blink is turned on too")
check_equal(o.vmware_layout.blinking, true, "the blink continues until the last retry")
run_timers(1200)
run_timers(2500)
check_equal(#timers, 0, "no timers remain after the retries")
check_equal(o.vmware_layout.blinking, false, "the blink ends after the last retry")

-- A reload while the screens are off: the state that knew about the blink is
-- gone, but the outputs still report dpms off, and that is what re-arms it.
monitors = { { name = "Virtual-1", dpms_status = false }, { name = "Virtual-2", dpms_status = true } }
load_config()
check_equal(o.vmware_layout.blinking, false, "a reload starts from a fresh state")
fire("config.reloaded")
check_equal(timeouts(), "250 1200 2500", "a reload mid-blink re-arms the on retries from the outputs' dpms state")
check_equal(rule_lines(), "Virtual-1 1600x900 0x0 1\nVirtual-2 1920x1080 1600x100 1", "a reload mid-blink pins the current layout")
run_timers()
check_equal(dpms_calls("enable"), "Virtual-1 Virtual-2 Virtual-1 Virtual-2 Virtual-1 Virtual-2", "the re-armed retries turn every output on")
check_equal(o.vmware_layout.blinking, false, "the re-armed retries end the blink")

-- A reload with all screens on re-arms nothing.
monitors = { { name = "Virtual-1", dpms_status = true }, { name = "Virtual-2", dpms_status = true } }
load_config()
fire("config.reloaded")
check_equal(#timers, 0, "a reload with the screens on schedules no retries")

-- A reload inside the settle window: the pending blink is lost with the
-- state, and the topology the reload sees counts as the first one shown.
set_layout("Virtual-1 1600 0 1600x900\nVirtual-2 0 0 1920x1080\n")
o.vmware_layout.sync()
check_equal(timeouts(), "800", "a rearrangement before a reload schedules a blink")
load_config()
check_equal(#timers, 0, "a reload cancels the pending blink")
fire("config.reloaded")
check_equal(#timers, 0, "a reload during the settle window does not blink on its own")
check_equal(rule_lines(), "Virtual-1 1600x900 1600x0 1\nVirtual-2 1920x1080 0x0 1", "a reload during the settle window pins the current kernel layout")
check_equal(o.vmware_layout.shown, "Virtual-1@1600,0 Virtual-2@0,0", "the topology seen at reload counts as shown")
set_layout("Virtual-1 0 0 1600x900\nVirtual-2 1600 0 1920x1080\n")
o.vmware_layout.sync()
check_equal(timeouts(), "800", "the next push after such a reload blinks as usual")
run_timers()
LUA

run_scenario "a VMware guest with one host monitor" <<'LUA'
set_layout("Virtual-1 0 0 2560x1440\n")
load_config()
fire("config.reloaded")
check_equal(rule_lines(), "Virtual-1 2560x1440 0x0 1", "a single screen is pinned")
reset_recording()
set_layout("Virtual-1 100 100 2560x1440\n")
o.vmware_layout.sync()
check_equal(rule_lines(), "Virtual-1 2560x1440 100x100 1", "a single screen that moves is re-pinned")
check_equal(#timers + #dispatches, 0, "a single screen never blinks")
check_equal(o.vmware_layout.shown, "Virtual-1@100,100", "a single screen is recorded as shown")
LUA

run_scenario "a VMware guest whose helper prints nothing" <<'LUA'
set_layout("Virtual-1 0 0 1920x1080\nVirtual-2 1920 0 1920x1080\n")
load_config()
fire("config.reloaded")
reset_recording()
set_layout("")
o.vmware_layout.sync()
check_equal(#rules + #timers, 0, "empty helper output writes no rules and sets no timers")
check_equal(o.vmware_layout.shown, "Virtual-1@0,0 Virtual-2@1920,0", "empty helper output leaves the shown topology alone")
LUA

run_scenario "a VMware guest whose helper prints unsafe names" <<'LUA'
set_layout('Virtual-1 0 0 1920x1080\nVirtual-2")os.execute("calc")-- 1920 0 1920x1080\n../card1-eDP-1 3840 0 1920x1080\nVirtual-3 abc 0 1920x1080\n')
load_config()
fire("config.reloaded")
check_equal(rule_lines(), "Virtual-1 1920x1080 0x0 1", "only plain connector names with numeric offsets become rules")
LUA
