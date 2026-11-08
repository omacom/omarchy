#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_lock="$ROOT/bin/omarchy-system-sleep-lock"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Each scenario gets its own mock PATH and call log, then runs the sleep lock
# with a short budget so a stalled shell cannot slow the suite down.
setup_scenario() {
  scenario_dir="$tmpdir/$1"
  mock_bin="$scenario_dir/bin"
  call_log="$scenario_dir/calls"
  state_dir="$scenario_dir/state"
  notify_log="$scenario_dir/notifications"
  journal_log="$scenario_dir/journal"
  mkdir -p "$mock_bin" "$state_dir"
  : >"$notify_log"
  : >"$journal_log"

  # The budget is derived from logind, so pin the window rather than letting the
  # host's own configuration decide what these scenarios are testing.
  mock_logind_window 5000000

  # Capture the desktop warning instead of firing a real one at whoever is
  # running the suite.
  cat >"$mock_bin/omarchy-notification-send" <<SH
#!/bin/bash

printf '%s\n' "\$*" >>"$notify_log"
SH
  chmod +x "$mock_bin/omarchy-notification-send"
}

mock_logind_window() {
  cat >"$mock_bin/busctl" <<SH
#!/bin/bash

printf 't %s\n' $1
SH
  chmod +x "$mock_bin/busctl"
}

mock_clamshell() {
  cat >"$mock_bin/omarchy-hyprland-monitor-clamshell" <<SH
#!/bin/bash

echo clamshell >>"\$CALL_LOG"
sleep ${1:-0}
touch "\$CALL_LOG.clamshell-done"
SH
  chmod +x "$mock_bin/omarchy-hyprland-monitor-clamshell"
}

# Called with no budget to exercise the value derived from logind's window.
run_sleep_lock() {
  local args=()
  [[ -n ${1:-} ]] && args=("$1")

  start_us=${EPOCHREALTIME//[!0-9]/}
  set +e
  CALL_LOG="$call_log" STATE_DIR="$state_dir" XDG_RUNTIME_DIR="$state_dir" WAYLAND_DISPLAY=fixture-wayland PATH="$mock_bin:$PATH" \
    "$sleep_lock" "${args[@]}" 2>"$journal_log"
  exit_status=$?
  set -e
  elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))

  mapfile -t calls <"$call_log"
}

# A responsive shell locks immediately, even when the clamshell sync stalls.
setup_scenario responsive
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'ok\n'
elif [[ $* == "lock status" ]]; then
  printf '{"secure":true}\n'
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell 2

run_sleep_lock 4000

(( exit_status == 0 )) ||
  fail "sleep lock succeeds once the session reports secure" "exit: $exit_status"
pass "sleep lock succeeds once the session reports secure"

[[ ${calls[0]} == "shell lock prepareSleep" ]] ||
  fail "sleep lock requests the session lock first" "first call: ${calls[0]}"
pass "sleep lock requests the session lock first"

[[ ${calls[1]} == "clamshell" && ${calls[2]} == "shell lock status" ]] ||
  fail "sleep lock checks security after clamshell reconciliation"
pass "sleep lock checks security after clamshell reconciliation"

# The stalled sync only finishes if the sleep lock waited it out.
[[ ! -e $call_log.clamshell-done ]] ||
  fail "sleep lock bounds a stalled clamshell sync" "the sleep lock waited for it"
pass "sleep lock bounds a stalled clamshell sync"

# A shell that never secures the session must give up inside the budget rather
# than hold logind's delay inhibitor open.
setup_scenario never_secure
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'ok\n'
elif [[ $* == "lock status" ]]; then
  printf '{"secure":false}\n'
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 1500

(( exit_status != 0 )) ||
  fail "sleep lock reports failure when the session never secures"
pass "sleep lock reports failure when the session never secures"

# The script may overshoot its budget by a poll interval, since the pause
# between polls is not itself clipped. What it must never overrun is the full
# second derived budgets hold back for logind: past that, logind suspends
# mid-lock. Bounding by that reserve rather than by the interval leaves room for
# process startup on a loaded machine, and still catches a wait that ignores
# its deadline.
(( elapsed_us <= 2500000 )) ||
  fail "sleep lock gives up within its budget" "elapsed: ${elapsed_us}us"
pass "sleep lock gives up within its budget"

polls=0
for call in "${calls[@]}"; do
  [[ $call == "shell lock status" ]] && (( ++polls ))
done
(( polls > 1 )) ||
  fail "sleep lock keeps polling until the deadline" "polls: $polls"
pass "sleep lock keeps polling until the deadline"

# A lock request that times out may never have landed, so the wait retries it
# instead of suspending an unlocked session over one slow IPC call.
setup_scenario retry_lock
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"

if [[ $* == "lock prepareSleep" ]]; then
  if [[ -f $STATE_DIR/requested ]]; then
    touch "$STATE_DIR/locked"
    printf 'ok\n'
    exit 0
  fi
  touch "$STATE_DIR/requested"
  exit 1
fi

if [[ $* == "lock status" ]]; then
  if [[ -f $STATE_DIR/locked ]]; then
    printf '{"secure":true}\n'
  else
    printf '{"secure":false}\n'
  fi
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 4000

(( exit_status == 0 )) ||
  fail "sleep lock retries a failed lock request" "exit: $exit_status"
pass "sleep lock retries a failed lock request"

requests=0
for call in "${calls[@]}"; do
  [[ $call == "shell lock prepareSleep" ]] && (( ++requests ))
done
(( requests == 2 )) ||
  fail "sleep lock stops requesting once the lock lands" "requests: $requests"
pass "sleep lock stops requesting once the lock lands"

# A request can land even when its IPC response times out. Pending status proves
# that Quickshell is already securing the session, so do not spend the remaining
# inhibitor budget sending the same request again.
setup_scenario pending_lock
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"

if [[ $* == "lock prepareSleep" ]]; then
  exit 1
fi

if [[ $* == "lock status" ]]; then
  if [[ -f $STATE_DIR/pending_seen ]]; then
    printf '{"secure":true}\n'
  else
    touch "$STATE_DIR/pending_seen"
    printf '{"secure":false,"requested":true,"pending":true,"sessionLocked":false}\n'
  fi
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 4000

(( exit_status == 0 )) ||
  fail "sleep lock succeeds after observing a pending lock" "exit: $exit_status"
pass "sleep lock succeeds after observing a pending lock"

requests=0
for call in "${calls[@]}"; do
  [[ $call == "shell lock prepareSleep" ]] && (( ++requests ))
done
(( requests == 1 )) ||
  fail "sleep lock does not retry an observed pending lock" "requests: $requests"
pass "sleep lock does not retry an observed pending lock"

# The shell reports a refusal on stdout with a zero exit, so a lock it can never
# perform has to end the wait instead of burning the rest of the window on it.
setup_scenario missing_pam
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'missing-pam\n'
fi
exit 0
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 4000

(( exit_status != 0 )) ||
  fail "sleep lock fails when the shell cannot lock at all"
pass "sleep lock fails when the shell cannot lock at all"

[[ ${calls[*]} != *"lock status"* ]] ||
  fail "sleep lock stops polling a shell that refused to lock" "calls: ${calls[*]}"
pass "sleep lock stops polling a shell that refused to lock"

# logind suspends regardless of this exit status, so an unlocked suspend is
# otherwise invisible. The warning is the only trace the user ever sees, and the
# journal line is what makes it diagnosable after the fact.
grep -qF "did not lock before suspend" "$notify_log" ||
  fail "sleep lock warns that the session was left unlocked" \
    "notifications: $(< "$notify_log")"
pass "sleep lock warns that the session was left unlocked"

grep -qF "suspending without a secure lock" "$journal_log" ||
  fail "sleep lock records the unlocked suspend in the journal" \
    "journal: $(< "$journal_log")"
pass "sleep lock records the unlocked suspend in the journal"

# A never-securing shell is the scenario that runs out the whole budget, so it
# is also the one that shows which budget was derived.
never_secures() {
  cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'ok\n'
elif [[ $* == "lock status" ]]; then
  printf '{"secure":false,"requested":true,"pending":true,"sessionLocked":false}\n'
fi
SH
  chmod +x "$mock_bin/omarchy-shell"
  mock_clamshell
}

# The drop-in only counts once logind has reloaded it, and a machine can carry
# its own override, so the budget follows whatever logind actually enforces.
# These derivation scenarios run a scratch copy with the cap, the assumed
# fallback window, and the reserve floor all at a quarter of their real
# values (and mock windows to match), so the budgets come out at a quarter
# length. The journal names the budget each one derived.
sleep_lock_shipped="$sleep_lock"
sleep_lock="$tmpdir/sleep-lock-fast"
sed -e 's/^budget_cap_ms=12000$/budget_cap_ms=3000/' \
  -e 's/window=5000000/window=1250000/' \
  -e 's/window \/ 5 > 1000 ? window \/ 5 : 1000/window \/ 5 > 250 ? window \/ 5 : 250/' \
  "$sleep_lock_shipped" >"$sleep_lock"
for scaled in '^budget_cap_ms=3000$' 'window=1250000' 'window / 5 > 250 ? window / 5 : 250'; do
  grep -q -- "$scaled" "$sleep_lock" ||
    fail "the scratch sleep lock scales its budgets down" "no match for: $scaled"
done
chmod +x "$sleep_lock"
setup_scenario derived_short_window
mock_logind_window 500000
never_secures

run_sleep_lock

grep -qF "within 250ms" "$journal_log" ||
  fail "sleep lock derives its budget from logind's window" "journal: $(<"$journal_log")"
pass "sleep lock derives its budget from logind's window"

# Without a readable window there is no way to know what logind will tolerate,
# so fall back to the budget that was safe before the drop-in existed.
setup_scenario unreadable_window
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin/busctl"
never_secures

run_sleep_lock

grep -qF "within 1000ms" "$journal_log" ||
  fail "sleep lock falls back to a conservative budget" "journal: $(<"$journal_log")"
pass "sleep lock falls back to a conservative budget when logind cannot be read"

# A hand-raised window must not strand a closed laptop awake in a bag. This
# scenario runs for the whole capped budget by design (a quarter of it here).
setup_scenario capped_window
mock_logind_window 150000000
never_secures

run_sleep_lock

(( exit_status != 0 )) ||
  fail "sleep lock caps the budget a huge logind window would allow"
grep -qF "within 3000ms" "$journal_log" ||
  fail "sleep lock caps the budget a huge logind window would allow" \
    "journal: $(<"$journal_log")"
pass "sleep lock caps the budget a huge logind window would allow"
sleep_lock="$sleep_lock_shipped"

# The cap is only reachable because the shipped drop-in widens logind's window
# past it. Ship one without the other and the cap is dead weight.
inhibit_delay=$(sed -n 's/^InhibitDelayMaxSec=//p' "$ROOT/etc/systemd/logind.conf.d/20-inhibit-delay.conf")
budget_cap_ms=$(sed -n 's/^budget_cap_ms=//p' "$sleep_lock")

[[ -n $inhibit_delay && -n $budget_cap_ms ]] ||
  fail "sleep lock cap and logind window are both declared" \
    "window: ${inhibit_delay:-unset} cap: ${budget_cap_ms:-unset}"
(( budget_cap_ms < inhibit_delay * 1000 )) ||
  fail "sleep lock cap leaves logind room to act" \
    "cap: ${budget_cap_ms}ms window: ${inhibit_delay}s"
pass "sleep lock cap stays inside the shipped logind inhibitor window"

# The fingerprint release is part of the inhibitor, not a side channel. A
# session that is already secure still has to wait out a held claim, and the
# request is repeated so a probe stopped with SIGTERM can be asked again.
setup_scenario claim_held
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'ok\n'
elif [[ $* == "lock status" ]]; then
  if [[ ! -f $STATE_DIR/saw_held ]]; then
    touch "$STATE_DIR/saw_held"
    printf '{"secure":true,"fingerprintSleepReady":false}\n'
  else
    printf '{"secure":true,"fingerprintSleepReady":true}\n'
  fi
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 4000

(( exit_status == 0 )) ||
  fail "sleep lock waits for the fingerprint claim before releasing the inhibitor" "exit: $exit_status"
pass "sleep lock waits for the fingerprint claim before releasing the inhibitor"

held_requests=0
status_polls=0
for call in "${calls[@]}"; do
  [[ $call == "shell lock prepareSleep" ]] && (( ++held_requests ))
  [[ $call == "shell lock status" ]] && (( ++status_polls ))
done
(( held_requests >= 2 )) ||
  fail "sleep lock asks for the release again while the claim is held" "requests: $held_requests"
(( status_polls >= 2 )) ||
  fail "sleep lock does not treat the first secure status as the claim release" "polls: $status_polls"
pass "sleep lock keeps the inhibitor until the claim is released"

# A claim that never drains must not be told to the user as a failed lock.
# logind suspends when the inhibitor process exits, secure or not.
setup_scenario claim_stuck
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock prepareSleep" ]]; then
  printf 'ok\n'
elif [[ $* == "lock status" ]]; then
  printf '{"secure":true,"fingerprintSleepReady":false}\n'
fi
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 1500

(( exit_status == 0 )) ||
  fail "a secure session with a stuck claim still lets suspend proceed" "exit: $exit_status"
grep -qF "fingerprint claim still held" "$journal_log" ||
  fail "a stuck claim is recorded without calling the session unlocked" "journal: $(<"$journal_log")"
[[ ! -s $notify_log ]] ||
  fail "a stuck claim does not raise the unlocked-suspend warning" "notifications: $(<"$notify_log")"
pass "a stuck fingerprint claim does not masquerade as an unlocked suspend"

# An older shell has no prepareSleep. The lock still has to be requested, or
# the update that ships this sleep lock ahead of the shell suspends unlocked.
setup_scenario old_shell
ln -s "$ROOT/bin/omarchy-shell" "$mock_bin/omarchy-shell"
cat >"$mock_bin/qs" <<'SH'
#!/bin/bash

args=("$@")
method=${args[-1]}
printf 'shell lock %s\n' "$method" >>"$CALL_LOG"
case $method in
  prepareSleep) printf 'Function not found.\n' ;;
  lock) printf 'ok\n' ;;
  status) printf '{"secure":true}\n' ;;
esac
SH
chmod +x "$mock_bin/qs"
mock_clamshell

run_sleep_lock 4000

(( exit_status == 0 )) ||
  fail "sleep lock falls back to an ordinary lock on an older shell" "exit: $exit_status"
[[ ${calls[*]} == *"shell lock prepareSleep"* && ${calls[*]} == *"shell lock lock"* ]] ||
  fail "sleep lock asks the old shell to lock after prepareSleep is missing" "calls: ${calls[*]}"
pass "sleep lock falls back to an ordinary lock on an older shell"
