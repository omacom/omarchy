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
  property bool mirrorEnabled: false
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
  //   "layout"     - the arrangement of the displays; h/l moves the shown one
  //                  to the left or right of the rest.
  // Every section is one row: j/k steps between them, h/l moves a slider or
  // walks a row of pills, identical to bluetooth's header.
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
        resolutions: resolutions.length > 1 ? resolutions : []
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
  readonly property var layoutRects: {
    var list = []
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (!display || !display.enabled || !(display.width > 0)) continue
      if (display.mirrorOf && display.mirrorOf !== "none") continue
      list.push(Model.logicalRect(display))
    }
    return list
  }

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
    if (layoutRects.length > 0) list.push("layout")
    return list
  }

  function sectionCount(section) {
    if (section === "displays") return segments.length
    if (section === "scale") return current ? current.scales.length : 0
    if (section === "resolution") return current ? current.resolutions.length : 0
    if (section === "layout") return 1
    return 0  // sliders: only the sentinel at -1
  }

  function sectionFirstIndex(section) {
    if (isSliderSection(section)) return -1
    if (section === "displays") return Math.max(0, currentIndex)
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

  // h/l: a slider moves, the picker shows the next display, a row of pills
  // walks its pills, and the layout moves the shown display to that side.
  function moveCursorH(delta) {
    if (focusSection === "brightness") {
      if (current) adjustBrightness(current.name, delta * 5)
    } else if (focusSection === "textsize") {
      adjustTextSize(delta)
    } else if (focusSection === "displays") {
      var next = Math.max(0, Math.min(segments.length - 1, currentIndex + delta))
      selectDisplay(segments[next].name)
      selectedIndex = next
    } else if (focusSection === "scale" || focusSection === "resolution") {
      selectedIndex = Math.max(0, Math.min(sectionCount(focusSection) - 1, selectedIndex + delta))
    } else if (focusSection === "layout" && current) {
      applyLayout(Model.placeDisplay(layoutRects, current.name, delta < 0 ? "left" : "right"))
    }
  }

  function activateCursor() {
    if (!current) return
    if (focusSection === "scale" && selectedIndex >= 0 && selectedIndex < current.scales.length)
      setScale(current.name, current.scales[selectedIndex])
    else if (focusSection === "resolution" && selectedIndex >= 0 && selectedIndex < current.resolutions.length)
      setResolution(current.name, current.resolutions[selectedIndex])
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

  function setScale(name, scale) {
    actionProc.command = ["omarchy-hyprland-monitor-scaling", "--monitor", name, scale]
    if (!actionProc.running) actionProc.running = true
  }

  function setResolution(name, resolution) {
    actionProc.command = ["omarchy-hyprland-monitor-resolution", "--monitor", name, resolution]
    if (!actionProc.running) actionProc.running = true
  }

  function setRotation(name, degrees) {
    actionProc.command = ["omarchy-hyprland-monitor-rotate", "--monitor", name, String(degrees)]
    if (!actionProc.running) actionProc.running = true
  }

  // The layout map's right-click menu: the display it's for, where it opened
  // within the panel, and that display's quarter turn now.
  property string rotateMenuName: ""
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
  }

  function closeRotateMenu() {
    rotateMenuName = ""
  }

  // Apply a whole arrangement, unless it leaves everything where it was.
  function applyLayout(rects) {
    if (!rects || Model.sameLayout(rects, Model.normalizeLayout(Model.copyRects(layoutRects)))) return
    var args = ["omarchy-hyprland-monitor-layout"]
    for (var i = 0; i < rects.length; i++)
      args.push(rects[i].name + "=" + rects[i].x + "x" + rects[i].y)
    actionProc.command = args
    if (!actionProc.running) actionProc.running = true
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
        root.mirrorEnabled = String(lines[4] || "").trim() === root.externalMonitor && root.externalMonitor !== ""
        root.focusedMonitor = String(lines[5] || "").trim()
        root.monitorScale = root.normalizeScale(String(lines[6] || "").trim())
        root.updateDisplays(String(lines[7] || "[]").trim())
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

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    onRunningChanged: if (!running) root.refresh()
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
      implicitHeight: panelColumn.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.moveCursorH(dx)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
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

            // One button per display, named in its tooltip; the shown one is lit.
            Row {
              id: picker
              visible: root.segments.length > 1
              spacing: Style.spacing.xs
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter

              Repeater {
                model: root.segments

                Button {
                  id: pick
                  required property var modelData
                  required property int index

                  iconText: root.displayGlyph(modelData)
                  tooltipText: modelData.title + " · " + modelData.name
                  foreground: root.bar.foreground
                  fontFamily: root.bar.fontFamily
                  horizontalPadding: Style.spacing.sm
                  verticalPadding: Style.spacing.controlPaddingY

                  active: root.currentIndex === index
                  hasCursor: root.cursorActive && root.focusSection === "displays" && root.selectedIndex === index
                  onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(pick)

                  onClicked: root.selectDisplay(modelData.name)
                  onHovered: function(isHovered) { if (isHovered) root.pointAt("displays", pick.index) }
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

          // ---------- Layout ----------
          // Shown for a single display too: right-clicking it is how it's rotated.
          PanelSeparator {
            visible: root.layoutRects.length > 0
            foreground: root.bar.foreground
          }

          Column {
            visible: root.layoutRects.length > 0
            width: parent.width
            spacing: Style.space(6)

            PanelSectionHeader {
              text: Commons.I18n.t("monitor.layout")
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
            }

            // Padded like a slider's track, around a map as tall as the arrangement.
            // No row box: the keyboard cursor shows on the shown display instead.
            Item {
              id: layoutRow
              readonly property bool hasCursor: root.cursorActive && root.focusSection === "layout"
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
                onHoveredChanged: if (hovered) root.pointAt("layout", 0)
              }
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

              text: modelData[1]
              checked: root.rotateMenuTransform === modelData[0] / 90
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

  // The displays drawn where they sit, at their relative sizes. Drag one
  // against another's side to move it there; it lines up with that display's
  // start, center or end when dropped near one. Clicking one shows it above.
  component LayoutMap: Item {
    id: map
    // The keyboard is on the map: h/l moves the shown display.
    property bool hasCursor: false

    readonly property var bounds: {
      var rects = root.layoutRects
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
    implicitHeight: bounds.h * ratio
    readonly property real offsetX: (width - bounds.w * ratio) / 2
    readonly property real offsetY: (height - bounds.h * ratio) / 2

    Repeater {
      model: root.layoutRects

      Rectangle {
        id: screenRect
        required property var modelData

        readonly property bool isCurrent: root.current !== null && root.current.name === modelData.name
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

        Text {
          anchors.centerIn: parent
          width: parent.width - Style.space(6)
          horizontalAlignment: Text.AlignHCenter
          textFormat: Text.PlainText
          text: screenRect.modelData.name
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: screenRect.isCurrent
          elide: Text.ElideRight
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
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
            if (!(pressedButtons & Qt.LeftButton)) return
            var point = mapToItem(map, mouse.x, mouse.y)
            screenRect.dragX = point.x - screenRect.pressX
            screenRect.dragY = point.y - screenRect.pressY
          }
          onReleased: function(mouse) {
            if (mouse.button === Qt.RightButton) return
            var moved = Math.abs(screenRect.dragX) + Math.abs(screenRect.dragY) > 3
            if (moved) {
              // Back into layout space; snap within about 8 map pixels.
              var x = map.bounds.x + (screenRect.x - map.offsetX) / map.ratio
              var y = map.bounds.y + (screenRect.y - map.offsetY) / map.ratio
              root.applyLayout(Model.dropDisplay(root.layoutRects, screenRect.modelData.name, x, y, Style.space(8) / map.ratio))
            } else {
              root.selectDisplay(screenRect.modelData.name)
            }
            screenRect.dragX = 0
            screenRect.dragY = 0
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
