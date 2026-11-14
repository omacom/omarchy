#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command flock

test_tmp=$(mktemp -d)
holder_pid=""

cleanup() {
  [[ -n $holder_pid ]] && kill "$holder_pid" 2>/dev/null || true
  [[ -n $holder_pid ]] && wait "$holder_pid" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

session_root="$test_tmp/session"
runtime_dir="$test_tmp/runtime"
mock_bin="$test_tmp/bin"
marker="$test_tmp/restart-progressed"
ready="$test_tmp/lock-ready"
mkdir -p "$session_root/shell" "$runtime_dir" "$mock_bin"
touch "$session_root/shell/shell.qml"

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == "--user" && ${2:-} == "show-environment" ]]; then
  printf 'OMARCHY_PATH=%s\n' "$OMARCHY_TEST_SESSION_PATH"
else
  exit 1
fi
SH

for command in omarchy-hyprland-session-locked omarchy-shell quickshell hyprctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
touch "$OMARCHY_TEST_MARKER"
exit 99
SH
  chmod +x "$mock_bin/$command"
done
chmod +x "$mock_bin/systemctl"

(
  exec 9>"$runtime_dir/omarchy-restart-shell.lock"
  flock 9
  touch "$ready"
  sleep 30
) &
holder_pid=$!

for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -f $ready ]] && break
  sleep 0.01
done
[[ -f $ready ]] || fail "test acquired the shell restart lock"

PATH="$mock_bin:$PATH" \
OMARCHY_PATH="$session_root" \
XDG_RUNTIME_DIR="$runtime_dir" \
HYPRLAND_INSTANCE_SIGNATURE=test \
OMARCHY_TEST_SESSION_PATH="$session_root" \
OMARCHY_TEST_MARKER="$marker" \
  timeout 1 "$ROOT/bin/omarchy-restart-shell" ||
  fail "overlapping shell restart is coalesced successfully"

[[ ! -e $marker ]] || fail "overlapping shell restart does not enter the restart sequence"
pass "overlapping shell restart is coalesced before it can kill the replacement shell"
