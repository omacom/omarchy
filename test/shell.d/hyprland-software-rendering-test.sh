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
assert pick(nodes, hybrid, {"AQ_DRM_DEVICES": "/dev/dri/missing:/dev/dri/card0"}) == "/dev/dri/renderD128", "a missing AQ_DRM_DEVICES entry is skipped"

# The laptop panel hangs off the GPU firmware didn't boot on: Aquamarine puts
# the GPU with the built-in panel first.
os.makedirs(f"{hybrid}/card0-eDP-1")
with open(f"{hybrid}/card0-eDP-1/status", "w") as f:
    f.write("connected\n")
assert pick(nodes, hybrid) == "/dev/dri/renderD128"

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
  rm -rf "$runtime" "$test_tmp/home"
  mkdir -p "$runtime/hypr/$signature"
}

reset_session
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
[[ $(cat "$marker") == "llvmpipe (LLVM 21.1.0, 128 bits)" ]] || fail "a CPU-rendered session is marked with its renderer"
grep -Fxq "hyprctl reload" "$log" || fail "marking the session reloads Hyprland" "$(cat "$log")"
grep -Fq "logger -t omarchy Hyprland renders on the CPU (llvmpipe (LLVM 21.1.0, 128 bits)), so animations" "$log" || fail "the journal says why animations are off" "$(cat "$log")"
grep -Fq "notify --app-name Software Rendering -g 󰘚 -u normal -t 30000 Animations off without a GPU No GPU in use, so animations, blur and shadows are off." "$log" || fail "a notification says why animations are off" "$(cat "$log")"
pass "a session that renders on the CPU is marked, reloaded and explained"

run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
[[ ! -s $log ]] || fail "a marked session is not probed or announced again" "$(cat "$log")"
pass "a marked session is not probed or announced again"

# The next login is a new session on the same machine: no second notice.
rm -rf "$runtime"
mkdir -p "$runtime/hypr/$signature"
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
grep -Fxq "hyprctl reload" "$log" || fail "a new session on the same machine still gets the lighter defaults" "$(cat "$log")"
if grep -q "^notify" "$log"; then
  fail "the notice shows once per machine" "$(cat "$log")"
fi
pass "the notice shows once per machine"

# A VM install already turned animations off with the toggle: no notice.
reset_session
mkdir -p "$test_tmp/home/.local/state/omarchy/toggles/hypr"
cp "$ROOT/default/hypr/toggles/no-animations.lua" "$test_tmp/home/.local/state/omarchy/toggles/hypr/"
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
if grep -q "^notify" "$log"; then
  fail "no notice where animations were already off by choice" "$(cat "$log")"
fi
pass "no notice where animations were already off by choice"

# Animations turned back on in Appearance: the session is marked, but nothing
# reloads and nothing is announced.
reset_session
mkdir -p "$test_tmp/home/.local/state/omarchy/toggles"
touch "$test_tmp/home/.local/state/omarchy/toggles/animations-without-gpu"
run_session_start 0 "llvmpipe (LLVM 21.1.0, 128 bits)" false
[[ -f $marker ]] || fail "a session with animations turned back on is still marked"
if grep -q "^hyprctl reload\|^notify" "$log"; then
  fail "animations turned back on in Appearance are left alone" "$(cat "$log")"
fi
pass "animations turned back on in Appearance are left alone"

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

# At Hyprland start the probe can't tell yet (no lock file, no DRM device
# open), so the script keeps asking for a while.
reset_session
run_session_start "2 2 0" "llvmpipe (LLVM 23.1.4, 128 bits)" false
(( $(grep -c '^probe$' "$log") == 3 )) || fail "a probe that can't tell yet is asked again" "$(cat "$log")"
[[ $(cat "$marker") == "llvmpipe (LLVM 23.1.4, 128 bits)" ]] || fail "a late answer still marks the session" "$(cat "$log")"
grep -Fxq "hyprctl reload" "$log" || fail "a late answer still reloads Hyprland" "$(cat "$log")"
pass "a probe that can't tell at start is retried until it can"

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
# software-rendering defaults, then a saved toggle. Prints the final
# animations, blur and shadow settings.
run_config() {
  HOME="$test_tmp/home" XDG_RUNTIME_DIR="$runtime" HYPRLAND_INSTANCE_SIGNATURE="$signature" OMARCHY_PATH="$ROOT" \
    TOGGLE="${1:-}" lua - <<'LUA'
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

reset_session
expect_config "animations=true blur=false shadow=false" "a GPU session keeps Omarchy's defaults"
expect_config "animations=true blur=true shadow=false" "a GPU session keeps the Glassy bar's blur" bar-glassy
expect_config "animations=true blur=true shadow=false" "a GPU session keeps Glassy windows' blur" window-glassy
pass "a GPU session is unchanged, Glassy toggles included"

printf 'llvmpipe\n' >"$marker"
expect_config "animations=false blur=false shadow=false" "a CPU session turns off animations, blur and shadows"
expect_config "animations=false blur=false shadow=false" "a CPU session turns off the Glassy bar's blur" bar-glassy
expect_config "animations=false blur=false shadow=false" "a CPU session turns off Glassy windows' blur" window-glassy
pass "a CPU session turns off animations, blur and shadows, Glassy toggles included"

mkdir -p "$test_tmp/home/.local/state/omarchy/toggles"
touch "$test_tmp/home/.local/state/omarchy/toggles/animations-without-gpu"
expect_config "animations=true blur=false shadow=false" "Appearance turns animations back on in a CPU session"
expect_config "animations=true blur=true shadow=false" "Appearance brings the Glassy bar's blur back in a CPU session" bar-glassy
pass "turning animations on in Appearance lifts the CPU session's defaults"
