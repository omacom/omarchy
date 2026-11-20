#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command flock

# A diagnosis must not chain another (#11992): a crash the diagnosis causes, the
# agent's own included, is announced without the offer, and so is a program
# whose diagnosis is under way. Driven through the real watcher,
# omarchy-agent-crash and omarchy-agent, with the journal, the agent, the
# terminal and the notification sender stubbed.

TMPDIR=$(mktemp -d)
holders=()
cleanup() {
  ((${#holders[@]} == 0)) || kill "${holders[@]}" 2>/dev/null || true
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

# A runner inside a diagnosis would mark every command below as part of it.
unset OMARCHY_CRASH_DIAGNOSIS

stub_bin="$TMPDIR/bin"
test_home="$TMPDIR/home"
stamps="$test_home/.local/state/omarchy/crash-diagnosis"
NOTIFY_LOG="$TMPDIR/notify-log"
AGENT_LOG="$TMPDIR/agent-log"
JOURNAL_ARGS="$TMPDIR/journal-args"
JOURNAL_ENTRIES="$TMPDIR/journal-entries"
LAUNCH_LOG="$TMPDIR/launch-log"
DEFAULT_AGENT="$TMPDIR/default-agent"
MISSING_COMMANDS="$TMPDIR/missing-commands"
export NOTIFY_LOG AGENT_LOG JOURNAL_ARGS JOURNAL_ENTRIES LAUNCH_LOG DEFAULT_AGENT MISSING_COMMANDS

mkdir -p "$stub_bin" "$test_home"
echo opencode >"$DEFAULT_AGENT"
: >"$MISSING_COMMANDS"

# --output-fields is an allowlist the real journal applies silently, so the stub
# applies it too: a field the watcher reads without asking for it arrives
# missing here as it would on a real machine.
cat >"$stub_bin/journalctl" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$JOURNAL_ARGS"
fields=
for arg; do
  [[ $arg == --output-fields=* ]] && fields=${arg#--output-fields=}
done
if [[ -n $fields ]]; then
  jq -c --arg f "$fields" '($f | split(",")) as $f | with_entries(select(.key | IN($f[])))' "$JOURNAL_ENTRIES"
else
  cat "$JOURNAL_ENTRIES"
fi
SH

cat >"$stub_bin/coredumpctl" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
cat "$DEFAULT_AGENT"
SH

cat >"$stub_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
grep -Fqx -- "$1" "$MISSING_COMMANDS"
SH

cat >"$stub_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH

# Stands in for the agent launcher when omarchy-agent-crash is driven, so the
# test sees whether a diagnosis was started, with what marker, and whether the
# dispatch lock came along with it.
cat >"$stub_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf 'marker=%s\n' "${OMARCHY_CRASH_DIAGNOSIS:-}" >>"$AGENT_LOG"
if flock -n "$HOME/.local/state/omarchy/crash-diagnosis.lock" true; then
  echo "lock=free" >>"$AGENT_LOG"
else
  echo "lock=held" >>"$AGENT_LOG"
fi
SH

cat >"$stub_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$LAUNCH_LOG"
SH

chmod +x "$stub_bin"/*

# Scratch HOME and XDG dirs for every command under test, so the stamps live
# here and nothing else in the run can see them, and none of the runner's
# tunables, so its environment cannot change a result. XDG state is kept apart
# from HOME's on purpose: the stamps live under HOME, as the crash-ignore flags
# do, and a script that looked under XDG instead would part from the other.
in_scratch() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  HOME="$test_home" \
  XDG_CONFIG_HOME="$test_home/.config" \
  XDG_STATE_HOME="$test_home/.xdg-state" \
  XDG_DATA_HOME="$test_home/.local/share" \
  XDG_CACHE_HOME="$test_home/.cache" \
  OMARCHY_PATH="$ROOT" \
    env -u OMARCHY_CRASH_DIAGNOSIS_COOLDOWN_SECONDS -u OMARCHY_CRASH_DIAGNOSIS_MAX_SECONDS \
      -u OMARCHY_CRASH_DEDUPE_SECONDS -u OMARCHY_CRASH_IGNORE "$@"
}

reset_entries() {
  : >"$JOURNAL_ENTRIES"
}

# One core dump as systemd-coredump journals it, with the crashed process's
# environment as one newline-separated string.
crash_entry() {
  local comm=$1 exe=$2 environ=${3:-HOME=/home/someone}

  jq -cn --arg uid "$UID" --arg comm "$comm" --arg exe "$exe" --arg environ "$environ" \
    '{_UID: $uid, COREDUMP_COMM: $comm, COREDUMP_PID: "4242",
      COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: "SIGSEGV",
      COREDUMP_ENVIRON: $environ}' >>"$JOURNAL_ENTRIES"
}

# The same, as the journal hands it over when the environment holds a byte that
# is not printable UTF-8: an array of byte values. This one ends in a lone 0xff.
crash_entry_bytes() {
  local comm=$1 exe=$2 environ=$3

  jq -cn --arg uid "$UID" --arg comm "$comm" --arg exe "$exe" --arg environ "$environ" \
    '{_UID: $uid, COREDUMP_COMM: $comm, COREDUMP_PID: "4242",
      COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: "SIGSEGV",
      COREDUMP_ENVIRON: (($environ | explode) + [10, 88, 61, 255])}' >>"$JOURNAL_ENTRIES"
}

run_watch() {
  local status=0

  : >"$NOTIFY_LOG"
  in_scratch "$ROOT/bin/omarchy-crash-watch" || status=$?
  ((status == 0)) || fail "the watcher exited $status rather than carrying on"
}

# What a click on an offering toast runs.
click_diagnose() {
  in_scratch "$ROOT/bin/omarchy-agent-crash" 4242 "$1" "/usr/bin/$1" SIGSEGV
}

announced() {
  grep -Fq "Process crashed: $1" "$NOTIFY_LOG"
}

offered() {
  grep -Eq "Process crashed: $1 .*--exec omarchy-agent-crash 4242 $1 " "$NOTIFY_LOG"
}

held() {
  announced "$1" && ! offered "$1"
}

diagnoses_started() {
  if [[ -f $AGENT_LOG ]]; then
    grep -c '^marker=' "$AGENT_LOG"
  else
    echo 0
  fi
}

# Starts a process carrying a diagnosis's marker, as the agent or something it
# ran would, and waits until it has exec'd so its environment shows the marker.
hold_marker() {
  local marker=$1 tries

  env "OMARCHY_CRASH_DIAGNOSIS=$marker" sleep 300 >/dev/null 2>&1 &
  holder=$!
  holders+=("$holder")
  for ((tries = 0; tries < 100; tries++)); do
    grep -qszxF -- "OMARCHY_CRASH_DIAGNOSIS=$marker" "/proc/$holder/environ" && return
    sleep 0.05
  done
  fail "the stand-in diagnosis process never showed its marker"
}

release_marker() {
  kill "$holder" 2>/dev/null || true
  wait "$holder" 2>/dev/null || true
}

# Moves a program's diagnoses back in time by their own start, which is what
# ages them, rather than the stamp's mtime: every line, or only the one given.
backdate() {
  local stamp="$stamps/$1" by=$2 only=${3:-} lines line

  mapfile -t lines <"$stamp"
  : >"$stamp"
  for line in "${lines[@]}"; do
    if [[ -z $only || $line == "$only" ]]; then
      line="${line%%:*}:$((${line#*:} - by))"
    fi
    printf '%s\n' "$line" >>"$stamp"
  done
}

# An ordinary crash is offered a diagnosis, and a click starts exactly one.
reset_entries
crash_entry brave /opt/brave/brave
run_watch
offered brave ||
  fail "an ordinary crash no longer offers a diagnosis" "$(cat "$NOTIFY_LOG")"
click_diagnose brave
(($(diagnoses_started) == 1)) ||
  fail "clicking an ordinary crash's toast did not start one diagnosis"
grep -Eqx "marker=4242:[0-9]+" "$AGENT_LOG" ||
  fail "the diagnosis is not marked with the crash it is diagnosing and when, so the crashes it causes look new" "$(cat "$AGENT_LOG")"
[[ $(cat "$stamps/brave") == "$(sed -n 's/^marker=//p' "$AGENT_LOG")" ]] ||
  fail "the stamp does not record the marker the diagnosis carries, so the watcher cannot tell whether it is still at work"
grep -Fqx "lock=free" "$AGENT_LOG" ||
  fail "the dispatch lock rides into the agent, so it is held for the whole diagnosis"
pass "an ordinary crash offers a diagnosis and a click starts one, marked"

# A second click, on an older toast for the same program, does not start a
# second diagnosis alongside the first, and the refusal offers the way past it.
: >"$NOTIFY_LOG"
click_diagnose brave
(($(diagnoses_started) == 1)) ||
  fail "a second click on the same program started a second diagnosis while the first is under way"
grep -Fq "Already diagnosing brave" "$NOTIFY_LOG" ||
  fail "a refused click says nothing, so the user cannot tell it from a broken toast"
grep -Fq -- "--exec omarchy-agent-crash --again 4242 brave /usr/bin/brave SIGSEGV" "$NOTIFY_LOG" ||
  fail "the refusal offers no way to start a diagnosis anyway, so a stale guard is a dead end" "$(cat "$NOTIFY_LOG")"
pass "a program already being diagnosed is not dispatched twice"

in_scratch "$ROOT/bin/omarchy-agent-crash" --again 4242 brave /usr/bin/brave SIGSEGV
(($(diagnoses_started) == 2)) ||
  fail "the refusal's action does not start a diagnosis anyway"
pass "the refusal's action starts a diagnosis anyway"

# The same program crashing again within the cooldown, as the diagnosis
# reproduces it, is announced without the offer.
reset_entries
crash_entry brave /opt/brave/brave
run_watch
announced brave ||
  fail "a crash within the cooldown is not announced at all"
! offered brave ||
  fail "a crash of a program sent for diagnosis minutes ago offers another, chaining an agent per reproduction"
grep -Fq "Already sent for AI diagnosis" "$NOTIFY_LOG" ||
  fail "the toast without the offer does not say why"
pass "a repeat crash within the cooldown is announced without the offer"

# Another program in the same window is still offered.
reset_entries
crash_entry nautilus /usr/bin/nautilus
run_watch
offered nautilus ||
  fail "a diagnosis of one program held back the offer for another"
pass "the cooldown is per program"

# After the cooldown, with nothing left carrying the marker, the same program is
# offered again, and a click starts a diagnosis again.
backdate brave 660
reset_entries
crash_entry brave /opt/brave/brave
run_watch
offered brave ||
  fail "a program is never offered a diagnosis again once its cooldown has passed"
click_diagnose brave
(($(diagnoses_started) == 3)) ||
  fail "a click after the cooldown did not start a diagnosis"
pass "after the cooldown a program is offered and dispatched again"

# A stamp from the future, after the clock stepped back, does not hold the
# program for hours.
mkdir -p "$stamps"
echo "4242:$((EPOCHSECONDS + 7200))" >"$stamps/mpv"
reset_entries
crash_entry mpv /usr/bin/mpv
run_watch
offered mpv ||
  fail "a stamp dated in the future holds its program back until the clock catches up"
click_diagnose mpv
(($(diagnoses_started) == 4)) ||
  fail "a click is refused against a stamp dated in the future"
pass "a stamp dated in the future holds nothing back"

# A click with no agent to start must not stamp anything: the launch would fail
# silently, and the stamp would then refuse every click for the cooldown.
: >"$DEFAULT_AGENT"
: >"$NOTIFY_LOG"
click_diagnose krita 2>/dev/null && fail "a click with no default agent reports success"
[[ ! -e $stamps/krita ]] ||
  fail "a click with no default agent stamped the program, refusing every click after it for nothing"
(($(diagnoses_started) == 4)) ||
  fail "a click with no default agent still tried to start one"
grep -Fq "No AI agent to diagnose krita" "$NOTIFY_LOG" ||
  fail "a click with no default agent says nothing, so the toast looks broken" "$(cat "$NOTIFY_LOG")"
echo opencode >"$DEFAULT_AGENT"

echo opencode >"$MISSING_COMMANDS"
: >"$NOTIFY_LOG"
click_diagnose krita 2>/dev/null && fail "a click with the default agent not installed reports success"
[[ ! -e $stamps/krita ]] ||
  fail "a click with the default agent not installed stamped the program"
grep -Fq "opencode is not installed" "$NOTIFY_LOG" ||
  fail "a click with the default agent not installed does not say so" "$(cat "$NOTIFY_LOG")"
: >"$MISSING_COMMANDS"
pass "a click that cannot start an agent says so and holds nothing back"

# A crash carrying the marker came from inside a diagnosis: the agent itself, or
# something it ran. It is announced without the offer, whatever its name.
reset_entries
crash_entry opencode /home/someone/.local/bin/opencode $'HOME=/home/someone\nOMARCHY_CRASH_DIAGNOSIS=4242:'"$EPOCHSECONDS"$'\nTERM=xterm'
run_watch
announced opencode ||
  fail "a crash inside a diagnosis is not announced at all"
! offered opencode ||
  fail "the diagnosis agent's own crash offers a diagnosis of its own, chaining an agent per hop"
grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "the toast for a crash inside a diagnosis does not say why there is no offer"
pass "a crash inside a diagnosis is announced without the offer"

# The marker can be the first variable in the block, with no newline before it.
reset_entries
crash_entry opencode /home/someone/.local/bin/opencode "OMARCHY_CRASH_DIAGNOSIS=4242:$EPOCHSECONDS"$'\nHOME=/home/someone'
run_watch
held opencode && grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "a marker that is the first variable in the environment is missed"
pass "the marker is found as the first variable"

# An environment with an escape in it (an exported PS1) and a byte that is not
# UTF-8 arrives as an array of bytes, and the marker in it still counts.
reset_entries
crash_entry_bytes opencode /home/someone/.local/bin/opencode $'PS1=\e[1;32m\\u\e[0m$ \nOMARCHY_CRASH_DIAGNOSIS=4242:'"$EPOCHSECONDS"$'\nHOME=/home/someone'
run_watch
held opencode && grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "an environment journalled as bytes loses the marker, and the chain comes back" "$(cat "$NOTIFY_LOG")"
pass "the marker is found in an environment journalled as bytes"

# A marker older than the maximum is a program the agent left running, crashing
# long after the diagnosis ended, and is offered like any other.
reset_entries
crash_entry opencode /home/someone/.local/bin/opencode $'HOME=/home/someone\nOMARCHY_CRASH_DIAGNOSIS=4242:'"$((EPOCHSECONDS - 7200))"
run_watch
offered opencode ||
  fail "a marker from a diagnosis hours ago still holds the offer back, so a program the agent left running is never offered again"
pass "an expired marker holds nothing back"

# Only the variable itself counts, not a value that mentions it.
reset_entries
crash_entry gimp /usr/bin/gimp "NOTE=OMARCHY_CRASH_DIAGNOSIS=1:$EPOCHSECONDS"
run_watch
offered gimp ||
  fail "a variable whose value mentions the marker is read as the marker"
pass "the marker is matched as a variable, not as text anywhere in the environment"

# Past the cooldown, a program is still held while something carries the marker
# its stamp records: the diagnosis is still at work. Once nothing does, or past
# the maximum whatever is still running, it is offered again.
click_diagnose vlc
backdate vlc 660
read -r vlc_marker <"$stamps/vlc"
hold_marker "$vlc_marker"
reset_entries
crash_entry vlc /usr/bin/vlc
run_watch
held vlc ||
  fail "a diagnosis still at work past the cooldown is chained by its program's next crash"
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_diagnose vlc
(($(diagnoses_started) == starts)) && grep -Fq "Already diagnosing vlc" "$NOTIFY_LOG" ||
  fail "a click past the cooldown starts a second diagnosis while the first is still at work"
pass "a diagnosis still at work holds its program past the cooldown"

release_marker
backdate vlc 6540
read -r vlc_marker <"$stamps/vlc"
hold_marker "$vlc_marker"
run_watch
offered vlc ||
  fail "a process left carrying the marker holds its program back past the maximum"
pass "the maximum bounds a diagnosis still apparently at work"

release_marker
backdate vlc -6540
run_watch
offered vlc ||
  fail "a finished diagnosis still holds its program back after the cooldown"
pass "a finished diagnosis holds nothing back after the cooldown"

# A diagnosis started anyway goes beside the one under way, not in its place:
# with the second's cooldown over and the second finished, the first, still at
# work, holds its program. Only once it finishes too is the program offered.
click_diagnose totem
backdate totem 1200
read -r first_marker <"$stamps/totem"
hold_marker "$first_marker"
starts=$(diagnoses_started)
in_scratch "$ROOT/bin/omarchy-agent-crash" --again 4242 totem /usr/bin/totem SIGSEGV
(($(diagnoses_started) == starts + 1)) ||
  fail "a diagnosis started anyway beside one still at work did not start"
second_marker=$(sed -n 's/^marker=//p' "$AGENT_LOG" | tail -n 1)
backdate totem 660 "$second_marker"
reset_entries
crash_entry totem /usr/bin/totem
run_watch
held totem ||
  fail "starting a diagnosis anyway dropped the first one's guard, so its reproductions chain an agent once the second's cooldown ends" "$(cat "$stamps/totem")"
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_diagnose totem
(($(diagnoses_started) == starts)) && grep -Fq "Already diagnosing totem" "$NOTIFY_LOG" ||
  fail "a click starts another diagnosis while the first of two is still at work"
(($(grep -c . "$stamps/totem") == 2)) ||
  fail "the stamp does not keep a line for each diagnosis" "$(cat "$stamps/totem")"
pass "a diagnosis started anyway keeps the first one's guard"

release_marker
run_watch
offered totem ||
  fail "a program is held back after every diagnosis of it has finished"
pass "a program is offered again once every diagnosis of it has finished"

# Two clicks at once must not both start one. A click that finds another
# dispatch holding the lock is refused, and stamps nothing.
# The holder execs into sleep with the lock still open, so killing it is what
# releases the lock, and nothing outlives the test holding it.
bash -c 'exec 9>>"$1" && flock 9 && exec sleep 300' _ "$stamps.lock" >/dev/null 2>&1 &
holders+=("$!")
for ((tries = 0; tries < 100; tries++)); do
  flock -n "$stamps.lock" true || break
  sleep 0.05
done
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_diagnose gedit
(($(diagnoses_started) == starts)) ||
  fail "a click started a diagnosis while another dispatch held the lock"
[[ ! -e $stamps/gedit ]] ||
  fail "a click refused for the lock still stamped the program"
grep -Fq "Already diagnosing gedit" "$NOTIFY_LOG" ||
  fail "a click refused for the lock says nothing"
kill "${holders[-1]}"
wait "${holders[-1]}" 2>/dev/null || true
pass "a click racing another dispatch is refused"

# Without --all the journal turns an environment over 4 KiB into null, and the
# marker would never be seen on a real machine.
grep -Fqx -- "--all" "$JOURNAL_ARGS" ||
  fail "the watcher reads the journal without --all, so a real crash's environment arrives as null"
grep -Eq -- '^--output-fields=.*COREDUMP_ENVIRON' "$JOURNAL_ARGS" ||
  fail "the watcher does not ask for COREDUMP_ENVIRON"
pass "the watcher asks the journal for the crashed process's full environment"

# The terminal is launched through uwsm, which does not pass our environment on,
# so the marker has to ride in the command the terminal runs.
OMARCHY_CRASH_DIAGNOSIS=4242:1700000000 in_scratch "$ROOT/bin/omarchy-agent" --prompt "why"
mapfile -d '' launched <"$LAUNCH_LOG"
[[ ${launched[1]:-} == "env" && ${launched[2]:-} == "OMARCHY_CRASH_DIAGNOSIS=4242:1700000000" && ${launched[3]:-} == "opencode" ]] ||
  fail "the marker does not reach the agent's terminal command" "${launched[*]}"
pass "the agent launcher carries the marker into the terminal"

in_scratch env -u OMARCHY_CRASH_DIAGNOSIS "$ROOT/bin/omarchy-agent" --prompt "why"
mapfile -d '' launched <"$LAUNCH_LOG"
[[ ${launched[1]:-} == "opencode" ]] ||
  fail "an ordinary agent launch gained a wrapper it did not ask for" "${launched[*]}"
pass "an ordinary agent launch is unchanged"
