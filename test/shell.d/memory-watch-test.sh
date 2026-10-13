#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
dummy_pids=()
cleanup() {
  local pid
  for pid in "${dummy_pids[@]}"; do
    # Some have exited already, and errexit still holds in this trap.
    kill -CONT "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
  done
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

mkdir -p "$TMPDIR/bin"
SYSTEMCTL_LOG="$TMPDIR/systemctl-log"
NOTIFY_LOG="$TMPDIR/notify-log"

# Fails any call whose arguments contain SYSTEMCTL_FAIL, when that is set.
cat >"$TMPDIR/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
[[ -z ${SYSTEMCTL_FAIL:-} || " $* " != *" $SYSTEMCTL_FAIL "* ]]
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH

# The user journal answers a follow with JOURNAL_USER, the system journal any
# other query with JOURNAL_SYSTEM. Never the real journals.
cat >"$TMPDIR/bin/journalctl" <<'SH'
#!/bin/bash
if [[ " $* " == *" --user "* ]]; then
  [[ -n ${JOURNAL_USER:-} ]] && printf '%s\n' "$JOURNAL_USER"
else
  [[ -n ${JOURNAL_SYSTEM:-} ]] && printf '%s\n' "$JOURNAL_SYSTEM"
fi
exit 0
SH

chmod +x "$TMPDIR/bin/"*

test_home="$TMPDIR/home"
flag="$test_home/.local/state/omarchy/toggles/memory-watch-on"
state="$test_home/.local/state/omarchy/memory-watch"
installed_unit="$test_home/.config/systemd/user/omarchy-memory-watch.service"

run() {
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" SYSTEMCTL_LOG="$SYSTEMCTL_LOG" NOTIFY_LOG="$NOTIFY_LOG" \
    HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" OMARCHY_PATH="$ROOT" "$@"
}

# Toggle: opt-in, so the first toggle turns it on.
run "$ROOT/bin/omarchy-toggle-memory-watch"
[[ -f $flag ]] || fail "the first memory watchdog toggle turns it on"
cmp -s "$ROOT/default/systemd/user/omarchy-memory-watch.service" "$installed_unit" ||
  fail "turning the memory watchdog on installs its unit, which no package ships"
grep -Fqx -- "--user enable --now omarchy-memory-watch.service" "$SYSTEMCTL_LOG" ||
  fail "enabling the memory watchdog starts it now and at every login"
pass "memory watchdog toggle installs and enables the watcher"

: >"$SYSTEMCTL_LOG"
run "$ROOT/bin/omarchy-toggle-memory-watch"
[[ ! -f $flag ]] || fail "the second memory watchdog toggle turns it off"
grep -Fqx -- "--user disable --now omarchy-memory-watch.service" "$SYSTEMCTL_LOG" ||
  fail "disabling the memory watchdog stops it now and at every login"
[[ ! -e $installed_unit ]] || fail "turning the memory watchdog off removes the unit it installed"
pass "memory watchdog toggle disables and removes the watcher"

# A watchdog that did not start is not on: the flag and the unit go again, and
# the toast says it failed. is-active catches a unit whose condition failed,
# which starts nothing and still reports success.
for failing in enable is-active; do
  : >"$NOTIFY_LOG"
  if run env SYSTEMCTL_FAIL="$failing" "$ROOT/bin/omarchy-toggle-memory-watch" on; then
    fail "the toggle fails when systemctl $failing does"
  fi
  [[ ! -f $flag ]] || fail "a watchdog that did not start ($failing failed) leaves the toggle off"
  [[ ! -e $installed_unit ]] || fail "a watchdog that did not start ($failing failed) leaves no unit behind"
  grep -Fq 'Memory watchdog failed to start' "$NOTIFY_LOG" ||
    fail "a watchdog that did not start ($failing failed) says so" "$(cat "$NOTIFY_LOG")"
  ! grep -Fq 'Memory watchdog enabled' "$NOTIFY_LOG" ||
    fail "a watchdog that did not start ($failing failed) never says it is enabled" "$(cat "$NOTIFY_LOG")"
done
pass "memory watchdog toggle rolls back when the watcher does not start"

# Fake readings: swap 55% (past the 50% warning, short of anything later and
# of oomd's 90%), RAM 82% used, past the warning's 80%, no stall.
fake="$TMPDIR/fake"
mkdir -p "$fake"
cat >"$fake/meminfo" <<'EOF'
MemTotal:        1000000 kB
MemAvailable:     180000 kB
SwapTotal:       1000000 kB
SwapFree:         450000 kB
EOF
printf 'some avg10=0.00 avg60=0.00 avg300=0.00 total=0\nfull avg10=0.00 avg60=0.00 avg300=0.00 total=0\n' >"$fake/pressure"

watch() {
  : >"$NOTIFY_LOG"
  # Nothing the watcher could act on outside this test is ever picked.
  run env OMARCHY_MEMORY_MEMINFO="$fake/meminfo" OMARCHY_MEMORY_PRESSURE="$fake/pressure" \
    OMARCHY_MEMORY_APP_PRESSURE="$fake/app-pressure" OMARCHY_MEMORY_INTERVAL=0.2 \
    OMARCHY_MEMORY_ONLY='^omarchy-memtest-nothing$' "$@" \
    timeout 3 "$ROOT/bin/omarchy-memory-watch" 2>/dev/null || true
  sleep 0.3
}

watch
grep -Fq 'Memory is running out' "$NOTIFY_LOG" ||
  fail "swap past the warning line raises a toast before oomd's 90%" "$(cat "$NOTIFY_LOG")"
grep -Fq 'Swap 55% and RAM 82% used; systemd-oomd kills an app once both pass 90%.' "$NOTIFY_LOG" ||
  fail "the warning says how close swap and RAM are to oomd's line, which needs both" "$(cat "$NOTIFY_LOG")"
[[ -s $state/last-top.json ]] || fail "the watcher keeps what memory looked like, to name a later kill"
pass "memory watchdog warns as swap nears oomd's line"

# app.slice stalling counts even when the system as a whole does not.
printf 'MemTotal: 1000000 kB\nMemAvailable: 50000 kB\nSwapTotal: 1000000 kB\nSwapFree: 1000000 kB\n' >"$fake/meminfo"
printf 'some avg10=30.00 avg60=0.00 avg300=0.00 total=0\nfull avg10=25.00 avg60=0.00 avg300=0.00 total=0\n' >"$fake/app-pressure"
watch
grep -Fq 'stalling (25%)' "$NOTIFY_LOG" ||
  fail "app.slice's own stall, the one oomd reads, raises the warning" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog warns on app.slice pressure"

printf 'MemTotal: 1000000 kB\nMemAvailable: 900000 kB\nSwapTotal: 0 kB\nSwapFree: 0 kB\n' >"$fake/meminfo"
rm -f "$fake/app-pressure"
watch
[[ ! -s $NOTIFY_LOG ]] || fail "plenty of memory raises no toast" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog stays quiet with memory to spare"

# Swap alone raises nothing: zram is sized to RAM, so it is often half used or
# more while RAM is fine.
printf 'MemTotal: 1000000 kB\nMemAvailable: 500000 kB\nSwapTotal: 1000000 kB\nSwapFree: 100000 kB\n' >"$fake/meminfo"
watch
[[ ! -s $NOTIFY_LOG ]] || fail "swap 90% used with RAM half free raises no toast" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog ignores swap while RAM is fine"

# oomd's stall line has no RAM condition, so a stall held at low RAM use warns
# too: thrashing on a cgroup's limit, say.
printf 'MemTotal: 1000000 kB\nMemAvailable: 900000 kB\nSwapTotal: 0 kB\nSwapFree: 0 kB\n' >"$fake/meminfo"
printf 'some avg10=40.00 avg60=0.00 avg300=0.00 total=0\nfull avg10=30.00 avg60=0.00 avg300=0.00 total=0\n' >"$fake/app-pressure"
watch
grep -Fq 'RAM 10% used and apps stalling (30%)' "$NOTIFY_LOG" ||
  fail "a stall held at low RAM use warns before oomd's stall line" "$(cat "$NOTIFY_LOG")"
rm -f "$fake/app-pressure"
pass "memory watchdog warns on a held stall at any RAM use"

# The kill follower ends when the journal it follows goes away; the watcher
# starts it again. The fake journal here ends every follow at once.
: >"$state/watch.log"
watch OMARCHY_MEMORY_KILLS_RESTART_GAP=0
grep -Fq 'oomd kill follower stopped; starting it again' "$state/watch.log" ||
  fail "the watcher starts the kill follower again when it stops" "$(cat "$state/watch.log")"
pass "memory watchdog restarts the oomd kill follower"

# One reading per sample, in order: meminfo and the pressure are FIFOs, which
# the watcher opens in that order once a sample, and each write below waits
# for its open. The write after the last sample returns only once that sample
# was acted on.
fifo="$TMPDIR/meminfo.fifo"
pressure_fifo="$TMPDIR/pressure.fifo"
fed_watch() {
  : >"$NOTIFY_LOG"
  rm -f "$fifo" "$pressure_fifo"
  mkfifo "$fifo" "$pressure_fifo"
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" SYSTEMCTL_LOG="$SYSTEMCTL_LOG" NOTIFY_LOG="$NOTIFY_LOG" \
    HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" OMARCHY_PATH="$ROOT" \
    OMARCHY_MEMORY_MEMINFO="$fifo" OMARCHY_MEMORY_PRESSURE="$pressure_fifo" \
    OMARCHY_MEMORY_APP_PRESSURE="$fake/app-pressure" OMARCHY_MEMORY_INTERVAL=0.2 \
    OMARCHY_MEMORY_ONLY='^omarchy-memtest-nothing$' env "$@" \
    timeout -k 1 30 "$ROOT/bin/omarchy-memory-watch" 2>/dev/null &
  fed_pid=$!
}
# One "MemAvailable/stall" per sample: kB out of 1000000, and full avg10.
feed() {
  local sample
  for sample in "$@"; do
    printf 'MemTotal: 1000000 kB\nMemAvailable: %s kB\nSwapTotal: 0 kB\nSwapFree: 0 kB\n' "${sample%/*}" |
      timeout 10 tee "$fifo" >/dev/null || fail "the watcher reads one sample every interval"
    printf 'some avg10=0.00 avg60=0.00 avg300=0.00 total=0\nfull avg10=%s.00 avg60=0.00 avg300=0.00 total=0\n' "${sample#*/}" |
      timeout 10 tee "$pressure_fifo" >/dev/null || fail "the watcher reads the pressure every sample"
    # Lets the watcher close each FIFO before the next write opens it.
    sleep 0.05
  done
}
fed_stop() {
  kill "$fed_pid" 2>/dev/null || true
  wait "$fed_pid" 2>/dev/null || true
  sleep 0.3
}

# The stall stays at 22%, past the RAM 90% line's 20% but short of 25% alone,
# so RAM decides.
# One sample over the line, then under it: a spike, not a warning.
fed_watch
feed 50000/22 900000/22 900000/22
fed_stop
[[ ! -s $NOTIFY_LOG ]] || fail "one sample over the warning line raises no toast" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog ignores a single-sample spike"

# The line held for several samples: one toast, then quiet for five minutes.
fed_watch
feed 50000/22 50000/22 50000/22 50000/22 50000/22 900000/22
fed_stop
[[ $(grep -c 'Memory is running out' "$NOTIFY_LOG") == 1 ]] ||
  fail "a warning held across samples raises exactly one toast" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog warns once per five minutes"

# After a kill, the toast names the app from what the watcher last saw.
unit="app-Hyprland-org.chromium.Chromium@3f2a.scope"
printf '[{"unit":"%s","leader":"chromium","total_mb":9000},{"unit":"%s","leader":"chromium-helper","total_mb":10}]\n' \
  "$unit" "$unit" >"$state/last-top.json"
: >"$NOTIFY_LOG"
run env JOURNAL_USER="{\"USER_UNIT\":\"$unit\",\"N_PROCESSES\":\"12\"}" \
  JOURNAL_SYSTEM="Killed /user.slice/user-1000.slice/user@1000.service/app.slice/$unit due to memory pressure for /user.slice/user-1000.slice/user@1000.service/app.slice being 63.00% > 50.00% for > 20s with reclaim activity" \
  "$ROOT/bin/omarchy-memory-oomd-kills"
grep -Fq 'systemd-oomd killed chromium (9000M)' "$NOTIFY_LOG" ||
  fail "an oomd kill is named after the app the watcher last saw in that scope" "$(cat "$NOTIFY_LOG")"
grep -Fq "12 processes in $unit. It stalled on memory over oomd's 50% for 20s." "$NOTIFY_LOG" ||
  fail "an oomd kill says how many processes went and why" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog names what oomd killed and why"

# Without a snapshot or a readable system journal, it still names the scope.
rm -f "$state/last-top.json"
: >"$NOTIFY_LOG"
run env JOURNAL_USER="{\"USER_UNIT\":\"$unit\",\"N_PROCESSES\":\"3\"}" "$ROOT/bin/omarchy-memory-oomd-kills"
grep -Fq 'systemd-oomd killed org.chromium.Chromium' "$NOTIFY_LOG" ||
  fail "an oomd kill with nothing remembered is named after its scope" "$(cat "$NOTIFY_LOG")"
grep -Fq 'sudo journalctl -u systemd-oomd' "$NOTIFY_LOG" ||
  fail "an unreadable system journal is said, not guessed around" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog names an oomd kill from the scope alone"

# A scope name is systemd-escaped and may end in a random hex suffix.
: >"$NOTIFY_LOG"
run env JOURNAL_USER='{"USER_UNIT":"app-Hyprland-my\\x2dapp-1a2b3c.scope","N_PROCESSES":"1"}' \
  "$ROOT/bin/omarchy-memory-oomd-kills"
grep -Fq 'systemd-oomd killed my-app' "$NOTIFY_LOG" ||
  fail "an oomd kill is named after the unescaped app, without the scope's suffix" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog unescapes the scope it names"

# omarchy memory top finds a process group of this user's.
setsid bash -c 'exec -a omarchy-memtest-dummy sleep 300' &
dummy_pids+=($!)
sleep 0.2
run "$ROOT/bin/omarchy-memory-top" --json | jq -e --argjson pid "${dummy_pids[0]}" \
  'any(.[]; .pids == [$pid] and .leader == "sleep")' >/dev/null ||
  fail "memory top lists a process group with its pids"
pass "memory top lists process groups"
