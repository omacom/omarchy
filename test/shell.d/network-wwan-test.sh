#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

// The probe output format is a contract with Model.wwanStatusScript; parse
// every field and both line kinds, including the empty-modem fallbacks.
const status = network.parseWwanStatus(
  'wwan\tregistered\t73\tlte\tCHINA MOBILE\tenabled\tcdc-wdm0\n' +
  'profile\tChina Mobile LTE\tfb1b894e-6bad-4383-8930-cea5be8cadf7\tno\n')
assertEqual(status.available, true, 'a modem answering makes wwan available')
assertEqual(status.state, 'registered', 'registration state parses')
assertEqual(status.signal, 73, 'signal quality parses as a number')
assertEqual(status.tech, 'lte', 'access technology parses')
assertEqual(status.operator, 'CHINA MOBILE', 'operator name parses')
assertEqual(status.radio, 'enabled', 'radio kill switch state parses')
assertEqual(status.netdev, 'cdc-wdm0', 'netdev parses so updateDetails can relabel it')
assertEqual(status.profiles.length, 1, 'one GSM profile row parses')
assertEqual(status.profiles[0].name, 'China Mobile LTE', 'profile name parses')
assertEqual(status.profiles[0].active, false, 'inactive profile parses')
assertEqual(status.profiles[0].uuid, 'fb1b894e-6bad-4383-8930-cea5be8cadf7', 'profile uuid parses')

// An empty probe means "no modem" (or no mmcli), which must read as
// unavailable rather than as a modem with empty fields.
const none = network.parseWwanStatus('')
assertEqual(none.available, false, 'no probe output means no cellular support')
assertEqual(none.profiles.length, 0, 'no probe output lists no profiles')

// jq emits empty fields when the modem has no operator cached yet; the
// header line keeps its column count and every field falls back cleanly.
const sparse = network.parseWwanStatus('wwan\t\t\t\t\tenabled\tcdc-wdm0')
assertEqual(sparse.available, true, 'a modem without cached readings is still available')
assertEqual(sparse.state, '', 'missing state falls back to empty')
assertEqual(sparse.signal, -1, 'missing signal falls back to -1, which renders the empty-bars icon')
assertEqual(sparse.operator, '', 'missing operator falls back to empty')
// Active profiles sort first so the connected row tops the section.
const ordered = network.parseWwanStatus(
  'wwan\tconnected\t70\tlte\tOp\tenabled\tcdc-wdm0\n' +
  'profile\tIdle\tuuid-idle\tno\n' +
  'profile\tLive\tuuid-live\tyes\n')
assertEqual(ordered.profiles[0].name, 'Live', 'the active profile sorts first')

// Marketing labels for ModemManager access-technology names.
assertEqual(network.accessTechLabel('lte'), '4G', 'lte maps to 4G')
assertEqual(network.accessTechLabel('nr5g'), '5G', 'nr5g maps to 5G')
assertEqual(network.accessTechLabel('umts'), '3G', 'umts maps to 3G')
assertEqual(network.accessTechLabel('edge'), '2G', 'edge maps to 2G')
assertEqual(network.accessTechLabel(''), '', 'unknown technology stays empty')

// Signal bars bucket on the same 0-100 scale as Wi-Fi SIGNAL.
assertEqual(network.wwanIconFor(-1), '󰣽', 'no reading renders the empty-bars icon')
assertEqual(network.wwanIconFor(0), '󰣽', 'zero signal renders the empty-bars icon')
assertEqual(network.wwanIconFor(21), '󰣴', 'just above a fifth of scale renders one bar')
assertEqual(network.wwanIconFor(73), '󰣸', 'mid-high signal renders three bars')
assertEqual(network.wwanIconFor(100), '󰣺', 'full signal renders four bars')
assertEqual(network.connectionIcon('wwan', 73), '󰣸', 'the bar pill icon recognises wwan')
assertEqual(network.connectionIcon('wwan', -1), '󰣽', 'the bar pill icon renders empty bars without a reading')

// Hero detail: technology plus signal, either alone, neither.
assertEqual(network.headerDetail({ type: 'wwan', wwan_tech: 'lte', wwan_signal: 73 }), '4G · 73%', 'hero detail pairs technology with signal')
assertEqual(network.headerDetail({ type: 'wwan', wwan_tech: 'lte' }), '4G', 'hero detail survives a missing signal')
assertEqual(network.headerDetail({ type: 'wwan' }), '', 'hero detail collapses without readings')

// The panel keeps polling while closed so the bar pill tracks the modem:
// the timer must not gate on the panel being open.
const poll = panelSource.match(/id: wwanPoll[\s\S]*?onTriggered[^\n]*\n/)
assert(poll, 'network has a wwan poll timer')
assert(/running: true/.test(poll[0]), 'the wwan poll runs while the panel is closed')
assert(/interval: root\.opened \? 4000 : 15000/.test(panelSource), 'the wwan poll slows down while the panel is closed')

// Radio state and profile actions go over IPC, matching toggleNetwork.
assert(/function toggleWwan\(\) \{ root\.toggleWwan\(\) \}/.test(panelSource), 'network exposes the cellular radio toggle over IPC')

// The section only appears for a modem that answered the probe.
const section = panelSource.match(/\/\/ Cellular profiles[\s\S]*?Repeater \{[\s\S]*?model: root\.wwanProfiles/)
assert(section, 'network has a cellular profile section')
assert(/visible: root\.wwanAvailable && root\.wwanProfiles\.length > 0/.test(section[0]), 'the cellular section hides without a modem or profiles')

// updateDetails relabels the modem netdev the stock status script files
// under ethernet, so the hero shows cellular state for a routed modem.
assert(/next\.iface === wwan\.netdev/.test(panelSource), 'details relabel the modem netdev as wwan')

// Cellular state must not leak into the connection pool the wifi rows use:
// the probe result lands on its own property.
assert(/wwan = Model\.parseWwanStatus\(raw\)/.test(panelSource), 'the probe result lands on the wwan property')
JS

pass "network wwan model and structure"
