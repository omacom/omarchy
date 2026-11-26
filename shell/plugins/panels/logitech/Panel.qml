import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model
import "Store.js" as Store

Panel {
  id: root
  moduleName: "omarchy.logitech"
  ipcTarget: "omarchy.logitech"
  manageIpc: false

  readonly property string cachePath: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/omarchy/logitech-mouse.json"
  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.45)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool showPercentage: setting("showPercentage", false) === true
  readonly property real openPanelIndicatorWidth: showPercentage && !button.vertical ? button.glyphPaintedWidth : 0

  property bool mouseConnected: false
  property bool refreshing: false
  property bool applying: false
  property string lastError: ""

  property string deviceName: ""
  property string deviceSerial: ""
  property string deviceTransport: ""

  property bool batteryKnown: false
  property int batteryLevel: -1
  property string batteryStatus: "unknown"
  property bool batteryCharging: false

  property var hosts: []
  property string currentHost: ""

  property bool hasDpi: false
  property int dpiValue: 1000
  property int dpiMin: 200
  property int dpiMax: 8000
  property int dpiStep: 50
  property int dpiPreview: 1000
  property bool dpiDragging: false
  readonly property var dpiPresets: hasDpi ? Model.dpiPresets(dpiMin, dpiMax) : []

  property bool hasRatchet: false
  property string ratchetValue: "Ratcheted"
  property var ratchetChoices: []

  property bool hasSmartShift: false
  property int smartShiftValue: 10
  property int smartShiftMin: 1
  property int smartShiftMax: 50
  property int smartShiftPreview: 10
  property bool smartShiftDragging: false

  property bool hasTorque: false
  property int torqueValue: 75
  property int torqueMin: 1
  property int torqueMax: 100
  property int torquePreview: 75
  property bool torqueDragging: false

  property bool hasHires: false
  property bool hiresValue: false
  property bool hasInvertVertical: false
  property bool invertVerticalValue: false
  property bool hasInvertThumb: false
  property bool invertThumbValue: false

  property bool hasHaptics: false
  property int hapticLevel: 0
  property int hapticMin: 0
  property int hapticMax: 100
  property int hapticPreview: 0
  property bool hapticDragging: false
  property bool canTestHaptics: false

  property var buttons: []
  property bool buttonsExpanded: false

  readonly property bool anySliderDragging: dpiDragging || smartShiftDragging || torqueDragging || hapticDragging
  readonly property bool hasScrollSection: hasRatchet || hasSmartShift || hasTorque || hasHires || hasInvertVertical || hasInvertThumb
  readonly property bool lowBattery: batteryKnown && batteryLevel <= 15 && !batteryCharging
  readonly property int remappedButtonCount: Model.remappedCount(buttons)
  readonly property real batteryFraction: batteryKnown ? Math.max(0, Math.min(1, batteryLevel / 100)) : 0

  function batteryStatusText() {
    var kind = Model.batteryStatusKind({
      known: batteryKnown,
      level: batteryLevel,
      status: batteryStatus,
      charging: batteryCharging
    })
    if (kind === "charging") return Commons.I18n.t("logitech.charging")
    if (kind === "full") return Commons.I18n.t("logitech.full")
    if (kind === "low") return Commons.I18n.t("logitech.lowBattery")
    if (kind === "discharging") return Commons.I18n.t("logitech.discharging")
    return Commons.I18n.t("logitech.connected")
  }

  function ratchetLabel(raw) {
    return Model.isFreespinMode(raw)
      ? Commons.I18n.t("logitech.freespinning")
      : Commons.I18n.t("logitech.ratcheted")
  }

  readonly property string heroStatusText: {
    if (applying) return Commons.I18n.t("logitech.applying")
    if (refreshing && !mouseConnected) return Commons.I18n.t("logitech.refreshing")
    var parts = []
    if (deviceTransport !== "") parts.push(deviceTransport)
    parts.push(batteryStatusText())
    return parts.join(" · ")
  }

  visible: mouseConnected
  implicitWidth: mouseConnected ? button.implicitWidth : 0
  implicitHeight: mouseConnected ? button.implicitHeight : 0

  onMouseConnectedChanged: {
    if (!mouseConnected && opened) close()
  }

  onOpenedChanged: {
    if (opened) {
      if (!mouseConnected) {
        Qt.callLater(function() { root.close() })
        return
      }
      refresh()
      Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
    }
  }

  Component.onCompleted: {
    Store.register(root)
    if (Store.isLeader(root)) {
      var cached = cacheFile.text()
      if (cached && cached.trim() !== "") Store.applyStatusPayload(cached)
      Store.requestStatus(root)
    }
  }

  Component.onDestruction: {
    Store.unregister(root)
  }

  function syncFromStore(st) {
    mouseConnected = st.connected
    refreshing = st.refreshing
    applying = st.applying
    lastError = st.lastError
    deviceName = st.name
    deviceSerial = st.serial
    deviceTransport = st.transport
    batteryKnown = st.batteryKnown
    batteryLevel = st.batteryLevel
    batteryStatus = st.batteryStatus
    batteryCharging = st.batteryCharging
    hosts = st.hosts
    currentHost = st.currentHost
    hasDpi = st.hasDpi
    dpiValue = st.dpiValue
    dpiMin = st.dpiMin
    dpiMax = st.dpiMax
    dpiStep = st.dpiStep
    if (!dpiDragging) dpiPreview = st.dpiValue
    hasRatchet = st.hasRatchet
    ratchetValue = st.ratchetValue
    ratchetChoices = st.ratchetChoices
    hasSmartShift = st.hasSmartShift
    smartShiftValue = st.smartShiftValue
    smartShiftMin = st.smartShiftMin
    smartShiftMax = st.smartShiftMax
    if (!smartShiftDragging) smartShiftPreview = st.smartShiftValue
    hasTorque = st.hasTorque
    torqueValue = st.torqueValue
    torqueMin = st.torqueMin
    torqueMax = st.torqueMax
    if (!torqueDragging) torquePreview = st.torqueValue
    hasHires = st.hasHires
    hiresValue = st.hiresValue
    hasInvertVertical = st.hasInvertVertical
    invertVerticalValue = st.invertVerticalValue
    hasInvertThumb = st.hasInvertThumb
    invertThumbValue = st.invertThumbValue
    hasHaptics = st.hasHaptics
    hapticLevel = st.hapticLevel
    hapticMin = st.hapticMin
    hapticMax = st.hapticMax
    if (!hapticDragging) hapticPreview = st.hapticLevel
    canTestHaptics = st.canTestHaptics
    buttons = st.buttons
  }

  function execCli(args, kind, refreshAfter) {
    ctlProc.execKind = kind
    ctlProc.refreshAfter = Boolean(refreshAfter)
    ctlProc.command = ["omarchy-mouse-logitech", "--json"].concat(args)
    ctlProc.running = true
  }

  function serialArgs() {
    return deviceSerial !== "" ? ["--serial", deviceSerial] : []
  }

  function refresh() {
    Store.requestStatus(root)
  }

  function togglePercentage() {
    root.settings = Object.assign({}, root.settings, { showPercentage: !root.showPercentage })
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function") {
      root.bar.shell.updateEntryInline(root.moduleName, root.settings)
    }
  }

  function setDpi(val) {
    var snapped = Model.snapValue(val, dpiMin, dpiMax, dpiStep)
    dpiPreview = snapped
    Store.setOptimistic({ dpiValue: snapped })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["dpi", String(snapped)]), false, root)
  }

  function setRatchet(mode) {
    if (!mode || mode === ratchetValue) return
    Store.setOptimistic({ ratchetValue: mode })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["scroll-ratchet", String(mode)]), false, root)
  }

  function setSmartShift(val) {
    var snapped = Model.snapValue(val, smartShiftMin, smartShiftMax, 1)
    smartShiftPreview = snapped
    Store.setOptimistic({ smartShiftValue: snapped })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["smart-shift", String(snapped)]), false, root)
  }

  function setTorque(val) {
    var snapped = Model.snapValue(val, torqueMin, torqueMax, 1)
    torquePreview = snapped
    Store.setOptimistic({ torqueValue: snapped })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["scroll-ratchet-torque", String(snapped)]), false, root)
  }

  function toggleHires() {
    var next = !hiresValue
    Store.setOptimistic({ hiresValue: next })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["hires-smooth-resolution", next ? "true" : "false"]), false, root)
  }

  function toggleInvertVertical() {
    var next = !invertVerticalValue
    Store.setOptimistic({ invertVerticalValue: next })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["hires-smooth-invert", next ? "true" : "false"]), false, root)
  }

  function toggleInvertThumb() {
    var next = !invertThumbValue
    Store.setOptimistic({ invertThumbValue: next })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["thumb-scroll-invert", next ? "true" : "false"]), false, root)
  }

  function setHapticLevel(val) {
    var snapped = Model.snapValue(val, hapticMin, hapticMax, 5)
    hapticPreview = snapped
    Store.setOptimistic({ hapticLevel: snapped })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["haptic-level", String(snapped)]), false, root)
  }

  function testHaptic() {
    Store.enqueueWrite(["set"].concat(serialArgs(), ["haptic-play", "SUBTLE COLLISION"]), false, root)
  }

  function switchHost(hostValue) {
    if (!hostValue || hostValue === currentHost) return
    Store.setOptimistic({ currentHost: hostValue })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["change-host", String(hostValue)]), false, root)
    hostSwitchTimer.restart()
  }

  function remapButton(keyId, actionId) {
    var updated = []
    for (var i = 0; i < buttons.length; i++) {
      var b = buttons[i]
      if (String(b.keyId) === String(keyId)) {
        var copy = Object.assign({}, b)
        copy.value = String(actionId)
        copy.isDefault = String(actionId) === String(b.defaultValue)
        updated.push(copy)
      } else {
        updated.push(b)
      }
    }
    Store.setOptimistic({ buttons: updated })
    Store.enqueueWrite(["set"].concat(serialArgs(), ["reprogrammable-keys", String(keyId), String(actionId)]), false, root)
  }

  function resetButtons() {
    Store.enqueueWrite(["reset-buttons"].concat(serialArgs()), true, root)
  }

  function openSolaarApp() {
    close()
    if (root.bar && typeof root.bar.run === "function") {
      root.bar.run("solaar")
    }
  }

  FileView {
    id: cacheFile
    path: root.cachePath
    watchChanges: false
    printErrors: false
    blockAllReads: true
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }
    function togglePercentage(): void { root.togglePercentage() }
  }

  // Event-driven hotplug monitor: stays asleep in udevadm monitor with zero
  // idle process spawns until a hidraw device arrives or leaves.
  Process {
    id: udevMonitor
    command: ["udevadm", "monitor", "--subsystem-match=hidraw", "--udev"]
    running: Store.isLeader(root)
    stdout: SplitParser {
      onRead: function(line) {
        if (line.indexOf("UDEV ") === 0 && (line.indexOf(" add ") !== -1 || line.indexOf(" remove ") !== -1)) {
          hotplugDebounce.restart()
        }
      }
    }
  }

  Timer {
    id: hotplugDebounce
    interval: 750
    repeat: false
    onTriggered: Store.requestStatus(root)
  }

  Timer {
    id: hostSwitchTimer
    interval: 2000
    repeat: false
    onTriggered: Store.requestStatus(root)
  }

  Process {
    id: ctlProc
    property string execKind: "status"
    property bool refreshAfter: false
    property string stdoutBuf: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: ctlProc.stdoutBuf = text
    }
    onExited: function(exitCode) {
      var raw = ctlProc.stdoutBuf
      var kind = ctlProc.execKind
      var ref = ctlProc.refreshAfter
      ctlProc.stdoutBuf = ""
      ctlProc.refreshAfter = false
      Store.finishExec(kind, raw, exitCode, ref)
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍽"
    labelText: root.showPercentage && !vertical && root.batteryKnown
      ? Commons.I18n.formatNumber(root.batteryLevel) + "%"
      : ""
    slotSize: Style.bar.iconSlot * (root.showPercentage && !vertical && root.batteryKnown ? 2 : 1)
    active: root.lowBattery
    tooltipText: root.batteryKnown
      ? Model.plainSafe(Commons.I18n.t("logitech.tooltipWithBattery").arg(root.deviceName || Commons.I18n.t("logitech.title")).arg(Commons.I18n.formatNumber(root.batteryLevel)))
      : Model.plainSafe(root.deviceName || Commons.I18n.t("logitech.title"))
    onPressed: function(b) {
      if (!root.mouseConnected) return
      if (b === Qt.RightButton) root.togglePercentage()
      else if (b === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened && root.mouseConnected
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(620))

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refresh()
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height && !root.anySliderDragging
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(14)

          // ---------- Hero: mouse icon · model/status · battery % ----------
          Item {
            width: parent.width
            implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroPercent.implicitHeight)

            PlainText {
              id: heroIcon
              text: "󰍽"
              color: root.lowBattery ? root.urgent : root.foreground
              font.pixelSize: Style.font.display
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              id: heroLabels
              anchors.left: heroIcon.right
              anchors.leftMargin: Style.space(14)
              anchors.right: heroPercent.left
              anchors.rightMargin: Style.space(10)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              PlainText {
                text: root.deviceName || Commons.I18n.t("logitech.title")
                color: root.foreground
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              PlainText {
                text: root.heroStatusText.toUpperCase()
                color: root.lowBattery ? root.urgent : root.dim
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
                elide: Text.ElideRight
                width: parent.width
              }
            }

            PlainText {
              id: heroPercent
              text: root.batteryKnown ? Commons.I18n.formatNumber(root.batteryLevel) + "%" : "—"
              color: root.lowBattery ? root.urgent : root.foreground
              font.pixelSize: Style.font.displayLarge
              font.bold: true
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          // ---------- Battery progress bar ----------
          Item {
            visible: root.batteryKnown
            width: parent.width
            implicitHeight: Style.space(6)

            Rectangle {
              id: batTrack
              anchors.fill: parent
              radius: height / 2
              color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
            }

            Rectangle {
              anchors.left: batTrack.left
              anchors.verticalCenter: batTrack.verticalCenter
              height: batTrack.height
              radius: batTrack.radius
              color: root.lowBattery ? root.urgent : root.foreground
              width: Math.max(batTrack.height, batTrack.width * root.batteryFraction)

              Behavior on width {
                NumberAnimation { duration: Style.duration(260); easing.type: Easing.OutCubic }
              }
            }
          }

          // ---------- Error banner ----------
          PlainText {
            visible: root.lastError !== ""
            width: parent.width
            text: root.lastError
            color: root.urgent
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          // ---------- Easy-Switch Hosts ----------
          PanelSeparator {
            visible: root.hosts.length > 1
            foreground: root.foreground
          }

          Column {
            visible: root.hosts.length > 1
            width: parent.width
            spacing: Style.space(8)

            PanelSectionHeader {
              text: Commons.I18n.t("logitech.host")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Row {
              id: hostRow
              width: parent.width
              spacing: Style.space(6)

              readonly property real cellWidth: root.hosts.length > 0
                ? (width - spacing * (root.hosts.length - 1)) / root.hosts.length
                : 0

              Repeater {
                model: root.hosts
                Button {
                  required property var modelData
                  width: hostRow.cellWidth
                  text: Commons.I18n.formatNumber(modelData.index) + " · " + String(modelData.label || "")
                  fontSize: Style.font.bodySmall
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.space(6)
                  verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
                  bordered: true
                  active: root.currentHost === String(modelData.value)
                  onClicked: root.switchHost(String(modelData.value))
                }
              }
            }
          }

          // ---------- Sensitivity (DPI) ----------
          PanelSeparator {
            visible: root.hasDpi
            foreground: root.foreground
          }

          Column {
            visible: root.hasDpi
            width: parent.width
            spacing: Style.space(8)

            Item {
              width: parent.width
              implicitHeight: Math.max(dpiHeader.implicitHeight, dpiReadout.implicitHeight)

              PanelSectionHeader {
                id: dpiHeader
                text: Commons.I18n.t("logitech.sensitivity")
                foreground: root.foreground
                fontFamily: root.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              PlainText {
                id: dpiReadout
                text: Commons.I18n.t("logitech.dpiUnit").arg(Commons.I18n.formatNumber(root.dpiPreview))
                color: root.foreground
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Row {
              id: dpiPresetRow
              visible: root.dpiPresets.length > 0
              width: parent.width
              spacing: Style.space(6)

              readonly property real cellWidth: root.dpiPresets.length > 0
                ? (width - spacing * (root.dpiPresets.length - 1)) / root.dpiPresets.length
                : 0

              Repeater {
                model: root.dpiPresets
                Button {
                  required property var modelData
                  width: dpiPresetRow.cellWidth
                  text: Commons.I18n.formatNumber(Number(modelData))
                  fontSize: Style.font.bodySmall
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.space(4)
                  verticalPadding: Style.spacing.controlPaddingY
                  bordered: true
                  active: root.dpiValue === Number(modelData)
                  onClicked: root.setDpi(Number(modelData))
                }
              }
            }

            PanelSlider {
              width: parent.width
              bar: root.bar
              minimum: root.dpiMin
              maximum: root.dpiMax
              step: root.dpiStep
              integer: true
              value: root.dpiValue
              onMoved: function(v) {
                root.dpiDragging = true
                root.dpiPreview = Model.snapValue(v, root.dpiMin, root.dpiMax, root.dpiStep)
              }
              onReleased: function(v) {
                root.dpiDragging = false
                root.setDpi(v)
              }
            }
          }

          // ---------- Scroll Wheel ----------
          PanelSeparator {
            visible: root.hasScrollSection
            foreground: root.foreground
          }

          Column {
            visible: root.hasScrollSection
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: Commons.I18n.t("logitech.scroll")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Row {
              id: ratchetRow
              visible: root.hasRatchet && root.ratchetChoices.length > 0
              width: parent.width
              spacing: Style.space(6)

              readonly property real cellWidth: root.ratchetChoices.length > 0
                ? (width - spacing * (root.ratchetChoices.length - 1)) / root.ratchetChoices.length
                : 0

              Repeater {
                model: root.ratchetChoices
                Button {
                  required property var modelData
                  width: ratchetRow.cellWidth
                  text: root.ratchetLabel(modelData)
                  fontSize: Style.font.bodySmall
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.spacing.controlPaddingX
                  verticalPadding: Style.spacing.controlPaddingY + Style.space(1)
                  bordered: true
                  active: root.ratchetValue === String(modelData)
                  onClicked: root.setRatchet(String(modelData))
                }
              }
            }

            Column {
              visible: root.hasSmartShift
              width: parent.width
              spacing: Style.space(4)
              opacity: Model.isFreespinMode(root.ratchetValue) ? 0.45 : 1.0

              SliderLabelRow {
                label: Commons.I18n.t("logitech.smartShift")
                valueText: root.smartShiftPreview >= root.smartShiftMax
                  ? Commons.I18n.t("logitech.alwaysRatcheted")
                  : Commons.I18n.formatNumber(root.smartShiftPreview)
              }

              PanelSlider {
                width: parent.width
                bar: root.bar
                minimum: root.smartShiftMin
                maximum: root.smartShiftMax
                step: 1
                integer: true
                value: root.smartShiftValue
                onMoved: function(v) {
                  root.smartShiftDragging = true
                  root.smartShiftPreview = Math.round(v)
                }
                onReleased: function(v) {
                  root.smartShiftDragging = false
                  root.setSmartShift(v)
                }
              }
            }

            Column {
              visible: root.hasTorque
              width: parent.width
              spacing: Style.space(4)
              opacity: Model.isFreespinMode(root.ratchetValue) ? 0.45 : 1.0

              SliderLabelRow {
                label: Commons.I18n.t("logitech.torque")
                valueText: Commons.I18n.formatNumber(root.torquePreview) + "%"
              }

              PanelSlider {
                width: parent.width
                bar: root.bar
                minimum: root.torqueMin
                maximum: root.torqueMax
                step: 5
                integer: true
                value: root.torqueValue
                onMoved: function(v) {
                  root.torqueDragging = true
                  root.torquePreview = Math.round(v)
                }
                onReleased: function(v) {
                  root.torqueDragging = false
                  root.setTorque(v)
                }
              }
            }

            CompactToggleRow {
              visible: root.hasHires
              label: Commons.I18n.t("logitech.hires")
              checked: root.hiresValue
              onToggled: root.toggleHires()
            }

            CompactToggleRow {
              visible: root.hasInvertVertical
              label: Commons.I18n.t("logitech.invertVertical")
              checked: root.invertVerticalValue
              onToggled: root.toggleInvertVertical()
            }

            CompactToggleRow {
              visible: root.hasInvertThumb
              label: Commons.I18n.t("logitech.invertThumb")
              checked: root.invertThumbValue
              onToggled: root.toggleInvertThumb()
            }
          }

          // ---------- Haptic Feedback ----------
          PanelSeparator {
            visible: root.hasHaptics
            foreground: root.foreground
          }

          Column {
            visible: root.hasHaptics
            width: parent.width
            spacing: Style.space(8)

            Item {
              width: parent.width
              implicitHeight: Math.max(hapticHeader.implicitHeight, hapticControls.implicitHeight)

              PanelSectionHeader {
                id: hapticHeader
                text: Commons.I18n.t("logitech.haptics")
                foreground: root.foreground
                fontFamily: root.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                id: hapticControls
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(8)

                PlainText {
                  text: root.hapticPreview <= 0
                    ? Commons.I18n.t("logitech.hapticsOff")
                    : Commons.I18n.formatNumber(root.hapticPreview) + "%"
                  color: root.foreground
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                  anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                  visible: root.canTestHaptics && root.hapticLevel > 0
                  text: Commons.I18n.t("logitech.hapticsTest")
                  fontSize: Style.font.caption
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.space(8)
                  verticalPadding: Style.space(3)
                  bordered: true
                  onClicked: root.testHaptic()
                }
              }
            }

            PanelSlider {
              width: parent.width
              bar: root.bar
              minimum: root.hapticMin
              maximum: root.hapticMax
              step: 5
              integer: true
              value: root.hapticLevel
              onMoved: function(v) {
                root.hapticDragging = true
                root.hapticPreview = Model.snapValue(v, root.hapticMin, root.hapticMax, 5)
              }
              onReleased: function(v) {
                root.hapticDragging = false
                root.setHapticLevel(v)
              }
            }
          }

          // ---------- Button Mapping ----------
          PanelSeparator {
            visible: root.buttons.length > 0
            foreground: root.foreground
          }

          Column {
            visible: root.buttons.length > 0
            width: parent.width
            spacing: Style.space(8)

            Item {
              width: parent.width
              implicitHeight: Math.max(btnHeaderCol.implicitHeight, btnHeaderActions.implicitHeight)

              Column {
                id: btnHeaderCol
                anchors.left: parent.left
                anchors.right: btnHeaderActions.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(2)

                PanelSectionHeader {
                  text: Commons.I18n.t("logitech.buttons")
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                }

                PlainText {
                  text: root.remappedButtonCount > 0
                    ? Commons.I18n.tn("logitech.buttonsRemapped", root.remappedButtonCount).arg(Commons.I18n.formatNumber(root.remappedButtonCount))
                    : Commons.I18n.tn("logitech.buttonsDefault", root.buttons.length).arg(Commons.I18n.formatNumber(root.buttons.length))
                  color: root.dim
                  font.pixelSize: Style.font.caption
                }
              }

              Row {
                id: btnHeaderActions
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(6)

                Button {
                  visible: root.remappedButtonCount > 0
                  text: Commons.I18n.t("logitech.buttonsReset")
                  fontSize: Style.font.caption
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.space(8)
                  verticalPadding: Style.space(4)
                  bordered: true
                  onClicked: root.resetButtons()
                }

                Button {
                  text: root.buttonsExpanded ? Commons.I18n.t("logitech.buttonsHide") : Commons.I18n.t("logitech.buttonsShow")
                  fontSize: Style.font.caption
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.space(8)
                  verticalPadding: Style.space(4)
                  bordered: true
                  active: root.buttonsExpanded
                  onClicked: root.buttonsExpanded = !root.buttonsExpanded
                }
              }
            }

            Column {
              visible: root.buttonsExpanded
              width: parent.width
              spacing: Style.space(8)

              Repeater {
                model: root.buttons
                Item {
                  required property var modelData
                  width: parent.width
                  implicitHeight: Math.max(btnLabel.implicitHeight, btnDropdown.implicitHeight)

                  PlainText {
                    id: btnLabel
                    text: String(modelData.label || "")
                    color: modelData.isDefault ? root.foreground : Commons.Color.accent
                    font.pixelSize: Style.font.bodySmall
                    font.bold: !modelData.isDefault
                    elide: Text.ElideRight
                    anchors.left: parent.left
                    anchors.right: btnDropdown.left
                    anchors.rightMargin: Style.space(10)
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Dropdown {
                    id: btnDropdown
                    width: Math.round(parent.width * 0.56)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    showLabel: false
                    rowHeight: Style.space(30)
                    popupRowHeight: Style.space(28)
                    foreground: root.foreground
                    background: Commons.Color.popups.background
                    fontFamily: root.fontFamily
                    options: modelData.choices || []
                    value: String(modelData.value || "")
                    onChanged: function(val) {
                      root.remapButton(String(modelData.keyId), String(val))
                    }
                  }
                }
              }
            }
          }

          // ---------- Footer ----------
          PanelSeparator {
            foreground: root.foreground
          }

          Button {
            width: parent.width
            iconText: "󰒓"
            text: Commons.I18n.t("logitech.openSolaar")
            fontSize: Style.font.bodySmall
            foreground: root.foreground
            fontFamily: root.fontFamily
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            bordered: true
            onClicked: root.openSolaarApp()
          }
        }
      }
    }
  }

  component PlainText: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
  }

  component SliderLabelRow: Item {
    property string label: ""
    property string valueText: ""

    width: parent.width
    implicitHeight: Math.max(slLabel.implicitHeight, slVal.implicitHeight)

    PlainText {
      id: slLabel
      text: label
      color: root.dim
      font.pixelSize: Style.font.bodySmall
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
    }

    PlainText {
      id: slVal
      text: valueText
      color: root.foreground
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  component CompactToggleRow: Item {
    property string label: ""
    property bool checked: false
    signal toggled()

    width: parent.width
    implicitHeight: Math.max(toggleLabel.implicitHeight, toggleCtrl.implicitHeight)

    PlainText {
      id: toggleLabel
      text: label
      color: root.foreground
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
      anchors.left: parent.left
      anchors.right: toggleCtrl.left
      anchors.rightMargin: Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
    }

    ToggleSwitch {
      id: toggleCtrl
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      checked: parent.checked
      trackHeight: Style.space(20)
      cursorRing: false
      foreground: root.foreground
      onToggled: parent.toggled()
    }

    MouseArea {
      anchors.left: parent.left
      anchors.right: toggleCtrl.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      cursorShape: Qt.PointingHandCursor
      onClicked: parent.toggled()
    }
  }
}
