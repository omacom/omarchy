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
def functions(source, names, indent=2):
    return '\n'.join(re.search(r' ' * indent + r'function ' + name + r'\([^\n]*\).*?\n' + r' ' * indent + r'\}', source, re.S).group() for name in names)
qml = (root / 'test/shell.d/fixtures/shell-config-mutation/shell.qml').read_text()
qml = qml.replace('// MUTATION_FUNCTIONS', functions(source, ['mutateShellConfig', 'updateEntryInline']).replace('Util.', 'shell.util.'))
qml = qml.replace('// IPC_FUNCTIONS', functions(source, ['toggleBarTransparency', 'setPluginEnabled'], 4))
bar = (root / 'shell/plugins/bar/Bar.qml').read_text()
qml = qml.replace('// BAR_FUNCTIONS', functions(bar, ['toggleTransparency']).replace('root.shell', 'fixtureBar.host').replace('root.', 'fixtureBar.').replace('Util.', 'shell.util.'))
registry = (root / 'shell/services/PluginRegistry.qml').read_text()
qml = qml.replace('// REGISTRY_FUNCTIONS', functions(registry, ['setEnabled', 'ensureConfigShape', 'findEntryLocation', 'findBarLocation', 'barEntryId', 'removeDisabled']).replace('Util.', 'shell.util.'))
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

# Keep the bar's requestedTransparent at false while editing disk underneath it.
printf '%s\n' '{"version":1,"bar":{"transparent":true},"plugins":[{"id":"example.service"},{"id":"example.other","keep":42}]}' > "$config"
[[ $(qs -p "$fixture" ipc call config-test toggleBarTransparency) == "ok" ]] || fail "fresh transparency toggle succeeds"
python3 - "$config" <<'PY'
import json, sys
config = json.load(open(sys.argv[1]))
assert config['bar']['transparent'] is False, config
assert config['plugins'][1] == {'id':'example.other', 'keep':42}, config
PY
[[ $(qs -p "$fixture" ipc call config-test toggleBarTransparency) == "ok" ]] || fail "sequential transparency toggle succeeds"
python3 - "$config" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['bar']['transparent'] is True
PY
pass "transparency IPC toggles fresh disk state despite stale bar properties"
qs -p "$fixture" ipc call config-test barAvailable false >/dev/null
[[ $(qs -p "$fixture" ipc call config-test toggleBarTransparency) == "no-bar" ]] || fail "absent bar still returns no-bar"
qs -p "$fixture" ipc call config-test legacyBar >/dev/null
[[ $(qs -p "$fixture" ipc call config-test toggleBarTransparency) == "ok" ]] || fail "legacy void-returning bar toggle succeeds"
qs -p "$fixture" ipc call config-test barAvailable true >/dev/null
pass "transparency IPC preserves missing-bar and legacy bar responses"
qs -p "$fixture" ipc call config-test noop > "$fixture/result"
python3 - "$fixture/result" "$fixture/expected-memory" <<'PY'
import json, sys
json.dump(json.load(open(sys.argv[1]))['config'], open(sys.argv[2], 'w'))
PY
cp "$config" "$fixture/valid"
assert_ipc_failure() {
  [[ $(qs -p "$fixture" ipc call config-test toggleBarTransparency) == "could not update shell config" ]] ||
    fail "transparency IPC reports persistence failure"
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
pass "toggle and known plugin disable IPC report invalid-file failures without publishing state"
cp "$fixture/valid" "$config"
if (( EUID != 0 )); then
  chmod 000 "$config"
  assert_ipc_failure
  chmod 600 "$config"
  cmp "$config" "$fixture/valid"
  pass "toggle and plugin disable IPC report read failures"
  chmod 500 "$(dirname "$config")"
  assert_ipc_failure
  chmod 700 "$(dirname "$config")"
  cmp "$config" "$fixture/valid"
  pass "toggle and plugin disable IPC report atomic write failures"
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
