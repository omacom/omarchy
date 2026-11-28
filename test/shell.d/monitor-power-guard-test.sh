#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command flock
require_command md5sum
require_command timeout

test_tmp=$(mktemp -d)
fake_bin=$test_tmp/bin
home=$test_tmp/home
run=$test_tmp/run
drm=$test_tmp/drm
monitors=$test_tmp/monitors.json
actions=$test_tmp/actions
ddc_sequence=$test_tmp/ddc-sequence
ddc_counter=$test_tmp/ddc-counter
state=$test_tmp/state
guard_log=$test_tmp/guard.log

cleanup() {
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$fake_bin" "$home" "$run" "$drm/card1-HDMI-A-1" "$state"

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

set -u

case ${1:-} in
monitors)
  cat "$FAKE_MONITORS"
  ;;
eval)
  lua=${2:-}
  printf 'eval %s\n' "$lua" >>"$FAKE_ACTIONS"
  output=$(sed -n 's/.*output = "\([^"]*\)".*/\1/p' <<<"$lua")
  [[ -n $output ]] || exit 0
  disabled=$(sed -n 's/.*disabled = \([a-z]*\).*/\1/p' <<<"$lua")
  position=$(sed -n 's/.*position = "\([^"]*\)".*/\1/p' <<<"$lua")
  scale=$(sed -n 's/.*scale = \([0-9.]*\).*/\1/p' <<<"$lua")
  temporary=$(mktemp "$FAKE_MONITORS.tmp.XXXXXX")
  if jq --arg output "$output" --arg disabled "$disabled" --arg position "$position" --arg scale "$scale" '
    map(if .name == $output then
      .disabled = (if $disabled == "" then .disabled else ($disabled == "true") end)
      | if $disabled == "false" then .width = 1920 | .height = 1080 | .dpmsStatus = true else . end
      | if $position != "" and $position != "auto" then
          .x = ($position | split("x")[0] | tonumber)
          | .y = ($position | split("x")[1] | tonumber)
        else . end
      | if $scale != "" then .scale = ($scale | tonumber) else . end
    else . end)' "$FAKE_MONITORS" >"$temporary"; then
    mv -f "$temporary" "$FAKE_MONITORS"
  else
    rm -f "$temporary"
  fi
  ;;
reload)
  printf 'reload\n' >>"$FAKE_ACTIONS"
  ;;
*)
  exit 1
  ;;
esac
SH

cat >"$fake_bin/ddcutil" <<'SH'
#!/bin/bash

set -u

if [[ $* == *"getvcp D6"* ]]; then
  count=0
  [[ -f $FAKE_DDC_COUNTER ]] && read -r count <"$FAKE_DDC_COUNTER"
  count=$((count + 1))
  printf '%s\n' "$count" >"$FAKE_DDC_COUNTER"

  line=$(sed -n "${count}p" "$FAKE_DDC_SEQUENCE")
  if [[ -z $line ]]; then
    line=$(awk 'NF { last = $0 } END { print last }' "$FAKE_DDC_SEQUENCE")
  fi
  [[ -n $line ]] || line='VCP D6 SNC x01'

  if [[ $line == ERR:timeout ]]; then
    printf 'timed out\n' >&2
    exit 124
  fi
  if [[ $line == ERR:* ]]; then
    printf '%s\n' "${line#ERR:}" >&2
    exit 1
  fi
  printf '%s\n' "$line"
  exit 0
fi

exit 1
SH

cat >"$fake_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$FAKE_ACTIONS"
SH

cat >"$fake_bin/omarchy-i18n" <<'SH'
#!/bin/bash
key=${1:-}
shift || true
printf '%s' "$key"
(( $# )) && printf ' %s' "$@"
printf '\n'
SH

cat >"$fake_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$FAKE_ACTIONS"
if [[ ${FAKE_SYSTEMCTL_FAIL:-} == "${2:-}" ]]; then
  exit 1
fi
SH

chmod +x "$fake_bin"/*

set_monitors() {
  printf '%s\n' "$1" >"$monitors"
}

default_monitors() {
  cat >"$monitors" <<'JSON'
[
  {"name":"eDP-1","description":"Laptop Panel TEST","mirrorOf":"none","disabled":false,"width":2560,"height":1600,"refreshRate":120,"x":0,"y":0,"scale":2,"transform":0,"vrr":false,"dpmsStatus":true,"availableModes":["2560x1600@120.00Hz"]},
  {"name":"HDMI-A-1","description":"Acer EK240Y TEST","mirrorOf":"none","disabled":false,"width":1920,"height":1080,"refreshRate":144,"x":1280,"y":0,"scale":1.25,"transform":0,"vrr":false,"dpmsStatus":true,"availableModes":["1920x1080@144.00Hz","1920x1080@60.00Hz"]}
]
JSON
}

set_output() {
  local output=$1 disabled=$2 temporary
  temporary=$(mktemp "$monitors.tmp.XXXXXX")
  jq --arg output "$output" --argjson disabled "$disabled" '
    map(if .name == $output then
      .disabled = $disabled
      | if $disabled then .width = 0 | .height = 0 else .width = 1920 | .height = 1080 | .dpmsStatus = true end
    else . end)' "$monitors" >"$temporary"
  mv -f "$temporary" "$monitors"
}

remove_external() {
  local temporary
  temporary=$(mktemp "$monitors.tmp.XXXXXX")
  jq 'map(select(.name != "HDMI-A-1"))' "$monitors" >"$temporary"
  mv -f "$temporary" "$monitors"
}

disable_internal() {
  local temporary
  temporary=$(mktemp "$monitors.tmp.XXXXXX")
  jq 'map(if .name == "eDP-1" then .disabled = true | .width = 0 | .height = 0 else . end)' \
    "$monitors" >"$temporary"
  mv -f "$temporary" "$monitors"
}

reset_state() {
  rm -rf "$state" "$home/.local/state/omarchy/toggles" "$home/.config/systemd/user" "$run" "$drm"
  mkdir -p "$state" "$home/.local/state/omarchy/toggles/hypr" "$run" "$drm/card1-HDMI-A-1"
  : >"$actions"
  : >"$ddc_counter"
  printf 'VCP D6 SNC x01\n' >"$ddc_sequence"
  printf 'connected\n' >"$drm/card1-HDMI-A-1/status"
  : >"$drm/i2c-5"
  ln -sfn "$drm/i2c-5" "$drm/card1-HDMI-A-1/ddc"
  printf 'edid-default\n' >"$drm/card1-HDMI-A-1/edid"
  default_monitors
}

run_guard() {
  HOME="$home" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_RUNTIME_DIR="$run" \
    OMARCHY_DRM_PATH="$drm" \
    MONITOR_POWER_GUARD_STATE_DIR="$state" \
    MONITOR_POWER_GUARD_INTERVAL=5 \
    MONITOR_POWER_GUARD_CONFIRM_DELAY=0 \
    MONITOR_POWER_GUARD_DDC_TIMEOUT=1 \
    MONITOR_POWER_GUARD_DDC_SLEEP=0.1 \
    MONITOR_POWER_GUARD_RESUME_GRACE=0 \
    MONITOR_POWER_GUARD_LOCK_WAIT=2 \
    PATH="$fake_bin:$ROOT/bin:$PATH" \
    FAKE_MONITORS="$monitors" \
    FAKE_ACTIONS="$actions" \
    FAKE_DDC_SEQUENCE="$ddc_sequence" \
    FAKE_DDC_COUNTER="$ddc_counter" \
    "$ROOT/bin/omarchy-hyprland-monitor-power-guard" "$@"
}

run_toggle() {
  HOME="$home" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_RUNTIME_DIR="$run" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_DRM_PATH="$drm" \
    MONITOR_POWER_GUARD_STATE_DIR="$state" \
    MONITOR_POWER_GUARD_INTERVAL=5 \
    MONITOR_POWER_GUARD_CONFIRM_DELAY=0 \
    MONITOR_POWER_GUARD_DDC_TIMEOUT=1 \
    MONITOR_POWER_GUARD_DDC_SLEEP=0.1 \
    MONITOR_POWER_GUARD_RESUME_GRACE=0 \
    MONITOR_POWER_GUARD_LOCK_WAIT=2 \
    PATH="$fake_bin:$ROOT/bin:$PATH" \
    FAKE_MONITORS="$monitors" \
    FAKE_ACTIONS="$actions" \
    FAKE_DDC_SEQUENCE="$ddc_sequence" \
    FAKE_DDC_COUNTER="$ddc_counter" \
    "$ROOT/bin/omarchy-toggle-monitor-power-guard" "$@"
}

assert_enabled() {
  local output=$1
  jq -e --arg output "$output" '.[] | select(.name == $output)
    | .disabled != true and .width > 0 and .height > 0 and .dpmsStatus == true' "$monitors" >/dev/null ||
    fail "$output is enabled and live"
}

assert_disabled() {
  local output=$1
  jq -e --arg output "$output" '.[] | select(.name == $output) | .disabled == true' "$monitors" >/dev/null ||
    fail "$output is disabled"
}

assert_state_exists() {
  [[ -s $state/suspended/HDMI-A-1.json ]] || fail "guard saved the suspended state"
}

assert_state_absent() {
  [[ ! -e $state/suspended/HDMI-A-1.json ]] || fail "guard cleared the suspended state"
}

assert_action_contains() {
  local expected=$1
  grep -F "$expected" "$actions" >/dev/null || fail "action log contains: $expected"
}

assert_flag_present() {
  [[ -f $home/.local/state/omarchy/toggles/monitor-power-guard ]] || fail "toggle writes the opt-in flag"
}

assert_flag_absent() {
  [[ ! -e $home/.local/state/omarchy/toggles/monitor-power-guard ]] || fail "toggle removes the opt-in flag"
}

assert_unit_present() {
  [[ -f $home/.config/systemd/user/omarchy-hyprland-monitor-power-guard.service ]] ||
    fail "toggle installs the fallback user unit"
}

assert_unit_absent() {
  [[ ! -e $home/.config/systemd/user/omarchy-hyprland-monitor-power-guard.service ]] ||
    fail "toggle removes the fallback user unit"
}

reset_state

# The toggle owns the flag and the service state. A source checkout needs the
# fallback unit; a packaged install uses its unit directly.
run_toggle on >/dev/null 2>&1 || fail "monitor power guard toggles on"
assert_flag_present
assert_unit_present
assert_action_contains "systemctl --user enable --now omarchy-hyprland-monitor-power-guard.service"

run_toggle off >/dev/null 2>&1 || fail "monitor power guard toggles off"
assert_flag_absent
assert_unit_absent
assert_action_contains "systemctl --user stop omarchy-hyprland-monitor-power-guard.service"
assert_action_contains "systemctl --user disable omarchy-hyprland-monitor-power-guard.service"
pass "monitor power guard toggles its service and flag together"

reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard disables a confirmed off monitor"
assert_disabled HDMI-A-1
assert_state_exists
assert_action_contains 'eval hl.monitor({ output = "HDMI-A-1", disabled = true })'
assert_action_contains 'monitor.powerGuardTurnedOff'
pass "a confirmed off monitor is disabled and its layout is saved"

reset_state
printf 'VCP D6 SNC x04\nERR:Device or resource busy\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard treats a busy confirmation as inconclusive"
assert_enabled HDMI-A-1
assert_state_absent
pass "a transient confirmation error does not disable the monitor"

# The off answer is already strong evidence. A timeout on the confirmation
# read must not crash the timeout path or turn a dark monitor back on.
reset_state
printf 'VCP D6 SNC x04\nERR:timeout\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard handles a timeout after an off answer"
assert_disabled HDMI-A-1
assert_state_exists
pass "a timeout after an off answer still suspends the monitor"

reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard accepts a monitor that answers on confirmation"
assert_enabled HDMI-A-1
assert_state_absent
pass "a monitor that answers the confirmation probe stays enabled"

reset_state
printf 'ERR:DDC communication failed\nERR:DDC communication failed\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard fails open when DDC never worked"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'monitor.powerGuardUnsupported'
pass "a monitor whose DDC has never worked fails open"

# A monitor that answered DDC before but now times out is the power-loss case.
# The marker is tied to the EDID, so a replacement cannot inherit it.
reset_state
printf 'VCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard records a successful DDC read"
printf 'ERR:timeout\nERR:timeout\nERR:timeout\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard disables a monitor that times out after a successful read"
assert_disabled HDMI-A-1
assert_state_exists
assert_action_contains 'monitor.powerGuardLost'
pass "a monitor that stops answering after a successful read is disabled"

reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves a confirmed outage"
assert_disabled HDMI-A-1
printf 'VCP D6 SNC x01\nVCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard restores a returning monitor"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'mode = "1920x1080@144"'
jq -e '.[] | select(.name == "HDMI-A-1") | .x == 1280 and .y == 0 and .scale == 1.25 and .dpmsStatus == true' \
  "$monitors" >/dev/null || fail "guard restores position, scale, and DPMS"
pass "a returning monitor is restored with its saved mode and position"

# An unreadable EDID during an outage is not proof that the monitor was
# replaced. The saved layout must survive until a readable identity differs.
reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the EDID test"
assert_disabled HDMI-A-1
rm -f "$drm/card1-HDMI-A-1/edid"
printf 'VCP D6 SNC x01\nVCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard restores with an unreadable EDID"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'mode = "1920x1080@144"'
pass "an unreadable EDID keeps the saved monitor layout"

# Some setups expose a zero-byte DRM EDID. Hyprland's description, including
# the monitor serial when the kernel supplies one, is the fallback identity.
reset_state
rm -f "$drm/card1-HDMI-A-1/edid"
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage with no sysfs EDID"
assert_disabled HDMI-A-1
assert_state_exists
jq -e '.edid == "" and .description == "Acer EK240Y TEST"' "$state/suspended/HDMI-A-1.json" >/dev/null ||
  fail "guard saves the description when EDID is unavailable"
printf 'VCP D6 SNC x01\nVCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard restores a monitor identified by description"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'mode = "1920x1080@144"'
pass "a description identity restores the saved layout when EDID is unavailable"

reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the identity test"
assert_state_exists
jq '.edid = "" | .description = ""' "$state/suspended/HDMI-A-1.json" >"$state/suspended/HDMI-A-1.json.tmp" &&
  mv -f "$state/suspended/HDMI-A-1.json.tmp" "$state/suspended/HDMI-A-1.json"
printf 'replacement-edid\n' >"$drm/card1-HDMI-A-1/edid"
printf 'VCP D6 SNC x01\nVCP D6 SNC x01\n' >"$ddc_sequence"
: >"$actions"
run_guard --once >"$guard_log" 2>&1 || fail "guard restores an unknown saved identity"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'mode = "preferred"'
assert_action_contains 'position = "auto"'
if grep -F 'mode = "1920x1080@144"' "$actions" >/dev/null; then
  fail "an empty saved identity does not reuse the old layout"
fi
pass "an empty saved identity uses the safe layout"

reset_state
disable_internal
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard refuses a dark monitor with no fallback"
assert_enabled HDMI-A-1
assert_state_absent
grep -F 'no other active display is available' "$guard_log" >/dev/null ||
  fail "guard reports why it left the only display enabled"
pass "the last active display is never disabled"

# If the fallback disappears too, the session has no enabled output. Saved
# recovery must still run instead of returning early on the DPMS check.
reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the all-disabled test"
assert_disabled HDMI-A-1
disable_internal
printf 'VCP D6 SNC x01\nVCP D6 SNC x01\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard restores when every output is disabled"
assert_enabled HDMI-A-1
assert_state_absent
pass "saved recovery runs when every output is disabled"

# A reload or manual enable can put a suspended output back without a DDC
# answer. The guard must put the dark output back out of service and keep the
# saved state for the real recovery.
reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the re-enable test"
assert_disabled HDMI-A-1
set_output HDMI-A-1 false
printf 'VCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard reconciles a re-enabled dark output"
assert_disabled HDMI-A-1
assert_state_exists
pass "a dark output re-enabled by a reload is disabled again"

# The timeout path also runs while reconciling an enabled suspended output.
reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the suspended timeout test"
set_output HDMI-A-1 false
printf 'ERR:timeout\nERR:timeout\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard handles a suspended output that times out"
assert_disabled HDMI-A-1
assert_state_exists
pass "a suspended output that times out is disabled again"

# The fallback display can disappear after the outage. Re-disabling the dark
# output then would leave the session with no output at all.
reset_state
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the no-fallback reconcile test"
assert_disabled HDMI-A-1
set_output HDMI-A-1 false
disable_internal
printf 'VCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard checks the fallback before re-disabling"
assert_enabled HDMI-A-1
assert_state_exists
grep -F 'no other active display is available' "$guard_log" >/dev/null ||
  fail "guard reports the missing fallback while reconciling"
pass "a suspended output is not re-disabled when its fallback is gone"

# Turning the guard off must not depend on the monitor being present. The old
# transactional restore could strand the feature enabled forever.
reset_state
run_toggle on >/dev/null 2>&1 || fail "toggle on before the absent-monitor off test"
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the absent-monitor test"
assert_state_exists
remove_external
run_toggle off >"$guard_log" 2>&1 || fail "toggle off succeeds when the monitor is absent"
assert_state_absent
assert_flag_absent
assert_unit_absent
pass "turning the guard off succeeds when the monitor is absent"

reset_state
run_toggle on >/dev/null 2>&1 || fail "toggle on before the dark-monitor off test"
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the dark-monitor test"
assert_disabled HDMI-A-1
printf 'ERR:DDC communication failed\n' >"$ddc_sequence"
run_toggle off >"$guard_log" 2>&1 || fail "toggle off succeeds when the monitor is dark"
assert_enabled HDMI-A-1
assert_state_absent
assert_flag_absent
pass "turning the guard off restores a stranded output even without DDC"

# Turning the guard off must not apply the old monitor's layout to a
# replacement attached to the same output.
reset_state
run_toggle on >/dev/null 2>&1 || fail "toggle on before the replacement-restore test"
printf 'VCP D6 SNC x04\nVCP D6 SNC x04\n' >"$ddc_sequence"
run_guard --once >"$guard_log" 2>&1 || fail "guard saves an outage before the replacement-restore test"
printf 'replacement-edid\n' >"$drm/card1-HDMI-A-1/edid"
: >"$actions"
run_toggle off >"$guard_log" 2>&1 || fail "toggle off succeeds with a replacement monitor"
assert_enabled HDMI-A-1
assert_state_absent
assert_action_contains 'mode = "preferred"'
if grep -F 'mode = "1920x1080@144"' "$actions" >/dev/null; then
  fail "off does not apply the old monitor's layout to a replacement"
fi
pass "turning the guard off uses the safe layout for a replacement monitor"

reset_state
if FAKE_SYSTEMCTL_FAIL=enable run_toggle on >/dev/null 2>&1; then
  fail "toggle on fails when the service cannot start"
fi
assert_flag_absent
assert_unit_absent
pass "failed enable rolls the opt-in flag and unit back"

reset_state
run_toggle on >/dev/null 2>&1 || fail "toggle on before the stop-failure test"
if FAKE_SYSTEMCTL_FAIL=stop run_toggle off >/dev/null 2>&1; then
  fail "toggle off fails when the service cannot stop"
fi
assert_flag_present
pass "failed stop keeps the opt-in flag"
