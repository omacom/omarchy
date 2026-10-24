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

if ! perl -0ne 'exit(/component CenterGestureArea:\s*MouseArea\s*\{[^}]*?\bpreventStealing:\s*true\b/s ? 0 : 1)' \
  "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "center gesture area must prevent stealing during bar drag"
fi
pass "center gesture area sets preventStealing to retain pointer grab across screen"

# Every click target registration used to resync every plugin api inline. With
# six monitors' worth of widgets that is hundreds of full walks at startup, so
# the change handlers coalesce into one deferred resync and ownership lookups
# are keyed by target instead of scanning an array.
if ! rg -q 'onClickTargetsChanged: schedulePluginBarApiSync\(\)' "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar coalesces plugin api resyncs instead of running one per click target change"
fi
if ! rg -q 'Qt\.callLater\(root\.syncAllPluginBarApiObjects\)' "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar defers the coalesced plugin api resync to the event loop"
fi
if ! rg -q 'pluginObjectOwners\.get\(target\)' "$ROOT/shell/plugins/bar/Bar.qml"; then
  fail "bar looks plugin object ownership up by target instead of scanning"
fi
pass "bar coalesces plugin api resyncs and looks ownership up by target"

# Both bar orientations used to be instantiated and toggled with `visible`,
# doubling every indicator (and every process an indicator spawns) per bar.
if ! rg -q 'sourceComponent: root\.vertical \? verticalIndicatorsTree : horizontalIndicatorsTree' \
  "$ROOT/shell/plugins/bar/widgets/Indicators.qml"; then
  fail "indicators instantiate only the tree for the current bar orientation"
fi
pass "indicators instantiate only the tree for the current bar orientation"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

assert(/function toggleBarTransparency\(\): string \{[\s\S]*?shell\.bar\.cycleBackground\(\)/.test(shellSource), 'shell exposes the bar background cycle over IPC')

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
  /exclusionMode: root\.barHidden \? ExclusionMode\.Ignore : ExclusionMode\.Auto/.test(barSource),
  'a hidden bar reserves no space for itself'
)
for (const edge of ['top', 'bottom', 'left', 'right']) {
  assert(
    new RegExp(`${edge}: root\\.barHidden && root\\.position === "${edge}" \\? -barWindow\\.thickness : 0`).test(barSource),
    `a hidden bar parks past the ${edge} edge by its whole thickness`
  )
}

const moduleSlot = barSource.slice(barSource.indexOf('component ModuleSlot'), barSource.indexOf('component CustomCommandModule'))
const dragSpacer = barSource.slice(barSource.indexOf('component DragSpacer'), barSource.indexOf('component CenterGestureArea'))
assert(
  /if \(slot\.traySectionContains\(mouse\.x, mouse\.y\)\) \{\s*mouse\.accepted = false/.test(moduleSlot),
  'a press in the tray\'s drawer goes to the widget in it, not the tray'
)
// A third-party widget's api lives as long as the widget does, wherever it
// moves, not as long as the slot it is in.
assert(
  /onWidgetHostsChanged: Qt\.callLater\(prunePluginBarApis\)/.test(barSource) && !/onModuleSlotsChanged/.test(barSource),
  'a widget\'s api is kept by the widget, not by the slots it moves between'
)

// A widget's slot can be on the bar without being drawn (hidden by the
// widget, or folded away by a drag), so panel routing has to pick the one
// that is actually on screen, whichever registered first.
const drawn = { moduleName: 'omarchy.clock', visible: true, width: 28, height: 81 }
const undrawn = { moduleName: 'omarchy.clock', visible: true, width: 0, height: 26 }
assertEqual(bar.isDrawnSlot(drawn), true, 'bar recognises a drawn slot')
assertEqual(bar.isDrawnSlot(undrawn), false, 'bar recognises a slot with nothing drawn')
assertEqual(bar.pickDrawnSlot([undrawn, drawn]), drawn, 'bar picks the drawn slot when an undrawn one registers first')
assertEqual(bar.pickDrawnSlot([drawn, undrawn]), drawn, 'bar picks the drawn slot when it registers first')
assertEqual(bar.pickDrawnSlot([undrawn]), undrawn, 'bar falls back to an undrawn slot when nothing is drawn')
assertEqual(bar.pickDrawnSlot([]), null, 'bar reports no slot when there are none')
assertEqual(bar.pickDrawnSlot(null), null, 'bar tolerates a missing slot list')

// Revealing the indicators can slide a neighbouring widget under a stationary
// pointer; collapsing the peek on that un-hover re-opens it and stutters the
// bar, so the peek stays held while the pointer is on the bar short of the
// center box's end.
const revealTimer = barSource.slice(barSource.indexOf('id: centerSectionRevealTimer'))
const revealTimerBody = revealTimer.slice(0, revealTimer.indexOf('\n  }'))
assert(
  /onTriggered: if \(!root\.barHovered\) root\.centerSectionRevealHeld = false/.test(revealTimerBody),
  'the indicator peek stays held while the pointer is on the bar'
)

// The whole-bar hover has to come from an ancestor of the sections. A sibling
// loses hover to whichever section the pointer moved onto, which is the very
// signal the peek must not collapse on.
const barLoader = barSource.slice(barSource.indexOf('sourceComponent: root.vertical ? verticalBar : horizontalBar'))
const barLoaderBody = barLoader.slice(0, barLoader.indexOf('\n    }'))
assert(
  /peeking: hovered && BarModel\.peeksAt\(point\.position, barWindow\.peekEdge, root\.vertical\)\s*onPeekingChanged: root\.setBarHovered\(peeking\)/.test(barLoaderBody),
  'the whole-bar hover handler is a child of the bar loader, above both orientations'
)

// Hovering the panel icons, or anything else past the clock, leaves the
// indicators hidden; the rest of the bar up to the clock's end opens them.
assertEqual(bar.peeksAt({ x: 400, y: 10 }, 1000, false), true, 'the peek opens left of the clock')
assertEqual(bar.peeksAt({ x: 1200, y: 10 }, 1000, false), false, 'the peek stays shut right of the clock')
assertEqual(bar.peeksAt({ x: 1200, y: 400 }, 600, true), true, 'a vertical bar opens the peek above the clock')
assertEqual(bar.peeksAt({ x: 10, y: 800 }, 600, true), false, 'a vertical bar keeps the peek shut below the clock')
assertEqual(bar.peeksAt(null, 1000, false), false, 'no pointer opens no peek')

// Beside a display notch, indicators right of the clock pull its end toward
// the start as they reveal. A stationary pointer between the two ends has to
// keep the peek open rather than close it, slide the clock back and reopen it.
const notchBoxEnd = revealed => revealed ? 900 : 1000
function peekRun(pointers) {
  let edge = notchBoxEnd(false)
  return pointers.map(pointer => {
    const held = bar.peeksAt(pointer, edge, false)
    edge = bar.nextPeekEdge(edge, notchBoxEnd(held), held)
    return held
  })
}
const between = { x: 950, y: 10 }
assertEqual(peekRun([between, between, between, between]).join(), 'true,true,true,true', 'a reveal that moves the clock does not close the peek under a still pointer')
assertEqual(peekRun([between, { x: 1050, y: 10 }, { x: 1050, y: 10 }]).join(), 'true,false,false', 'leaving past the clock closes the peek for good')

// A widget that grows (the indicator peek, a drawer) has to know which of its
// edges stays put, and that is the side its list is anchored by.
const centerSections = barSource.slice(barSource.indexOf('component CenterSections'), barSource.indexOf('component CenterBox'))
const centerBox = barSource.slice(barSource.indexOf('component CenterBox'), barSource.indexOf('component CenterGestureArea'))
const fixedEdges = [
  [/component LeftModules: ModuleList \{[^}]*?region: "left"\s*fixedEdge: "start"/, barSource, 'the left section grows rightward and downward'],
  [/component RightModules: ModuleList \{[^}]*?region: "right"\s*fixedEdge: "end"/, barSource, 'the right section grows leftward and upward'],
  [/region: "centerBegin"\s*fixedEdge: "end"/, centerSections, 'centerBegin grows away from the center box'],
  [/region: "centerEnd"\s*fixedEdge: sections\.besideRight \? "end" : "start"/, centerSections, 'centerEnd grows away from the center box'],
  [/fixedEdge: sections\.besideRight \? "end" : "center"/, centerSections, 'the center box grows both ways'],
  [/region: "center"\s*fixedEdge: box\.fixedEdge/, centerBox, 'the center box hands its edge to the widgets in it']
]
for (const [pattern, source, message] of fixedEdges) assert(pattern.test(source), message)

// A layout reading an implicit size that drops from a fraction of a pixel to
// nothing keeps the old size, so a widget hiding itself would leave a hole.
for (const [name, body] of [['slot', moduleSlot], ['spacer', dragSpacer]]) {
  assert(
    /Layout\.preferredWidth: implicitWidth\s*Layout\.preferredHeight: implicitHeight/.test(body),
    `a ${name} hands its section's layout its size as a preferred size`
  )
}

// Unplugging a monitor tears its bar down mid-hover with no leave event, which
// would leave that surface counted forever and the peek stuck open.
assert(
  /Component\.onDestruction: if \(peeking\) root\.setBarHovered\(false\)/.test(barLoaderBody),
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
  /if \(barHoverCount > 0\) \{\s*centerSectionRevealTimer\.stop\(\)\s*centerSectionRevealHeld = true\s*\} else \{\s*centerSectionRevealTimer\.restart\(\)/.test(setBarHoveredBody),
  'the pointer coming onto any bar opens the peek, and leaving the last one re-runs the collapse'
)

// The peek opens from the bar up to the center box's end, widgets included,
// so no narrower hover area opens it as well.
const opensPeek = barSource.split('\n').filter(line => /centerSectionRevealHeld = true/.test(line))
assertEqual(opensPeek.length, 1, 'exactly one line in the bar opens the indicator peek')
assert(setBarHoveredBody.includes(opensPeek[0].trim()), 'only the whole-bar hover opens the peek')

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
    [row(undrawn, 'DP-1'), row(drawn, 'DP-1'), row(internal, 'eDP-1')],
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
  /BarModel\.centerDropTarget\(onBar, root\.centerBoxDropRect\(box\), scenePoint, root\.vertical, sourceSlot\)/.test(barSource) &&
    /region: slot\.region,/.test(barSource),
  'bar uses nearest insertion targeting, aware of the center box, for widget and free-space drops'
)

// A drag moves an entry by index, as the drag found it.
const moveLayout = () => ({ bar: { layout: { left: ['a', { id: 'b', tag: 'x' }, { id: 'b', tag: 'y' }, 'c'], right: ['d'] } } })
const moved = (config) => Object.fromEntries(Object.entries(config.bar.layout).map(([region, entries]) => [region, entries.map(entry => typeof entry === 'string' ? entry : entry.id + entry.tag)]))
let moveConfig = moveLayout()
assertEqual(bar.moveEntry(moveConfig, { from: { region: 'left', index: 2, id: 'b' }, to: { region: 'left', index: 0 } }), true, 'a drag moves an entry within its section')
assertDeepEqual(moved(moveConfig), { left: ['by', 'a', 'bx', 'c'], right: ['d'] }, 'the second of two entries with one id moves when it is the one dragged')
moveConfig = moveLayout()
bar.moveEntry(moveConfig, { from: { region: 'left', index: 1, id: 'b' }, to: { region: 'left', index: 3 } })
assertDeepEqual(moved(moveConfig).left, ['a', 'by', 'bx', 'c'], 'a drop before a later widget lands just before it')
moveConfig = moveLayout()
bar.moveEntry(moveConfig, { from: { region: 'left', index: 0, id: 'a' }, to: { region: 'left', index: -1 } })
assertDeepEqual(moved(moveConfig).left, ['bx', 'by', 'c', 'a'], 'a drop at the end of the section lands after its last entry')
moveConfig = moveLayout()
bar.moveEntry(moveConfig, { from: { region: 'left', index: 2, id: 'b' }, to: { region: 'centerEnd', index: -1 } })
assertDeepEqual(moved(moveConfig), { left: ['a', 'bx', 'c'], right: ['d'], centerEnd: ['by'] }, 'a drop in a section the config lacks makes it')
moveConfig = moveLayout()
assertEqual(bar.moveEntry(moveConfig, { from: { region: 'left', index: 1, id: 'b' }, to: { region: 'left', index: 2 } }), false, 'a drop back where the entry was changes nothing')
assertEqual(bar.moveEntry(moveConfig, { from: { region: 'left', index: 0, id: 'b' }, to: { region: 'right', index: 0 } }), false, 'a layout that changed since the drag started is left alone')
assertDeepEqual(moved(moveConfig), moved(moveLayout()), 'a move that does not apply leaves the layout as it was')
assertEqual(bar.moveEntry(moveConfig, { from: { region: 'nowhere', index: 0, id: 'a' }, to: { region: 'left', index: 0 } }), false, 'a move from an unknown section changes nothing')
// The bar leaves out entries that aren't widgets, and its indexes do too.
const strayConfig = { bar: { layout: { left: [42, 'a', {}, 'b', 'c'] } } }
assertEqual(bar.moveEntry(strayConfig, { from: { region: 'left', index: 2, id: 'c' }, to: { region: 'left', index: 1 } }), true, 'a drag moves by the bar\'s indexes past entries it leaves out')
assertDeepEqual(strayConfig.bar.layout.left, [42, 'a', {}, 'c', 'b'], 'the move lands among the widgets the bar drew, leaving the rest alone')
const aliasConfig = { bar: { layout: { left: ['clock', 'b'] } } }
assertEqual(bar.moveEntry(aliasConfig, { from: { region: 'left', index: 0, id: 'omarchy.clock' }, to: { region: 'left', index: -1 } }, entry => entry === 'clock' ? { id: 'omarchy.clock' } : entry), true, 'an entry is matched by the id the bar knows it by')
assertDeepEqual(aliasConfig.bar.layout.left, ['b', 'clock'], 'and moved as it is written')

// Horizontal bar: indicators in centerBegin, the clock alone in the center box
// at 340-400, weather in centerEnd, the menu far off in the left section.
const menuSlot = { id: 'menu' }
const indicatorsSlot = { id: 'indicators' }
const boxClock = { id: 'clock' }
const weatherSlot = { id: 'weather' }
const dropRow = (slot, region, x, width) => ({ slot, region, x, y: 0, width, height: 26 })
const menu = dropRow(menuSlot, 'left', 0, 30)
const indicators = dropRow(indicatorsSlot, 'centerBegin', 300, 40)
const clock = dropRow(boxClock, 'center', 340, 60)
const weather = dropRow(weatherSlot, 'centerEnd', 400, 40)
const box = { x: 340, y: 0, width: 60, height: 26 }
const full = [menu, indicators, clock, weather]
assertDeepEqual(bar.centerDropTarget(full, box, { x: 345 }, false), { slot: boxClock, after: false }, 'a drop over the box lands among its widgets')
assertDeepEqual(bar.centerDropTarget(full, box, { x: 395 }, false), { slot: boxClock, after: true }, 'a drop over the end of the box lands after its last widget')
assertDeepEqual(bar.centerDropTarget(full, box, { x: 338 }, false), { slot: indicatorsSlot, after: true }, 'a drop just before the box lands at the end of centerBegin')
assertDeepEqual(bar.centerDropTarget(full, box, { x: 402 }, false), { slot: weatherSlot, after: false }, 'a drop just after the box lands at the start of centerEnd')
assertDeepEqual(bar.centerDropTarget([menu, clock], box, { x: 330 }, false), { region: 'centerBegin', after: true }, 'beside the box with centerBegin empty, a drop starts centerBegin')
assertDeepEqual(bar.centerDropTarget([menu, clock], box, { x: 410 }, false), { region: 'centerEnd', after: false }, 'beside the box with centerEnd empty, a drop starts centerEnd')
// The box grows to take in a widget dropped from outside; over the room it
// has opened, the drop still lands in the box.
const grown = { x: 320, y: 0, width: 100, height: 26 }
assertDeepEqual(bar.centerDropTarget(full, grown, { x: 325 }, false), { slot: boxClock, after: false }, 'a drop over the room the box has opened still lands in it')
assertDeepEqual(bar.centerDropTarget([menu, clock], grown, { x: 430 }, false), { region: 'centerEnd', after: false }, 'off the box, its widgets are out of reach')

// An empty box takes no room, so a drop reaches into it over the bar's
// thickness, centered on it, over the widgets either side of it as well.
assertDeepEqual(bar.centerDropZone({ x: 500, y: 0, width: 0, height: 26 }, 26, false), { x: 487, y: 0, width: 26, height: 26 }, 'an empty box is hit across the bar\'s thickness, centered on it')
assertDeepEqual(bar.centerDropZone(box, 26, false), box, 'a box longer than the bar is thick is hit just where it is')
assertDeepEqual(bar.centerDropZone({ x: 0, y: 300, width: 28, height: 10 }, 28, true), { x: 0, y: 291, width: 28, height: 28 }, 'a vertical bar grows the zone along y')
assertEqual(bar.centerDropZone(null, 26, false), null, 'a bar without a center box has no zone')
const empty = bar.centerDropZone({ x: 500, y: 0, width: 0, height: 26 }, 26, false)
const meeting = [menu, dropRow(indicatorsSlot, 'centerBegin', 460, 40), dropRow(weatherSlot, 'centerEnd', 500, 40)]
assertDeepEqual(bar.centerDropTarget([menu], empty, { x: 500 }, false), { region: 'center', after: true }, 'a drop on the empty box puts the widget in it')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 489 }, false), { region: 'center', after: true }, 'a drop over the inner end of centerBegin, near the empty box, lands in the box')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 511 }, false), { region: 'center', after: true }, 'a drop over the inner end of centerEnd, near the empty box, lands in the box')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 485 }, false), { region: 'centerBegin', after: true }, 'a drop just short of the empty box lands at the end of centerBegin')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 515 }, false), { region: 'centerEnd', after: false }, 'a drop just past the empty box lands at the start of centerEnd')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 470 }, false), { slot: indicatorsSlot, after: false }, 'further off, a drop lands by the nearest widget')
assertDeepEqual(bar.centerDropTarget([menu], empty, { x: 20 }, false), { slot: menuSlot, after: true }, 'a drop far from the box still lands by the nearest widget')
// A widget picked up beside the empty box goes back where it was while the
// pointer is over its own room, though the box reaches over it.
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 506 }, false, weatherSlot), { slot: weatherSlot, after: false }, 'a drop over the dragged widget\'s own room puts it back, near the empty box as it is')
assertDeepEqual(bar.centerDropTarget(meeting, empty, { x: 495 }, false, weatherSlot), { region: 'center', after: true }, 'past its own room, the dragged widget goes into the box')
assertDeepEqual(bar.centerDropTarget([menu, dropRow(indicatorsSlot, 'centerBegin', 460, 40), dropRow(weatherSlot, 'centerEnd', 500, 0)], empty, { x: 500 }, false, weatherSlot), { region: 'center', after: true }, 'folded away, the dragged widget holds no room against the box')

// Vertical bars measure along y.
const vbox = { x: 0, y: 400, width: 26, height: 50 }
const vclock = { slot: boxClock, region: 'center', x: 0, y: 400, width: 26, height: 50 }
assertDeepEqual(bar.centerDropTarget([vclock], vbox, { x: 13, y: 440 }, true), { slot: boxClock, after: true }, 'vertical bars drop into the box along y')
assertDeepEqual(bar.centerDropTarget([vclock], vbox, { x: 13, y: 380 }, true), { region: 'centerBegin', after: true }, 'vertical bars drop above the box into centerBegin')
assertDeepEqual(bar.centerDropTarget([vclock], vbox, { x: 13, y: 470 }, true), { region: 'centerEnd', after: false }, 'vertical bars drop below the box into centerEnd')
assertDeepEqual(bar.centerDropTarget(full, null, { x: 345 }, false), bar.nearestDropTarget(full, { x: 345 }, false), 'a bar without a center box resolves drops as before')
assertEqual(bar.centerDropTarget(full, box, {}, false), null, 'an unreadable pointer resolves to no drop')

// A lifted widget answers at the point it left, so the pointer can put it back.
const lifted = { id: 'lifted' }
assertDeepEqual(
  bar.nearestDropTarget([{ slot: lifted, x: 200, y: 0, width: 0, height: 26 }, ...horizontalTargets], { x: 205, y: 13 }, false),
  { slot: lifted, after: false },
  'a widget with no room left still answers at its point'
)

// Where a drop opens room, by the keys each section shows: before the widget
// it lands by, or at the end of the section. In the left section a, the
// dragged b and c; the indicators alone in centerBegin.
const gapA = { widgetKey: 'a#1', region: 'left' }
const gapB = { widgetKey: 'b#2', region: 'left' }
const gapC = { widgetKey: 'c#3', region: 'left' }
const gapInd = { widgetKey: 'ind#4', region: 'centerBegin' }
const gapKeys = { left: ['a#1', 'b#2', 'c#3'], centerBegin: ['ind#4'], center: [], centerEnd: [], right: [], tray: [] }
const gapSource = { key: 'b#2', region: 'left' }
const home = { region: 'left', index: 1, home: true }
assertDeepEqual(bar.dropRoom({ slot: gapA, after: true }, gapSource, gapKeys), home, 'a drop after the widget before it puts the dragged widget back')
assertDeepEqual(bar.dropRoom({ slot: gapC, after: false }, gapSource, gapKeys), home, 'a drop before the widget after it puts the dragged widget back')
assertDeepEqual(bar.dropRoom({ slot: gapB, after: true }, gapSource, gapKeys), home, 'a drop on the dragged widget puts it back')
assertDeepEqual(bar.dropRoom(null, gapSource, gapKeys), home, 'the pointer off the bar puts the dragged widget back')
assertDeepEqual(bar.dropRoom({ slot: gapA, after: false }, gapSource, gapKeys), { region: 'left', index: 0, home: false }, 'a drop before a widget opens room before it')
assertDeepEqual(bar.dropRoom({ slot: gapC, after: true }, gapSource, gapKeys), { region: 'left', index: 3, home: false }, 'a drop after the last widget opens room at the end of the section')
assertDeepEqual(bar.dropRoom({ slot: gapInd, after: true }, gapSource, gapKeys), { region: 'centerBegin', index: 1, home: false }, 'a drop after the last widget of a section opens room at its end')
assertDeepEqual(bar.dropRoom({ region: 'centerBegin', after: true }, gapSource, gapKeys), { region: 'centerBegin', index: 1, home: false }, 'a drop at the end of a section opens the same room')
const fromElsewhere = { key: 'ind#4', region: 'centerBegin' }
assertDeepEqual(bar.dropRoom({ slot: gapA, after: true }, fromElsewhere, gapKeys), bar.dropRoom({ slot: gapB, after: false }, fromElsewhere, gapKeys), 'after one widget and before the next open the same room')
assertDeepEqual(bar.dropRoom({ region: 'centerEnd', after: false }, gapSource, gapKeys), { region: 'centerEnd', index: 0, home: false }, 'a drop in an empty section opens room in the section')
assertDeepEqual(bar.dropRoom({ region: 'center', after: true }, gapSource, gapKeys), { region: 'center', index: 0, home: false }, 'a drop in the empty box opens room in the box')
assertDeepEqual(bar.dropRoom({ region: 'center', after: true }, { key: 'clock#5', region: 'center' }, { center: ['clock#5'] }), { region: 'center', index: 0, home: true }, 'the only widget in the box dropped back on the empty box stays put')
// The drop is placed by the bar as it is now, so a widget that shows itself
// mid-drag, hidden as the drag started, can be dropped beside.
const shown = { widgetKey: 'd#6', region: 'right' }
assertDeepEqual(bar.dropRoom({ slot: shown, after: true }, gapSource, Object.assign({}, gapKeys, { right: ['d#6'] })), { region: 'right', index: 1, home: false }, 'a widget that has just shown itself can be dropped beside')
assertDeepEqual(bar.dropRoom({ slot: { widgetKey: 'gone#7', region: 'right' }, after: true }, gapSource, gapKeys), home, 'a drop by a widget the layout no longer holds puts the dragged widget back')
// A widget that draws nothing, as the keyboard layout with one layout, takes
// no place of its own: either side of it is the same place, and beside the
// dragged widget, home.
const hiddenKeys = { right: ['tray#1', 'kb#2', 'agents#3', 'net#4'] }
const drawnNow = { 'tray#1': true, 'agents#3': true, 'net#4': true }
const agents = { key: 'agents#3', region: 'right' }
assertEqual(bar.dropRoom({ slot: { widgetKey: 'tray#1', region: 'right' }, after: true }, agents, hiddenKeys, drawnNow).home, true, 'a drop after the widget before the dragged one, past a hidden one, puts it back')
const fromLeft = { key: 'menu#5', region: 'left' }
assertDeepEqual(bar.dropRoom({ slot: { widgetKey: 'tray#1', region: 'right' }, after: true }, fromLeft, hiddenKeys, drawnNow), bar.dropRoom({ slot: { widgetKey: 'agents#3', region: 'right' }, after: false }, fromLeft, hiddenKeys, drawnNow), 'after one widget and before the next drawn one are the same place')

// A move crossfades: the place left behind gives up the room as the new one
// takes it, however far apart, and the places together always hold all of it.
let crossfade = { 'right:0': 1 }
crossfade = bar.fadeShares(crossfade, 'right:3', 0.25)
assertDeepEqual(crossfade, { 'right:0': 0.75, 'right:3': 0.25 }, 'the new place takes the room as the old one gives it up, with nothing in between')
crossfade = bar.fadeShares(crossfade, 'right:3', 1)
assertDeepEqual(crossfade, { 'right:3': 1 }, 'a place that has given up all of the room is dropped')
// Moving again before the last move has finished: every place but the target
// keeps giving up the room, and the target holds the rest.
let retarget = bar.fadeShares({ 'right:0': 0.6, 'right:3': 0.4 }, 'right:1', 0.1)
assertEqual(Object.keys(retarget).length, 3, 'a place still handing over keeps handing over after the target moves on')
assert(Math.abs(Object.values(retarget).reduce((sum, share) => sum + share, 0) - 1) < 1e-9, 'the places still hold the whole room')
assert(Math.abs(retarget['right:1'] - 0.2) < 1e-9, 'the new target holds what the others have given up')
assertDeepEqual(bar.fadeShares({ 'right:0': 0.5, 'centerEnd:1': 0.5 }, 'centerEnd:1', 0), { 'right:0': 0.5, 'centerEnd:1': 0.5 }, 'a move to another section hands the room over the same way')

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

// The tray sits where the layout puts it, like any other widget, so the bar
// reads in the order the panel hotkeys count.
assert(!/pinTrayToInner/.test(barSource) && bar.pinTrayToInner === undefined, 'the bar keeps the tray where the layout puts it')

// The section list lives in Util for QML and in BarModel and TrayModel for
// plain JS; all three run the bar the same way.
const utilSource = fs.readFileSync(root + '/shell/Commons/Util.qml', 'utf8')
const utilSections = JSON.parse(utilSource.match(/readonly property var barSections: (\[[^\]]*\])/)[1])
assertDeepEqual(bar.sections, ['left', 'centerBegin', 'center', 'centerEnd', 'right', 'tray'], 'the bar runs left, centerBegin, center, centerEnd, right, with tray in the tray\'s drawer')
assertDeepEqual(utilSections, bar.sections, 'Util and BarModel list the same bar sections')
const trayModel = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')
for (const section of bar.sections)
  assert(trayModel.layoutHasWidget({ [section]: ['omarchy.dropbox'] }, 'omarchy.dropbox'), `the tray finds a widget in ${section}`)
assert(/function normalizeLayout\(layout\) \{\s*return Util\.normalizeLayout\(/.test(barSource), 'bar normalizes every section the way the shared helper does')

// Panel tabbing and positional hotkeys take the center as one section.
for (const region of ['centerBegin', 'center', 'centerEnd'])
  assertDeepEqual(bar.navigationRegions(region), ['centerBegin', 'center', 'centerEnd'], `panel navigation from ${region} walks all three center sections`)
assertDeepEqual(bar.navigationRegions('left'), ['left'], 'panel navigation in the left section stays in it')
assertDeepEqual(bar.navigationRegions('right'), ['right'], 'panel navigation in the right section stays in it')
assert(/var regions = BarModel\.navigationRegions\(region\)/.test(barSource), 'bar tabs panels across the center sections')

// The first and last of several widgets in the centered box grow away from
// its middle, as centerBegin's and centerEnd's do; one alone grows both ways.
assertDeepEqual([0, 1, 2].map(index => bar.slotEdge(3, index, 'center', 'end', 'start')), ['end', 'center', 'start'], 'the outer widgets of several grow away from the middle')
assertEqual(bar.slotEdge(1, 0, 'center', 'end', 'start'), 'center', 'a widget alone in the box grows both ways')
assertDeepEqual([0, 1].map(index => bar.slotEdge(2, index, 'end', '', '')), ['end', 'end'], 'a section without outer edges hands every widget its own')

// Every widget on the bar has a key it keeps wherever it moves, so each bar
// surface keeps one widget per key and hands it to whichever section shows it.
const widgetMemo = {}
const firstLayout = bar.layoutWidgets({ left: ['t.menu'], center: [{ id: 't.clock', format: 'HH:mm' }], right: [{ id: 't.audio' }] }, widgetMemo)
assertDeepEqual(Object.keys(firstLayout.sections), bar.sections, 'every section has its list of keys')
assertDeepEqual(firstLayout.keys, [...firstLayout.keys].sort(), 'the keys come in a fixed order, so a move never reorders the widgets')
assertDeepEqual(firstLayout.keys.length, 3, 'one key per entry')
const clockKey = firstLayout.sections.center[0]
assertDeepEqual(firstLayout.entries[clockKey], { id: 't.clock', format: 'HH:mm' }, 'a key\'s entry is the layout entry')
const movedLayout = bar.layoutWidgets({ left: ['t.menu', { id: 't.clock', format: 'HH:mm' }], right: [{ id: 't.audio' }] }, widgetMemo)
assertEqual(movedLayout.sections.left[1], clockKey, 'a widget moved to another section keeps its key')
assertEqual(movedLayout.entries[clockKey], firstLayout.entries[clockKey], 'and its entry object, so it hears of nothing')
assertDeepEqual(movedLayout.keys, firstLayout.keys, 'a move adds and removes no keys')
const changedLayout = bar.layoutWidgets({ left: ['t.menu'], centerEnd: [{ id: 't.clock', format: 'HH:mm:ss' }], right: [{ id: 't.audio' }] }, widgetMemo)
assertEqual(changedLayout.sections.centerEnd[0], clockKey, 'a widget moved and changed in one write keeps its key, and is updated in place')
assertDeepEqual(changedLayout.entries[clockKey], { id: 't.clock', format: 'HH:mm:ss' }, 'with its new settings')
assertEqual(changedLayout.entries[changedLayout.sections.left[0]], movedLayout.entries[movedLayout.sections.left[0]], 'an unchanged entry keeps its object')
const goneLayout = bar.layoutWidgets({ left: ['t.menu'], right: [{ id: 't.audio' }] }, widgetMemo)
assert(!goneLayout.keys.includes(clockKey), 'a widget the layout drops loses its key')
assertEqual(goneLayout.entries[clockKey], changedLayout.entries[clockKey], 'but keeps its entry for that update, so it isn\'t handed empty settings on its way out')
assertEqual(bar.layoutWidgets({ left: ['t.menu'], right: [{ id: 't.audio' }] }, widgetMemo).entries[clockKey], undefined, 'and only for that update')
const backLayout = bar.layoutWidgets({ left: ['t.menu'], center: [{ id: 't.clock', format: 'HH:mm:ss' }], right: [{ id: 't.audio' }] }, widgetMemo)
assert(backLayout.sections.center[0] !== clockKey, 'a widget added again is a new widget')

// The tray's drawer section reaches half the bar's thickness past either end,
// so an empty one is hit across the thickness, and the stretch only grows as
// room opens in the section from either end.
assertDeepEqual(bar.sectionDropZone({ x: 700, y: 3, width: 0, height: 20 }, 26, false), { x: 687, y: 3, width: 26, height: 20 }, 'an empty tray section is hit across the bar\'s thickness')
assertDeepEqual(bar.sectionDropZone({ x: 4, y: 300, width: 20, height: 30 }, 28, true), { x: 4, y: 286, width: 20, height: 58 }, 'a vertical bar reaches past the section along y')
const sectionZone = bar.sectionDropZone({ x: 700, y: 0, width: 0, height: 26 }, 26, false)
const grownLeft = bar.sectionDropZone({ x: 670, y: 0, width: 30, height: 26 }, 26, false)
const grownRight = bar.sectionDropZone({ x: 700, y: 0, width: 30, height: 26 }, 26, false)
for (const grown of [grownLeft, grownRight])
  assert(grown.x <= sectionZone.x && grown.x + grown.width >= sectionZone.x + sectionZone.width, 'room opening in the section, from either end, keeps the stretch it reached before')
const trayRows = [dropRow(weatherSlot, 'tray', 660, 40), dropRow(menuSlot, 'right', 740, 30)]
assertEqual(bar.traySectionDropTarget(trayRows, null, { x: 680 }, false), null, 'no tray section, no drop in it')
assertEqual(bar.traySectionDropTarget(trayRows, bar.sectionDropZone({ x: 660, y: 0, width: 40, height: 26 }, 26, false), { x: 720 }, false), null, 'off the section, its widgets are out of reach')
assertDeepEqual(bar.traySectionDropTarget(trayRows, bar.sectionDropZone({ x: 660, y: 0, width: 40, height: 26 }, 26, false), { x: 690 }, false), { slot: weatherSlot, after: true }, 'over the section, a drop lands among its widgets')
assertDeepEqual(bar.traySectionDropTarget([trayRows[1]], sectionZone, { x: 708 }, false), { region: 'tray', after: true }, 'over an empty section, a drop lands in it')
const besideTray = { id: 'beside' }
assertDeepEqual(bar.traySectionDropTarget([trayRows[1], dropRow(besideTray, 'right', 705, 30)], sectionZone, { x: 708 }, false, besideTray), { slot: besideTray, after: false }, 'over the dragged widget\'s own room, it goes back')
// The tray's own ends stay where a drop lands beside the tray, even where its
// section reaches them with no pinned icons between: here the tray alone in
// centerEnd, hanging off the center box, with its section first.
const trayAtBox = { id: 'tray' }
const elsewhen = { id: 'elsewhen' }
const inSection = { id: 'indicators' }
const boxRow = dropRow(elsewhen, 'center', 300, 100)
const trayRow = dropRow(trayAtBox, 'centerEnd', 400, 120)
const trayAtBoxZone = bar.sectionDropZone({ x: 400, y: 0, width: 80, height: 26 }, 26, false, { x: 400, y: 0, width: 120, height: 26 })
const dropAt = x => bar.traySectionDropTarget([boxRow, trayRow, dropRow(inSection, 'tray', 400, 80)], trayAtBoxZone, { x }, false) ||
  bar.centerDropTarget([boxRow, trayRow], { x: 300, y: 0, width: 100, height: 26 }, { x }, false)
assertDeepEqual(dropAt(405), { slot: trayAtBox, after: false }, 'just past the center box, a drop lands before a tray whose section comes first')
assertDeepEqual(dropAt(395), { slot: elsewhen, after: true }, 'over the end of the box, a drop still lands in the box')
assertDeepEqual(dropAt(425), { slot: inSection, after: false }, 'further in, a drop goes into the tray section')
assertDeepEqual(bar.sectionDropZone({ x: 480, y: 0, width: 40, height: 26 }, 26, false, { x: 400, y: 0, width: 120, height: 26 }), { x: 467, y: 0, width: 40, height: 26 }, 'a section that ends the tray stops short of its end, so a drop there lands after the tray')
assertDeepEqual(bar.sectionDropZone({ x: 400, y: 0, width: 0, height: 26 }, 26, false, { x: 400, y: 0, width: 120, height: 26 }), { x: 413, y: 0, width: 26, height: 26 }, 'an empty section at the tray\'s start is hit across the bar\'s thickness, inward')
assertDeepEqual(bar.sectionDropZone({ x: 400, y: 0, width: 0, height: 26 }, 26, false, { x: 400, y: 0, width: 40, height: 26 }), { x: 413, y: 0, width: 14, height: 26 }, 'in a tray too short for both, the tray\'s ends still come first')
assertDeepEqual(bar.sectionDropZone({ x: 4, y: 300, width: 20, height: 30 }, 28, true, { x: 0, y: 260, width: 28, height: 120 }), { x: 4, y: 286, width: 20, height: 58 }, 'a section well inside the tray reaches past it by half the bar\'s thickness as before')

// Two entries with one id keep their own widgets: by their settings first,
// then in order.
const dupeMemo = {}
const dupes = bar.layoutWidgets({ centerBegin: [{ id: 'omarchy.indicators', items: ['Dnd'] }], right: [{ id: 'omarchy.indicators', items: ['NightLight'] }] }, dupeMemo)
const dnd = dupes.sections.centerBegin[0]
const night = dupes.sections.right[0]
assert(dnd !== night, 'repeated widgets get keys of their own')
const dupesMoved = bar.layoutWidgets({ left: [{ id: 'omarchy.indicators', items: ['NightLight'] }], centerBegin: [{ id: 'omarchy.indicators', items: ['Dnd'] }] }, dupeMemo)
assertEqual(dupesMoved.sections.left[0], night, 'one of two entries with one id moved past the other keeps its own widget')
assertEqual(dupesMoved.sections.centerBegin[0], dnd, 'as does the other')
const dupesChanged = bar.layoutWidgets({ left: [{ id: 'omarchy.indicators', items: ['NightLight'] }], centerBegin: [{ id: 'omarchy.indicators', items: ['Dnd', 'Reminder'] }] }, dupeMemo)
assertDeepEqual([dupesChanged.sections.left[0], dupesChanged.sections.centerBegin[0]], [night, dnd], 'the one whose settings changed takes the widget its id has left over')
// One of two entries with one id changing, or going, leaves the other with
// its own widget, in its own section.
const pairMemo = {}
const pair = bar.layoutWidgets({ left: [{ id: 't.b', tag: 'x' }, 't.menu'], right: ['t.a', { id: 't.b', tag: 'y' }] }, pairMemo)
const pairChanged = bar.layoutWidgets({ left: [{ id: 't.b', tag: 'y' }, 't.menu'], right: ['t.a', { id: 't.b', tag: 'y' }] }, pairMemo)
assertDeepEqual([pairChanged.sections.left[0], pairChanged.sections.right[1]], [pair.sections.left[0], pair.sections.right[1]], 'an entry changed to match its twin in another section keeps its own widget')
const both = bar.layoutWidgets({ right: [{ id: 't.b', tag: 'x' }, { id: 't.b', tag: 'y' }] }, {})
const bothMemo = {}
bar.layoutWidgets({ right: [{ id: 't.b', tag: 'x' }, { id: 't.b', tag: 'y' }] }, bothMemo)
const bothMoved = bar.layoutWidgets({ left: [{ id: 't.b', tag: 'y' }, { id: 't.b', tag: 'x' }] }, bothMemo)
assertDeepEqual(bothMoved.sections.left.map(key => bothMoved.entries[key].tag + ':' + key), ['y:' + both.sections.right[1], 'x:' + both.sections.right[0]], 'two entries with one id moved to another section, and reordered, each keep their own widget')
const pairGone = bar.layoutWidgets({ left: ['t.menu'], right: ['t.a', { id: 't.b', tag: 'z' }] }, pairMemo)
assertEqual(pairGone.sections.right[1], pair.sections.right[1], 'with its twin gone, a changed entry keeps its own widget rather than the one going')
// Ids are anything a layout says.
const protoMemo = {}
for (const id of ['constructor', 'hasOwnProperty', 'toString', '__proto__']) {
  bar.layoutWidgets({ right: [{ id }] }, protoMemo)
  const twice = bar.layoutWidgets({ right: [{ id }, { id, w: 2 }] }, protoMemo)
  assertEqual(twice.sections.right.length, 2, `a widget with the id ${id} is just a widget`)
}
const twinMemo = {}
const twinsBefore = bar.layoutWidgets({ right: ['t.ind', 't.ind', 't.ind'] }, twinMemo).sections.right
const twinsAfter = bar.layoutWidgets({ right: [{ id: 't.ind', items: ['Dnd'] }, 't.ind', 't.ind'] }, twinMemo).sections.right
assertDeepEqual(twinsAfter, twinsBefore, 'one of three identical entries changing leaves every widget in its place')
const customTwinMemo = {}
const customBefore = bar.layoutWidgets({ right: [{ id: 'local.x', exec: 'date' }, { id: 'local.x', exec: 'date' }, { id: 'local.x', exec: 'date' }] }, customTwinMemo).sections.right
const customAfter = bar.layoutWidgets({ right: [{ id: 'local.x', exec: 'uptime' }, { id: 'local.x', exec: 'date' }, { id: 'local.x', exec: 'date' }] }, customTwinMemo).sections.right
assert(!customBefore.includes(customAfter[0]) && customAfter[1] === customBefore[1] && customAfter[2] === customBefore[2], 'a changed custom module among identical ones is rebuilt in its place, and the others stay put')
const sameMemo = {}
const twins = bar.layoutWidgets({ right: ['t.a', 't.a'] }, sameMemo)
assertDeepEqual(bar.layoutWidgets({ right: ['t.a', 't.a'] }, sameMemo).sections.right, twins.sections.right, 'identical entries keep their keys in order')

// One of two entries with one id changed to match the other keeps its own
// widget, as does the other.
const matchMemo = {}
const matchBefore = bar.layoutWidgets({ right: [{ id: 't.clock', format: 'A' }, { id: 't.clock', format: 'B' }] }, matchMemo).sections.right
assertDeepEqual(bar.layoutWidgets({ right: [{ id: 't.clock', format: 'B' }, { id: 't.clock', format: 'B' }] }, matchMemo).sections.right, matchBefore, 'an entry changed to match its twin keeps its own widget')

// A move the bar writes itself says which widget went where, so each of two
// widgets alike in every way keeps its own instance: the dragged one where it
// lands, the other where it was.
const dragMemo = {}
const dragFrom = bar.layoutWidgets({ left: ['t.menu'], right: ['t.a', 't.ind', 't.c', 't.ind'] }, dragMemo).sections
const [firstInd, secondInd] = [dragFrom.right[1], dragFrom.right[3]]
dragMemo.expected = { left: [dragFrom.left[0], firstInd], right: [dragFrom.right[0], dragFrom.right[2], secondInd] }
const dragTo = bar.layoutWidgets({ left: ['t.menu', 't.ind'], right: ['t.a', 't.c', 't.ind'] }, dragMemo).sections
assertEqual(dragTo.left[1], firstInd, 'the first of two identical widgets dragged to another section takes its own instance with it')
assertEqual(dragTo.right[2], secondInd, 'and the other keeps its own where it was')
assertEqual(dragMemo.expected, null, 'the bar\'s word on a move holds for that write alone')
dragMemo.expected = { left: [dragTo.left[0]], right: [secondInd, dragTo.right[0], dragTo.right[1], firstInd] }
const dragBack = bar.layoutWidgets({ left: ['t.menu'], right: ['t.ind', 't.a', 't.c', 't.ind'] }, dragMemo).sections
assertDeepEqual([dragBack.right[0], dragBack.right[3]], [secondInd, firstInd], 'one of two identical widgets dragged past the other within a section keeps its own instance')
dragMemo.expected = { left: [dragBack.right[1]], right: [] }
const notAsSaid = bar.layoutWidgets({ left: ['t.menu'], right: ['t.ind', 't.a', 't.c', 't.ind'] }, dragMemo).sections
assertDeepEqual(notAsSaid, dragBack, 'a layout that isn\'t the one the bar expected is matched by its entries, as one written from elsewhere')

const sortedMemo = {}
const unsorted = bar.layoutWidgets({ right: [{ id: 'local.status', exec: 'date', interval: 5 }] }, sortedMemo)
const resorted = bar.layoutWidgets({ right: [{ exec: 'date', id: 'local.status', interval: 5 }] }, sortedMemo)
assertEqual(resorted.sections.right[0], unsorted.sections.right[0], 'an entry written back with its keys sorted keeps its widget')
assertEqual(resorted.entries[resorted.sections.right[0]], unsorted.entries[unsorted.sections.right[0]], 'and its entry object')
const customKey = resorted.sections.right[0]
assert(bar.layoutWidgets({ right: [{ id: 'local.status', exec: 'uptime', interval: 5 }] }, sortedMemo).sections.right[0] !== customKey, 'a custom module, which reads its entry directly, gets a new widget when its entry changes')
const turnMemo = {}
const plain = bar.layoutWidgets({ right: [{ id: 'local.x' }] }, turnMemo).sections.right[0]
const turned = bar.layoutWidgets({ right: [{ id: 'local.x', exec: 'date' }] }, turnMemo).sections.right[0]
assert(turned !== plain, 'an entry that becomes a custom module gets a new widget')
assert(bar.layoutWidgets({ right: [{ id: 'local.x' }] }, turnMemo).sections.right[0] !== turned, 'as does a custom module that stops being one')

// A section's rows hold just their keys, so a row is the same object for as
// long as it is shown, and the model only adds, moves and removes rows.
const rowMemo = {}
const firstRows = bar.sectionRows(['a#1', 'b#2'], [], rowMemo)
assertDeepEqual(firstRows, [{ key: 'a#1', kind: 'widget' }, { key: 'b#2', kind: 'widget' }], 'a widget\'s row is its key')
const reordered = bar.sectionRows(['b#2', 'a#1'], [], rowMemo)
assert(reordered[0] === firstRows[1] && reordered[1] === firstRows[0], 'reordered rows are the very same objects')
assert(bar.sectionRows(['a#1', 'b#2', 'c#3'], [], rowMemo)[0] === firstRows[0], 'a row added beside others leaves theirs alone')
assertDeepEqual(
  bar.sectionRows(['a#1', 'b#2'], [2, 1], {}).map(row => row.kind + ':' + (row.place === undefined ? row.key : row.place)),
  ['widget:a#1', 'spacer:1', 'widget:b#2', 'spacer:2'],
  'a spacer sits before the widget at its index, or past the last'
)
assertDeepEqual(
  bar.sectionRows([], [0], {}).map(row => row.key),
  ['room:0'],
  'an empty section holds just the spacer'
)

// A layout places items on whole pixels, so the places get whole lengths
// that add up to the rounded room, however it is split between them.
for (const extent of [29, 30, 47]) {
  for (const shares of [{ 0: 1 }, { 0: 0.5, 3: 0.5 }, { 0: 0.33, 1: 0.33, 2: 0.34 }, { 1: 0.71, 2: 0.29 }, { 0: 0.05, 2: 0.15, 4: 0.8 }]) {
    const lengths = bar.roomLengths(extent, shares)
    assertEqual(Object.values(lengths).reduce((sum, length) => sum + length, 0), extent, `the places add up to the whole ${extent}px room for ${JSON.stringify(shares)}`)
    assert(Object.values(lengths).every(length => Number.isInteger(length)), 'every place is a whole number of pixels')
  }
}
assertDeepEqual(bar.roomLengths(40, { 2: 0.5 }), { 2: 20 }, 'a half open room is half as long')

assertEqual(bar.moduleString({ id: 'custom', label: 42 }, 'label', 'fallback'), '42', 'bar stringifies module settings')

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
