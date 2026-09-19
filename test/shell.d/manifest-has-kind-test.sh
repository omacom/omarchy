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

run_node_test <<'JS'
const fs = require('fs')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

const fn = /function manifestHasKind\(manifest, kind\) \{[\s\S]*?\n  \}/.exec(shellQml)
assert(!!fn, 'manifestHasKind is defined in shell.qml')

assert(
  !/Array\.isArray\(manifest\.kinds\)/.test(fn[0]),
  'manifestHasKind does not gate on Array.isArray(manifest.kinds)',
  'A manifest read through an Instantiator model (panelEntries) has its ' +
  'kinds converted to a list-like value that Array.isArray() rejects even ' +
  'though indexing and .length still work, so gating on it makes ' +
  'manifestHasKind() answer differently for the same plugin depending on ' +
  'the caller — see the panel-loader vs. bar-widget paths in ' +
  'createScopedPluginShell().'
)
assert(
  /typeof manifest\.kinds\.length !== "number"/.test(fn[0]),
  'manifestHasKind duck-types on kinds.length instead'
)
JS

require_compositor "manifestHasKind Instantiator-model runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping manifestHasKind Instantiator-model runtime test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/manifest-has-kind"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/manifest-has-kind/"*.qml "$config_dir/"

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
    sed -n '1,220p' "$log" >&2
    fail "manifestHasKind fixture exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "manifestHasKind Instantiator-model runtime test timed out"
}

if ! jq -e '.viaModelKindsIsArray == false' "$result" >/dev/null; then
  jq . "$result" >&2
  fail "fixture no longer reproduces the Instantiator-model Array.isArray quirk it exists to guard against"
fi

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,220p' "$log" >&2
  fail "manifestHasKind gives the same answer for a direct manifest and one read through an Instantiator model"
fi

pass "manifestHasKind gives the same answer for a direct manifest and one read through an Instantiator model"
