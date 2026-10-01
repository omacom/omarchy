#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
function method(name) {
  const start = source.indexOf('  function ' + name + '(')
  const end = source.indexOf('\n  }', start) + 4
  return source.slice(start, end)
}
const a = { pluginApiScope: '1', centerRevealState: { centerSectionRevealHeld: true } }
const b = { pluginApiScope: '2', centerRevealState: { centerSectionRevealHeld: false } }
const calls = []
const host = {
  pluginBarApis: {}, moduleSlots: [], shell: null,
  targetWindow: target => target.surface,
  syncPluginBarApiObjects: () => {},
  releasePluginObjects: id => calls.push(['release', id]),
  registerPluginClickTarget: (id, target) => calls.push(['register', id, target]),
}
const Qt = { binding: callback => callback }
const component = { createObject: (_, props) => ({ ...props, destroy() { this.destroyed = true } }) }
for (const name of ['bindPluginBarApi', 'pluginBarApiFor', 'pluginBarApiUsed', 'prunePluginBarApis']) {
  host[name] = new Function('root', 'Qt', 'pluginBarApiComponent', `with(root) { return (${method(name)}).apply(root, Array.prototype.slice.call(arguments, 3)) }`).bind(null, host, Qt, component)
}
const apiA = host.pluginBarApiFor('clone.indicators', 'omarchy.indicators', true, {surface: a})
const apiB = host.pluginBarApiFor('clone.indicators', 'omarchy.indicators', true, {surface: b})
assert(apiA !== apiB, 'the production factory gives a widget separate facades on separate surfaces')
assertEqual(apiA.centerSectionRevealHeld(), true, 'first facade binds its own reveal state')
assertEqual(apiB.centerSectionRevealHeld(), false, 'second facade stays collapsed')
assertEqual(host.pluginBarApiFor('clone.indicators', 'omarchy.indicators', true, {surface: a}), apiA, 'facade stays stable within its surface')
apiA._registerClickTarget('button')
assertDeepEqual(calls.pop(), ['register', 'clone.indicators', 'button'], 'scoping preserves original plugin ownership')
apiB._setCenterHoverRevealSuppressed(true)
assertEqual(host.centerHoverRevealSuppressed, true, 'scoped facade preserves shared suppression callback')
host.moduleSlots = [{pluginApiId: 'clone.indicators', pluginApiKey: 'clone.indicators@2'}]
host.prunePluginBarApis()
assert(apiA.destroyed && !apiB.destroyed, 'removing a surface destroys only its cached facade')
assertEqual(calls.length, 0, 'removing one surface keeps another surface plugin ownership')
const replacement = {pluginApiScope: '3', centerRevealState: {centerSectionRevealHeld: false}}
const apiReplacement = host.pluginBarApiFor('clone.indicators', 'omarchy.indicators', true, {surface: replacement})
assert(apiReplacement !== apiA, 'recreated surfaces receive fresh reveal bindings')
host.moduleSlots = []
host.prunePluginBarApis()
assert(apiB.destroyed && apiReplacement.destroyed, 'last-surface teardown destroys remaining facades')
assert(calls.every(call => call[1] === 'clone.indicators'), 'facade teardown preserves original ownership ID')
JS

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; per-surface QML runtime checks"
  exit 0
fi
require_command jq

fixture_dir=$(mktemp -d)
qs_pid=""
cleanup() {
  if [[ -n $qs_pid ]]; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  rm -rf "$fixture_dir"
}
trap cleanup EXIT

cp "$SHELL_TEST_DIR/fixtures/bar-reveal/shell.qml" "$fixture_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$fixture_dir/Ui"
ln -s "$ROOT/shell/Commons" "$fixture_dir/Commons"
ln -s "$ROOT/shell/plugins" "$fixture_dir/plugins"
mkdir -p "$fixture_dir/home"

# No desktop surfaces are mapped: synthetic hover exercises the real QML
# timers, indicator widgets, and PluginBarApi bindings on two independent bars.
QT_QPA_PLATFORM=offscreen OMARCHY_PATH="$ROOT" \
  OMARCHY_QML_TEST_RESULT="$fixture_dir/result.json" \
  HOME="$fixture_dir/home" XDG_CONFIG_HOME="$fixture_dir/home/.config" \
  XDG_CACHE_HOME="$fixture_dir/home/.cache" \
  quickshell -p "$fixture_dir" --no-color >"$fixture_dir/log" 2>&1 &
qs_pid=$!

for _ in {1..70}; do
  [[ -s $fixture_dir/result.json ]] && break
  if ! kill -0 "$qs_pid" 2>/dev/null; then
    cat "$fixture_dir/log" >&2
    fail "bar reveal fixture exited before producing results"
  fi
  sleep 0.1
done

if [[ ! -s $fixture_dir/result.json ]] || ! jq -e '.ok' "$fixture_dir/result.json" >/dev/null; then
  cat "$fixture_dir/log" >&2
  [[ ! -s $fixture_dir/result.json ]] || cat "$fixture_dir/result.json" >&2
  fail "per-surface runtime reveal checks"
fi
pass "independent QML surfaces reveal, hold, suppress, collapse and tear down locally"
