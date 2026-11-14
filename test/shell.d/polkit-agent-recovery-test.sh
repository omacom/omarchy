#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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

require_compositor "polkit agent recovery test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping polkit agent recovery test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/polkit-agent-recovery"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/polkit-agent-recovery/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

# With no system bus every registration fails, and Quickshell logs each attempt
# it actually makes; a replacement agent it never bound makes none.
DBUS_SYSTEM_BUS_ADDRESS="unix:path=$TMPDIR/no-system-bus" \
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
    fail "polkit agent recovery quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "polkit agent recovery test timed out"
}

if ! jq -e '.loaded == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,220p' "$log" >&2
  fail "polkit agent loads for the recovery test"
fi

attempts=$(grep -c 'failed to register listener on path' "$log" || true)
if (( attempts != 2 )); then
  sed -n '1,220p' "$log" >&2
  fail "recreating the polkit agent makes a fresh registration attempt (saw $attempts of 2)"
fi

pass "recreating the polkit agent makes a fresh registration attempt"
