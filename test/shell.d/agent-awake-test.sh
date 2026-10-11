#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

awake="$ROOT/bin/omarchy-agent-awake"
tmpdir=$(mktemp -d)
fake_bin="$tmpdir/bin"
clock_bin="$tmpdir/clock"
runtime="$tmpdir/runtime"
state="$runtime/omarchy/agent-awake"
log="$tmpdir/log"
home="$tmpdir/home"

cleanup() {
  [[ -r $tmpdir/holder.pid ]] && pkill -P "$(<"$tmpdir/holder.pid")" 2>/dev/null
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$fake_bin" "$clock_bin" "$runtime" "$home"
chmod 700 "$runtime"

# systemd stands in for itself: a unit is active while its holder runs, and the
# holder runs the real command, so readiness and the record are exercised.
cat >"$fake_bin/systemctl" <<'SH'
#!/bin/bash
[[ $1 == "--user" ]] && shift
case $1 in
  is-active)
    [[ ${@: -1} == "graphical-session.target" ]] && { [[ ! -e $TEST_DIR/no-desktop ]]; exit; }
    [[ -e $TEST_DIR/unit-active ]]
    ;;
  stop)
    echo "stop" >>"$TEST_DIR/log"
    if [[ -r $TEST_DIR/holder.pid ]]; then
      pkill -P "$(<"$TEST_DIR/holder.pid")" 2>/dev/null
      kill "$(<"$TEST_DIR/holder.pid")" 2>/dev/null
    fi
    rm -f "$TEST_DIR/unit-active" "$TEST_DIR/holder.pid"
    ;;
esac
SH

cat >"$fake_bin/systemd-run" <<'SH'
#!/bin/bash
if [[ " $* " == *" omarchy-notification-send "* ]]; then
  call="$*"
  call=${call##*omarchy-notification-send -g 󰈈 }
  printf 'notify %s\n' "$call" >>"$TEST_DIR/log"
  exit 0
fi
printf 'systemd-run %s\n' "$*" >>"$TEST_DIR/log"
[[ -e $TEST_DIR/run-fails ]] && exit 1
token=${@: -1}
touch "$TEST_DIR/unit-active"
if [[ ! -e $TEST_DIR/inhibit-fails ]]; then
  # A unit inherits none of its caller's descriptors.
  ( omarchy-agent-awake hold "$token"; rm -f "$TEST_DIR/unit-active" ) </dev/null >/dev/null 2>&1 9>&- &
  echo $! >"$TEST_DIR/holder.pid"
else
  rm -f "$TEST_DIR/unit-active"
fi
SH

cat >"$fake_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'refusal %s\n' "${*: -1}" >>"$TEST_DIR/log"
SH

cat >"$fake_bin/omarchy-hw-laptop" <<'SH'
#!/bin/bash
[[ ! -e $TEST_DIR/no-lid ]]
SH

cat >"$fake_bin/omarchy-battery-present" <<'SH'
#!/bin/bash
[[ -e $TEST_DIR/battery ]]
SH

cat >"$fake_bin/upower" <<'SH'
#!/bin/bash
[[ -r $TEST_DIR/battery ]] && cat "$TEST_DIR/battery"
SH

ln -s "$awake" "$fake_bin/omarchy-agent-awake"
ln -s "$ROOT/bin/omarchy-agent-busy" "$fake_bin/omarchy-agent-busy"

# The holder's clock: date +%s reads a file that sleep advances, so hours of
# session pass in a moment and a runaway loop is cut off rather than hung.
cat >"$clock_bin/date" <<'SH'
#!/bin/bash
if [[ $* == "+%s" ]]; then
  cat "$TEST_DIR/now"
else
  exec /usr/bin/date "$@"
fi
SH

cat >"$clock_bin/sleep" <<'SH'
#!/bin/bash
now=$(<"$TEST_DIR/now")
echo $((now + ${1%.*})) >"$TEST_DIR/now"
[[ -x $TEST_DIR/on-sleep ]] && HOLDER=$PPID "$TEST_DIR/on-sleep"
(( now - $(<"$TEST_DIR/epoch") < 200000 )) || kill -TERM "$PPID"
SH

chmod +x "$fake_bin"/* "$clock_bin"/*

export TEST_DIR="$tmpdir"
export XDG_RUNTIME_DIR="$runtime"
export HOME="$home"

reset() {
  [[ -r $tmpdir/holder.pid ]] && { pkill -P "$(<"$tmpdir/holder.pid")" 2>/dev/null; kill "$(<"$tmpdir/holder.pid")" 2>/dev/null; } || true
  rm -f "$tmpdir"/{unit-active,holder.pid,no-desktop,no-lid,battery,run-fails,inhibit-fails,on-sleep}
  rm -rf "$state" "$home"
  mkdir -p "$home"
  : >"$log"
}

run() {
  PATH="$fake_bin:$PATH" "$awake" "$@"
}

field() {
  local fields
  read -r -a fields <"$state/session"
  printf '%s\n' "${fields[$1]}"
}

# --- starting

reset
before=$(date +%s)
output=$(run 2h)
[[ $output == "Awake until "* ]] || fail "a duration starts a session" "$output"
deadline=$(field 1)
(( deadline - before >= 7200 && deadline - before <= 7202 )) || fail "2h ends two hours from now" "deadline=$deadline before=$before"
[[ $(field 2) == "time" ]] || fail "a duration is a time session"
pass "a duration starts a session ending that far from now"

args=$(grep '^systemd-run' "$log")
[[ $args == *"--what=handle-lid-switch "* ]] || fail "the holder takes the lid-switch inhibitor" "$args"
[[ $args != *sleep:* && $args != *:idle* && $args != *"--what=sleep"* && $args != *"--what=idle"* ]] || fail "the holder inhibits nothing but the lid" "$args"
[[ $args == *"--no-ask-password"* ]] || fail "the holder never prompts for a password" "$args"
[[ $args == *"--property=RuntimeMaxSec=86460"* ]] || fail "systemd bounds the holder's lifetime" "$args"
pass "only the lid switch is inhibited, and systemd bounds the holder"

[[ $(<"$state/ready") == "$(field 0)" ]] || fail "start returns only once the holder has the lid"
pass "start waits for the holder to confirm the inhibitor"

for spec in 90m:5400 1h30m:5400 45m:2700; do
  reset
  before=$(date +%s)
  run "${spec%%:*}" >/dev/null
  (( $(field 1) - before >= ${spec##*:} && $(field 1) - before <= ${spec##*:} + 2 )) || fail "${spec%%:*} lasts ${spec##*:} seconds"
done
pass "minutes and hours-and-minutes durations parse"

reset
target=$(date -d "+2 hours" +%H:%M)
run "$target" >/dev/null
[[ $(date -d "@$(field 1)" +%H:%M) == "$target" ]] || fail "a clock time ends at that time"
(( $(field 1) > $(date +%s) )) || fail "a clock time ends in the future"
reset
target=$(date -d "-1 hour" +%H:%M)
run "$target" >/dev/null
(( $(field 1) > $(date +%s) + 20 * 3600 )) || fail "a clock time already past today means tomorrow"
pass "a clock time ends at its next occurrence"

for bad in 0m 2x abc 25:00 12:60 1h-5m "" 100h; do
  reset
  if [[ -z $bad ]]; then continue; fi
  if run "$bad" >/dev/null 2>&1; then fail "'$bad' is refused"; fi
  [[ ! -e $state/session ]] || fail "'$bad' leaves no session behind"
done
pass "nonsense durations and times are refused"

reset
if run 24h1m >/dev/null 2>&1; then fail "a session longer than 24 hours is refused"; fi
run 24h >/dev/null || fail "a 24 hour session is allowed"
pass "sessions are capped at 24 hours"

reset
touch "$tmpdir/no-lid"
if output=$(run 2h 2>&1); then fail "a machine without a lid refuses"; fi
[[ $output == *"no lid"* ]] && ! grep -q '^systemd-run' "$log" || fail "a machine without a lid refuses before starting anything" "$output"
pass "a machine without a lid refuses"

reset
touch "$tmpdir/no-desktop"
if run 2h >/dev/null 2>&1; then fail "without a desktop session it refuses"; fi
pass "without a desktop session to lock, it refuses"

reset
printf '  percentage:          9%%\n  state:               discharging\n' >"$tmpdir/battery"
if output=$(run 2h 2>&1); then fail "a battery at the floor refuses to start"; fi
[[ $output == *"too low"* ]] || fail "the refusal says the battery is too low" "$output"
printf '  percentage:          9%%\n  state:               charging\n' >"$tmpdir/battery"
run 2h >/dev/null || fail "a low battery on the charger may start"
grep -q '^refusal The battery' "$log" || fail "a refusal nobody sees on a terminal is sent as a notification" "$(<"$log")"
pass "a battery at or below 10% and not charging refuses to start"

reset
touch "$tmpdir/run-fails"
if run 2h >/dev/null 2>&1; then fail "a unit that cannot start is reported"; fi
[[ ! -e $state/session ]] || fail "a unit that cannot start leaves no session"
reset
touch "$tmpdir/inhibit-fails"
if output=$(run 2h 2>&1); then fail "an inhibitor that is never granted is reported"; fi
[[ $output == *"Could not hold the lid"* && ! -e $state/session ]] || fail "an ungranted inhibitor is reported and cleaned up" "$output"
pass "a holder that never confirms is reported and cleaned up"

# --- a running session

reset
run 2h >/dev/null
token=$(field 0)
pid=$(<"$tmpdir/holder.pid")
run 4h >/dev/null
[[ $(grep -c '^systemd-run' "$log") == 1 && $(<"$tmpdir/holder.pid") == "$pid" ]] || fail "a new end time reuses the running holder" "$(<"$log")"
[[ $(field 0) == "$token" ]] || fail "the running holder keeps its token"
(( $(field 1) - $(date +%s) >= 4 * 3600 - 2 )) || fail "the new end time is recorded"
pass "a new end time is handed to the running holder without releasing the lid"

deadline=$(field 1)
run add 30m >/dev/null
(( $(field 1) == deadline + 1800 )) || fail "add pushes the end back from the current end"
pass "add pushes the end time back"

run add 20h >/dev/null 2>&1 && fail "add past 24 hours from the holder's start is refused"
(( $(field 1) == deadline + 1800 )) || fail "a refused add changes nothing"
pass "add cannot stretch a holder past 24 hours"

# A new end time for a running holder still counts from when that holder began.
read -r -a fields <"$state/session"
printf '%s %s %s %s %s\n' "${fields[0]}" "${fields[1]}" "${fields[2]}" "${fields[3]}" $(( $(date +%s) - 23 * 3600 )) >"$state/session"
if run 4h >/dev/null 2>&1; then fail "a new end time past the running holder's 24 hours is refused"; fi
run 30m >/dev/null || fail "a new end time inside the running holder's 24 hours is accepted"
pass "a new end time cannot stretch a running holder past 24 hours"

[[ $(PATH="$fake_bin:$PATH" "$awake" status | jq -r .active) == "true" ]] || fail "status reports an active session"
PATH="$fake_bin:$PATH" "$awake" active || fail "active succeeds while a session runs"
pass "status and active report a running session"

run stop
! PATH="$fake_bin:$PATH" "$awake" active || fail "active fails once stopped"
[[ ! -e $state/session && -d $state ]] || fail "stop clears the session but keeps the watched directory"
pass "stop ends the session"

reset
if run add 30m >/dev/null 2>&1; then fail "add without a session is refused"; fi
pass "add without a session is refused"

# A holder whose record is gone is on its way out: start waits for it to stop
# rather than hand it an end time it will never read.
reset
touch "$tmpdir/unit-active"
mkdir -p "$state"
run 2h >/dev/null
grep -q '^stop' "$log" || fail "start stops a holder that is ending"
[[ $(grep -c '^systemd-run' "$log") == 1 ]] || fail "start then runs a new holder"
pass "start after a holder began ending starts a new one"

# Killed holder: the unit is gone but the record stays; status believes systemd.
reset
run 2h >/dev/null
pkill -P "$(<"$tmpdir/holder.pid")"
kill "$(<"$tmpdir/holder.pid")"
rm -f "$tmpdir/unit-active"
[[ $(PATH="$fake_bin:$PATH" "$awake" status | jq -r .active) == "false" ]] || fail "a killed holder reads inactive"
pass "a killed holder reads inactive whatever its record says"

# --- the holder

hold_session() {
  reset
  mkdir -p -m 700 "$state"
  echo 1000000 >"$tmpdir/now"
  echo 1000000 >"$tmpdir/epoch"
  printf 'aaaaaaaaaaaaaaaa %s %s 1000000 1000000\n' "$1" "$2" >"$state/session"
}

hold() {
  PATH="$clock_bin:$fake_bin:$PATH" "$awake" hold aaaaaaaaaaaaaaaa 2>/dev/null
}

hold_session 1003600 time
hold
(( $(<"$tmpdir/now") >= 1003600 && $(<"$tmpdir/now") <= 1003605 )) || fail "the holder ends within a tick of its end time" "now=$(<"$tmpdir/now")"
[[ ! -e $state/session ]] || fail "an ended session clears its record"
grep -q '^notify Agent Awake is over' "$log" || fail "the end is announced" "$(<"$log")"
pass "the holder ends at its end time and says so"

hold_session 1003600 time
cat >"$tmpdir/on-sleep" <<'SH'
#!/bin/bash
(( $(<"$TEST_DIR/now") >= 1001000 )) && sed -i 's/ 1003600 / 1007200 /' "$XDG_RUNTIME_DIR/omarchy/agent-awake/session"
exit 0
SH
chmod +x "$tmpdir/on-sleep"
hold
(( $(<"$tmpdir/now") >= 1007200 )) || fail "the holder follows an end time moved while it runs"
pass "the holder rereads its end time"

hold_session 1086400 time
printf '  percentage:          10%%\n  state:               discharging\n' >"$tmpdir/battery"
hold
grep -q '^notify -u critical Agent Awake stopped The battery' "$log" || fail "10% discharging ends the session" "$(<"$log")"
(( $(<"$tmpdir/now") < 1000100 )) || fail "the battery is checked straight away"
pass "the battery floor ends the session"

hold_session 1003600 time
printf '  percentage:          5%%\n  state:               pending-charge\n' >"$tmpdir/battery"
hold
grep -q '^notify Agent Awake is over' "$log" || fail "a charging battery below the floor does not end it" "$(<"$log")"
pass "a battery that is charging does not end it"

hold_session 1003600 time
printf '  percentage:          9%%\n  state:               unknown\n' >"$tmpdir/battery"
hold
grep -q 'The battery is at' "$log" || fail "an unknown state below the floor counts as discharging" "$(<"$log")"
pass "a battery in an unknown state below the floor ends it"

hold_session 1086400 time
: >"$tmpdir/battery"
hold
grep -q 'Could not read the battery' "$log" || fail "a battery that cannot be read ends the session" "$(<"$log")"
(( $(<"$tmpdir/now") >= 1000030 )) || fail "one unreadable answer is forgiven"
pass "a battery that cannot be read twice in a row ends it"

# Agents mode ends only once activity it has seen goes quiet.
hold_session 1028800 agents
hold
grep -q '^notify Agent Awake is over Its end time' "$log" || fail "never seeing an agent runs to the cap" "$(<"$log")"
pass "agents mode with no activity ever seen runs to its cap"

hold_session 1028800 agents
mkdir -p "$home/.claude/projects/p"
touch "$home/.claude/projects/p/s.jsonl"
cat >"$tmpdir/on-sleep" <<'SH'
#!/bin/bash
(( $(<"$TEST_DIR/now") >= 1003600 )) && touch -d "-20 minutes" "$HOME/.claude/projects/p/s.jsonl"
grep -q . "$XDG_RUNTIME_DIR/omarchy/agent-awake/agents" 2>/dev/null && cp "$XDG_RUNTIME_DIR/omarchy/agent-awake/agents" "$TEST_DIR/agents-seen"
exit 0
SH
chmod +x "$tmpdir/on-sleep"
hold
grep -q '^notify Agent Awake is over No agent activity' "$log" || fail "seen activity going quiet ends agents mode" "$(<"$log")"
(( $(<"$tmpdir/now") >= 1003600 && $(<"$tmpdir/now") < 1003700 )) || fail "agents mode ends at the first quiet check" "now=$(<"$tmpdir/now")"
[[ $(<"$tmpdir/agents-seen") == "Claude Code" ]] || fail "the agents with activity are recorded for the bar"
pass "agents mode ends once the activity it saw goes quiet"

hold_session 1028800 agents
mkdir -p "$home/.claude/projects/p"
chmod 000 "$home/.claude/projects"
touch "$state/seen"
cat >"$tmpdir/on-sleep" <<'SH'
#!/bin/bash
(( $(<"$TEST_DIR/now") >= 1001000 )) && kill -TERM "$HOLDER"
exit 0
SH
chmod +x "$tmpdir/on-sleep"
{ hold || true; } 2>/dev/null
chmod 755 "$home/.claude/projects"
[[ -e $state/session ]] && ! grep -q '^notify' "$log" || fail "a scan that failed is not quiet" "$(<"$log")"
pass "a failed activity scan never ends agents mode"

hold_session 1003600 time
printf 'bbbbbbbbbbbbbbbb 1003600 time 1000000 1000000\n' >"$state/session"
hold
grep -q . "$state/session" && ! grep -q '^notify' "$log" || fail "a holder never ends another holder's session"
[[ ! -e $state/ready ]] || fail "a superseded holder never confirms"
pass "a holder leaves a session that is not its own alone"

hold_session 1003600 time
cat >"$tmpdir/on-sleep" <<'SH'
#!/bin/bash
(( $(<"$TEST_DIR/now") >= 1001000 )) && printf 'bbbbbbbbbbbbbbbb 1003600 time 1000000 1000000\n' >"$XDG_RUNTIME_DIR/omarchy/agent-awake/session"
exit 0
SH
chmod +x "$tmpdir/on-sleep"
hold
(( $(<"$tmpdir/now") < 1001100 )) || fail "a holder whose session passed to another stops at once" "now=$(<"$tmpdir/now")"
grep -q '^bbbbbbbbbbbbbbbb' "$state/session" && ! grep -q '^notify' "$log" || fail "a holder never clears or announces another holder's session"
pass "a holder that loses its session mid-run stops without touching the new one"

# --- undocking with the lid shut

# Agent Awake keeps that lid from suspending, and suspend is what used to lock
# it, so the monitor watcher has to lock and blank it instead.
watch_bin="$tmpdir/watch-bin"
watch_log="$tmpdir/watch-log"
mkdir -p "$watch_bin"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$watch_bin/$1"
  chmod +x "$watch_bin/$1"
}

stub socat 'exit 0'
stub hyprctl 'exit 0'
stub omarchy-hw-laptop 'exit 1'
stub omarchy-hyprland-monitor-external-active 'exit 1'
stub omarchy-hyprland-monitor-modeless 'exit 1'
stub omarchy-system-lid-inhibit 'exit 0'
stub omarchy-hw-external-monitors '[[ -e $TEST_DIR/docked ]]'
stub omarchy-hw-laptop-closed '[[ -e $TEST_DIR/closed ]]'
stub omarchy-agent-awake '[[ $1 == "active" && -e $TEST_DIR/awake ]]'
stub omarchy-shell '[[ $* == "lock isLocked" ]] && { [[ -e $TEST_DIR/locked ]] && echo true || echo false; }'
for command in omarchy-system-lock omarchy-hyprland-monitor-clamshell omarchy-brightness-display omarchy-brightness-keyboard; do
  stub "$command" "echo $command >>\"\$TEST_DIR/watch-log\""
done

# The startup pass runs before any event is read, and socat ending at once ends
# the watcher; its delayed retries are left to the process group to clean up.
watch_once() {
  rm -f "$tmpdir"/{docked,closed,awake,locked}
  for flag in "$@"; do touch "$tmpdir/$flag"; done
  : >"$watch_log"
  PATH="$watch_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test setsid "$ROOT/bin/omarchy-hyprland-monitor-watch" &
  local pid=$!
  wait "$pid" || true
  kill -- -"$pid" 2>/dev/null || true
  mapfile -t watched <"$watch_log"
}

watch_once closed awake
[[ ${watched[*]:0:4} == "omarchy-system-lock omarchy-hyprland-monitor-clamshell omarchy-brightness-keyboard omarchy-brightness-display" ]] ||
  fail "a closed, undocked lid under Agent Awake locks, reconciles, then blanks" "calls: ${watched[*]}"
pass "a closed, undocked lid under Agent Awake locks, reconciles, then blanks"

watch_once closed awake locked
[[ ${watched[*]:0:3} == "omarchy-hyprland-monitor-clamshell omarchy-brightness-keyboard omarchy-brightness-display" ]] ||
  fail "an already locked session is blanked again, not locked again" "calls: ${watched[*]}"
pass "an already locked session is blanked again, not locked again"

for flags in "closed" "awake" "closed awake docked"; do
  # shellcheck disable=SC2086
  watch_once $flags
  [[ ${watched[*]:0:1} == "omarchy-hyprland-monitor-clamshell" && ${#watched[@]} -ge 1 && " ${watched[*]} " != *" omarchy-system-lock "* && " ${watched[*]} " != *brightness* ]] ||
    fail "'$flags' neither locks nor blanks" "calls: ${watched[*]}"
done
pass "without Agent Awake, with the lid open, or docked, the watcher neither locks nor blanks"
