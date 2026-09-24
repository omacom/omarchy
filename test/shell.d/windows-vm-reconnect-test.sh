#!/bin/bash
# The launcher must tell a closed window apart from Windows restarting or
# shutting down: only the first should tear the VM down.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null 2>&1

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# --- rdp_state against real sockets on 127.0.0.1:3389 ------------------------

if ! command -v python3 >/dev/null; then
  skip "python3 unavailable; skipping RDP probe socket checks"
elif (exec 3<>/dev/tcp/127.0.0.1/3389) 2>/dev/null; then
  skip "127.0.0.1:3389 already in use; skipping RDP probe socket checks"
else
  # mode "rdp" answers like Windows; "close" accepts then hangs up like
  # docker-proxy does while the guest is down.
  fake_server() {
    python3 - "$1" <<'EOF' &
import socket, sys
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 3389))
s.listen(1)
c, _ = s.accept()
c.recv(64)
if sys.argv[1] == "rdp":
    c.sendall(bytes.fromhex("0300001302f0d0000000000200080001000000"))
c.close()
EOF
    FAKE_PID=$!
    for _ in {1..50}; do
      ss -ltn 'sport = :3389' | grep -q LISTEN && return
      sleep 0.1
    done
  }

  [[ $(rdp_state) == "stopped" ]] || fail "RDP probe reports stopped when nothing listens"
  pass "RDP probe reports stopped when nothing listens"

  fake_server rdp
  [[ $(rdp_state) == "up" ]] || fail "RDP probe reports up when Windows answers"
  wait "$FAKE_PID" || true
  pass "RDP probe reports up when Windows answers"

  fake_server close
  [[ $(rdp_state) == "booting" ]] || fail "RDP probe reports booting when only the port forward answers"
  wait "$FAKE_PID" || true
  pass "RDP probe reports booting when only the port forward answers"
fi

# --- launch loop decisions, with FreeRDP and the probe scripted ---------------

# Each scenario scripts the xfreerdp3 exit codes and the rdp_state answers in
# order, then records which privileged actions ran and how often FreeRDP ran.
# The helper is not written for nounset, so drive it the way it runs.
set +u
migrate_legacy_compose() { return 0; }
read_credential() { echo "test"; }
gum() { :; }
hyprctl() { echo '[{"focused":true,"scale":1}]'; }
omarchy-notification-send() { :; }
sleep() { :; }
priv() { echo "$1" >>"$test_tmp/priv"; }

xfreerdp3() {
  cat >/dev/null
  local n
  n=$(($(cat "$test_tmp/rdp_n") + 1))
  echo "$n" >"$test_tmp/rdp_n"
  return "${RDP_CODES[n - 1]:-0}"
}

rdp_state() {
  local n
  n=$(($(cat "$test_tmp/state_n") + 1))
  echo "$n" >"$test_tmp/state_n"
  echo "${STATES[n - 1]:-up}"
}

run_launch() {
  : >"$test_tmp/priv"
  echo 0 >"$test_tmp/rdp_n"
  echo 0 >"$test_tmp/state_n"
  (launch_windows "$@") >/dev/null 2>&1 || true
  PRIV=$(tr '\n' ' ' <"$test_tmp/priv")
  RDP_RUNS=$(cat "$test_tmp/rdp_n")
}

RDP_CODES=(0) STATES=(up)
run_launch
[[ $PRIV == "up_wait down " && $RDP_RUNS == 1 ]] ||
  fail "closing the window stops the VM" "priv: $PRIV runs: $RDP_RUNS"
pass "closing the window stops the VM"

RDP_CODES=(0) STATES=(up)
run_launch --keep-alive
[[ $PRIV == "up_wait " && $RDP_RUNS == 1 ]] ||
  fail "closing the window keeps the VM with --keep-alive" "priv: $PRIV runs: $RDP_RUNS"
pass "closing the window keeps the VM with --keep-alive"

# Restart: RDP still answers right after the disconnect, then goes away, then
# comes back; the second session is closed by the user.
RDP_CODES=(1 0) STATES=(up up booting booting up up)
run_launch
[[ $PRIV == "up_wait down " && $RDP_RUNS == 2 ]] ||
  fail "Windows restart reconnects instead of stopping the VM" "priv: $PRIV runs: $RDP_RUNS"
pass "Windows restart reconnects instead of stopping the VM"

# Shutdown: the container exits by itself, so there is nothing to tear down.
RDP_CODES=(1) STATES=(up booting stopped)
run_launch
[[ $PRIV == "up_wait " && $RDP_RUNS == 1 ]] ||
  fail "Windows shutdown exits without another stop" "priv: $PRIV runs: $RDP_RUNS"
pass "Windows shutdown exits without another stop"

# First connect before the guest listens (#5202): wait instead of tearing down.
RDP_CODES=(131 0) STATES=(booting booting up up)
run_launch
[[ $PRIV == "up_wait down " && $RDP_RUNS == 2 ]] ||
  fail "connecting before Windows is ready waits and retries" "priv: $PRIV runs: $RDP_RUNS"
pass "connecting before Windows is ready waits and retries"

# A connection that keeps failing while Windows is up must not spin forever.
RDP_CODES=(132 132 132 132 132) STATES=()
run_launch
[[ $PRIV == "up_wait down " && $RDP_RUNS == 3 ]] ||
  fail "repeated immediate failures give up after three tries" "priv: $PRIV runs: $RDP_RUNS"
pass "repeated immediate failures give up after three tries"
