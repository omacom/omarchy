#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

launch_output=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = {}
require("default.hypr.helpers")
print(o.launch("foot"))
print(o.launch("[workspace 4 silent] foot"))
print(o.launch("[float] kitty --class notes"))
LUA
) || fail "o.launch can be evaluated"

expected=$'uwsm-app -- foot\n[workspace 4 silent] uwsm-app -- foot\n[float] uwsm-app -- kitty --class notes'
[[ $launch_output == "$expected" ]] || fail "o.launch keeps Hyprland exec-rule brackets outside uwsm-app" "$launch_output"
pass "o.launch keeps Hyprland exec-rule brackets outside uwsm-app"

sole_output=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = {}
require("default.hypr.helpers")
print(o.launch_sole("foot", "foot"))
print(o.launch_sole("foot", "[workspace 4 silent] foot"))
print(o.launch_sole("notes", "[float] kitty --class notes"))
LUA
) || fail "o.launch_sole can be evaluated"

sole_expected=$'omarchy-launch-or-focus \'foot\' \'uwsm-app -- foot\'\nomarchy-launch-or-focus \'foot\' \'[workspace 4 silent] uwsm-app -- foot\'\nomarchy-launch-or-focus \'notes\' \'[float] uwsm-app -- kitty --class notes\''
[[ $sole_output == "$sole_expected" ]] || fail "o.launch_sole keeps Hyprland exec-rule brackets outside uwsm-app" "$sole_output"
pass "o.launch_sole keeps Hyprland exec-rule brackets outside uwsm-app"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
hypr_log="$test_tmp/hyprctl"
setsid_log="$test_tmp/setsid"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"
if [[ $1 == clients ]]; then
  printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON"
  exit 0
fi
if [[ $1 == dispatch && ${OMARCHY_TEST_FAIL_LUA_EXEC:-0} == 1 && $2 == hl.dsp.exec_cmd* ]]; then
  printf '%s\n' 'dispatcher not found'
  exit 1
fi
printf 'ok\n'
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_SETSID_LOG"
SH

chmod +x "$mock_bin/hyprctl" "$mock_bin/setsid"

run_focus_launch() {
  local clients="$1"
  shift
  : >"$hypr_log"
  rm -f "$setsid_log"
  PATH="$mock_bin:$PATH" \
    OMARCHY_TEST_CLIENTS_JSON="$clients" \
    OMARCHY_TEST_HYPRCTL_LOG="$hypr_log" \
    OMARCHY_TEST_SETSID_LOG="$setsid_log" \
    OMARCHY_TEST_FAIL_LUA_EXEC="${OMARCHY_TEST_FAIL_LUA_EXEC:-0}" \
    bash "$ROOT/bin/omarchy-launch-or-focus" "$@"
}

run_focus_launch '[]' foot 'uwsm-app -- foot'
[[ -f $setsid_log ]] || fail "plain focus launch still detaches with setsid"
[[ $(<"$setsid_log") == "uwsm-app -- foot" ]] || fail "plain focus launch keeps the uwsm-app command" "$(<"$setsid_log")"
grep -F 'exec_cmd' "$hypr_log" >/dev/null && fail "plain focus launch does not go through the Hyprland exec dispatcher" "$(<"$hypr_log")"
pass "plain focus launch still detaches uwsm-app with setsid"

run_focus_launch '[]' foot '[workspace 4 silent] uwsm-app -- foot'
[[ ! -e $setsid_log ]] || fail "rule-prefixed focus launch does not execute the bracket as a program" "$(<"$setsid_log")"
grep -F 'dispatch hl.dsp.exec_cmd("[workspace 4 silent] uwsm-app -- foot")' "$hypr_log" >/dev/null ||
  fail "rule-prefixed focus launch opens through Hyprland exec" "$(<"$hypr_log")"
grep -E '^dispatch exec ' "$hypr_log" >/dev/null && fail "rule-prefixed focus launch does not also use the legacy exec dispatcher" "$(<"$hypr_log")"
pass "rule-prefixed focus launch opens through Hyprland exec"

run_focus_launch '[]' notes '[float] uwsm-app -- kitty --class notes'
grep -F 'dispatch hl.dsp.exec_cmd("[float] uwsm-app -- kitty --class notes")' "$hypr_log" >/dev/null ||
  fail "a float exec rule still reaches Hyprland" "$(<"$hypr_log")"
pass "a float exec rule still reaches Hyprland"

OMARCHY_TEST_FAIL_LUA_EXEC=1 run_focus_launch '[]' foot '[workspace 4 silent] uwsm-app -- foot'
[[ ! -e $setsid_log ]] || fail "legacy exec fallback does not execute the bracket as a program" "$(<"$setsid_log")"
grep -F 'dispatch exec [workspace 4 silent] uwsm-app -- foot' "$hypr_log" >/dev/null ||
  fail "rule-prefixed focus launch falls back to the legacy exec dispatcher" "$(<"$hypr_log")"
pass "rule-prefixed focus launch falls back to the legacy exec dispatcher"
OMARCHY_TEST_FAIL_LUA_EXEC=0

run_focus_launch '[{"address":"0xabc","class":"foot","title":"shell"}]' foot '[workspace 4 silent] uwsm-app -- foot'
[[ ! -e $setsid_log ]] || fail "an existing window is focused instead of launched" "$(<"$setsid_log")"
grep -F 'hl.dsp.focus({ window = "address:0xabc" })' "$hypr_log" >/dev/null ||
  fail "an existing window is focused" "$(<"$hypr_log")"
grep -F 'exec_cmd' "$hypr_log" >/dev/null && fail "an existing window does not launch again" "$(<"$hypr_log")"
pass "an existing window is focused instead of launched"
