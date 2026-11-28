import QtQuick
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Store.js" as Store

Panel {
  id: root
  moduleName: "omarchy.mv7plus"
  ipcTarget: "omarchy.mv7plus"

  // Items inside the panel's lazily built content, null until it first opens.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item panelColumn: panel.loadedContent ? panel.loadedContent.panelColumn : null
  readonly property Item hpfDropdown: panel.loadedContent ? panel.loadedContent.hpfDropdown : null

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

  function syncFromStore(st) {
    root.deviceConnected = st.deviceConnected
    root.deviceError = st.deviceError
    if (!root.deviceConnected) {
      if (root.opened) root.close()
      return
    }
    if (Store.isLeader(root)) {
      if (root.deviceError === "permission" && !root.permissionRetried) {
        root.permissionRetried = true
        permissionRetry.restart()
      } else if (root.deviceError === "") {
        root.permissionRetried = false
      }
    }
    root.autoLevel = st.autoLevel
    root.gainDb = st.gainDb
    root.micMuted = st.micMuted
    root.hpfMode = st.hpfMode
    root.limiterOn = st.limiterOn
    root.compressorMode = st.compressorMode
    root.denoiserOn = st.denoiserOn
    root.popperStopperOn = st.popperStopperOn
    root.tonePct = st.tonePct
    root.reverbOutputOn = st.reverbOutputOn
    root.reverbType = st.reverbType
    root.reverbIntensity = st.reverbIntensity
    root.reverbMonitorOn = st.reverbMonitorOn
    root.micLevel = st.micLevel
    root.playbackLevel = st.playbackLevel
  }

  function execCli(args) {
    ctlProc.outputBuffer = ""
    ctlProc.command = ["omarchy-audio-mv7plus", "--json"].concat(args)
    ctlProc.running = true
  }

  function runCtl(args) {
    Store.enqueue(args, root)
  }

  function refresh() {
    runCtl(["status"])
  }

  function setFeature(key, value) {
    var num = Number(value)
    var rounded = Math.round(num)
    switch (key) {
    case "auto_level": runCtl(["mode", num !== 0 ? "auto" : "manual"]); break
    case "gain_db": runCtl(["gain", Math.max(0, Math.min(36, num)).toFixed(1)]); break
    case "mute": runCtl(["mute", num !== 0 ? "on" : "off"]); break
    case "hpf": runCtl(["hpf", rounded === 1 ? "75" : rounded === 2 ? "150" : "off"]); break
    case "limiter": runCtl(["limiter", num !== 0 ? "on" : "off"]); break
    case "compressor": runCtl(["compressor", ["off", "light", "medium", "heavy"][rounded] || "off"]); break
    case "denoiser": runCtl(["denoiser", num !== 0 ? "on" : "off"]); break
    case "popper_stopper": runCtl(["popper", num !== 0 ? "on" : "off"]); break
    case "tone_pct": runCtl(["tone", "--", String(Math.max(-100, Math.min(100, rounded)))]); break
    case "reverb_output": runCtl(["reverb", num !== 0 ? "on" : "off"]); break
    case "reverb_type": runCtl(["reverb", "type", ["plate", "hall", "studio"][rounded] || "plate"]); break
    case "reverb_intensity": runCtl(["reverb", "intensity", String(Math.max(0, Math.min(100, rounded)))]); break
    case "reverb_monitor": runCtl(["reverb", "monitor", num !== 0 ? "on" : "off"]); break
    case "mic_level": runCtl(["monitor", "mic", String(Math.max(0, Math.min(100, rounded)))]); break
    case "playback_level": runCtl(["monitor", "playback", String(Math.max(0, Math.min(100, rounded)))]); break
    }
  }

  function applyPreset(name) {
    runCtl(["preset", String(name)])
  }

  function toggleMute() {
    var next = !micMuted
    Store.setOptimistic("micMuted", next)
    setFeature("mute", next ? 1 : 0)
  }

  // Optimistic setters shared by the mouse and the keyboard cursor: the control
  // moves at once across all monitors and the helper's readback confirms it.
  function setBool(prop, key, on) {
    if (root[prop] === on) return
    Store.setOptimistic(prop, on)
    setFeature(key, on ? 1 : 0)
  }

  function setNumber(prop, key, value) {
    if (root[prop] === value) return
    Store.setOptimistic(prop, value)
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
    if (hpfDropdown && hpfDropdown.popupOpen) return
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
    case "hpf": if (hpfDropdown) hpfDropdown.toggle(); break
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
      Store.finishExec(ctlProc.outputBuffer)
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
    if (!Store.isLeader(root)) return
    if (pipewireHasMv7) {
      permissionRetried = false
      hotplugDebounce.restart()
    } else {
      permissionRetry.stop()
      Store.markDisconnected()
    }
  }

  onOpenedChanged: {
    if (opened) {
      cursorActive = false
      cursorRow = "mode"
      if (panelFlick) panelFlick.contentY = 0
      refresh()
    } else if (hpfDropdown) {
      hpfDropdown.close()
    }
  }

  // Avoid spawning a helper at startup when no MV7+ is connected.
  Component.onCompleted: {
    Store.register(root)
    if (Store.isLeader(root) && pipewireHasMv7) refresh()
  }
  Component.onDestruction: Store.unregister(root)

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
    property int controlWidth: root.controlColumn
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
      width: row.controlWidth
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

  component DropdownRow: SettingRow {
    id: dropRow

    property alias options: rowDropdown.options
    property string value: ""
    readonly property alias popupOpen: rowDropdown.popupOpen
    function open() { rowDropdown.open() }
    function close() { rowDropdown.close() }
    function toggle() { rowDropdown.toggle() }

    signal picked(string value)

    FontMetrics {
      id: dropMetrics
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }

    readonly property int widestOptionWidth: {
      var widest = 0
      for (var i = 0; i < options.length; i++) {
        var o = options[i]
        var lbl = (o && typeof o === "object") ? String(o.label) : String(o)
        widest = Math.max(widest, Math.ceil(dropMetrics.advanceWidth(lbl)))
      }
      return widest
    }

    controlWidth: Math.min(
      root.controlColumn,
      widestOptionWidth
        + Math.ceil(dropMetrics.advanceWidth("󰅀"))
        + Style.spacing.controlPaddingX * 2
        + Style.spacing.md
        + Style.space(4)
    )

    Dropdown {
      id: rowDropdown
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      showLabel: false
      rowHeight: Style.space(26)
      popupRowHeight: Style.space(26)
      foreground: root.foreground
      background: root.background
      accent: root.accent
      fontFamily: root.fontFamily
      hasCursor: dropRow.hasCursor
      onHovered: function(h) { if (h) root.setCursor(dropRow.rowKey) }
      onChanged: function(v) { dropRow.picked(v) }
      onPopupOpenChanged: {
        if (!popupOpen && root.opened && panel.loadedContent) panel.loadedContent.forceActiveFocus()
      }

      // Dropdown.selectCurrent() assigns `value = v` directly, which would
      // break a plain binding when a preset later resets the setting.
      Binding {
        target: rowDropdown
        property: "value"
        value: dropRow.value
      }
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
      property alias hpfDropdown: hpfRow
      blocked: hpfRow.popupOpen
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
        interactive: contentHeight > height && !hpfRow.popupOpen
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

            DropdownRow {
              id: hpfRow
              rowKey: "hpf"
              label: Commons.I18n.t("mv7plus.hpfLabel")
              hint: hpfRow.popupOpen ? "" : Commons.I18n.t("mv7plus.hpfDesc")
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

            SwitchRow {
              rowKey: "reverb"
              label: Commons.I18n.t("mv7plus.reverbLabel")
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
              readonly property bool hasCursor: root.cursorActive && root.cursorRow === "presets"
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(presetRow)
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
