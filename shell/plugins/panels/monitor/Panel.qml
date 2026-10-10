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
  readonly property int brightnessPercent: brightnessControl.value
  readonly property bool brightnessAvailable: brightnessControl.available
  readonly property string helperDirectory: Quickshell.env("OMARCHY_PATH") + "/shell/plugins/panels/monitor/"
  readonly property string focusedMonitor: (displays.find(function(d) { return d.focused }) || {}).name || ""
  property string selectedMonitor: ""
  property int selectionSerial: 0
  property bool stateFresh: false
  property string selectedIdentity: ""
  readonly property bool identifying: identifier.visible
  property int draftTransform: -1
  property string draftScale: ""
  property var draftBaseline: null
  readonly property bool settingsDirty: (draftTransform >= 0 && draftTransform !== monitorTransform)
    || (draftScale !== "" && Number(draftScale) !== Number(monitorScale))
  readonly property bool settingsBusy: orientationProc.running || displayPowerProc.running || brightnessControl.busy
  readonly property int displayedTransform: draftTransform >= 0 ? draftTransform : monitorTransform
  readonly property string displayedScale: draftScale !== "" ? draftScale : monitorScale
  property string monitorScale: ""
  property var displays: []
  property int enabledDisplayCount: 0
  property string orientationError: ""
  readonly property var orientationLabels: ["Normal", "Left 90°", "180°", "Right 90°"]
  readonly property var orientationDisplay: {
    for (var i = 0; i < displays.length; i++)
      if (displays[i].name === selectedMonitor) return displays[i]
    return null
  }
  readonly property int monitorTransform: orientationDisplay ? orientationDisplay.transform : -1

  // Carry sub-notch touchpad deltas between wheel events.
  property real wheelAccumulator: 0

  // Cursor model shared by keyboard and mouse. Sections:
  //   "brightness" - single slider row, selectedIndex = -1 sentinel
  //                  (mirrors Audio's slider rows). Only present if a
  //                  controllable backlight was detected.
  //   "scale"      - 6 Button scale presets; treated as a single
  //                  horizontal row from j/k's perspective. h/l moves
  //                  between presets, identical to bluetooth's header.
  //   "monitors"   - vertical list for selecting a display;
  //                  j/k walks each row.
  // Mouse hover on a target updates root state via the components' `hovered`
  // signal so keyboard cursor and pointer share one highlight.
  readonly property var scalePresets: ["1", "1.25", "1.6", "2", "3", "4"]
  readonly property var scaleValues: {
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (display && display.name === selectedMonitor)
        return Model.availableScales(scalePresets, display.width, display.height)
    }
    return scalePresets
  }
  property string focusSection: "scale"
  property int selectedIndex: 0
  property bool cursorActive: false
  property bool monitorPowerFocused: false

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
    list.push("identify")
    if (displays.length > 0) list.push("monitors")
    if (brightnessAvailable) list.push("brightness")
    list.push("scale")
    if (orientationDisplay) list.push("orientation")
    list.push("apply")
    list.push("textsize")
    return list
  }

  function sectionCount(section) {
    if (section === "identify") return 1
    if (section === "brightness") return 0  // only the slider sentinel at -1
    if (section === "textsize") return 0    // slider sentinel at -1, like brightness
    if (section === "apply") return 2
    if (section === "orientation") return orientationLabels ? orientationLabels.length : 0
    if (section === "scale") return scaleValues ? scaleValues.length : 0
    if (section === "monitors") return displays ? displays.length : 0
    return 0
  }

  function sectionIsSingleRow(section) {
    // brightness and text size are lone sliders; scale presets sit horizontally.
    return section === "brightness" || section === "textsize" || section === "scale" || section === "orientation" || section === "apply" || section === "identify"
  }

  function sectionFirstIndex(section) {
    if (section === "brightness" || section === "textsize") return -1
    return 0
  }

  function moveCursor(delta) {
    monitorPowerFocused = false
    var sections = visibleSections
    if (!sections || sections.length === 0) return
    var sIdx = sections.indexOf(focusSection)
    if (sIdx < 0) {
      focusSection = sections[0]
      selectedIndex = sectionFirstIndex(focusSection)
      return
    }
    var inSingleRow = sectionIsSingleRow(focusSection)
    var max = inSingleRow ? 0 : sectionCount(focusSection) - 1

    if (delta > 0) {
      if (!inSingleRow && selectedIndex < max) { selectedIndex = selectedIndex + 1; return }
      if (sIdx < sections.length - 1) {
        focusSection = sections[sIdx + 1]
        selectedIndex = sectionFirstIndex(focusSection)
      }
    } else {
      if (!inSingleRow && selectedIndex > 0) { selectedIndex = selectedIndex - 1; return }
      if (sIdx > 0) {
        var prev = sections[sIdx - 1]
        focusSection = prev
        // Coming up from below — land on the last navigable row of the prev
        // section, or its sentinel for single-row sections.
        selectedIndex = sectionIsSingleRow(prev) ? sectionFirstIndex(prev) : sectionCount(prev) - 1
      }
    }
  }

  // h/l switches between display selection and power, or walks preset rows.
  function moveCursorH(delta) {
    if (focusSection === "monitors") {
      monitorPowerFocused = delta > 0
      return
    }
    if (focusSection !== "scale" && focusSection !== "orientation" && focusSection !== "apply") return
    var count = sectionCount(focusSection)
    var next = selectedIndex + delta
    if (next < 0) next = 0
    if (next > count - 1) next = count - 1
    selectedIndex = next
  }

  function adjustBrightness(delta) {
    if (focusSection !== "brightness") return
    if (!brightnessAvailable) return
    setBrightness(root.brightnessPercent + delta)
  }

  function activateCursor() {
    if (focusSection === "identify") { identifyDisplays(""); return }
    if (focusSection === "apply") {
      if (selectedIndex === 0) applySettings()
      else discardSettings()
      return
    }
    if (focusSection === "orientation") {
      setOrientation(selectedIndex)
      return
    }
    if (focusSection === "scale" && selectedIndex >= 0 && selectedIndex < scaleValues.length) {
      setScale(scaleValues[selectedIndex])
      return
    }
    if (focusSection === "monitors" && selectedIndex >= 0 && selectedIndex < displays.length) {
      var d = displays[selectedIndex]
      if (d) {
        if (monitorPowerFocused) toggleDisplay(d.name, d.enabled)
        else selectDisplay(d.name)
      }
    }
    // brightness: no separate action; the slider value is the action.
  }

  function clampCursor() {
    var sections = visibleSections
    if (!sections || !sections.length) return
    if (sections.indexOf(focusSection) < 0) {
      focusSection = sections[0]
      selectedIndex = sectionFirstIndex(focusSection)
      return
    }
    var count = sectionCount(focusSection)
    if (sectionIsSingleRow(focusSection)) {
      // brightness/text size use the -1 sentinel; scale clamps into the presets.
      if (focusSection === "brightness" || focusSection === "textsize") selectedIndex = -1
      else if (selectedIndex < 0 || selectedIndex >= count) selectedIndex = 0
      return
    }
    if (count === 0) {
      var sIdx = sections.indexOf(focusSection)
      focusSection = sIdx > 0 ? sections[sIdx - 1] : sections[0]
      selectedIndex = sectionFirstIndex(focusSection)
      return
    }
    if (selectedIndex > count - 1) selectedIndex = count - 1
    if (selectedIndex < 0) selectedIndex = 0
  }

  // Keep the keyboard-focused row inside the viewport when the panel grows
  // taller than its allotted height (lots of displays). Mirrors audio's
  // ensureCursorVisible helper.
  function ensureCursorVisible(item) {
    if (!item || !scrollArea) return
    var flick = scrollArea.contentItem
    if (!flick || flick.contentY === undefined) return
    var pt = item.mapToItem(flick.contentItem || flick, 0, 0)
    var top = pt.y
    var bottom = top + (item.height || 0)
    var viewTop = flick.contentY
    var viewBottom = viewTop + flick.height
    var margin = 6
    if (top < viewTop + margin) flick.contentY = Math.max(0, top - margin)
    else if (bottom > viewBottom - margin)
      flick.contentY = bottom + margin - flick.height
  }

  function brightnessIpc(percent) {
    var value = Number(percent)
    if (String(percent).trim() === "" || !isFinite(value) || value < 1 || value > 100) return "Invalid brightness: expected 1–100"
    if (!brightnessAvailable || orientationProc.running) return "Brightness unavailable for the selected display"
    root.setBrightness(value)
    return "Brightness change queued for " + root.selectedMonitor
  }

  function stateIpc() {
    return JSON.stringify({
      brightness: root.brightnessAvailable ? root.brightnessPercent : null,
      brightnessAvailable: root.brightnessAvailable,
      brightnessTarget: brightnessControl.targetName,
      brightnessStatus: brightnessControl.status,
      brightnessScope: brightnessControl.scope,
      brightnessAffectedDisplays: brightnessControl.affectedDisplays,
      brightnessBackend: brightnessControl.backend,
      brightnessError: brightnessControl.error,
      selectedMonitor: root.selectedMonitor,
      focusedMonitor: root.focusedMonitor,
      scale: root.monitorScale,
      transform: root.monitorTransform,
      orientationError: root.orientationError,
      pendingTransform: root.displayedTransform,
      pendingScale: root.displayedScale,
      identifying: root.identifying,
      displays: root.displays
    })
  }

  ShellIpc {
    target: "omarchy.monitor"

    function brightness(percent: string): string { return root.brightnessIpc(percent) }
    function state(): string { return root.stateIpc() }
    function selectDisplay(name: string) { root.selectDisplay(name) }
    function identify() { root.identifyDisplays("") }
    function open() { root.open() }
    function close() { root.close() }
    function toggle() { root.toggle() }
    function show() { root.open() }
    function hide() { root.close() }
  }

  function refresh() {
    if (stateProc.running || orientationProc.running) return
    stateProc.requestSerial = selectionSerial
    stateProc.command = ["python3", "-B", root.helperDirectory + "monitor_state.py", selectedMonitor]
    stateProc.running = true
  }

  function selectDisplay(name) {
    if (settingsBusy || name === selectedMonitor) return
    var found = displays.some(function(d) { return d.name === name && d.enabled })
    if (!found) return
    selectionSerial++
    selectedMonitor = name
    selectedIdentity = (displays.find(function(d) { return d.name === name }) || {}).description || ""
    draftTransform = -1
    draftScale = ""
    draftBaseline = null
    orientationError = ""
    for (var i = 0; i < displays.length; i++) {
      if (displays[i].name === name) monitorScale = normalizeScale(displays[i].scale)
    }
    refresh()
    identifyDisplays(name)
  }

  function toggleDisplay(name, enabled) {
    if (!name || settingsBusy || settingsDirty || !stateFresh) return
    if (enabled && enabledDisplayCount <= 1) return
    var output = '"' + name.replace(/[\\"]/g, "\\$&") + '"'
    var expr = enabled
      ? 'hl.monitor({ output = ' + output + ', disabled = true })'
      : 'hl.monitor({ output = ' + output + ', disabled = false, mode = "preferred", position = "auto", scale = "auto" })'
    displayPowerProc.command = ["hyprctl", "eval", expr]
    displayPowerProc.running = true
  }

  Process {
    id: displayPowerProc
    stderr: StdioCollector { id: displayPowerError; waitForEnd: true }
    onExited: function(code) {
      if (code !== 0) root.orientationError = String(displayPowerError.text || "Could not change display power").trim()
      root.refresh()
    }
  }

  function identifyDisplays(name) { identifier.show(name) }

  IdentifyOverlay { id: identifier; displays: root.displays }

  function setBrightness(value) { brightnessControl.setValue(value) }
  function previewBrightness(value) { brightnessControl.preview(value) }

  BrightnessController {
    id: brightnessControl
    helperDirectory: root.helperDirectory
    targetName: root.selectedMonitor
    identity: root.selectedIdentity
    hardwareIdentity: root.orientationDisplay ? (root.orientationDisplay.brightnessIdentity || "") : ""
    active: root.opened
    suspended: orientationProc.running
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

  function activeScaleIndex() {
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (display && display.name === selectedMonitor)
        return Model.matchingScaleIndex(scaleValues, displayedScale, display.width, display.height)
    }
    return -1
  }

  function effectiveScale(scale) {
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (display && display.name === selectedMonitor)
        return Model.cleanScale(scale, display.width, display.height)
    }
    return normalizeScale(scale)
  }

  // Playful mood-name for a given brightness percent. Bands intentionally
  // span ~10–20 points so casual tweaks change the label, while small
  // nudges within one band don't.
  function brightnessName(percent) {
    return Model.brightnessName(percent)
  }

  function updateDisplays(values) {
    if (JSON.stringify(values) === JSON.stringify(displays)) return
    displays = values
    enabledDisplayCount = values.filter(function(d) { return d.enabled }).length
  }

  function discardSettings() {
    if (settingsBusy) return
    draftTransform = -1
    draftScale = ""
    draftBaseline = null
    orientationError = ""
  }

  function setOrientation(transform) {
    if (!orientationDisplay || !orientationDisplay.enabled || !stateFresh || settingsBusy) return
    if (transform < 0 || transform > 3) return
    if (!settingsDirty) draftBaseline = Model.monitorSnapshot(orientationDisplay)
    draftTransform = transform
  }

  function setScale(scale) {
    if (!orientationDisplay || !orientationDisplay.enabled || !stateFresh || settingsBusy) return
    if (!settingsDirty) draftBaseline = Model.monitorSnapshot(orientationDisplay)
    draftScale = effectiveScale(scale)
  }

  function applySettings() {
    if (!orientationDisplay || settingsBusy || !settingsDirty || stateProc.running || brightnessControl.reading || !stateFresh) return
    orientationError = ""
    var command = ["systemd-run", "--user", "--wait", "--collect", "--pipe", "--quiet", "--service-type=exec", "--property=RuntimeMaxSec=60", "--unit=omarchy-display-orientation", "--", "python3", "-B", root.helperDirectory + "rotate.py", selectedMonitor, String(displayedTransform)]
    command.push("--expected-description", selectedIdentity)
    command.push("--expected-state", JSON.stringify(draftBaseline || Model.monitorSnapshot(orientationDisplay)))
    if (draftScale !== "") command.push("--scale", draftScale)
    orientationProc.command = command
    orientationProc.running = true
  }

  // ---- Text size (shell base font + GTK text-scaling, via one CLI) ----
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
    if (opened) {
      refresh()
      focusSection = "monitors"
      selectedIndex = 0
      cursorActive = false
      monitorPowerFocused = false
    }
  }

  onBrightnessAvailableChanged: clampCursor()
  onDisplaysChanged: clampCursor()
  Connections {
    target: Quickshell
    function onScreensChanged() { Qt.callLater(root.refresh) }
  }
  onScaleValuesChanged: clampCursor()
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
    property int requestSerial: -1
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (stateProc.requestSerial !== root.selectionSerial) return
        try {
          var data = JSON.parse(text)
          var nextDisplay = data.displays.find(function(d) { return d.name === data.selected })
          var identity = nextDisplay ? nextDisplay.description : ""
          if (data.selected !== root.selectedMonitor || (root.selectedIdentity && identity !== root.selectedIdentity)) {
            if (root.selectedMonitor) root.orientationError = "Display connection changed; review the selected display."
            brightnessControl.invalidate()

            root.draftTransform = -1
            root.draftScale = ""
            root.draftBaseline = null
          }
          root.selectedMonitor = data.selected
          root.selectedIdentity = identity
          if (root.settingsDirty && root.draftBaseline && nextDisplay
              && JSON.stringify(root.draftBaseline) !== JSON.stringify(Model.monitorSnapshot(nextDisplay)))
            root.orientationError = "Display settings changed; discard pending changes and review."
          root.updateDisplays(data.displays)
          root.monitorScale = root.orientationDisplay ? root.normalizeScale(root.orientationDisplay.scale) : ""
          root.stateFresh = true
        } catch (e) { root.stateFresh = false; root.orientationError = "Could not read display settings" }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) { root.stateFresh = false; root.orientationError = "Could not read display settings" }
      if (requestSerial !== root.selectionSerial) Qt.callLater(root.refresh)
    }
  }

  Process {
    id: orientationProc
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector { id: orientationStderr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.orientationError = String(orientationStderr.text || "Could not change display settings").trim()
      else { root.draftTransform = -1; root.draftScale = ""; root.draftBaseline = null }
      root.refresh()
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
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(700))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) {
          if (root.focusSection === "brightness") root.adjustBrightness(dx * 5)
          else if (root.focusSection === "textsize") root.adjustTextSize(dx)
          else root.moveCursorH(dx)
        }
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
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

          // ---------- Hero: display icon · title/status ----------
          Item {
            width: parent.width
            implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

            Text {
              id: heroIcon
              textFormat: Text.PlainText
              text: root.displays.length > 1 ? "󰍺" : "󰍹"
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
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: "Display"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              Text {
                id: heroLabel
                textFormat: Text.PlainText
                text: "Choose a display to configure"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 0
                elide: Text.ElideRight
                width: parent.width
              }
            }
          }

          // ---------- Monitors ----------
          PanelSeparator {
            visible: root.displays.length > 0
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(10)
            visible: root.displays.length > 0

            PanelSectionHeader {
              text: "SELECT DISPLAY"
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
            }

            Button {
              id: identifyButton
              width: parent.width
              text: "Identify displays"
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              hasCursor: root.cursorActive && root.focusSection === "identify"
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(identifyButton)
              onClicked: root.identifyDisplays("")
              onHovered: function(h) { if (h) { root.cursorActive = true; root.focusSection = "identify"; root.selectedIndex = 0 } }
            }

            Repeater {
              model: root.displays

              MonitorRow {
                required property var modelData
                required property int index

                width: panelColumn.width
                display: modelData
                rowIndex: index
              }
            }
          }

          // ---------- Brightness ----------
          PanelSeparator {
            visible: root.selectedMonitor !== ""
            foreground: root.bar.foreground
          }

          Column {
            visible: root.selectedMonitor !== ""
            width: parent.width
            spacing: Style.space(6)

            Item {
              width: parent.width
              implicitHeight: Math.max(brightnessHeader.implicitHeight, brightnessPercent.implicitHeight)

              PanelSectionHeader {
                id: brightnessHeader
                text: brightnessControl.scope === "shared" ? "SHARED BRIGHTNESS" : "BRIGHTNESS · " + root.selectedMonitor
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: brightnessPercent
                visible: root.brightnessAvailable
                textFormat: Text.PlainText
                text: Math.round(brightnessSlider.dragging ? brightnessSlider.liveValue : root.brightnessPercent) + "%"
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
              visible: root.brightnessAvailable
              width: parent.width
              height: brightnessSlider.implicitHeight + Style.spacing.controlGap
              hasCursor: root.cursorActive && root.focusSection === "brightness" && root.selectedIndex === -1
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(brightnessRow)
              foreground: root.bar.foreground
              outline: true

              PanelSlider {
                id: brightnessSlider
                enabled: !orientationProc.running
                bar: root.bar
                anchors.fill: parent
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                minimum: 1
                maximum: 100
                step: 1
                value: root.brightnessPercent
                integer: true
                onMoved: function(v) { root.previewBrightness(v) }
                onReleased: function(v) {
                  brightnessControl.cancelPreview()
                  root.setBrightness(v)
                }
              }

              HoverHandler {
                onHoveredChanged: if (hovered && !root.reflowingText) {
                  root.cursorActive = true
                  root.focusSection = "brightness"
                  root.selectedIndex = -1
                }
              }
            }

            Text {
              width: parent.width
              visible: !root.brightnessAvailable || brightnessControl.error !== "" || brightnessControl.scope !== "display"
              textFormat: Text.PlainText
              text: brightnessControl.error || (brightnessControl.status === "loading"
                ? "Reading this display's brightness…"
                : brightnessControl.scope === "shared"
                  ? "Adjusts " + brightnessControl.affectedDisplays.join(", ") + " together."
                  : root.brightnessAvailable
                    ? "Controlled by the monitor; linked panels may change together."
                    : "Brightness control is unavailable for this display.")
              wrapMode: Text.Wrap
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          // ---------- Scale ----------
          PanelSeparator {
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(10)

            Item {
              width: parent.width
              implicitHeight: Math.max(scaleHeader.implicitHeight, scaleMonitor.implicitHeight)

              PanelSectionHeader {
                id: scaleHeader
                text: "SCALE"
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              // Name the monitor SCALE targets, so the setting target stays explicit.
              Text {
                id: scaleMonitor
                textFormat: Text.PlainText
                text: root.selectedMonitor
                // Only worth naming when more than one display is in play.
                visible: root.selectedMonitor !== "" && root.enabledDisplayCount > 1
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
              id: scaleRow
              width: parent.width
              columns: root.scaleValues.length
              spacing: Style.spacing.xs

              readonly property real cellWidth: root.scaleValues.length > 0
                ? (width - spacing * (columns - 1)) / columns
                : 0

              Repeater {
                model: root.scaleValues

                ScalePill {
                  required property string modelData
                  required property int index

                  scaleValue: modelData
                  scaleIndex: index
                  width: scaleRow.cellWidth
                }
              }
            }
          }

          // ---------- Orientation ----------
          PanelSeparator {
            visible: root.orientationDisplay !== null
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            visible: root.orientationDisplay !== null
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "ORIENTATION · " + root.selectedMonitor
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
            }

            Row {
              id: orientationRow
              width: parent.width
              spacing: Style.spacing.xs

              Repeater {
                model: root.orientationLabels
                Button {
                  id: orientationButton
                  required property string modelData
                  required property int index
                  width: (orientationRow.width - orientationRow.spacing * 3) / 4
                  text: modelData
                  fontSize: Style.font.caption
                  foreground: root.bar.foreground
                  fontFamily: root.bar.fontFamily
                  horizontalPadding: Style.spacing.xs
                  verticalPadding: Style.spacing.controlPaddingY
                  bordered: true
                  enabled: !root.settingsBusy && root.stateFresh && root.orientationDisplay !== null
                  active: root.displayedTransform === index
                  hasCursor: root.cursorActive && root.focusSection === "orientation" && root.selectedIndex === index
                  onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(orientationButton)
                  onClicked: root.setOrientation(index)
                  onHovered: function(isHovered) {
                    if (!isHovered || root.reflowingText) return
                    root.cursorActive = true
                    root.focusSection = "orientation"
                    root.selectedIndex = index
                  }
                }
              }
            }

            Text {
              width: parent.width
              visible: orientationProc.running || root.orientationError !== ""
              textFormat: Text.PlainText
              text: orientationProc.running ? "Applying display settings…" : root.orientationError
              wrapMode: Text.Wrap
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
            }
          }


          Row {
            width: parent.width
            spacing: Style.space(8)
            Button {
              id: applyButton
              width: (parent.width - parent.spacing) * 0.65
              text: orientationProc.running ? "Applying…" : "Apply changes"
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              active: root.settingsDirty
              enabled: root.settingsDirty && !root.settingsBusy && !stateProc.running && !brightnessControl.reading && root.stateFresh
              hasCursor: root.cursorActive && root.focusSection === "apply" && root.selectedIndex === 0
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(applyButton)
              onClicked: root.applySettings()
              onHovered: function(h) { if (h) { root.cursorActive = true; root.focusSection = "apply"; root.selectedIndex = 0 } }
            }
            Button {
              width: (parent.width - parent.spacing) * 0.35
              text: "Discard"
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              enabled: root.settingsDirty && !root.settingsBusy
              hasCursor: root.cursorActive && root.focusSection === "apply" && root.selectedIndex === 1
              onClicked: root.discardSettings()
              onHovered: function(h) { if (h) { root.cursorActive = true; root.focusSection = "apply"; root.selectedIndex = 1 } }
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
                text: "TEXT SIZE · ALL DISPLAYS"
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: textSizePx
                textFormat: Text.PlainText
                text: (textSizeSlider.dragging
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
                onHoveredChanged: if (hovered && !root.reflowingText) {
                  root.cursorActive = true
                  root.focusSection = "textsize"
                  root.selectedIndex = -1
                }
              }
            }
          }


          Item {
            width: parent.width
            height: Style.space(4)
          }
        }
      }
    }
  }

  component ScalePill: Button {
    id: pill
    required property string scaleValue
    required property int scaleIndex

    text: root.effectiveScale(scaleValue) + "x"
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: root.activeScaleIndex() === scaleIndex
    hasCursor: root.cursorActive && root.focusSection === "scale" && root.selectedIndex === scaleIndex

    enabled: !root.settingsBusy && root.stateFresh && root.orientationDisplay !== null
    onClicked: root.setScale(scaleValue)
    onHovered: function(isHovered) {
      if (!isHovered || root.reflowingText) return
      root.cursorActive = true
      root.focusSection = "scale"
      root.selectedIndex = pill.scaleIndex
    }
  }

  component MonitorRow: CursorSurface {
    id: monitorRow
    required property var display
    required property int rowIndex

    readonly property bool isFocused: display && display.name === root.selectedMonitor
    readonly property bool canSelect: display && display.enabled && !root.settingsBusy
    readonly property bool cursorOnRow: root.cursorActive && root.focusSection === "monitors" && root.selectedIndex === rowIndex

    hasCursor: cursorOnRow && !root.monitorPowerFocused
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(monitorRow)
    current: isFocused
    foreground: root.bar.foreground
    fill: Style.hoverFillFor(root.bar.foreground, Commons.Color.accent)
    currentFill: Style.selectedFillFor(root.bar.foreground, Commons.Color.accent)
    implicitHeight: monitorInner.implicitHeight + Style.spacing.xl
    opacity: root.settingsBusy ? 0.45 : 1.0

    Row {
      id: monitorInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: displayPowerButton.width + Style.space(12)
      spacing: Style.space(8)

      Text {
        text: String(monitorRow.rowIndex + 1)
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.title
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        textFormat: Text.PlainText
        text: (monitorRow.display.model || monitorRow.display.name) + " · " + monitorRow.display.name
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        width: parent.width - Style.space(22) - Style.space(14) - Style.space(16)
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        textFormat: Text.PlainText
        text: monitorRow.isFocused ? "󰄬" : (monitorRow.display.enabled ? "" : "Off")
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.subtitle
        width: Style.space(14)
        horizontalAlignment: Text.AlignRight
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      anchors.rightMargin: displayPowerButton.width + Style.space(12)
      cursorShape: monitorRow.canSelect ? Qt.PointingHandCursor : Qt.ArrowCursor
      onContainsMouseChanged: if (containsMouse && !root.reflowingText) {
        root.cursorActive = true
        root.focusSection = "monitors"
        root.selectedIndex = monitorRow.rowIndex
        root.monitorPowerFocused = false
      }
      onClicked: if (monitorRow.canSelect) root.selectDisplay(monitorRow.display.name)
    }

    Button {
      id: displayPowerButton
      anchors.right: parent.right
      anchors.rightMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      text: monitorRow.display.enabled ? "Disable" : "Enable"
      foreground: root.bar.foreground
      fontFamily: root.bar.fontFamily
      fontSize: Style.font.caption
      bordered: true
      hasCursor: monitorRow.cursorOnRow && root.monitorPowerFocused
      onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(monitorRow)
      onHovered: function(hovered) {
        if (!hovered || root.reflowingText) return
        root.cursorActive = true
        root.focusSection = "monitors"
        root.selectedIndex = monitorRow.rowIndex
        root.monitorPowerFocused = true
      }
      enabled: !root.settingsBusy && !root.settingsDirty && root.stateFresh
        && (!monitorRow.display.enabled || root.enabledDisplayCount > 1)
      onClicked: root.toggleDisplay(monitorRow.display.name, monitorRow.display.enabled)
    }
  }
}
