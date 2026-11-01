import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.monitor"
  ipcTarget: "omarchy.monitor"
  manageIpc: false

  // manageIpc: false so this panel can own the single IpcHandler the target
  // permits — needed for the brightness + state methods below.
  // brightnessPercent and brightnessAvailable are the focused display's, which
  // the bar icon's wheel follows; each display's own level lives in
  // brightnessLevels.
  property int brightnessPercent: 0
  property bool brightnessAvailable: false
  property var brightnessLevels: ({})
  property string pendingBrightnessMonitor: ""
  property int pendingBrightnessPercent: 0
  property bool brightnessSetQueued: false
  property string internalMonitor: ""
  property string externalMonitor: ""
  property string focusedMonitor: ""
  property bool internalEnabled: false
  // Omarchy's mirror toggle is on, so Extend can turn it back off.
  property bool mirrorManaged: false
  property string monitorScale: ""
  property string displaysJson: ""
  property var displays: []

  // The display the panel is showing. Each open starts on the focused one.
  property string selectedName: ""

  // Carry sub-notch touchpad deltas between wheel events.
  property real wheelAccumulator: 0

  // Cursor model shared by keyboard and mouse. Sections, top to bottom:
  //   "displays"   - the display picker in the hero; h/l shows the next one.
  //                  Only present with more than one display.
  //   "brightness" - the shown display's brightness slider, selectedIndex = -1
  //                  sentinel (mirrors Audio's slider rows); only present when
  //                  its brightness can be controlled.
  //   "textsize"   - single slider row, the same -1 sentinel; one size for
  //                  every display.
  //   "scale"      - the shown display's scale presets.
  //   "resolution" - the resolutions it advertises, when it has more than one
  //                  to offer.
  //   "refresh"    - the refresh rates its resolution offers, when one is
  //                  faster than 60Hz.
  //   "mirror"     - Mirror or Extend, when there's a built-in display and an
  //                  external one to mirror it on.
  //   "layout"     - the arrangement of the displays; ctrl+h/j/k/l places
  //                  the shown one left of, below, above or right of the rest.
  // Every section is one row: j/k steps between them, h/l moves a slider or
  // walks a row of pills, identical to bluetooth's header. r opens the shown
  // display's rotate menu from anywhere, which j/k and Enter then walk.
  // Mouse hover on a target updates root state via the components' `hovered`
  // signal so keyboard cursor and pointer share one highlight.
  readonly property var scalePresets: ["1", "1.25", "1.6", "2", "3", "4"]
  // One entry per display that's on, in Hyprland's order, with the scales its
  // mode can reach and the resolutions it offers. Brightness stays out of it,
  // in brightnessLevels, so a slider moving doesn't rebuild the picker.
  readonly property var segments: {
    var list = []
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (!display || !display.name || !display.enabled || !(display.width > 0)) continue
      // Matched here, on the plain arrays: once they're handed through a QML
      // property they're no longer ones Array.isArray accepts.
      var scales = Model.availableScales(scalePresets, display.width, display.height)
      var resolutions = Model.resolutionOptions(display.availableModes, display.width, display.height)
      list.push({
        name: display.name,
        title: Model.displayTitle(display, Commons.I18n.t("monitor.builtInDisplay")),
        builtIn: /^(eDP|LVDS|DSI)-/.test(display.name),
        focused: !!display.focused,
        width: display.width,
        height: display.height,
        current: display.width + "x" + display.height,
        scales: scales,
        scaleIndex: Model.matchingScaleIndex(scales, display.scale, display.width, display.height),
        resolutions: resolutions.length > 1 ? resolutions : [],
        refreshes: Model.refreshOptions(display.availableModes, display.width, display.height),
        refreshRate: Number(display.refreshRate) || 0
      })
    }
    return list
  }

  // The shown display: the one picked, else the focused one, else the first.
  readonly property var current: {
    var fallback = null
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].name === selectedName) return segments[i]
      if (segments[i].focused && !fallback) fallback = segments[i]
    }
    return fallback || (segments.length > 0 ? segments[0] : null)
  }
  readonly property int currentIndex: segments.indexOf(current)
  readonly property int currentBrightness: current ? brightnessOf(current.name) : -1

  // The displays that are on and not mirroring another, where they sit.
  // Switching to Mirror reloads Hyprland, and a read can come back from
  // before it lands, so the map shows the stack as soon as Mirror is clicked:
  // every external display mirroring the built-in one, as
  // omarchy-hyprland-monitor-internal-mirror sets it up. "on" or "off" while
  // a switch is on its way; Extend keeps the stack until the real layout,
  // with the external back in its own place, comes in.
  property string pendingMirror: ""
  readonly property var layoutDisplays: {
    if (pendingMirror !== "on") return displays
    var internal = ""
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (display && display.enabled && /^(eDP|LVDS|DSI)-/.test(display.name)) { internal = display.name; break }
    }
    if (!internal) return displays
    var list = []
    for (var j = 0; j < displays.length; j++) {
      var entry = displays[j]
      if (entry && entry.enabled && !/^(eDP|LVDS|DSI)-/.test(entry.name)) {
        var copy = {}
        for (var key in entry) copy[key] = entry[key]
        copy.mirrorOf = internal
        entry = copy
      }
      list.push(entry)
    }
    return list
  }

  readonly property var layoutRects: {
    var list = []
    for (var i = 0; i < layoutDisplays.length; i++) {
      var display = layoutDisplays[i]
      if (!display || !display.enabled || !(display.width > 0)) continue
      if (display.mirrorOf && display.mirrorOf !== "none") continue
      list.push(Model.logicalRect(display))
    }
    return list
  }

  // The displays showing each layout rect's picture, keyed by the rect's name.
  // With one box in the map, a lone display or a mirrored stack, there's
  // nothing to move it against: no dragging, hover or keyboard stop, and no
  // accent marking the shown display. Right-clicking it still rotates it.
  readonly property bool layoutMovable: layoutRects.length > 1
  // The section shows when there's something to arrange or to mirror onto,
  // not for a lone display; r still rotates that one.
  readonly property bool layoutShown: layoutMovable || mirrorAvailable

  readonly property var mirroredBy: {
    var map = {}
    for (var i = 0; i < layoutDisplays.length; i++) {
      var display = layoutDisplays[i]
      if (!display || !display.enabled || !display.mirrorOf || display.mirrorOf === "none") continue
      if (!map[display.mirrorOf]) map[display.mirrorOf] = []
      map[display.mirrorOf].push(display.name)
    }
    return map
  }

  // Some display is showing another's picture, or is about to.
  readonly property bool mirroredNow: {
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (display && display.enabled && display.mirrorOf && display.mirrorOf !== "none") return true
    }
    return false
  }
  readonly property bool mirrorEnabled: pendingMirror !== "" ? pendingMirror === "on" : mirroredNow
  // omarchy-hyprland-monitor-internal-mirror puts the built-in display's
  // picture on every external one, so it needs the built-in display on, not
  // shut in clamshell, and an external one. A mirror set up in
  // the user's own monitors.lua is theirs to undo, so Extend isn't offered.
  readonly property bool mirrorAvailable: internalEnabled && externalMonitor !== "" && (!mirrorEnabled || mirrorManaged || pendingMirror !== "")
  readonly property var mirrorModes: ["mirror", "extend"]

  function displayGlyph(entry) {
    return entry && entry.builtIn ? "󰌢" : "󰍹"
  }

  // A lone slider, held at the -1 sentinel.
  function isSliderSection(section) {
    return section === "textsize" || section === "brightness"
  }

  // A display's brightness percent, or -1 when it can't be controlled.
  function brightnessOf(name) {
    var level = brightnessLevels[name]
    return level === undefined || level === null ? -1 : level
  }

  function pointAt(section, index) {
    if (root.reflowingText) return
    root.cursorActive = true
    root.focusSection = section
    root.selectedIndex = index
  }

  function selectDisplay(name) {
    root.selectedName = name
  }

  property string focusSection: ""
  property int selectedIndex: 0
  property bool cursorActive: false

  // Text size slider — curated macOS-style notches (px). The panel snaps to
  // these stops; the CLI (omarchy-display-text-size) accepts any integer in range.
  readonly property var textSizeStops: [9, 10, 11, 12, 14, 16, 20]
  // While a change is in flight, the chosen stop index overrides the live
  // base-size so the knob doesn't snap back during the file round-trip. -1 =
  // no pending change; follow Style.font.baseSize.
  property int textSizePreviewIndex: -1

  // A text-size change reflows the whole panel (both font and spacing scale),
  // which slides rows under a stationary pointer and fires synthetic hover.
  // While true, hover is not allowed to hijack the keyboard focus section —
  // otherwise h/l on the text-size slider can jump focus to another row.
  property bool reflowingText: false
  function markReflowing() {
    root.reflowingText = true
    reflowSettle.restart()
  }

  readonly property var visibleSections: {
    var list = []
    if (segments.length > 1) list.push("displays")
    if (currentBrightness >= 0) list.push("brightness")
    list.push("textsize")
    if (current && current.scales.length > 0) list.push("scale")
    if (current && current.resolutions.length > 0) list.push("resolution")
    if (current && current.refreshes.length > 0) list.push("refresh")
    if (mirrorAvailable) list.push("mirror")
    if (layoutMovable) list.push("layout")
    return list
  }

  function sectionCount(section) {
    if (section === "displays") return segments.length
    if (section === "scale") return current ? current.scales.length : 0
    if (section === "resolution") return current ? current.resolutions.length : 0
    if (section === "refresh") return current ? current.refreshes.length : 0
    if (section === "mirror") return mirrorModes.length
    if (section === "layout") return 1
    return 0  // sliders: only the sentinel at -1
  }

  function sectionFirstIndex(section) {
    if (isSliderSection(section)) return -1
    if (section === "displays") return Math.max(0, currentIndex)
    // The other choice, so arriving shows as it turns bold, and Enter switches.
    if (section === "mirror") return mirrorEnabled ? 1 : 0
    return 0
  }

  // Where the keyboard lands on open: the shown display's brightness, else its
  // scale, else the first row there is.
  function landingSection() {
    var sections = visibleSections
    var preferred = ["brightness", "scale"]
    for (var i = 0; i < preferred.length; i++)
      if (sections.indexOf(preferred[i]) >= 0) return preferred[i]
    return sections.length > 0 ? sections[0] : ""
  }

  function moveCursor(delta) {
    var sections = visibleSections
    if (!sections || sections.length === 0) return
    var sIdx = sections.indexOf(focusSection)
    var next = sIdx < 0 ? 0 : Math.max(0, Math.min(sections.length - 1, sIdx + delta))
    if (next === sIdx) return
    focusSection = sections[next]
    selectedIndex = sectionFirstIndex(focusSection)
  }

  // h/l: a slider moves, the picker shows the next display and a row of pills
  // walks its pills. The layout takes ctrl+h/l instead, like ctrl+j/k.
  function moveCursorH(delta) {
    if (focusSection === "brightness") {
      if (current) adjustBrightness(current.name, delta * 5)
    } else if (focusSection === "textsize") {
      adjustTextSize(delta)
    } else if (focusSection === "displays") {
      var next = Math.max(0, Math.min(segments.length - 1, currentIndex + delta))
      selectDisplay(segments[next].name)
      selectedIndex = next
    } else if (focusSection === "scale" || focusSection === "resolution" || focusSection === "refresh" || focusSection === "mirror") {
      selectedIndex = Math.max(0, Math.min(sectionCount(focusSection) - 1, selectedIndex + delta))
    }
  }

  function activateCursor() {
    if (focusSection === "mirror" && selectedIndex >= 0 && selectedIndex < mirrorModes.length) {
      setMirror(mirrorModes[selectedIndex] === "mirror")
      return
    }
    if (!current) return
    if (focusSection === "scale" && selectedIndex >= 0 && selectedIndex < current.scales.length)
      setScale(current.name, current.scales[selectedIndex])
    else if (focusSection === "resolution" && selectedIndex >= 0 && selectedIndex < current.resolutions.length)
      setResolution(current.name, current.resolutions[selectedIndex])
    else if (focusSection === "refresh" && selectedIndex >= 0 && selectedIndex < current.refreshes.length)
      setResolution(current.name, current.current + "@" + current.refreshes[selectedIndex].rate)
    // The picker, sliders and layout: moving is the action.
  }

  function clampCursor() {
    var sections = visibleSections
    if (!sections || !sections.length) return
    if (sections.indexOf(focusSection) < 0) {
      focusSection = sections[0]
      selectedIndex = sectionFirstIndex(focusSection)
      return
    }
    // Sliders use the -1 sentinel; everything else clamps into its row.
    var count = sectionCount(focusSection)
    if (isSliderSection(focusSection)) selectedIndex = -1
    else if (selectedIndex < 0 || selectedIndex >= count) selectedIndex = 0
  }

  // Keep the keyboard-focused row inside the viewport when the panel grows
  // taller than its allotted height. Mirrors audio's ensureCursorVisible helper.
  function ensureCursorVisible(item) {
    var scrollArea = panel.loadedContent ? panel.loadedContent.scrollArea : null
    if (!item || !scrollArea) return
    var flick = scrollArea.contentItem
    if (!flick || flick.contentY === undefined) return
    var pt = item.mapToItem(flick.contentItem || flick, 0, 0)
    var top = pt.y
    var bottom = top + (item.height || 0)
    var viewTop = flick.contentY
    var viewBottom = viewTop + flick.height
    var margin = 6
    // Never past either end: the last row sits flush with the bottom when the
    // panel fits, and a margin there would push the hero off the top.
    var maxY = Math.max(0, flick.contentHeight - flick.height)
    if (top < viewTop + margin) flick.contentY = Math.max(0, top - margin)
    else if (bottom > viewBottom - margin)
      flick.contentY = Math.min(maxY, bottom + margin - flick.height)
  }

  function brightnessIpc(percent) {
    var value = Number(percent)
    root.setBrightness(value)
    return "got " + root.pendingBrightnessPercent
  }

  function stateIpc() {
    return JSON.stringify({
      brightness: root.brightnessPercent,
      brightnessAvailable: root.brightnessAvailable,
      focusedMonitor: root.focusedMonitor,
      scale: root.monitorScale,
      displays: root.displays
    })
  }

  ShellIpc {
    target: "omarchy.monitor"

    function brightness(percent: string): string { return root.brightnessIpc(percent) }
    function state(): string { return root.stateIpc() }
    function open() { root.open() }
    function close() { root.close() }
    function toggle() { root.toggle() }
    function show() { root.open() }
    function hide() { root.close() }
  }

  function refresh() {
    if (!stateProc.running) stateProc.running = true
  }

  // The focused display's brightness, for the bar icon's wheel and IPC.
  function setBrightness(value) {
    setDisplayBrightness(root.focusedMonitor, value)
  }

  // Show a level right away, before the set behind it lands.
  function showBrightness(name, percent) {
    var levels = {}
    for (var key in brightnessLevels) levels[key] = brightnessLevels[key]
    levels[name] = percent
    root.brightnessLevels = levels
    if (name === root.focusedMonitor) root.brightnessPercent = percent
  }

  function setDisplayBrightness(name, value) {
    var percent = Model.clampBrightness(value)
    showBrightness(name, percent)
    root.pendingBrightnessMonitor = name
    root.pendingBrightnessPercent = percent

    if (setBrightnessProc.running) {
      root.brightnessSetQueued = true
      return
    }

    root.brightnessSetQueued = false
    setBrightnessProc.command = ["omarchy-brightness-display", "--no-osd", "--monitor", name, percent + "%"]
    setBrightnessProc.running = true
  }

  function previewBrightness(name, value) {
    var percent = Model.clampBrightness(value)
    showBrightness(name, percent)
    root.pendingBrightnessMonitor = name
    root.pendingBrightnessPercent = percent
    brightnessDebounce.restart()
  }

  function adjustBrightness(name, delta) {
    var level = brightnessOf(name)
    if (level < 0) return
    setDisplayBrightness(name, level + delta)
  }

  function showBrightnessOsd(percent) {
    if (!bar || !bar.shell) return
    bar.shell.summon("omarchy.osd", JSON.stringify({
      icon: "brightness",
      value: percent
    }))
  }

  function normalizeScale(scale) {
    return Model.normalizeScale(scale)
  }

  // Playful mood-name for a given brightness percent. Bands intentionally
  // span ~10–20 points so casual tweaks change the label, while small
  // nudges within one band don't.
  function brightnessName(percent) {
    return Model.brightnessName(percent, Commons.I18n.t)
  }

  // Brightness is taken from every poll, so a level set elsewhere replaces one
  // shown here. The list itself is only taken when something besides
  // brightness changed: a new one rebuilds the picker and the layout, which
  // would drop a hover or a drag in progress on each poll.
  function updateDisplays(displaysJson) {
    var parsed = Model.parseDisplays(displaysJson)
    var levels = {}
    for (var i = 0; i < parsed.displays.length; i++) {
      var display = parsed.displays[i]
      if (display && display.enabled && typeof display.brightness === "number")
        levels[display.name] = display.brightness
    }
    root.brightnessLevels = levels

    var shape = JSON.stringify(parsed.displays, function(key, value) { return key === "brightness" ? undefined : value })
    if (shape === root.displaysJson) return
    root.displaysJson = shape
    root.displays = parsed.displays
  }

  // One display command at a time, in the order asked: a second key press or
  // drop while the first is still applying waits its turn instead of being
  // lost, as starting a running Process again would lose it. A queued move
  // waits as the work to place it, not as positions: a scale or rotation
  // ahead of it changes the sizes it has to fit around, so it's worked out
  // from a state read that started after everything before it landed.
  property var queuedActions: []
  property bool awaitingFreshState: false
  readonly property bool actionBusy: actionProc.running || queuedActions.length > 0 || awaitingFreshState
  // Finished commands, and how many had finished when the running state read
  // started, so a read already under way when a command ended isn't fresh.
  property int actionsDone: 0
  property int readAfterActions: 0
  property bool rereadState: false

  function runAction(command) {
    if (actionBusy) {
      queuedActions = queuedActions.concat([{ command: command }])
      return
    }
    actionProc.command = command
    actionProc.running = true
  }

  function runNextAction() {
    if (actionProc.running || awaitingFreshState) return
    if (queuedActions.length === 0) {
      // A read already under way started before this command landed.
      if (stateProc.running) rereadState = true
      else refresh()
      return
    }
    var next = queuedActions[0]
    if (next.layout) {
      // Placed by the state read once a fresh one lands; see stateProc.
      awaitingFreshState = true
      if (stateProc.running) rereadState = true
      else refresh()
      return
    }
    queuedActions = queuedActions.slice(1)
    actionProc.command = next.command
    actionProc.running = true
  }

  // The queued move at the front, worked out now the state is fresh.
  function placeQueuedLayout() {
    awaitingFreshState = false
    var next = queuedActions[0]
    queuedActions = queuedActions.slice(1)
    var rects = next.layout()
    if (rects && !Model.sameLayout(rects, Model.normalizeLayout(Model.copyRects(layoutRects)))) {
      pendingRects = rects
      actionProc.command = layoutCommand(rects)
      actionProc.running = true
    } else {
      runNextAction()
    }
  }

  function setScale(name, scale) {
    runAction(["omarchy-hyprland-monitor-scaling", "--monitor", name, scale])
  }

  function setResolution(name, resolution) {
    runAction(["omarchy-hyprland-monitor-resolution", "--monitor", name, resolution])
  }

  function setMirror(enabled) {
    if (enabled === mirrorEnabled) return
    pendingMirror = enabled ? "on" : "off"
    mirrorSettle.restart()
    runAction(["omarchy-hyprland-monitor-internal-mirror", enabled ? "on" : "off"])
  }

  function setRotation(name, degrees) {
    runAction(["omarchy-hyprland-monitor-rotate", "--monitor", name, String(degrees)])
  }

  // The layout map's right-click menu: the display it's for, where it opened
  // within the panel, and that display's quarter turn now.
  property string rotateMenuName: ""
  // The keyboard's row in the rotate menu, a quarter turn each.
  property int rotateMenuIndex: 0
  property real rotateMenuX: 0
  property real rotateMenuY: 0
  readonly property int rotateMenuTransform: {
    for (var i = 0; i < displays.length; i++)
      if (displays[i] && displays[i].name === rotateMenuName) return Number(displays[i].transform) || 0
    return 0
  }

  // Opens where `item` was clicked, at (x, y) within it, in panel coordinates.
  function openRotateMenu(name, item, x, y) {
    var spot = item.mapToItem(panel.loadedContent, x, y)
    rotateMenuName = name
    rotateMenuX = spot.x
    rotateMenuY = spot.y
    rotateMenuIndex = rotateMenuTransform % 4
  }

  // r: the shown display's rotate menu, opened over the middle of the map.
  function openRotateMenuForShown() {
    var content = panel.loadedContent
    if (!current || !content) return
    var map = content.layoutMap
    // A lone display has no map, so the menu opens near the top instead.
    if (map && map.visible) openRotateMenu(current.name, map, map.width / 2, map.height / 2)
    else openRotateMenu(current.name, content, content.width / 2, Style.space(60))
  }

  function applyRotateMenu() {
    setRotation(rotateMenuName, rotateMenuIndex * 90)
    closeRotateMenu()
  }

  // ctrl+h/j/k/l on the layout: the shown display to that side of the rest.
  function placeShown(side) {
    if (!current || !layoutMovable) return
    var name = current.name
    applyLayout(function() { return Model.placeDisplay(layoutRects, name, side) })
  }

  function closeRotateMenu() {
    rotateMenuName = ""
  }

  // A moved display stays where it was put in the map until the state read
  // after the move catches up, instead of snapping back for a moment.
  property var pendingRects: null
  readonly property var shownRects: pendingRects || layoutRects

  // Apply the arrangement `place` works out from layoutRects, unless it
  // leaves everything where it was. Behind another command it waits its turn
  // and is worked out again then, from the sizes that command left.
  function applyLayout(place) {
    var rects = place()
    if (!rects || Model.sameLayout(rects, Model.normalizeLayout(Model.copyRects(layoutRects)))) return
    pendingRects = rects
    if (actionBusy) queuedActions = queuedActions.concat([{ layout: place }])
    else runAction(layoutCommand(rects))
  }

  function layoutCommand(rects) {
    var args = ["omarchy-hyprland-monitor-layout"]
    for (var i = 0; i < rects.length; i++)
      args.push(rects[i].name + "=" + rects[i].x + "x" + rects[i].y)
    return args
  }

  // ---- Text size (shell base font + GTK text-scaling, via one CLI) ----
  // One size for the whole session: the shell font, GTK and the terminals each
  // take a single value, so unlike the rows around it it isn't per display.
  function nearestTextStop(px) {
    var best = 0
    var bestDist = 1e9
    for (var i = 0; i < textSizeStops.length; i++) {
      var d = Math.abs(textSizeStops[i] - px)
      if (d < bestDist) { bestDist = d; best = i }
    }
    return best
  }

  // Effective stop index: the pending choice while a change is in flight,
  // otherwise whatever Style's live base-size rounds to.
  function currentTextIndex() {
    return textSizePreviewIndex >= 0 ? textSizePreviewIndex : nearestTextStop(Style.font.baseSize)
  }

  // px shown in the header: the pending stop if any, else the true base-size
  // (which may be an off-notch value set from the CLI).
  function displayedTextPx() {
    return textSizePreviewIndex >= 0 ? textSizeStops[textSizePreviewIndex] : Style.font.baseSize
  }

  function setTextSize(px) {
    textScaleProc.command = ["omarchy-display-text-size", String(px)]
    if (!textScaleProc.running) textScaleProc.running = true
  }

  function adjustTextSize(deltaSteps) {
    var idx = currentTextIndex() + deltaSteps
    if (idx < 0) idx = 0
    if (idx > textSizeStops.length - 1) idx = textSizeStops.length - 1
    markReflowing()
    textSizePreviewIndex = idx
    setTextSize(textSizeStops[idx])
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: refresh()

  // KeyboardPanel primes focus at open-time, so SUPER-bound IPC summons land
  // with j/k ready to navigate. Keep a default landing point, but don't paint
  // the cursor until hover or the first navigation key.
  onOpenedChanged: {
    closeRotateMenu()
    if (opened) {
      refresh()
      selectedName = ""
      focusSection = landingSection()
      selectedIndex = sectionFirstIndex(focusSection)
      cursorActive = false
    }
  }

  onDisplaysChanged: clampCursor()
  onVisibleSectionsChanged: clampCursor()

  // Only poll while the panel is open; the bar glyph tracks monitor count via
  // Quickshell.screens, and open-time refresh + Component.onCompleted cover the
  // rest. External brightness changes are reflected whenever the panel is open.
  Timer {
    interval: 5000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: stateProc
    command: ["omarchy-monitor-state"]
    onRunningChanged: {
      if (running) {
        root.readAfterActions = root.actionsDone
      } else if (root.rereadState) {
        root.rereadState = false
        Qt.callLater(root.refresh)
      }
    }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = String(text || "").split("\n")
        var brightness = String(lines[0] || "").trim()
        root.brightnessAvailable = brightness !== "unavailable" && brightness !== ""
        root.brightnessPercent = root.brightnessAvailable ? Math.max(0, Math.min(100, parseInt(brightness, 10))) : 0
        root.internalMonitor = String(lines[1] || "").trim()
        root.externalMonitor = String(lines[2] || "").trim()
        root.internalEnabled = String(lines[3] || "").trim() !== ""
        root.focusedMonitor = String(lines[5] || "").trim()
        root.monitorScale = root.normalizeScale(String(lines[6] || "").trim())
        root.updateDisplays(String(lines[7] || "[]").trim())
        // A queued move waits for a read that started after the last command;
        // an older one reads again once this process has stopped.
        if (root.awaitingFreshState) {
          if (root.readAfterActions === root.actionsDone) root.placeQueuedLayout()
          else root.rereadState = true
        }
        // A mirror switch has landed once a read shows it; until then, look
        // again shortly instead of waiting for the next regular read.
        if (root.pendingMirror !== "" && !root.actionBusy) {
          if (root.mirroredNow === (root.pendingMirror === "on")) root.pendingMirror = ""
          else mirrorRecheck.restart()
        }
        // The move has landed once a read after it comes back.
        if (!root.actionBusy) root.pendingRects = null
        root.mirrorManaged = String(lines[8] || "").trim() === "on"
      }
    }
  }

  Timer {
    id: brightnessDebounce
    interval: 180
    repeat: false
    onTriggered: root.setDisplayBrightness(root.pendingBrightnessMonitor, root.pendingBrightnessPercent)
  }

  Process {
    id: setBrightnessProc
    stdout: StdioCollector { waitForEnd: true }
    // Do NOT call refresh() after a brightness set completes. The local
    // level we just wrote is authoritative; re-reading via
    // `omarchy-brightness-display` races the hardware/driver and can
    // return an empty string, which the parser then coerces to 0 —
    // visible as a "bounce to zero" after h/l keypresses. External
    // brightness changes are still picked up by the 5s periodic refresh,
    // the open-time refresh, and Component.onCompleted.
    onRunningChanged: {
      if (running) return
      if (root.brightnessSetQueued) {
        root.setDisplayBrightness(root.pendingBrightnessMonitor, root.pendingBrightnessPercent)
      }
    }
  }

  Timer {
    id: mirrorRecheck
    interval: 400
    onTriggered: root.refresh()
  }

  // Never hold a mirror switch that didn't happen.
  Timer {
    id: mirrorSettle
    interval: 6000
    onTriggered: root.pendingMirror = ""
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    // The next one starts a turn later, not from inside this change.
    onRunningChanged: {
      if (running) return
      root.actionsDone++
      Qt.callLater(root.runNextAction)
    }
  }

  // Applies text size via the CLI, which rewrites the shell override file;
  // Style picks the new base-size up through its own file watch, so there's
  // nothing to refresh here.
  Process {
    id: textScaleProc
    stdout: StdioCollector { waitForEnd: true }
  }

  // Clears the hover-suppression flag once the reflow triggered by a text-size
  // change has settled.
  Timer {
    id: reflowSettle
    interval: 300
    repeat: false
    onTriggered: root.reflowingText = false
  }

  // Once Style's base-size catches up to the pending choice, drop the preview
  // so the slider tracks the live value again. The change itself reflows the
  // panel, so suppress hover for a beat while it lands.
  Connections {
    target: Style
    function onFontBaseSizeChanged() {
      root.markReflowing()
      if (root.textSizePreviewIndex >= 0
          && root.nearestTextStop(Style.font.baseSize) === root.textSizePreviewIndex)
        root.textSizePreviewIndex = -1
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: Quickshell.screens.length > 1 ? "󰍺" : "󰍹"
    onPressed: function(b) { root.toggle() }
    onWheelMoved: function(delta) {
      if (!root.brightnessAvailable) return
      var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
      root.wheelAccumulator = wheel.remainder
      if (wheel.steps === 0) return
      root.setBrightness(root.brightnessPercent + wheel.steps * 5)
      root.showBrightnessOsd(root.brightnessPercent)
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(860))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias scrollArea: scrollArea
      property alias layoutMap: layoutMap
      reorderable: root.rotateMenuName === "" && root.cursorActive && root.focusSection === "layout"
      reorderableSideways: reorderable
      onReorderRequested: function(dy) { root.placeShown(dy < 0 ? "above" : "below") }
      onReorderSidewaysRequested: function(dx) { root.placeShown(dx < 0 ? "left" : "right") }
      onTextKey: function(t) {
        if ((t === "r" || t === "R") && root.rotateMenuName === "") root.openRotateMenuForShown()
      }
      implicitHeight: panelColumn.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        // An open rotate menu takes j/k.
        if (root.rotateMenuName !== "") {
          if (dy !== 0) root.rotateMenuIndex = Math.max(0, Math.min(3, root.rotateMenuIndex + dy))
          return
        }
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.moveCursorH(dx)
      }
      onActivateRequested: {
        if (root.rotateMenuName !== "") root.applyRotateMenu()
        else if (root.cursorActive) root.activateCursor()
      }
      // Esc closes the rotate menu first, then the panel.
      onCloseRequested: {
        if (root.rotateMenuName !== "") root.closeRotateMenu()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }

      ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        Binding {
          target: scrollArea.contentItem
          property: "interactive"
          value: panelColumn.implicitHeight > scrollArea.height
        }

        Column {
          id: panelColumn
          width: scrollArea.availableWidth
          spacing: Style.space(14)

          // A slider's row is as tall as its knob plus a control gap, with the
          // thin track centered in it. Rows of pills and the layout map are
          // padded by the room around that track, so every section shows the
          // same gap above and below what's drawn.
          readonly property real sliderInset: Math.round((textSizeRow.height - textSizeSlider.trackHeight) / 2)

          // ---------- Hero: the shown display, and the picker ----------
          Item {
            width: parent.width
            implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, picker.implicitHeight)

            Text {
              id: heroIcon
              textFormat: Text.PlainText
              text: root.displayGlyph(root.current)
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.display
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              id: heroLabels
              anchors.left: heroIcon.right
              anchors.leftMargin: Style.space(14)
              anchors.right: picker.visible ? picker.left : parent.right
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: root.current ? root.current.title : Commons.I18n.t("monitor.display")
                textFormat: Text.PlainText
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              // The shown display's mood.
              Text {
                id: heroLabel
                textFormat: Text.PlainText
                text: root.currentBrightness >= 0
                  ? root.brightnessName(root.currentBrightness).toUpperCase()
                  : Commons.I18n.t("monitor.fixedBrightness")
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
                elide: Text.ElideRight
                width: parent.width
              }
            }

            // One icon per display, named in its tooltip. Plain glyphs like
            // Mirror and Extend: the shown one in the accent, the rest dim until
            // hovered or picked, and no box either way.
            Row {
              id: picker
              visible: root.segments.length > 1
              spacing: Style.space(14)
              anchors.right: parent.right
              anchors.rightMargin: Style.space(6)
              anchors.verticalCenter: parent.verticalCenter

              Repeater {
                model: root.segments

                Text {
                  id: pick
                  required property var modelData
                  required property int index

                  readonly property bool current: root.currentIndex === index
                  readonly property bool picked: root.cursorActive && root.focusSection === "displays" && root.selectedIndex === index
                  readonly property bool hot: pickMouse.containsMouse || picked
                  onPickedChanged: if (picked) root.ensureCursorVisible(pick)

                  text: root.displayGlyph(modelData)
                  textFormat: Text.PlainText
                  color: current ? Commons.Color.accent : (hot ? root.bar.foreground : Qt.darker(root.bar.foreground, 1.55))
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.icon

                  MouseArea {
                    id: pickMouse
                    anchors.fill: parent
                    anchors.margins: -Style.space(6)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectDisplay(pick.modelData.name)
                    onContainsMouseChanged: if (containsMouse) root.pointAt("displays", pick.index)
                  }

                  PanelToolTip {
                    visible: pickMouse.containsMouse
                    text: pick.modelData.title + " · " + pick.modelData.name
                  }
                }
              }
            }
          }

          // ---------- Brightness ----------
          PanelSeparator {
            visible: root.currentBrightness >= 0
            foreground: root.bar.foreground
          }

          Column {
            visible: root.currentBrightness >= 0
            width: parent.width
            spacing: Style.space(6)

            Item {
              width: parent.width
              implicitHeight: Math.max(brightnessHeader.implicitHeight, brightnessPercent.implicitHeight)

              PanelSectionHeader {
                id: brightnessHeader
                text: Commons.I18n.t("monitor.brightness")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: brightnessPercent
                textFormat: Text.PlainText
                text: Commons.I18n.formatNumber(Math.round(brightnessSlider.dragging ? brightnessSlider.liveValue : root.currentBrightness)) + "%"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            CursorSurface {
              id: brightnessRow
              width: parent.width
              height: brightnessSlider.implicitHeight + Style.spacing.controlGap
              hasCursor: root.cursorActive && root.focusSection === "brightness" && root.selectedIndex === -1
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(brightnessRow)
              foreground: root.bar.foreground
              outline: true

              PanelSlider {
                id: brightnessSlider
                bar: root.bar
                anchors.fill: parent
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                minimum: 1
                maximum: 100
                step: 1
                value: Math.max(1, root.currentBrightness)
                integer: true
                onMoved: function(v) { if (root.current) root.previewBrightness(root.current.name, v) }
                onReleased: function(v) {
                  brightnessDebounce.stop()
                  if (root.current) root.setDisplayBrightness(root.current.name, v)
                }
              }

              HoverHandler {
                onHoveredChanged: if (hovered) root.pointAt("brightness", -1)
              }
            }
          }

          // ---------- Text size ----------
          PanelSeparator {
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Item {
              width: parent.width
              implicitHeight: Math.max(textSizeHeader.implicitHeight, textSizePx.implicitHeight)

              PanelSectionHeader {
                id: textSizeHeader
                text: Commons.I18n.t("monitor.textSize")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: textSizePx
                textFormat: Text.PlainText
                text: Commons.I18n.formatNumber(textSizeSlider.dragging
                       ? root.textSizeStops[Math.round(textSizeSlider.liveValue)]
                       : root.displayedTextPx()) + "px"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            CursorSurface {
              id: textSizeRow
              width: parent.width
              height: textSizeSlider.implicitHeight + Style.spacing.controlGap
              hasCursor: root.cursorActive && root.focusSection === "textsize" && root.selectedIndex === -1
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(textSizeRow)
              foreground: root.bar.foreground
              outline: true

              PanelSlider {
                id: textSizeSlider
                bar: root.bar
                anchors.fill: parent
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                minimum: 0
                maximum: root.textSizeStops.length - 1
                step: 1
                integer: true
                tickCount: root.textSizeStops.length
                value: root.currentTextIndex()
                onReleased: function(v) { root.setTextSize(root.textSizeStops[Math.round(v)]) }
              }

              HoverHandler {
                onHoveredChanged: if (hovered) root.pointAt("textsize", -1)
              }
            }
          }

          // ---------- Scale ----------
          PanelSeparator {
            visible: root.current !== null && root.current.scales.length > 0
            foreground: root.bar.foreground
          }

          Column {
            visible: root.current !== null && root.current.scales.length > 0
            width: parent.width
            spacing: Style.space(6) + panelColumn.sliderInset
            bottomPadding: panelColumn.sliderInset

            PanelSectionHeader {
              text: Commons.I18n.t("monitor.scale")
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
            }

            Grid {
              id: scaleGrid
              width: parent.width
              columns: Math.max(1, root.current ? root.current.scales.length : 1)
              spacing: Style.spacing.xs

              readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

              Repeater {
                model: root.current ? root.current.scales : []

                ScalePill {
                  required property string modelData
                  required property int index

                  scaleValue: modelData
                  scaleIndex: index
                  width: scaleGrid.cellWidth
                }
              }
            }
          }

          // ---------- Resolution ----------
          PanelSeparator {
            visible: root.current !== null && root.current.resolutions.length > 0
            foreground: root.bar.foreground
          }

          // The pills only carry short names, so the exact mode sits by the header.
          Column {
            visible: root.current !== null && root.current.resolutions.length > 0
            width: parent.width
            spacing: Style.space(6) + panelColumn.sliderInset
            bottomPadding: panelColumn.sliderInset

            Item {
              width: parent.width
              implicitHeight: Math.max(resolutionHeader.implicitHeight, resolutionCurrent.implicitHeight)

              PanelSectionHeader {
                id: resolutionHeader
                text: Commons.I18n.t("monitor.resolution")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: resolutionCurrent
                textFormat: Text.PlainText
                text: root.current ? root.current.current.replace("x", "×") : ""
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Grid {
              id: resolutionGrid
              width: parent.width
              columns: Math.max(1, root.current ? root.current.resolutions.length : 1)
              spacing: Style.spacing.xs

              readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

              Repeater {
                model: root.current ? root.current.resolutions : []

                ResolutionPill {
                  required property string modelData
                  required property int index

                  resolution: modelData
                  resolutionIndex: index
                  width: resolutionGrid.cellWidth
                }
              }
            }
          }

          // ---------- Refresh rate ----------
          PanelSeparator {
            visible: root.current !== null && root.current.refreshes.length > 0
            foreground: root.bar.foreground
          }

          Column {
            visible: root.current !== null && root.current.refreshes.length > 0
            width: parent.width
            spacing: Style.space(6) + panelColumn.sliderInset
            bottomPadding: panelColumn.sliderInset

            Item {
              width: parent.width
              implicitHeight: Math.max(refreshHeader.implicitHeight, refreshCurrent.implicitHeight)

              PanelSectionHeader {
                id: refreshHeader
                text: Commons.I18n.t("monitor.refreshRate")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: refreshCurrent
                textFormat: Text.PlainText
                text: root.current ? Commons.I18n.formatNumber(Math.round(root.current.refreshRate)) + " Hz" : ""
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Grid {
              id: refreshGrid
              width: parent.width
              columns: Math.max(1, root.current ? root.current.refreshes.length : 1)
              spacing: Style.spacing.xs

              readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

              Repeater {
                model: root.current ? root.current.refreshes : []

                RefreshPill {
                  required property var modelData
                  required property int index

                  option: modelData
                  refreshIndex: index
                  width: refreshGrid.cellWidth
                }
              }
            }
          }

          // ---------- Layout ----------
          PanelSeparator {
            visible: root.layoutShown
            foreground: root.bar.foreground
          }

          Column {
            visible: root.layoutShown
            width: parent.width
            spacing: Style.space(6)

            Item {
              width: parent.width
              implicitHeight: Math.max(layoutHeader.implicitHeight, mirrorRow.visible ? mirrorRow.implicitHeight : 0)

              PanelSectionHeader {
                id: layoutHeader
                text: Commons.I18n.t("monitor.layout")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                id: mirrorRow
                visible: root.mirrorAvailable
                spacing: Style.space(14)
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter

                MirrorLink { mode: "mirror"; modeIndex: 0 }
                MirrorLink { mode: "extend"; modeIndex: 1 }
              }
            }

            // Padded like a slider's track, around a map as tall as the arrangement.
            // No row box: the keyboard cursor shows on the shown display instead.
            Item {
              id: layoutRow
              readonly property bool hasCursor: root.layoutMovable && root.cursorActive && root.focusSection === "layout"
              width: parent.width
              height: layoutMap.implicitHeight + panelColumn.sliderInset * 2
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(layoutRow)

              LayoutMap {
                id: layoutMap
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                height: implicitHeight
                hasCursor: layoutRow.hasCursor
              }

              // The pointer on the map takes the shared cursor, as every row does,
              // so h/l afterwards moves the shown display instead of the last row.
              HoverHandler {
                enabled: root.layoutMovable
                onHoveredChanged: if (hovered) root.pointAt("layout", 0)
              }

              HoverHandler { id: layoutHover }
            }

            // The keys the map takes, while it's hovered or the keyboard is on
            // it; a lone or mirrored map isn't a stop, so the row above shows
            // its hint instead. Its room stays reserved and it appears without
            // a fade, so nothing shifts as the pointer crosses the map.
            Text {
              readonly property bool shown: layoutHover.hovered || (root.cursorActive &&
                (root.focusSection === "layout" || (!root.layoutMovable && root.focusSection === "mirror")))
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
              textFormat: Text.PlainText
              text: root.layoutMovable ? Commons.I18n.t("monitor.layoutHint") : Commons.I18n.t("monitor.rotateHint")
              color: Qt.darker(root.bar.foreground, 1.55)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              opacity: shown ? 1 : 0
            }
          }
        }
      }

      // The layout map's right-click menu sits over the scrolling content, so
      // the panel's edge doesn't clip it near the bottom. A click anywhere
      // else closes it.
      MouseArea {
        anchors.fill: parent
        visible: root.rotateMenuName !== ""
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: root.closeRotateMenu()
      }

      BorderSurface {
        id: rotateMenu
        visible: root.rotateMenuName !== ""
        width: Math.max(Style.space(140), rotateColumn.implicitWidth) + padding * 2
        height: rotateColumn.implicitHeight + padding * 2
        x: Math.max(0, Math.min(root.rotateMenuX, parent.width - width))
        y: Math.max(0, Math.min(root.rotateMenuY, parent.height - height))
        radius: Style.cornerRadius
        color: Commons.Color.popups.background
        borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
        padding: Style.spacing.sm

        Column {
          id: rotateColumn
          x: rotateMenu.contentLeftInset
          y: rotateMenu.contentTopInset
          width: rotateMenu.width - rotateMenu.contentLeftInset - rotateMenu.contentRightInset

          Repeater {
            model: [
              [0, Commons.I18n.t("monitor.rotateNormal")],
              [90, Commons.I18n.t("monitor.rotate90")],
              [180, Commons.I18n.t("monitor.rotate180")],
              [270, Commons.I18n.t("monitor.rotate270")]
            ]

            delegate: PopupMenuRow {
              required property var modelData
              required property int index

              text: modelData[1]
              checked: root.rotateMenuTransform === modelData[0] / 90
              // Hover and the keyboard share one lit row.
              highlighted: root.rotateMenuIndex === index
              HoverHandler { onHoveredChanged: if (hovered) root.rotateMenuIndex = index }
              onTriggered: {
                root.setRotation(root.rotateMenuName, modelData[0])
                root.closeRotateMenu()
              }
            }
          }
        }
      }
    }
  }

  component ScalePill: Button {
    id: pill
    required property string scaleValue
    required property int scaleIndex

    text: root.current ? Commons.I18n.formatNumber(Model.cleanScale(scaleValue, root.current.width, root.current.height)) + "x" : ""
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: root.current !== null && root.current.scaleIndex === scaleIndex
    hasCursor: root.cursorActive && root.focusSection === "scale" && root.selectedIndex === scaleIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(pill)

    onClicked: if (root.current) root.setScale(root.current.name, scaleValue)
    onHovered: function(isHovered) { if (isHovered) root.pointAt("scale", pill.scaleIndex) }
  }

  component ResolutionPill: Button {
    id: resolutionPill
    required property string resolution
    required property int resolutionIndex

    text: Model.resolutionLabel(resolution)
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: root.current !== null && root.current.current === resolution
    hasCursor: root.cursorActive && root.focusSection === "resolution" && root.selectedIndex === resolutionIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(resolutionPill)

    onClicked: if (root.current) root.setResolution(root.current.name, resolution)
    onHovered: function(isHovered) { if (isHovered) root.pointAt("resolution", resolutionPill.resolutionIndex) }
  }

  // A refresh rate at the current resolution, set as that exact mode.
  component RefreshPill: Button {
    id: refreshPill
    required property var option
    required property int refreshIndex

    text: Commons.I18n.formatNumber(Number(option.label))
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: root.current !== null && Math.round(root.current.refreshRate) === Number(option.label)
    hasCursor: root.cursorActive && root.focusSection === "refresh" && root.selectedIndex === refreshIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(refreshPill)

    onClicked: if (root.current) root.setResolution(root.current.name, root.current.current + "@" + option.rate)
    onHovered: function(isHovered) { if (isHovered) root.pointAt("refresh", refreshPill.refreshIndex) }
  }

  // Extend puts each display beside the others; Mirror shows the built-in
  // display's picture on the external one too. Plain text like the agents
  // panel's Autoswitch: the current choice in bold accent, the other dim
  // until hovered or picked, when it turns bold. The current one, already
  // bold, takes a soft underline when picked.
  component MirrorLink: Text {
    id: mirrorLink
    property string mode: ""
    property int modeIndex: 0
    readonly property bool current: root.mirrorEnabled === (mode === "mirror")
    readonly property bool picked: root.cursorActive && root.focusSection === "mirror" && root.selectedIndex === modeIndex
    readonly property bool hot: linkMouse.containsMouse || picked
    onPickedChanged: if (picked) root.ensureCursorVisible(mirrorLink)

    text: mode === "mirror" ? Commons.I18n.t("monitor.mirror") : Commons.I18n.t("monitor.extend")
    textFormat: Text.PlainText
    color: current ? Commons.Color.accent : (hot ? root.bar.foreground : Qt.darker(root.bar.foreground, 1.55))
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: current || hot
    font.underline: current && picked

    MouseArea {
      id: linkMouse
      anchors.fill: parent
      anchors.margins: -Style.space(4)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.setMirror(mirrorLink.mode === "mirror")
      onContainsMouseChanged: if (containsMouse) root.pointAt("mirror", mirrorLink.modeIndex)
    }
  }

  // The displays drawn where they sit, at their relative sizes. Drag one
  // against another's side to move it there; it lines up with that display's
  // start, center or end when dropped near one. Clicking one shows it above.
  component LayoutMap: Item {
    id: map
    // The keyboard is on the map: ctrl+h/j/k/l moves the shown display.
    property bool hasCursor: false

    readonly property var bounds: {
      var rects = root.shownRects
      var b = { x: 0, y: 0, w: 1, h: 1 }
      if (rects.length === 0) return b
      var right = -Infinity
      var bottom = -Infinity
      b.x = Infinity
      b.y = Infinity
      for (var i = 0; i < rects.length; i++) {
        b.x = Math.min(b.x, rects[i].x)
        b.y = Math.min(b.y, rects[i].y)
        right = Math.max(right, rects[i].x + rects[i].w)
        bottom = Math.max(bottom, rects[i].y + rects[i].h)
      }
      b.w = Math.max(1, right - b.x)
      b.h = Math.max(1, bottom - b.y)
      return b
    }
    // Room either side for a display dragged past the arrangement's edge, and
    // no taller than a slider row or two.
    readonly property real ratio: Math.min(width * 0.8 / bounds.w, Style.space(100) / bounds.h)
    // A display that others mirror is drawn as a stack: one card behind it,
    // up and to the right, per display showing the same picture.
    readonly property real stackStep: Style.space(6)
    readonly property int stackDepth: {
      var depth = 0
      for (var i = 0; i < root.shownRects.length; i++)
        depth = Math.max(depth, (root.mirroredBy[root.shownRects[i].name] || []).length)
      return depth
    }
    implicitHeight: bounds.h * ratio + stackDepth * stackStep
    readonly property real offsetX: (width - bounds.w * ratio - stackDepth * stackStep) / 2
    readonly property real offsetY: (height - bounds.h * ratio + stackDepth * stackStep) / 2

    Repeater {
      model: root.shownRects

      Rectangle {
        id: screenRect
        required property var modelData

        readonly property bool isCurrent: root.layoutMovable && root.current !== null && root.current.name === modelData.name
        property real dragX: 0
        property real dragY: 0
        property real pressX: 0
        property real pressY: 0
        readonly property bool dragging: dragX !== 0 || dragY !== 0

        x: map.offsetX + (modelData.x - map.bounds.x) * map.ratio + dragX
        y: map.offsetY + (modelData.y - map.bounds.y) * map.ratio + dragY
        width: Math.max(4, modelData.w * map.ratio - 2)
        height: Math.max(4, modelData.h * map.ratio - 2)
        z: dragging ? 1 : 0
        radius: Style.cornerRadius > 0 ? Style.space(3) : 0
        color: isCurrent
          ? Style.selectedFillFor(root.bar.foreground, Commons.Color.accent)
          : Style.hoverFillFor(root.bar.foreground, Commons.Color.accent)
        border.width: isCurrent && map.hasCursor ? 2 : 1
        border.color: isCurrent ? Commons.Color.accent : Qt.darker(root.bar.foreground, 1.6)

        // The fill is translucent, so back it with the panel's own surface
        // to keep the cards behind from showing through.
        Rectangle {
          anchors.fill: parent
          z: -1
          radius: parent.radius
          color: Commons.Color.popups.background
        }

        // The displays mirroring this one, stacked behind it.
        Repeater {
          model: root.mirroredBy[screenRect.modelData.name] || []

          Rectangle {
            required property int index
            x: (index + 1) * map.stackStep
            y: -(index + 1) * map.stackStep
            z: -2 - index
            width: screenRect.width
            height: screenRect.height
            radius: screenRect.radius
            color: Commons.Color.popups.background
            border.width: 1
            border.color: Qt.darker(root.bar.foreground, 1.6)

            Rectangle {
              anchors.fill: parent
              radius: parent.radius
              color: Style.hoverFillFor(root.bar.foreground, Commons.Color.accent)
            }
          }
        }

        Text {
          anchors.centerIn: parent
          width: parent.width - Style.space(6)
          horizontalAlignment: Text.AlignHCenter
          textFormat: Text.PlainText
          text: [screenRect.modelData.name].concat(root.mirroredBy[screenRect.modelData.name] || []).join(" + ")
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: screenRect.isCurrent
          elide: Text.ElideRight
        }

        MouseArea {
          // A lone display, or a mirrored stack, has nothing to move against.
          readonly property bool canDrag: root.layoutMovable && !root.pendingRects
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: !canDrag ? Qt.ArrowCursor : (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
          preventStealing: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onPressed: function(mouse) {
            // A right click opens the rotate menu where it was made, within the panel.
            if (mouse.button === Qt.RightButton) {
              root.openRotateMenu(screenRect.modelData.name, screenRect, mouse.x, mouse.y)
              return
            }
            var point = mapToItem(map, mouse.x, mouse.y)
            screenRect.pressX = point.x
            screenRect.pressY = point.y
          }
          onPositionChanged: function(mouse) {
            if (!canDrag || !(pressedButtons & Qt.LeftButton)) return
            var point = mapToItem(map, mouse.x, mouse.y)
            screenRect.dragX = point.x - screenRect.pressX
            screenRect.dragY = point.y - screenRect.pressY
          }
          onReleased: function(mouse) {
            if (mouse.button === Qt.RightButton) return
            var name = screenRect.modelData.name
            var moved = Math.abs(screenRect.dragX) + Math.abs(screenRect.dragY) > 3
            // Back into layout space; snap within about 8 map pixels.
            var x = map.bounds.x + (screenRect.x - map.offsetX) / map.ratio
            var y = map.bounds.y + (screenRect.y - map.offsetY) / map.ratio
            // Reset first: applying the move redraws the map, this box included.
            screenRect.dragX = 0
            screenRect.dragY = 0
            var snap = Style.space(8) / map.ratio
            if (moved) root.applyLayout(function() { return Model.dropDisplay(root.layoutRects, name, x, y, snap) })
            else root.selectDisplay(name)
          }
          onCanceled: {
            screenRect.dragX = 0
            screenRect.dragY = 0
          }
        }
      }
    }
  }
}
