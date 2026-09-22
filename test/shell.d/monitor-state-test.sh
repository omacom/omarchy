#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_bin=$(mktemp -d)
monitors_file=$(mktemp)

cleanup() {
  rm -rf "$test_bin"
  rm -f "$monitors_file"
}
trap cleanup EXIT

cat >"$test_bin/hyprctl" <<'EOF'
#!/bin/bash
[[ $* == "monitors all -j" ]] || exit 1
cat "$FAKE_MONITORS"
EOF

cat >"$test_bin/omarchy-brightness-display" <<'EOF'
#!/bin/bash
echo 42
EOF

cat >"$test_bin/omarchy-hyprland-monitor-scaling" <<'EOF'
#!/bin/bash
echo 1.5
EOF

chmod +x "$test_bin"/*

# The panel reads this output by line index, so every case has to answer with
# the same number of lines. A helper that dies mid-script drops its line and
# silently shifts every field below it into the wrong property.
state_lines=()
monitor_state() {
  printf '%s\n' "$1" >"$monitors_file"

  mapfile -t state_lines < <(
    FAKE_MONITORS="$monitors_file" PATH="$test_bin:$PATH" \
      bash "$ROOT/bin/omarchy-monitor-state" 2>/dev/null
  )
}

assert_line() {
  local index="$1" expected="$2" description="$3"

  [[ ${state_lines[index]-} == "$expected" ]] ||
    fail "$description" "line $index expected: $expected"$'\n'"line $index actual:   ${state_lines[index]-<missing>}"
}

assert_line_count() {
  local description="$1"

  (( ${#state_lines[@]} == 8 )) ||
    fail "$description" "expected 8 lines, got ${#state_lines[@]}"
}

extended='[
  { "name": "eDP-1", "mirrorOf": "none", "disabled": false, "focused": false, "width": 1920, "height": 1080 },
  { "name": "DP-1", "mirrorOf": "none", "disabled": false, "focused": true, "width": 2560, "height": 1440 }
]'

# Omarchy mirrors by pointing the external at the internal, so `mirrorOf` lands
# on the external and the internal keeps saying "none".
mirrored='[
  { "name": "eDP-1", "mirrorOf": "none", "disabled": false, "focused": true, "width": 1920, "height": 1080 },
  { "name": "DP-1", "mirrorOf": "eDP-1", "disabled": false, "focused": false, "width": 1920, "height": 1080 }
]'

# A monitors.lua of the user's own can mirror the other way instead.
reverse_mirrored='[
  { "name": "eDP-1", "mirrorOf": "DP-1", "disabled": false, "focused": false, "width": 2560, "height": 1440 },
  { "name": "DP-1", "mirrorOf": "none", "disabled": false, "focused": true, "width": 2560, "height": 1440 }
]'

clamshell='[
  { "name": "eDP-1", "description": "AU Optronics 0x1234", "make": "AU Optronics", "model": "0x1234", "availableModes": ["1920x1080@60.00Hz"], "mirrorOf": "none", "disabled": true, "focused": false, "width": 0, "height": 0 },
  { "name": "DP-1", "description": "Dell Inc. DELL U2720Q", "make": "Dell Inc.", "model": "DELL U2720Q", "availableModes": ["2560x1440@60.00Hz"], "mirrorOf": "none", "disabled": false, "focused": true, "width": 2560, "height": 1440 }
]'

ghost='[
  { "name": "eDP-1", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": false, "focused": false, "width": 0, "height": 0 },
  { "name": "eDP-2", "description": "Apple Computer Inc Color LCD", "make": "Apple Computer Inc", "model": "Color LCD", "availableModes": ["2880x1800@60.00Hz"], "mirrorOf": "none", "disabled": false, "focused": true, "width": 2880, "height": 1800 }
]'

disabled_ghost='[
  { "name": "eDP-1", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": true, "focused": false, "width": 0, "height": 0 },
  { "name": "eDP-2", "description": "Apple Computer Inc Color LCD", "make": "Apple Computer Inc", "model": "Color LCD", "availableModes": ["2880x1800@60.00Hz"], "mirrorOf": "none", "disabled": false, "focused": true, "width": 2880, "height": 1800 }
]'

swapped_ghost='[
  { "name": "eDP-1", "description": "Apple Computer Inc Color LCD", "make": "Apple Computer Inc", "model": "Color LCD", "availableModes": ["2880x1800@60.00Hz"], "mirrorOf": "none", "disabled": false, "focused": true, "width": 2880, "height": 1800 },
  { "name": "eDP-2", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": false, "focused": false, "width": 0, "height": 0 }
]'

# The real panel is powered down (lid shut) and still has an EDID. The ghost
# connector in front of it does not. Clamshell has to name the real panel so
# opening the lid can enable it again.
lid_behind_ghost='[
  { "name": "eDP-1", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": false, "focused": false, "width": 0, "height": 0 },
  { "name": "eDP-2", "description": "Apple Computer Inc Color LCD", "make": "Apple Computer Inc", "model": "Color LCD", "availableModes": [], "mirrorOf": "none", "disabled": true, "focused": false, "width": 0, "height": 0 },
  { "name": "DP-1", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": false, "focused": true, "width": 0, "height": 0 }
]'

lone_ghost='[
  { "name": "eDP-1", "description": "", "make": "", "model": "", "availableModes": [], "mirrorOf": "none", "disabled": false, "focused": true, "width": 0, "height": 0 }
]'

laptop_name() {
  printf '%s\n' "$1" >"$monitors_file"
  FAKE_MONITORS="$monitors_file" PATH="$test_bin:$PATH" \
    bash "$ROOT/bin/omarchy-hyprland-monitor-laptop" 2>/dev/null
}

assert_laptop() {
  local monitors="$1" expected="$2" description="$3" actual

  actual=$(laptop_name "$monitors")
  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   ${actual:-<missing>}"
}

monitor_state "$extended"
assert_line_count "monitor state answers every line while extended"
assert_line 0 42 "monitor state reports brightness"
assert_line 1 eDP-1 "monitor state names the internal monitor"
assert_line 2 DP-1 "monitor state names the external monitor"
assert_line 3 eDP-1 "monitor state reports the internal monitor enabled"
assert_line 4 "" "monitor state reports no mirror while extended"
assert_line 5 DP-1 "monitor state reports the focused monitor"
assert_line 6 1.5 "monitor state reports the scale"
pass "monitor state keeps its lines aligned when nothing is mirrored"

monitor_state "$mirrored"
assert_line_count "monitor state answers every line while mirroring"
assert_line 4 DP-1 "monitor state names the mirroring external monitor"
assert_line 5 eDP-1 "monitor state still reports the focused monitor while mirroring"
pass "monitor state reports the external monitor when it mirrors the internal"

monitor_state "$reverse_mirrored"
assert_line_count "monitor state answers every line while mirroring in reverse"
assert_line 4 DP-1 "monitor state names the external monitor either way round"
pass "monitor state reports the external monitor when the internal mirrors it"

monitor_state "$clamshell"
assert_line_count "monitor state answers every line while clamshelled"
assert_line 1 eDP-1 "monitor state still names a disabled internal monitor"
assert_line 3 "" "monitor state reports the internal monitor disabled"
assert_line 4 "" "monitor state reports no mirror while clamshelled"
pass "monitor state separates a disabled internal monitor from a missing one"

monitor_state "$extended"
[[ ${state_lines[7]-} == '[{"name":"eDP-1","enabled":true,"focused":false,"width":1920,"height":1080},{"name":"DP-1","enabled":true,"focused":true,"width":2560,"height":1440}]' ]] ||
  fail "monitor state lists every display for the panel" "actual: ${state_lines[7]-<missing>}"
monitor_state "$clamshell"
[[ ${state_lines[7]-} == '[{"name":"eDP-1","enabled":false,"focused":false,"width":0,"height":0},{"name":"DP-1","enabled":true,"focused":true,"width":2560,"height":1440}]' ]] ||
  fail "monitor state lists every display for the panel" "actual: ${state_lines[7]-<missing>}"
pass "monitor state lists every display with its enabled and focused state"

monitor_state "$ghost"
assert_line_count "monitor state answers every line with a ghost internal connector"
assert_line 1 eDP-2 "monitor state names the real internal panel when a ghost precedes it"
assert_line 3 eDP-2 "monitor state reports the real internal panel enabled"
[[ ${state_lines[7]-} == '[{"name":"eDP-2","enabled":true,"focused":true,"width":2880,"height":1800}]' ]] ||
  fail "monitor state omits an empty duplicate internal connector" "actual: ${state_lines[7]-<missing>}"
pass "monitor state omits an empty duplicate internal connector"

monitor_state "$disabled_ghost"
assert_line_count "monitor state answers every line with a disabled ghost connector"
assert_line 1 eDP-2 "monitor state names the real internal panel when the ghost is disabled"
[[ ${state_lines[7]-} == '[{"name":"eDP-2","enabled":true,"focused":true,"width":2880,"height":1800}]' ]] ||
  fail "monitor state omits a disabled empty internal connector" "actual: ${state_lines[7]-<missing>}"
pass "monitor state omits a disabled empty internal connector"

monitor_state "$swapped_ghost"
assert_line_count "monitor state answers every line when the ghost is eDP-2"
assert_line 1 eDP-1 "monitor state names the real internal panel when the ghost is eDP-2"
[[ ${state_lines[7]-} == '[{"name":"eDP-1","enabled":true,"focused":true,"width":2880,"height":1800}]' ]] ||
  fail "monitor state omits an empty duplicate regardless of eDP numbering" "actual: ${state_lines[7]-<missing>}"
pass "monitor state omits an empty duplicate regardless of eDP numbering"

monitor_state "$lid_behind_ghost"
assert_line_count "monitor state answers every line when the real panel is disabled behind a ghost"
assert_line 1 eDP-2 "monitor state names a disabled real panel ahead of an empty connector"
assert_line 2 DP-1 "monitor state still names the external monitor"
assert_line 3 "" "monitor state does not treat the empty connector as the enabled internal panel"
[[ ${state_lines[7]-} == '[{"name":"eDP-2","enabled":false,"focused":false,"width":0,"height":0},{"name":"DP-1","enabled":true,"focused":true,"width":0,"height":0}]' ]] ||
  fail "monitor state keeps a disabled real panel and a modeless external" "actual: ${state_lines[7]-<missing>}"
pass "monitor state keeps a disabled real panel and a modeless external"

monitor_state "$lone_ghost"
assert_line_count "monitor state answers every line with only an empty internal connector"
assert_line 1 eDP-1 "monitor state still names the only internal connector"
assert_line 3 eDP-1 "monitor state reports the only internal connector enabled"
[[ ${state_lines[7]-} == '[]' ]] ||
  fail "monitor state omits an empty internal connector with no real panel beside it" "actual: ${state_lines[7]-<missing>}"
pass "monitor state omits an empty internal connector with no real panel beside it"

assert_laptop "$extended" eDP-1 "laptop display is the internal monitor"
assert_laptop "$clamshell" eDP-1 "laptop display stays the disabled internal panel"
assert_laptop "$ghost" eDP-2 "laptop display skips an empty connector in front of the real panel"
assert_laptop "$swapped_ghost" eDP-1 "laptop display skips an empty connector after the real panel"
assert_laptop "$lid_behind_ghost" eDP-2 "laptop display names a disabled real panel ahead of an empty connector"
assert_laptop "$lone_ghost" eDP-1 "laptop display keeps the only internal connector"
pass "laptop display and monitor state agree on the built-in panel"
