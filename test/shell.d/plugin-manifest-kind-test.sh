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

require_compositor "plugin manifest kind test"

require_command jq

# Static guards: shell.qml delegates to the shared check, and the shared check
# duck-types the list, so a future inlining of Array.isArray reddens here even
# if the runtime fixture below were skipped.
qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

qml_matches "$ROOT/shell/shell.qml" 'function manifestHasKind\(manifest, kind\) \{ *return Util\.hasKind\(manifest, kind\) *\}' ||
  fail "shell.qml does not delegate manifestHasKind to Util.hasKind"
pass "shell.qml delegates manifest kind checks to the shared helper"

qml_matches "$ROOT/shell/Commons/Util.qml" 'typeof kinds\.indexOf === "function"' ||
  fail "Util.hasKind no longer duck-types the kind list"
pass "Util.hasKind duck-types the kind list"

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/manifest-model-roundtrip"
mkdir -p "$config_dir"
cp "$SHELL_TEST_DIR/fixtures/manifest-model-roundtrip/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "manifest model roundtrip quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "manifest model roundtrip test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Manifest kind check result:\n' >&2
  jq . "$result" >&2
  printf 'Manifest kind check log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "manifest kind checks pass through the model path"
fi

pass "manifest kind checks pass through the model path"
