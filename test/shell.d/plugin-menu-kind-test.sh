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

shell_qml="$ROOT/shell/shell.qml"

# A third-party menu plugin only receives its application-library facade when
# manifestHasKind(manifest, "menu") holds. Manifests read from a model
# delegate's modelData carry kinds as a QML sequence, not a JS Array; when the
# panel loader did that, the facade was built without appLibrary and then
# revoked as stale, leaving cloned menus with an empty application list.
if tr '\n\r\t' '   ' < "$shell_qml" | grep -Eq 'property var manifest: *modelData\.manifest'; then
  fail "panel entries read plugin manifests from modelData"
fi
pass "panel entries read plugin manifests from the registry"

require_compositor "plugin menu kind runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping plugin menu kind runtime test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/plugin-menu-kind"
mkdir -p "$config_dir" "$TMPDIR/home"

predicate=$(sed -n '/^  function manifestHasKind(/,/^  }/p' "$shell_qml")
[[ -n $predicate ]] || fail "manifestHasKind not found in shell.qml"

{
  sed -n '1,/^  \/\/ MANIFEST_HAS_KIND$/p' "$SHELL_TEST_DIR/fixtures/plugin-menu-kind/shell.qml"
  printf '%s\n' "$predicate"
  sed -n '/^  \/\/ MANIFEST_HAS_KIND$/,$p' "$SHELL_TEST_DIR/fixtures/plugin-menu-kind/shell.qml" | tail -n +2
} > "$config_dir/shell.qml"

OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,120p' "$log" >&2
    fail "plugin menu kind fixture exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,120p' "$log" >&2
  fail "plugin menu kind runtime test timed out"
}

# The predicate case only exists while modelData delivers kinds as a QML
# sequence. If a Qt release hands over a plain Array instead, say so rather
# than pass without exercising it.
if ! jq -e '.kindsIsSequence == true' "$result" >/dev/null; then
  skip "modelData no longer delivers kinds as a QML sequence; sequence case not exercised"
  exit 0
fi

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  fail "manifestHasKind recognizes kinds delivered as a QML sequence"
fi

pass "manifestHasKind recognizes kinds delivered as a QML sequence"
