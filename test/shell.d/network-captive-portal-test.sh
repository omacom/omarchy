#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const states = { Unknown: 0, None: 1, Portal: 2, Limited: 3, Full: 4 }

for (const kind of ['wifi', 'ethernet']) {
  for (const [native, expected] of [
    ['Unknown', 'unknown'], ['None', 'none'], ['Portal', 'portal'],
    ['Limited', 'limited'], ['Full', 'full']
  ]) {
    assertEqual(network.connectivityState(kind, states[native], states, true), expected,
      `${kind} maps native ${native} connectivity without confusing an outage with a portal`)
  }
  assertEqual(network.connectivityState(kind, 99, states, true), 'unknown', `${kind} handles unknown connectivity`)
  for (const native of Object.values(states)) {
    assertEqual(network.connectivityState(kind, native, states, false), 'unknown', `${kind} ignores stale results with probing disabled (${native})`)
  }
}
for (const native of Object.values(states)) {
  assertEqual(network.connectivityState('disconnected', native, states, true), 'none', `disconnect clears stale connectivity (${native})`)
}
for (const state of ['portal', 'limited']) {
  assertEqual(network.connectionIcon('wifi', 80, state), '󰤩', `${state} uses a blocked Wi-Fi icon`)
  assertEqual(network.connectionIcon('ethernet', 80, state), '󰈂', `${state} uses a blocked Ethernet icon`)
  assertEqual(network.connectionIcon('disconnected', 80, state), '󰤮', `${state} does not override the disconnected icon`)
}
for (const state of ['full', 'unknown', 'none', undefined]) {
  for (const signal of [-1, 0, 20, 40, 60, 80, 100]) {
    assertEqual(network.connectionIcon('wifi', signal, state), network.wifiIconFor(signal), `${state} preserves Wi-Fi strength ${signal}`)
  }
  assertEqual(network.connectionIcon('ethernet', -1, state), '󰈀', `${state} preserves the Ethernet icon`)
}
const fs = require('fs')
const vm = require('vm')
const portal = vm.createContext({})
vm.runInContext(fs.readFileSync(root + '/shell/plugins/panels/network/PortalState.js', 'utf8')
  .replace(/^\.pragma library\s*/, ''), portal)
assert(!portal.claimAutomatic('wifi:a', 'portal', false), 'automatic sign-in is opt-in')
assert(portal.claimAutomatic('wifi:a', 'portal', true), 'first opted-in panel claims portal')
assert(!portal.claimAutomatic('wifi:a', 'portal', true), 'second monitor cannot duplicate launch')
assert(!portal.claimAutomatic('wifi:a', 'limited', true), 'limited is not a portal')
assert(!portal.claimAutomatic('wifi:a', 'portal', true), 'temporary limited status does not reopen the same portal')
portal.claimAutomatic('wifi:a', 'full', true)
assert(portal.claimAutomatic('wifi:a', 'portal', true), 'a new portal after full connectivity can open')
portal.claimAutomatic('', 'none', true)
assert(portal.claimAutomatic('wifi:a', 'portal', true), 'reconnection rearms automatic sign-in')
portal.markOpened('wifi:b')
assert(!portal.claimAutomatic('wifi:b', 'portal', true), 'manual launch consumes automatic launch for the same connection')
assert(portal.claimAutomatic('wifi:c', 'portal', true), 'another network is independently eligible')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')
assert(!/ping\.archlinux\.org|captive\.apple\.com/.test(panelSource), 'panel contains no hardcoded Arch or Apple URL')
assert(!/--print-config/.test(panelSource), 'panel does not cache on-disk NM configuration')

JS

require_compositor "network captive-portal runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-captive-portal"
mkdir -p "$stage/network" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$fixture/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/"{Model,PortalState}.js "$stage/network/"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Keep installed enum values and actual UI bindings. Only replace the singleton
// and expose private IDs in the disposable copy, never in production code.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
source = source.replace('  id: root', `  id: root
  property alias testPortalProcess: portalProcess
  property alias testButton: portalAction
  property alias testKeys: keyCatcher
  property alias testMeta: heroMeta
  property alias testTitle: heroSsid
  property alias testPoll: connectivityPoll
  property alias testBarButton: button`)
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band; do
  ln -s noop "$stage/bin/$command"
done
# Preview uses only synthetic details, never the host's SSID or addresses.
# Normal assertions keep the details empty to exercise missing-route handling.
printf '#!/bin/bash\nif [[ -n ${NETWORK_TEST_PREVIEW:-} ]]; then\n  printf "type\\twifi\\niface\\ttest-wifi\\nssid\\tGuest Wi-Fi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\nfi\n' > "$stage/bin/omarchy-network-status"
chmod +x "$stage/bin/omarchy-network-status"
# Both the old and the new entry point are stubbed, so the run can prove which
# one was used: the sign-in view must be, and the real browser must not.
cat > "$stage/bin/argv-log" <<'PY_STUB'
#!/usr/bin/python3
import json, os, signal, sys
with open(os.environ["NETWORK_TEST_LOG_DIR"] + "/" + os.path.basename(sys.argv[0]) + ".log", "a") as log:
  log.write(json.dumps(sys.argv[1:]) + "\n")
if os.environ.get("NETWORK_TEST_HOLD") == "1":
  def stop(*args):
    with open(os.environ["NETWORK_TEST_LOG_DIR"] + "/stopped.log", "w") as log:
      log.write("stopped\n")
    sys.exit(0)
  signal.signal(signal.SIGTERM, stop)
  print("READY", flush=True)
  signal.pause()
PY_STUB
chmod +x "$stage/bin/argv-log"
for command in omarchy-launch-browser omarchy-network-portal-signin; do
  ln -s argv-log "$stage/bin/$command"
done

# All networking and external actions are mocked; the real connection and
# browser are never touched, and the fixture writes only to its scratch HOME.
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  NETWORK_TEST_LOG_DIR="$stage" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network portal fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network portal runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network portal fixture has no QML errors" "$output"
fi
if [[ -n ${NETWORK_TEST_PREVIEW:-} && -n ${NETWORK_TEST_SCREENSHOT:-} ]]; then
  [[ -s $NETWORK_TEST_SCREENSHOT ]] || fail "portal preview produces its requested screenshot"
fi
signin_log="$stage/omarchy-network-portal-signin.log"
[[ -f $signin_log ]] || fail "portal action opens the sign-in view"
python3 - "$signin_log" <<'PY_CHECK'
import json, sys
with open(sys.argv[1]) as log:
  calls = [json.loads(line) for line in log]
# One manual action, one reconnect, one new portal after Full, one lifetime check.
# Repeated callbacks, an extra monitor and Limited->Portal must add no launches.
assert len(calls) == 4, calls
for args in calls:
  assert args[:2] == ["--ssid=Guest Wi-Fi", "--interface=test-wifi"], args
  assert len(args) == 3 and args[2].startswith("--placement="), args
PY_CHECK
[[ -f $stage/stopped.log ]] || fail "closing the originating panel terminates its sign-in process"
# The sign-in view carries no profile of the user's, which is most of the point
# of it; letting the real browser answer a gateway again would undo that.
[[ ! -f $stage/omarchy-launch-browser.log ]] ||
  fail "signing in never hands the gateway the real browser" "$(<"$stage/omarchy-launch-browser.log")"
pass "network portal, recovery, disabled checks, outage, disconnect, keyboard navigation, multi-monitor automatic sign-in, and sign-in argv work in QML"
