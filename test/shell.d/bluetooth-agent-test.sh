#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
supervisor_pid=

cleanup() {
  if [[ $supervisor_pid =~ ^[0-9]+$ ]]; then
    kill "$supervisor_pid" 2>/dev/null || true
    wait "$supervisor_pid" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}

trap cleanup EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash

count=0
[[ ! -f $BUSCTL_COUNT_FILE ]] || read -r count <"$BUSCTL_COUNT_FILE"
count=$((count + 1))
printf '%s\n' "$count" >"$BUSCTL_COUNT_FILE"

case $BUSCTL_SEQUENCE in
  replaced)
    if (( count <= 2 )); then
      printf 'org.bluez 101 bluetoothd root system.slice 1 bluetooth.service - -\n'
    else
      printf 'org.bluez 202 bluetoothd root system.slice 1 bluetooth.service - -\n'
    fi
    ;;
  absent-then-stable)
    if (( count >= 3 )); then
      printf 'org.bluez 303 bluetoothd root system.slice 1 bluetooth.service - -\n'
    fi
    ;;
esac
SH

cat >"$mock_bin/bt-agent" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$AGENT_LOG"
printf '%s\n' "$$" >"$AGENT_PID_FILE"
while :; do sleep 1; done
SH

chmod +x "$mock_bin/busctl" "$mock_bin/bt-agent"

supervisor="$ROOT/bin/omarchy-bluetooth-agent-supervisor"

replacement_dir="$test_tmp/replacement"
mkdir -p "$replacement_dir"

set +e
PATH="$mock_bin:$PATH" \
  BUSCTL_SEQUENCE=replaced \
  BUSCTL_COUNT_FILE="$replacement_dir/busctl-count" \
  AGENT_LOG="$replacement_dir/agent-log" \
  AGENT_PID_FILE="$replacement_dir/agent-pid" \
  OMARCHY_BLUETOOTH_AGENT_POLL_INTERVAL=0.02 \
  timeout 5 "$supervisor"
replacement_status=$?
set -e

(( replacement_status == 1 )) ||
  fail "Bluetooth agent supervisor did not exit for replacement after BlueZ changed owner"
grep -Fx -- '-c NoInputNoOutput' "$replacement_dir/agent-log" >/dev/null
replacement_agent_pid=$(<"$replacement_dir/agent-pid")
kill -0 "$replacement_agent_pid" 2>/dev/null &&
  fail "Bluetooth agent supervisor left the stale agent running after BlueZ changed owner"
pass "Bluetooth agent supervisor replaces an agent registered to an old BlueZ owner"

startup_dir="$test_tmp/startup"
mkdir -p "$startup_dir"

PATH="$mock_bin:$PATH" \
  BUSCTL_SEQUENCE=absent-then-stable \
  BUSCTL_COUNT_FILE="$startup_dir/busctl-count" \
  AGENT_LOG="$startup_dir/agent-log" \
  AGENT_PID_FILE="$startup_dir/agent-pid" \
  OMARCHY_BLUETOOTH_AGENT_POLL_INTERVAL=0.02 \
  "$supervisor" &
supervisor_pid=$!

for _ in {1..100}; do
  [[ -s $startup_dir/agent-pid ]] && break
  sleep 0.02
done

[[ -s $startup_dir/agent-pid ]] ||
  fail "Bluetooth agent supervisor did not start the agent after BlueZ appeared"
startup_checks=$(<"$startup_dir/busctl-count")
(( startup_checks >= 3 )) ||
  fail "Bluetooth agent supervisor started the agent before BlueZ appeared"

startup_agent_pid=$(<"$startup_dir/agent-pid")
kill "$supervisor_pid"
wait "$supervisor_pid"
supervisor_pid=
kill -0 "$startup_agent_pid" 2>/dev/null &&
  fail "Bluetooth agent supervisor left the agent running when its service stopped"
pass "Bluetooth agent supervisor waits for BlueZ and cleans up with its service"
