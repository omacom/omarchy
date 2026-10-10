#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

SCRIPT="$ROOT/bin/omarchy-capture-screenrecording-process"

tmp=$(mktemp -d)
cleanup() {
  local file
  for file in "$tmp"/*.pid; do
    [[ -f $file ]] && kill -KILL "$(<"$file")" 2>/dev/null || true
  done
  rm -rf "$tmp"
}
trap cleanup EXIT
mkdir -p "$tmp/bin"

# pgrep reports the pids listed in $TEST_STATE/running, as a recorder search would.
cat >"$tmp/bin/pgrep" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_STATE/pgrep-args"
[[ -s $TEST_STATE/running ]] || exit 1
cat "$TEST_STATE/running"
SH
chmod +x "$tmp/bin/pgrep"
export TEST_STATE="$tmp"

# A fake /proc gives each pid the executable link only Linux provides.
exe() {
  mkdir -p "$tmp/proc/$1"
  ln -sfn "$2" "$tmp/proc/$1/exe"
}

recorders() {
  local pid
  printf '%s\n' "$@" >"$tmp/running"
  for pid; do
    [[ -L $tmp/proc/$pid/exe ]] || exe "$pid" /usr/bin/gpu-screen-recorder
  done
}

run() {
  local status=0
  OMARCHY_PROC_ROOT="$tmp/proc" PATH="$tmp/bin:$PATH" "$SCRIPT" "$@" 2>"$tmp/stderr" || status=$?
  echo "$status"
}

# Job control keeps SIGINT deliverable to background jobs, which a
# non-interactive shell would otherwise start with it ignored.
set -m
spawn() {
  local name=$1
  bash -c 'trap "echo INT >\"$0\"; exit 0" INT; while :; do sleep 0.05; done' "$tmp/$name.signal" &
  echo $! >"$tmp/$name.pid"
  disown
}

got_int() {
  local name=$1 tries=0
  while [[ ! -s $tmp/$name.signal ]] && ((tries < 100)); do
    sleep 0.02
    tries=$((tries + 1))
  done
  [[ -s $tmp/$name.signal ]]
}

alive() {
  kill -0 "$1" 2>/dev/null
}

wait_dead() {
  local tries=0
  while alive "$1" && ((tries < 100)); do
    sleep 0.02
    tries=$((tries + 1))
  done
  ! alive "$1"
}

: >"$tmp/running"
[[ $(run) == 1 ]] || fail "no recorder running exits 1"
[[ $(run --pid 123) == 1 ]] || fail "a pid with no recorder running exits 1"
pass "no recorder running exits 1"

recorders 4242
[[ $(run) == 0 ]] || fail "a running recorder exits 0"
[[ $(<"$tmp/pgrep-args") == "-u $UID -x gpu-screen-reco(rder)?|wf-recorder" ]] ||
  fail "recorders are found by the current user's process name" "$(<"$tmp/pgrep-args")"
pass "a running recorder exits 0"

recorders 4242 4343
[[ $(run --pid 4343) == 0 ]] || fail "--pid of a recorder exits 0"
[[ $(run --pid 04343) == 0 ]] || fail "--pid ignores leading zeros"
[[ $(run --pid 0000000000000004343) == 0 ]] || fail "--pid ignores leading zeros past ten digits"
[[ $(run --pid 4194304) == 1 ]] || fail "--pid accepts the largest Linux pid"
[[ $(run --pid 999) == 1 ]] || fail "--pid of a non-recorder exits 1"
[[ $(run --pid 434) == 1 ]] || fail "--pid matches whole pids only"
[[ $(run --pid 999 --pid 4242) == 0 ]] || fail "repeated --pid matches any of them"
pass "--pid restricts the check to the given recorder pids"

spawn a
spawn b
spawn other
recorders "$(<"$tmp/a.pid")" "$(<"$tmp/b.pid")"
[[ $(run --signal INT) == 0 ]] || fail "--signal INT with recorders exits 0"
got_int a && got_int b || fail "--signal INT interrupts every recorder"
alive "$(<"$tmp/other.pid")" && [[ ! -s $tmp/other.signal ]] || fail "--signal INT leaves other processes alone"
pass "--signal INT interrupts every recorder and nothing else"

spawn c
spawn d
recorders "$(<"$tmp/c.pid")" "$(<"$tmp/d.pid")"
[[ $(run --pid "$(<"$tmp/c.pid")" --signal INT) == 0 ]] || fail "--pid with --signal INT exits 0"
got_int c || fail "--pid with --signal INT interrupts the given recorder"
[[ ! -s $tmp/d.signal ]] && alive "$(<"$tmp/d.pid")" || fail "--pid with --signal INT leaves other recorders alone"
[[ $(run --pid "$(<"$tmp/d.pid")" --signal KILL) == 0 ]] || fail "--signal KILL exits 0"
wait_dead "$(<"$tmp/d.pid")" || fail "--signal KILL kills the given recorder"
[[ ! -s $tmp/d.signal ]] || fail "--signal KILL does not interrupt first"
alive "$(<"$tmp/other.pid")" || fail "--signal KILL leaves other processes alone"
[[ $(run --pid 999 --signal KILL) == 1 ]] || fail "--signal with no matching recorder exits 1"
alive "$(<"$tmp/other.pid")" || fail "--signal with no matching recorder signals nothing"
pass "--pid with --signal INT or KILL sends that signal to only the given recorder"

spawn e
gone=$(<"$tmp/d.pid")
recorders "$gone" "$(<"$tmp/e.pid")"
[[ $(run --signal INT) == 0 ]] || fail "a recorder exiting before its signal is not an error"
got_int e || fail "a recorder exiting before its signal does not stop the others being signalled"
pass "a recorder exiting before its signal is not an error"

exe 5001 /usr/bin/gpu-screen-recorder-helper
exe 5002 "/usr/bin/wf-recorder (deleted)"
recorders 5001
[[ $(run) == 1 ]] || fail "a process named like a recorder but running another executable is not a recorder"
[[ $(run --pid 5001) == 1 ]] || fail "--pid of a recorder-prefixed helper exits 1"
recorders 5003
rm -rf "$tmp/proc/5003"
[[ $(run) == 1 ]] || fail "a candidate whose executable cannot be read is not a recorder"
recorders 5002
[[ $(run) == 0 ]] || fail "a recorder whose executable an upgrade replaced is still a recorder"
spawn helper
exe "$(<"$tmp/helper.pid")" /usr/bin/gpu-screen-recorder-helper
recorders "$(<"$tmp/helper.pid")"
[[ $(run --signal INT) == 1 ]] || fail "--signal with only a recorder-prefixed helper exits 1"
alive "$(<"$tmp/helper.pid")" && [[ ! -s $tmp/helper.signal ]] || fail "--signal leaves a recorder-prefixed helper alone"
pass "the executable, not the truncated process name, decides what is a recorder"

true &
dead1=$!
wait "$dead1"
true &
dead2=$!
wait "$dead2"
recorders "$dead1" "$dead2"
[[ $(run --signal INT) == 1 ]] || fail "--signal exits 1 when every recorder exits before its signal"
pass "--signal exits 1 when no signal was delivered"

for args in "--pid" "--pid abc" "--pid -1" "--pid 12x" "--signal" "--signal TERM" "--signal int" "--bogus" "123" "--pid 1 extra" \
  "--pid 4194305" "--pid 12345678901" "--pid 18446744073709555959" "--pid 99999999999999999999"; do
  # shellcheck disable=SC2086
  [[ $(run $args) == 2 ]] || fail "invalid arguments exit 2: $args"
  grep -q '^Usage: omarchy-capture-screenrecording-process ' "$tmp/stderr" || fail "invalid arguments print usage: $args"
done
pass "invalid arguments print usage and exit 2"

# The real pgrep sees Linux's 15-character process names, which cut
# gpu-screen-recorder short.
if [[ -r /proc/self/comm ]]; then
  mkdir -p "$tmp/real"
  cp "$(command -v sleep)" "$tmp/real/gpu-screen-recorder"
  cp "$(command -v sleep)" "$tmp/real/wf-recorder"
  "$tmp/real/gpu-screen-recorder" 30 &
  gpu=$!
  echo "$gpu" >"$tmp/gpu.pid"
  "$tmp/real/wf-recorder" 30 &
  wf=$!
  echo "$wf" >"$tmp/wf.pid"
  disown -a
  sleep 0.2
  "$SCRIPT" --pid "$gpu" || fail "the real pgrep finds gpu-screen-recorder"
  "$SCRIPT" --pid "$wf" || fail "the real pgrep finds wf-recorder"
  "$SCRIPT" --pid "$gpu" --pid "$wf" --signal KILL || fail "the real pgrep signals both recorders"
  wait_dead "$gpu" && wait_dead "$wf" || fail "the real recorders are killed"
  pass "the real pgrep finds and signals both recorders by name"
else
  skip "the real pgrep finds and signals both recorders by name (needs Linux /proc)"
fi

grep -Fq '["omarchy-capture-screenrecording", "--status"]' "$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml" ||
  fail "the bar recording indicator asks the recorder script, which stop also uses"
! grep -Fq 'gpu-screen-recorder' "$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml" ||
  fail "the bar recording indicator still greps gpu-screen-recorder"
grep -Fq '"when":"omarchy-capture-screenrecording --status"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "Stop Screenrecording asks the recorder script, which its action also uses"
! grep -Fq "pgrep -f '^gpu-screen-recorder'" "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "Stop Screenrecording still greps gpu-screen-recorder"
pass "the bar indicator and the menu ask the recorder script whether its stop has a recording to end"
