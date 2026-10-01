#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/services/PluginRegistry.qml'), 'utf8')
const registry = {
  shellConfigMutator: () => false,
  installedPlugins: { 'example.service': { kinds: ['service'] } },
  Util: { canonicalWidgetId: value => value, isPlainObject: value => value && typeof value === 'object' },
  registryRevision: 0,
  pluginsChanged: () => { throw new Error('failed mutation must not announce success') }
}
vm.createContext(registry)
for (const name of ['moveBarWidget', 'setBarWidget', 'setEnabled']) {
  vm.runInContext(source.match(new RegExp('  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?\\n  \\}'))[0], registry)
}
assertEqual(registry.moveBarWidget('example.service', {}), 'could not update shell config', 'registry move reports persistence failure')
assertEqual(registry.setBarWidget('example.service', 'setting', true, {}), 'could not update shell config', 'registry settings report persistence failure')
assertEqual(registry.setEnabled('example.service', true, {}), false, 'registry enable rejects persistence failure')
assertEqual(registry.lastEnableError, 'could not update shell config', 'registry enable exposes the failure reason')
assertEqual(registry.registryRevision, 0, 'failed registry mutations do not publish a revision')
const barSource = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const bar = {
  root: {
    shell: { mutateShellConfig: () => false },
    requestedTransparent: false
  },
  normalizePosition: value => value
}
vm.createContext(bar)
for (const name of ['setBarPosition', 'toggleTransparency', 'dropBarModule']) {
  vm.runInContext(barSource.match(new RegExp('  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?\\n  \\}'))[0], bar)
}
assertEqual(bar.setBarPosition('bottom'), false, 'bar position returns persistence failure')
assertEqual(bar.toggleTransparency(), false, 'bar transparency returns persistence failure')
assertEqual(bar.dropBarModule({ region: 'left', moduleName: 'example.widget' }, 'right', ''), false, 'bar drop returns persistence failure')
JS

require_command python3
if ! command -v quickshell >/dev/null; then
  skip "shell config mutation runtime (quickshell unavailable)"
  exit 0
fi

fixture=$(mktemp -d)
config_runtime=""
qs_pid=""
cleanup() {
  if [[ -n $qs_pid ]]; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  chmod -R u+rwX "$fixture"
  rm -rf "$fixture"
  if [[ -n $config_runtime ]]; then rm -rf "$config_runtime"; fi
}
trap cleanup EXIT
# Unix socket paths have a small fixed limit; TMPDIR can be much longer.
config_runtime=$(mktemp -d /tmp/omarchy-config-runtime.XXXXXX)
chmod 700 "$config_runtime"
mkdir -p "$fixture/home/.config/omarchy" "$fixture/services"
cp "$ROOT/shell/services/ShellConfigStore.qml" "$fixture/services/"
# Exercise the production mutation entry points without loading the desktop.
python3 - "$ROOT" "$fixture" <<'PY'
import pathlib, re, sys
root, fixture = map(pathlib.Path, sys.argv[1:])
source = (root / 'shell/shell.qml').read_text()
functions = []
for name in ['mutateShellConfig', 'updateEntryInline']:
    functions.append(re.search(r'  function ' + name + r'\([^\n]*\) \{.*?\n  \}', source, re.S).group())
qml = (root / 'test/shell.d/fixtures/shell-config-mutation/shell.qml').read_text()
qml = qml.replace('// MUTATION_FUNCTIONS', '\n'.join(functions).replace('Util.', 'shell.util.'))
(fixture / 'shell.qml').write_text(qml)
PY
config="$fixture/home/.config/omarchy/shell.json"
printf '%s\n' '{"version":1,"plugins":[]}' > "$config"
qs() {
  HOME="$fixture/home" XDG_RUNTIME_DIR="$config_runtime" XDG_CONFIG_HOME="$fixture/home/.config" \
    XDG_CACHE_HOME="$fixture/home/.cache" XDG_STATE_HOME="$fixture/home/.local/state" \
    QT_QPA_PLATFORM=offscreen quickshell "$@"
}
ulimit -c 0
qs -n -p "$fixture" > "$fixture/log" 2>&1 &
qs_pid=$!
ready=false
for _ in {1..100}; do
  if qs -p "$fixture" ipc call config-test noop > "$fixture/result" 2>/dev/null; then
    ready=true
    break
  fi
  if ! kill -0 "$qs_pid" 2>/dev/null; then break; fi
  sleep 0.05
done
[[ $ready == "true" ]] || fail "isolated config fixture starts" "$(cat "$fixture/log")"
pass "isolated config fixture starts offscreen with a fake HOME"

# Add an external plugin after the shell has cached the original empty list.
printf '%s\n' '{"version":1,"plugins":[{"id":"example.service","unknownSetting":42},{"id":"example.other","settings":{"keep":42}}],"external":{"unknown":true}}' > "$config"
qs -p "$fixture" ipc call config-test mutate > "$fixture/result"
python3 - "$config" "$fixture/result" <<'PY'
import json, sys
config, result = [json.load(open(p)) for p in sys.argv[1:]]
assert result['ok'] is True, result
assert config['plugins'] == [{'id': 'example.service', 'unknownSetting': 42}, {'id':'example.other', 'settings':{'keep':42}}], config
assert config['external'] == {'unknown': True}, config
assert config['bar']['position'] == 'bottom', config
assert result['config'] == config, result
PY
pass "mutation reads fresh disk config and preserves un-ingested plugins and unknown fields"
qs -p "$fixture" ipc call config-test inline > "$fixture/result"
python3 - "$config" "$fixture/result" <<'PY'
import json, sys
config, result = [json.load(open(p)) for p in sys.argv[1:]]
assert result['ok'] is True, result
assert config['plugins'][0] == {'id':'example.service', 'enabled':True}, config
assert config['plugins'][1] == {'id':'example.other', 'settings':{'keep':42}}, config
assert config['bar']['position'] == 'bottom', config
PY
pass "sequential inline settings preserve other entries and retain targeted replacement semantics"
cp "$config" "$fixture/before"
qs -p "$fixture" ipc call config-test inline > "$fixture/result"
python3 - "$fixture/result" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['ok'] is False
PY
cmp "$config" "$fixture/before"
pass "unchanged inline settings do not write"
qs -p "$fixture" ipc call config-test noop > "$fixture/result"
python3 - "$fixture/result" "$fixture/expected-memory" <<'PY'
import json, sys
json.dump(json.load(open(sys.argv[1]))['config'], open(sys.argv[2], 'w'))
PY

assert_refused() {
  qs -p "$fixture" ipc call config-test mutate > "$fixture/result"
  python3 - "$fixture/result" "$fixture/expected-memory" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
assert r['ok'] is False and r['error'], r
assert r['config'] == json.load(open(sys.argv[2])), r
PY
}
for invalid in '' '{' '[]' '{"version":2}' 'null'; do
  printf '%s' "$invalid" > "$config"
  cp "$config" "$fixture/before"
  assert_refused
  cmp "$config" "$fixture/before"
done
pass "empty, malformed and unsupported config files are refused without resetting disk or memory"
cp "$fixture/before" "$config"
# Restore the valid config for read/write failure cases.
printf '%s\n' '{"version":1,"plugins":[{"id":"example.service","unknownSetting":42}]}' > "$config"
cp "$config" "$fixture/before"
if (( EUID != 0 )); then
  chmod 000 "$config"
  assert_refused
  chmod 600 "$config"
  cmp "$config" "$fixture/before"
  pass "read failure is reported without changing disk or memory"
  chmod 500 "$(dirname "$config")"
  assert_refused
  chmod 700 "$(dirname "$config")"
  cmp "$config" "$fixture/before"
  pass "atomic write failure is reported without changing disk or memory"
else
  skip "permission failure cases require an unprivileged user"
fi
qs -p "$fixture" ipc call config-test throwing > "$fixture/result"
python3 - "$fixture/result" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
assert r['ok'] is False and 'mutation failed' in r['error'], r
PY
cmp "$config" "$fixture/before"
pass "throwing mutator leaves disk untouched"
qs -p "$fixture" ipc call config-test conflict > "$fixture/result"
python3 - "$config" "$fixture/result" <<'PY'
import json, sys
config, r = [json.load(open(p)) for p in sys.argv[1:]]
assert r['ok'] is False and 'changed during mutation' in r['error'], r
assert config == {'version':1, 'external':'during mutation'}, config
PY
pass "external edit during mutation is detected and retained"
printf '%s\n' '{"version":1,"external":"partial","bar":{"customOnly":true}}' > "$config"
qs -p "$fixture" ipc call config-test mutate > "$fixture/result"
python3 - "$config" "$fixture/result" <<'PY'
import json, sys
config, r = [json.load(open(p)) for p in sys.argv[1:]]
assert r['ok'] is True and r['config'] == config, r
assert config == {'version':1, 'external':'partial', 'bar':{'customOnly':True, 'position':'bottom'}}, config
PY
pass "valid partial config remains canonical without adding default fields"
rm "$config"
qs -p "$fixture" ipc call config-test mutate > "$fixture/result"
python3 - "$config" "$fixture/result" <<'PY'
import json, sys
config, r = [json.load(open(p)) for p in sys.argv[1:]]
assert r['ok'] is True, r
assert config == {'version':1, 'plugins':[], 'bar':{'position':'bottom'}}, config
PY
pass "genuinely missing config can be created from defaults"
