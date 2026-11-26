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

  property real gammaValue: 1.50
  property real contrastValue: 1.05
  property real saturationValue: 1.40

  // Raw values as saved in camera-relay.env (unclamped), so CLI overrides
  // outside the slider bounds stay visible to isModified and are never
  // clobbered when the user adjusts a different slider.
  property real savedGamma: 1.50
  property real savedContrast: 1.05
  property real savedSaturation: 1.40

  property real defaultGamma: 1.50
  property real defaultContrast: 1.05
  property real defaultSaturation: 1.40

  property var dirtyKeys: ({})
  property double lastLiveSentMs: 0

  readonly property bool anyDragging: gammaSlider.dragging || contrastSlider.dragging || saturationSlider.dragging

  readonly property bool isModified:
    Math.abs(savedGamma - defaultGamma) > 0.005
    || Math.abs(savedContrast - defaultContrast) > 0.005
    || Math.abs(savedSaturation - defaultSaturation) > 0.005

  // Visible only while the camera is actively streaming (or while the user
  // still has this popup open), plus in `omarchy agent look plugin` preview.
  visible: previewMode || (tuningInstalled && (cameraActive || opened))
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

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
    return Math.round(clamped / stepVal) * stepVal
  }

  function formatArg(value) {
    return Number(value).toFixed(2)
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
      var g = parseFloat(map.GAMMA)
      var c = parseFloat(map.CONTRAST)
      var s = parseFloat(map.SATURATION)
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
      if (key === "gamma") root.defaultGamma = val
      else if (key === "contrast") root.defaultContrast = val
      else if (key === "saturation") root.defaultSaturation = val
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
      "gamma=" + formatArg(root.savedGamma)
      + " contrast=" + formatArg(root.savedContrast)
      + " saturation=" + formatArg(root.savedSaturation) + "\n"
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
    root.pendingSave = false
    if (root.pendingReset) {
      root.pendingReset = false
      root.saving = true
      saveProc.command = ["omarchy-camera-tuning", "reset"]
      saveProc.running = true
      return
    }

    var args = ["omarchy-camera-tuning", "set"]
    if (root.dirtyKeys.gamma) args.push("gamma=" + formatArg(root.savedGamma))
    if (root.dirtyKeys.contrast) args.push("contrast=" + formatArg(root.savedContrast))
    if (root.dirtyKeys.saturation) args.push("saturation=" + formatArg(root.savedSaturation))
    if (args.length <= 2) return

    root.dirtyKeys = ({})
    root.saving = true
    saveProc.command = args
    saveProc.running = true
  }

  function resetAll() {
    if (root.previewMode) return
    persistDebounceTimer.stop()
    root.savedGamma = root.defaultGamma
    root.savedContrast = root.defaultContrast
    root.savedSaturation = root.defaultSaturation
    root.gammaValue = snapStep(root.defaultGamma, 1.00, 2.40, 0.05)
    root.contrastValue = snapStep(root.defaultContrast, 0.50, 2.00, 0.05)
    root.saturationValue = snapStep(root.defaultSaturation, 0.00, 2.00, 0.05)
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
        spacing: Style.space(10)

        // Gamma
        Column {
          width: parent.width
          spacing: Style.space(4)

          Item {
            width: parent.width
            height: gammaLabel.implicitHeight

            Text {
              id: gammaLabel
              textFormat: Text.PlainText
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.t("camera.gamma")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }

            Text {
              textFormat: Text.PlainText
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.formatNumber(gammaSlider.liveValue, 2)
              color: gammaSlider.dragging ? root.foreground : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }

          PanelSlider {
            id: gammaSlider
            width: parent.width
            bar: root.bar
            minimum: 1.00
            maximum: 2.40
            step: 0.05
            value: root.gammaValue
            onMoved: function(v) {
              root.sendLiveKey("gamma", v, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.gammaValue = next
              root.savedGamma = next
              root.sendLiveKey("gamma", next, true)
              root.queuePersist("gamma")
            }
            onRightClicked: {
              root.savedGamma = root.defaultGamma
              root.gammaValue = root.snapStep(root.defaultGamma, minimum, maximum, step)
              root.sendLiveKey("gamma", root.savedGamma, true)
              root.queuePersist("gamma")
            }
          }
        }

        // Contrast
        Column {
          width: parent.width
          spacing: Style.space(4)

          Item {
            width: parent.width
            height: contrastLabel.implicitHeight

            Text {
              id: contrastLabel
              textFormat: Text.PlainText
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.t("camera.contrast")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }

            Text {
              textFormat: Text.PlainText
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.formatNumber(contrastSlider.liveValue, 2)
              color: contrastSlider.dragging ? root.foreground : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }

          PanelSlider {
            id: contrastSlider
            width: parent.width
            bar: root.bar
            minimum: 0.50
            maximum: 2.00
            step: 0.05
            value: root.contrastValue
            onMoved: function(v) {
              root.sendLiveKey("contrast", v, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.contrastValue = next
              root.savedContrast = next
              root.sendLiveKey("contrast", next, true)
              root.queuePersist("contrast")
            }
            onRightClicked: {
              root.savedContrast = root.defaultContrast
              root.contrastValue = root.snapStep(root.defaultContrast, minimum, maximum, step)
              root.sendLiveKey("contrast", root.savedContrast, true)
              root.queuePersist("contrast")
            }
          }
        }

        // Saturation
        Column {
          width: parent.width
          spacing: Style.space(4)

          Item {
            width: parent.width
            height: saturationLabel.implicitHeight

            Text {
              id: saturationLabel
              textFormat: Text.PlainText
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.t("camera.saturation")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }

            Text {
              textFormat: Text.PlainText
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.formatNumber(saturationSlider.liveValue, 2)
              color: saturationSlider.dragging ? root.foreground : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }

          PanelSlider {
            id: saturationSlider
            width: parent.width
            bar: root.bar
            minimum: 0.00
            maximum: 2.00
            step: 0.05
            value: root.saturationValue
            onMoved: function(v) {
              root.sendLiveKey("saturation", v, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.saturationValue = next
              root.savedSaturation = next
              root.sendLiveKey("saturation", next, true)
              root.queuePersist("saturation")
            }
            onRightClicked: {
              root.savedSaturation = root.defaultSaturation
              root.saturationValue = root.snapStep(root.defaultSaturation, minimum, maximum, step)
              root.sendLiveKey("saturation", root.savedSaturation, true)
              root.queuePersist("saturation")
            }
          }
        }
      }
    }
  }
}
