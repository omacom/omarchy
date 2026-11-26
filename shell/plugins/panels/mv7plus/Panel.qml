import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.mv7plus"
  ipcTarget: "omarchy.mv7plus"

  readonly property string helperPath: {
    var base = Quickshell.env("OMARCHY_PATH")
    if (base) return base + "/shell/plugins/panels/mv7plus/mv7plus-ctl.py"
    var url = Qt.resolvedUrl("mv7plus-ctl.py").toString()
    return url.indexOf("file://") === 0 ? decodeURIComponent(url.slice(7)) : url
  }

  // Items inside the panel's lazily built content, null until it first opens.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item panelColumn: panel.loadedContent ? panel.loadedContent.panelColumn : null

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color background: bar ? bar.background : Commons.Color.background
  readonly property color accent: Commons.Color.accent
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // React to USB connect/disconnect through PipeWire's live node graph without
  // background polling timers or startup subprocesses when disconnected.
  readonly property var pwNodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property bool pipewireHasMv7: {
    for (var i = 0; i < pwNodes.length; i++) {
      var n = pwNodes[i]
      if (!n || !n.name) continue
      var lower = String(n.name).toLowerCase()
      if (lower.indexOf("shure_mv7") >= 0 || lower.indexOf("mv7+") >= 0) return true
    }
    return false
  }

  property bool deviceConnected: false
  property string deviceError: ""
  property bool permissionRetried: false
  property bool busy: false
  // Writes that arrive while the helper is running. One entry per feature, so
  // a held key coalesces to its latest value without dropping other features.
  property var pendingCmds: []

  property bool autoLevel: true
  property real gainDb: 28.0
  property bool micMuted: false
  property int hpfMode: 0
  property bool limiterOn: false
  property int compressorMode: 0
  property bool denoiserOn: false
  property bool popperStopperOn: false
  property int tonePct: 0
  property bool reverbOutputOn: false
  property int reverbType: 0
  property int reverbIntensity: 0
  property bool reverbMonitorOn: false
  property int micLevel: 100
  property int playbackLevel: 100

  // Gate visibility strictly on confirmed MV7+ (14ed:1019) HID presence so
  // original MV7/MV7X microphones do not show a broken button.
  visible: deviceConnected
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

  function toneLabel(pct) {
    var rounded = Math.round(pct)
    if (rounded === 0) return Commons.I18n.t("mv7plus.toneNatural")
    if (rounded < 0) return Commons.I18n.t("mv7plus.toneDark").arg(Commons.I18n.formatNumber(rounded))
    return Commons.I18n.t("mv7plus.toneBright").arg(Commons.I18n.formatNumber(rounded))
  }

  function applySnapshot(raw) {
    var trimmed = String(raw || "").trim()
    if (!trimmed) return
    var data
    try {
      data = JSON.parse(trimmed)
    } catch (e) {
      return
    }
    root.deviceConnected = Boolean(data.connected)
    root.deviceError = data.error ? String(data.error) : ""
    if (!root.deviceConnected) {
      if (root.opened) root.close()
      return
    }
    if (root.deviceError === "permission" && !root.permissionRetried) {
      root.permissionRetried = true
      permissionRetry.restart()
      return
    }
    if (root.deviceError === "") root.permissionRetried = false
    // More writes are queued: this snapshot predates them, and applying it
    // would bounce the controls back for a moment.
    if (root.pendingCmds.length > 0) return
    var st = data.state
    if (!st || typeof st !== "object") return
    if (st.auto_level !== null && st.auto_level !== undefined) root.autoLevel = Number(st.auto_level) !== 0
    if (st.gain_db !== null && st.gain_db !== undefined) root.gainDb = Number(st.gain_db)
    if (st.mute !== null && st.mute !== undefined) root.micMuted = Number(st.mute) !== 0
    if (st.hpf !== null && st.hpf !== undefined) root.hpfMode = Number(st.hpf)
    if (st.limiter !== null && st.limiter !== undefined) root.limiterOn = Number(st.limiter) !== 0
    if (st.compressor !== null && st.compressor !== undefined) root.compressorMode = Number(st.compressor)
    if (st.denoiser !== null && st.denoiser !== undefined) root.denoiserOn = Number(st.denoiser) !== 0
    if (st.popper_stopper !== null && st.popper_stopper !== undefined) root.popperStopperOn = Number(st.popper_stopper) !== 0
    if (st.tone_pct !== null && st.tone_pct !== undefined) root.tonePct = Number(st.tone_pct)
    if (st.reverb_output !== null && st.reverb_output !== undefined) root.reverbOutputOn = Number(st.reverb_output) !== 0
    if (st.reverb_type !== null && st.reverb_type !== undefined) root.reverbType = Number(st.reverb_type)
    if (st.reverb_intensity !== null && st.reverb_intensity !== undefined) root.reverbIntensity = Number(st.reverb_intensity)
    if (st.reverb_monitor !== null && st.reverb_monitor !== undefined) root.reverbMonitorOn = Number(st.reverb_monitor) !== 0
    if (st.mic_level !== null && st.mic_level !== undefined) root.micLevel = Number(st.mic_level)
    if (st.playback_level !== null && st.playback_level !== undefined) root.playbackLevel = Number(st.playback_level)
  }

  function runCtl(args) {
    if (ctlProc.running) {
      var slot = args.slice(0, 2).join(" ")
      var queue = pendingCmds.filter(function(c) { return c.slice(0, 2).join(" ") !== slot })
      queue.push(args)
      pendingCmds = queue
      return
    }
    busy = true
    ctlProc.outputBuffer = ""
    ctlProc.command = ["python3", root.helperPath].concat(args)
    ctlProc.running = true
  }

  function refresh() {
    runCtl(["read"])
  }

  function setFeature(key, value) {
    runCtl(["set", String(key), String(value)])
  }

  function applyPreset(name) {
    runCtl(["preset", String(name)])
  }

  function toggleMute() {
    var next = !micMuted
    micMuted = next
    setFeature("mute", next ? 1 : 0)
  }

  // Optimistic setters shared by the mouse and the keyboard cursor: the control
  // moves at once and the helper's snapshot confirms it.
  function setBool(prop, key, on) {
    if (root[prop] === on) return
    root[prop] = on
    setFeature(key, on ? 1 : 0)
  }

  function setNumber(prop, key, value) {
    if (root[prop] === value) return
    root[prop] = value
    setFeature(key, value)
  }

  function stepNumber(prop, key, delta, min, max) {
    setNumber(prop, key, Math.max(min, Math.min(max, root[prop] + delta)))
  }

  // ---- Keyboard cursor -------------------------------------------------------
  // j/k walk the rows, h/l adjust the row under the cursor, Enter/Space
  // toggles or cycles it. Mouse hover moves the same cursor, so there is only
  // ever one highlight.
  property bool cursorActive: false
  property string cursorRow: "mode"
  property int presetIndex: 0
  readonly property var presetNames: ["neutral", "factory"]

  readonly property var cursorRows: {
    var rows = ["mute", "mode"]
    if (!autoLevel) rows.push("gain")
    rows.push("tone", "hpf", "denoiser", "popper")
    if (!autoLevel) rows.push("limiter", "compressor")
    rows.push("reverb")
    if (reverbOutputOn) rows.push("reverbType", "reverbIntensity", "reverbMonitor")
    rows.push("micLevel", "playbackLevel", "presets")
    return rows
  }
  onCursorRowsChanged: if (cursorRows.indexOf(cursorRow) < 0) cursorRow = "mode"

  function setCursor(key) {
    cursorActive = true
    cursorRow = key
  }

  function moveCursor(dy) {
    var i = cursorRows.indexOf(cursorRow)
    if (i < 0) i = 1
    cursorRow = cursorRows[Math.max(0, Math.min(cursorRows.length - 1, i + dy))]
    if (cursorRow === "mute" && panelFlick) panelFlick.contentY = 0
  }

  function adjustCursor(dx) {
    var on = dx > 0
    switch (cursorRow) {
    case "mute": if (micMuted === on) toggleMute(); break
    case "mode": setBool("autoLevel", "auto_level", !on); break
    case "gain": stepNumber("gainDb", "gain_db", dx * 0.5, 0, 36); break
    case "tone": stepNumber("tonePct", "tone_pct", dx * 10, -100, 100); break
    case "hpf": stepNumber("hpfMode", "hpf", dx, 0, 2); break
    case "denoiser": setBool("denoiserOn", "denoiser", on); break
    case "popper": setBool("popperStopperOn", "popper_stopper", on); break
    case "limiter": setBool("limiterOn", "limiter", on); break
    case "compressor": stepNumber("compressorMode", "compressor", dx, 0, 3); break
    case "reverb": setBool("reverbOutputOn", "reverb_output", on); break
    case "reverbType": stepNumber("reverbType", "reverb_type", dx, 0, 2); break
    case "reverbIntensity": stepNumber("reverbIntensity", "reverb_intensity", dx * 5, 0, 100); break
    case "reverbMonitor": setBool("reverbMonitorOn", "reverb_monitor", on); break
    case "micLevel": stepNumber("micLevel", "mic_level", dx * 5, 0, 100); break
    case "playbackLevel": stepNumber("playbackLevel", "playback_level", dx * 5, 0, 100); break
    case "presets": presetIndex = Math.max(0, Math.min(presetNames.length - 1, presetIndex + dx)); break
    }
  }

  function activateCursor() {
    switch (cursorRow) {
    case "mute": toggleMute(); break
    case "mode": setBool("autoLevel", "auto_level", !autoLevel); break
    case "hpf": setNumber("hpfMode", "hpf", (hpfMode + 1) % 3); break
    case "denoiser": setBool("denoiserOn", "denoiser", !denoiserOn); break
    case "popper": setBool("popperStopperOn", "popper_stopper", !popperStopperOn); break
    case "limiter": setBool("limiterOn", "limiter", !limiterOn); break
    case "compressor": setNumber("compressorMode", "compressor", (compressorMode + 1) % 4); break
    case "reverb": setBool("reverbOutputOn", "reverb_output", !reverbOutputOn); break
    case "reverbType": setNumber("reverbType", "reverb_type", (reverbType + 1) % 3); break
    case "reverbMonitor": setBool("reverbMonitorOn", "reverb_monitor", !reverbMonitorOn); break
    case "presets": applyPreset(presetNames[presetIndex]); break
    }
  }

  function ensureCursorVisible(item) {
    if (!item || !panelFlick || !panelColumn) return
    var maxY = Math.max(0, panelFlick.contentHeight - panelFlick.height)
    if (maxY <= 0) return
    var margin = Style.space(6)
    var top = item.mapToItem(panelColumn, 0, 0).y
    var bottom = top + item.height
    if (top < panelFlick.contentY + margin) panelFlick.contentY = Math.max(0, Math.min(maxY, top - margin))
    else if (bottom > panelFlick.contentY + panelFlick.height - margin)
      panelFlick.contentY = Math.max(0, Math.min(maxY, bottom + margin - panelFlick.height))
  }

  Process {
    id: ctlProc
    property string outputBuffer: ""
    stdout: SplitParser {
      onRead: function(line) {
        ctlProc.outputBuffer += line
      }
    }
    onExited: {
      root.busy = false
      root.applySnapshot(ctlProc.outputBuffer)
      if (root.pendingCmds.length > 0) {
        var queue = root.pendingCmds.slice()
        var next = queue.shift()
        root.pendingCmds = queue
        root.runCtl(next)
      }
    }
  }

  // Wait briefly after USB hotplug so udev finishes granting hidraw uaccess.
  Timer {
    id: hotplugDebounce
    interval: 300
    repeat: false
    onTriggered: root.refresh()
  }

  // One-shot retry if udev uaccess finishes slightly after the initial probe.
  Timer {
    id: permissionRetry
    interval: 600
    repeat: false
    onTriggered: root.refresh()
  }

  onPipewireHasMv7Changed: {
    if (pipewireHasMv7) {
      permissionRetried = false
      hotplugDebounce.restart()
    } else {
      permissionRetry.stop()
      deviceConnected = false
      deviceError = ""
      if (opened) close()
    }
  }

  onOpenedChanged: {
    if (opened) {
      cursorActive = false
      cursorRow = "mode"
      if (panelFlick) panelFlick.contentY = 0
      refresh()
    }
  }

  // Avoid spawning a helper at startup when no MV7+ is connected.
  Component.onCompleted: if (pipewireHasMv7) refresh()

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.micMuted ? "" : ""
    active: root.micMuted
    tooltipText: root.micMuted
      ? Commons.I18n.t("mv7plus.tooltipMuted")
      : Commons.I18n.t("mv7plus.tooltipLive").arg(
          root.autoLevel
            ? Commons.I18n.t("mv7plus.metaAuto")
            : Commons.I18n.t("mv7plus.metaManual").arg(Commons.I18n.formatNumber(root.gainDb, 1))
        )
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton || mouseButton === Qt.MiddleButton) {
        root.toggleMute()
      } else {
        root.toggle()
      }
    }
  }

  // ---- Layout metrics ---------------------------------------------------------
  // Every secondary control is one row: label on the leading edge, control in
  // a shared trailing column, so switches, segments and sliders line up.
  readonly property int rowInset: Style.space(6)
  readonly property int rowHeight: Style.space(30)
  readonly property int panelWidth: panel.fittedContentWidth(Style.space(380))
  readonly property int controlColumn: Math.round((panelWidth - rowInset * 2) * 0.6)

  // ---- Inline components -----------------------------------------------------

  component Txt: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
    elide: Text.ElideRight
  }

  // Equal-width segmented control built from the kit's Button, so selected,
  // hover and press states all come from the theme's shared tokens.
  component Segmented: Row {
    id: seg

    property var options: []
    property string value: ""
    property bool hasCursor: false
    property real fontSize: Style.font.body
    property real padY: Style.space(4)
    readonly property int chipWidth: options.length > 0
      ? Math.floor((width - spacing * (options.length - 1)) / options.length)
      : 0

    signal picked(string value)
    signal chipHovered(int index)

    spacing: Style.spacing.sm

    Repeater {
      model: seg.options

      delegate: Button {
        required property var modelData
        required property int index
        // The last chip absorbs the rounding remainder so the group ends flush.
        width: index === seg.options.length - 1
          ? seg.width - (seg.chipWidth + seg.spacing) * index
          : seg.chipWidth
        text: modelData.label
        selected: modelData.value === seg.value
        hasCursor: seg.hasCursor && selected
        bordered: true
        horizontalPadding: Style.spacing.sm
        verticalPadding: seg.padY
        foreground: root.foreground
        background: root.background
        accent: root.accent
        fontFamily: root.fontFamily
        fontSize: seg.fontSize
        onClicked: seg.picked(modelData.value)
        onHovered: function(isHovered) { if (isHovered) seg.chipHovered(index) }
      }
    }
  }

  // One compact setting: label left, control right. The row is the cursor
  // target; whatever is declared inside lands in the trailing control column.
  component SettingRow: CursorSurface {
    id: row

    property string rowKey: ""
    property string label: ""
    property string hint: ""
    property bool clickable: false
    default property alias control: slot.data

    signal activated()

    width: parent ? parent.width : 0
    implicitHeight: root.rowHeight
    foreground: root.foreground
    accent: root.accent
    hasCursor: root.cursorActive && root.cursorRow === rowKey
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(row)

    MouseArea {
      anchors.fill: parent
      enabled: row.clickable
      cursorShape: row.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: row.activated()
    }

    Txt {
      anchors.left: parent.left
      anchors.leftMargin: root.rowInset
      anchors.right: slot.left
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      text: row.label
    }

    Item {
      id: slot
      anchors.right: parent.right
      anchors.rightMargin: root.rowInset
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: root.controlColumn
    }

    HoverHandler {
      id: rowHover
      onHoveredChanged: if (hovered) root.setCursor(row.rowKey)
    }

    PanelToolTip {
      visible: row.hint !== "" && rowHover.hovered
      text: row.hint
      fontFamily: root.fontFamily
    }
  }

  component SwitchRow: SettingRow {
    id: switchRow

    property bool checked: false

    clickable: true

    // The row owns the click and the cursor, so the switch is presentation only.
    ToggleSwitch {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      checked: switchRow.checked
      interactive: false
      trackHeight: Style.space(20)
      foreground: root.foreground
      accent: root.accent
    }
  }

  component SegmentedRow: SettingRow {
    id: segRow

    property alias options: rowSeg.options
    property alias value: rowSeg.value

    signal picked(string value)

    Segmented {
      id: rowSeg
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      fontSize: Style.font.bodySmall
      onPicked: function(v) { segRow.picked(v) }
    }
  }

  // Secondary level: label · slider · value on a single line.
  component SliderRow: SettingRow {
    id: sliderRow

    property alias value: rowSlider.value
    property alias step: rowSlider.step
    readonly property alias liveValue: rowSlider.liveValue

    signal committed(real value)

    PanelSlider {
      id: rowSlider
      bar: root.bar
      anchors.left: parent.left
      anchors.right: rowValue.left
      anchors.rightMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      minimum: 0
      maximum: 100
      step: 5
      integer: true
      onReleased: function(v) { sliderRow.committed(Math.round(v)) }
    }

    Txt {
      id: rowValue
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(36)
      horizontalAlignment: Text.AlignRight
      text: Commons.I18n.t("mv7plus.percentValue").arg(Commons.I18n.formatNumber(Math.round(rowSlider.liveValue)))
      color: root.dim
      font.pixelSize: Style.font.caption
      font.bold: true
    }
  }

  // Primary level: bold label and live value over a full-width slider.
  component SliderBlock: CursorSurface {
    id: block

    property string rowKey: ""
    property string label: ""
    property string valueText: ""
    property alias value: blockSlider.value
    property alias minimum: blockSlider.minimum
    property alias maximum: blockSlider.maximum
    property alias step: blockSlider.step
    property alias integer: blockSlider.integer
    property alias tickCount: blockSlider.tickCount
    readonly property alias liveValue: blockSlider.liveValue

    signal committed(real value)

    width: parent ? parent.width : 0
    implicitHeight: blockColumn.implicitHeight + Style.space(8)
    foreground: root.foreground
    accent: root.accent
    hasCursor: root.cursorActive && root.cursorRow === rowKey
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(block)

    Column {
      id: blockColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: root.rowInset
      anchors.rightMargin: root.rowInset
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(1)

      Item {
        width: parent.width
        implicitHeight: Math.max(blockLabel.implicitHeight, blockValue.implicitHeight)

        Txt {
          id: blockLabel
          anchors.left: parent.left
          anchors.right: blockValue.left
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
          text: block.label
          font.bold: true
        }

        Txt {
          id: blockValue
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: block.valueText
          color: root.dim
          font.pixelSize: Style.font.bodySmall
          font.bold: true
        }
      }

      PanelSlider {
        id: blockSlider
        width: parent.width
        bar: root.bar
        onReleased: function(v) { block.committed(v) }
      }
    }

    HoverHandler {
      onHoveredChanged: if (hovered) root.setCursor(block.rowKey)
    }
  }

  component SectionTitle: PanelSectionHeader {
    foreground: root.foreground
    fontFamily: root.fontFamily
    bottomPadding: Style.space(4)
  }

  // ---- Panel -------------------------------------------------------------------

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: root.panelWidth
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(840))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias panelFlick: panelFlick
      property alias panelColumn: column
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.adjustCursor(dx)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "m" || t === "M") root.toggleMute()
        else if (t === "r" || t === "R") root.refresh()
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: panelFlick.interactive ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(12)

          // ---- Hero: mic status, with the live/mute switch on the trailing edge
          PanelHero {
            width: parent.width
            title: Commons.I18n.t("mv7plus.heroTitle")
            meta: root.micMuted
              ? Commons.I18n.t("mv7plus.metaMuted")
              : (root.autoLevel
                ? Commons.I18n.t("mv7plus.metaAuto")
                : Commons.I18n.t("mv7plus.metaManual").arg(Commons.I18n.formatNumber(root.gainDb, 1)))
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              Text {
                textFormat: Text.PlainText
                text: root.micMuted ? "" : ""
                color: root.micMuted ? root.urgent : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }
            // Checked means the mic is live, so muting reads as switching it off.
            trailingControl: Component {
              ToggleSwitch {
                id: liveSwitch
                checked: !root.micMuted
                hasCursor: root.cursorActive && root.cursorRow === "mute"
                foreground: root.foreground
                accent: root.accent
                onHovered: function(isHovered) { if (isHovered) root.setCursor("mute") }
                onToggled: root.toggleMute()

                PanelToolTip {
                  visible: liveSwitch.containsMouse
                  text: root.micMuted ? Commons.I18n.t("mv7plus.unmute") : Commons.I18n.t("mv7plus.mute")
                  fontFamily: root.fontFamily
                }
              }
            }
          }

          Txt {
            visible: root.deviceError !== ""
            width: parent.width
            wrapMode: Text.WordWrap
            elide: Text.ElideNone
            text: root.deviceError === "permission"
              ? Commons.I18n.t("mv7plus.errorPermission").arg("/etc/udev/rules.d/62-shure-mv7plus.rules")
              : root.deviceError
            color: root.urgent
            font.pixelSize: Style.font.caption
          }

          PanelSeparator { foreground: root.foreground }

          // ---- Level: the primary controls, full width --------------------------
          Column {
            width: parent.width
            spacing: Style.space(4)

            SectionTitle { text: Commons.I18n.t("mv7plus.sectionLevel") }

            // Symmetric inset, so the chips share the rows' edges in either reading direction.
            Segmented {
              x: root.rowInset
              width: parent.width - root.rowInset * 2
              padY: Style.spacing.controlPaddingY
              hasCursor: root.cursorActive && root.cursorRow === "mode"
              value: root.autoLevel ? "auto" : "manual"
              options: [
                { value: "auto", label: Commons.I18n.t("mv7plus.modeAuto") },
                { value: "manual", label: Commons.I18n.t("mv7plus.modeManual") }
              ]
              onPicked: function(v) { root.setBool("autoLevel", "auto_level", v === "auto") }
              onChipHovered: root.setCursor("mode")
            }

            SliderBlock {
              id: gainBlock
              visible: !root.autoLevel
              rowKey: "gain"
              label: Commons.I18n.t("mv7plus.gainLabel")
              valueText: Commons.I18n.t("mv7plus.gainValue").arg(Commons.I18n.formatNumber(Math.round(gainBlock.liveValue * 2) / 2, 1))
              minimum: 0
              maximum: 36
              step: 0.5
              value: root.gainDb
              onCommitted: function(v) { root.setNumber("gainDb", "gain_db", Math.round(v * 2) / 2) }
            }

            SliderBlock {
              id: toneBlock
              rowKey: "tone"
              label: Commons.I18n.t("mv7plus.toneLabel")
              valueText: root.toneLabel(Math.round(toneBlock.liveValue / 10) * 10)
              minimum: -100
              maximum: 100
              step: 10
              integer: true
              tickCount: 3
              value: root.tonePct
              onCommitted: function(v) { root.setNumber("tonePct", "tone_pct", Math.round(v / 10) * 10) }
            }
          }

          PanelSeparator { foreground: root.foreground }

          // ---- Voice processing ------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(2)

            SectionTitle { text: Commons.I18n.t("mv7plus.sectionDsp") }

            SegmentedRow {
              rowKey: "hpf"
              label: Commons.I18n.t("mv7plus.hpfLabel")
              hint: Commons.I18n.t("mv7plus.hpfDesc")
              value: String(root.hpfMode)
              options: [
                { value: "0", label: Commons.I18n.t("mv7plus.hpfOff") },
                { value: "1", label: Commons.I18n.t("mv7plus.hpf75") },
                { value: "2", label: Commons.I18n.t("mv7plus.hpf150") }
              ]
              onPicked: function(v) { root.setNumber("hpfMode", "hpf", Number(v)) }
            }

            SwitchRow {
              rowKey: "denoiser"
              label: Commons.I18n.t("mv7plus.denoiserLabel")
              hint: Commons.I18n.t("mv7plus.denoiserDesc")
              checked: root.denoiserOn
              onActivated: root.setBool("denoiserOn", "denoiser", !root.denoiserOn)
            }

            SwitchRow {
              rowKey: "popper"
              label: Commons.I18n.t("mv7plus.popperLabel")
              hint: Commons.I18n.t("mv7plus.popperDesc")
              checked: root.popperStopperOn
              onActivated: root.setBool("popperStopperOn", "popper_stopper", !root.popperStopperOn)
            }

            SwitchRow {
              visible: !root.autoLevel
              rowKey: "limiter"
              label: Commons.I18n.t("mv7plus.limiterLabel")
              hint: Commons.I18n.t("mv7plus.limiterDesc")
              checked: root.limiterOn
              onActivated: root.setBool("limiterOn", "limiter", !root.limiterOn)
            }

            SegmentedRow {
              visible: !root.autoLevel
              rowKey: "compressor"
              label: Commons.I18n.t("mv7plus.compressorLabel")
              hint: Commons.I18n.t("mv7plus.compressorDesc")
              value: String(root.compressorMode)
              options: [
                { value: "0", label: Commons.I18n.t("mv7plus.compressorOff") },
                { value: "1", label: Commons.I18n.t("mv7plus.compressorLight") },
                { value: "2", label: Commons.I18n.t("mv7plus.compressorMedium") },
                { value: "3", label: Commons.I18n.t("mv7plus.compressorHeavy") }
              ]
              onPicked: function(v) { root.setNumber("compressorMode", "compressor", Number(v)) }
            }
          }

          PanelSeparator { foreground: root.foreground }

          // ---- Reverb ----------------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(2)

            SectionTitle { text: Commons.I18n.t("mv7plus.sectionReverb") }

            SwitchRow {
              rowKey: "reverb"
              label: Commons.I18n.t("mv7plus.reverbOutput")
              hint: Commons.I18n.t("mv7plus.reverbOutputDesc")
              checked: root.reverbOutputOn
              onActivated: root.setBool("reverbOutputOn", "reverb_output", !root.reverbOutputOn)
            }

            SegmentedRow {
              visible: root.reverbOutputOn
              rowKey: "reverbType"
              label: Commons.I18n.t("mv7plus.reverbType")
              value: String(root.reverbType)
              options: [
                { value: "0", label: Commons.I18n.t("mv7plus.reverbPlate") },
                { value: "1", label: Commons.I18n.t("mv7plus.reverbHall") },
                { value: "2", label: Commons.I18n.t("mv7plus.reverbStudio") }
              ]
              onPicked: function(v) { root.setNumber("reverbType", "reverb_type", Number(v)) }
            }

            SliderRow {
              visible: root.reverbOutputOn
              rowKey: "reverbIntensity"
              label: Commons.I18n.t("mv7plus.reverbIntensity")
              value: root.reverbIntensity
              onCommitted: function(v) { root.setNumber("reverbIntensity", "reverb_intensity", v) }
            }

            SwitchRow {
              visible: root.reverbOutputOn
              rowKey: "reverbMonitor"
              label: Commons.I18n.t("mv7plus.reverbMonitor")
              hint: Commons.I18n.t("mv7plus.reverbMonitorDesc")
              checked: root.reverbMonitorOn
              onActivated: root.setBool("reverbMonitorOn", "reverb_monitor", !root.reverbMonitorOn)
            }
          }

          PanelSeparator { foreground: root.foreground }

          // ---- Headphone monitor mix ---------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(2)

            SectionTitle { text: Commons.I18n.t("mv7plus.sectionMonitor") }

            SliderRow {
              rowKey: "micLevel"
              label: Commons.I18n.t("mv7plus.monitorMic")
              hint: Commons.I18n.t("mv7plus.monitorMicDesc")
              value: root.micLevel
              onCommitted: function(v) { root.setNumber("micLevel", "mic_level", v) }
            }

            SliderRow {
              rowKey: "playbackLevel"
              label: Commons.I18n.t("mv7plus.monitorPlayback")
              hint: Commons.I18n.t("mv7plus.monitorPlaybackDesc")
              value: root.playbackLevel
              onCommitted: function(v) { root.setNumber("playbackLevel", "playback_level", v) }
            }
          }

          PanelSeparator { foreground: root.foreground }

          // ---- Presets -----------------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(4)

            SectionTitle { text: Commons.I18n.t("mv7plus.sectionPresets") }

            Row {
              id: presetRow
              x: root.rowInset
              width: parent.width - root.rowInset * 2
              spacing: Style.spacing.sm

              Repeater {
                model: [
                  { name: "neutral", label: Commons.I18n.t("mv7plus.presetNeutral"), hint: Commons.I18n.t("mv7plus.presetNeutralDesc") },
                  { name: "factory", label: Commons.I18n.t("mv7plus.presetFactory"), hint: Commons.I18n.t("mv7plus.presetFactoryDesc") }
                ]

                delegate: Button {
                  required property var modelData
                  required property int index
                  width: Math.floor((presetRow.width - presetRow.spacing) / 2)
                  text: modelData.label
                  tooltipText: modelData.hint
                  bordered: true
                  hasCursor: root.cursorActive && root.cursorRow === "presets" && root.presetIndex === index
                  foreground: root.foreground
                  background: root.background
                  accent: root.accent
                  fontFamily: root.fontFamily
                  onClicked: root.applyPreset(modelData.name)
                  onHovered: function(isHovered) {
                    if (!isHovered) return
                    root.presetIndex = index
                    root.setCursor("presets")
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
