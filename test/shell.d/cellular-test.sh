#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const cellular = requireFromRoot('shell/plugins/panels/cellular/Model.js')
const serviceSource = fs.readFileSync(root + '/shell/plugins/panels/cellular/Service.qml', 'utf8')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/cellular/Panel.qml', 'utf8')

// A Quectel EM05-CN on beeline, captured with `mmcli -m any -K` and
// `mmcli -b 1 -K`, trimmed of the band and mode lists, followed by
// /proc/net/route as the service reads it.
const connected = `modem.dbus-path                                 : /org/freedesktop/ModemManager1/Modem/1
modem.generic.manufacturer                      : Quectel
modem.generic.model                             : Quectel EM05-CN
modem.generic.primary-port                      : cdc-wdm0
modem.generic.ports.value[3]                    : wwp0s20f0u5u3i1 (net)
modem.generic.unlock-required                   : sim-pin2
modem.generic.unlock-retries.value[1]           : sim-pin2 (3)
modem.generic.state                             : connected
modem.generic.state-failed-reason               : --
modem.generic.power-state                       : on
modem.generic.access-technologies.length        : 1
modem.generic.access-technologies.value[1]      : lte
modem.generic.signal-quality.value              : 54
modem.generic.signal-quality.recent             : yes
modem.generic.current-modes                     : allowed: 2g, 3g, 4g; preferred: 4g
modem.3gpp.operator-code                        : 25099
modem.3gpp.operator-name                        : beeline
modem.3gpp.registration-state                   : home
modem.3gpp.packet-service-state                 : attached
modem.3gpp.eps.initial-bearer.dbus-path         : /org/freedesktop/ModemManager1/Bearer/0
modem.3gpp.eps.initial-bearer.settings.apn      : 3g.ge
modem.generic.sim                               : /org/freedesktop/ModemManager1/SIM/0
modem.generic.bearers.length                    : 1
modem.generic.bearers.value[1]                  : /org/freedesktop/ModemManager1/Bearer/1
bearer.dbus-path                         : /org/freedesktop/ModemManager1/Bearer/1
bearer.type                              : default
bearer.status.connected                  : yes
bearer.status.interface                  : wwp0s20f0u5u3i1
bearer.properties.apn                    : home.beeline.ru
bearer.properties.ip-type                : ipv4v6
bearer.ipv4-config.method                : static
bearer.ipv4-config.address               : 10.42.181.217
bearer.ipv4-config.prefix                : 30
bearer.ipv4-config.gateway               : 10.42.181.218
bearer.ipv6-config.address               : --
bearer.stats.start-date                  : 1794651728
bearer.stats.bytes-rx                    : --
Iface	Destination	Gateway 	Flags	RefCnt	Use	Metric	Mask		MTU	Window	IRTT
wwp0s20f0u5u3i1	00000000	DAB52A0A	0003	0	0	700	00000000	0	0	0
wwp0s20f0u5u3i1	D8B52A0A	00000000	0001	0	0	700	FCFFFFFF	0	0	0
`

const registeredOnly = `modem.dbus-path                                 : /org/freedesktop/ModemManager1/Modem/0
modem.generic.primary-port                      : cdc-wdm0
modem.generic.state                             : registered
modem.generic.access-technologies.length        : 1
modem.generic.access-technologies.value[1]      : umts
modem.generic.signal-quality.value              : 31
modem.3gpp.operator-name                        : Vodafone
modem.3gpp.registration-state                   : roaming
modem.generic.bearers.length                    : 0
`

const simMissing = `modem.dbus-path                                 : /org/freedesktop/ModemManager1/Modem/2
modem.generic.model                             : Quectel EM05-CN
modem.generic.primary-port                      : cdc-wdm0
modem.generic.unlock-required                   : --
modem.generic.state                             : failed
modem.generic.state-failed-reason               : sim-missing
modem.generic.power-state                       : on
modem.generic.access-technologies.length        : 0
modem.generic.signal-quality.value              : 0
modem.generic.signal-quality.recent             : no
modem.3gpp.operator-code                        : --
modem.3gpp.operator-name                        : --
modem.3gpp.registration-state                   : --
modem.generic.sim                               : --
modem.generic.bearers.length                    : 0
`

const pinLocked = `modem.dbus-path                                 : /org/freedesktop/ModemManager1/Modem/3
modem.generic.primary-port                      : cdc-wdm0
modem.generic.unlock-required                   : sim-pin
modem.generic.unlock-retries.value[1]           : sim-pin (3)
modem.generic.state                             : locked
modem.generic.state-failed-reason               : --
modem.generic.signal-quality.value              : 0
modem.generic.bearers.length                    : 0
`

// Parsing: every field the bar and panel show, from a real capture.
const status = cellular.parseStatus(connected, true)
assertDeepEqual(
  {
    present: status.present, state: status.state, signal: status.signal, tech: status.tech,
    operatorName: status.operatorName, operatorCode: status.operatorCode, registration: status.registration,
    apn: status.apn, primaryPort: status.primaryPort, model: status.model, unlockRequired: status.unlockRequired
  },
  {
    present: true, state: 'connected', signal: 54, tech: 'lte',
    operatorName: 'beeline', operatorCode: '25099', registration: 'home',
    apn: 'home.beeline.ru', primaryPort: 'cdc-wdm0', model: 'Quectel EM05-CN', unlockRequired: 'sim-pin2'
  },
  'cellular parses a connected modem from mmcli keyvalue output'
)
assertDeepEqual(
  status.bearer,
  {
    path: '/org/freedesktop/ModemManager1/Bearer/1', connected: true, iface: 'wwp0s20f0u5u3i1', apn: 'home.beeline.ru',
    ipType: 'ipv4v6', ipv4: '10.42.181.217', prefix: '30', gateway: '10.42.181.218', startDate: 1794651728
  },
  'cellular parses the connected bearer'
)
assertEqual(cellular.formatAddress(status.bearer), '10.42.181.217/30', 'cellular formats the bearer address with its prefix')
assertEqual(cellular.primaryRouteInterface(connected), 'wwp0s20f0u5u3i1', 'cellular finds the default-route interface in /proc/net/route')
assertEqual(
  cellular.primaryRouteInterface('Iface\tDestination\tGateway\tFlags\tRefCnt\tUse\tMetric\tMask\nwwan0\t00000000\t01000A0A\t0003\t0\t0\t700\t00000000\t0\t0\t0\nwlan0\t00000000\t0101A8C0\t0003\t0\t0\t600\t00000000\t0\t0\t0\n'),
  'wlan0',
  'cellular picks the default route with the lowest metric'
)

const registered = cellular.parseStatus(registeredOnly, true)
assertDeepEqual(
  [registered.present, registered.state, registered.signal, registered.tech, registered.registration, registered.bearer, registered.apn],
  [true, 'registered', 31, 'umts', 'roaming', null, ''],
  'cellular parses a registered modem with no bearer'
)

const missing = cellular.parseStatus(simMissing, true)
assertDeepEqual(
  [missing.present, missing.state, missing.failedReason, missing.operatorName, missing.registration, missing.tech],
  [true, 'failed', 'sim-missing', '', '', ''],
  'cellular parses a modem without a SIM, reading -- as empty'
)

const empty = cellular.parseStatus('', true)
assertDeepEqual([empty.installed, empty.daemon, empty.present], [true, true, false], 'cellular reads empty output as no modem')
const garbage = cellular.parseStatus('\u0000\u0001 not mmcli at all\n:::\n{"json": true}\n', true)
assertDeepEqual([garbage.daemon, garbage.present, garbage.state, garbage.signal], [true, false, '', -1], 'cellular survives garbage input')
assertEqual(cellular.parseStatus('error: couldn\'t find modem\n', true).present, false, 'cellular reads the mmcli no-modem error as no modem')
assertEqual(cellular.parseStatus('error: couldn\'t find the ModemManager process in the bus\n', true).daemon, false, 'cellular reads a missing daemon from mmcli')
assertEqual(cellular.parseStatus('', false).installed, false, 'cellular reads a missing mmcli as not installed')

// Signal bars: raw levels at the boundaries, then hysteresis.
assertDeepEqual(
  [0, 9, 10, 29, 30, 49, 50, 69, 70, 100].map(q => cellular.signalLevel(q, -1)),
  [0, 0, 1, 1, 2, 2, 3, 3, 4, 4],
  'cellular maps signal quality to four bars at 10/30/50/70'
)
function levels(samples, start) {
  let level = start === undefined ? -1 : start
  return samples.map(q => (level = cellular.signalLevel(q, level)))
}
assertDeepEqual(levels([48, 45, 40, 30, 20]), [2, 2, 2, 2, 1], 'cellular steps down through a falling signal without bouncing back')
assertDeepEqual(levels([54, 48, 45, 44, 40, 30, 20]), [3, 3, 3, 2, 2, 2, 1], 'cellular holds a bar until the signal clears the threshold by the margin')
assertDeepEqual(levels([49, 51, 49, 51, 50, 48, 52]), [2, 2, 2, 2, 2, 2, 2], 'cellular does not flicker on a signal hovering at a threshold')
assertDeepEqual(levels([51, 49, 51, 46, 54, 55]), [3, 3, 3, 3, 3, 3], 'cellular keeps the higher count hovering just above a threshold')
assertDeepEqual(levels([50, 55, 60, 75, 74, 66, 64]), [3, 3, 3, 4, 4, 4, 3], 'cellular steps up only past threshold plus margin and back down below threshold minus margin')

// State mapping: what the bar draws and what the tooltip says.
function present(raw, level, primary) {
  const s = cellular.parseStatus(raw, true)
  return cellular.presentation(s, level === undefined ? cellular.signalLevel(s.signal, -1) : level, primary || '')
}
let view = present(connected, undefined, 'wwp0s20f0u5u3i1')
assertDeepEqual(
  [view.kind, view.visual, view.level, view.crossed, view.badge, view.connected, view.canToggle, view.title, view.tech],
  ['connected', 'normal', 3, false, '', true, true, 'beeline', 'LTE'],
  'cellular draws a connected primary link at full color'
)
assertEqual(view.tooltip, 'beeline · LTE\nConnected · 54% signal', 'cellular tooltip names operator, technology, state and signal')

view = present(connected, undefined, 'wlan0')
assertDeepEqual([view.kind, view.visual], ['connected', 'dimmed'], 'cellular dims a connected link that is not the default route')
assertEqual(view.tooltip, 'beeline · LTE\nConnected · 54% signal\nNot the primary connection', 'cellular tooltip says when another connection is primary')

view = present(registeredOnly)
assertDeepEqual(
  [view.kind, view.visual, view.level, view.roaming, view.badge, view.connected, view.canToggle],
  ['registered', 'dimmed', 2, true, 'R', false, true],
  'cellular dims a registered link without data and badges roaming'
)
assertEqual(view.tooltip, 'Vodafone · 3G\nRegistered, no data · 31% signal · Roaming', 'cellular tooltip for a roaming registration without data')
view = present(registeredOnly.replace(': registered', ': connecting'))
assertDeepEqual(
  [view.kind, view.visual, view.transition, view.canToggle, view.statusText],
  ['registered', 'dimmed', 'connecting', false, 'Connecting…'],
  'cellular marks a link that is still connecting and holds the data switch'
)

view = present(simMissing)
assertDeepEqual([view.kind, view.visual, view.crossed, view.canToggle], ['sim-missing', 'alarm', true, false], 'cellular raises an alarm for a missing SIM')
assertEqual(view.tooltip, 'Cellular\nNo SIM card', 'cellular tooltip for a missing SIM')

view = present(pinLocked)
assertDeepEqual([view.kind, view.visual, view.badge, view.crossed], ['pin-locked', 'alarm', '!', false], 'cellular raises an alarm for a SIM waiting for its PIN')
assertEqual(view.tooltip, 'Cellular\nSIM PIN required', 'cellular tooltip for a PIN-locked SIM')
assertEqual(present(pinLocked.replace('sim-pin\n', 'sim-puk\n')).statusText, 'SIM PUK required', 'cellular names a PUK lock')
assertEqual(present(connected).kind, 'connected', 'cellular ignores sim-pin2 on a connected modem')

view = present(simMissing.replace('sim-missing', 'unknown'))
assertDeepEqual([view.kind, view.visual, view.tooltip], ['failed', 'alarm', 'Cellular\nModem failed'], 'cellular raises an alarm for a failed modem')
assertEqual(present(simMissing.replace('sim-missing', 'sim-error')).statusText, 'Modem failed: sim-error', 'cellular names the failure reason')

view = present(registeredOnly.replace('registered', 'disabled'))
assertDeepEqual([view.kind, view.visual, view.crossed], ['disabled', 'dimmed', true], 'cellular crosses out a disabled modem without alarm')
view = present(registeredOnly.replace(': registered', ': searching').replace(': roaming', ': searching'))
assertDeepEqual([view.kind, view.visual, view.statusText], ['searching', 'dimmed', 'Searching for network'], 'cellular dims a modem searching for a network')

view = cellular.presentation(cellular.parseStatus('error: couldn\'t find modem', true), 0, '')
assertDeepEqual([view.kind, view.visual, view.crossed, view.tooltip], ['no-modem', 'dimmed', true, 'No modem'], 'cellular shows a missing modem dimmed and crossed')
assertEqual(cellular.presentation(cellular.parseStatus('', false), 0, '').visual, 'hidden', 'cellular hides without ModemManager installed')
assertEqual(cellular.presentation(cellular.parseStatus('error: couldn\'t find the ModemManager process in the bus', true), 0, '').visual, 'hidden', 'cellular hides while ModemManager is not running')

const tr = (key, english) => '[' + key + ']'
view = cellular.presentation(cellular.parseStatus(simMissing, true), 0, '', tr)
assertEqual(view.tooltip, '[cellular.title]\n[cellular.simMissing]', 'cellular translates its tooltip through tr')
assertEqual(cellular.registrationLabel('home', tr), '[cellular.registrationHome]', 'cellular translates the registration label')
assertEqual(cellular.registrationLabel('roaming-sms-only'), 'Roaming', 'cellular labels every roaming registration as roaming')

// The gdbus stream: signal quality is applied in place, stats are dropped,
// and everything else costs one read.
assertDeepEqual(
  cellular.classifyMonitorLine("/org/freedesktop/ModemManager1/Modem/1: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Modem', {'SignalQuality': <(uint32 48, true)>}, @as [])"),
  { kind: 'signal', quality: 48 },
  'cellular reads signal quality straight off the monitor stream'
)
assertEqual(
  cellular.classifyMonitorLine("/org/freedesktop/ModemManager1/Bearer/1: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Bearer', {'Stats': <{'duration': <uint32 2790>, 'rx-bytes': <uint64 0>, 'tx-bytes': <uint64 0>, 'start-date': <uint64 1794651728>, 'attempts': <uint32 4>, 'failed-attempts': <uint32 0>, 'total-duration': <uint32 4705>, 'total-rx-bytes': <uint64 0>, 'total-tx-bytes': <uint64 0>}>}, @as [])").kind,
  'ignore',
  'cellular drops periodic bearer stats'
)
assertEqual(
  cellular.classifyMonitorLine("/org/freedesktop/ModemManager1/Modem/1: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.ModemManager1.Modem', {'State': <11>, 'SignalQuality': <(uint32 48, true)>}, @as [])").kind,
  'refresh',
  'cellular reads the modem again when state changes alongside the signal'
)
assertEqual(
  cellular.classifyMonitorLine("/org/freedesktop/ModemManager1: org.freedesktop.DBus.ObjectManager.InterfacesAdded (objectpath '/org/freedesktop/ModemManager1/Modem/2', {})").kind,
  'refresh',
  'cellular reads again when a modem appears'
)
assertDeepEqual(cellular.classifyMonitorLine('The name org.freedesktop.ModemManager1 is owned by :1.7760'), { kind: 'owner', present: true }, 'cellular notices ModemManager on the bus')
assertDeepEqual(cellular.classifyMonitorLine('The name org.freedesktop.ModemManager1 does not have an owner'), { kind: 'owner', present: false }, 'cellular notices ModemManager leaving the bus')
assertEqual(cellular.classifyMonitorLine('Monitoring signals from all objects owned by org.freedesktop.ModemManager1').kind, 'ignore', 'cellular skips the monitor banner')

// Formatting the panel owns.
assertEqual(cellular.formatBytes(39478369), '37.6 MB', 'cellular formats session bytes')
assertEqual(cellular.formatBytes(512), '512 B', 'cellular formats small byte counts')
assertEqual(cellular.formatBytes(-1), '0 B', 'cellular floors invalid byte counts')
assertEqual(cellular.formatBytes(1536, (v, d) => String(v).replace('.', ',')), '1,5 KB', 'cellular formats bytes through the language formatter')
assertEqual(cellular.parseCounter('39478369\n'), 39478369, 'cellular parses a sysfs counter')
assertEqual(cellular.parseCounter(''), -1, 'cellular reports an unreadable sysfs counter')
assertEqual(cellular.formatUptime(1794651728, 1794651728 + 46 * 60 + 5), '46m', 'cellular formats bearer uptime in minutes')
assertEqual(cellular.formatUptime(1794651728, 1794651728 + 125 * 60), '2h 5m', 'cellular formats bearer uptime in hours')
assertEqual(cellular.formatUptime(0, 1794651728), '', 'cellular has no uptime without a start date')
assertEqual(cellular.techLabel('5gnr'), '5G', 'cellular labels 5G')
assertEqual(cellular.techLabel('unknown'), '', 'cellular leaves unknown technology blank')

// The polling rule in agents/skills/shell-dev.md: one long-running monitor,
// no repeating timer that reaches mmcli, and nothing spawned per monitor.
assert(/command: \["gdbus", "monitor", "--system", "--dest", "org\.freedesktop\.ModemManager1"\]/.test(serviceSource), 'cellular service watches ModemManager with one gdbus monitor')
const timers = serviceSource.match(/Timer \{[\s\S]*?\n  \}/g) || []
assert(timers.length > 0, 'cellular service timers are found')
for (const timer of timers) {
  if (!/repeat: true/.test(timer)) continue
  assert(!/reader|refresh\(|mmcli|Process|\.running = true/.test(timer), 'cellular repeating timers never start a process', timer)
  assert(/running: root\.openPanels > 0/.test(timer), 'cellular repeating timer runs only while a panel is open', timer)
}
assert(/onWantedChanged[\s\S]*?monitor\.running = false/.test(serviceSource), 'cellular service stops the monitor when no widget holds it')
assert(/firstPartyServiceFor\("omarchy\.cellular"\)/.test(panelSource), 'cellular widget reaches the shared service through firstPartyServiceFor')
assert(!/\bTimer \{|\bProcess \{/.test(panelSource), 'cellular widget starts no timers or processes of its own')
assert(/heldService\.acquire\(\)/.test(panelSource) && /heldService\.release\(\)/.test(panelSource), 'cellular widget holds and releases the service')
JS
