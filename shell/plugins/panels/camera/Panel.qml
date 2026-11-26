import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.camera"

  readonly property bool previewMode: moduleName === "preview"
  readonly property string homeDir: Quickshell.env("HOME") || ""
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (homeDir + "/.config")
  readonly property string tuningsRoot: Quickshell.env("OMARCHY_PATH") + "/default/camera/tunings"
  readonly property string envFilePath: configHome + "/omarchy/camera-relay.env"
  readonly property string watcherPath: Qt.resolvedUrl("camera-watch.py").toString().replace(/^file:\/\//, "")

  readonly property color foreground: bar ? bar.foreground : Commons.Color.popups.text
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property bool tuningInstalled: false
  property bool cameraActive: false
  property bool opened: false
  property bool saving: false
  property bool pendingSave: false
  property bool pendingReset: false

  property string tuningName: ""
  property string cameraLabel: Commons.I18n.t("camera.title")
  property string resolutionBadge: ""

  property real brightnessValue: 0.00
  property real gammaValue: 1.50
  property real contrastValue: 1.05
  property real saturationValue: 1.40
  property real warmthValue: 0.00
  property real tintValue: 0.00

  // Raw values as saved in camera-relay.env (unclamped), so CLI overrides
  // outside the slider bounds stay visible to isModified and are never
  // clobbered when the user adjusts a different slider.
  property real savedBrightness: 0.00
  property real savedGamma: 1.50
  property real savedContrast: 1.05
  property real savedSaturation: 1.40
  property real savedWarmth: 0.00
  property real savedTint: 0.00

  property real defaultBrightness: 0.00
  property real defaultGamma: 1.50
  property real defaultContrast: 1.05
  property real defaultSaturation: 1.40
  property real defaultWarmth: 0.00
  property real defaultTint: 0.00

  property var dirtyKeys: ({})
  property double lastLiveSentMs: 0

  readonly property bool anyDragging:
    brightnessRow.dragging
    || gammaRow.dragging
    || contrastRow.dragging
    || saturationRow.dragging
    || warmthRow.dragging
    || tintRow.dragging

  readonly property bool isModified:
    Math.abs(savedBrightness - defaultBrightness) > 0.005
    || Math.abs(savedGamma - defaultGamma) > 0.005
    || Math.abs(savedContrast - defaultContrast) > 0.005
    || Math.abs(savedSaturation - defaultSaturation) > 0.005
    || Math.abs(savedWarmth - defaultWarmth) > 0.005
    || Math.abs(savedTint - defaultTint) > 0.005

  // Visible only while the camera is actively streaming (or while the user
  // still has this popup open), plus in `omarchy agent look plugin` preview.
  visible: previewMode || (tuningInstalled && (cameraActive || opened))
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

  component SliderRow: Column {
    id: rowRoot

    property string label: ""
    property real minimum: 0.00
    property real maximum: 1.00
    property real step: 0.05
    property real value: 0.00
    property bool signed: false
    readonly property alias dragging: slider.dragging

    signal moved(real value)
    signal committed(real value)
    signal resetRequested()

    width: parent ? parent.width : Style.space(280)
    spacing: Style.space(4)

    Item {
      width: parent.width
      height: rowLabel.implicitHeight

      Text {
        id: rowLabel
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: rowRoot.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: true
      }

      Text {
        textFormat: Text.PlainText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.formatDisplay(slider.liveValue, rowRoot.signed)
        color: slider.dragging ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

    PanelSlider {
      id: slider
      width: parent.width
      bar: root.bar
      minimum: rowRoot.minimum
      maximum: rowRoot.maximum
      step: rowRoot.step
      value: rowRoot.value
      onMoved: function(v) { rowRoot.moved(v) }
      onReleased: function(v) { rowRoot.committed(root.snapStep(v, minimum, maximum, step)) }
      onRightClicked: rowRoot.resetRequested()
    }
  }

  function open() {
    if (root.tuningInstalled || root.previewMode) root.opened = true
  }

  function close() {
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function snapStep(value, minVal, maxVal, stepVal) {
    var clamped = Math.max(minVal, Math.min(maxVal, Number(value)))
    var snapped = Math.round(clamped / stepVal) * stepVal
    return Math.abs(snapped) < 0.0001 ? 0 : snapped
  }

  function formatArg(value) {
    var num = Math.abs(Number(value)) < 0.0001 ? 0 : Number(value)
    return num.toFixed(2)
  }

  function formatDisplay(value, isSigned) {
    var rounded = Math.round(Number(value) * 100) / 100
    if (Math.abs(rounded) < 0.005) rounded = 0
    var formatted = Commons.I18n.formatNumber(rounded, 2)
    return isSigned && rounded > 0 ? ("+" + formatted) : formatted
  }

  function unescapeShellValue(raw) {
    var s = String(raw || "").trim()
    if (s.length >= 2 && ((s[0] === "'" && s[s.length - 1] === "'") || (s[0] === "\"" && s[s.length - 1] === "\""))) {
      return s.slice(1, -1)
    }
    return s.replace(/\\(.)/g, "$1")
  }

  function parseEnvText(text) {
    var lines = String(text || "").split(/\r?\n/)
    var map = {}
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line || line.charAt(0) === "#") continue
      var eq = line.indexOf("=")
      if (eq <= 0) continue
      var key = line.slice(0, eq).trim()
      var val = unescapeShellValue(line.slice(eq + 1))
      map[key] = val
    }

    if (!map.CAMERA_NAME && !map.TUNING_NAME) {
      root.tuningInstalled = false
      return
    }

    root.tuningInstalled = true
    if (map.TUNING_NAME) root.tuningName = map.TUNING_NAME
    if (map.CARD_LABEL) root.cameraLabel = map.CARD_LABEL
    root.resolutionBadge = map.HEIGHT ? (map.HEIGHT + "p") : ""

    if (!root.saving && !root.pendingSave && !root.anyDragging) {
      var b = parseFloat(map.BRIGHTNESS)
      var g = parseFloat(map.GAMMA)
      var c = parseFloat(map.CONTRAST)
      var s = parseFloat(map.SATURATION)
      var w = parseFloat(map.WARMTH)
      var t = parseFloat(map.TINT)
      if (!isNaN(b)) {
        root.savedBrightness = b
        root.brightnessValue = snapStep(b, -0.50, 0.50, 0.05)
      }
      if (!isNaN(g)) {
        root.savedGamma = g
        root.gammaValue = snapStep(g, 1.00, 2.40, 0.05)
      }
      if (!isNaN(c)) {
        root.savedContrast = c
        root.contrastValue = snapStep(c, 0.50, 2.00, 0.05)
      }
      if (!isNaN(s)) {
        root.savedSaturation = s
        root.saturationValue = snapStep(s, 0.00, 2.00, 0.05)
      }
      if (!isNaN(w)) {
        root.savedWarmth = w
        root.warmthValue = snapStep(w, -1.00, 1.00, 0.05)
      }
      if (!isNaN(t)) {
        root.savedTint = t
        root.tintValue = snapStep(t, -1.00, 1.00, 0.05)
      }
    }
  }

  function parseDefaultsText(text) {
    var lines = String(text || "").split(/\r?\n/)
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line || line.charAt(0) === "#") continue
      var eq = line.indexOf("=")
      if (eq <= 0) continue
      var key = line.slice(0, eq).trim()
      var val = parseFloat(unescapeShellValue(line.slice(eq + 1)))
      if (isNaN(val)) continue
      if (key === "brightness") root.defaultBrightness = val
      else if (key === "gamma") root.defaultGamma = val
      else if (key === "contrast") root.defaultContrast = val
      else if (key === "saturation") root.defaultSaturation = val
      else if (key === "warmth") root.defaultWarmth = val
      else if (key === "tint") root.defaultTint = val
    }
  }

  // Send 0ms live property updates for only the changed control(s) through the
  // already-running watcher bridge to the relay's Unix datagram socket.
  function sendLiveKey(key, value, force) {
    if (root.previewMode || !watcherProc.running) return
    var now = Date.now()
    if (!force && (now - root.lastLiveSentMs) < 33) return
    root.lastLiveSentMs = now
    watcherProc.write(key + "=" + formatArg(value) + "\n")
  }

  function sendLiveAll() {
    if (root.previewMode || !watcherProc.running) return
    root.lastLiveSentMs = Date.now()
    watcherProc.write(
      "brightness=" + formatArg(root.savedBrightness)
      + " gamma=" + formatArg(root.savedGamma)
      + " contrast=" + formatArg(root.savedContrast)
      + " saturation=" + formatArg(root.savedSaturation)
      + " warmth=" + formatArg(root.savedWarmth)
      + " tint=" + formatArg(root.savedTint) + "\n"
    )
  }

  function markDirty(key) {
    var next = {}
    for (var k in root.dirtyKeys) next[k] = root.dirtyKeys[k]
    next[key] = true
    root.dirtyKeys = next
  }

  function hasDirtyKeys() {
    for (var k in root.dirtyKeys) {
      if (root.dirtyKeys[k]) return true
    }
    return false
  }

  function queuePersist(key) {
    if (root.previewMode) return
    root.markDirty(key)
    persistDebounceTimer.restart()
  }

  function flushPersist() {
    if (root.previewMode) return
    if (saveProc.running) {
      root.pendingSave = true
      return
    }
    persistDebounceTimer.stop()
    root.pendingSave = false
    if (root.pendingReset) {
      root.pendingReset = false
      root.saving = true
      saveProc.command = ["omarchy-camera-tuning", "reset"]
      saveProc.running = true
      return
    }

    var args = ["omarchy-camera-tuning", "set"]
    if (root.dirtyKeys.brightness) args.push("brightness=" + formatArg(root.savedBrightness))
    if (root.dirtyKeys.gamma) args.push("gamma=" + formatArg(root.savedGamma))
    if (root.dirtyKeys.contrast) args.push("contrast=" + formatArg(root.savedContrast))
    if (root.dirtyKeys.saturation) args.push("saturation=" + formatArg(root.savedSaturation))
    if (root.dirtyKeys.warmth) args.push("warmth=" + formatArg(root.savedWarmth))
    if (root.dirtyKeys.tint) args.push("tint=" + formatArg(root.savedTint))
    if (args.length <= 2) {
      root.saving = false
      envFile.reload()
      return
    }

    root.dirtyKeys = ({})
    root.saving = true
    saveProc.command = args
    saveProc.running = true
  }

  function resetAll() {
    if (root.previewMode) return
    persistDebounceTimer.stop()
    root.savedBrightness = root.defaultBrightness
    root.savedGamma = root.defaultGamma
    root.savedContrast = root.defaultContrast
    root.savedSaturation = root.defaultSaturation
    root.savedWarmth = root.defaultWarmth
    root.savedTint = root.defaultTint
    root.brightnessValue = snapStep(root.defaultBrightness, -0.50, 0.50, 0.05)
    root.gammaValue = snapStep(root.defaultGamma, 1.00, 2.40, 0.05)
    root.contrastValue = snapStep(root.defaultContrast, 0.50, 2.00, 0.05)
    root.saturationValue = snapStep(root.defaultSaturation, 0.00, 2.00, 0.05)
    root.warmthValue = snapStep(root.defaultWarmth, -1.00, 1.00, 0.05)
    root.tintValue = snapStep(root.defaultTint, -1.00, 1.00, 0.05)
    root.dirtyKeys = ({})
    root.sendLiveAll()
    root.pendingReset = true
    root.flushPersist()
  }

  FileView {
    id: envFile
    path: root.envFilePath
    watchChanges: true
    onLoaded: root.parseEnvText(text())
    onLoadFailed: root.tuningInstalled = false
    onFileChanged: reload()
  }

  FileView {
    id: defaultsFile
    path: root.tuningName !== "" && root.tuningsRoot !== "/default/camera/tunings"
      ? (root.tuningsRoot + "/" + root.tuningName + "/tuning.conf")
      : ""
    onLoaded: root.parseDefaultsText(text())
  }

  // Brief grace period only when hiding, so a mode switch never flickers the
  // bar icon. Showing is always immediate (0 ms).
  Timer {
    id: hideDelayTimer
    interval: 1000
    repeat: false
    onTriggered: root.cameraActive = false
  }

  // Self-heal if the watcher ever exits (e.g. loopback device wasn't ready
  // yet at early login).
  Timer {
    id: watcherRetryTimer
    interval: 5000
    repeat: false
    onTriggered: {
      if (!root.previewMode && root.tuningInstalled && !watcherProc.running) {
        watcherProc.running = true
      }
    }
  }

  // Coalesce persistent writes to ~/.config/omarchy/camera.conf after release.
  Timer {
    id: persistDebounceTimer
    interval: 350
    repeat: false
    onTriggered: root.flushPersist()
  }

  Process {
    id: watcherProc
    running: !root.previewMode && root.tuningInstalled && root.watcherPath !== ""
    stdinEnabled: true
    command: ["python3", "-u", root.watcherPath]
    stdout: SplitParser {
      onRead: function(line) {
        var status = String(line || "").trim()
        if (status === "active") {
          hideDelayTimer.stop()
          root.cameraActive = true
        } else if (status === "inactive") {
          if (root.cameraActive) hideDelayTimer.restart()
        }
      }
    }
    onExited: {
      if (!root.previewMode && root.tuningInstalled) {
        watcherRetryTimer.restart()
      }
    }
  }

  Process {
    id: saveProc
    onExited: {
      if (root.pendingSave || root.pendingReset || root.hasDirtyKeys()) {
        root.pendingSave = false
        root.flushPersist()
        return
      }
      root.saving = false
      envFile.reload()
    }
  }

  Connections {
    target: root.bar
    ignoreUnknownSignals: true
    function onActivePopoutChanged() {
      if (root.opened && root.bar && root.bar.activePopout !== root) {
        root.opened = false
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰄀"
    tooltipText: Commons.I18n.t("camera.tooltipActive")
    onPressed: function(btn) {
      if (btn === Qt.LeftButton) {
        root.toggle()
      }
    }
  }

  PopupCard {
    id: card
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.opened
    contentWidth: card.fittedContentWidth(Style.space(320))
    contentHeight: card.fittedContentHeight(contentColumn.implicitHeight)

    Column {
      id: contentColumn
      width: parent.width
      spacing: Style.space(12)

      PanelHero {
        width: parent.width
        title: root.cameraLabel
        meta: {
          var status = Commons.I18n.t("camera.liveMeta")
          return root.resolutionBadge !== "" ? (status + " · " + root.resolutionBadge) : status
        }
        foreground: root.foreground
        fontFamily: root.fontFamily

        iconComponent: Component {
          Text {
            textFormat: Text.PlainText
            text: "󰄀"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
          }
        }

        trailingControl: Component {
          PanelActionButton {
            iconText: "󰑐"
            tooltipText: Commons.I18n.t("camera.resetTooltip")
            foreground: root.foreground
            fontFamily: root.fontFamily
            bordered: true
            enabled: root.isModified
            onClicked: root.resetAll()
          }
        }
      }

      PanelSeparator {
        foreground: root.foreground
      }

      Column {
        width: parent.width
        spacing: Style.space(8)

        SliderRow {
          id: brightnessRow
          label: Commons.I18n.t("camera.brightness")
          minimum: -0.50
          maximum: 0.50
          step: 0.05
          value: root.brightnessValue
          signed: true
          onMoved: function(v) { root.sendLiveKey("brightness", v, false) }
          onCommitted: function(v) {
            root.brightnessValue = v
            root.savedBrightness = v
            root.sendLiveKey("brightness", v, true)
            root.queuePersist("brightness")
          }
          onResetRequested: {
            root.savedBrightness = root.defaultBrightness
            root.brightnessValue = root.snapStep(root.defaultBrightness, minimum, maximum, step)
            root.sendLiveKey("brightness", root.savedBrightness, true)
            root.queuePersist("brightness")
          }
        }

        SliderRow {
          id: gammaRow
          label: Commons.I18n.t("camera.gamma")
          minimum: 1.00
          maximum: 2.40
          step: 0.05
          value: root.gammaValue
          onMoved: function(v) { root.sendLiveKey("gamma", v, false) }
          onCommitted: function(v) {
            root.gammaValue = v
            root.savedGamma = v
            root.sendLiveKey("gamma", v, true)
            root.queuePersist("gamma")
          }
          onResetRequested: {
            root.savedGamma = root.defaultGamma
            root.gammaValue = root.snapStep(root.defaultGamma, minimum, maximum, step)
            root.sendLiveKey("gamma", root.savedGamma, true)
            root.queuePersist("gamma")
          }
        }

        SliderRow {
          id: contrastRow
          label: Commons.I18n.t("camera.contrast")
          minimum: 0.50
          maximum: 2.00
          step: 0.05
          value: root.contrastValue
          onMoved: function(v) { root.sendLiveKey("contrast", v, false) }
          onCommitted: function(v) {
            root.contrastValue = v
            root.savedContrast = v
            root.sendLiveKey("contrast", v, true)
            root.queuePersist("contrast")
          }
          onResetRequested: {
            root.savedContrast = root.defaultContrast
            root.contrastValue = root.snapStep(root.defaultContrast, minimum, maximum, step)
            root.sendLiveKey("contrast", root.savedContrast, true)
            root.queuePersist("contrast")
          }
        }
      }

      PanelSeparator {
        foreground: root.foreground
      }

      Column {
        width: parent.width
        spacing: Style.space(8)

        SliderRow {
          id: saturationRow
          label: Commons.I18n.t("camera.saturation")
          minimum: 0.00
          maximum: 2.00
          step: 0.05
          value: root.saturationValue
          onMoved: function(v) { root.sendLiveKey("saturation", v, false) }
          onCommitted: function(v) {
            root.saturationValue = v
            root.savedSaturation = v
            root.sendLiveKey("saturation", v, true)
            root.queuePersist("saturation")
          }
          onResetRequested: {
            root.savedSaturation = root.defaultSaturation
            root.saturationValue = root.snapStep(root.defaultSaturation, minimum, maximum, step)
            root.sendLiveKey("saturation", root.savedSaturation, true)
            root.queuePersist("saturation")
          }
        }

        SliderRow {
          id: warmthRow
          label: Commons.I18n.t("camera.warmth")
          minimum: -1.00
          maximum: 1.00
          step: 0.05
          value: root.warmthValue
          signed: true
          onMoved: function(v) { root.sendLiveKey("warmth", v, false) }
          onCommitted: function(v) {
            root.warmthValue = v
            root.savedWarmth = v
            root.sendLiveKey("warmth", v, true)
            root.queuePersist("warmth")
          }
          onResetRequested: {
            root.savedWarmth = root.defaultWarmth
            root.warmthValue = root.snapStep(root.defaultWarmth, minimum, maximum, step)
            root.sendLiveKey("warmth", root.savedWarmth, true)
            root.queuePersist("warmth")
          }
        }

        SliderRow {
          id: tintRow
          label: Commons.I18n.t("camera.tint")
          minimum: -1.00
          maximum: 1.00
          step: 0.05
          value: root.tintValue
          signed: true
          onMoved: function(v) { root.sendLiveKey("tint", v, false) }
          onCommitted: function(v) {
            root.tintValue = v
            root.savedTint = v
            root.sendLiveKey("tint", v, true)
            root.queuePersist("tint")
          }
          onResetRequested: {
            root.savedTint = root.defaultTint
            root.tintValue = root.snapStep(root.defaultTint, minimum, maximum, step)
            root.sendLiveKey("tint", root.savedTint, true)
            root.queuePersist("tint")
          }
        }
      }
    }
  }
}
