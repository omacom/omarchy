#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
slow_pid_file="$test_tmp/slow-launch-pid"
clients_file="$test_tmp/clients.json"
# The slow launcher fixture detaches through setsid into its own session, so
# cleanup stops its whole process group; the fixture is that group's leader.
trap '[[ -f $slow_pid_file ]] && kill -- "-$(<"$slow_pid_file")" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_INSTALLED:-false} == "true" ]]
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  cat "$OMARCHY_TEST_CLIENTS_FILE"
  exit 0
fi
printf 'dispatch:%s\n' "${*:2}" >>"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
# Bitwarden counts as running while its alive marker exists; the pkill mock
# removes the marker, standing in for the process dying.
[[ -f $OMARCHY_TEST_BITWARDEN_ALIVE ]]
SH

cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
printf 'pkill:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
rm -f "$OMARCHY_TEST_BITWARDEN_ALIVE"
SH

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
# A handoff that works shows the hidden window again.
if [[ ${OMARCHY_TEST_HANDOFF_SHOWS_WINDOW:-0} == "1" ]]; then
  printf '[{"class":"bitwarden","address":"0xhandoff0001"}]' >"$OMARCHY_TEST_CLIENTS_FILE"
fi
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf 'install:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

# The app launch is detached, so the log lands a moment after the script exits.
wait_for_log() {
  for _ in $(seq 100); do
    [[ -s $1 ]] && return 0
    sleep 0.05
  done
  return 1
}

run_launcher() {
  local log=$1
  shift
  env PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_FILE="$clients_file" OMARCHY_TEST_LOG="$log" "$@" \
    bash "$ROOT/bin/omarchy-launch-bitwarden"
}

launch_log="$test_tmp/launch-log"
printf '[]' >"$clients_file"
run_launcher "$launch_log" OMARCHY_TEST_INSTALLED=true
wait_for_log "$launch_log" ||
  fail "Bitwarden launcher starts the installed app at a fixed scale factor"
grep -Fxq 'launch:-- bitwarden-desktop --force-device-scale-factor=1' "$launch_log" ||
  fail "Bitwarden launcher starts the installed app at a fixed scale factor"
pass "Bitwarden launcher starts the installed app at a fixed scale factor"

run_launcher "$launch_log" OMARCHY_TEST_INSTALLED=false
grep -Fxq 'install:omarchy-install-service-bitwarden' "$launch_log" ||
  fail "Bitwarden launcher starts the installer when missing"
pass "Bitwarden launcher starts the installer when missing"

# A window that still exists is focused, not relaunched.
focus_log="$test_tmp/focus-log"
printf '[{"class":"bitwarden","address":"0x56780001"}]' >"$clients_file"
run_launcher "$focus_log" OMARCHY_TEST_INSTALLED=true
grep -Fxq 'dispatch:hl.dsp.focus({ window = "address:0x56780001" })' "$focus_log" ||
  fail "Bitwarden launcher focuses an existing window instead of relaunching"
if grep -Fq 'launch:' "$focus_log"; then
  fail "Bitwarden launcher does not relaunch beside an existing window"
fi
pass "Bitwarden launcher focuses an existing window instead of relaunching"

# A hidden window behind a running process is brought back by the
# single-instance handoff, which keeps the process and its unlocked vault.
handoff_log="$test_tmp/handoff-log"
alive_marker="$test_tmp/bitwarden-alive"
printf '[]' >"$clients_file"
touch "$alive_marker"
run_launcher "$handoff_log" OMARCHY_TEST_INSTALLED=true \
  OMARCHY_TEST_BITWARDEN_ALIVE="$alive_marker" OMARCHY_TEST_HANDOFF_SHOWS_WINDOW=1
if grep -Fq 'pkill:' "$handoff_log"; then
  fail "Bitwarden launcher does not restart a process the handoff recovers"
fi
[[ $(grep -Fc 'launch:' "$handoff_log") == 1 ]] ||
  fail "Bitwarden launcher brings a hidden window back with one handoff launch"
pass "Bitwarden launcher brings a hidden window back through the handoff"

# When the handoff brings nothing back — the re-show fails to remap, or the
# window is really gone — the background instance is restarted, and only
# after it has stopped, so the new instance can take the lock.
restart_log="$test_tmp/restart-log"
printf '[]' >"$clients_file"
touch "$alive_marker"
run_launcher "$restart_log" OMARCHY_TEST_INSTALLED=true \
  OMARCHY_TEST_BITWARDEN_ALIVE="$alive_marker"
grep -Fxq 'pkill:-x bitwarden-app' "$restart_log" ||
  fail "Bitwarden launcher restarts a process the handoff cannot recover"
# The restart launches detached, so its log line lands a moment after the
# launcher returns; wait for it rather than racing the count.
relaunches=0
for _ in $(seq 100); do
  relaunches=$(grep -Fc 'launch:' "$restart_log" || true)
  if (( relaunches >= 2 )); then
    break
  fi
  sleep 0.05
done
((relaunches == 2)) ||
  fail "Bitwarden launcher starts exactly one new instance after the failed handoff" "launches: $relaunches"
pass "Bitwarden launcher restarts a process the handoff cannot recover"

# Script callers must not sit in the app's foreground: setsid only forks for
# process-group leaders, so an exec'd launcher blocks until the app quits and
# the default password manager setup would save its choice only then. Real
# setsid and a slow app; the launcher has to hand the prompt back immediately.
slow_bin="$test_tmp/slow-bin"
mkdir -p "$slow_bin"

cat >"$slow_bin/uwsm-app" <<'SH'
#!/bin/bash
# The PID lands before the launch line so the exit trap can always stop the
# fixture once the log it waits for has appeared.
printf '%s\n' $$ >"$OMARCHY_TEST_SLOW_PID"
printf 'launch:%s\n' "$*" >"$OMARCHY_TEST_LOG"
sleep 10
SH

chmod +x "$slow_bin"/*

launch_log="$test_tmp/slow-launch-log"
printf '[]' >"$clients_file"
rc=0
timeout 2 env PATH="$slow_bin:$mock_bin:$PATH" OMARCHY_TEST_INSTALLED=true \
  OMARCHY_TEST_LOG="$launch_log" OMARCHY_TEST_CLIENTS_FILE="$clients_file" \
  OMARCHY_TEST_SLOW_PID="$slow_pid_file" bash "$ROOT/bin/omarchy-launch-bitwarden" || rc=$?
((rc == 0)) ||
  fail "Bitwarden launcher returns to a script caller while the app is running" "exit: $rc"
wait_for_log "$launch_log" ||
  fail "Bitwarden launcher returns to a script caller while the app is running" "log: $(cat "$launch_log" 2>/dev/null)"
grep -Fxq 'launch:-- bitwarden-desktop --force-device-scale-factor=1' "$launch_log" ||
  fail "Bitwarden launcher still passes the scale factor when detaching"
pass "Bitwarden launcher returns to a script caller while the app is running"
