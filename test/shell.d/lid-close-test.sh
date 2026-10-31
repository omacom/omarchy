#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lid_close="$ROOT/bin/omarchy-system-lid-close"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# closed/docked are the two facts logind uses to decide whether a lid close
# suspends, so each scenario pins them and records what the lid handler did.
setup_scenario() {
  scenario_dir="$tmpdir/$1"
  mock_bin="$scenario_dir/bin"
  call_log="$scenario_dir/calls"
  mkdir -p "$mock_bin"
  : >"$call_log"

  local closed="$2" docked="$3"

  cat >"$mock_bin/omarchy-hw-laptop-closed" <<SH
#!/bin/bash
exit $closed
SH
  cat >"$mock_bin/omarchy-hw-external-monitors" <<SH
#!/bin/bash
exit $docked
SH
  for command in omarchy-system-lock omarchy-hyprland-monitor-clamshell; do
    cat >"$mock_bin/$command" <<SH
#!/bin/bash
echo $command >>"\$CALL_LOG"
SH
  done
  printf '#!/bin/bash\n' >"$mock_bin/logger"
  chmod +x "$mock_bin"/*
}

run_lid_close() {
  mkdir -p "$scenario_dir/runtime"
  CALL_LOG="$call_log" XDG_RUNTIME_DIR="$scenario_dir/runtime" PATH="$mock_bin:$PATH" "$lid_close"
  mapfile -t calls <"$call_log"
}

# An undocked lid close is about to suspend, and logind's inhibitor window is a
# timer rather than a promise, so the lock has to start now instead of waiting
# for PrepareForSleep.
setup_scenario undocked 0 1
run_lid_close

[[ ${calls[0]} == "omarchy-system-lock" ]] ||
  fail "undocked lid close locks before anything else" "calls: ${calls[*]}"
pass "undocked lid close locks before anything else"

[[ ${calls[1]} == "omarchy-hyprland-monitor-clamshell" ]] ||
  fail "undocked lid close still reconciles displays" "calls: ${calls[*]}"
pass "undocked lid close still reconciles displays"

# A docked lid close is clamshell mode: logind leaves the machine awake and the
# session stays in use on the external display, so locking it would be wrong.
setup_scenario docked 0 0
run_lid_close

[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "docked lid close does not lock the session" "calls: ${calls[*]}"
pass "docked lid close does not lock the session"

[[ ${calls[0]} == "omarchy-hyprland-monitor-clamshell" ]] ||
  fail "docked lid close reconciles displays" "calls: ${calls[*]}"
pass "docked lid close reconciles displays"

# Hyprland can replay a switch binding when the lid is already open, and an
# open lid must never lock the machine the user is sitting at.
setup_scenario open 1 1
run_lid_close

[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "an open lid never locks the session" "calls: ${calls[*]}"
pass "an open lid never locks the session"

# The lid handler runs from a Hyprland binding, so a lock that hangs or fails
# must not stop the display reconciliation behind it.
setup_scenario failing_lock 0 1
cat >"$mock_bin/omarchy-system-lock" <<'SH'
#!/bin/bash
echo omarchy-system-lock >>"$CALL_LOG"
exit 1
SH
chmod +x "$mock_bin/omarchy-system-lock"
run_lid_close

[[ ${calls[1]} == "omarchy-hyprland-monitor-clamshell" ]] ||
  fail "a failing lock still reconciles displays" "calls: ${calls[*]}"
pass "a failing lock still reconciles displays"

# omarchy-system-hibernate holds its marker until resume. A lid closed while
# that encrypted hibernate is being entered must neither lock (resume already
# asks for the LUKS passphrase) nor touch the displays, but only while logind
# confirms a hibernate is being prepared; any doubt locks as usual.
hold_hibernate_marker() {
  local marker="$scenario_dir/runtime/omarchy-hibernate-boot-auth.lock"
  local ready="$scenario_dir/marker-held"
  mkdir -p "$scenario_dir/runtime"
  (
    exec 9>>"$marker"
    flock 9
    touch "$ready"
    exec sleep 30
  ) &
  marker_holder_pid=$!
  for _ in {1..100}; do
    [[ -e $ready ]] && break
    sleep 0.01
  done
  [[ -e $ready ]] || fail "lid close test acquires the hibernate marker"
}

release_hibernate_marker() {
  kill "$marker_holder_pid" 2>/dev/null || true
  wait "$marker_holder_pid" 2>/dev/null || true
}

mock_logind() {
  local preparing="$1" operation="$2"
  cat >"$mock_bin/busctl" <<SH
#!/bin/bash
printf 'b %s\\n(st) "%s" 1791700000000000\\n' "$preparing" "$operation"
SH
  chmod +x "$mock_bin/busctl"
}

setup_scenario hibernating 0 1
mock_logind true hibernate
hold_hibernate_marker
run_lid_close
release_hibernate_marker

(( ${#calls[@]} == 0 )) ||
  fail "lid close during an encrypted hibernate neither locks nor reconciles displays" "calls: ${calls[*]}"
pass "lid close during an encrypted hibernate neither locks nor reconciles displays"

setup_scenario hibernate_marker_suspending 0 1
mock_logind true suspend
hold_hibernate_marker
run_lid_close
release_hibernate_marker

[[ ${calls[0]:-} == "omarchy-system-lock" ]] ||
  fail "a held hibernate marker does not stop the lock for a suspend" "calls: ${calls[*]}"
pass "a held hibernate marker does not stop the lock for a suspend"

# ScheduledShutdown keeps naming the last sleep after logind is done with it.
setup_scenario hibernate_marker_not_preparing 0 1
mock_logind false hibernate
hold_hibernate_marker
run_lid_close
release_hibernate_marker

[[ ${calls[0]:-} == "omarchy-system-lock" ]] ||
  fail "a stale hibernate operation in logind does not stop the lock" "calls: ${calls[*]}"
pass "a stale hibernate operation in logind does not stop the lock"

setup_scenario stale_hibernate_marker 0 1
mock_logind true hibernate
mkdir -p "$scenario_dir/runtime"
: >"$scenario_dir/runtime/omarchy-hibernate-boot-auth.lock"
run_lid_close

[[ ${calls[0]:-} == "omarchy-system-lock" ]] ||
  fail "a hibernate marker without a live holder does not stop the lock" "calls: ${calls[*]}"
pass "a hibernate marker without a live holder does not stop the lock"

setup_scenario logind_unreachable 0 1
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin/busctl"
hold_hibernate_marker
run_lid_close
release_hibernate_marker

[[ ${calls[0]:-} == "omarchy-system-lock" ]] ||
  fail "lid close locks when logind cannot confirm the hibernate" "calls: ${calls[*]}"
pass "lid close locks when logind cannot confirm the hibernate"
