#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

const match = shellQml.match(/function manifestHasKind\(manifest, kind\) \{([\s\S]*?)\n  \}/)
assert(match, 'shell.qml defines manifestHasKind')

const manifestHasKind = new Function('manifest', 'kind', match[1])

// Standard JS Array checks
assert(manifestHasKind({ kinds: ['menu'] }, 'menu') === true, 'manifestHasKind matches kind in JS array')
assert(manifestHasKind({ kinds: ['menu', 'bar-widget'] }, 'bar-widget') === true, 'manifestHasKind matches second kind in JS array')
assert(manifestHasKind({ kinds: ['menu'] }, 'bar') === false, 'manifestHasKind rejects missing kind in JS array')

// Sequence-like objects (e.g. QML V4Sequence wrapping QVariantList from modelData / property var)
class MockV4Sequence {
  constructor(items) {
    this._items = items
  }
  indexOf(kind) {
    return this._items.indexOf(kind)
  }
}

const sequence = new MockV4Sequence(['menu', 'bar-widget'])
assert(!Array.isArray(sequence), 'MockV4Sequence is not a native JS Array')
assert(typeof sequence === 'object', 'MockV4Sequence is an object')
assert(manifestHasKind({ kinds: sequence }, 'menu') === true, 'manifestHasKind matches kind in sequence object')
assert(manifestHasKind({ kinds: sequence }, 'bar-widget') === true, 'manifestHasKind matches second kind in sequence object')
assert(manifestHasKind({ kinds: sequence }, 'panel') === false, 'manifestHasKind rejects missing kind in sequence object')

// Non-object and invalid inputs
assert(manifestHasKind(null, 'menu') === false, 'manifestHasKind rejects null manifest')
assert(manifestHasKind(undefined, 'menu') === false, 'manifestHasKind rejects undefined manifest')
assert(manifestHasKind({}, 'menu') === false, 'manifestHasKind rejects manifest without kinds')
assert(manifestHasKind({ kinds: null }, 'menu') === false, 'manifestHasKind rejects null kinds')
assert(manifestHasKind({ kinds: 'menu' }, 'menu') === false, 'manifestHasKind rejects string kinds')
assert(manifestHasKind({ kinds: 'menu-app' }, 'menu') === false, 'manifestHasKind rejects substring match on string kinds')
assert(manifestHasKind({ kinds: 123 }, 'menu') === false, 'manifestHasKind rejects numeric kinds')
assert(manifestHasKind({ kinds: {} }, 'menu') === false, 'manifestHasKind rejects plain object without indexOf')

// Scoped shell wiring checks
assert(
  shellQml.includes('appLibrary: shell.manifestHasKind(manifest, "menu")'),
  'scoped plugin shell gates appLibrary on manifestHasKind'
)
assert(
  shellQml.includes('shell.manifestHasKind(manifest, "menu") ? "menu" : "no-menu"'),
  'plugin shell capability profile queries manifestHasKind for menu kind'
)
assert(
  shellQml.includes('return shell.manifestHasKind(manifest, "bar")'),
  'isBarOptionManifest delegates to shell.manifestHasKind'
)
JS

# QML runtime test with Instantiator
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

require_compositor "cloned menu appLibrary QML test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping cloned menu appLibrary QML runtime test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/cloned-menu-app-library"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/cloned-menu-app-library/shell.qml" "$config_dir/shell.qml"

OMARCHY_PATH="$ROOT" \
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
    fail "cloned menu appLibrary fixture exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "cloned menu appLibrary QML test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  fail "cloned menu did not receive appLibrary through Instantiator sequence"
fi

pass "cloned menu receives appLibrary when manifest kinds pass through Instantiator"
