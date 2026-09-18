#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
call_log="$test_tmp/calls"
mkdir -p "$mock_bin" "$test_home/.local/state/omarchy/current/theme"
touch "$call_log"

printf '#7aa2f7\n' >"$test_home/.local/state/omarchy/current/theme/keyboard.rgb"

cat >"$mock_bin/openrgb" <<'SH'
#!/bin/bash
printf 'openrgb %s\n' "$*" >>"$CALL_LOG"
if [[ $* == *"--list-devices"* ]]; then
  [[ ${OPENRGB_LIST_FAIL:-0} == "1" ]] && exit 1
  printf '%s\n' "$OPENRGB_LIST_DEVICES"
fi
SH
chmod +x "$mock_bin/openrgb"

run_openrgb_theme() {
  HOME="$test_home" CALL_LOG="$call_log" OPENRGB_LIST_DEVICES="${OPENRGB_LIST_DEVICES:-}" OPENRGB_LIST_FAIL="${OPENRGB_LIST_FAIL:-0}" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-openrgb"
}

PLAIN_DEVICES='0: Logitech G512 RGB
  Modes: [Direct] Static Off Cycle Breathing
1: Razer Basilisk V3
  Modes: [Direct] Off Static '"'"'Spectrum Cycle'"'"' Wave'

: >"$call_log"
OPENRGB_LIST_DEVICES="$PLAIN_DEVICES" run_openrgb_theme
(( $(grep -c '^openrgb' "$call_log") == 3 )) || fail "static accent needs one detection and one apply per device" "$(cat "$call_log")"
grep -F 'openrgb -d 0 -m static -c afc7fa -b 100' "$call_log" >/dev/null || fail "static accent reaches every detected device" "$(cat "$call_log")"
grep -F 'openrgb -d 1 -m static -c afc7fa -b 100' "$call_log" >/dev/null || fail "static accent reaches every detected device" "$(cat "$call_log")"
grep -F '7aa2f7' "$call_log" >/dev/null && fail "raw accent is brightened before applying" "$(cat "$call_log")"
pass "static accent reaches every detected device"

: >"$call_log"
OPENRGB_LIST_DEVICES='0: Fake Board
  Modes: Direct Static Gradient Wave
1: Other Pad
  Modes: [Direct] Off Static '"'"'Rainbow Gradient'"'"'' run_openrgb_theme
grep -F 'openrgb -d 0 -m Gradient -c afc7fa -b 100' "$call_log" >/dev/null || fail "bare gradient mode wins on its device" "$(cat "$call_log")"
grep -F 'openrgb -d 1 -m Rainbow Gradient -c afc7fa -b 100' "$call_log" >/dev/null || fail "quoted gradient mode wins on its device" "$(cat "$call_log")"
pass "gradient-capable devices prefer their gradient mode"

: >"$call_log"
OPENRGB_LIST_DEVICES="$PLAIN_DEVICES" OPENRGB_LIST_FAIL=1 run_openrgb_theme || fail "failed detection still exits zero"
grep -F 'openrgb -m static -c afc7fa -b 100' "$call_log" >/dev/null || fail "failed detection falls back to static broadcast" "$(cat "$call_log")"
pass "failed detection falls back to static broadcast"

mv "$test_home/.local/state/omarchy/current/theme/keyboard.rgb" "$test_home/.local/state/omarchy/current/theme/keyboard.rgb.bak"
: >"$call_log"
OPENRGB_LIST_DEVICES="$PLAIN_DEVICES" run_openrgb_theme
[[ ! -s $call_log ]] || fail "missing keyboard.rgb makes no OpenRGB calls" "$(cat "$call_log")"
pass "missing keyboard.rgb makes no OpenRGB calls"
mv "$test_home/.local/state/omarchy/current/theme/keyboard.rgb.bak" "$test_home/.local/state/omarchy/current/theme/keyboard.rgb"

printf 'not-a-color\n' >"$test_home/.local/state/omarchy/current/theme/keyboard.rgb"
: >"$call_log"
OPENRGB_LIST_DEVICES="$PLAIN_DEVICES" run_openrgb_theme
[[ ! -s $call_log ]] || fail "invalid color makes no OpenRGB calls" "$(cat "$call_log")"
pass "invalid color makes no OpenRGB calls"
printf '#7aa2f7\n' >"$test_home/.local/state/omarchy/current/theme/keyboard.rgb"

no_openrgb_bin="$test_tmp/no-openrgb"
mkdir -p "$no_openrgb_bin"
cat >"$no_openrgb_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "openrgb" ]] && exit 1
exec "$ROOT/bin/omarchy-cmd-present" "$@"
SH
chmod +x "$no_openrgb_bin/omarchy-cmd-present"
: >"$call_log"
HOME="$test_home" CALL_LOG="$call_log" PATH="$no_openrgb_bin:$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-openrgb"
[[ ! -s $call_log ]] || fail "missing openrgb binary is a silent no-op" "$(cat "$call_log")"
pass "missing openrgb binary is a silent no-op"

: >"$call_log"
HOME="$test_home" CALL_LOG="$call_log" OPENRGB_LIST_DEVICES="$PLAIN_DEVICES" \
  PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-keyboard"
grep -F 'openrgb -d 0 -m static -c afc7fa -b 100' "$call_log" >/dev/null || fail "keyboard dispatcher applies the OpenRGB theme" "$(cat "$call_log")"
pass "keyboard dispatcher applies the OpenRGB theme"
