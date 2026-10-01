#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TEST_TMP_DIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TEST_TMP_DIR && -d $TEST_TMP_DIR ]]; then
    rm -rf "$TEST_TMP_DIR"
  fi
}
trap cleanup EXIT

require_compositor "lock mascot test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping lock mascot test"
  exit 0
fi

require_command jq

TEST_TMP_DIR=$(mktemp -d)
result="$TEST_TMP_DIR/result.json"
log="$TEST_TMP_DIR/quickshell.log"
config_dir="$TEST_TMP_DIR/lock-mascot"
mkdir -p "$config_dir" "$TEST_TMP_DIR/home"
cp "$SHELL_TEST_DIR/fixtures/lock-mascot/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TEST_TMP_DIR/home" \
XDG_CONFIG_HOME="$TEST_TMP_DIR/home/.config" \
XDG_CACHE_HOME="$TEST_TMP_DIR/home/.cache" \
XDG_STATE_HOME="$TEST_TMP_DIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "lock mascot quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "lock mascot test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Lock mascot result:\n' >&2
  jq . "$result" >&2
  printf 'Lock mascot log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "lock mascot follows presentation state"
fi

pass "lock mascot follows presentation state"
