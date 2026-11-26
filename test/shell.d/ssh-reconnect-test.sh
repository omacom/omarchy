#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command script

fns="$ROOT/default/bash/fns/ssh-reconnect"

# The behavior tests patch the 30-second drop threshold down to 2 seconds so
# they run quickly; make sure the marker they patch still exists. (Not 1:
# SECONDS is whole seconds, so a fast failure that crosses a second
# boundary would read as 1s elapsed and reconnect.)
grep -q 'SECONDS - started < 30' "$fns" ||
  fail "drop threshold marker exists for test patching"
pass "drop threshold marker exists for test patching"

# --- _ssh_interactive parsing ---

run_interactive() {
  bash -c "source '$fns'; _ssh_interactive \"\$@\"" _ "$@"
}

run_interactive -F /dev/null host || fail "plain destination is interactive"
pass "plain destination is interactive"

run_interactive -F /dev/null -p 2222 user@host || fail "separated option value is skipped"
pass "separated option value is skipped"

run_interactive -F /dev/null -4p2222 host || fail "glued option value is skipped"
pass "glued option value is skipped"

run_interactive -F /dev/null -L 8080:localhost:80 -o "ServerAliveInterval=5" host ||
  fail "forwarding and -o options are skipped"
pass "forwarding and -o options are skipped"

if run_interactive -F /dev/null -o "RemoteCommand=uptime" host; then
  fail "configured RemoteCommand is not interactive"
fi
pass "configured RemoteCommand is not interactive"

run_interactive -F /dev/null -o "RemoteCommand=none" host ||
  fail "explicit RemoteCommand none stays interactive"
pass "explicit RemoteCommand none stays interactive"

if run_interactive host uptime; then
  fail "remote command is not interactive"
fi
pass "remote command is not interactive"

if run_interactive -- host uptime; then
  fail "remote command after -- is not interactive"
fi
pass "remote command after -- is not interactive"

if run_interactive -p 2222; then
  fail "missing destination is not interactive"
fi
pass "missing destination is not interactive"

# --- reconnect behavior, run on a pty with a fake ssh ---

fake_dir=$(mktemp -d)
worker_pids=()
cleanup() {
  local pid
  for pid in "${worker_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  rm -rf "$fake_dir"
}
trap cleanup EXIT

cat >"$fake_dir/ssh" <<EOF
#!/bin/bash
[[ \$1 == "-G" ]] && { echo "remotecommand none"; exit 0; }
n=\$(( \$(cat "$fake_dir/count" 2>/dev/null || echo 0) + 1 ))
echo "\$n" >"$fake_dir/count"
read -r duration code <<<"\$(sed -n "\${n}p" "$fake_dir/plan")"
sleep "\$duration"
exit "\$code"
EOF
chmod +x "$fake_dir/ssh"

cat >"$fake_dir/driver" <<EOF
PATH="$fake_dir:\$PATH"
source <(sed 's/< 30/< 2/' "$fns")
sleep() { :; }
ssh "\$@"
echo "rc=\$?"
EOF

# Each plan line is "<duration> <exit code>" for one fake ssh attempt.
# Uses a private per-case directory so the sleep-based cases run in parallel.
run_case_dir() {
  local dir="$1" plan="$2"
  shift 2
  mkdir -p "$dir"
  cat >"$dir/ssh" <<EOF
#!/bin/bash
[[ \$1 == "-G" ]] && { echo "remotecommand none"; exit 0; }
n=\$(( \$(cat "$dir/count" 2>/dev/null || echo 0) + 1 ))
echo "\$n" >"$dir/count"
read -r duration code <<<"\$(sed -n "\${n}p" "$dir/plan")"
sleep "\$duration"
exit "\$code"
EOF
  chmod +x "$dir/ssh"
  cat >"$dir/driver" <<EOF
PATH="$dir:\$PATH"
source <(sed 's/< 30/< 2/' "$fns")
sleep() { :; }
ssh "\$@"
echo "rc=\$?"
EOF
  printf '%s\n' "$plan" >"$dir/plan"
  script -qec "bash '$dir/driver' $*" /dev/null | tr -d '\r' >"$dir/out"
}

disarm=$(printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h')

# Launch all independent pty cases in parallel so the 2s thresholds overlap.
run_case_dir "$fake_dir/c1" "0 255" host & worker_pids+=("$!")
run_case_dir "$fake_dir/c2" $'2 255\n0 0' host & worker_pids+=("$!")
run_case_dir "$fake_dir/c3" $'2 255\n0 255\n0 0' host & worker_pids+=("$!")
run_case_dir "$fake_dir/c4" $'2 255\n0 0' host uptime & worker_pids+=("$!")
(
  mkdir -p "$fake_dir/c5"
  sed "s|$fake_dir|$fake_dir/c5|g" "$fake_dir/ssh" >"$fake_dir/c5/ssh"
  chmod +x "$fake_dir/c5/ssh"
  cat >"$fake_dir/c5/driver" <<EOF
PATH="$fake_dir/c5:\$PATH"
source <(sed 's/< 30/< 2/' "$fns")
sleep() { :; }
ssh "\$@"
echo "rc=\$?"
EOF
  printf '%s\n' $'2 255\n0 0' >"$fake_dir/c5/plan"
  script -qec "bash '$fake_dir/c5/driver' host </dev/null" /dev/null | tr -d '\r' >"$fake_dir/c5/out"
) & worker_pids+=("$!")

# Ctrl-C must stop the loop, not just the in-flight attempt. Only a real
# interactive shell reproduces the job-control process groups this depends on,
# so type the command, wait until the first retry attempt starts, then send ^C
# and read the exit status. With the loop killed, attempts stay low; a surviving
# loop would drain the whole plan before reporting a different status.
cat >"$fake_dir/rcfile" <<EOF
PATH="$fake_dir:\$PATH"
source <(sed 's/< 30/< 2/' "$fns")
sleep() { :; }
PS1='$ '
EOF

plan="2 255"
for _ in {1..12}; do plan+=$'\n1 255'; done
printf '%s\n' "$plan" >"$fake_dir/plan"
rm -f "$fake_dir/count"
out_ctrlc=$({
  printf 'ssh host\n'
  for _ in {1..100}; do
    (( $(cat "$fake_dir/count" 2>/dev/null || echo 0) >= 2 )) && break
    command sleep 0.05
  done
  printf '\003'
  command sleep 0.3
  printf 'echo DONE rc=$?\n'
  command sleep 0.3
  printf 'exit\n'
} | script -qec "bash --rcfile '$fake_dir/rcfile' -i" /dev/null | tr -d '\r')

for pid in "${worker_pids[@]}"; do
  wait "$pid" || fail "parallel ssh-reconnect worker exited cleanly"
done
worker_pids=()

out=$(cat "$fake_dir/c1/out")
[[ $out == *"$disarm"* ]] || fail "stray terminal modes are reset after ssh exits" "$out"
pass "stray terminal modes are reset after ssh exits"

[[ $out == *"rc=255"* ]] && (( $(cat "$fake_dir/c1/count") == 1 )) ||
  fail "fast connection failure does not reconnect" "$out"
pass "fast connection failure does not reconnect"

out=$(cat "$fake_dir/c2/out")
[[ $out == *"Connection lost"* ]] && [[ $out == *"rc=0"* ]] && (( $(cat "$fake_dir/c2/count") == 2 )) ||
  fail "dropped session reconnects" "$out"
pass "dropped session reconnects"

out=$(cat "$fake_dir/c3/out")
[[ $out == *"rc=0"* ]] && (( $(cat "$fake_dir/c3/count") == 3 )) ||
  fail "reconnecting keeps retrying while the server is still down" "$out"
pass "reconnecting keeps retrying while the server is still down"

out=$(cat "$fake_dir/c4/out")
[[ $out == *"rc=255"* ]] && (( $(cat "$fake_dir/c4/count") == 1 )) ||
  fail "remote command exiting 255 is not replayed" "$out"
pass "remote command exiting 255 is not replayed"

out=$(cat "$fake_dir/c5/out")
[[ $out == *"rc=255"* ]] && (( $(cat "$fake_dir/c5/count") == 1 )) ||
  fail "redirected stdin does not reconnect" "$out"
pass "redirected stdin does not reconnect"

[[ $out_ctrlc == *"Connection lost"* ]] && [[ $out_ctrlc == *"DONE rc=130"* ]] && (( $(cat "$fake_dir/count") < 10 )) ||
  fail "Ctrl-C during a retry attempt stops the reconnect loop" "$out_ctrlc"
pass "Ctrl-C during a retry attempt stops the reconnect loop"
