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
SH
  chmod +x "$mock_bin/omarchy-hyprland-monitor-clamshell"
}

# Called with no budget to exercise the value derived from logind's window.
run_sleep_lock() {
  local args=()
  [[ -n ${1:-} ]] && args=("$1")

  start_us=${EPOCHREALTIME//[!0-9]/}
  set +e
  CALL_LOG="$call_log" STATE_DIR="$state_dir" PATH="$mock_bin:$PATH" \
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
if [[ $* == "lock lock" ]]; then
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

[[ ${calls[0]} == "shell lock lock" ]] ||
  fail "sleep lock requests the session lock first" "first call: ${calls[0]}"
pass "sleep lock requests the session lock first"

[[ ${calls[1]} == "clamshell" && ${calls[2]} == "shell lock status" ]] ||
  fail "sleep lock checks security after clamshell reconciliation"
pass "sleep lock checks security after clamshell reconciliation"

(( elapsed_us < 1500000 )) ||
  fail "sleep lock bounds a stalled clamshell sync" "elapsed: ${elapsed_us}us"
pass "sleep lock bounds a stalled clamshell sync"

# A shell that never secures the session must give up inside the budget rather
# than hold logind's delay inhibitor open.
setup_scenario never_secure
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
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

# The contract is the budget plus at most one poll interval, since the pause
# between polls is not itself clipped. Derived budgets hold back at least a
# second for logind, and that reserve is what the overshoot has to fit inside.
# Hold the whole process to it rather than to an interval or two: wall time also
# counts startup, every poll's forks and the notification, which stretch by
# hundreds of milliseconds under load. Past the
# reserve, logind would suspend mid-lock, so that is a failure, not a flake.
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

if [[ $* == "lock lock" ]]; then
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
  [[ $call == "shell lock lock" ]] && (( ++requests ))
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

if [[ $* == "lock lock" ]]; then
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
  [[ $call == "shell lock lock" ]] && (( ++requests ))
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
if [[ $* == "lock lock" ]]; then
  printf 'missing-pam\n'
fi
exit 0
SH
chmod +x "$mock_bin/omarchy-shell"
mock_clamshell

run_sleep_lock 4000

(( exit_status != 0 )) ||
  fail "sleep lock fails fast when the shell cannot lock at all"
(( elapsed_us < 500000 )) ||
  fail "sleep lock fails fast when the shell cannot lock at all" "elapsed: ${elapsed_us}us"
pass "sleep lock fails fast when the shell cannot lock at all"

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
# is also the one that shows which budget was derived: the script names it when
# it gives up. Read it from there rather than from wall time, which also counts
# process startup, the budget derivation and the post-deadline notification,
# all of which stretch under load. Wall time is then held to the contract that
# matters, releasing the inhibitor inside the window logind enforces.
reported_budget_ms() {
  sed -n 's/.*within \([0-9]*\)ms.*/\1/p' "$journal_log"
}

never_secures() {
  cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
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
setup_scenario derived_short_window
mock_logind_window 2000000
never_secures

run_sleep_lock

[[ $(reported_budget_ms) == 1000 ]] ||
  fail "sleep lock derives its budget from logind's window" "journal: $(< "$journal_log")"
(( elapsed_us < 2000000 )) ||
  fail "sleep lock derives its budget from logind's window" "elapsed: ${elapsed_us}us"
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

[[ $(reported_budget_ms) == 4000 ]] ||
  fail "sleep lock falls back to a conservative budget" "journal: $(< "$journal_log")"
(( elapsed_us < 5000000 )) ||
  fail "sleep lock falls back to a conservative budget" "elapsed: ${elapsed_us}us"
pass "sleep lock falls back to a conservative budget when logind cannot be read"

# The cap is only reachable because the shipped drop-in widens logind's window
# past it. Ship one without the other and the cap is dead weight.
inhibit_delay=$(sed -n 's/^InhibitDelayMaxSec=//p' "$ROOT/etc/systemd/logind.conf.d/20-inhibit-delay.conf")
budget_cap_ms=$(sed -n 's/^budget_cap_ms=//p' "$sleep_lock")

# A hand-raised window must not strand a closed laptop awake in a bag. This
# scenario runs for the whole capped budget by design.
setup_scenario capped_window
mock_logind_window 600000000
never_secures

run_sleep_lock

(( exit_status != 0 )) ||
  fail "sleep lock caps the budget a huge logind window would allow"
[[ -n $budget_cap_ms && $(reported_budget_ms) == "$budget_cap_ms" ]] ||
  fail "sleep lock caps the budget a huge logind window would allow" \
    "cap: ${budget_cap_ms:-unset} journal: $(< "$journal_log")"
(( elapsed_us < ${inhibit_delay:-0} * 1000000 )) ||
  fail "sleep lock caps the budget a huge logind window would allow" \
    "elapsed: ${elapsed_us}us window: ${inhibit_delay:-unset}s"
pass "sleep lock caps the budget a huge logind window would allow"

[[ -n $inhibit_delay && -n $budget_cap_ms ]] ||
  fail "sleep lock cap and logind window are both declared" \
    "window: ${inhibit_delay:-unset} cap: ${budget_cap_ms:-unset}"
(( budget_cap_ms < inhibit_delay * 1000 )) ||
  fail "sleep lock cap leaves logind room to act" \
    "cap: ${budget_cap_ms}ms window: ${inhibit_delay}s"
pass "sleep lock cap stays inside the shipped logind inhibitor window"
