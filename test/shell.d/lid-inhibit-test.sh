#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The watcher half opens its event stream with {fd}> redirection.
(( BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 401 )) || fail "this test runs under bash 4.1 or newer" "$BASH_VERSION"

lid_inhibit="$ROOT/bin/omarchy-system-lid-inhibit"

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""

# The watcher forks clamshell retries and a poll; orphaning them would leave
# them syncing against a deleted test tree.
stop_watcher() {
  local child descendants

  if [[ -n $watch_pid ]]; then
    descendants=$(pgrep -P "$watch_pid" 2>/dev/null || true)
    for child in $descendants; do
      descendants+=" $(pgrep -P "$child" 2>/dev/null || true)"
    done

    kill -KILL "$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    for child in $descendants; do
      kill -KILL "$child" 2>/dev/null || true
    done
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi

  return 0
}

cleanup() {
  stop_watcher
  rm -rf "$test_tmp"
}
trap cleanup EXIT

fake_bin="$test_tmp/bin"
drm_path="$test_tmp/drm"
unit_state="$test_tmp/unit-active"
call_log="$test_tmp/calls"
monitors="$test_tmp/monitors.json"
hyprctl_fail="$test_tmp/hyprctl-fails"
busctl_fail="$test_tmp/busctl-fails"
cgroup="$test_tmp/cgroup"
events="$test_tmp/events"
mkdir -p "$fake_bin"

# The user manager, reduced to the one unit. Like the real one, it refuses to
# start a unit name that is already loaded.
cat >"$fake_bin/systemd-run" <<'SH'
#!/bin/bash

if [[ -e $OMARCHY_TEST_UNIT_STATE ]]; then
  printf 'refused\n' >>"$OMARCHY_TEST_CALL_LOG"
  echo "Unit already loaded" >&2
  exit 1
fi

printf 'start %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
touch "$OMARCHY_TEST_UNIT_STATE"
SH

cat >"$fake_bin/systemctl" <<'SH'
#!/bin/bash

case "$*" in
  "--user is-active --quiet omarchy-lid-inhibit.service")
    [[ -e $OMARCHY_TEST_UNIT_STATE ]]
    ;;
  "--user stop omarchy-lid-inhibit.service")
    printf 'stop\n' >>"$OMARCHY_TEST_CALL_LOG"
    rm -f "$OMARCHY_TEST_UNIT_STATE"
    ;;
  *)
    exit 2
    ;;
esac
SH

cat >"$fake_bin/busctl" <<'SH'
#!/bin/bash

[[ $* == *" HandleLidSwitchDocked" ]] || exit 1
[[ -f $OMARCHY_TEST_BUSCTL_FAIL ]] && exit 1
printf 's "%s"\n' "$OMARCHY_TEST_DOCKED_ACTION"
SH

cat >"$fake_bin/omarchy-hw-laptop" <<'SH'
#!/bin/bash

[[ $OMARCHY_TEST_LAPTOP == 1 ]]
SH

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

[[ $* == "monitors all -j" ]] || exit 0
[[ -f $OMARCHY_TEST_HYPRCTL_FAIL ]] && exit 1
cat "$OMARCHY_TEST_MONITORS"
SH

chmod +x "$fake_bin"/*

export OMARCHY_DRM_PATH="$drm_path"
export OMARCHY_TEST_UNIT_STATE="$unit_state"
export OMARCHY_TEST_CALL_LOG="$call_log"
export OMARCHY_TEST_MONITORS="$monitors"
export OMARCHY_TEST_HYPRCTL_FAIL="$hyprctl_fail"
export OMARCHY_TEST_BUSCTL_FAIL="$busctl_fail"
export OMARCHY_CGROUP_PATH="$cgroup"
export OMARCHY_TEST_DOCKED_ACTION=ignore
export OMARCHY_TEST_LAPTOP=1

# Arguments come in pairs: connector and status. The card itself sits beside
# its connectors, as in sysfs.
write_connectors() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path/card2"

  while (( $# )); do
    mkdir -p "$drm_path/$1"
    printf '%s\n' "$2" >"$drm_path/$1/status"
    shift 2
  done
}

# What Hyprland reports: every output it knows, with whether it is disabled.
write_monitors() {
  printf '%s\n' "$1" >"$monitors"
}

reset_unit() {
  rm -f "$unit_state" "$hyprctl_fail" "$busctl_fail"
  : >"$call_log"
}

# Where the caller runs: an SSH login's session scope, outside the user manager.
printf '0::/user.slice/user-1000.slice/session-3.scope\n' >"$cgroup"

clamshell='[{"name":"eDP-1","disabled":true,"dpmsStatus":true},{"name":"USB-2","disabled":false,"dpmsStatus":true}]'

sync_inhibit() {
  PATH="$fake_bin:$PATH" "$lid_inhibit"
}

held() {
  [[ -e $unit_state ]]
}

count_calls() {
  grep -c "^$1" "$call_log" || true
}

# Apple Silicon in clamshell: the panel on eDP, a USB-C display on a "USB"
# connector that logind does not count as external.
reset_unit
write_connectors card2-eDP-1 connected card2-USB-2 connected
write_monitors "$clamshell"
sync_inhibit

held || fail "a USB-C display on a USB connector takes the lid inhibitor"
start=$(grep '^start' "$call_log")
for arg in --no-ask-password --what=handle-lid-switch --mode=block PartOf=graphical-session.target "sleep infinity"; do
  [[ $start == *"$arg"* ]] || fail "the inhibitor unit is started with $arg" "$start"
done
pass "a USB-C display on a USB connector takes a blocking lid inhibitor without prompting"

[[ $start != *BindsTo=* ]] || fail "a caller outside the user manager binds the inhibitor to nothing" "$start"
pass "a caller outside the user manager binds the inhibitor to nothing"

# The watcher runs in a scope of the user manager; the inhibitor stops with it.
reset_unit
watcher_scope='app-Hyprland-omarchy\x2dhyprland\x2dmonitor\x2dwatch-f1fda151.scope'
printf '0::/user.slice/user-1000.slice/user@1000.service/app.slice/app-graphical.slice/%s\n' "$watcher_scope" >"$cgroup"
sync_inhibit
start=$(grep '^start' "$call_log")
# systemd-run unquotes property values: a single backslash would name a unit
# that does not exist, and the inhibitor would never start.
bound_scope='app-Hyprland-omarchy\\x2dhyprland\\x2dmonitor\\x2dwatch-f1fda151.scope'
[[ $start == *"--property=BindsTo=$bound_scope --property=After=$bound_scope "* ]] ||
  fail "the inhibitor is bound to the watcher's unit" "$start"
printf '0::/user.slice/user-1000.slice/session-3.scope\n' >"$cgroup"
pass "the inhibitor is bound to the watcher's unit, so it cannot outlive it"

sync_inhibit
sync_inhibit
(( $(count_calls start) == 1 && $(count_calls stop) == 0 && $(count_calls refused) == 0 )) ||
  fail "repeated syncs keep a single inhibitor" "$(<"$call_log")"
pass "repeated syncs keep a single inhibitor"

# Some drivers report a connector disabled while DPMS blanks it; Hyprland keeps
# the monitor enabled. Releasing here would suspend a closed laptop the moment
# its external display went idle.
write_monitors '[{"name":"eDP-1","disabled":true,"dpmsStatus":false},{"name":"USB-2","disabled":false,"dpmsStatus":false}]'
sync_inhibit
held || fail "a USB-C display blanked by DPMS keeps the inhibitor" "$(<"$call_log")"
pass "a USB-C display blanked by DPMS keeps the inhibitor"

# Hyprland misses queries while it reconfigures outputs, which is exactly what
# a lid close sets off. Releasing on a missed answer would suspend the machine.
touch "$hyprctl_fail"
sync_inhibit || fail "an unanswered compositor query is not an error"
held || fail "an unanswered compositor query keeps the inhibitor"
rm -f "$hyprctl_fail"
write_monitors ''
sync_inhibit || fail "an empty compositor answer is not an error"
held || fail "an empty compositor answer keeps the inhibitor"
write_monitors 'HYPRLAND_INSTANCE_SIGNATURE not set!'
sync_inhibit || fail "a compositor answer that is not JSON is not an error"
held || fail "a compositor answer that is not JSON keeps the inhibitor"
write_monitors "$clamshell"
pass "a compositor that does not answer changes nothing"

# logind can miss a query too, and the release would suspend the machine just the same.
touch "$busctl_fail"
sync_inhibit || fail "an unanswered logind query is not an error"
held || fail "an unanswered logind query keeps the inhibitor"
rm -f "$busctl_fail"
pass "logind not answering changes nothing"

# Unplugging is read from the connector, so it releases even when the compositor
# cannot be asked.
write_connectors card2-eDP-1 connected card2-USB-2 disconnected
touch "$hyprctl_fail"
sync_inhibit
! held || fail "unplugging the USB-C display releases the inhibitor"
(( $(count_calls stop) == 1 )) || fail "the inhibitor is released once" "$(<"$call_log")"
pass "unplugging the USB-C display releases the inhibitor"

sync_inhibit
(( $(count_calls stop) == 1 && $(count_calls start) == 1 )) ||
  fail "a sync with nothing held changes nothing" "$(<"$call_log")"
pass "a sync with nothing held changes nothing"

reset_unit
write_connectors card2-eDP-1 connected card2-USB-2 connected
touch "$hyprctl_fail"
sync_inhibit || fail "an unanswered compositor query is not an error"
touch "$busctl_fail"
rm -f "$hyprctl_fail"
sync_inhibit || fail "an unanswered logind query is not an error"
[[ ! -s $call_log ]] || fail "an unanswered query takes no inhibitor" "$(<"$call_log")"
pass "an unanswered query takes no inhibitor either"

# A display left plugged in but switched off in the monitor config is not in use,
# and a closed lid should suspend as it would with that display on HDMI.
reset_unit
write_connectors card2-eDP-1 connected card2-USB-2 connected
write_monitors '[{"name":"eDP-1","disabled":false},{"name":"USB-2","disabled":true}]'
sync_inhibit
[[ ! -s $call_log ]] || fail "a display switched off in the monitor config takes no inhibitor" "$(<"$call_log")"
pass "a USB-C display switched off in the monitor config takes no inhibitor"

# Machines logind already handles must behave exactly as before.
reset_unit
write_connectors card2-eDP-1 connected
write_monitors '[{"name":"eDP-1","disabled":false}]'
sync_inhibit
[[ ! -s $call_log ]] || fail "the built-in panel alone takes no inhibitor" "$(<"$call_log")"
pass "the built-in panel alone takes no inhibitor"

reset_unit
write_connectors card0-eDP-1 connected card0-HDMI-A-1 connected card0-DP-1 connected
write_monitors '[{"name":"eDP-1","disabled":true},{"name":"HDMI-A-1","disabled":false},{"name":"DP-1","disabled":false}]'
sync_inhibit
[[ ! -s $call_log ]] || fail "displays logind counts take no inhibitor" "$(<"$call_log")"
pass "HDMI and DisplayPort displays, which logind counts, take no inhibitor"

reset_unit
write_connectors card2-USB-2 connected
write_monitors "$clamshell"
OMARCHY_TEST_LAPTOP=0 sync_inhibit
[[ ! -s $call_log ]] || fail "a machine without a lid takes no inhibitor" "$(<"$call_log")"
pass "a machine without a lid takes no inhibitor"

# Only where logind would ignore a docked lid is there anything to stand in for.
reset_unit
write_connectors card2-eDP-1 connected card2-USB-2 connected
write_monitors "$clamshell"
OMARCHY_TEST_DOCKED_ACTION=suspend sync_inhibit
[[ ! -s $call_log ]] || fail "a docked lid set to suspend takes no inhibitor" "$(<"$call_log")"
sync_inhibit
held || fail "the inhibitor is taken under the default docked action"
OMARCHY_TEST_DOCKED_ACTION=suspend sync_inhibit
! held || fail "changing the docked lid action away from ignore releases the inhibitor"
pass "the inhibitor follows logind's docked lid action"

# logind lists DVI-A and Composite, but a missing comma fuses them into one
# entry, so they are uncounted too.
for connector in DVI-A-1 Composite-1; do
  reset_unit
  write_connectors card0-LVDS-1 connected "card0-$connector" connected
  write_monitors "[{\"name\":\"LVDS-1\",\"disabled\":true},{\"name\":\"$connector\",\"disabled\":false}]"
  sync_inhibit
  held || fail "$connector takes the inhibitor"
done
pass "every external connector type logind misses takes the inhibitor"

# Held alongside a counted display too, or unplugging that one would let logind
# suspend before the watcher could take over.
reset_unit
write_connectors card2-eDP-1 connected card2-HDMI-A-1 connected card2-USB-2 connected
write_monitors '[{"name":"eDP-1","disabled":true},{"name":"HDMI-A-1","disabled":false},{"name":"USB-2","disabled":false}]'
sync_inhibit
held || fail "a USB-C display beside an HDMI one still holds the inhibitor"
pass "a USB-C display beside an HDMI one still holds the inhibitor"

# The monitor watcher is what keeps the inhibitor in step as displays come and go.
cat >"$fake_bin/socat" <<'SH'
#!/bin/bash

exec cat "$OMARCHY_TEST_EVENTS"
SH

for command in omarchy-hyprland-monitor-clamshell omarchy-hyprland-monitor-external-active; do
  cat >"$fake_bin/$command" <<'SH'
#!/bin/bash

exit 0
SH
done

cat >"$fake_bin/omarchy-hyprland-monitor-modeless" <<'SH'
#!/bin/bash

exit 1
SH

chmod +x "$fake_bin"/*
ln -s "$lid_inhibit" "$fake_bin/omarchy-system-lid-inhibit"

start_watcher() {
  rm -f "$events"
  mkfifo "$events"

  PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$test_tmp" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_EVENTS="$events" \
    "$ROOT/bin/omarchy-hyprland-monitor-watch" &
  watch_pid=$!

  exec {events_fd}>"$events"
}

await() {
  local waited

  for (( waited = 0; waited < 100; waited++ )); do
    "$@" && return 0
    sleep 0.05
  done

  return 1
}

released() {
  ! held
}

reset_unit
write_connectors card2-eDP-1 connected card2-USB-2 connected
write_monitors "$clamshell"
start_watcher

await held || fail "the watcher takes the inhibitor at startup with a USB-C display attached"
pass "the watcher takes the inhibitor at startup with a USB-C display attached"

write_connectors card2-eDP-1 connected card2-USB-2 disconnected
write_monitors '[{"name":"eDP-1","disabled":false}]'
printf 'monitorremovedv2>>1,USB-2,Display\n' >&"$events_fd"
await released || fail "the watcher releases the inhibitor when the USB-C display is removed"
pass "the watcher releases the inhibitor when the USB-C display is removed"

write_connectors card2-eDP-1 connected card2-USB-2 connected
write_monitors "$clamshell"
printf 'monitoraddedv2>>2,USB-2,Display\n' >&"$events_fd"
await held || fail "the watcher takes the inhibitor again when the USB-C display returns"

# Across the delayed retries and the docked poll, one unit stays the only one.
sleep 3.5
(( $(count_calls start) == 2 && $(count_calls stop) == 1 && $(count_calls refused) == 0 )) ||
  fail "the watcher never stacks inhibitors across its retries and poll" "$(<"$call_log")"
pass "the watcher keeps one inhibitor across hotplugs, retries and its poll"

stop_watcher
