#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
listener=
cleanup() {
  if [[ -n $listener ]]; then kill "$listener" 2>/dev/null || true; fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

# A scratch runtime directory, so status never reaches the live broker.
export HOME="$test_tmp/home"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
mkdir -p "$HOME" "$XDG_RUNTIME_DIR/omarchy/agent-seat"
export PATH="$ROOT/bin:$PATH"

control="$XDG_RUNTIME_DIR/omarchy/agent-seat/control"

# No broker at all: the seat is stopped.
output=$(timeout 10 omarchy-agent-seat-status) && fail "status fails when no broker is running"
[[ $output == "Agent seat: stopped" ]] || fail "status reports a seat with no broker as stopped" "$output"

# A broker that accepts the connection and never answers.
python3 -c '
import socket, sys
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.bind(sys.argv[1])
sock.listen()
conns = []
while True:
  conns.append(sock.accept()[0])
' "$control" &
listener=$!
for _ in {1..50}; do [[ -S $control ]] && break; sleep 0.1; done
[[ -S $control ]] || fail "the silent broker listens on the control socket"

start=$SECONDS
code=0
output=$(timeout 10 omarchy-agent-seat-status) || code=$?
((code != 124)) || fail "status gives up on a broker that never answers"
((code != 0)) || fail "status fails when the broker never answers"
[[ $output == "Agent seat: stopped" ]] || fail "status reports a silent broker as a stopped seat" "$output"
((SECONDS - start <= 4)) || fail "status gives up on a silent broker within a few seconds"

json=$(timeout 10 omarchy-agent-seat-status --json) && fail "status --json fails when the broker never answers"
[[ $(jq -r '.running' <<<"$json") == "false" ]] || fail "status --json reports a silent broker as not running" "$json"

pass "status treats a broker that never answers as a stopped seat"
