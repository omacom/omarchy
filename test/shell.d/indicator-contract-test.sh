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

require_compositor "QML contract test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping QML contract test"
  exit 0
fi

require_command jq
require_command node

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/indicator-contract"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/indicator-contract/shell.qml" "$config_dir/shell.qml"
# Exercise the production lookup inside the QML binding engine, not a mock
# that bypasses clone resolution. Only service instances are test doubles.
node - "$ROOT" "$config_dir/shell.qml" <<'JS'
const fs = require('fs')
const path = require('path')
const [root, target] = process.argv.slice(2)
function method(file, name) {
  const source = fs.readFileSync(path.join(root, file), 'utf8')
  const match = source.match(new RegExp(`^  function ${name}\\([^]*?^  }`, 'm'))
  if (!match) throw new Error(`Missing ${name} in ${file}`)
  return match[0]
}
let fixture = fs.readFileSync(target, 'utf8')
fixture = fixture.replace('// SERVICE_LOOKUP_METHODS',
  ['serviceFor', 'firstPartyServiceFor'].map(name => method('shell/shell.qml', name)).join('\n'))
fixture = fixture.replace('// RESOLVE_ENABLED_ID_METHOD', method('shell/services/PluginRegistry.qml', 'resolveEnabledId'))
fs.writeFileSync(target, fixture)
JS
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

for _ in {1..50}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,160p' "$log" >&2
    fail "QML contract quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,160p' "$log" >&2
  fail "QML contract test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'QML contract result:\n' >&2
  jq . "$result" >&2
  printf 'QML contract log:\n' >&2
  sed -n '1,160p' "$log" >&2
  fail "QML indicator contract checks pass"
fi

if rg -q 'Indicators.qml.*Binding loop detected for property "implicitWidth"' "$log"; then
  sed -n '1,200p' "$log" >&2
  fail "indicator tray avoids implicit-width binding loops"
fi

pass "QML indicator contract checks pass"
