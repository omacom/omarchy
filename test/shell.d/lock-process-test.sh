#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/root/shell" "$test_dir/run"
touch "$test_dir/root/shell/lock.qml"

cat >"$test_dir/bin/qs" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_IPC_LOG"
if [[ $* == *'/lock.qml '* ]]; then
  echo 'locker-reply'
else
  echo 'shell-reply'
  exit "${OMARCHY_TEST_SHELL_EXIT:-0}"
fi
SH
chmod +x "$test_dir/bin/qs"
export PATH="$test_dir/bin:$PATH" OMARCHY_PATH="$test_dir/root"
export XDG_RUNTIME_DIR="$test_dir/run" WAYLAND_DISPLAY=wayland-test
export OMARCHY_TEST_IPC_LOG="$test_dir/ipc.log"

# No main shell configuration even exists: lock IPC must not depend on it.
[[ $("$ROOT/bin/omarchy-shell" lock status) == locker-reply ]] || fail "lock IPC works without the main shell"
grep -Fx "ipc -n -p $OMARCHY_PATH/shell/lock.qml call -- lock status" "$OMARCHY_TEST_IPC_LOG" >/dev/null || fail "lock IPC selects only the locker configuration"
pass "lock IPC reaches the separate locker without the main shell"

touch "$OMARCHY_PATH/shell/shell.qml"
for method in direct transition; do
  : >"$OMARCHY_TEST_IPC_LOG"
  if [[ $method == direct ]]; then
    reply=$("$ROOT/bin/omarchy-shell" shell applyTheme Y29sb3Jz c2hlbGw=)
  else
    reply=$("$ROOT/bin/omarchy-shell" background themeTransition old new final Y29sb3Jz c2hlbGw=)
  fi
  [[ $reply == shell-reply ]] || fail "theme forwarding preserves the main reply"
  [[ $(wc -l <"$OMARCHY_TEST_IPC_LOG") == 2 ]] || fail "theme forwarding calls each process once"
  grep -Fx "ipc -n -p $OMARCHY_PATH/shell/lock.qml call -- lock applyTheme Y29sb3Jz c2hlbGw=" "$OMARCHY_TEST_IPC_LOG" >/dev/null || fail "theme forwarding preserves the locker payload"
done
pass "direct and background-transition themes reach both processes"

: >"$OMARCHY_TEST_IPC_LOG"
OMARCHY_TEST_SHELL_EXIT=1 "$ROOT/bin/omarchy-shell" -q shell applyTheme Y29sb3Jz c2hlbGw=
grep -F '/lock.qml call -- lock applyTheme' "$OMARCHY_TEST_IPC_LOG" >/dev/null || fail "locker receives themes while the main shell is down"
pass "theme forwarding still reaches the locker when the main shell fails"

run_node_test <<'JS'
const fs = require('fs')
const locker = fs.readFileSync(path.join(root, 'shell/lock.qml'), 'utf8')
assert(!fs.existsSync(path.join(root, 'shell/plugins/lock/manifest.json')), 'the plugin scanner cannot load the built-in locker into the main shell')
assert(/Service\s*\{/.test(locker) && !/PluginRegistry\s*\{/.test(locker), 'the independent root loads the locker without a plugin registry')
JS
