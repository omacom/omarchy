#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /property bool sessionLocked: false/.test(serviceQml),
  'the lock service defines a sessionLocked property on root with change notifications'
)

assert(
  /readonly property bool locked: lockRequested \|\| sessionLocked \|\| sessionLock\.secure/.test(serviceQml),
  'the composite locked property binds to sessionLocked instead of WlSessionLock.locked'
)

assert(
  /function requestSessionLock\(\) \{[\s\S]*sessionLocked = true\s*\n\s*sessionLock\.locked = true/.test(serviceQml),
  'requesting the session lock marks sessionLocked true'
)

assert(
  /function finishUnlock\(\) \{[\s\S]*sessionLocked = false\s*[\s\S]*sessionLock\.locked = false/.test(serviceQml),
  'finishing unlock clears sessionLocked before or alongside sessionLock.locked'
)

assert(
  /onLockStateChanged: \{[\s\S]*root\.sessionLocked = locked/.test(serviceQml),
  'lock state changes synchronize root.sessionLocked'
)

assert(
  /status\(\): string \{[\s\S]*sessionLocked: root\.sessionLocked/.test(serviceQml),
  'status IPC reports root.sessionLocked so components and composite stay consistent'
)
JS

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "lock service unlock state test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping live lock unlock state test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/lock-unlock-state"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/lock-unlock-state/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "lock service quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "lock service unlock test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Lock service unlock result:\n' >&2
  jq . "$result" >&2
  printf 'Lock service log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "lock service unlock updates locked state across lock/unlock cycles"
fi

pass "lock service unlock updates locked state across lock/unlock cycles"
