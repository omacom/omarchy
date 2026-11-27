#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_quickshell "deferred shell IPC response"
require_command socat

test_tmp=$(mktemp -d)
server_pid=""
socket=""
cleanup() {
  if [[ -n $server_pid ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  [[ -z $socket ]] || rm -f "$socket"
  rm -rf "$test_tmp"
}
trap cleanup EXIT
mkdir -p "$test_tmp/shell" "$test_tmp/home" "$test_tmp/bin"
cp "$SHELL_TEST_DIR/fixtures/shell-ipc-delayed/shell.qml" "$test_tmp/shell/"
socket=$(OMARCHY_PATH="$test_tmp" shell_ipc_socket "$test_tmp")
cat > "$test_tmp/bin/qs" <<SHIM
#!/bin/bash
echo fallback >> "$test_tmp/fallback"
exit 1
SHIM
chmod +x "$test_tmp/bin/qs"
HOME="$test_tmp/home" OMARCHY_TEST_SOCKET="$socket" quickshell -p "$test_tmp/shell" --no-color > "$test_tmp/server.log" 2>&1 &
server_pid=$!
for _ in {1..100}; do
  [[ ! -S $socket ]] || break
  kill -0 "$server_pid" 2>/dev/null || { cat "$test_tmp/server.log"; fail "deferred IPC server starts"; }
  sleep 0.02
done
[[ -S $socket ]] || fail "deferred IPC server creates its socket"
output=$(OMARCHY_PATH="$test_tmp" PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-shell" shell ping 2>&1) || {
  cat "$test_tmp/server.log"
  fail "IPC keeps the connection open until the framed response" "$output"
}
[[ $output == "deferred" ]] || fail "IPC receives the complete deferred response" "$output"
[[ ! -e $test_tmp/fallback ]] || fail "a deferred response never retries via qs"
[[ $(grep -c delayed-ipc-request "$test_tmp/server.log") == 1 ]] || fail "the deferred call runs exactly once"
pass "IPC waits for a framed Quickshell reply without closing its request stream or retrying"
