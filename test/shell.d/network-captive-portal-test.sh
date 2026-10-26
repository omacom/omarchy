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
const url = new URL(network.captivePortalUrl)
assertEqual(url.protocol, 'http:', 'browser entry point uses plain HTTP so a portal can intercept it')
assertEqual(url.hostname, 'ping.omacom.io', 'browser entry point is fixed rather than portal-supplied')
assertEqual(url.username + url.password, '', 'browser entry point contains no credentials')
JS

# The browser must open the URL NetworkManager probes, or a portal that only
# intercepts the probed host would never show its sign-in page.
nm_conf="$ROOT/etc/NetworkManager/conf.d/omarchy-connectivity.conf"
nm_uri=$(sed -n 's/^uri=//p' "$nm_conf")
panel_uri=$(sed -n 's/^var captivePortalUrl = "\(.*\)"$/\1/p' "$ROOT/shell/plugins/panels/network/Model.js")
[[ -n $nm_uri && $nm_uri == "$panel_uri" ]] || fail "NetworkManager probes the URL the panel opens ($nm_uri vs $panel_uri)"
pass "NetworkManager probes the URL the panel opens"
[[ $(sed -n 's/^response=\(.*\)$/[\1]/p' "$nm_conf") == "[]" ]] || fail "NetworkManager expects the endpoint's empty 204"
pass "NetworkManager expects the endpoint's empty 204"

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
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Keep installed enum values and actual UI bindings. Only replace the singleton
// and expose private IDs in the disposable copy, never in production code.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
// The panel's content is built lazily, so its private IDs are exposed from
// the content root and mirrored on the panel once the test builds it.
source = source.replace('      id: keyCatcher\n', `      id: keyCatcher
      property alias testButton: portalAction
      property alias testTitle: heroSsid
`)
source = source.replace('  id: root', `  id: root
  function testEnsureContent() { return panel.ensureContent() }
  readonly property Item testContent: panel.loadedContent
  readonly property Item testButton: panel.loadedContent ? panel.loadedContent.testButton : null
  readonly property Item testKeys: panel.loadedContent
  readonly property Item testMeta: panel.loadedContent ? panel.loadedContent.heroMeta : null
  readonly property Item testTitle: panel.loadedContent ? panel.loadedContent.testTitle : null
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
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >> "$NETWORK_TEST_BROWSER_LOG"\n' > "$stage/bin/omarchy-network-captive-portal"
chmod +x "$stage/bin/omarchy-network-captive-portal"

# All networking and external actions are mocked; the real connection and
# browser are never touched, and the fixture writes only to its scratch HOME.
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  NETWORK_TEST_BROWSER_LOG="$stage/browser.log" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network portal fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network portal runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network portal fixture has no QML errors" "$output"
fi
[[ -f $stage/browser.log ]] || fail "portal action launches the browser"
[[ $(<"$stage/browser.log") == "http://ping.omacom.io/nm-check.txt" ]] || fail "portal opens exactly one fixed HTTP URL"
pass "network portal, recovery, disabled checks, outage, disconnect, keyboard navigation, and browser argv work in QML"
