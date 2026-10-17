#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
dummy_pids=()
dummy_groups=()
cleanup() {
  local pid group
  for pid in "${dummy_pids[@]}"; do
    # Some have exited already, and errexit still holds in this trap.
    kill -CONT "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
  done
  for group in "${dummy_groups[@]}"; do
    kill -CONT -- "-$group" 2>/dev/null || true
    kill -- "-$group" 2>/dev/null || true
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

# A disk with room for a new file but not its contents, when the test asks
# for one: the frozen list's copy lands on /dev/full.
cat >"$TMPDIR/bin/mktemp" <<'SH'
#!/bin/bash
path=$(/usr/bin/mktemp "$@") || exit 1
if [[ -e $MKTEMP_FULL && $path == *frozen.tsv.* ]]; then
  rm -f "$path"
  ln -s /dev/full "$path"
fi
echo "$path"
SH

# The real omarchy-memory-top, waiting MEMTEST_PICK_DELAY after a pick when
# that is set, as a loaded machine might, so the picked group forks meanwhile.
cat >"$TMPDIR/bin/omarchy-memory-top" <<'SH'
#!/bin/bash
"$ROOT/bin/omarchy-memory-top" "$@"
rc=$?
[[ -n ${MEMTEST_PICK_DELAY:-} && " $* " == *" --pick "* ]] && sleep "$MEMTEST_PICK_DELAY"
exit "$rc"
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
    MKTEMP_FULL="$TMPDIR/mktemp-full" \
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

service="$ROOT/default/systemd/user/omarchy-memory-watch.service"
grep -Fx 'ConditionEnvironment=OMARCHY_PATH' "$service" >/dev/null ||
  fail "the memory watchdog waits for OMARCHY_PATH, which the commands it runs need"
grep -Fx 'ConditionPathExists=%h/.local/state/omarchy/toggles/memory-watch-on' "$service" >/dev/null ||
  fail "the memory watchdog stays opt-in even when its unit is enabled"
grep -Fx 'Slice=session.slice' "$service" >/dev/null ||
  fail "the memory watchdog runs in app.slice, where systemd-oomd can kill it before it reports anything"
pass "memory watchdog unit is opt-in and out of systemd-oomd's reach"

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
    OMARCHY_MEMORY_ONLY='^omarchy-memtest-nothing$' OMARCHY_MEMORY_RESUME_HOLDOFF=0 "$@" \
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

# Every dummy this run starts is named omarchy-memtest-<run>-<tag>, and the
# brake is only ever let at the one only() names: anchored on argv[0], with a
# run id no other run or process shares, so nothing else is ever paused.
run_id=$RANDOM$RANDOM
only() {
  printf '^omarchy-memtest-%s-%s( |$)' "$run_id" "$1"
}
re_escape() {
  sed 's/[][\\.*^$+?(){}|]/\\&/g' <<<"$1"
}

# omarchy memory top finds a process group of this user's.
setsid bash -c "exec -a omarchy-memtest-$run_id-a sleep 300" &
dummy_pids+=($!)
sleep 0.2
run "$ROOT/bin/omarchy-memory-top" --json | jq -e --argjson pid "${dummy_pids[0]}" \
  'any(.[]; .pids == [$pid] and .leader == "sleep")' >/dev/null ||
  fail "memory top lists a process group with its pids"
pass "memory top lists process groups"

# The brake pauses a whole group when nothing in it is protected.
# Its own process group, like a job started from a terminal or an agent's shell.
dummy_pid=${dummy_pids[0]}
picked=$(OMARCHY_MEMORY_ONLY=$(only a) run "$ROOT/bin/omarchy-memory-top" --pick 0) ||
  fail "the brake can pick an unprotected process group"
[[ $picked == *$'\t'"$dummy_pid"$'\t'* ]] || fail "the brake picks the dummy's own pids, got: $picked"
pass "memory brake picks an unprotected group"

if OMARCHY_MEMORY_ONLY=$(only a) OMARCHY_MEMORY_PROTECT='^sleep$' run "$ROOT/bin/omarchy-memory-top" --pick 0 >/dev/null; then
  fail "the brake never picks a protected process"
fi
pass "memory brake skips protected processes"

# A protect pattern that is not a regex falls back to the built-in list, and
# says so, rather than stopping the snapshot and the pick altogether.
picked=$(OMARCHY_MEMORY_ONLY=$(only a) OMARCHY_MEMORY_PROTECT='(' \
  run "$ROOT/bin/omarchy-memory-top" --pick 0 2>"$TMPDIR/top.err") ||
  fail "an invalid protect pattern still lets the brake pick" "$(cat "$TMPDIR/top.err")"
[[ $picked == *$'\t'"$dummy_pid"$'\t'* ]] || fail "an invalid protect pattern still picks the dummy, got: $picked"
grep -Fq "ignoring OMARCHY_MEMORY_PROTECT='('" "$TMPDIR/top.err" ||
  fail "an invalid protect pattern is reported" "$(cat "$TMPDIR/top.err")"
if run "$ROOT/bin/omarchy-memory-top" --pick 2>"$TMPDIR/top.err"; then
  fail "--pick without its size is a usage error"
fi
grep -Fq 'usage:' "$TMPDIR/top.err" || fail "--pick without its size prints the usage" "$(cat "$TMPDIR/top.err")"
pass "memory top survives an invalid protect pattern and a missing argument"

# A user's protect pattern adds to the built-in list; it never strips the
# compositor of its protection.
mkdir -p "$TMPDIR/hy"
ln -s "$(command -v sleep)" "$TMPDIR/hy/Hyprland"
setsid "$TMPDIR/hy/Hyprland" 300 &
hy_pid=$!
dummy_pids+=("$hy_pid")
sleep 0.2
OMARCHY_MEMORY_PROTECT='^sleep$' run "$ROOT/bin/omarchy-memory-top" --json |
  jq -e --argjson pid "$hy_pid" 'any(.[]; (.pids | index($pid)) and .protected)' >/dev/null ||
  fail "a custom protect pattern keeps the built-in protections"
pass "memory top adds a custom protect pattern to the built-in list"

# A custom protect pattern is matched on its own: joined to the built-in list,
# its backreference would count the list's groups and miss what it names.
cp "$(command -v sleep)" "$TMPDIR/foofoo"
setsid bash -c "exec -a omarchy-memtest-$run_id-r \"$TMPDIR/foofoo\" 300" &
dummy_pids+=($!)
sleep 0.2
OMARCHY_MEMORY_ONLY=$(only r) run "$ROOT/bin/omarchy-memory-top" --pick 0 >/dev/null ||
  fail "the brake picks the backreference dummy while nothing protects it"
if picked=$(OMARCHY_MEMORY_ONLY=$(only r) OMARCHY_MEMORY_PROTECT='^(foo)\1$' run "$ROOT/bin/omarchy-memory-top" --pick 0); then
  fail "a custom protect pattern with a backreference protects what it names" "$picked"
fi
pass "memory top matches a custom protect pattern on its own"

# Protection is per process: in a group led by a protected process (Hyprland,
# with everything it started without a launcher in its pgid), the brake takes
# the unprotected child and never the protected leader.
cp "$(command -v bash)" "$TMPDIR/memtest-shield"
cp "$(command -v sleep)" "$TMPDIR/memtest-child"
setsid "$TMPDIR/memtest-shield" -c "\"$TMPDIR/memtest-child\" 301 & \"$TMPDIR/memtest-child\" 302 & wait" &
shield_pid=$!
dummy_pids+=("$shield_pid")
sleep 0.3
child_pids=$(pgrep -g "$shield_pid" -x memtest-child | sort -n | paste -sd,)
dummy_pids+=(${child_pids//,/ })
[[ $child_pids == *,* ]] || fail "the protected group's children started" "$child_pids"
picked=$(OMARCHY_MEMORY_ONLY="^$(re_escape "$TMPDIR")/memtest-child 30[12]\$" OMARCHY_MEMORY_PROTECT='^memtest-shield$' \
  run "$ROOT/bin/omarchy-memory-top" --pick 0) ||
  fail "the brake picks an unprotected process inside a protected group"
IFS=$'\t' read -r key _ name pids _ <<<"$picked"
[[ $name == memtest-child && $pids =~ ^[0-9]+$ && ,$child_pids, == *,$pids,* ]] ||
  fail "the brake takes one unprotected child of a protected group, got: $picked"
[[ $key == *"#$shield_pid@$pids" ]] || fail "the brake records which tree inside the group it took, got: $key"
[[ ,$pids, != *,$shield_pid,* ]] || fail "the brake never pauses the protected leader"
pass "memory brake protects per process, not per group"

start_time() {
  local stat
  stat=$(<"/proc/$1/stat")
  stat=${stat##*) }
  read -ra stat <<<"$stat"
  echo "${stat[19]}"
}

proc_state() {
  awk '{ print $3 }' "/proc/$1/stat"
}

# A terminal's foreground job is never paused whole: the shell would take the
# terminal back, and the job would be left in the background after a resume.
# The name comes from the environment, so the python parent's own cmdline
# never matches it.
MEMTEST_NAME=omarchy-memtest-$run_id-fg python3 -c '
import os, pty, time
pid, fd = pty.fork()
if pid == 0:
    os.execvp("sleep", [os.environ["MEMTEST_NAME"], "300"])
print(pid, flush=True)
time.sleep(300)
' >"$TMPDIR/fg-pid" &
dummy_pids+=($!)
sleep 0.5
fg_pid=$(<"$TMPDIR/fg-pid")
dummy_pids+=("$fg_pid")
run "$ROOT/bin/omarchy-memory-top" --json | jq -e --argjson pid "$fg_pid" \
  'any(.[]; .pids == [$pid] and .foreground)' >/dev/null ||
  fail "memory top sees the dummy as a terminal's foreground job"
if picked=$(OMARCHY_MEMORY_ONLY=$(only fg) run "$ROOT/bin/omarchy-memory-top" --pick 0); then
  fail "the brake never pauses a terminal's foreground job" "$picked"
fi
pass "memory brake leaves a terminal's foreground job alone"

# Resume sends SIGCONT to exactly what the brake recorded.
kill -STOP "$dummy_pid"
mkdir -p "$state"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"

if OMARCHY_MEMORY_ONLY=$(only a) run "$ROOT/bin/omarchy-memory-top" --pick 0 >/dev/null; then
  fail "the brake doesn't pick a group it already paused"
fi
pass "memory brake skips stopped groups"

run "$ROOT/bin/omarchy-memory-resume" sleep >/dev/null
sleep 0.2
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues the paused group"
[[ ! -s $state/frozen.tsv ]] || fail "resume clears what it resumed from frozen.tsv"
pass "memory resume continues paused groups"

# A pid whose start time no longer matches is someone else's now.
kill -STOP "$dummy_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" 1 >"$state/frozen.tsv"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
sleep 0.2
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "resume never signals a pid that has been reused"
kill -CONT "$dummy_pid"
pass "memory resume checks each process's start time"

# Swap alone never brakes: zram is sized to RAM, so half of it or more in use
# is routine while RAM is fine.
printf 'MemTotal: 1000000 kB\nMemAvailable: 500000 kB\nSwapTotal: 1000000 kB\nSwapFree: 100000 kB\n' >"$fake/meminfo"
: >"$state/frozen.tsv"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "swap 90% used with RAM half free pauses nothing"
! grep -Fq 'Memory brake' "$NOTIFY_LOG" || fail "swap with RAM to spare raises no brake toast" "$(cat "$NOTIFY_LOG")"
pass "memory brake ignores swap while RAM is fine"

# Swap and RAM both past the brake lines pause one group straight away, short
# of oomd's 90% and 90%. A second dummy stays running: while the first is
# still paused, the brake pauses nothing else, even with no gap between tries.
setsid bash -c "exec -a omarchy-memtest-$run_id-b sleep 300" &
dummy2_pid=$!
dummy_pids+=("$dummy2_pid")
sleep 0.2
printf 'MemTotal: 1000000 kB\nMemAvailable: 120000 kB\nSwapTotal: 1000000 kB\nSwapFree: 200000 kB\n' >"$fake/meminfo"
watch OMARCHY_MEMORY_ONLY="$(only '[ab]')" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
paused=0
for pid in "$dummy_pid" "$dummy2_pid"; do
  [[ $(proc_state "$pid") == "T" ]] && ((++paused))
done
((paused == 1)) || fail "swap 80% with RAM 88% pauses exactly one group, paused $paused"
[[ $(wc -l <"$state/frozen.tsv") == 1 ]] || fail "the brake records one pause" "$(cat "$state/frozen.tsv")"
IFS=$'\t' read -r _ source _ _ _ pids starts <"$state/frozen.tsv"
[[ $source == brake ]] || fail "the brake records itself as the source" "$(cat "$state/frozen.tsv")"
[[ $starts == "$(start_time "$pids")" ]] || fail "the brake records the start time of what it paused"
grep -Fq 'Memory brake: paused sleep' "$NOTIFY_LOG" || fail "the brake says what it paused" "$(cat "$NOTIFY_LOG")"
pass "memory brake pauses one group before oomd's lines"

# Resumed by hand (a plain SIGCONT), the pause no longer holds the brake back.
kill -CONT "$pids"
watch OMARCHY_MEMORY_ONLY="$(only '[ab]')" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
grep -Fq 'Memory brake: paused sleep' "$NOTIFY_LOG" || fail "a pause resumed by hand stops holding the brake back"
[[ $(wc -l <"$state/frozen.tsv") == 1 ]] || fail "a resumed pause is dropped from frozen.tsv" "$(cat "$state/frozen.tsv")"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
for pid in "$dummy_pid" "$dummy2_pid"; do
  [[ $(proc_state "$pid") != "T" ]] || fail "resume continues everything the brake paused"
done
pass "memory brake holds only while its pause does"

# oomd's stall line has no RAM condition, so a stall held at low RAM use
# brakes too: on the third sample in a row, well short of oomd's 20s, and not
# on the second.
: >"$state/frozen.tsv"
: >"$state/resumed.tsv"
fed_watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
feed 900000/45 900000/45 900000/0 900000/0
fed_stop
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "a stall held for two samples does not brake yet"
fed_watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
feed 900000/45 900000/45 900000/45 900000/0
fed_stop
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "a stall held for three samples at low RAM use brakes" "$(tail -3 "$state/watch.log")"
grep -Fq 'Memory brake: paused sleep' "$NOTIFY_LOG" || fail "the stall brake says what it paused" "$(cat "$NOTIFY_LOG")"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
: >"$state/resumed.tsv"
pass "memory brake pauses on a held stall at any RAM use"

# What resume let go of is left alone for the hold-off, so its work can be
# saved while memory is still short; after that, the brake may take it again.
: >"$state/frozen.tsv"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "the brake pauses the dummy before the hold-off test"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues the dummy before the hold-off test"
grep -Fq "#$dummy_pid" "$state/resumed.tsv" || fail "resume records what it let go of" "$(cat "$state/resumed.tsv")"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0 OMARCHY_MEMORY_RESUME_HOLDOFF=300
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "the brake leaves what was just resumed alone"
! grep -Fq 'Memory brake' "$NOTIFY_LOG" || fail "the brake raises no toast within the hold-off" "$(cat "$NOTIFY_LOG")"
# Five minutes and more ago.
awk -F '\t' -v OFS='\t' -v then=$((EPOCHSECONDS - 400)) '{ $1 = then; print }' "$state/resumed.tsv" >"$TMPDIR/resumed"
mv "$TMPDIR/resumed" "$state/resumed.tsv"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0 OMARCHY_MEMORY_RESUME_HOLDOFF=300
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "the brake may pause it again once the hold-off is over"
[[ ! -s $state/resumed.tsv ]] || fail "a hold-off that has run out is dropped" "$(cat "$state/resumed.tsv")"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
: >"$state/resumed.tsv"
pass "memory brake holds off what resume let go of"

# A hold-off that cannot be written (the disk full) is said and reported,
# not passed off as recorded; the group is still resumed, as asked.
: >"$state/frozen.tsv"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "the brake pauses the dummy before the hold-off failure test"
rm -f "$state/resumed.tsv"
ln -s /dev/full "$state/resumed.tsv"
if run "$ROOT/bin/omarchy-memory-resume" >"$TMPDIR/resume-out" 2>"$TMPDIR/resume-err"; then
  fail "resume reports success when it could not record the hold-off" "$(cat "$TMPDIR/resume-err")"
fi
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume still continues the group when the hold-off cannot be written"
grep -q 'hold-off' "$TMPDIR/resume-err" || fail "resume says the hold-off could not be recorded" "$(cat "$TMPDIR/resume-err")"
grep -q '^Resumed ' "$TMPDIR/resume-out" || fail "resume still reports what it continued" "$(cat "$TMPDIR/resume-out")"
rm -f "$state/resumed.tsv"
: >"$state/resumed.tsv"
pass "resume reports a hold-off it could not record and continues the group anyway"

# With nothing it may pause, the brake looks again a minute later rather than
# scanning every process every sample.
: >"$state/frozen.tsv"
: >"$state/watch.log"
watch OMARCHY_MEMORY_BRAKE_GAP=0
[[ $(grep -c 'brake: nothing unprotected' "$state/watch.log") == 1 ]] ||
  fail "the brake backs off after finding nothing to pause" "$(cat "$state/watch.log")"
pass "memory brake backs off when nothing may be paused"

# An invalid protect pattern costs neither the snapshot nor the brake, and the
# watcher logs what the pick said.
: >"$state/watch.log"
watch OMARCHY_MEMORY_ONLY="$(only a)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_PROTECT='('
grep -Fq "brake: omarchy-memory-top: ignoring OMARCHY_MEMORY_PROTECT='('" "$state/watch.log" ||
  fail "the watcher logs what the pick reported" "$(cat "$state/watch.log")"
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "an invalid protect pattern does not stop the brake"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
: >"$state/resumed.tsv"
pass "memory brake logs the pick's complaints and carries on"

# A group that forks between the pick and its SIGSTOP (a build starting jobs)
# is paused whole, the new processes too, and all of them are recorded.
setsid bash -c "exec -a omarchy-memtest-$run_id-f bash -c 'while :; do sleep 300 & sleep 0.05; done'" &
fork_pid=$!
dummy_groups+=("$fork_pid")
sleep 0.3
: >"$state/frozen.tsv"
watch OMARCHY_MEMORY_ONLY="$(only f)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 MEMTEST_PICK_DELAY=0.5
IFS=$'\t' read -r _ _ _ _ _ pids _ <"$state/frozen.tsv"
# A child that exited as its parent stopped stays a zombie, which no pause
# concerns.
for pid in $(pgrep -g "$fork_pid"); do
  [[ $(proc_state "$pid") == "Z" ]] && continue
  [[ $(proc_state "$pid") == "T" ]] ||
    fail "the brake also pauses what the group forked after the pick" "$(pgrep -a -g "$fork_pid")"
  [[ ,$pids, == *,$pid,* ]] || fail "the brake records every process it paused, not $pid" "$pids"
done
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
kill -- -"$fork_pid" 2>/dev/null || true
: >"$state/resumed.tsv"
pass "memory brake pauses what the group forked since the pick"

# A member the user stopped is not the brake's to pause: it is left out of the
# pause and its record, so a resume never continues it.
setsid bash -c "exec -a omarchy-memtest-$run_id-u bash -c '(exec -a omarchy-memtest-$run_id-u sleep 3035) & (exec -a omarchy-memtest-$run_id-u sleep 3036) & wait'" &
user_pid=$!
dummy_groups+=("$user_pid")
sleep 0.3
user_children=$(pgrep -P "$user_pid" -x sleep | sort -n | paste -sd' ')
read -r user_stopped user_running <<<"$user_children"
[[ -n ${user_running:-} ]] || fail "the user-stopped test's children started" "$user_children"
kill -STOP "$user_stopped"
picked=$(OMARCHY_MEMORY_ONLY=$(only u) run "$ROOT/bin/omarchy-memory-top" --pick 0) ||
  fail "the brake picks a group with a member still running"
IFS=$'\t' read -r _ _ _ pids _ <<<"$picked"
[[ ,$pids, != *,$user_stopped,* && ,$pids, == *,$user_running,* && ,$pids, == *,$user_pid,* ]] ||
  fail "the brake picks only the members that run, not $user_stopped" "$picked"
: >"$state/frozen.tsv"
watch OMARCHY_MEMORY_ONLY="$(only u)" OMARCHY_MEMORY_BRAKE_MIN_MB=0
IFS=$'\t' read -r _ _ _ _ _ pids _ <"$state/frozen.tsv"
[[ ,$pids, != *,$user_stopped,* ]] || fail "the brake never records a member the user stopped" "$(cat "$state/frozen.tsv")"
for pid in "$user_pid" "$user_running"; do
  [[ $(proc_state "$pid") == "T" ]] || fail "the brake pauses the members that ran" "$(pgrep -a -g "$user_pid")"
  [[ ,$pids, == *,$pid,* ]] || fail "the brake records the members it paused, not $pid" "$pids"
done
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
for pid in "$user_pid" "$user_running"; do
  [[ $(proc_state "$pid") != "T" ]] || fail "resume continues what the brake paused"
done
[[ $(proc_state "$user_stopped") == "T" ]] || fail "resume leaves a member the user stopped stopped"
kill -CONT "$user_stopped"
kill -- -"$user_pid" 2>/dev/null || true
: >"$state/resumed.tsv"
pass "memory brake leaves members the user stopped out of its pause"

# Whatever holds frozen.lock: waits until it has it.
wait_locked() {
  local i
  for ((i = 0; i < 50; i++)); do
    flock -n "$state/frozen.lock" true || return 0
    sleep 0.1
  done
  fail "the test's lock holder takes frozen.lock"
}

# A resume that holds frozen.lock past the brake's wait rewrites frozen.tsv
# from the copy it read, dropping any line appended meanwhile. The brake
# pauses nothing it cannot record under the lock.
setsid bash -c "exec -a omarchy-memtest-$run_id-locked sleep 3040" &
locked_pid=$!
dummy_pids+=("$locked_pid")
: >"$state/frozen.tsv"
: >"$state/watch.log"
(
  flock 9
  cp "$state/frozen.tsv" "$TMPDIR/frozen.kept"
  sleep 8.5
  mv "$TMPDIR/frozen.kept" "$state/frozen.tsv"
) 9>"$state/frozen.lock" &
holder=$!
wait_locked
run env OMARCHY_MEMORY_MEMINFO="$fake/meminfo" OMARCHY_MEMORY_PRESSURE="$fake/pressure" \
  OMARCHY_MEMORY_APP_PRESSURE="$fake/app-pressure" OMARCHY_MEMORY_INTERVAL=0.2 \
  OMARCHY_MEMORY_ONLY="$(only locked)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 \
  timeout 7.5 "$ROOT/bin/omarchy-memory-watch" 2>/dev/null || true
wait "$holder"
if [[ $(proc_state "$locked_pid") == "T" ]]; then
  grep -Fq $'\t'"$locked_pid"$'\t' "$state/frozen.tsv" ||
    fail "the brake never leaves a group paused with no record to resume it" "$(cat "$state/frozen.tsv")"
fi
[[ $(proc_state "$locked_pid") != "T" ]] && grep -Fq 'brake: frozen.tsv stayed locked; left sleep running' "$state/watch.log" ||
  fail "the brake pauses nothing while it cannot take frozen.lock, and says so" "$(cat "$state/watch.log")"
pass "memory brake pauses only what it can record"

# Turning the watchdog off stops it with a TERM to everything in its unit, then
# resumes what frozen.tsv lists. A TERM between the brake's SIGSTOPs and their
# line in frozen.tsv waits for that line, so nothing is left stopped that
# resume cannot see. The brake is held in that window by its test hook.
: >"$state/frozen.tsv"
: >"$state/watch.log"
hold="$TMPDIR/brake-hold"
run env OMARCHY_MEMORY_MEMINFO="$fake/meminfo" OMARCHY_MEMORY_PRESSURE="$fake/pressure" \
  OMARCHY_MEMORY_APP_PRESSURE="$fake/app-pressure" OMARCHY_MEMORY_INTERVAL=0.2 \
  OMARCHY_MEMORY_ONLY="$(only locked)" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_TEST_BRAKE_HOLD="$hold" \
  timeout 20 "$ROOT/bin/omarchy-memory-watch" 2>/dev/null &
watch_job=$!
for _ in {1..100}; do
  [[ -e $hold.ready ]] && break
  sleep 0.1
done
[[ -e $hold.ready ]] || fail "the brake reaches the window between its SIGSTOPs and their record"
[[ $(proc_state "$locked_pid") == "T" ]] || fail "the brake stops the group before it records it"
# timeout leads its own process group, as a unit's cgroup holds the watcher.
group=$(pgrep -P "$watch_job" -x timeout)
kill -TERM -- -"$group"
sleep 0.5
touch "$hold"
wait "$watch_job" || true
! pgrep -g "$group" >/dev/null || fail "a TERM during the brake still stops the watcher"
grep -Fq $'\t'"$locked_pid"$'\t' "$state/frozen.tsv" ||
  fail "a TERM between the SIGSTOP and its record still records the pause" "$(cat "$state/frozen.tsv")"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
[[ $(proc_state "$locked_pid") != "T" ]] || fail "resume continues a pause the brake made as it was stopped"
pass "memory brake leaves nothing paused unrecorded when stopped"

# Turning the watchdog off resumes what it paused.
kill -STOP "$dummy_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"
mkdir -p "$(dirname "$flag")"
touch "$flag"
run "$ROOT/bin/omarchy-toggle-memory-watch" off
sleep 0.2
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "turning the watchdog off resumes what it paused"
pass "memory watchdog toggle off resumes paused groups"

# Turning it off is not passed off as done when the watcher could not be
# stopped: it says so, keeps the unit so `off` again can stop it, and fails.
touch "$flag"
run "$ROOT/bin/omarchy-toggle-memory-watch" on >/dev/null
: >"$NOTIFY_LOG"
if run env SYSTEMCTL_FAIL=disable "$ROOT/bin/omarchy-toggle-memory-watch" off; then
  fail "the toggle reports success when the watcher could not be stopped"
fi
[[ ! -f $flag ]] || fail "a watcher that could not be stopped still leaves the flag off"
[[ -e $installed_unit ]] || fail "a watcher that could not be stopped keeps its unit for the retry"
grep -Fq 'Memory watchdog could not be stopped' "$NOTIFY_LOG" ||
  fail "a watcher that could not be stopped says so" "$(cat "$NOTIFY_LOG")"
! grep -Fq 'Memory watchdog disabled' "$NOTIFY_LOG" ||
  fail "a watcher that could not be stopped is never reported disabled" "$(cat "$NOTIFY_LOG")"
: >"$NOTIFY_LOG"
run "$ROOT/bin/omarchy-toggle-memory-watch" off || fail "off again after a failed stop does not retry"
[[ ! -e $installed_unit ]] || fail "off again after a failed stop removes the unit"
grep -Fq 'Memory watchdog disabled' "$NOTIFY_LOG" || fail "off again after a failed stop reports disabled" "$(cat "$NOTIFY_LOG")"
pass "memory watchdog toggle off says when the watcher could not be stopped"

# Nor when what it paused could not be resumed: another resume holding the
# lock past the wait leaves the group stopped, which the toast must say.
kill -STOP "$dummy_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"
touch "$flag"
: >"$NOTIFY_LOG"
( exec 9>"$state/frozen.lock"; flock 9; sleep 30 ) &
lock_holder=$!
sleep 0.2
if run "$ROOT/bin/omarchy-toggle-memory-watch" off; then
  fail "the toggle reports success when what it paused could not be resumed"
fi
[[ $(proc_state "$dummy_pid") == "T" ]] || fail "the lock-held resume test lost its stopped dummy"
grep -Fq 'could not be resumed' "$NOTIFY_LOG" ||
  fail "a group left paused by a failed resume is said" "$(cat "$NOTIFY_LOG")"
! grep -Fq 'Memory watchdog disabled' "$NOTIFY_LOG" ||
  fail "a failed resume is never reported as disabled" "$(cat "$NOTIFY_LOG")"
kill "$lock_holder" 2>/dev/null || true
wait "$lock_holder" 2>/dev/null || true
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues the group once the lock is free"
pass "memory watchdog toggle off says when what it paused could not be resumed"

# A pause the brake cannot record (the disk full, say) is not kept: resume
# and turning the watchdog off could never find it.
: >"$state/frozen.tsv"
touch "$TMPDIR/mktemp-full"
paused_before=$(grep -c 'brake: paused' "$state/watch.log" || true)
watch OMARCHY_MEMORY_ONLY="$(only '[ab]')" OMARCHY_MEMORY_BRAKE_MIN_MB=0 OMARCHY_MEMORY_BRAKE_GAP=0
rm -f "$TMPDIR/mktemp-full" "$state"/frozen.tsv.*
for pid in "$dummy_pid" "$dummy2_pid"; do
  [[ $(proc_state "$pid") != "T" ]] || fail "the brake resumes a pause it could not record" "$(tail -3 "$state/watch.log")"
done
grep -Fq 'could not record the pause' "$state/watch.log" || fail "the brake says it could not record the pause"
[[ $(grep -c 'brake: paused' "$state/watch.log" || true) == "$paused_before" ]] ||
  fail "the brake does not announce a pause it undid"
! grep -Fq 'Memory brake' "$NOTIFY_LOG" || fail "the brake raises no toast for a pause it undid" "$(cat "$NOTIFY_LOG")"
: >"$state/frozen.tsv"
pass "memory brake keeps no pause it could not record"

# A stop sent to a process in uninterruptible sleep takes effect later: its
# record stays while the stop is pending, and goes once the process is neither
# stopped nor about to be. The processes are a fake /proc, since a process
# cannot be put in that sleep to order.
mkdir -p "$fake/proc/4000001" "$fake/proc/4000002"
printf '4000001 (memtest io) D 1 1 1 0 -1 0 0 0 0 0 0 0 0 0 20 0 1 0 777 0 0\n' >"$fake/proc/4000001/stat"
printf 'Name:\tmemtest io\nState:\tD (disk sleep)\nSigPnd:\t0000000000000000\nShdPnd:\t0000000000040000\n' >"$fake/proc/4000001/status"
printf '4000002 (memtest idle) S 1 1 1 0 -1 0 0 0 0 0 0 0 0 0 20 0 1 0 778 0 0\n' >"$fake/proc/4000002/stat"
printf 'Name:\tmemtest idle\nState:\tS (sleeping)\nSigPnd:\t0000000000000000\nShdPnd:\t0000000000000000\n' >"$fake/proc/4000002/status"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#4000001" 1 io 4000001 777 >"$state/frozen.tsv"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#4000002" 1 idle 4000002 778 >>"$state/frozen.tsv"
watch OMARCHY_MEMORY_PROC="$fake/proc"
grep -Fq $'\t4000001\t' "$state/frozen.tsv" || fail "pruning keeps the record of a stop still pending" "$(cat "$state/frozen.tsv")"
! grep -Fq $'\t4000002\t' "$state/frozen.tsv" || fail "pruning drops the record of a process that runs on" "$(cat "$state/frozen.tsv")"
: >"$state/frozen.tsv"
pass "memory watchdog keeps the record of a stop that has yet to take effect"

# Pruning and resuming rewrite the frozen list through a copy; a copy that
# cannot be written whole never replaces the list, so no pause loses its record.
kill -STOP "$dummy_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"
touch "$TMPDIR/mktemp-full"
watch
[[ -f $state/frozen.tsv && ! -L $state/frozen.tsv ]] || fail "pruning keeps the frozen list when its copy cannot be written"
grep -Fq "$dummy_pid" "$state/frozen.tsv" || fail "pruning keeps every pause it cannot copy" "$(cat "$state/frozen.tsv")"
# Resuming one group must keep the other's line, which the copy cannot take.
kill -STOP "$dummy2_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy2_pid" 1 held "$dummy2_pid" \
  "$(start_time "$dummy2_pid")" >>"$state/frozen.tsv"
if run "$ROOT/bin/omarchy-memory-resume" '^sleep$' >/dev/null 2>"$TMPDIR/resume.err"; then
  fail "resume reports success when it could not rewrite the list"
fi
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues the pause even when it cannot rewrite the list"
[[ $(proc_state "$dummy2_pid") == "T" ]] || fail "resume by name leaves a pause that does not match it"
[[ -f $state/frozen.tsv && ! -L $state/frozen.tsv ]] || fail "resume keeps the frozen list when its copy cannot be written"
grep -Fq "$dummy2_pid" "$state/frozen.tsv" || fail "resume keeps the pause it did not undo when it cannot copy it" "$(cat "$state/frozen.tsv")"
[[ $(<"$TMPDIR/resume.err") == *"Could not rewrite frozen.tsv"* ]] || fail "resume says it could not rewrite the list" "$(cat "$TMPDIR/resume.err")"
rm -f "$TMPDIR/mktemp-full" "$state"/frozen.tsv.*
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
[[ $(proc_state "$dummy2_pid") != "T" ]] || fail "the kept pause can still be resumed once the copy can be written"
: >"$state/frozen.tsv"
pass "memory watchdog keeps its records when it cannot rewrite them"

# A copy that fails on a line resume keeps does not end the resume: a match on
# a later line is still continued, the list is left as it was, and the exit
# status says it was not rewritten.
kill -STOP "$dummy_pid" "$dummy2_pid"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy2_pid" 1 held "$dummy2_pid" \
  "$(start_time "$dummy2_pid")" >"$state/frozen.tsv"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >>"$state/frozen.tsv"
cp "$state/frozen.tsv" "$TMPDIR/frozen-before"
touch "$TMPDIR/mktemp-full"
if run "$ROOT/bin/omarchy-memory-resume" '^sleep$' >"$TMPDIR/resume.out" 2>"$TMPDIR/resume.err"; then
  fail "resume reports success when it could not rewrite the list" "$(cat "$TMPDIR/resume.err")"
fi
rm -f "$TMPDIR/mktemp-full" "$state"/frozen.tsv.*
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues a match after the line it could not copy"
[[ $(proc_state "$dummy2_pid") == "T" ]] || fail "resume by name leaves the pause it could not copy paused"
grep -q '^Resumed sleep' "$TMPDIR/resume.out" || fail "resume reports the match it continued" "$(cat "$TMPDIR/resume.out")"
cmp -s "$TMPDIR/frozen-before" "$state/frozen.tsv" || fail "resume leaves the frozen list as it was" "$(cat "$state/frozen.tsv")"
[[ $(grep -c 'Could not rewrite frozen.tsv' "$TMPDIR/resume.err") == 1 ]] ||
  fail "resume says once that it could not rewrite the list" "$(cat "$TMPDIR/resume.err")"
run "$ROOT/bin/omarchy-memory-resume" >/dev/null
[[ $(proc_state "$dummy2_pid") != "T" ]] || fail "the kept pause can still be resumed once the copy can be written"
: >"$state/frozen.tsv"
: >"$state/resumed.tsv"
pass "resume continues every match when it cannot rewrite the list"

# A last line without its newline is still a record, and a malformed line is
# skipped with a word, not taken for one.
kill -STOP "$dummy_pid"
printf 'garbage\n%s\t%s\t%s\t%s\t%s\t%s\t%s' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"
watch
[[ $(tail -c 1 "$state/frozen.tsv") == "" && $(wc -l <"$state/frozen.tsv") == 1 ]] ||
  fail "pruning keeps a last line without its newline, and drops a malformed one" "$(cat -A "$state/frozen.tsv")"
grep -Fq 'prune: dropped a malformed line from frozen.tsv: garbage' "$state/watch.log" ||
  fail "pruning says it dropped a malformed line"
printf 'garbage\n%s\t%s\t%s\t%s\t%s\t%s\t%s' "2026-01-01 00:00:00" brake "test#$dummy_pid" 1 sleep "$dummy_pid" \
  "$(start_time "$dummy_pid")" >"$state/frozen.tsv"
out=$(run "$ROOT/bin/omarchy-memory-resume" 2>"$TMPDIR/resume.err")
[[ $out == "Resumed sleep"* ]] || fail "resume reads a last line without its newline" "$out"
[[ $(proc_state "$dummy_pid") != "T" ]] || fail "resume continues a pause on a last line without its newline"
grep -Fq 'Skipped a malformed line in frozen.tsv: garbage' "$TMPDIR/resume.err" ||
  fail "resume says it skipped a malformed line" "$(cat "$TMPDIR/resume.err")"
[[ ! -s $state/frozen.tsv ]] || fail "resume clears what it resumed and what was malformed" "$(cat "$state/frozen.tsv")"
: >"$state/resumed.tsv"
pass "memory watchdog reads frozen.tsv's last line and skips malformed ones"

# A game's own binary often has a bland name (under gamescope, or a Proton
# helper), so the brake protects everything under a game: a child in the
# game's group, and one in a group of its own.
setsid bash -c "exec -a /tmp/memtest/steamapps/common/game.exe bash -c \"(exec -a omarchy-memtest-$run_id-g sleep 3032) & setsid -w bash -c 'exec -a omarchy-memtest-$run_id-g sleep 3033' & wait\"" &
game_pid=$!
dummy_pids+=("$game_pid")
sleep 0.3
game_children=$(pgrep -P "$game_pid" -x sleep | sort -n | paste -sd' ')
dummy_pids+=($game_children)
[[ $game_children == *' '* ]] || fail "the game's children started" "$game_children"
if picked=$(OMARCHY_MEMORY_ONLY=$(only g) run "$ROOT/bin/omarchy-memory-top" --pick 0); then
  fail "the brake never pauses what runs under a game" "$picked"
fi
pass "memory brake protects everything under a game"

# A native launcher is a game too: what Lutris, Heroic or RetroArch started
# is never paused.
cp "$(command -v bash)" "$TMPDIR/lutris"
setsid "$TMPDIR/lutris" -c "(exec -a omarchy-memtest-$run_id-l sleep 3034) & wait" &
dummy_groups+=($!)
sleep 0.3
if picked=$(OMARCHY_MEMORY_ONLY=$(only l) run "$ROOT/bin/omarchy-memory-top" --pick 0); then
  fail "the brake never pauses what a game launcher started" "$picked"
fi
pass "memory brake protects what a game launcher started"
