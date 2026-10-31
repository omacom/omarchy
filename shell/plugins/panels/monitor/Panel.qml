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
  // the bar icon's wheel and the hero follow; each display's own level lives in
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
  property int enabledDisplayCount: 0

  // Carry sub-notch touchpad deltas between wheel events.
  property real wheelAccumulator: 0

  // Cursor model shared by keyboard and mouse. Sections:
  //   "textsize"   - single slider row, selectedIndex = -1 sentinel
  //                  (mirrors Audio's slider rows).
  // Then, for each display's segment:
  //   "display:<name>" - the on/off switch in its header; only present with
  //                  more than one display.
  //   "brightness:<name>" - its brightness slider, the same -1 sentinel; only
  //                  present when the display's brightness can be controlled.
  //   "scale:<name>" - its scale presets, while it's on.
  //   "resolution:<name>" - the resolutions it advertises, while it's on and
  //                  has more than one to offer.
  // Every section is one row: j/k steps between them, h/l moves a slider or
  // walks the pills of a scale or resolution row, identical to bluetooth's
  // header.
  // Mouse hover on a target updates root state via the components' `hovered`
  // signal so keyboard cursor and pointer share one highlight.
  readonly property var scalePresets: ["1", "1.25", "1.6", "2", "3", "4"]
  // One segment per display, in Hyprland's order, like the agents panel's one
  // per agent: the scales its mode can reach and the resolutions it offers,
  // both empty while it's off. Brightness stays out of it, in brightnessLevels,
  // so a slider moving doesn't rebuild the segments under the pointer.
  readonly property var segments: {
    var list = []
    for (var i = 0; i < displays.length; i++) {
      var display = displays[i]
      if (!display || !display.name) continue
      var on = !!display.enabled && display.width > 0
      // Matched here, on the plain arrays: once they're handed through a QML
      // property they're no longer ones Array.isArray accepts.
      var scales = on ? Model.availableScales(scalePresets, display.width, display.height) : []
      var resolutions = on ? Model.resolutionOptions(display.availableModes, display.width, display.height) : []
      list.push({
        name: display.name,
        title: Model.displayTitle(display, Commons.I18n.t("monitor.builtInDisplay")),
        enabled: !!display.enabled,
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

  // "scale:DP-1" -> "scale"
  function sectionKind(section) {
    var text = String(section)
    var colon = text.indexOf(":")
    return colon < 0 ? text : text.slice(0, colon)
  }

  // The segment a "<kind>:<name>" section belongs to.
  function segmentFor(section) {
    var text = String(section)
    var name = text.slice(text.indexOf(":") + 1)
    for (var i = 0; i < segments.length; i++)
      if (segments[i].name === name) return segments[i]
    return null
  }

  // A row of pills: a scale or resolution row.
  function isPillSection(section) {
    var kind = sectionKind(section)
    return kind === "scale" || kind === "resolution"
  }

  // A lone slider, held at the -1 sentinel.
  function isSliderSection(section) {
    var kind = sectionKind(section)
    return kind === "textsize" || kind === "brightness"
  }

  // A display's brightness percent, or -1 when it can't be controlled.
  function brightnessOf(name) {
    var level = brightnessLevels[name]
    return level === undefined || level === null ? -1 : level
  }

  // Where the keyboard lands on open: the focused display's brightness, else
  // its scale, else the first row there is.
  function landingSection() {
    var sections = visibleSections
    var preferred = ["brightness:" + focusedMonitor, "scale:" + focusedMonitor]
    for (var i = 0; i < preferred.length; i++)
      if (sections.indexOf(preferred[i]) >= 0) return preferred[i]
    return sections.length > 0 ? sections[0] : ""
  }

  function pointAt(section, index) {
    if (root.reflowingText) return
    root.cursorActive = true
    root.focusSection = section
    root.selectedIndex = index
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
    var list = ["textsize"]
    for (var i = 0; i < segments.length; i++) {
      var segment = segments[i]
      if (segments.length > 1) list.push("display:" + segment.name)
      if (segment.enabled && brightnessOf(segment.name) >= 0) list.push("brightness:" + segment.name)
      if (segment.scales.length > 0) list.push("scale:" + segment.name)
      if (segment.resolutions.length > 0) list.push("resolution:" + segment.name)
    }
    return list
  }

  function sectionCount(section) {
    var kind = sectionKind(section)
    if (kind === "display") return 1
    var segment = segmentFor(section)
    if (!segment) return 0
    if (kind === "scale") return segment.scales.length
    if (kind === "resolution") return segment.resolutions.length
    return 0  // sliders: only the sentinel at -1
  }

  function sectionFirstIndex(section) {
    return isSliderSection(section) ? -1 : 0
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

  // h/l: in the scale and resolution rows, walks the pills; everywhere else,
  // no-op because the sliders handle their own horizontal motion.
  function moveCursorH(delta) {
    if (!isPillSection(focusSection)) return
    var next = selectedIndex + delta
    if (next < 0) next = 0
    if (next > sectionCount(focusSection) - 1) next = sectionCount(focusSection) - 1
    selectedIndex = next
  }

  function activateCursor() {
    var segment = segmentFor(focusSection)
    if (!segment) return
    var kind = sectionKind(focusSection)
    if (kind === "display") toggleDisplay(segment.name, segment.enabled)
    else if (kind === "scale" && selectedIndex >= 0 && selectedIndex < segment.scales.length)
      setScale(segment.name, segment.scales[selectedIndex])
    else if (kind === "resolution" && selectedIndex >= 0 && selectedIndex < segment.resolutions.length)
      setResolution(segment.name, segment.resolutions[selectedIndex])
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
    // Sliders use the -1 sentinel; the switch and pills clamp into their row.
    var count = sectionCount(focusSection)
    if (isSliderSection(focusSection)) selectedIndex = -1
    else if (selectedIndex < 0 || selectedIndex >= count) selectedIndex = 0
  }

  // Keep the keyboard-focused row inside the viewport when the panel grows
  // taller than its allotted height (lots of displays). Mirrors audio's
  // ensureCursorVisible helper.
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
    if (top < viewTop + margin) flick.contentY = Math.max(0, top - margin)
    else if (bottom > viewBottom - margin)
      flick.contentY = bottom + margin - flick.height
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
    var current = brightnessOf(name)
    if (current < 0) return
    setDisplayBrightness(name, current + delta)
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

  // Only take the list when it changed: a new one rebuilds every segment,
  // which would drop a hover or a drag in progress on each poll.
  function updateDisplays(displaysJson) {
    if (displaysJson === root.displaysJson) return
    root.displaysJson = displaysJson
    var parsed = Model.parseDisplays(displaysJson)
    var levels = {}
    for (var i = 0; i < parsed.displays.length; i++) {
      var display = parsed.displays[i]
      if (display && display.enabled && typeof display.brightness === "number")
        levels[display.name] = display.brightness
    }
    root.brightnessLevels = levels
    root.displays = parsed.displays
    root.enabledDisplayCount = parsed.enabledDisplayCount
  }

  function toggleDisplay(name, enabled) {
    if (!name) return
    if (enabled && root.enabledDisplayCount <= 1) return

    // hyprctl keyword is rejected under the Lua config ("non-legacy parsers"),
    // so drive the monitor through the hl.monitor eval API instead.
    var output = '"' + name.replace(/[\\"]/g, "\\$&") + '"'
    // hl.monitor updates the existing rule. Keep its mode, position and scale
    // when bringing the display back.
    var expr = enabled
      ? 'hl.monitor({ output = ' + output + ', disabled = true })'
      : 'hl.monitor({ output = ' + output + ', disabled = false })'
    actionProc.command = ["hyprctl", "eval", expr]
    if (!actionProc.running) actionProc.running = true
  }

  function setScale(name, scale) {
    actionProc.command = ["omarchy-hyprland-monitor-scaling", "--monitor", name, scale]
    if (!actionProc.running) actionProc.running = true
  }

  function setResolution(name, resolution) {
    actionProc.command = ["omarchy-hyprland-monitor-resolution", "--monitor", name, resolution]
    if (!actionProc.running) actionProc.running = true
  }

  // ---- Text size (shell base font + GTK text-scaling, via one CLI) ----
  // One size for the whole session: the shell font, GTK and the terminals each
  // take a single value, so unlike the rest of the panel it isn't per display.
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
    // A segment per display adds up, so it reaches as far as the agents panel.
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(860))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias scrollArea: scrollArea
      implicitHeight: panelColumn.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) {
          var kind = root.sectionKind(root.focusSection)
          if (kind === "brightness") root.adjustBrightness(root.segmentFor(root.focusSection).name, dx * 5)
          else if (kind === "textsize") root.adjustTextSize(dx)
          else if (root.isPillSection(root.focusSection)) root.moveCursorH(dx)
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
                text: Commons.I18n.t("monitor.display")
                textFormat: Text.PlainText
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
                text: root.brightnessAvailable
                  ? root.brightnessName(root.brightnessPercent).toUpperCase()
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

          // ---------- One segment per display ----------
          Repeater {
            model: root.segments

            DisplaySegment {
              required property var modelData
              width: panelColumn.width
              entry: modelData
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

  // One display's segment, like an agent's in the agents panel: its name and
  // on/off switch, then its brightness, scale and resolution while it's on.
  component DisplaySegment: Column {
    id: segment
    required property var entry
    readonly property bool canToggle: !entry.enabled || root.enabledDisplayCount > 1
    readonly property string brightnessSection: "brightness:" + entry.name
    readonly property int brightness: root.brightnessOf(entry.name)
    spacing: Style.space(14)

    PanelSeparator { foreground: root.bar.foreground }

    // Its name, and beneath it the connector and mode, like an agent's header.
    Item {
      width: parent.width
      implicitHeight: Math.max(segmentIcon.implicitHeight, segmentLabels.implicitHeight,
                               segmentSwitch.visible ? segmentSwitch.implicitHeight : 0)

      Text {
        id: segmentIcon
        textFormat: Text.PlainText
        text: "󰍹"
        color: root.bar.foreground
        opacity: segment.entry.enabled ? 1.0 : 0.45
        font.family: root.bar.fontFamily
        // Spans the two header lines, a step below the hero's icon.
        font.pixelSize: Math.round(Style.font.display * 0.8)
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      Column {
        id: segmentLabels
        anchors.left: segmentIcon.right
        anchors.leftMargin: Style.space(12)
        anchors.right: segmentSwitch.visible ? segmentSwitch.left : parent.right
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        opacity: segment.entry.enabled ? 1.0 : 0.45
        spacing: Style.space(2)

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: segment.entry.title
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.subtitle
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: {
            var detail = segment.entry.enabled && segment.entry.width > 0
              ? segment.entry.name + " · " + segment.entry.current.replace("x", "×")
              : segment.entry.name
            // Focus only says something when there's another display it could be on.
            return segment.entry.focused && root.enabledDisplayCount > 1
              ? Commons.I18n.t("monitor.displayFocused").arg(detail)
              : detail
          }
          color: Qt.darker(root.bar.foreground, 1.4)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
          elide: Text.ElideRight
        }
      }

      // Turning the last display off would leave nothing to turn it back on
      // from, so its switch stays on and dimmed. Sized to the header's text
      // rather than as a full control, like the network panel's band switch.
      ToggleSwitch {
        id: segmentSwitch
        visible: root.segments.length > 1
        trackHeight: Math.round(Style.font.body * 1.2)
        checked: segment.entry.enabled
        opacity: segment.canToggle ? 1.0 : 0.45
        hasCursor: root.cursorActive && root.focusSection === "display:" + segment.entry.name
        foreground: root.bar.foreground
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(segmentSwitch)
        onHovered: function(on) { if (on) root.pointAt("display:" + segment.entry.name, 0) }
        onToggled: root.toggleDisplay(segment.entry.name, segment.entry.enabled)
      }
    }

    // ---------- Brightness ----------
    Column {
      visible: segment.entry.enabled && segment.brightness >= 0
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
          text: Commons.I18n.formatNumber(Math.round(brightnessSlider.dragging ? brightnessSlider.liveValue : segment.brightness)) + "%"
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
        hasCursor: root.cursorActive && root.focusSection === segment.brightnessSection && root.selectedIndex === -1
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
          value: Math.max(1, segment.brightness)
          integer: true
          onMoved: function(v) { root.previewBrightness(segment.entry.name, v) }
          onReleased: function(v) {
            brightnessDebounce.stop()
            root.setDisplayBrightness(segment.entry.name, v)
          }
        }

        HoverHandler {
          onHoveredChanged: if (hovered) root.pointAt(segment.brightnessSection, -1)
        }
      }
    }

    // ---------- Scale ----------
    Column {
      visible: segment.entry.scales.length > 0
      width: parent.width
      spacing: Style.space(10)

      PanelSectionHeader {
        text: Commons.I18n.t("monitor.scale")
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
      }

      Grid {
        id: scaleGrid
        width: parent.width
        columns: Math.max(1, segment.entry.scales.length)
        spacing: Style.spacing.xs

        readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

        Repeater {
          model: segment.entry.scales

          ScalePill {
            required property string modelData
            required property int index

            entry: segment.entry
            scaleValue: modelData
            scaleIndex: index
            width: scaleGrid.cellWidth
          }
        }
      }
    }

    // ---------- Resolution ----------
    // The pills only carry short names; the exact mode is in the header.
    Column {
      visible: segment.entry.resolutions.length > 0
      width: parent.width
      spacing: Style.space(10)

      PanelSectionHeader {
        text: Commons.I18n.t("monitor.resolution")
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
      }

      Grid {
        id: resolutionGrid
        width: parent.width
        columns: Math.max(1, segment.entry.resolutions.length)
        spacing: Style.spacing.xs

        readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

        Repeater {
          model: segment.entry.resolutions

          ResolutionPill {
            required property string modelData
            required property int index

            entry: segment.entry
            resolution: modelData
            resolutionIndex: index
            width: resolutionGrid.cellWidth
          }
        }
      }
    }
  }

  component ScalePill: Button {
    id: pill
    required property var entry
    required property string scaleValue
    required property int scaleIndex
    readonly property string section: "scale:" + entry.name

    text: Commons.I18n.formatNumber(Model.cleanScale(scaleValue, entry.width, entry.height)) + "x"
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: entry.scaleIndex === scaleIndex
    hasCursor: root.cursorActive && root.focusSection === section && root.selectedIndex === scaleIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(pill)

    onClicked: root.setScale(entry.name, scaleValue)
    onHovered: function(isHovered) { if (isHovered) root.pointAt(pill.section, pill.scaleIndex) }
  }

  component ResolutionPill: Button {
    id: resolutionPill
    required property var entry
    required property string resolution
    required property int resolutionIndex
    readonly property string section: "resolution:" + entry.name

    text: Model.resolutionLabel(resolution)
    fontSize: Style.font.caption
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.sm
    verticalPadding: Style.spacing.controlPaddingY
    bordered: true

    active: entry.current === resolution
    hasCursor: root.cursorActive && root.focusSection === section && root.selectedIndex === resolutionIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(resolutionPill)

    onClicked: root.setResolution(entry.name, resolution)
    onHovered: function(isHovered) { if (isHovered) root.pointAt(resolutionPill.section, resolutionPill.resolutionIndex) }
  }
}
