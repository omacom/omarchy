#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/hypr"
chmod +x "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-dell-xps-oled" <<'SH'
#!/bin/bash
exit "${TEST_XPS_OLED:-0}"
SH
chmod +x "$test_tmp/bin/omarchy-hw-dell-xps-oled"

monitors="$test_tmp/home/.config/hypr/monitors.lua"
cp "$ROOT/config/hypr/monitors.lua" "$monitors"

run_fix() {
  HOME="$test_tmp/home" \
    PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    TEST_XPS_OLED="${1:-0}" \
    bash -euo pipefail -c 'source "$ROOT/install/user/hardware/dell/xps-oled-color.sh"'
}

run_fix 0 >/dev/null
grep -F 'cm = "dp3"' "$monitors" >/dev/null
grep -F 'output = "eDP-1"' "$monitors" >/dev/null
pass "XPS OLED setup adds Display P3 on eDP-1"

run_fix 0 >/dev/null
(( $(grep -c 'cm = "dp3"' "$monitors") == 1 )) || fail "XPS OLED color setup is idempotent"
pass "XPS OLED color setup is idempotent"

cp "$ROOT/config/hypr/monitors.lua" "$monitors"
run_fix 1 >/dev/null
if grep -q 'cm =' "$monitors"; then
  fail "XPS OLED color setup ignores other machines"
fi
pass "XPS OLED color setup ignores other machines"

rm -f "$monitors"
run_fix 0 >/dev/null
pass "XPS OLED color setup skips a missing monitors.lua"

cat >"$monitors" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, cm = "srgb" })
LUA
run_fix 0 >/dev/null
grep -F 'cm = "srgb"' "$monitors" >/dev/null || fail "preserved existing color management"
if grep -q 'cm = "dp3"' "$monitors"; then
  fail "XPS OLED color setup should not override an existing cm"
fi
pass "XPS OLED color setup leaves an existing cm alone"

cat >"$monitors" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, cm="srgb" })
LUA
run_fix 0 >/dev/null
grep -F 'cm="srgb"' "$monitors" >/dev/null || fail "preserved compact color management"
if grep -q 'cm = "dp3"' "$monitors"; then
  fail "XPS OLED color setup should not override a compact cm"
fi
pass "XPS OLED color setup leaves a compact cm alone"

cat >"$monitors" <<'LUA'
hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = 1.25 })
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
LUA
run_fix 0 >/dev/null
grep -F 'mode = "2880x1800@120"' "$monitors" >/dev/null || fail "preserved existing eDP-1 mode"
grep -F 'position = "0x0"' "$monitors" >/dev/null || fail "preserved existing eDP-1 position"
grep -F 'scale = 1.25' "$monitors" >/dev/null || fail "preserved existing eDP-1 scale"
grep -F 'cm = "dp3"' "$monitors" >/dev/null || fail "added Display P3 to existing eDP-1"
(( $(grep -c 'output = "eDP-1"' "$monitors") == 1 )) || fail "did not insert a second eDP-1 rule"
pass "XPS OLED color setup patches an existing eDP-1 instead of replacing it"

run_fix 0 >/dev/null
(( $(grep -c 'cm = "dp3"' "$monitors") == 1 )) || fail "patching existing eDP-1 is idempotent"
pass "XPS OLED color setup patching existing eDP-1 is idempotent"

cat >"$monitors" <<'LUA'
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = 1.25,
})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
run_fix 0 >/dev/null
grep -F 'scale = 1.25' "$monitors" >/dev/null || fail "preserved multiline eDP-1 scale"
grep -F 'cm = "dp3"' "$monitors" >/dev/null || fail "added Display P3 to multiline eDP-1"
(( $(grep -c 'output = "eDP-1"' "$monitors") == 1 )) || fail "did not insert a second eDP-1 on a multiline rule"
pass "XPS OLED color setup patches a multiline eDP-1"

cat >"$monitors" <<'LUA'
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
run_fix 0 >/dev/null
if grep -q 'output = "eDP-1"' "$monitors"; then
  fail "XPS OLED color setup should not match a commented catch-all"
fi
pass "XPS OLED color setup ignores a commented catch-all"

cat >"$monitors" <<'LUA'
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 }) -- output = "eDP-1"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
LUA
run_fix 0 >/dev/null
grep -F 'output = "eDP-1"' "$monitors" >/dev/null || fail "still inserts when eDP-1 is only in a comment"
grep -F 'output = "DP-1"' "$monitors" >/dev/null || fail "preserved unrelated named output"
pass "XPS OLED color setup ignores eDP-1 mentioned in a trailing comment"
