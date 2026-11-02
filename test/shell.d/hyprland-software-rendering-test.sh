#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The renderer names Hyprland itself counts as software since #16343.
ROOT="$ROOT" TEST_TMP="$test_tmp" python3 -I - <<'PY' || fail "the detector classifies renderers and DRM nodes as Hyprland does"
import importlib.machinery
import importlib.util
import os

path = os.environ["ROOT"] + "/bin/omarchy-hw-software-rendering"
loader = importlib.machinery.SourceFileLoader("hw_software_rendering", path)
spec = importlib.util.spec_from_loader(loader.name, loader)
detector = importlib.util.module_from_spec(spec)
loader.exec_module(detector)

for name in ("llvmpipe (LLVM 21.1.0, 128 bits)", "softpipe", "Software Rasterizer", "LLVMPIPE"):
    assert detector.is_software(name), name
for name in ("Apple M2 (G14G B1)", "AMD Radeon 780M (radeonsi, gfx1103_r1, LLVM 21.1.0, DRM 3.64)", "Mesa Intel(R) Graphics (LNL)", "virgl (Mesa Intel(R) Graphics (LNL))"):
    assert not detector.is_software(name), name

# A device's render node is where Hyprland renders; a display-only device
# leaves only its card node.
import tempfile

def fake_sysfs(cards):
    root = tempfile.mkdtemp(dir=os.environ["TEST_TMP"])
    for card, (boot_vga, render) in cards.items():
        os.makedirs(f"{root}/{card}/device/drm/{card}")
        if render:
            os.makedirs(f"{root}/{card}/device/drm/{render}")
        if boot_vga is not None:
            with open(f"{root}/{card}/device/boot_vga", "w") as f:
                f.write(f"{boot_vga}\n")
    return root

none = fake_sysfs({})
pick = lambda nodes, sysfs=none, environ={}: detector.pick_node(["/dev/dri/" + n for n in nodes], sysfs, environ)
assert pick(["card1", "renderD128"]) == "/dev/dri/renderD128"
assert pick(["card1", "card0"]) == "/dev/dri/card0"
assert pick(["card10", "card2"]) == "/dev/dri/card2", "cards sort by number"
assert pick(["renderD129", "renderD1280"]) == "/dev/dri/renderD129"
assert pick(["by-path"]) is None
assert pick([]) is None

# Two GPUs: the one firmware booted on renders, not the lowest-numbered one.
hybrid = fake_sysfs({"card0": (0, "renderD128"), "card1": (1, "renderD129")})
nodes = ["card0", "card1", "renderD128", "renderD129"]
assert pick(nodes, hybrid) == "/dev/dri/renderD129"
assert pick(nodes, hybrid, {"AQ_DRM_DEVICES": "/dev/dri/card0:/dev/dri/card1"}) == "/dev/dri/renderD128"

# Apple Silicon: a display-only apple-drm card and the GPU's own card, so the
# sole render node renders; with it unopenable, the display card does.
apple = fake_sysfs({"card1": (None, "renderD128"), "card2": (None, None)})
assert pick(["card1", "card2", "renderD128"], apple, {"AQ_DRM_DEVICES": "/dev/dri/card2"}) == "/dev/dri/renderD128"
assert pick(["card2"], apple, {"AQ_DRM_DEVICES": "/dev/dri/card2"}) == "/dev/dri/card2"
PY
pass "the detector classifies renderers and DRM nodes as Hyprland does"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-hw-software-rendering" <<'SH'
#!/bin/bash
# FAKE_STATUS lists the exit status of each probe in turn; the last repeats.
# Mesa's noise about unopenable devices comes along on stderr, as on a Mac.
printf 'probe\n' >>"$FAKE_LOG"
read -ra statuses <<<"$FAKE_STATUS"
calls=$(grep -c '^probe$' "$FAKE_LOG")
index=$(( calls <= ${#statuses[@]} ? calls - 1 : ${#statuses[@]} - 1 ))
echo "failed to open /dev/dri/renderD128: Permission denied" >&2
(( statuses[index] == 2 )) || printf '%s\n' "$FAKE_RENDERER"
exit "${statuses[index]}"
SH
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
printf 'sleep %s\n' "$*" >>"$FAKE_LOG"
SH
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$FAKE_LOG"
case $* in
  "-j getoption animations:enabled") value=$FAKE_ANIMATIONS ;;
  "-j getoption decoration:blur:enabled") value=${FAKE_BLUR:-false} ;;
  "-j getoption decoration:shadow:enabled") value=${FAKE_SHADOW:-false} ;;
  *) exit 0 ;;
esac
printf '{"option": "%s", "bool": %s, "set": true }\n' "${3:-}" "$value"
SH
cat >"$stub_bin/logger" <<'SH'
#!/bin/bash
printf 'logger %s\n' "$*" >>"$FAKE_LOG"
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$FAKE_LOG"
SH
# The notification server answers once the shell has called busctl
# FAKE_SERVER_AFTER times (0: at once; empty: never).
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl\n' >>"$FAKE_LOG"
[[ -n ${FAKE_SERVER_AFTER:-} ]] && (( $(grep -c '^busctl$' "$FAKE_LOG") > FAKE_SERVER_AFTER ))
SH
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin"/*

signature="test-signature"
runtime="$test_tmp/run"
marker="$runtime/hypr/$signature/omarchy-software-rendering"
log="$test_tmp/log"

run_session_start() {
  : >"$log"
  HOME="$test_tmp/home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$runtime" HYPRLAND_INSTANCE_SIGNATURE="$signature" FAKE_LOG="$log" \
    FAKE_STATUS="$1" FAKE_RENDERER="${2:-}" FAKE_ANIMATIONS="${3:-false}" FAKE_SERVER_AFTER="${4-0}" \
    "$ROOT/bin/omarchy-hyprland-software-rendering" 2>"$test_tmp/stderr"
  [[ ! -s $test_tmp/stderr ]] || fail "Mesa's complaints stay out of the session log" "$(cat "$test_tmp/stderr")"
}

reset_session() {
  rm -rf "$runtime"
  mkdir -p "$runtime/hypr/$signature"
}

reset_session
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
[[ $(cat "$marker") == "llvmpipe (LLVM 21.1.0, 128 bits)" ]] || fail "a CPU-rendered session is marked with its renderer"
grep -Fxq "hyprctl reload" "$log" || fail "marking the session reloads Hyprland" "$(cat "$log")"
grep -Fq "logger -t omarchy Hyprland renders on the CPU (llvmpipe (LLVM 21.1.0, 128 bits)), so animations" "$log" || fail "the journal says why animations are off" "$(cat "$log")"
grep -Fq "notify --app-name Software Rendering -g 󰘚 -u normal -t 30000 --transient Animations off without a GPU No GPU in use, so animations, blur and shadows are off." "$log" || fail "a notification says why animations are off" "$(cat "$log")"
pass "a session that renders on the CPU is marked, reloaded and explained"

run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
[[ ! -s $log ]] || fail "a marked session is not probed or announced again" "$(cat "$log")"
pass "a marked session is not probed or announced again"

reset_session
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" true
[[ -f $marker ]] || fail "a user override still leaves the session marked"
if grep -q "^notify" "$log"; then
  fail "no notification claims animations are off when the user turned them on" "$(cat "$log")"
fi
grep -Fq "keeping the animations ~/.config/hypr turns on" "$log" || fail "the journal records the user's override" "$(cat "$log")"
pass "a user who turns animations on is not told they are off"

reset_session
run_session_start 0 "llvmpipe (LLVM 23.1.4, 128 bits)" garbage
if grep -q "^notify\|keeping the animations" "$log"; then
  fail "an unreadable animations setting is neither announced nor logged as an override" "$(cat "$log")"
fi
grep -Fq "logger -t omarchy -p user.debug Hyprland renders on the CPU (llvmpipe (LLVM 23.1.4, 128 bits)), but its animations, blur or shadows setting couldn't be read" "$log" ||
  fail "an unreadable animations setting is logged as such" "$(cat "$log")"
pass "an unreadable animations setting after the reload is logged, not guessed"

# Blur kept on in looknfeel.lua: no notice claiming it is off, and the journal
# names exactly what the user kept.
reset_session
: >"$log"
HOME="$test_tmp/home" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  XDG_RUNTIME_DIR="$runtime" HYPRLAND_INSTANCE_SIGNATURE="$signature" FAKE_LOG="$log" \
  FAKE_STATUS=0 FAKE_RENDERER="llvmpipe (LLVM 23.1.4, 128 bits)" FAKE_ANIMATIONS=false FAKE_BLUR=true FAKE_SERVER_AFTER=0 \
  "$ROOT/bin/omarchy-hyprland-software-rendering" 2>/dev/null
if grep -q "^notify" "$log"; then
  fail "no notice claims blur is off when the user kept it on" "$(cat "$log")"
fi
grep -Fq "keeping the blur ~/.config/hypr turns on" "$log" || fail "the journal names the setting the user kept" "$(cat "$log")"
pass "a user who keeps blur on is not told it is off"

# The shell that serves notifications can come up after the session is
# marked; the notice waits for it rather than being lost.
reset_session
run_session_start 0 "llvmpipe (LLVM 23.1.4, 128 bits)" false 5
(( $(grep -c '^busctl$' "$log") == 6 )) || fail "the notice waits for the notification server" "$(cat "$log")"
grep -q "^notify --app-name Software Rendering -g 󰘚 -u normal -t 30000 --transient Animations off without a GPU" "$log" || fail "the notice is sent once the server is up" "$(cat "$log")"
(( $(grep -n '^hyprctl reload$' "$log" | cut -d: -f1) < $(grep -n '^busctl$' "$log" | head -1 | cut -d: -f1) )) ||
  fail "the reload doesn't wait for the notification server" "$(cat "$log")"
pass "a slow notification server still gets the notice, after the reload"

reset_session
run_session_start 0 "llvmpipe (LLVM 23.1.4, 128 bits)" false ""
[[ -f $marker ]] || fail "a missing notification server still leaves the session marked"
if grep -q "^notify" "$log"; then
  fail "no notice is sent without a notification server" "$(cat "$log")"
fi
(( $(grep -c '^busctl$' "$log") == 150 )) || fail "the wait for the notification server is bounded to 15s" "$(grep -c '^busctl$' "$log")"
grep -Fq "logger -t omarchy -p user.debug No notification server after 15s" "$log" || fail "a skipped notice is logged" "$(cat "$log")"
pass "without a notification server the notice is skipped and logged"

# At Hyprland start the probe can't tell yet (no lock file, no DRM device
# open), so the script keeps asking for a while.
reset_session
run_session_start "2 2 0" "llvmpipe (LLVM 23.1.4, 128 bits)" false
(( $(grep -c '^probe$' "$log") == 3 )) || fail "a probe that can't tell yet is asked again" "$(cat "$log")"
[[ $(cat "$marker") == "llvmpipe (LLVM 23.1.4, 128 bits)" ]] || fail "a late answer still marks the session" "$(cat "$log")"
grep -Fxq "hyprctl reload" "$log" || fail "a late answer still reloads Hyprland" "$(cat "$log")"
pass "a probe that can't tell at start is retried until it can"

reset_session
run_session_start 2
(( $(grep -c '^probe$' "$log") == 20 )) || fail "the probe is retried for a bounded time" "$(cat "$log")"
(( $(grep -c '^sleep 0.5$' "$log") == 20 )) || fail "retries wait between probes" "$(cat "$log")"
grep -Fq "logger -t omarchy -p user.debug Couldn't read Hyprland's GL renderer after 20 tries" "$log" || fail "giving up is logged" "$(cat "$log")"
pass "a probe that never answers is given up on after 10s, with a log line"

for status in 1 2; do
  reset_session
  run_session_start "$status" "Apple M2 (G14G B1)"
  [[ ! -e $marker ]] || fail "a session without a CPU renderer is not marked" "status $status"
  if grep -q "^hyprctl\|^notify" "$log"; then
    fail "a session without a CPU renderer is left alone" "$(cat "$log")"
  fi
done
grep -Fq "Couldn't read Hyprland's GL renderer" "$log" || fail "an unreadable renderer is logged" "$(cat "$log")"
pass "a GPU or unreadable renderer leaves the session alone"

# Replays the order hyprland.lua loads things in: Omarchy's defaults, the
# software-rendering defaults, the user's looknfeel.lua, then the saved
# toggles. Prints the final animations and blur settings.
run_config() {
  XDG_RUNTIME_DIR="$runtime" HYPRLAND_INSTANCE_SIGNATURE="$signature" OMARCHY_PATH="$ROOT" \
    USER_CONFIG="${1:-}" TOGGLE="${2:-}" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local values = {}
local function merge(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" and next(value) ~= nil and #value == 0 then
      target[key] = type(target[key]) == "table" and target[key] or {}
      merge(target[key], value)
    else
      target[key] = value
    end
  end
end
hl = setmetatable({
  config = function(config) merge(values, config) end,
  get_config = function(key)
    local value = values
    for part in key:gmatch("[^.]+") do
      value = type(value) == "table" and value[part] or nil
    end
    return value
  end,
}, { __index = function() return function() end end })

require("default.hypr.helpers")
hl.config({ animations = { enabled = true }, decoration = { blur = { enabled = false }, shadow = { enabled = false } } })
require("default.hypr.software-rendering")
if os.getenv("USER_CONFIG") ~= "" then
  assert(load(os.getenv("USER_CONFIG")))()
end
if os.getenv("TOGGLE") ~= "" then
  dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/toggles/" .. os.getenv("TOGGLE") .. ".lua")
end
print(string.format("animations=%s blur=%s shadow=%s", tostring(values.animations.enabled),
  tostring(values.decoration.blur.enabled), tostring(values.decoration.shadow.enabled)))
LUA
}

expect_config() {
  local expected="$1" description="$2" output
  shift 2
  output=$(run_config "$@")
  [[ $output == "$expected" ]] || fail "$description" "$output"
}

user_animations='hl.config({ animations = { enabled = true } })'
user_blur='hl.config({ decoration = { blur = { enabled = true } } })'

reset_session
expect_config "animations=true blur=false shadow=false" "a GPU session keeps Omarchy's defaults"
expect_config "animations=true blur=true shadow=false" "a GPU session keeps the Glassy bar's blur" "" bar-glassy
expect_config "animations=true blur=true shadow=false" "a GPU session keeps Glassy windows' blur" "" window-glassy
pass "a GPU session is unchanged, Glassy toggles included"

printf 'llvmpipe\n' >"$marker"
expect_config "animations=false blur=false shadow=false" "a CPU session turns off animations, blur and shadows"
expect_config "animations=false blur=false shadow=false" "a CPU session turns off the Glassy bar's blur" "" bar-glassy
expect_config "animations=false blur=false shadow=false" "a CPU session turns off Glassy windows' blur" "" window-glassy
pass "a CPU session turns off animations, blur and shadows, Glassy toggles included"

expect_config "animations=true blur=false shadow=false" "the user's looknfeel.lua can turn animations back on" "$user_animations"
expect_config "animations=false blur=true shadow=false" "the user's looknfeel.lua can turn blur back on" "$user_blur"
expect_config "animations=false blur=true shadow=false" "blur from the user's looknfeel.lua survives the Glassy bar" "$user_blur" bar-glassy
pass "the user's looknfeel.lua still wins in a CPU session"

# The lighter defaults must land over the theme and under ~/.config/hypr.
order=$(OMARCHY_PATH="$ROOT" lua - <<'LUA'
local loaded = {}
local real_require = require
require = function(name)
  table.insert(loaded, name)
  if name == "default.hypr.require_optional" then
    return { module = function(module) table.insert(loaded, module) end }
  end
  return {}
end
dofile = function() end
loadfile(os.getenv("OMARCHY_PATH") .. "/config/hypr/hyprland.lua")()
loadfile(os.getenv("OMARCHY_PATH") .. "/default/hypr/omarchy.lua")()
print(table.concat(loaded, " "))
LUA
)
position() {
  local words=($order) index
  for index in "${!words[@]}"; do
    [[ ${words[$index]} == "$1" ]] && { echo "$index"; return; }
  done
  echo -1
}
theme=$(position omarchy.current.theme.hyprland)
software=$(position default.hypr.software-rendering)
omarchy=$(position default.hypr.omarchy)
user=$(position hypr.looknfeel)
(( omarchy >= 0 && user > omarchy )) || fail "hyprland.lua loads Omarchy's defaults before the user's looknfeel.lua" "$order"
(( theme >= 0 && software > theme )) || fail "the software-rendering defaults load after the theme" "$order"
toggles=$(position default.hypr.toggles)
(( toggles > user )) || fail "the saved toggles load after the user's looknfeel.lua" "$order"
pass "the software-rendering defaults load over the theme and under user config"
