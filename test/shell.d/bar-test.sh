#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The command fixture follows the runtime invariant and reads defaults through
# OMARCHY_PATH. Point it at this checkout rather than whichever install launched
# the test (or nothing at all on a non-Omarchy development machine).
export OMARCHY_PATH="$ROOT"

if perl -0ne 'exit(/drag\s*\.\s*target\s*:\s*[^;]*\bslot\b/s ? 0 : 1)' "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar module dragging must not mutate ModuleSlot positions"
fi
pass "bar module dragging leaves layout-managed slots in place"

if rg -q 'barMoveSettling|barMoveSettleTimer' "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar move outline must clear when the pointer is released"
fi
pass "bar move outline has no post-release settling state"

# A widget above the gesture area propagates its composed press-and-hold down
# without handing over the grab, so the resulting move gets neither a release
# nor a cancel and the ghost stays up for the session. Only the grabbing area
# reports pressed, which is what separates the two, so the guard has to stay
# ahead of the drag.
if ! perl -0ne 'exit(/onPressAndHold:\s*function[^{]*\{[^}]*?\bpressed\b[^}]*?\bstartDrag\b/s ? 0 : 1)' \
  "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar move ignores a press-and-hold the gesture area does not hold the press for"
fi
pass "bar move ignores a press-and-hold propagated from a widget above"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

assert(/function toggleBarTransparency\(\): string \{[\s\S]*?shell\.bar\.toggleTransparency\(\)/.test(shellSource), 'shell exposes the bar transparency toggle over IPC')
assert(/function toggleBarPills\(\): string \{[\s\S]*?shell\.bar\.togglePills\(\)/.test(shellSource), 'shell exposes the bar pills toggle over IPC')
assert(/function toggleBarFloating\(\): string \{[\s\S]*?shell\.bar\.toggleFloating\(\)/.test(shellSource), 'shell exposes the bar floating toggle over IPC')

// A right button held past pressAndHoldInterval never reports a click, so the
// bar options open on press.
const gestureSource = barSource.slice(barSource.indexOf('component CenterGestureArea'))
assert(
  /onPressed: function\(mouse\) \{[\s\S]*?if \(mouse\.button === Qt\.RightButton\) \{\s*if \(dragging \|\| \(mouse\.buttons & Qt\.LeftButton\)\) \{\s*if \(!\(gestureArea\.pressedButtons & Qt\.LeftButton\)\) mouse\.accepted = false\s*return\s*\}\s*if \(menuOpen\) menuOpen = false\s*else if \(!openMenu\(mouse\.x, mouse\.y\)\) mouse\.accepted = false\s*return\s*\}\s*menuOpen = false\s*dragging = false/.test(gestureSource) &&
  /onReleased: function\(mouse\) \{\s*if \(mouse\.button === Qt\.RightButton\) return\s*if \(!dragging\) return/.test(gestureSource),
  'a right press opens or closes the bar options, does nothing during a left press or drag without taking a widget\'s grab, and passes on a press it does not use'
)
assert(
  /var slot = root\.moduleSlotAtScene\(scenePoint, root\.targetWindow\(gestureArea\)\)\s*if \(slot && !root\.inPillGap\(slot, scenePoint\)\) return false/.test(gestureSource),
  'the bar options open only off widgets, gaps between pills included'
)
assert(/onPositionChanged: function\(mouse\) \{\s*if \(!\(mouse\.buttons & Qt\.LeftButton\)\) return/.test(gestureSource), 'only the left button drags the bar')
assert(/function toggleFloating\(\) \{\s*setBarOption\("floating", !floating\)/.test(barSource), 'the floating switch starts from what the bar shows, theme margin included')
assert(/function togglePills\(\) \{\s*setBarOption\("pills", pillsOn \? "off" : lastPillMode\)/.test(barSource) && /onPillModeChanged: if \(pillMode !== "off"\) lastPillMode = pillMode/.test(barSource), 'the pills switch comes back in the last mode used')
assert(/Component\.onCompleted: \{[^}]*if \(pillMode !== "off"\) lastPillMode = pillMode[^}]*applyBarConfig\(\)/.test(barSource), 'a theme\'s default pill mode counts as the last mode used')
assert(/onPressAndHold: function\(mouse\) \{[^}]*?pressedButtons\s*&\s*Qt\.LeftButton[^}]*?startDrag/.test(gestureSource), 'only a left press-and-hold moves the bar')

// put tolerates a placement target the bar does not carry, so the IPC call
// must reach the registry's put rather than route back through enable.
assert(
  /function putBarWidget\(id: string, placementJson: string\): string \{[\s\S]*?shell\.pluginRegistry\.putBarWidget\(/.test(shellSource),
  'putting a bar widget over IPC goes through the registry put'
)

// Hiding must not unmap the bar. An unmapped layer surface has to be rebuilt on
// every reveal, which measured ~150ms against ~20ms to tear it down; parking it
// past the screen edge keeps show and hide symmetric at ~12ms.
assert(
  /visible: !remapGuard\.remapping/.test(barSource),
  'bar stays mapped while hidden so revealing it does not rebuild the surface'
)
assert(
  /exclusionMode: root\.barHidden \? ExclusionMode\.Ignore : \(root\.floatInGap \? ExclusionMode\.Normal : ExclusionMode\.Auto\)/.test(barSource),
  'a hidden bar reserves no space for itself'
)

// Every bar size token is read through barToken(), so the [bar] parser must
// hand every numeric key over instead of naming a few: icon-slot, icon-canvas,
// icon-font and status-slot were silently dropped (#11359). Run the real
// parser and token reader rather than matching their text.
const vm = require('vm')
const styleSource = fs.readFileSync(root + '/shell/Commons/Style.qml', 'utf8')
function qmlFunction(source, name) {
  const start = source.indexOf(`function ${name}(`)
  let depth = 0
  for (let i = source.indexOf('{', start); start >= 0 && i < source.length; i++) {
    if (source[i] === '{') depth++
    else if (source[i] === '}' && --depth === 0) return source.slice(start, i + 1)
  }
  throw new Error(`Style.qml has no function ${name}`)
}
const style = vm.createContext({})
vm.runInContext(
  ['barToken', 'boolToken', 'applyShellValues'].map(name => qmlFunction(styleSource, name)).join('\n') +
  '\nvar fontScale = 1, barScaleWithFont = true, barOverrides = {}',
  style
)
style.applyShellValues({
  'bar.size-horizontal': '32', 'bar.size-vertical': '34', 'bar.icon-slot': '30',
  'bar.icon-canvas': '20', 'bar.icon-font': '17', 'bar.status-slot': '25'
})
for (const [key, value] of [['size-horizontal', 32], ['size-vertical', 34], ['icon-slot', 30],
                            ['icon-canvas', 20], ['icon-font', 17], ['status-slot', 25]]) {
  assertEqual(style.barToken(key, 1), value, `[bar] ${key} in shell.toml reaches barToken()`)
}

// The gap is a width spec, not a scalar, so a bar can sit further off the edges
// it spans than off the one it hangs from. The anchored edge reads out of the
// same object by position name.
assert(
  /Geometry\.parseWidthSpec\(barOverrides\["margin"\], 0\)/.test(styleSource),
  'the bar margin is parsed as a per-edge width spec'
)
assert(
  /barOut\[key\] = raw/.test(styleSource),
  'the bar margin reaches the parser unparsed, so a list survives'
)
// The drag overlays are full-screen, so a bar-local point becomes a screen point
// by adding the bar window's origin. A detached bar's origin is the gap itself on the
// axes it spans, and the far edge less its own size and gap on the one it is
// anchored to; without that the drop marker and the drag ghost sit a margin away
// from the cursor.
const windowScreenPoint = barSource.slice(
  barSource.indexOf('function windowScreenPoint'),
  barSource.indexOf('function barDragScreenPoint')
)
assert(
  /var margins = root\.barMargins/.test(windowScreenPoint),
  'mapping a bar point to the screen accounts for a detached bar'
)
assert(
  /window\.screen\.height - window\.height - margins\.bottom/.test(windowScreenPoint),
  'a detached bottom bar maps from its own top edge, not the screen edge'
)
assert(
  /window\.screen\.width - window\.width - margins\.right/.test(windowScreenPoint),
  'a detached right bar maps from its own left edge, not the screen edge'
)

// omarchy-bar-text-color samples the wallpaper under the bar to pick a legible
// transparent-mode foreground. It crops from the screen edge unless told
// otherwise, so a detached bar has to hand it the gap or the contrast is
// decided against pixels the bar does not cover.
const transparentForeground = barSource.slice(
  barSource.indexOf('function refreshTransparentForeground'),
  barSource.indexOf('onRequestedTransparentChanged')
)
assert(
  /"--inset",\s*\n\s*\[root\.barMargins\.top/.test(transparentForeground),
  'transparent bar text samples the strip a detached bar covers'
)
assert(
  /onBarMarginsChanged: scheduleTransparentForegroundRefresh\(\)/.test(barSource),
  'changing the bar margin re-samples the transparent bar text color'
)

// Floating: bar.floating wins when set; unset, a non-zero theme margin floats
// the bar, as it always did. With no theme margin a floating bar takes
// Hyprland's gaps_out, and a flush bar has no margin at all.
const themeMargin = { top: 4, right: 8, bottom: 4, left: 8 }
const noMargin = { top: 0, right: 0, bottom: 0, left: 0 }
const gaps = { top: 12, right: 12, bottom: 12, left: 12 }
assertEqual(bar.barFloating(undefined, noMargin, 'top'), false, 'a bar with no theme margin and no setting is flush')
assertEqual(bar.barFloating(undefined, themeMargin, 'top'), true, 'a theme margin floats the bar when shell.json says nothing')
assertEqual(bar.barFloating(false, themeMargin, 'top'), false, 'bar.floating false keeps the bar flush over a theme margin')
assertEqual(bar.barFloating(true, noMargin, 'top'), true, 'bar.floating true floats the bar without a theme margin')
assertDeepEqual(bar.barMargins(false, themeMargin, gaps, 'top'), noMargin, 'a flush bar has no margin')
assertDeepEqual(bar.barMargins(true, themeMargin, gaps, 'top'), themeMargin, 'a floating bar takes the theme margin as given')
assertDeepEqual(bar.barMargins(true, noMargin, gaps, 'top'), { top: 6, right: 12, bottom: 12, left: 12 }, 'a default floating top bar sits half of gaps_out from the edge, full gaps_out at its ends')
assertDeepEqual(bar.barMargins(true, noMargin, gaps, 'left'), { top: 12, right: 12, bottom: 12, left: 6 }, 'a default floating left bar halves the left gap')
assertDeepEqual(bar.barMargins(true, noMargin, noMargin, 'top'), noMargin, 'zero gaps give a floating bar no margin')
// Uneven gaps and margins, every edge: the anchored edge takes half its own
// gap, the others keep theirs, and a theme margin is used as given.
const unevenGaps = { top: 10, right: 14, bottom: 18, left: 22 }
const unevenTheme = { top: 3, right: 7, bottom: 11, left: 13 }
for (const edge of ['top', 'right', 'bottom', 'left']) {
  const expected = Object.assign({}, unevenGaps, { [edge]: Math.round(unevenGaps[edge] / 2) })
  assertDeepEqual(bar.barMargins(true, noMargin, unevenGaps, edge), expected, `a default floating ${edge} bar halves only its own gap`)
  assertDeepEqual(bar.barMargins(true, unevenTheme, unevenGaps, edge), unevenTheme, `a floating ${edge} bar takes an uneven theme margin as given`)
}
assertEqual(bar.barRadius(false, 8, 12, 26), 0, 'a flush bar stays square whatever the theme radius')
assertEqual(bar.barRadius(true, undefined, 12, 26), 12, 'a floating bar follows Hyprland rounding when the theme sets none')
assertEqual(bar.barRadius(true, 4, 12, 26), 4, 'a theme radius overrides Hyprland rounding on a floating bar')
assertEqual(bar.barRadius(true, 0, 12, 26), 0, 'a theme radius of 0 keeps a floating bar square')
assertEqual(bar.barRadius(true, 40, 12, 26), 13, 'the radius is capped at half the bar thickness')
assertEqual(bar.floatsInGap(true, noMargin, 'top'), true, 'the default floating bar keeps the windows where they are')
assertEqual(bar.floatsInGap(true, themeMargin, 'top'), false, 'a theme margin is reserved on top of the bar')
assertEqual(bar.floatsInGap(false, noMargin, 'top'), false, 'a flush bar reserves as it always has')
// Only the edges a bar touches take a margin, so a theme margin on the far
// side alone neither floats the bar nor stops it floating in the gap.
const farOnly = { top: 0, right: 0, bottom: 10, left: 0 }
assertEqual(bar.barFloating(undefined, farOnly, 'top'), false, 'a margin only on the far side leaves a top bar flush')
assertEqual(bar.barFloating(undefined, farOnly, 'bottom'), true, 'the same margin floats a bottom bar, whose edge it is')
assertEqual(bar.barFloating(undefined, farOnly, 'left'), true, 'the same margin floats a side bar, which spans that edge')
assertEqual(bar.floatsInGap(true, farOnly, 'top'), true, 'a top bar switched to floating over a far-side margin floats in the gap')
assertDeepEqual(bar.barMargins(true, farOnly, gaps, 'top'), { top: 6, right: 12, bottom: 12, left: 12 }, 'and takes the gap margins, not the far-side theme margin')
assert(/BarModel\.barFloating\(floatingSetting, Style\.bar\.margins, position\)/.test(barSource) && /BarModel\.floatsInGap\(floating, Style\.bar\.margins, position\)/.test(barSource), 'the bar asks the floating rules for its own edge')
// A flush bar must not depend on Hyprland's gaps at all: a gaps refresh
// would otherwise re-run everything that watches barMargins.
assert(
  /readonly property var barMargins: floating \? BarModel\.barMargins\(true, Style\.bar\.margins, Style\.gapsOutEdges, position\) : BarModel\.NO_MARGINS/.test(barSource),
  'the bar takes its margins from the floating rules, and none while flush'
)

// Window margins: only the edges the bar touches take a gap, and a hidden bar
// parks past its anchored edge, clearing its margin as well as its own size,
// or the margin leaves a sliver of it on screen.
const inGapTop = { top: 6, right: 12, bottom: 12, left: 12 }
assertDeepEqual(bar.windowMargins('top', noMargin, 26, false), noMargin, 'a flush bar window has no margins')
assertDeepEqual(bar.windowMargins('top', inGapTop, 26, false), { top: 6, right: 12, bottom: 0, left: 12 }, 'a floating top bar is inset at its edge and both ends, not at its far face')
assertDeepEqual(bar.windowMargins('left', { top: 12, right: 12, bottom: 12, left: 6 }, 28, false), { top: 12, right: 0, bottom: 12, left: 6 }, 'a floating left bar is inset at its edge and both ends')
const unevenWindow = {
  top: { top: 3, right: 7, bottom: 0, left: 13 },
  bottom: { top: 0, right: 7, bottom: 11, left: 13 },
  left: { top: 3, right: 0, bottom: 11, left: 13 },
  right: { top: 3, right: 7, bottom: 11, left: 0 }
}
for (const edge of ['top', 'bottom', 'left', 'right']) {
  assertDeepEqual(bar.windowMargins(edge, unevenTheme, 26, false), unevenWindow[edge], `a floating ${edge} bar window takes each touching edge's own margin`)
  assertEqual(bar.windowMargins(edge, noMargin, 26, true)[edge], -26, `a hidden flush bar parks past the ${edge} edge`)
  assertEqual(bar.windowMargins(edge, themeMargin, 26, true)[edge], -(26 + themeMargin[edge]), `a hidden floating bar parks past the ${edge} edge, margin included`)
}

// Hyprland reserves the zone plus the anchored margin, so a bar floating in
// the gap reserves exactly what a flush bar does.
assertEqual(bar.exclusiveZone(false, 26, noMargin, 'top'), 26, 'a flush bar reserves its size')
assertEqual(bar.exclusiveZone(false, 26, themeMargin, 'top'), 26, 'a theme margin is reserved on top of the bar size')
assertEqual(bar.exclusiveZone(true, 26, inGapTop, 'top') + inGapTop.top, 26, 'a bar floating in the gap reserves what a flush bar reserves')
assertEqual(bar.exclusiveZone(true, 26, { top: 40, right: 80, bottom: 80, left: 80 }, 'top'), 1, 'the zone stays positive once the edge margin reaches the bar size')
for (const edge of ['top', 'right', 'bottom', 'left']) {
  assertEqual(bar.exclusiveZone(true, 26, unevenTheme, edge) + unevenTheme[edge], 26, `a ${edge} bar floating in the gap reserves what a flush bar reserves`)
}
// Quickshell's exclusiveZone setter also sets exclusionMode to Normal, so the
// zone is written only while the bar floats in the gap and is visible.
assert(
  !/^    exclusiveZone:/m.test(barSource) &&
  /Binding \{\s*target: barWindow\s*property: "exclusiveZone"\s*when: root\.floatInGap && !root\.barHidden\s*value: BarModel\.exclusiveZone\(true, root\.barSize, root\.barMargins, root\.position\)\s*restoreMode: Binding\.RestoreNone/.test(barSource) &&
  /BarModel\.windowMargins\(root\.position, root\.barMargins, root\.barSize, root\.barHidden\)/.test(barSource) &&
  ['top', 'right', 'bottom', 'left'].every(edge => new RegExp(`${edge}: windowMargins\\.${edge}\\b`).test(barSource)),
  'the bar window takes its zone and margins from BarModel, and sets no zone when flush'
)
// The move preview shows the bar where it would land, floating included.
assert(
  /readonly property bool edgeFloating: BarModel\.barFloating\(root\.floatingSetting, Style\.bar\.margins, modelData\)/.test(barSource) &&
  /readonly property var edgeMargins: edgeFloating \? BarModel\.barMargins\(true, Style\.bar\.margins, Style\.gapsOutEdges, modelData\) : BarModel\.NO_MARGINS/.test(barSource) &&
  /x: modelData === "right" \? parent\.width - edgeSize - edgeMargins\.right : edgeMargins\.left/.test(barSource) &&
  /radius: BarModel\.barRadius\(edgeFloating,/.test(barSource),
  'the move preview shows each edge as the bar would float there, margins and radius included'
)
assert(/floatingSetting = typeof config\.floating === "boolean" \? config\.floating : undefined/.test(barSource), 'the bar reads bar.floating from shell.json')
assert(
  /color: "transparent"\s*\n\s*surfaceFormat\.opaque: false/.test(barSource) && /color: root\.transparent \? "transparent" : root\.background\s*\n\s*radius: root\.barRadius/.test(barSource),
  'the background is painted with the bar radius, not by the square window'
)

// gaps_out comes from hyprctl as a CSS-style list; each side is kept. Runs
// the real Style.qml function, in a block so its helpers stay local.
{
  const vm = require('vm')
  const styleFunction = name => {
    const start = styleSource.indexOf(`function ${name}(`)
    let depth = 0
    for (let i = styleSource.indexOf('{', start); start >= 0 && i < styleSource.length; i++) {
      if (styleSource[i] === '{') depth++
      else if (styleSource[i] === '}' && --depth === 0) return styleSource.slice(start, i + 1)
    }
    throw new Error(`Style.qml has no function ${name}`)
  }
  const geometrySource = fs.readFileSync(root + '/shell/Commons/BorderGeometry.js', 'utf8').replace(/^\.pragma library\n/, '')
  const geometry = vm.createContext({})
  vm.runInContext(geometrySource, geometry)
  const gapsStyle = vm.createContext({ Geometry: geometry })
  vm.runInContext(styleFunction('applyGapsOutJson') + '\nvar gapsOut = 5, gapsOutEdges = null', gapsStyle)
  const edges = () => JSON.parse(JSON.stringify(gapsStyle.gapsOutEdges))
  gapsStyle.applyGapsOutJson('{"option":"general:gaps_out","css":"10 20 30 40"}')
  assertDeepEqual(edges(), { top: 10, right: 20, bottom: 30, left: 40 }, 'per-side gaps_out reaches the floating bar')
  gapsStyle.applyGapsOutJson('{"option":"general:gaps_out","css":"12"}')
  assertDeepEqual(edges(), { top: 12, right: 12, bottom: 12, left: 12 }, 'a single gaps_out value applies to every side')
  // [bar] radius is a number like the sizes; margin stays a raw list.
  const parseStyle = vm.createContext({})
  vm.runInContext(['barToken', 'barInsetToken', 'boolToken', 'applyShellValues'].map(styleFunction).join('\n') + '\nvar fontScale = 1, barScaleWithFont = true, barOverrides = {}', parseStyle)
  parseStyle.applyShellValues({ 'bar.radius': '9', 'bar.margin': '4 8' })
  assertEqual(parseStyle.barInsetToken('radius', 0), 9, '[bar] radius in shell.toml reaches the bar')
  assertEqual(parseStyle.barOverrides.margin, '4 8', '[bar] margin reaches the bar as the list it was written as')
  gapsStyle.applyGapsOutJson('not json')
  assertDeepEqual(edges(), { top: 12, right: 12, bottom: 12, left: 12 }, 'unreadable hyprctl output keeps the last gaps')
}

// Popouts and toasts place themselves from the bar's outer face, which a
// floating bar moves off the screen edge. The arithmetic runs by value; the
// QML is checked only for feeding it the bar's margins.
{
  const vm = require('vm')
  const panelGeometry = vm.createContext({})
  vm.runInContext(fs.readFileSync(root + '/shell/Commons/PanelGeometry.js', 'utf8').replace(/^\.pragma library\n/, ''), panelGeometry)
  const flush = { top: 0, right: 0, bottom: 0, left: 0 }
  const inGap = { top: 6, right: 12, bottom: 12, left: 12 }
  const origin = (position, margins, w, h) => JSON.parse(JSON.stringify(panelGeometry.barOrigin(position, margins, w, h, 2000, 1250)))
  assertDeepEqual(origin('top', flush, 2000, 26), { x: 0, y: 0 }, 'a flush top bar starts at the screen corner')
  assertDeepEqual(origin('top', inGap, 1976, 26), { x: 12, y: 6 }, 'a floating top bar starts at its margins')
  assertDeepEqual(origin('bottom', { top: 12, right: 12, bottom: 6, left: 12 }, 1976, 26), { x: 12, y: 1218 }, 'a floating bottom bar ends its margin above the screen edge')
  assertDeepEqual(origin('right', { top: 12, right: 6, bottom: 12, left: 12 }, 28, 1226), { x: 1966, y: 12 }, 'a floating right bar ends its margin left of the screen edge')

  const card = (position, margins, barW, barH, anchor, centerOnBar) => {
    const o = panelGeometry.barOrigin(position, margins, barW, barH, 2000, 1250)
    return JSON.parse(JSON.stringify(panelGeometry.cardOrigin({
      position, centerOnBar: !!centerOnBar, origin: o, barW, barH, anchor,
      width: 300, height: 200, gap: 6, margin: 6, screenW: 2000, screenH: 1250
    })))
  }
  // An icon at x 988..1012 on screen: 976 inside a bar that starts at x 12.
  const icon = { x: 988, y: 1, w: 24, h: 24 }
  assertDeepEqual(card('top', flush, 2000, 26, icon), { x: 850, y: 32 }, 'a flush top bar opens its card gap below the bar, centred on the icon')
  assertDeepEqual(card('top', inGap, 1976, 26, icon), { x: 850, y: 38 }, 'a floating top bar opens its card gap below its outer face, centred on the icon')
  assertDeepEqual(card('top', { top: 6, right: 30, bottom: 12, left: 10 }, 1960, 26, icon, true), { x: 840, y: 38 }, 'a centred card follows the bar, not the screen, with uneven margins')
  assertDeepEqual(card('bottom', { top: 12, right: 12, bottom: 6, left: 12 }, 1976, 26, icon), { x: 850, y: 1012 }, 'a floating bottom bar opens its card gap above its outer face')
  assertDeepEqual(card('left', { top: 12, right: 12, bottom: 12, left: 6 }, 28, 1226, { x: 8, y: 600, w: 20, h: 20 }), { x: 40, y: 510 }, 'a floating left bar opens its card gap right of its outer face')
  assertDeepEqual(card('right', { top: 12, right: 6, bottom: 12, left: 12 }, 28, 1226, { x: 1970, y: 600, w: 20, h: 20 }), { x: 1660, y: 510 }, 'a floating right bar opens its card gap left of its outer face')
  assertDeepEqual(card('top', inGap, 1976, 26, { x: 1980, y: 1, w: 24, h: 24 }), { x: 1694, y: 38 }, 'a card near the screen end stays inside the screen margin')
  assertDeepEqual(card('left', { top: 30, right: 12, bottom: 10, left: 6 }, 28, 1210, { x: 8, y: 600, w: 20, h: 20 }, true), { x: 40, y: 535 }, 'a centred card on a side bar follows the bar, not the screen')
  // Room for a card: across the bar it loses the bar, its edge margin and
  // the reserve; along the bar only the reserve.
  assertEqual(panelGeometry.availableLength(1250, true, 26 + 6, 12, 12), 1206, 'a card below a floating bar loses the bar and its margin')
  assertEqual(panelGeometry.availableLength(1250, true, 26, 12, 12), 1212, 'a card below a flush bar loses the bar')
  assertEqual(panelGeometry.availableLength(2000, false, 26 + 6, 12, 12), 1988, 'a card along the bar loses only the reserve')
  assertEqual(panelGeometry.availableLength(100, true, 26, 12, 12), 120, 'a card keeps at least 120 px')
  assertEqual(panelGeometry.barStripSize(26, 26, 6, 6), 38, 'clicks up to the gap below a floating bar count as the bar')
  assertEqual(panelGeometry.barStripSize(26, 26, 0, 6), 32, 'a flush bar strip is the bar and the gap')

  const panelSource = fs.readFileSync(root + '/shell/Ui/KeyboardPanel.qml', 'utf8')
  assert(
    /readonly property var barMargins: bar && bar\.barMargins \? bar\.barMargins :/.test(panelSource) &&
    /readonly property real barEdgeMargin: barMargins\[barPos\]/.test(panelSource) &&
    /readonly property var barOrigin: PanelGeometry\.barOrigin\(barPos, barMargins, barW, barH, screenW, screenH\)/.test(panelSource) &&
    /readonly property real barX: barOrigin\.x/.test(panelSource) && /readonly property real barY: barOrigin\.y/.test(panelSource) &&
    /return Qt\.point\(p\.x \+ barX, p\.y \+ barY\)/.test(panelSource) &&
    /PanelGeometry\.cardOrigin\(\{[\s\S]*?origin: barOrigin[\s\S]*?anchor: \{ x: anchorScreenPos\.x, y: anchorScreenPos\.y/.test(panelSource) &&
    /PanelGeometry\.barStripSize\(bar\.barSize, actual, root\.barEdgeMargin, root\.gap\)/.test(panelSource) &&
    /PanelGeometry\.availableLength\(screenW, barPos === "left" \|\| barPos === "right", barW \+ barEdgeMargin, gap \+ margin, margin \* 2\)/.test(panelSource) &&
    /PanelGeometry\.availableLength\(screenH, barPos === "top" \|\| barPos === "bottom", barH \+ barEdgeMargin, gap \+ margin, margin \* 2\)/.test(panelSource) &&
    /return Qt\.point\(px - root\.barX, py - root\.barY\)/.test(panelSource),
    'bar popouts place and forward through the bar window origin and margins'
  )

  // Tray menus, the media popup and the bar options size themselves the same way.
  const popupSource = fs.readFileSync(root + '/shell/Ui/PopupCard.qml', 'utf8')
  assert(
    /readonly property real barEdgeMargin: bar && bar\.barMargins \? \(bar\.barMargins\[bar\.position\] \|\| 0\) : 0/.test(popupSource) &&
    /PanelGeometry\.availableLength\(screenW, !!bar && \(bar\.position === "left" \|\| bar\.position === "right"\), barW \+ barEdgeMargin, root\.margin \* 2, root\.margin \* 2\)/.test(popupSource) &&
    /PanelGeometry\.availableLength\(screenH, !!bar && \(bar\.position === "top" \|\| bar\.position === "bottom"\), barH \+ barEdgeMargin, root\.margin \* 2, root\.margin \* 2\)/.test(popupSource),
    'popup cards leave room for a floating bar\'s edge margin'
  )

  const notificationLogic = requireFromRoot('shell/plugins/notifications/NotificationLogic.js')
  assertEqual(notificationLogic.barClearance(26, null, 'top', 6), 32, 'toasts clear a flush or hidden bar by its size and the gap')
  assertEqual(notificationLogic.barClearance(26, inGap, 'top', 6), 38, 'toasts clear a floating top bar\'s edge margin')
  assertEqual(notificationLogic.barClearance(28, { top: 12, right: 6, bottom: 12, left: 12 }, 'right', 6), 40, 'toasts clear a floating right bar\'s edge margin')
  const notificationSource = fs.readFileSync(root + '/shell/plugins/notifications/Service.qml', 'utf8')
  assert(
    /liveBarMargins: shell && shell\.bar && !shell\.bar\.barHidden && shell\.bar\.barMargins \? shell\.bar\.barMargins : null/.test(notificationSource) &&
    /barClearance: NotificationLogic\.barClearance\(liveBarSize, liveBarMargins, barPosition, Style\.gapsOut\)/.test(notificationSource),
    'toasts take the live bar margins'
  )

  // Widgets and plugins that place their own windows get the margins too.
  const pluginApiSource = fs.readFileSync(root + '/shell/Ui/PluginBarApi.qml', 'utf8')
  const stateApiSource = fs.readFileSync(root + '/shell/services/PluginBarStateApi.qml', 'utf8')
  assert(
    /property var barMargins:/.test(pluginApiSource) && /api\.barMargins = Qt\.binding\(function\(\) \{ return root\.barMargins \}\)/.test(barSource),
    'bar widgets get bar.barMargins'
  )
  assert(
    /property var barMargins:/.test(stateApiSource) && /api\.barMargins = Qt\.binding\(function\(\) \{ return shell\.bar && shell\.bar\.barMargins \? shell\.bar\.barMargins :/.test(shellSource),
    'plugins positioning their own windows get shell.bar.barMargins'
  )
}

// The floating switch and the radius reach the bar through these bindings.
assert(/readonly property bool floating: BarModel\.barFloating\(floatingSetting, Style\.bar\.margins, position\)/.test(barSource), 'the floating state comes from bar.floating and the theme margin')
assert(/readonly property int barRadius: BarModel\.barRadius\(\s*floating,\s*Style\.barOverrides\["radius"\] !== undefined \? Style\.bar\.radius : undefined,\s*Style\.cornerRadius,\s*barSize\)/.test(barSource), 'the bar radius comes from the floating state, the theme radius and Hyprland rounding')

// The center section declares two arrangements and shows one; the hidden one
// must not build its modules or every center widget exists twice.
const moduleList = barSource.slice(barSource.indexOf('component ModuleList'), barSource.indexOf('component ModuleSlot'))
assert(
  /active: visible && entries\.length > 0/.test(moduleList),
  'bar builds only the module list it is showing'
)

// A center module is mounted twice — drawn copy plus zero-size placeholder —
// and the order they register in is not stable across a live reconfiguration,
// so panel routing has to pick the one that is actually on screen.
const drawn = { moduleName: 'omarchy.clock', visible: true, width: 28, height: 81 }
const placeholder = { moduleName: 'omarchy.clock', visible: false, width: 0, height: 0 }
assertEqual(bar.isDrawnSlot(drawn), true, 'bar recognises a drawn slot')
assertEqual(bar.isDrawnSlot(placeholder), false, 'bar recognises a layout placeholder')
assertEqual(bar.pickDrawnSlot([placeholder, drawn]), drawn, 'bar picks the drawn slot when the placeholder registers first')
assertEqual(bar.pickDrawnSlot([drawn, placeholder]), drawn, 'bar picks the drawn slot when it registers first')
assertEqual(bar.pickDrawnSlot([placeholder]), placeholder, 'bar falls back to the placeholder when nothing is drawn')
assertEqual(bar.pickDrawnSlot([]), null, 'bar reports no slot when there are none')
assertEqual(bar.pickDrawnSlot(null), null, 'bar tolerates a missing slot list')

// Revealing the indicators can slide a neighbouring widget under a stationary
// pointer; collapsing the peek on that un-hover re-opens it and stutters the
// bar, so the peek stays held while the pointer is anywhere on the bar.
const revealTimer = barSource.slice(barSource.indexOf('id: centerSectionRevealTimer'))
const revealTimerBody = revealTimer.slice(0, revealTimer.indexOf('\n  }'))
assert(
  /!root\.centerSectionHovered && !root\.barHovered/.test(revealTimerBody),
  'the indicator peek stays held while the pointer is anywhere on the bar'
)

// The timer runs on a delay, so it can fire for a pointer that has already come
// back. Letting it assign the held state outright would then reveal indicators
// from bar hover alone; it may only close what the center section opened.
assert(
  !/centerSectionRevealHeld = (?!false)/.test(revealTimerBody),
  'the delayed collapse can only close the peek, never open it'
)

// The whole-bar hover has to come from an ancestor of the sections. A sibling
// loses hover to whichever section the pointer moved onto, which is the very
// signal the peek must not collapse on.
const barLoader = barSource.slice(barSource.indexOf('sourceComponent: root.vertical ? verticalBar : horizontalBar'))
const barLoaderBody = barLoader.slice(0, barLoader.indexOf('\n    }'))
assert(
  /setBarHovered\(hovered\)/.test(barLoaderBody),
  'the whole-bar hover handler is a child of the bar loader, above both orientations'
)

// Unplugging a monitor tears its bar down mid-hover with no leave event, which
// would leave that surface counted forever and the peek stuck open.
assert(
  /Component\.onDestruction: if \(hovered\) root\.setBarHovered\(false\)/.test(barLoaderBody),
  'a bar torn down while hovered gives its hover back'
)

// The helper has to record the state it is handed and re-run the collapse once
// the pointer leaves. It counts rather than assigns because every monitor's bar
// reports here: a slide from one bar to the next can deliver the enter before
// the leave, and a shared bool would read as un-hovered under a live pointer.
const setBarHovered = barSource.slice(barSource.indexOf('function setBarHovered'))
const setBarHoveredBody = setBarHovered.slice(0, setBarHovered.indexOf('\n  }'))
assert(
  /barHoverCount = Math\.max\(0, barHoverCount \+ \(hovered \? 1 : -1\)\)/.test(setBarHoveredBody),
  'each bar surface adds to a hover tally instead of overwriting a shared flag'
)
assert(
  /if \(barHoverCount === 0\) centerSectionRevealTimer\.restart\(\)/.test(setBarHoveredBody),
  'the peek collapse re-runs once the pointer has left the last bar'
)

// Opening the peek stays the center section's own gesture: pointing straight at
// a widget reveals nothing. Checking that only inside setBarHovered proves
// nothing, since the shared reveal timer is the path a bar hover leaks through.
const opensPeek = barSource.split('\n').filter(line => /centerSectionRevealHeld = true/.test(line))
assertEqual(opensPeek.length, 1, 'exactly one line in the bar opens the indicator peek')
const setCenterSectionHovered = barSource.slice(barSource.indexOf('function setCenterSectionHovered'))
assert(
  setCenterSectionHovered.slice(0, setCenterSectionHovered.indexOf('\n  }')).includes(opensPeek[0].trim()),
  'hovering the bar never opens the peek on its own'
)

// A bar surface is built per monitor, so a panel hotkey has one live copy of
// the widget per screen to choose between.
const internal = { moduleName: 'omarchy.audio', visible: true, width: 28, height: 81 }
const external = { moduleName: 'omarchy.audio', visible: true, width: 28, height: 81 }
const row = (slot, screenName, opened) => ({ slot, screenName, opened: opened === true })
const copies = [row(internal, 'eDP-1'), row(external, 'DP-1')]
assertEqual(
  bar.pickPanelSlot(copies, 'DP-1'),
  external,
  'bar summons a panel on the focused monitor'
)
assertEqual(
  bar.pickPanelSlot(copies, 'eDP-1'),
  internal,
  'bar summons a panel on the focused monitor whichever one it is'
)
assertEqual(
  bar.pickPanelSlot(copies, 'HDMI-A-1'),
  internal,
  'bar falls back to any live copy when the focused monitor has no bar'
)
assertEqual(
  bar.pickPanelSlot(copies, ''),
  internal,
  'bar falls back to any live copy before Hyprland reports a focused monitor'
)
assertEqual(
  bar.pickPanelSlot([row(internal, 'eDP-1', true), row(external, 'DP-1')], 'DP-1'),
  internal,
  'bar hides the panel that is open rather than the focused monitor copy'
)
assertEqual(
  bar.pickPanelSlot(
    [row(placeholder, 'DP-1'), row(drawn, 'DP-1'), row(internal, 'eDP-1')],
    'DP-1'
  ),
  drawn,
  'bar still picks the drawn slot among the focused monitor copies'
)
assertEqual(bar.pickPanelSlot([], 'DP-1'), null, 'bar reports no panel slot when there are none')
assertEqual(bar.pickPanelSlot(null, 'DP-1'), null, 'bar tolerates a missing panel slot list')
assert(
  /BarModel\.pickPanelSlot\(candidates, focusedScreenName\(\)\)/.test(barSource),
  'bar routes panel hotkeys through the focused-monitor picker'
)
assert(
  /function focusedScreenName\(\) \{[\s\S]*?Hyprland\.focusedMonitor/.test(barSource),
  'bar reads the focused monitor from Hyprland'
)
assert(
  /var slots = panelNavigationSlots\(currentSlot\.region, slotWindow\(currentSlot\)\)/.test(barSource),
  'bar tabs between panels within one bar surface'
)

// A positional hotkey means "the third panel in this section", so it counts the
// panels the bar actually draws. Reusing the tab-order walk is what keeps the
// count honest: a widget with no panel and a hidden one are already passed over
// there, and reading the layout config a second time would count both.
assert(
  /function panelWidgetIdAt\(region, index\) \{[\s\S]*?panelNavigationSlots\(String\(region \|\| ""\), null\)/.test(barSource),
  'bar counts positional panels off the drawn tab order'
)
assert(
  /var slot = slots\[Math\.round\(Number\(index\)\) - 1\]/.test(barSource),
  'positional panels are one-based, and anything off the end lands on no slot'
)
assert(
  /function togglePanelAt\(section: string, index: string\): string \{[\s\S]*?shell\.bar\.panelWidgetIdAt\(section, index\)[\s\S]*?shell\.toggle\(id, "\{\}"\)/.test(shellSource),
  'shell toggles a bar panel by its position over IPC'
)

const clockSlot = { id: 'clock' }
const traySlot = { id: 'tray' }
const horizontalTargets = [
  { slot: clockSlot, x: 100, y: 0, width: 100, height: 26 },
  { slot: traySlot, x: 500, y: 0, width: 50, height: 26 }
]
assertDeepEqual(
  bar.nearestDropTarget(horizontalTargets, { x: 240, y: 13 }, false),
  { slot: clockSlot, after: true },
  'bar resolves free space beside a widget to its nearest insertion edge'
)
assertDeepEqual(
  bar.nearestDropTarget(horizontalTargets, { x: 460, y: 13 }, false),
  { slot: traySlot, after: false },
  'bar resolves free space before a widget to its nearest insertion edge'
)
assertDeepEqual(
  bar.nearestDropTarget(horizontalTargets, { x: 125, y: 13 }, false),
  { slot: clockSlot, after: false },
  'bar resolves the first half of a widget before it'
)
assertDeepEqual(
  bar.nearestDropTarget(horizontalTargets, { x: 175, y: 13 }, false),
  { slot: clockSlot, after: true },
  'bar resolves the second half of a widget after it'
)
assertDeepEqual(
  bar.nearestDropTarget([
    { slot: clockSlot, x: 0, y: 100, width: 26, height: 80 }
  ], { x: 13, y: 220 }, true),
  { slot: clockSlot, after: true },
  'vertical bars resolve free space along their vertical axis'
)
assertEqual(bar.nearestDropTarget([], { x: 10, y: 10 }, false), null, 'bar reports no insertion edge without targets')
assert(
  /contentItem\.mapFromItem\(null, scenePoint\.x, scenePoint\.y\)[\s\S]*?return null/.test(barSource),
  'bar rejects free-space drops after the pointer leaves the bar'
)
assert(
  /BarModel\.nearestDropTarget\(candidates, scenePoint, root\.vertical\)/.test(barSource),
  'bar uses nearest insertion targeting for widget and free-space drops'
)
assert(
  /component DragGhostPanel:[\s\S]*?readonly property var targetRect: root\.barDragTargetGeometry[\s\S]*?color: Color\.accent/.test(barSource),
  'bar draws the insertion marker above the bar in the drag overlay'
)

// The open-panel mark sits on the module's desktop-facing edge at every
// position: under a top bar, over a bottom one, inward from left and right.
const indicator = barSource.slice(barSource.indexOf('id: openPanelIndicator'), barSource.indexOf('id: openPanelIndicator') + 1600)
assert(
  /x: root\.vertical\s*\n\s*\? \(root\.position === "left" \? parent\.width - width - inset : inset\)/.test(indicator),
  'bar pins the open-panel mark to the desktop-facing edge on vertical bars'
)
assert(
  /root\.position === "top" \? parent\.height - height - inset : inset/.test(indicator),
  'bar pins the open-panel mark to the desktop-facing edge on horizontal bars'
)
assert(
  /key in activeItem/.test(barSource),
  'bar asks whether a widget declares an indicator hint before reading it'
)
assert(
  /width: root\.vertical \? Style\.space\(2\) : slot\.panelIndicatorExtent/.test(indicator) &&
  /height: root\.vertical \? slot\.panelIndicatorExtent : Style\.space\(2\)/.test(indicator),
  'bar sizes the open-panel mark from the same content hint on both axes'
)

assertEqual(bar.normalizePosition('left'), 'left', 'bar accepts valid positions')
assertEqual(bar.normalizePosition('sideways'), 'top', 'bar defaults invalid positions')
assertDeepEqual(bar.entrySettings({ id: 'omarchy.clock', format: 'HH:mm' }), { format: 'HH:mm' }, 'bar extracts entry settings')
assertEqual(bar.entryId({ id: 'omarchy.clock' }), 'omarchy.clock', 'bar extracts object entry ids')
assertEqual(bar.entryId('omarchy.clock'), 'omarchy.clock', 'bar extracts string entry ids')

const entries = [{ id: 'a' }, { id: 'omarchy.tray' }, { id: 'b' }]
assertDeepEqual(bar.pinTrayToInner(entries, 'left').map(bar.entryId), ['a', 'b', 'omarchy.tray'], 'bar pins tray to left inner edge')
assertDeepEqual(bar.pinTrayToInner(entries, 'right').map(bar.entryId), ['omarchy.tray', 'a', 'b'], 'bar pins tray to right inner edge')

// A settings-only shell.json write must patch the live bar, not rebuild it:
// the module Repeaters recreate every widget when their array model changes.
const settingsLayout = { left: [{ id: 'omarchy.power' }], center: [{ id: 'omarchy.clock', format: 'HH:mm' }], right: [] }
assertDeepEqual(
  bar.inlineSettingsDelta(settingsLayout, { left: [{ id: 'omarchy.power', showPercentage: true }], center: [{ id: 'omarchy.clock', format: 'HH:mm' }], right: [] }),
  [{ region: 'left', index: 0, entry: { id: 'omarchy.power', showPercentage: true } }],
  'bar reports a settings-only change as an inline delta'
)
assertDeepEqual(
  bar.inlineSettingsDelta(settingsLayout, JSON.parse(JSON.stringify(settingsLayout))),
  [],
  'bar reports an unchanged layout as an empty delta'
)
assertEqual(
  bar.inlineSettingsDelta(settingsLayout, { left: [{ id: 'omarchy.clock', format: 'HH:mm' }], center: [{ id: 'omarchy.power' }], right: [] }),
  null,
  'bar treats reordered entries as structural'
)
assertEqual(
  bar.inlineSettingsDelta(settingsLayout, { left: [{ id: 'omarchy.power' }, { id: 'omarchy.battery' }], center: settingsLayout.center, right: [] }),
  null,
  'bar treats added entries as structural'
)
assertEqual(
  bar.inlineSettingsDelta(
    { left: [{ id: 'local.status', exec: 'date' }], center: [], right: [] },
    { left: [{ id: 'local.status', exec: 'uptime' }], center: [], right: [] }
  ),
  null,
  'bar rebuilds for custom modules, which read their entry directly'
)
assertEqual(
  bar.inlineSettingsDelta(
    { left: [{ id: 'x' }], center: [], right: [{ id: 'x' }] },
    { left: [{ id: 'x', a: 1 }], center: [], right: [{ id: 'x' }] }
  ),
  null,
  'bar rebuilds when a changed id appears more than once in the layout'
)
assert(
  /BarModel\.inlineSettingsDelta\(layoutConfig, next\)/.test(barSource),
  'bar consults the inline settings delta before rebuilding the layout'
)

assertEqual(bar.moduleString({ id: 'custom', label: 42 }, 'label', 'fallback'), '42', 'bar stringifies module settings')
assertEqual(bar.entryIndex(entries, 'b'), 2, 'bar finds entry indexes')
assertDeepEqual(bar.entriesBefore(entries, 'b').map(bar.entryId), ['a', 'omarchy.tray'], 'bar returns entries before target')
assertDeepEqual(bar.entriesAfter(entries, 'a').map(bar.entryId), ['omarchy.tray', 'b'], 'bar returns entries after target')

assertEqual(bar.expandPath('~/module.qml', '/home/dhh'), '/home/dhh/module.qml', 'bar expands tilde paths')
assertEqual(bar.expandPath('$HOME/module.qml', '/home/dhh'), '/home/dhh/module.qml', 'bar expands HOME paths')
assert(bar.customModuleSafeName('local.weather'), 'bar accepts safe custom module names')
assert(!bar.customModuleSafeName('../escape'), 'bar rejects path traversal custom module names')
assertEqual(bar.customModuleType({ id: 'custom', exec: 'date' }), 'command', 'bar infers command custom modules')
assertEqual(bar.customModuleType({ id: 'custom', source: '~/Custom.qml' }), 'qml', 'bar infers qml custom modules')
assertEqual(
  bar.customModulePath({ id: 'local.weather' }, '/home/dhh', '/home/dhh/.config/omarchy'),
  '/home/dhh/.config/omarchy/bar/modules/local.weather.qml',
  'bar builds default custom module paths'
)

// Pills. A run is the DMS segment model: spacers break it, hidden widgets drop
// out of it without breaking it, and runs of one are a whole pill.
assertEqual(bar.pillMode(undefined), 'off', 'pills are off by default')
assertEqual(bar.pillMode('section'), 'section', 'pills accept section mode')
assertEqual(bar.pillMode('widget'), 'widget', 'pills accept widget mode')
assertEqual(bar.pillMode('bogus'), 'off', 'an unknown pill mode draws no pills')

assertEqual(bar.pillState({ id: 'omarchy.clock' }, true), true, 'a drawn widget joins a pill')
assertEqual(bar.pillState({ id: 'omarchy.clock' }, false), null, 'a hidden widget is skipped')
assertEqual(bar.pillState({ id: 'omarchy.spacer', size: 0 }, false), false, 'a zero-size spacer still breaks a pill')
assertEqual(bar.pillState({ id: 'omarchy.spacer', size: 8 }, true), false, 'a spacer never draws a pill')
assertEqual(bar.pillState({ id: 'omarchy.clock', pill: false }, true), false, 'pill: false opts a widget out and breaks the run')
assertEqual(bar.pillState({ id: 'omarchy.clock', pill: false }, false), null, 'a hidden opted-out widget is skipped')

const pillEntries = [{ id: 'a' }, { id: 'b' }, { id: 'c' }, { id: 'omarchy.spacer' }, { id: 'd' }, { id: 'e' }]
const pillDrawn = pillEntries.map(entry => bar.pillState(entry, true))
assertDeepEqual(bar.pillRoles(pillEntries, pillDrawn, 'off'), ['none', 'none', 'none', 'none', 'none', 'none'], 'off mode draws no pills')
assertDeepEqual(bar.pillRoles(pillEntries, pillDrawn, 'section'), ['first', 'middle', 'last', 'none', 'first', 'last'], 'section mode joins runs and a spacer splits them')
assertDeepEqual(bar.pillRoles(pillEntries, pillDrawn, 'widget'), ['solo', 'solo', 'solo', 'none', 'solo', 'solo'], 'widget mode gives each widget its own pill')
assertDeepEqual(bar.pillRoles(pillEntries, [true, null, true, false, null, true], 'section'), ['first', 'none', 'last', 'none', 'none', 'solo'], 'hidden widgets drop out of a run without breaking it')
assertDeepEqual(bar.pillRoles(pillEntries, [], 'section'), ['none', 'none', 'none', 'none', 'none', 'none'], 'widgets that have not reported draw nothing')
assertDeepEqual(bar.pillRoles([], [], 'section'), [], 'an empty section has no roles')

const groupEntries = [{ id: 'a' }, { id: 'b', group: 'net' }, { id: 'c', group: 'net' }, { id: 'd', group: 'power' }, { id: 'e' }, { id: 'f' }]
assertDeepEqual(
  bar.pillRoles(groupEntries, groupEntries.map(entry => bar.pillState(entry, true)), 'section'),
  ['solo', 'first', 'last', 'solo', 'first', 'last'],
  'a change of group key splits a run with no spacer'
)
assertDeepEqual(
  bar.pillRoles(groupEntries, [true, true, null, true, true, true], 'section'),
  ['solo', 'solo', 'none', 'solo', 'first', 'last'],
  'a group left with one drawn widget is a whole pill'
)

// Section ends: an outer pill sits pillInset from the bar end (its slot
// carries half the gap), a bare outer widget keeps the stock margin.
assertEqual(bar.sectionEndMargin([true, true], false, false, 2, 6, 8), 8, 'without pills a section keeps the stock end margin')
assertEqual(bar.sectionEndMargin([true, false], false, true, 2, 6, 8), -1, 'an outer pill carries half the gap itself')
assertEqual(bar.sectionEndMargin([null, false, true], false, true, 2, 6, 8), 8, 'a bare outer widget keeps the stock margin, hidden ones skipped')
assertEqual(bar.sectionEndMargin([true, false, null], true, true, 2, 6, 8), 8, 'the far end reads the last drawn widget')
assertEqual(bar.sectionEndMargin([], true, true, 2, 6, 8), 8, 'an empty section keeps the stock margin')
// An odd gap splits unevenly, and two neighbours still add up to it.
assertEqual(bar.pillGapLead(7) + (7 - bar.pillGapLead(7)), 7, 'the gap halves of two neighbouring pills add up to pill-gap')
assertEqual(bar.pillGapLead(6), 3, 'an even gap splits evenly')
assertEqual(bar.sectionEndMargin([true], false, true, 2, 7, 8), -1, 'the start of a section takes the smaller half of an odd gap')
assertEqual(bar.sectionEndMargin([true], true, true, 2, 7, 8), -2, 'the end of a section takes the larger half of an odd gap')
const slotSource = barSource.slice(barSource.indexOf('component ModuleSlot'))
assert(
  /readonly property int pillGapLead: BarModel\.pillGapLead\(Style\.bar\.pillGap\)/.test(slotSource) &&
  /readonly property int pillGapTrail: Style\.bar\.pillGap - pillGapLead/.test(slotSource) &&
  /pillTrail: BarModel\.pillEndsRound\(pillRole\) \? Style\.bar\.pillPadding \+ pillGapTrail/.test(slotSource) &&
  /width: root\.vertical \? slot\.width - inset \* 2 : slot\.pillLength - slot\.pillGapLead - slot\.pillGapTrail/.test(slotSource),
  'a pill is drawn between the two gap halves of its run'
)
assert(/pillPadding: root\.barInsetToken\("pill-padding", 4\)/.test(styleSource) && /pillGap: +root\.barInsetToken\("pill-gap", +6\)/.test(styleSource), 'pill-padding and pill-gap keep a deliberate 0')
// Dragging the slot that draws a multi-widget pill must not lift the pill
// over the rest of the run, and the ghost is the widget, not the slot.
assert(/z: modulePointer\.dragging && !\(slot\.pillLength > 0 && slot\.pillRole === "first"\) \? 100 : 0/.test(slotSource), 'dragging the first widget of a pill keeps the pill under its neighbours')
assert(
  /color: root\.pillsOn\s*\? \(root\.transparent \? root\.pillFill : Qt\.tint\(root\.background, root\.pillFill\)\)\s*: \(root\.transparent \? "transparent" : root\.background\)/.test(barSource),
  'the drag ghost sits on the pill colour while pills are on, and on the bar colour otherwise'
)
assert(
  /root\.barDragOffsetX = pressedX - \(root\.vertical \? 0 : slot\.pillLead\)/.test(slotSource) &&
  /root\.barDragOffsetY = pressedY - \(root\.vertical \? slot\.pillLead : 0\)/.test(slotSource),
  'the drag ghost stays under the pointer inside a pill'
)
// Pills off must leave the bar as it was: these are the switches.
assert(/property color barForeground: pillsOn && /.test(barSource), 'bar text follows pills only while pills are on')
assert(/readonly property var roles: root\.pillsOn \? BarModel\.pillRoles\(/.test(barSource), 'no pill roles while pills are off')
assert(/readonly property color pillForeground: !pillsOn \? themeForeground :/.test(barSource), 'no pill text colour work while pills are off')
assert(/readonly property bool pillTextSampled: pillsOn && !pillTextFixed && requestedTransparent && Color\.bar\.pill\.a < 1/.test(barSource), 'pill text is sampled only for a translucent pill on a transparent bar')
assert(/readonly property bool pillRaised: !transparent && Color\.pick\("bar\.pill", ""\) === ""/.test(barSource), 'the raised pill tone is used only on the drawn bar without a theme pill')
assert(/x: BarModel\.anchorOffset\(parent\.width, width, pillLead, pillTrail\)/.test(barSource) && /y: BarModel\.anchorOffset\(parent\.height, height, pillLead, pillTrail\)/.test(barSource), 'the anchored centre widget is placed by anchorOffset on both axes')
assert(
  /if \(root\.pillsOn \|\| root\.transparentForegroundBlended\) root\.transparentForegroundPending = true/.test(barSource) &&
  /root\.transparentForegroundBlended = root\.pillBlendArgs\.length > 0/.test(barSource) &&
  /onExited: \{\s*if \(!root\.transparentForegroundPending\) return\s*root\.transparentForegroundPending = false\s*Qt\.callLater\(root\.refreshTransparentForeground\)/.test(barSource),
  'with pills on, a text colour refresh asked for during a sample runs after it'
)

// The anchored centre widget must sit where anchors.centerIn puts it without
// pills: Qt rounds each half on its own, round(P/2) - round(s/2).
let anchorMismatches = 0
for (let parent = 1000; parent < 1100; parent++) {
  for (let size = 20; size < 120; size++) {
    if (bar.anchorOffset(parent, size, 0, 0) !== Math.round(parent / 2) - Math.round(size / 2)) anchorMismatches++
  }
}
assertEqual(anchorMismatches, 0, 'without pills the anchor matches anchors.centerIn to the pixel')

// Tray icons on the bar sit on the pill and take its text colour; the tray
// popups sit on the popup background and keep the theme text.
const traySource = fs.readFileSync(root + '/shell/plugins/bar/widgets/Tray.qml', 'utf8')
const trayItem = traySource.slice(traySource.indexOf('component TrayItem'))
assert(/readonly property color foreground: bar \? bar\.foreground : Color\.foreground/.test(traySource), 'tray popups keep the theme text colour')
assert(/readonly property color barIconColor: bar \? \(bar\.pillsOn \? bar\.barForeground : bar\.foreground\)/.test(traySource), 'tray bar icons follow the pill text while pills are on')
assert(/property color tint: root\.foreground/.test(traySource) && /colorizationColor: trayIconRoot\.tint/.test(traySource), 'tray icons are tinted with their own tint, the popup colour by default')
assert(/TrayIcon \{[^}]*tint: root\.barIconColor/.test(trayItem), 'the tray icon on the bar takes the bar icon colour')
// A cloned tray gets the plugin facade, which must carry pillsOn for that.
assert(/property bool pillsOn: false/.test(fs.readFileSync(root + '/shell/Ui/PluginBarApi.qml', 'utf8')) && /api\.pillsOn = Qt\.binding\(function\(\) \{ return root\.pillsOn \}\)/.test(barSource), 'bar widgets outside the shell see whether pills are on')
assertEqual(bar.anchorOffset(1080, 81 + 14, 7, 7), bar.anchorOffset(1080, 81, 0, 0) - 7, 'pill padding does not move the anchored widget')

assertEqual(
  bar.inlineSettingsDelta({ left: [{ id: 'a' }], center: [], right: [] }, { left: [{ id: 'a', pill: false }], center: [], right: [] }),
  null,
  'bar rebuilds when an entry opts out of pills'
)
assertEqual(
  bar.inlineSettingsDelta({ left: [{ id: 'a', group: 'x' }], center: [], right: [] }, { left: [{ id: 'a', group: 'y' }], center: [], right: [] }),
  null,
  'bar rebuilds when an entry changes pill group'
)

assertEqual(bar.blendHex('#ffffff', 0.5, '#000000'), '#808080', 'pill colour blends over its backdrop')
assertEqual(bar.blendHex('#1a1b26', 1, '#ffffff'), '#1a1b26', 'an opaque pill hides its backdrop')
assertEqual(bar.blendHex('bogus', 1, '#ffffff'), '', 'blending rejects a malformed colour')
assertEqual(bar.pickTextColor('#ffffff', '#101010', '#f5f5f5'), '#101010', 'pill text flips to the background colour on a light pill')
assertEqual(bar.pickTextColor('#ffffff', '#101010', '#202020'), '#ffffff', 'pill text keeps the bar text on a dark pill')
assertEqual(bar.pickTextColor('#ffffff', '#101010', 'bogus'), '#ffffff', 'pill text keeps the bar text when the backdrop is unknown')
assert(Math.abs(bar.contrastRatio('#ffffff', '#000000') - 21) < 1e-9, 'contrast ratio follows WCAG')
JS

put_tmp=$(mktemp -d)
trap 'rm -rf "$put_tmp"' EXIT
mkdir -p "$put_tmp/bin"
ln -s "$ROOT/bin/omarchy-shell-config" "$put_tmp/bin/omarchy-shell-config"

cat >"$put_tmp/bin/omarchy-shell" <<'STUB'
#!/bin/bash
case ${OMARCHY_TEST_SHELL_STATE:-ready} in
  missing)
    echo "omarchy-shell is not running" >&2
    exit 1
    ;;
  starting)
    echo "omarchy-shell is not ready" >&2
    exit 1
    ;;
  crashing)
    # Seen coming up, then gone.
    if [[ -e $OMARCHY_TEST_SHELL_MARKER ]]; then
      echo "omarchy-shell is not running" >&2
    else
      touch "$OMARCHY_TEST_SHELL_MARKER"
      echo "omarchy-shell is not ready" >&2
    fi
    exit 1
    ;;
  oldshell)
    # A shell from before put learned to fall back.
    if [[ $4 == *"after"* ]]; then
      echo "could not find target widget omarchy.clock"
    else
      echo "ok"
    fi
    exit 0
    ;;
  spawning)
    # Launched, but with no socket to answer on yet.
    if [[ ! -e $OMARCHY_TEST_SHELL_MARKER ]]; then
      touch "$OMARCHY_TEST_SHELL_MARKER"
      echo "omarchy-shell is not running" >&2
      exit 1
    fi
    ;;
  vanishing)
    # Answers the first ask, then is gone before the fallback lands.
    if [[ ! -e $OMARCHY_TEST_SHELL_MARKER ]]; then
      touch "$OMARCHY_TEST_SHELL_MARKER"
      echo "could not find target widget omarchy.clock"
      exit 0
    fi
    echo "omarchy-shell is not running" >&2
    exit 1
    ;;
  unsupported)
    # An older shell that predates this call.
    echo "Function not found." >&2
    exit 1
    ;;
  scanning)
    # Answering IPC, but has not read the plugins yet.
    if [[ ! -e $OMARCHY_TEST_SHELL_MARKER ]]; then
      touch "$OMARCHY_TEST_SHELL_MARKER"
      echo "not ready"
      exit 0
    fi
    ;;
esac
echo "ok"
STUB
chmod +x "$put_tmp/bin/omarchy-shell"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=missing \
  OMARCHY_SHELL_ABSENT_ATTEMPTS=2 \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) ||
  fail "put carries on when no shell is running" "$put_output"
[[ $put_output == *"is not running"* ]] || fail "put says why it placed nothing" "$put_output"
pass "put carries on when no shell is running"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=spawning \
  OMARCHY_TEST_SHELL_MARKER="$put_tmp/spawned" \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) ||
  fail "put waits for a shell that is being spawned" "$put_output"
[[ $put_output == "omarchy.keyboard-layout is on the bar" ]] || fail "put places once the shell answers" "$put_output"
pass "put waits for a shell that is being spawned"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=starting OMARCHY_SHELL_READY_ATTEMPTS=2 \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) &&
  fail "put fails when the shell never becomes ready" "$put_output"
[[ $put_output == *"did not become ready"* ]] || fail "put says the shell never became ready" "$put_output"
pass "put fails when the shell never becomes ready"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=crashing \
  OMARCHY_TEST_SHELL_MARKER="$put_tmp/started" \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) &&
  fail "put fails when a starting shell disappears" "$put_output"
[[ $put_output == *"did not become ready"* ]] || fail "put keeps a lost shell retryable" "$put_output"
pass "put fails when a starting shell disappears"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=oldshell \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) ||
  fail "put falls back against a shell that has not restarted yet" "$put_output"
[[ $put_output == "omarchy.keyboard-layout is on the bar" ]] || fail "put places without the missing neighbour" "$put_output"
pass "put falls back against a shell that has not restarted yet"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=vanishing \
  OMARCHY_TEST_SHELL_MARKER="$put_tmp/vanished" \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) &&
  fail "put fails when the shell goes away mid-fallback" "$put_output"
[[ $put_output == *"did not become ready"* ]] || fail "put remembers the shell answered once" "$put_output"
pass "put fails when the shell goes away mid-fallback"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=unsupported \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) &&
  fail "put fails when the shell cannot answer the call" "$put_output"
[[ $put_output == *"Function not found"* ]] || fail "put passes on what the shell said" "$put_output"
pass "put fails when the shell cannot answer the call"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" OMARCHY_TEST_SHELL_STATE=scanning \
  OMARCHY_TEST_SHELL_MARKER="$put_tmp/scanned" \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) ||
  fail "put asks again while the shell is still reading its plugins" "$put_output"
[[ $put_output == "omarchy.keyboard-layout is on the bar" ]] || fail "put places once the plugins are read" "$put_output"
pass "put asks again while the shell is still reading its plugins"

put_output=$(PATH="$put_tmp/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bar" put omarchy.keyboard-layout --after omarchy.clock 2>&1) ||
  fail "put places a widget through a ready shell" "$put_output"
[[ $put_output == "omarchy.keyboard-layout is on the bar" ]] || fail "put reports the placed widget" "$put_output"
pass "put places a widget through a ready shell"
