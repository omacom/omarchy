#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command socat

test_tmp=$(mktemp -d)
server_pid=""
cleanup() {
  [[ -n $server_pid ]] && kill "$server_pid" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

root_dir="$test_tmp/root"
run_dir="$test_tmp/run"
stub_bin="$test_tmp/bin"
mkdir -p "$root_dir/shell" "$run_dir" "$stub_bin"
touch "$root_dir/shell/shell.qml"
# The shell names its socket after its config and display, as omarchy-shell
# derives it.
display="test-display"
socket_id=$(printf '%s\n%s' "$root_dir/shell" "$display" | md5sum)
socket="$run_dir/omarchy-shell-${socket_id:0:16}.sock"

# qs is the fallback: it records that it ran and answers.
cat >"$stub_bin/qs" <<'SH'
#!/bin/bash
printf 'qs\n' >>"$QS_CALLS"
printf 'from-qs\n'
SH
chmod +x "$stub_bin/qs"

# The fake shell replies as the mode file says, and logs each request with
# its separators made visible.
cat >"$test_tmp/responder" <<'SH'
#!/bin/bash
IFS= read -r -d $'\x1e' request
printf '%s\n' "${request//$'\x1f'/|}" >>"$REQUESTS"
case $(<"$MODE") in
  ok) printf 'OK\x1f%s\x1e' "answer to ${request//$'\x1f'/ }" ;;
  newlines) printf 'OK\x1fline\n\n\x1e' ;;
  skip) printf 'SKIP\x1e' ;;
  hang) sleep 2 ;;
  close) ;;
  partial) printf 'OK\x1fpartial answer' ;;
esac
SH
chmod +x "$test_tmp/responder"

mode="$test_tmp/mode"
calls="$test_tmp/qs-calls"
requests="$test_tmp/requests"
MODE="$mode" REQUESTS="$requests" socat UNIX-LISTEN:"$socket",fork SYSTEM:"$test_tmp/responder" 2>/dev/null &
server_pid=$!
for _ in $(seq 50); do [[ -S $socket ]] && break; sleep 0.05; done

shell_call() {
  : >"$calls"
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$root_dir" XDG_RUNTIME_DIR="$run_dir" WAYLAND_DISPLAY="$display" QS_CALLS="$calls" \
    OMARCHY_SHELL_IPC_TIMEOUT="${IPC_TIMEOUT:-2s}" "$ROOT/bin/omarchy-shell" "$@"
}

printf 'ok' >"$mode"
output=$(shell_call media next extra-arg)
[[ $output == "answer to media next extra-arg" ]] || fail "the shell answers over its socket" "got: $output"
[[ ! -s $calls ]] || fail "an answered call never starts qs ipc"
[[ $(tail -n1 "$requests") == "media|next|extra-arg" ]] || fail "arguments travel as separate fields" "got: $(tail -n1 "$requests")"
pass "the shell answers over its socket without starting qs ipc"

output=$(shell_call -q media next)
[[ -z $output ]] || fail "quiet calls print nothing" "got: $output"
pass "quiet calls over the socket print nothing"

printf 'newlines' >"$mode"
output=$(shell_call shell ping)
[[ $output == "line" ]] || fail "socket output drops trailing newlines as qs ipc's does" "got: $(printf '%q' "$output")"
pass "socket output drops trailing newlines as the qs ipc path does"

printf 'skip' >"$mode"
output=$(shell_call nosuch ping)
[[ $output == "from-qs" && -s $calls ]] || fail "a call the shell did not run goes to qs ipc" "got: $output"
pass "a call the shell did not run goes to qs ipc for its exact answer"

printf 'ok' >"$mode"
: >"$requests"
output=$(shell_call shell summon "$(printf 'a\x1fb')")
[[ $output == "from-qs" && ! -s $requests ]] || fail "an argument holding a separator goes straight to qs ipc" "got: $output"
pass "an argument holding a separator goes straight to qs ipc"

printf 'hang' >"$mode"
output=$(IPC_TIMEOUT=0.5s shell_call shell ping 2>&1) && fail "a shell that never replies fails the call"
[[ $output == "omarchy-shell is not responding" && ! -s $calls ]] ||
  fail "a call that may have run is reported, not retried through qs ipc" "got: $output"
pass "a call that may have run is reported as unresponsive, not retried"

printf 'close' >"$mode"
output=$(shell_call shell ping 2>&1) && fail "a shell that closes without answering fails the call"
[[ $output == "omarchy-shell is not responding" && ! -s $calls ]] ||
  fail "a connection closed without an answer is reported, not retried" "got: $output"
pass "a connection closed without an answer is reported, not retried"

printf 'partial' >"$mode"
output=$(shell_call shell listPlugins 2>&1) && fail "a reply cut off before its end fails the call"
[[ $output == "omarchy-shell is not responding" && ! -s $calls ]] ||
  fail "a reply cut off before its end is reported, not taken or retried" "got: $output"
pass "a reply cut off before its end is reported, not taken or retried"

# SIGKILL leaves the socket file behind with nothing listening, as a crashed
# shell does; socat then never connects, so qs ipc may safely answer.
kill -9 "$server_pid"
wait "$server_pid" 2>/dev/null || true
server_pid=""
[[ -S $socket ]] || fail "a killed listener leaves its socket file behind"
output=$(shell_call shell ping)
[[ $output == "from-qs" ]] || fail "a stale socket with nothing listening falls back to qs ipc" "got: $output"
pass "a stale socket with nothing listening falls back to qs ipc"

rm -f "$socket"
output=$(shell_call shell ping)
[[ $output == "from-qs" ]] || fail "without the socket calls go through qs ipc" "got: $output"
pass "without the socket calls go through qs ipc"

# A call for a different display never reaches this shell's socket.
printf 'ok' >"$mode"
MODE="$mode" REQUESTS="$requests" socat UNIX-LISTEN:"$socket",fork SYSTEM:"$test_tmp/responder" 2>/dev/null &
server_pid=$!
for _ in $(seq 50); do [[ -S $socket ]] && break; sleep 0.05; done
output=$(display="other-display" shell_call shell ping)
[[ $output == "from-qs" ]] || fail "a call for another display does not reach this shell's socket" "got: $output"
pass "a call for another display does not reach this shell's socket"

run_node_test <<'JS'
const fs = require('fs')
const { execSync } = require('child_process')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const registry = fs.readFileSync(path.join(root, 'shell/Commons/IpcRegistry.qml'), 'utf8')

// Only handlers that register can answer over the socket, so every
// first-party one does; the registry's own bare handler is the reference for
// the functions a handler never exposes.
const bare = execSync(`grep -rln 'IpcHandler {' ${path.join(root, 'shell')} --include=*.qml || true`).toString().trim().split('\n').filter(Boolean)
assertDeepEqual(bare.map((f) => path.relative(root, f)).sort(), ['shell/Commons/IpcRegistry.qml', 'shell/Commons/ShellIpc.qml'], 'first-party IPC handlers register through ShellIpc')

// Declared functions are allowed by name: destroy() and other QObject
// methods are callable yet not enumerable, so subtracting builtins from what a
// call can reach would let them through.
assert(
  registry.includes('readonly property var builtins: functionNames(bareHandler)') &&
    /return builtins\.indexOf\(name\) === -1 && !\/Changed\$\/\.test\(name\)/.test(registry) &&
    registry.includes('if (declaredFunctions(handler).indexOf(method) === -1) return { ran: false }') &&
    registry.includes('handler[method].length !== args.length'),
  'the socket answers only declared functions with their exact argument count'
)
assert(
  shellQml.includes('+ Qt.md5(shell.omarchyPath + "/shell\\n" + Quickshell.env("WAYLAND_DISPLAY")).slice(0, 16) + ".sock"'),
  'the shell names its socket after its config and display, as omarchy-shell does'
)
JS
