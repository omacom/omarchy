#!/bin/bash
# Launcher behaviour with a fake client and a fake `owe`. Fixtures live in a
# retained ${TMPDIR:-/var/tmp} directory.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
run=$root/omarchy-plymouth-continuity-run
work=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-continuity-launcher-test.XXXXXX")

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Fake client: records its arguments, then waits for SIGUSR1 or SIGTERM.
cat >"$work/client" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$FAKE_DIR/client-args"
trap 'echo usr1 >"$FAKE_DIR/client-signal"; exit 0' USR1
trap 'echo term >"$FAKE_DIR/client-signal"; exit 0' TERM
for _ in $(seq 1 200); do sleep 0.05; done
echo timeout >"$FAKE_DIR/client-signal"
EOF
# Fake owe: replays one render-status line per call from $FAKE_DIR/script,
# and records its pid at the first call (pids are allocated in fork order).
cat >"$work/owe" <<'EOF'
#!/bin/bash
[[ $1 == render-status ]] || exit 1
[[ -e $FAKE_DIR/owe-pid ]] || echo $$ >"$FAKE_DIR/owe-pid"
n=$(cat "$FAKE_DIR/calls" 2>/dev/null || echo 0)
echo $((n + 1)) >"$FAKE_DIR/calls"
line=$(sed -n "$((n + 1))p" "$FAKE_DIR/script")
[[ -n $line ]] || line=$(tail -n 1 "$FAKE_DIR/script")
[[ $line == FAIL ]] && exit 1
printf '%s\n' "$line"
EOF
chmod +x "$work/client" "$work/owe"

# case NAME EXPECTED_REASON_REGEX [env...] < script
case_run() {
  local name=$1 expect=$2
  shift 2
  local dir=$work/$name
  mkdir "$dir"
  cat >"$dir/script"
  local start=$EPOCHREALTIME
  env FAKE_DIR="$dir" OMARCHY_CONTINUITY_CLIENT="$work/client" \
    OMARCHY_CONTINUITY_OWE="$work/owe" OMARCHY_CONTINUITY_POLL_MS=10 "$@" \
    bash "$run" --file /nonexistent 2>"$dir/log"
  local status=$?
  ((status == 0)) || fail "$name: exit status $status"
  grep -Eq "$expect" "$dir/log" || fail "$name: expected /$expect/ in: $(cat "$dir/log")"
  for _ in $(seq 1 100); do [[ -s $dir/client-signal ]] && break; sleep 0.02; done
  printf '%s: PASS (%s)\n' "$name" "$(tail -n 1 "$dir/log" | sed 's/^omarchy-plymouth-continuity-run: //')"
}

case_run playing 'reason=intro-playing time_pos=0.12' <<'EOF'
{"status":"ok","intro":false,"time_pos":0.0,"has_video":false,"swaps":0}
{"status":"ok","intro":true,"time_pos":0.0,"has_video":true,"swaps":1}
{"status":"ok","intro":true,"time_pos":0.04,"has_video":true,"swaps":3}
{"status":"ok","intro":true,"time_pos":0.12,"has_video":true,"swaps":9}
EOF
[[ $(cat "$work/playing/client-signal") == usr1 ]] || fail "playing: client not signalled"
grep -qx -- '--max-ms' "$work/playing/client-args" || fail "client did not get --max-ms"
grep -qx -- '--file' "$work/playing/client-args" || fail "client options not passed through"
[[ $(cat "$work/playing/calls") == 4 ]] || fail "playing: expected 4 owe calls"
# The client is started before anything else: it was forked before the first
# owe call (the launcher logs its pid).
client_pid=$(sed -n 's/.*started client pid=\([0-9]*\).*/\1/p' "$work/playing/log")
[[ -n $client_pid ]] || fail "playing: no start log line"
(($(cat "$work/playing/owe-pid") > client_pid)) || fail "playing: owe ran before the client"
# Nothing forks before the client: no command substitution or external
# command ahead of its start line.
grep -q '"$client" --max-ms' "$run" || fail "launcher: client start line not found"
prelude=$(sed -n '/"\$client" --max-ms/q;p' "$run" | grep -v '^[[:space:]]*#')
if grep -nE '\$\([^(]|`|sleep|command -v|timeout|owe|dirname' <<<"$prelude"; then
  fail "launcher: something forks before the client starts"
fi

# intro_result must not be mistaken for intro, nor has_intro.
case_run keys 'reason=intro-playing time_pos=1.5e-1' <<'EOF'
{"intro_result":"ok","has_intro":true,"intro":true,"time_pos":1.5e-1}
EOF

case_run ended 'reason=intro-ended' <<'EOF'
{"intro":true,"time_pos":0.0}
{"intro":false,"time_pos":0.0}
EOF

case_run no-intro 'reason=no-intro-within-300ms' OMARCHY_CONTINUITY_INTRO_WAIT_MS=300 <<'EOF'
{"intro":false,"render_alive":false}
EOF

case_run owe-fails 'reason=no-intro-within-200ms' OMARCHY_CONTINUITY_INTRO_WAIT_MS=200 <<'EOF'
FAIL
EOF

case_run threshold 'reason=intro-playing time_pos=0.3' OMARCHY_CONTINUITY_TIME_POS=0.25 <<'EOF'
{"intro":true,"time_pos":0.2}
{"intro":true,"time_pos":0.3}
EOF
[[ $(cat "$work/threshold/calls") == 2 ]] || fail "threshold: signalled too early"

case_run swaps 'reason=intro-playing time_pos=0.2 swaps=5' OMARCHY_CONTINUITY_MIN_SWAPS=5 <<'EOF'
{"intro":true,"time_pos":0.1,"swaps":2}
{"intro":true,"time_pos":0.2,"swaps":5}
EOF

case_run stuck-intro 'max-ms reached' OMARCHY_CONTINUITY_MAX_MS=400 <<'EOF'
{"intro":true,"time_pos":0.0}
EOF

case_run no-owe 'reason=no-owe' OMARCHY_CONTINUITY_OWE="$work/missing-owe" <<'EOF'
EOF

# Without OMARCHY_CONTINUITY_CLIENT the client next to the script is used,
# else one in PATH; a bad OMARCHY_CONTINUITY_MAX_MS falls back to 8000.
dir=$work/discovery
mkdir -p "$dir/side" "$dir/path"
cp "$run" "$dir/side/omarchy-plymouth-continuity-run"
cp "$run" "$dir/omarchy-plymouth-continuity-run"
for where in side path; do
  printf '#!/bin/bash\nprintf "%%s\\n" %s "$@" >"%s/%s.args"\n' "$where" "$dir" "$where" \
    >"$dir/$where/omarchy-plymouth-continuity"
  chmod +x "$dir/$where/omarchy-plymouth-continuity"
done
env -u OMARCHY_CONTINUITY_CLIENT OMARCHY_CONTINUITY_OWE="$work/missing-owe" \
  bash "$dir/side/omarchy-plymouth-continuity-run" --file /nonexistent 2>"$dir/side.log" ||
  fail "discovery: non-zero exit"
for _ in $(seq 1 100); do [[ -s $dir/side.args ]] && break; sleep 0.02; done
[[ $(head -n 3 "$dir/side.args" | tr '\n' ' ') == "side --max-ms 8000 " ]] ||
  fail "discovery: sibling client not used: $(cat "$dir/side.args" 2>/dev/null)"
env -u OMARCHY_CONTINUITY_CLIENT OMARCHY_CONTINUITY_OWE="$work/missing-owe" \
  OMARCHY_CONTINUITY_MAX_MS=bogus PATH="$dir/empty:$dir/path:$PATH" \
  bash "$dir/omarchy-plymouth-continuity-run" 2>"$dir/path.log" || fail "discovery: non-zero exit"
for _ in $(seq 1 100); do [[ -s $dir/path.args ]] && break; sleep 0.02; done
[[ $(head -n 3 "$dir/path.args" | tr '\n' ' ') == "path --max-ms 8000 " ]] ||
  fail "discovery: PATH client not used: $(cat "$dir/path.args" 2>/dev/null)"
printf 'discovery: PASS\n'

# A missing client exits 0 immediately.
dir=$work/no-client
mkdir "$dir"
OMARCHY_CONTINUITY_CLIENT="$work/missing-client" bash "$run" 2>"$dir/log" ||
  fail "no-client: non-zero exit"
grep -q 'client not found' "$dir/log" || fail "no-client: no log line"
printf 'no-client: PASS\n'
printf 'launcher tests: PASS (fixtures retained in %s)\n' "$work"
