#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const styleSource = fs.readFileSync(root + '/shell/Commons/Style.qml', 'utf8')
const shellJson = fs.readFileSync(root + '/config/omarchy/shell.json', 'utf8')

// A platform package's cutout description, as it would ship it.
const cutouts = bar.parseCutouts(JSON.stringify({ panels: [
  { connector: 'eDP', width: 3024, height: 1964, top: 64 },
  { connector: 'eDP', width: 2560, height: 1664, top: 56 }
] }))
assertEqual(cutouts.length, 2, 'a well-formed description yields its panels')

// Malformed descriptions and entries are dropped, never guessed at.
for (const text of ['', 'not json', '[]', '{}', '{"panels": {}}'])
  assertDeepEqual(bar.parseCutouts(text), [], `an unusable description (${JSON.stringify(text)}) yields no cutouts`)
assertDeepEqual(bar.parseCutouts(JSON.stringify({ panels: [
  { width: 3024, height: 1964, top: 64 },
  { connector: '', width: 3024, height: 1964, top: 64 },
  { connector: 'eDP', width: 0, height: 1964, top: 64 },
  { connector: 'eDP', width: 3024, height: 1964, top: 0 },
  { connector: 'eDP', width: 3024, height: 1964, top: 1964 },
  null
] })), [], 'entries without a connector, a size or a sensible cutout are dropped')

// A cutout is described in physical rows; the bar works in logical pixels at
// any scale. Hyprland reports each output's physical mode, as hyprctl monitors
// does; Qt's devicePixelRatio is a whole number even at a fractional scale.
const mode = (width, height, transform = 0) => ({ width, height, transform })
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1512, 982, 2, mode(3024, 1964)), 32, 'a 64-row cutout is 32 px at scale 2')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 3024, 1964, 1, mode(3024, 1964)), 64, 'scale 1 uses the rows as they are')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1280, 832, 2, mode(2560, 1664)), 28, 'each described panel gets its own cutout')

// A 16" MacBook Pro panel at scale 1.33: Qt says 2, Hyprland says 3456x2234.
const pro16 = [{ connector: 'eDP', width: 3456, height: 2234, top: 64 }]
assertEqual(bar.cutoutTop(pro16, 'eDP-1', 2592, 1676, 2, mode(3456, 2234)), 48, 'a fractional scale matches its panel by the mode Hyprland reports')
assertEqual(bar.notchFloor(pro16, 'top', 'eDP-1', 2592, 1676, 2, mode(3456, 2234), 0), 48, 'a top bar at a fractional scale floors at the cutout')
assertEqual(bar.centerBesideRight(pro16, 'top', 'eDP-1', 2592, 1676, 2, mode(3456, 2234)), true, 'a top bar at a fractional scale moves the center section')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1890, 1228, 2, mode(3024, 1964)), 40, 'scale 1.6 matches too')

// Until Hyprland answers, the logical size times Qt's ratio stands in for the
// mode, which holds at whole scales only.
for (const pending of [null, undefined, {}, mode(0, 0)])
  assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1512, 982, 2, pending), 32, `a whole scale matches before Hyprland reports the mode (${JSON.stringify(pending)})`)
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 3024, 1964, 0, null), 64, 'a missing scale reads as 1')
assertEqual(bar.cutoutTop(pro16, 'eDP-1', 2592, 1676, 2, null), 0, 'a fractional scale finds nothing on Qt\'s ratio alone')

// A mode Hyprland reports is the answer: one no panel describes has no cutout,
// whatever the logical size times the ratio would say.
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1512, 982, 2, mode(3024, 1890)), 0, 'the same panel with its cutout rows hidden has none')
assertEqual(bar.cutoutTop(cutouts, 'DP-1', 1512, 982, 2, mode(3024, 1964)), 0, 'another connector with the same mode has none')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1728, 1117, 2, mode(3456, 2234)), 0, 'a panel nobody described has none')
assertEqual(bar.cutoutTop([], 'eDP-1', 1512, 982, 2, mode(3024, 1964)), 0, 'with no description no panel has a cutout')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 0, 0, 2, mode(3024, 1964)), 0, 'degenerate screen sizes have none')

// Turned a quarter or upside down, the cutout is on another edge; mirrored,
// it is still at the top.
for (const transform of [1, 2, 3, 5, 6, 7])
  assertEqual(bar.cutoutTop(cutouts, 'eDP-1', transform % 2 ? 982 : 1512, transform % 2 ? 1512 : 982, 2, mode(3024, 1964, transform)), 0, `a panel with transform ${transform} has no cutout at its top`)
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 1512, 982, 2, mode(3024, 1964, 4)), 32, 'a mirrored panel keeps its cutout at the top')
assertEqual(bar.cutoutTop(cutouts, 'eDP-1', 982, 1512, 2, mode(3024, 1964)), 0, 'a portrait screen on a landscape mode is turned, whatever its transform says')

// Only a top bar on a described panel has a floor; a calibrated [bar]
// notch-height replaces the described value there and nowhere else.
assertEqual(bar.notchFloor(cutouts, 'top', 'eDP-1', 1512, 982, 2, mode(3024, 1964), 0), 32, 'a top bar floors at the cutout')
for (const position of ['bottom', 'left', 'right'])
  assertEqual(bar.notchFloor(cutouts, position, 'eDP-1', 1512, 982, 2, mode(3024, 1964), 0), 0, `a ${position} bar has no floor`)
assertEqual(bar.notchFloor(cutouts, 'top', 'eDP-1', 1512, 982, 2, mode(3024, 1964), 36), 36, 'a calibrated notch-height overrides the described floor')
assertEqual(bar.notchFloor(cutouts, 'top', 'DP-1', 2560, 1440, 1, mode(2560, 1440), 36), 0, 'a calibrated notch-height never floors an external monitor')
assertEqual(bar.notchFloor([], 'top', 'eDP-1', 1512, 982, 2, mode(3024, 1964), 36), 0, 'a calibrated notch-height never floors a panel without a cutout')
assertEqual(bar.notchFloor(cutouts, 'top', 'eDP-1', 1512, 982, 2, mode(3024, 1964), 'x'), 32, 'an unreadable calibration falls back to the described floor')

// Source wiring only (no Quickshell here): the bar reads the description from
// the fixed platform root, which no environment variable moves, not from a
// detector.
assert(
  /path: "\/usr\/share\/omarchy-platform\/display-cutouts\.json"/.test(barSource) &&
    /readonly property var displayCutouts: displayCutoutsFile\.missing \? \[\] : BarModel\.parseCutouts\(displayCutoutsFile\.text\(\)\)/.test(barSource),
  'bar reads the platform package\'s cutout description from the platform root'
)
assert(
  /id: displayCutoutsFile[\s\S]{0,400}blockLoading: true[\s\S]{0,200}onLoadFailed: missing = true/.test(barSource),
  'bar reads the description as the shell starts, before its surfaces map, and a removed file describes nothing'
)
assert(!/_PACKAGED_PATH|packagedPath/.test(barSource), 'no environment variable moves the cutout description')
assert(!/omarchy-hw-/.test(barSource), 'bar asks no hardware detector')
assert(
  /BarModel\.notchFloor\(root\.displayCutouts, root\.position, screen\.name, screen\.width, screen\.height, screen\.devicePixelRatio, root\.panelModeFor\(screen\), Style\.bar\.notchHeight\)/.test(barSource),
  'bar derives the floor from its own screen geometry, its mode and the calibration'
)
assert(
  /function panelModeFor\(screen\) \{\s*var monitor = screen \? Hyprland\.monitorFor\(screen\) : null\s*return monitor \? \(\{\s*width: monitor\.width,\s*height: monitor\.height,\s*transform: monitor\.lastIpcObject \? monitor\.lastIpcObject\.transform : 0\s*\}\) : null/.test(barSource) &&
    /readonly property var panelMode: root\.panelModeFor\(screen\)/.test(barSource),
  'bar takes its screen\'s physical mode from Hyprland'
)
assert(
  /function thicknessFor\(screen\) \{\s*if \(root\.vertical \|\| !screen\) return root\.barSize\s*return Math\.max\(root\.barSize, BarModel\.notchFloor\(/.test(barSource) &&
    /readonly property int thickness: root\.thicknessFor\(screen\)/.test(barSource) &&
    /implicitHeight: root\.vertical \? 0 : thickness/.test(barSource),
  'bar height is floored at the cutout, never shrunk to it'
)
// A hidden bar parks by that same thickness (bar-test.sh), so a floored top
// bar leaves no strip of itself on screen.

// The calibration must not scale with the font: it describes physical pixels
// beside the camera.
assert(
  /notchHeight:[\s\S]{0,240}barOverrides\["notch-height"\]/.test(styleSource) &&
    !/barToken\("notch-height"/.test(styleSource),
  'notch-height is read raw, not through the font-scaled bar tokens'
)

// A top bar on a described panel draws its center section beside the right
// one; everything else keeps the configured layout.
for (const scale of [1, 2])
  assertEqual(bar.centerBesideRight(cutouts, 'top', 'eDP-1', 3024 / scale, 1964 / scale, scale, mode(3024, 1964)), true, `a described panel at scale ${scale} moves the center section`)
assertEqual(bar.centerBesideRight(cutouts, 'top', 'USB-2', 3440, 1440, 1, mode(3440, 1440)), false, 'an external monitor keeps the center section')
assertEqual(bar.centerBesideRight([], 'top', 'eDP-1', 1512, 982, 2, mode(3024, 1964)), false, 'a machine without a description keeps the center section')
for (const position of ['bottom', 'left', 'right'])
  assertEqual(bar.centerBesideRight(cutouts, position, 'eDP-1', 1512, 982, 2, mode(3024, 1964)), false, `a ${position} bar keeps the center section`)

// The move is per screen and draw-time only: the user's layout is read as
// configured, and the center entries keep their order and their own region.
assert(
  /centerBesideRight: BarModel\.centerBesideRight\(root\.displayCutouts, root\.position, screen\.name, screen\.width, screen\.height, screen\.devicePixelRatio, panelMode\)/.test(barSource),
  'each bar surface decides the move from its own screen'
)
assert(
  /CenterModules \{\s*anchors\.fill: parent\s*entries: barWindow\.centerBesideRight \? \[\] : root\.layoutEntries\("center"\)\s*\}/.test(barSource),
  'a moved center section draws nothing in the middle of the bar'
)
assert(
  /ModuleList \{\s*entries: barWindow\.centerBesideRight \? root\.layoutEntries\("center"\) : \[\]\s*region: "center"\s*anchors\.right: rightModules\.left\s*anchors\.rightMargin: Style\.space\(\d+\)/.test(barSource),
  'the center entries sit just left of the right section in their own region'
)

// With no gap the last center slot and the first right slot would share an
// edge, and a drop there would always land in whichever registered first.
const seam = [
  { slot: 'right-first', x: 104, width: 20 },
  { slot: 'center-last', x: 80, width: 20 }
]
assertDeepEqual(bar.nearestDropTarget(seam, { x: 101 }, false), { slot: 'center-last', after: true }, 'a drop at the seam nearer the center section lands after its last entry')
assertDeepEqual(bar.nearestDropTarget(seam, { x: 103 }, false), { slot: 'right-first', after: false }, 'a drop at the seam nearer the right section lands before its first entry')
assert(
  /anchorEntry: root\.findCenterAnchorEntry\(entries\)/.test(barSource),
  'an emptied center section does not keep a hidden copy of its anchor'
)

// Until Hyprland reports the mode, a top bar waits to map where the mode may
// still bring a cutout: a described connector whose whole-scale rebuild
// matched nothing, as at a fractional scale. It never guesses a floor there.
assertEqual(bar.cutoutPending(pro16, 'top', 'eDP-1', 2592, 1676, 2, null), true, 'a fractional scale on a described connector waits for the mode')
for (const pending of [undefined, {}, mode(0, 0)])
  assertEqual(bar.cutoutPending(pro16, 'top', 'eDP-1', 2592, 1676, 2, pending), true, `no mode yet (${JSON.stringify(pending)}) still waits`)
assertEqual(bar.notchFloor(pro16, 'top', 'eDP-1', 2592, 1676, 2, null, 0), 0, 'a waiting bar has no guessed floor')
assertEqual(bar.cutoutPending(pro16, 'top', 'eDP-1', 2592, 1676, 2, mode(3456, 2234)), false, 'the mode ends the wait')
assertEqual(bar.cutoutPending(pro16, 'top', 'eDP-1', 1728, 1117, 2, mode(3456, 2160)), false, 'a mode no panel describes ends the wait too')
assertEqual(bar.cutoutPending(cutouts, 'top', 'eDP-1', 1512, 982, 2, null), false, 'a whole scale that matches needs no wait')
assertEqual(bar.cutoutPending(cutouts, 'top', 'DP-1', 2560, 1440, 1, null), false, 'a connector no entry names never waits')
assertEqual(bar.cutoutPending([], 'top', 'eDP-1', 2592, 1676, 2, null), false, 'without a description nothing waits')
for (const position of ['bottom', 'left', 'right'])
  assertEqual(bar.cutoutPending(pro16, position, 'eDP-1', 2592, 1676, 2, null), false, `a ${position} bar never waits`)
assert(
  /readonly property bool cutoutPending: BarModel\.cutoutPending\(root\.displayCutouts, root\.position, screen\.name, screen\.width, screen\.height, screen\.devicePixelRatio, panelMode\)/.test(barSource) &&
    /visible: !remapGuard\.remapping && \(cutoutWaitOver \|\| !cutoutPending\)/.test(barSource),
  'a bar surface maps only once its floor is known, and still remaps on a screen move'
)
assert(
  /property bool cutoutWaitOver: false\s*onCutoutPendingChanged: if \(!cutoutPending\) cutoutWaitOver = true\s*Component\.onCompleted: if \(!cutoutPending\) cutoutWaitOver = true/.test(barSource) &&
    /Timer \{\s*interval: 2000\s*running: barWindow\.cutoutPending && !barWindow\.cutoutWaitOver\s*onTriggered: barWindow\.cutoutWaitOver = true\s*\}/.test(barSource),
  'the wait ends once, for good: when the mode settles it or after two seconds'
)

// Toasts and plugins clear the bar as thick as it is on their screen. The bar
// publishes each screen's thickness by name from the same calculation its
// surfaces use; barSize stays the configured size the widgets are drawn at.
const sizes = { 'eDP-1': 40, 'DP-1': 26 }
assertEqual(bar.barSizeFor(sizes, 'eDP-1', 26), 40, 'a notch screen reports its floored thickness')
assertEqual(bar.barSizeFor(sizes, 'DP-1', 26), 26, 'another screen reports its own')
assertEqual(bar.barSizeFor(sizes, 'HDMI-A-1', 26), 26, 'a screen without a surface falls back to the configured size')
assertEqual(bar.barSizeFor({}, 'eDP-1', 26), 26, 'no published sizes fall back to the configured size')
assertEqual(bar.barSizeFor(sizes, 'constructor', 26), 26, 'inherited object keys are no screen')
assert(
  /readonly property var screenBarSizes: \{\s*var sizes = \(\{\}\)\s*var screens = Quickshell\.screens\s*for \(var i = 0; i < screens\.length; i\+\+\) sizes\[screens\[i\]\.name\] = root\.thicknessFor\(screens\[i\]\)\s*return sizes\s*\}/.test(barSource) &&
    /function barSizeFor\(screenName\) \{\s*return BarModel\.barSizeFor\(root\.screenBarSizes, screenName, root\.barSize\)\s*\}/.test(barSource),
  'bar publishes every screen\'s thickness from the same calculation its surfaces use'
)
assert(
  /readonly property int barSize: vertical \? Style\.bar\.sizeVertical : Style\.bar\.sizeHorizontal/.test(barSource),
  'barSize stays the configured size'
)

// The plugin facade copies the sizes, holding no reference into the bar, and
// keeps barSize the configured size.
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
const stateApiSource = fs.readFileSync(root + '/shell/services/PluginBarStateApi.qml', 'utf8')
const extract = (source, name) => {
  const match = source.match(new RegExp(`function ${name}\\((\\w+)\\) \\{([\\s\\S]*?)\\n  \\}\\n`))
  assert(match, `${name} is defined`)
  return match
}
const detached = extract(shellSource, 'detachedBarSizes')
const Util = { isPlainObject: value => value !== null && typeof value === 'object' && !Array.isArray(value) }
const detachedBarSizes = new Function('Util', detached[1], detached[2])
const live = { 'eDP-1': 40, 'DP-1': 26, broken: 'x', none: 0 }
const copy = detachedBarSizes.call(null, Util, live)
assertDeepEqual(copy, { 'eDP-1': 40, 'DP-1': 26 }, 'the plugin facade copies each screen\'s thickness')
assert(copy !== live, 'the copy is detached from the bar\'s map')
assertDeepEqual(detachedBarSizes.call(null, Util, undefined), {}, 'a bar without per-screen sizes gives an empty map')
assert(
  /api\.barSize = Qt\.binding\(function\(\) \{ return shell\.bar \? Math\.max\(0, shell\.bar\.barSize \|\| 0\) : 0 \}\)/.test(shellSource) &&
    /api\.barSizes = Qt\.binding\(function\(\) \{ return shell\.bar \? shell\.detachedBarSizes\(shell\.bar\.screenBarSizes\) : \(\{\}\) \}\)/.test(shellSource),
  'plugins get the configured barSize and every screen\'s thickness'
)
const apiFor = extract(stateApiSource, 'barSizeFor')
const stateBarSizeFor = new Function('barSizes', 'barSize', apiFor[1], apiFor[2])
assertEqual(stateBarSizeFor(copy, 26, 'eDP-1'), 40, 'a plugin reads a notch screen\'s thickness')
assertEqual(stateBarSizeFor(copy, 26, 'HDMI-A-1'), 26, 'a plugin falls back to barSize for a screen with none')
assertEqual(stateBarSizeFor({}, 26, 'eDP-1'), 26, 'a plugin under a bar without per-screen sizes gets barSize')

const parsed = JSON.parse(shellJson)
assertEqual(parsed.bar.centerAnchor, 'omarchy.clock', 'shipped bar layout still anchors on the clock')
assert(
  JSON.stringify(parsed.bar.layout.center).indexOf('omarchy.indicators') >= 0,
  'shipped bar layout still keeps the default center widgets'
)
JS
