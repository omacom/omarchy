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
    shell: { mutateShellConfig: () => false }
  },
  normalizePosition: value => value,
  normalizeLayout: value => value,
  clearBarDrag: () => {},
  layoutWidgets: { sections: { left: ['widget'], right: [] } },
  widgetMemo: {}
}
vm.createContext(bar)
for (const name of ['setBarPosition', 'landBarDrag']) {
  vm.runInContext(barSource.match(new RegExp('  function ' + name + '\\([^\\n]*\\) \\{[\\s\\S]*?\\n  \\}'))[0], bar)
}
assertEqual(bar.setBarPosition('bottom'), false, 'bar position returns persistence failure')
const move = { key: 'widget', keys: JSON.stringify(bar.layoutWidgets.sections), from: {region: 'left', index: 0, id: 'example.widget'}, to: {region: 'right', index: -1} }
assertEqual(bar.landBarDrag(move), false, 'bar drop returns persistence failure')
assertEqual(bar.widgetMemo.expected, null, 'failed drop retires its expected layout')
const fresh = {bar: {layout: {left: [{id: 'different.widget'}], right: []}}, external: true}
bar.BarModel = requireFromRoot('shell/plugins/bar/BarModel.js')
bar.Util = {normalizeLayoutEntry: entry => entry}
bar.root.shell.mutateShellConfig = mutator => mutator(fresh)
assertEqual(bar.landBarDrag(move), false, 'bar drop cancels when the dragged entry changed on disk')
assertEqual(fresh.bar.layout.left[0].id, 'different.widget', 'bar drop preserves the external replacement')
assertEqual(fresh.bar.layout.right.length, 0, 'refused drag does not move the replacement')
const originalLayout = {left: [{id: 'example.widget', value: 'one'}, {id: 'example.widget', value: 'two'}], right: []}
move.layout = JSON.stringify(originalLayout)
fresh.bar.layout = JSON.parse(move.layout)
fresh.bar.layout.left.reverse()
assertEqual(bar.landBarDrag(move), false, 'same-id widgets swapped on disk cancel the drag')
assertEqual(fresh.bar.layout.left[0].value, 'two', 'same-id replacement remains in place')
fresh.bar.layout = JSON.parse(move.layout)
fresh.bar.layout.right.push({id: 'destination.widget'})
assertEqual(bar.landBarDrag(move), false, 'destination edit before watcher refresh cancels the drag')
fresh.bar.layout = JSON.parse(move.layout)
assertEqual(bar.landBarDrag(move), true, 'unchanged fresh layout still accepts the drag')
assertEqual(fresh.bar.layout.right[0].value, 'one', 'the captured source widget moves')

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
def functions(source, names, indent=2):
    return '\n'.join(re.search(r' ' * indent + r'function ' + name + r'\([^\n]*\).*?\n' + r' ' * indent + r'\}', source, re.S).group() for name in names)
qml = (root / 'test/shell.d/fixtures/shell-config-mutation/shell.qml').read_text()
qml = qml.replace('// MUTATION_FUNCTIONS', functions(source, ['mutateShellConfig', 'updateEntryInline']).replace('Util.', 'shell.util.'))
qml = qml.replace('// IPC_FUNCTIONS', functions(source, ['setPluginEnabled'], 4))
registry = (root / 'shell/services/PluginRegistry.qml').read_text()
qml = qml.replace('// REGISTRY_FUNCTIONS', functions(registry, ['setEnabled', 'ensureConfigShape', 'findEntryLocation', 'findBarLocation', 'barEntryId', 'removeDisabled']).replace('Util.', 'shell.util.'))
(fixture / 'shell.qml').write_text(qml)
PY
config="$fixture/home/.config/omarchy/shell.json"
printf '%s\n' '{"version":1,"plugins":[]}' > "$config"
qs_env=(env
  HOME="$fixture/home" XDG_RUNTIME_DIR="$config_runtime" XDG_CONFIG_HOME="$fixture/home/.config"
  XDG_CACHE_HOME="$fixture/home/.cache" XDG_STATE_HOME="$fixture/home/.local/state"
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic)
qs() {
  "${qs_env[@]}" quickshell "$@"
}
ulimit -c 0
# Keep the child PID itself so cleanup cannot leave Quickshell running after
# terminating a background function's wrapper shell.
"${qs_env[@]}" quickshell -n -p "$fixture" > "$fixture/log" 2>&1 &
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

# Every current bar section must use the fresh on-disk entry, including the
# sections added by the bar rework and the tray drawer.
for section in left centerBegin center centerEnd right tray; do
  printf '{"version":1,"bar":{"layout":{"%s":[{"id":"example.service","before":true}]}},"external":"keep"}\n' "$section" > "$config"
  qs -p "$fixture" ipc call config-test inline > "$fixture/result"
  python3 - "$config" "$fixture/result" "$section" <<'CHECK'
import json, sys
config, result = [json.load(open(p)) for p in sys.argv[1:3]]
assert result['ok'] is True, result
assert config['bar']['layout'][sys.argv[3]] == [{'id': 'example.service', 'enabled': True}], config
assert config['external'] == 'keep', config
CHECK
  pass "fresh inline settings update the $section section"
done
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

printf '%s\n' '{"version":1,"plugins":[{"id":"example.service"},{"id":"example.other","keep":42}]}' > "$config"
qs -p "$fixture" ipc call config-test noop > "$fixture/result"
python3 - "$fixture/result" "$fixture/expected-memory" <<'PY'
import json, sys
json.dump(json.load(open(sys.argv[1]))['config'], open(sys.argv[2], 'w'))
PY
cp "$config" "$fixture/valid"
assert_ipc_failure() {
  [[ $(qs -p "$fixture" ipc call config-test setPluginEnabled example.service false) == "could not update shell config" ]] ||
    fail "known plugin disable IPC reports persistence failure"
  qs -p "$fixture" ipc call config-test noop > "$fixture/result"
  python3 - "$fixture/result" "$fixture/expected-memory" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['config'] == json.load(open(sys.argv[2]))
PY
}
printf '%s' '{' > "$config"
assert_ipc_failure
[[ $(cat "$config") == "{" ]] || fail "failed IPC mutations retain malformed file"
pass "known plugin disable IPC reports invalid-file failures without publishing state"
cp "$fixture/valid" "$config"
if (( EUID != 0 )); then
  chmod 000 "$config"
  assert_ipc_failure
  chmod 600 "$config"
  cmp "$config" "$fixture/valid"
  pass "plugin disable IPC reports read failures"
  chmod 500 "$(dirname "$config")"
  assert_ipc_failure
  chmod 700 "$(dirname "$config")"
  cmp "$config" "$fixture/valid"
  pass "plugin disable IPC reports atomic write failures"
else
  skip "IPC permission failure cases require an unprivileged user"
fi
[[ $(qs -p "$fixture" ipc call config-test setPluginEnabled example.service false) == "ok" ]] || fail "known plugin disable succeeds"
python3 - "$config" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['plugins'] == [{'id':'example.other', 'keep':42}]
PY
[[ $(qs -p "$fixture" ipc call config-test setPluginEnabled example.service true) == "ok" ]] || fail "known plugin enable succeeds"
cp "$config" "$fixture/before"
[[ $(qs -p "$fixture" ipc call config-test setPluginEnabled missing.plugin true) == "unknown" ]] || fail "unknown enable preserves unknown response"
cmp "$config" "$fixture/before"
# Disabling an unregistered ID intentionally supports removing stale entries.
printf '%s\n' '{"version":1,"plugins":[{"id":"missing.plugin"}]}' > "$config"
[[ $(qs -p "$fixture" ipc call config-test setPluginEnabled missing.plugin false) == "ok" ]] || fail "unregistered disable keeps cleanup behavior"
python3 - "$config" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['plugins'] == []
PY
pass "plugin IPC preserves known enable/disable, unknown enable and unregistered cleanup"

mkdir "$fixture/bin"
cat > "$fixture/bin/omarchy-shell" <<'SH'
#!/bin/bash
if [[ -n ${CONFIG_TEST_RESPONSE:-} ]]; then
  printf '%s\n' "$CONFIG_TEST_RESPONSE"
else
  exec quickshell -p "$CONFIG_TEST_FIXTURE" ipc call config-test "${@:2}"
fi
SH
chmod +x "$fixture/bin/omarchy-shell"
plugin_disable() {
  HOME="$fixture/home" XDG_RUNTIME_DIR="$config_runtime" XDG_CONFIG_HOME="$fixture/home/.config" \
    XDG_CACHE_HOME="$fixture/home/.cache" XDG_STATE_HOME="$fixture/home/.local/state" \
    QT_QPA_PLATFORM=offscreen CONFIG_TEST_FIXTURE="$fixture" PATH="$fixture/bin:$PATH" \
    bash "$ROOT/bin/omarchy-plugin-disable" "$@"
}
printf '%s' '{' > "$config"
if plugin_disable example.service > "$fixture/cli-result" 2>&1; then fail "plugin disable CLI rejects persistence failure"; fi
[[ $(cat "$fixture/cli-result") == "omarchy-plugin-disable: could not update shell config" ]] ||
  fail "plugin disable CLI prints actual persistence failure" "$(cat "$fixture/cli-result")"
if CONFIG_TEST_RESPONSE=unknown plugin_disable missing.plugin > "$fixture/cli-result" 2>&1; then fail "plugin disable CLI rejects unknown response"; fi
[[ $(cat "$fixture/cli-result") == "omarchy-plugin-disable: plugin 'missing.plugin' is not known; run: omarchy-shell shell rescanPlugins" ]] ||
  fail "plugin disable CLI retains unknown-plugin advice"
cp "$fixture/valid" "$config"
[[ $(plugin_disable example.service) == "Disabled example.service" ]] || fail "plugin disable CLI reports successful save"
pass "plugin disable CLI distinguishes persistence errors, unknown plugins and success"
