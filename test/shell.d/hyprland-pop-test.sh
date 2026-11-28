#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/run/omarchy/windows/test-sig"

OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_tmp/run" HYPRLAND_INSTANCE_SIGNATURE="test-sig" TEST_RUNTIME_DIR="$test_tmp/run" lua - <<'LUA' || fail "a popped-out window is centered again on the monitor it moves to"
local handlers, timers, centered = {}, {}, {}

hl = {
  on = function(event, callback) handlers[event] = callback end,
  timer = function(callback, opts) table.insert(timers, { run = callback, opts = opts }) end,
  dispatch = function(dispatcher) table.insert(centered, dispatcher.window) end,
  dsp = { window = { center = function(args) return args end } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.pop")

local left, right = { id = 0 }, { id = 1 }

local function move(tags, from, to)
  timers, centered = {}, {}
  handlers["window.move_to_workspace"]({ address = "0xabc", tags = tags, monitor = from }, { monitor = to })
  for _, timer in ipairs(timers) do timer.run() end
  return centered
end

local moved = move({ "pop" }, left, right)
assert(#moved == 1 and moved[1] == "address:0xabc", "a popped window moved to another monitor is centered there")

-- Centering in the event itself would measure the monitor it is leaving.
timers, centered = {}, {}
handlers["window.move_to_workspace"]({ address = "0xabc", tags = { "pop" }, monitor = left }, { monitor = right })
assert(#centered == 0, "nothing is centered while the move is still in flight")
assert(#timers == 1 and timers[1].opts.type == "oneshot" and timers[1].opts.timeout > 0, "the center waits until the move has landed")

assert(#move({ "pop" }, left, left) == 0, "a move between workspaces on the same monitor keeps where it was put")
assert(#move({ "default-opacity*" }, left, right) == 0, "a window that was not popped out is left alone")
assert(#move({ "pop" }, left, nil) == 0, "a workspace without a monitor is not measured")

-- Closing a popped floating window removes its session geometry file.
local runtime_dir = os.getenv("TEST_RUNTIME_DIR")
local geom_dir = runtime_dir .. "/omarchy/windows/test-sig"
local geom_path = geom_dir .. "/pop-0xdead-geometry"
local f = assert(io.open(geom_path, "w"))
f:write("640 480 100 120\n")
f:close()
handlers["window.destroy"]({ address = "0xdead" })
assert(io.open(geom_path, "r") == nil, "closing a window cleans up its saved pop geometry")
LUA
pass "a popped-out window is centered again on the monitor it moves to and cleaned up on close"

env -u XDG_RUNTIME_DIR OMARCHY_PATH="$ROOT" HYPRLAND_INSTANCE_SIGNATURE="test-sig" lua - <<'LUA' || fail "window.destroy is a safe no-op without XDG_RUNTIME_DIR"
local handlers = {}
hl = { on = function(event, callback) handlers[event] = callback end }
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.pop")
handlers["window.destroy"]({ address = "0xdead" })
LUA
pass "window.destroy is a safe no-op without XDG_RUNTIME_DIR"

rm -rf "$test_tmp/run/omarchy"

cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  cat "$FAKE_ACTIVE_WINDOW"
  exit 0
fi

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  cat "$FAKE_MONITORS"
  exit 0
fi

if [[ $1 == "--batch" ]]; then
  printf '%s\n' "$2" >>"$FAKE_DISPATCH_LOG"
  IFS=';' read -ra cmds <<<"$2"
  for _ in "${cmds[@]}"; do printf 'ok\n\n\n'; done
  exit 0
fi

if [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$2" >>"$FAKE_DISPATCH_LOG"
  exit 0
fi

exit 1
SH
chmod +x "$test_tmp/bin/hyprctl"

cat >"$test_tmp/monitors.json" <<'JSON'
[
  { "id": 0, "x": 0, "y": 0, "width": 2560, "height": 1440, "scale": 1, "transform": 0, "reserved": [0, 30, 0, 0] },
  { "id": 1, "x": 2560, "y": 0, "width": 1920, "height": 1080, "scale": 1, "transform": 0, "reserved": [0, 30, 0, 0] }
]
JSON

run_pop() {
  printf '%s\n' "$1" >"$test_tmp/active.json"
  : >"$test_tmp/dispatch.log"
  XDG_RUNTIME_DIR="${2-$test_tmp/run}" \
    HYPRLAND_INSTANCE_SIGNATURE="test-sig" \
    FAKE_ACTIVE_WINDOW="$test_tmp/active.json" \
    FAKE_MONITORS="${FAKE_MONITORS:-$test_tmp/monitors.json}" \
    FAKE_DISPATCH_LOG="$test_tmp/dispatch.log" \
    PATH="$test_tmp/bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-window-pop"
}

geom_file="$test_tmp/run/omarchy/windows/test-sig/pop-0x111-geometry"

# 1. Floating window pop/unpop round trip on the same monitor restores size, position, and floating state.
run_pop '{"address":"0x111","pinned":false,"floating":true,"monitor":0,"size":[720,540],"at":[140,180]}'
[[ -f $geom_file ]] || fail "popping a floating window saves geometry in the session runtime dir"
if grep -Fq 'hl.dsp.window.float(' "$test_tmp/dispatch.log"; then
  fail "popping an already floating window leaves it floating" "$(<"$test_tmp/dispatch.log")"
fi

run_pop '{"address":"0x111","pinned":true,"floating":true,"monitor":0,"size":[1300,900],"at":[630,270]}'
[[ ! -e $geom_file ]] || fail "unpopping removes the saved geometry file"
grep -Fq 'hl.dsp.window.resize({ window = "address:0x111", x = 720, y = 540 })' "$test_tmp/dispatch.log" ||
  fail "unpopping restores original floating size" "$(<"$test_tmp/dispatch.log")"
grep -Fq 'hl.dsp.window.move({ window = "address:0x111", x = 140, y = 180 })' "$test_tmp/dispatch.log" ||
  fail "unpopping restores original floating position on same monitor" "$(<"$test_tmp/dispatch.log")"
if grep -Fq 'action = "off"' "$test_tmp/dispatch.log"; then
  fail "unpopping a previously floating window keeps it floating" "$(<"$test_tmp/dispatch.log")"
fi
pass "floating window pop/unpop round trip restores size, position, and floating state"

# 2. Popping on monitor 0, moving to monitor 1, and unpopping keeps the window on monitor 1.
run_pop '{"address":"0x111","pinned":false,"floating":true,"monitor":0,"size":[720,540],"at":[140,180]}'
run_pop '{"address":"0x111","pinned":true,"floating":true,"monitor":1,"size":[1300,900],"at":[2870,90]}'
grep -Fq 'hl.dsp.window.move({ window = "address:0x111", x = 2700, y = 180 })' "$test_tmp/dispatch.log" ||
  fail "unpopping on another monitor preserves offset within the destination monitor" "$(<"$test_tmp/dispatch.log")"

run_pop '{"address":"0x111","pinned":false,"floating":true,"monitor":0,"size":[720,540],"at":[2000,900]}'
run_pop '{"address":"0x111","pinned":true,"floating":true,"monitor":1,"size":[1300,900],"at":[2870,90]}'
grep -Fq 'hl.dsp.window.resize({ window = "address:0x111", x = 720, y = 540 })' "$test_tmp/dispatch.log" ||
  fail "unpopping on another monitor keeps original size when it fits" "$(<"$test_tmp/dispatch.log")"
# Offset (2000, 900) on monitor 1 (x=2560..4480, y=30..1080) clamps to x=2560+1920-720=3760, y=1080-540=540.
grep -Fq 'hl.dsp.window.move({ window = "address:0x111", x = 3760, y = 540 })' "$test_tmp/dispatch.log" ||
  fail "unpopping after a monitor move clamps to the destination monitor work area" "$(<"$test_tmp/dispatch.log")"
pass "unpopping after a monitor move keeps the window on the destination monitor"

# A monitor rescaled while the window was popped out no longer has room where the window used to sit.
run_pop '{"address":"0x111","pinned":false,"floating":true,"monitor":0,"size":[720,540],"at":[1500,700]}'
sed 's/"width": 2560, "height": 1440, "scale": 1/"width": 2560, "height": 1440, "scale": 2/' "$test_tmp/monitors.json" >"$test_tmp/rescaled.json"
FAKE_MONITORS="$test_tmp/rescaled.json" run_pop '{"address":"0x111","pinned":true,"floating":true,"monitor":0,"size":[1300,900],"at":[0,0]}'
grep -Fq 'hl.dsp.window.move({ window = "address:0x111", x = 560, y = 180 })' "$test_tmp/dispatch.log" ||
  fail "unpopping on a rescaled monitor keeps the window on it" "$(<"$test_tmp/dispatch.log")"
pass "unpopping on a rescaled monitor keeps the window on it"

# 3. Tiled window pop/unpop still returns to tiled.
run_pop '{"address":"0x222","pinned":false,"floating":false,"monitor":0,"size":[1200,800],"at":[10,40]}'
run_pop '{"address":"0x222","pinned":true,"floating":true,"monitor":0,"size":[1300,900],"at":[630,270]}'
grep -Fq 'hl.dsp.window.float({ window = "address:0x222", action = "off" })' "$test_tmp/dispatch.log" ||
  fail "unpopping a previously tiled window tiles it again" "$(<"$test_tmp/dispatch.log")"
pass "tiled window pop/unpop returns to tiled"

# 4. Without XDG_RUNTIME_DIR nothing is saved, and the window still pops out.
run_pop '{"address":"0x333","pinned":false,"floating":true,"monitor":0,"size":[720,540],"at":[140,180]}' ""
grep -Fq 'hl.dsp.window.tag({ window = "address:0x333", tag = "+pop" })' "$test_tmp/dispatch.log" ||
  fail "popping still succeeds when XDG_RUNTIME_DIR is unset" "$(<"$test_tmp/dispatch.log")"
pass "popping a floating window still works without XDG_RUNTIME_DIR"
