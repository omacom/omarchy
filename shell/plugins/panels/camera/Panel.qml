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
  property bool popupOpen: false
  property bool saving: false
  property bool pendingSave: false
  property bool pendingReset: false

  property string tuningName: ""
  property string cameraLabel: Commons.I18n.t("camera.title")
  property string resolutionBadge: ""

  property real gammaValue: 1.50
  property real contrastValue: 1.05
  property real saturationValue: 1.40

  property real defaultGamma: 1.50
  property real defaultContrast: 1.05
  property real defaultSaturation: 1.40

  property double lastLiveSentMs: 0

  readonly property bool anyDragging: gammaSlider.dragging || contrastSlider.dragging || saturationSlider.dragging

  readonly property bool isModified:
    Math.abs(gammaValue - defaultGamma) > 0.005
    || Math.abs(contrastValue - defaultContrast) > 0.005
    || Math.abs(saturationValue - defaultSaturation) > 0.005

  // Visible only while the camera is actively streaming (or while the user
  // still has this popup open), plus in `omarchy agent look plugin` preview.
  visible: previewMode || (tuningInstalled && (cameraActive || popupOpen))
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

  function close() {
    root.popupOpen = false
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
      if (!isNaN(g)) root.gammaValue = snapStep(g, 1.00, 2.40, 0.05)
      if (!isNaN(c)) root.contrastValue = snapStep(c, 0.50, 2.00, 0.05)
      if (!isNaN(s)) root.saturationValue = snapStep(s, 0.00, 2.00, 0.05)
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
      if (key === "gamma") root.defaultGamma = snapStep(val, 1.00, 2.40, 0.05)
      else if (key === "contrast") root.defaultContrast = snapStep(val, 0.50, 2.00, 0.05)
      else if (key === "saturation") root.defaultSaturation = snapStep(val, 0.00, 2.00, 0.05)
    }
  }

  // Send 0ms live property updates through the already-running watcher bridge
  // to the relay's Unix datagram socket — zero process spawns, zero restarts.
  function sendLive(g, c, s, force) {
    if (root.previewMode || !watcherProc.running) return
    var now = Date.now()
    if (!force && (now - root.lastLiveSentMs) < 33) return
    root.lastLiveSentMs = now
    watcherProc.write(
      "gamma=" + formatArg(g)
      + " contrast=" + formatArg(c)
      + " saturation=" + formatArg(s) + "\n"
    )
  }

  function queuePersist() {
    if (root.previewMode) return
    root.pendingReset = false
    persistDebounceTimer.restart()
  }

  function flushPersist() {
    if (root.previewMode) return
    if (saveProc.running) {
      root.pendingSave = true
      return
    }
    root.saving = true
    root.pendingSave = false
    if (root.pendingReset) {
      root.pendingReset = false
      saveProc.command = ["omarchy-camera-tuning", "reset"]
    } else {
      saveProc.command = [
        "omarchy-camera-tuning",
        "set",
        "gamma=" + formatArg(root.gammaValue),
        "contrast=" + formatArg(root.contrastValue),
        "saturation=" + formatArg(root.saturationValue)
      ]
    }
    saveProc.running = true
  }

  function resetAll() {
    if (root.previewMode) return
    persistDebounceTimer.stop()
    root.gammaValue = root.defaultGamma
    root.contrastValue = root.defaultContrast
    root.saturationValue = root.defaultSaturation
    root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
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
      if (root.pendingSave) {
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
      if (root.popupOpen && root.bar && root.bar.activePopout !== root) {
        root.popupOpen = false
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
        root.popupOpen = !root.popupOpen
      }
    }
  }

  PopupCard {
    id: card
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
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
              root.sendLive(v, contrastSlider.liveValue, saturationSlider.liveValue, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.gammaValue = next
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
            }
            onRightClicked: {
              root.gammaValue = root.defaultGamma
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
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
              root.sendLive(gammaSlider.liveValue, v, saturationSlider.liveValue, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.contrastValue = next
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
            }
            onRightClicked: {
              root.contrastValue = root.defaultContrast
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
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
              root.sendLive(gammaSlider.liveValue, contrastSlider.liveValue, v, false)
            }
            onReleased: function(v) {
              var next = root.snapStep(v, minimum, maximum, step)
              root.saturationValue = next
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
            }
            onRightClicked: {
              root.saturationValue = root.defaultSaturation
              root.sendLive(root.gammaValue, root.contrastValue, root.saturationValue, true)
              root.queuePersist()
            }
          }
        }
      }
    }
  }
}
