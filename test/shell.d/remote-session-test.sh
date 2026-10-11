#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const model = requireFromRoot('shell/plugins/services/remote-session/RemoteSessionModel.js')

assert(model.isCaptureEvent('screencast'), 'the screencast event triggers a probe')
assert(!model.isCaptureEvent('screencastv2'), 'the paired screencastv2 event does not double the probe')
assert(!model.isCaptureEvent('openwindow') && !model.isCaptureEvent(''), 'unrelated Hyprland events are ignored')

assertDeepEqual(model.stateFromOutput(''), { active: false, peers: [] }, 'no gliff-server means no session')
assertDeepEqual(model.stateFromOutput('\n'), { active: false, peers: [] }, 'blank output means no session')
assertDeepEqual(model.stateFromOutput('4321 \n'), { active: true, peers: [] }, 'a local server without ssh is a session with no known peer')
assertDeepEqual(model.stateFromOutput('4321 10.0.0.5\n'), { active: true, peers: ['10.0.0.5'] }, 'an ssh-spawned server reports the client address')
assertDeepEqual(model.stateFromOutput('1 10.0.0.5\n2 10.0.0.5\n3 fd00::9\n'), { active: true, peers: ['10.0.0.5', 'fd00::9'] }, 'peers are listed once each')

const service = read('shell/plugins/services/remote-session/Service.qml')
const manifest = JSON.parse(read('shell/plugins/services/remote-session/manifest.json'))
assertEqual(manifest.id, 'omarchy.remote-session', 'service manifest id matches the indicator lookup')
assert(manifest.kinds.includes('service') && manifest.entryPoints.service === 'Service.qml', 'service manifest declares a service entry point')
assert(service.includes('target: Hyprland') && service.includes('isCaptureEvent(event ? event.name : "")'), 'service re-probes on Hyprland screencast events')
assert(service.includes('eventDebounce.restart()'), 'service debounces event bursts into one probe')
assert(service.includes('/shell/plugins/services/remote-session/probe.sh"'), 'service runs the shared probe script')
assert(service.includes('running: root.active') && service.includes('interval: 2000'), 'service polls only while a session is active, since the stop event is not reliable')
assert(!service.includes('omarchy-notification-send'), 'a session is shown by the indicator alone, with no notification')

const indicator = read('shell/plugins/bar/indicators/RemoteSession.qml')
const widget = read('shell/plugins/bar/widgets/Indicators.qml')
const widgetManifest = JSON.parse(read('shell/plugins/bar/widgets/Indicators.manifest.json'))
assert(widget.match(/defaultIndicatorEntries: \[ "PasswordlessSudo", "ScreenRecording", "RemoteSession"/), 'remote session is included in the default indicator tray')
assert(widgetManifest.barWidget.schema.find(field => field.key === 'items').options.some(option => option.value === 'RemoteSession'), 'remote session is configurable alongside the other indicators')
assert(indicator.includes('firstPartyServiceFor("omarchy.remote-session")'), 'indicator reads the remote session service')
assert(indicator.includes('"Remote session from " + peers.join(", ")'), 'active tooltip names the connected peers')
assert(indicator.includes('useActiveColor: true') && indicator.includes('activeColor: Commons.Color.urgent'), 'active remote session uses the theme danger color')
assertEqual(indicator.match(/activeText: "([^"]+)"/)[1], indicator.match(/inactiveText: "([^"]+)"/)[1], 'remote session keeps the same icon in both states')
assert(!indicator.includes('visible:'), 'remote session uses the shared indicator visibility and hover behavior')
assert(indicator.includes('root.remoteSessionService.refresh()'), 'indicator refresh re-probes the service')

const shell = read('shell/shell.qml')
assert((shell.match(/"omarchy\.remote-session"/g) || []).length >= 2, 'third-party bar clones can read the remote session service')
const api = read('shell/services/PluginFirstPartyServiceApi.qml')
assert(api.includes('property bool active: false') && api.includes('property var peers: []'), 'service proxy exposes the remote session state')
assert(api.includes('serviceId === "omarchy.remote-session" && _refresh') && shell.includes('_refresh: function()'), 'service proxy forwards refresh for cloned indicator widgets')
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/bin" "$TMPDIR/proc/100" "$TMPDIR/proc/200"

probe_script="$ROOT/shell/plugins/services/remote-session/probe.sh"
bash -n "$probe_script" || fail "remote session probe is valid bash"
pass "remote session probe is valid bash"

cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
[[ $1 == "-x" && $2 == "-u" && $3 == "$(id -u)" && $4 == "gliff-server" ]] || exit 2
[[ -n ${GLIFF_PIDS:-} ]] || exit 1
printf '%s\n' $GLIFF_PIDS
SH
chmod +x "$TMPDIR/bin/pgrep"

# The probe reads /proc/<pid>/environ; point a copy at fixtures instead.
sed "s|/proc/\$pid/environ|$TMPDIR/proc/\$pid/environ|" "$probe_script" >"$TMPDIR/probe.sh"
grep -q "$TMPDIR/proc" "$TMPDIR/probe.sh" || fail "probe reads the server environment from /proc"
pass "probe reads the server environment from /proc"

probe() {
  PATH="$TMPDIR/bin:$PATH" GLIFF_PIDS="${1:-}" bash "$TMPDIR/probe.sh"
}

[[ -z $(probe) ]] || fail "probe prints nothing without a gliff server"
pass "probe prints nothing without a gliff server"

printf 'HOME=/home/x\0SSH_CONNECTION=10.0.0.5 51234 10.0.0.1 22\0TERM=foot\0' >"$TMPDIR/proc/100/environ"
printf 'HOME=/home/x\0TERM=foot\0' >"$TMPDIR/proc/200/environ"

[[ $(probe "100") == "100 10.0.0.5" ]] || fail "probe reports the ssh client address of a spawned server"
pass "probe reports the ssh client address of a spawned server"

[[ $(probe "200") == "200 " ]] || fail "probe reports a local server with an empty peer"
pass "probe reports a local server with an empty peer"

(( $(probe "100 200" | wc -l) == 2 )) || fail "probe lists every server"
pass "probe lists every server"
