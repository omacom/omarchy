import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Centered Wi-Fi QR overlay supporting two modes:
//   - "share": renders the connected Wi-Fi network as a scannable QR matrix
//   - "scan": opens the webcam to scan a WIFI: QR code and connect to it
//     automatically via NetworkManager.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  function scriptPath(name) {
    var sourceDir = manifest && manifest.__sourceDir ? String(manifest.__sourceDir) : ""
    if (sourceDir !== "") return sourceDir + "/" + name
    return omarchyPath + "/shell/plugins/panels/wifiqr/" + name
  }

  property bool opened: false
  property string mode: "share" // "share" | "scan"
  property string iface: ""
  property string ssid: ""
  property bool secured: false

  // Share-mode state
  property var qrRows: []
  property int qrSize: 0
  property string error: ""
  property bool loading: false
  property bool expectedStop: false
  property bool pendingShow: false
  property string pendingIface: ""
  property string password: ""
  property bool passwordVisible: false
  property string passwordError: ""
  property bool pwExpectedStop: false

  readonly property bool showingQr: mode === "share" && qrSize > 0 && !loading && error === ""

  // Scan-mode state
  property bool webcamAvailable: false
  property string scanState: "starting" // "starting" | "scanning" | "connecting" | "connected" | "error"
  property var cameras: []
  property string activeCameraDevice: ""
  property string activeCameraLabel: ""
  property string framePath: ""
  property bool frameReady: false
  property int frameTick: 0
  property string scanHintError: ""
  property string scanErrorCode: ""
  property string scanErrorText: ""
  property string scannedSsid: ""
  property string scannedSecurity: "WPA"
  property bool scannedHidden: false
  property string pendingConnectPassword: ""
  property bool scanExpectedStop: false
  property bool pendingScan: false
  property string pendingScanDevice: ""
  property bool connectExpectedStop: false

  // The scrim below is a fixed near-black regardless of theme, so text on
  // it needs a fixed light palette, not the themed foreground.
  readonly property color onScrim: "white"
  readonly property color onScrimDim: Qt.rgba(1, 1, 1, 0.55)
  readonly property color onScrimUrgent: "#ff6b6b"
  readonly property color onScrimSuccess: "#51cf66"
  readonly property string fontFamily: Style.font.family

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    root.ssid = payload.ssid !== undefined ? String(payload.ssid) : ""
    root.iface = payload.iface !== undefined ? String(payload.iface) : ""
    root.opened = true
    if (!webcamCheckProc.running) webcamCheckProc.running = true

    if (payload.mode === "scan") {
      startScan(String(payload.device || ""))
    } else {
      startShare(String(payload.iface || ""))
    }

    Qt.callLater(function() {
      if (root.opened) keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
    root.pendingShow = false
    stopShareProcesses()
    stopScanProcesses()
    resetShareState()
    resetScanState()
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.wifiqr")
    else close()
  }

  function stopShareProcesses() {
    if (qrProc.running) {
      root.expectedStop = true
      qrProc.running = false
    }
    if (pwProc.running) {
      root.pwExpectedStop = true
      pwProc.running = false
    }
  }

  function resetShareState() {
    root.qrSize = 0
    root.qrRows = []
    root.error = ""
    root.loading = false
    root.secured = false
    root.password = ""
    root.passwordVisible = false
    root.passwordError = ""
  }

  function stopCameraProcess() {
    root.pendingScan = false
    root.pendingScanDevice = ""
    if (scanProc.running) {
      root.scanExpectedStop = true
      scanProc.running = false
    }
    root.frameReady = false
  }

  function stopScanProcesses() {
    stopCameraProcess()
    if (connectProc.running) {
      root.connectExpectedStop = true
      connectProc.running = false
    }
    hintResetTimer.stop()
    connectedDismissTimer.stop()
    root.pendingConnectPassword = ""
  }

  function resetScanState() {
    root.scanState = "starting"
    root.cameras = []
    root.activeCameraDevice = ""
    root.activeCameraLabel = ""
    root.framePath = ""
    root.frameReady = false
    root.frameTick = 0
    root.scanHintError = ""
    root.scanErrorCode = ""
    root.scanErrorText = ""
    root.scannedSsid = ""
    root.scannedSecurity = "WPA"
    root.scannedHidden = false
    root.pendingConnectPassword = ""
  }

  function startShare(requestedIface) {
    stopScanProcesses()
    resetScanState()
    root.mode = "share"
    generate(requestedIface !== undefined ? requestedIface : root.iface)
  }

  function startScan(requestedDevice) {
    stopShareProcesses()
    if (connectProc.running) {
      root.connectExpectedStop = true
      connectProc.running = false
    }
    hintResetTimer.stop()
    connectedDismissTimer.stop()
    root.pendingConnectPassword = ""

    if (scanProc.running) {
      root.pendingScan = true
      root.pendingScanDevice = requestedDevice || ""
      if (!root.scanExpectedStop) {
        root.scanExpectedStop = true
        scanProc.running = false
      }
      return
    }

    root.mode = "scan"
    root.scanState = "starting"
    root.frameReady = false
    root.framePath = ""
    root.frameTick = 0
    root.scanHintError = ""
    root.scanErrorCode = ""
    root.scanErrorText = ""
    root.scannedSsid = ""
    root.cameras = []
    root.scanExpectedStop = false

    var script = root.scriptPath("scan-webcam-qr.sh")
    scanProc.command = requestedDevice ? [script, requestedDevice] : [script]
    scanProc.running = true
  }

  function switchCamera() {
    if (root.cameras.length <= 1) return
    var currentIdx = -1
    for (var i = 0; i < root.cameras.length; i++) {
      if (root.cameras[i].device === root.activeCameraDevice) {
        currentIdx = i
        break
      }
    }
    var nextIdx = (currentIdx + 1) % root.cameras.length
    startScan(root.cameras[nextIdx].device)
  }

  function generate(requestedIface) {
    if (qrProc.running) {
      pendingShow = true
      pendingIface = requestedIface
      if (!expectedStop) {
        expectedStop = true
        qrProc.running = false
      }
      return
    }
    qrSize = 0
    qrRows = []
    error = ""
    loading = true
    expectedStop = false
    secured = false
    password = ""
    passwordVisible = false
    passwordError = ""
    if (pwProc.running) {
      pwExpectedStop = true
      pwProc.running = false
    }
    qrProc.command = requestedIface
      ? ["omarchy-network-qr", "--meta", requestedIface]
      : ["omarchy-network-qr", "--meta"]
    qrProc.running = true
  }

  function updateQr(raw) {
    var parsed = Model.parseQrOutput(raw)
    qrRows = parsed.matrix.rows
    qrSize = parsed.matrix.size
    if (parsed.meta.ssid !== "") ssid = parsed.meta.ssid
    if (parsed.meta.iface !== "") iface = parsed.meta.iface
    secured = parsed.meta.security !== "" && parsed.meta.security !== "nopass"
    if (qrSize > 0) error = ""
  }

  function togglePassword() {
    if (passwordVisible) { passwordVisible = false; return }
    if (password !== "") { passwordVisible = true; return }
    if (pwProc.running || !iface) return
    passwordError = ""
    pwExpectedStop = false
    pwProc.command = ["omarchy-network-password", iface]
    pwProc.running = true
  }

  function localizedScanError(code, fallbackText) {
    if (code === "noWebcam") return I18n.t("wifiqr.noWebcam")
    if (code === "cameraFailed") return I18n.t("wifiqr.cameraFailed")
    if (code === "notWifi") return I18n.t("wifiqr.notWifiQr")
    if (code === "missingSsid") return I18n.t("wifiqr.missingSsid")
    if (code === "missingPassword") return I18n.t("wifiqr.missingPassword")
    if (code === "enterpriseUnsupported") return I18n.t("wifiqr.enterpriseUnsupported")
    if (code === "connectFailed") return I18n.t("wifiqr.connectFailed").arg(root.scannedSsid || "Wi-Fi")
    return fallbackText || I18n.t("wifiqr.cameraFailed")
  }

  function handleScannerEvent(line) {
    if (!root.opened || root.mode !== "scan") return
    var ev = Model.parseScannerLine(line)
    if (!ev) return

    if (ev.type === "camera") {
      var list = root.cameras.slice()
      list.push({ device: ev.device, label: ev.label })
      root.cameras = list
    } else if (ev.type === "active") {
      root.activeCameraDevice = ev.device
      root.activeCameraLabel = ev.label
      root.framePath = ev.framePath
    } else if (ev.type === "ready") {
      root.framePath = ev.framePath
      root.frameReady = true
      root.frameTick = 1
      if (root.scanState === "starting") root.scanState = "scanning"
    } else if (ev.type === "qr") {
      handleDecodedQr(ev.raw)
    } else if (ev.type === "error") {
      if (ev.code === "noWebcam") root.webcamAvailable = false
      root.scanErrorCode = ev.code
      root.scanErrorText = ""
      root.scanState = "error"
    }
  }

  function handleDecodedQr(rawText) {
    if (root.scanState === "connecting" || root.scanState === "connected") return

    var parsed = Model.parseWifiQr(rawText)
    if (!parsed.valid) {
      root.scanHintError = localizedScanError(parsed.reason || "notWifi", "")
      hintResetTimer.restart()
      return
    }

    stopCameraProcess()
    hintResetTimer.stop()
    root.scanHintError = ""
    root.scannedSsid = parsed.ssid
    root.scannedSecurity = parsed.security
    root.scannedHidden = parsed.hidden
    root.scanState = "connecting"
    root.connectExpectedStop = false
    root.pendingConnectPassword = parsed.password || ""

    var connectScript = root.scriptPath("connect-wifi-qr.sh")
    connectProc.command = [
      connectScript,
      parsed.ssid,
      parsed.security,
      parsed.hidden ? "yes" : "no",
      root.iface
    ]
    connectProc.running = true
  }

  Timer {
    id: frameTimer
    interval: 66
    repeat: true
    running: root.opened && root.mode === "scan" && root.scanState === "scanning" && root.frameReady
    onTriggered: root.frameTick = (root.frameTick + 1) % 1000000
  }

  Timer {
    id: hintResetTimer
    interval: 2600
    repeat: false
    onTriggered: root.scanHintError = ""
  }

  Timer {
    id: connectedDismissTimer
    interval: 1200
    repeat: false
    onTriggered: if (root.opened && root.scanState === "connected") root.dismiss()
  }

  Process {
    id: qrProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (!root.expectedStop) root.updateQr(text)
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (!root.expectedStop) root.error = String(text || "").trim()
    }
    onExited: function(exitCode) {
      root.loading = false
      if (root.pendingShow) {
        root.pendingShow = false
        Qt.callLater(function() { root.generate(root.pendingIface) })
        return
      }
      if (root.expectedStop) return
      if (exitCode !== 0 || root.qrSize === 0) {
        root.qrSize = 0
        root.qrRows = []
        if (root.error === "") root.error = I18n.t("wifiqr.generateFailed")
      }
    }
  }

  Process {
    id: pwProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (root.opened && !root.pwExpectedStop) root.password = String(text || "").trim()
    }
    onExited: function(exitCode) {
      if (root.pwExpectedStop) return
      if (!root.opened) return
      if (exitCode === 0 && root.password !== "") root.passwordVisible = true
      else root.passwordError = I18n.t("wifiqr.passwordFailed")
    }
  }

  Process {
    id: webcamCheckProc
    command: ["omarchy-hw-webcam"]
    onExited: function(exitCode) {
      root.webcamAvailable = (exitCode === 0)
    }
  }

  Process {
    id: scanProc
    stdout: SplitParser {
      onRead: function(line) {
        if (!root.scanExpectedStop) root.handleScannerEvent(line)
      }
    }
    onExited: function(exitCode) {
      root.frameReady = false
      if (root.pendingScan) {
        root.pendingScan = false
        var nextDevice = root.pendingScanDevice
        root.pendingScanDevice = ""
        Qt.callLater(function() {
          if (root.opened) root.startScan(nextDevice)
        })
        return
      }
      if (root.scanExpectedStop || !root.opened || root.mode !== "scan") return
      if (root.scanState === "starting" || root.scanState === "scanning") {
        if (root.scanErrorCode === "") root.scanErrorCode = "cameraFailed"
        root.scanState = "error"
      }
    }
  }

  Process {
    id: connectProc
    stdinEnabled: true
    onStarted: {
      write(root.pendingConnectPassword + "\n")
      root.pendingConnectPassword = ""
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (!root.connectExpectedStop) root.scanErrorText = String(text || "").trim()
      }
    }
    onExited: function(exitCode) {
      root.pendingConnectPassword = ""
      if (root.connectExpectedStop || !root.opened) return
      if (exitCode === 0) {
        root.ssid = root.scannedSsid
        root.scanState = "connected"
        connectedDismissTimer.restart()
      } else {
        root.scanErrorCode = "connectFailed"
        root.scanState = "error"
      }
    }
  }

  OverlayWindow {
    shown: root.opened
    WlrLayershell.namespace: "omarchy-network-qr"

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.78)

      MouseArea {
        anchors.fill: parent
        onClicked: root.dismiss()
      }
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true

      Keys.onEscapePressed: root.dismiss()
      Keys.onPressed: function(event) {
        if (!root.webcamAvailable || root.mode !== "scan") return
        if (event.key === Qt.Key_C && root.cameras.length > 1) {
          root.switchCamera()
          event.accepted = true
        } else if ((event.key === Qt.Key_R || event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)
                   && root.scanState === "error") {
          root.startScan(root.activeCameraDevice)
          event.accepted = true
        }
      }

      Item {
        anchors.centerIn: parent
        width: content.implicitWidth
        height: content.implicitHeight
        scale: Math.min(1,
          (keyCatcher.width - Style.space(32)) / Math.max(1, width),
          (keyCatcher.height - Style.space(32)) / Math.max(1, height))

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
          id: content
          anchors.fill: parent
          spacing: Style.space(16)

          // Title header
          Text {
            textFormat: Text.PlainText
            text: (root.mode === "scan"
              ? (root.scannedSsid !== "" && root.scanState !== "scanning" ? root.scannedSsid : I18n.t("wifiqr.scanTitle"))
              : (root.ssid || "Wi-Fi")).toUpperCase()
            color: root.onScrimDim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 2
            elide: Text.ElideRight
            Layout.maximumWidth: Style.space(340)
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
          }

          // ==================== SHARE MODE ====================
          Rectangle {
            id: qrCanvas
            readonly property int moduleSize: root.qrSize > 0
              ? Math.max(4, Math.floor(Style.space(240) / root.qrSize))
              : 0

            visible: root.showingQr
            width: root.qrSize * moduleSize
            height: width
            color: "white"
            radius: Style.cornerRadius
            Layout.alignment: Qt.AlignHCenter

            Grid {
              anchors.fill: parent
              columns: root.qrSize
              LayoutMirroring.enabled: false

              Repeater {
                model: root.qrSize * root.qrSize

                Rectangle {
                  required property int index
                  readonly property int matrixRow: Math.floor(index / root.qrSize)
                  readonly property int matrixColumn: index % root.qrSize

                  width: qrCanvas.moduleSize
                  height: qrCanvas.moduleSize
                  color: root.qrRows[matrixRow].charAt(matrixColumn) === "1" ? "#111111" : "transparent"
                }
              }
            }
          }

          Text {
            visible: root.mode === "share" && root.loading
            text: I18n.t("wifiqr.generating")
            textFormat: Text.PlainText
            color: root.onScrimDim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            textFormat: Text.PlainText
            visible: root.mode === "share" && root.error !== ""
            text: root.error
            color: root.onScrimUrgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.maximumWidth: Style.space(320)
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            visible: root.showingQr
            text: I18n.t("wifiqr.scanToJoin")
            textFormat: Text.PlainText
            color: root.onScrimDim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            textFormat: Text.PlainText
            visible: root.showingQr && root.secured
            text: root.passwordError !== "" ? root.passwordError
              : root.passwordVisible ? root.password
              : I18n.t("wifiqr.showPassword")
            color: root.passwordError !== "" ? root.onScrimUrgent : root.onScrim
            opacity: root.passwordVisible || root.passwordError !== "" ? 1 : 0.6
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WrapAnywhere
            Layout.fillWidth: true
            Layout.maximumWidth: Style.space(320)
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.togglePassword()
            }
          }

          // ==================== SCAN MODE ====================
          Rectangle {
            id: scannerCard
            visible: root.mode === "scan"
            width: Style.space(320)
            height: Style.space(240)
            radius: Style.cornerRadius
            color: "#141414"
            border.width: 1
            border.color: root.scanState === "connected" ? root.onScrimSuccess
              : (root.scanState === "error" ? root.onScrimUrgent : Qt.rgba(1, 1, 1, 0.18))
            clip: true
            Layout.alignment: Qt.AlignHCenter

            Image {
              id: cameraPreview
              anchors.fill: parent
              anchors.margins: 1
              visible: (root.scanState === "scanning" || root.scanState === "starting") && root.frameReady
              source: root.frameReady && root.framePath !== ""
                ? "file://" + root.framePath + "?v=" + root.frameTick
                : ""
              fillMode: Image.PreserveAspectCrop
              cache: false
              asynchronous: false
              mirror: true
            }

            // Viewfinder reticle brackets while actively scanning
            Item {
              anchors.centerIn: parent
              width: Style.space(168)
              height: Style.space(168)
              visible: root.scanState === "scanning" && root.frameReady

              readonly property int armLen: Style.space(22)
              readonly property int armThick: 3
              readonly property color reticleColor: root.scanHintError !== "" ? root.onScrimUrgent : root.onScrim

              // Top-left
              Rectangle { x: 0; y: 0; width: parent.armLen; height: parent.armThick; color: parent.reticleColor; radius: 1 }
              Rectangle { x: 0; y: 0; width: parent.armThick; height: parent.armLen; color: parent.reticleColor; radius: 1 }
              // Top-right
              Rectangle { anchors.right: parent.right; y: 0; width: parent.armLen; height: parent.armThick; color: parent.reticleColor; radius: 1 }
              Rectangle { anchors.right: parent.right; y: 0; width: parent.armThick; height: parent.armLen; color: parent.reticleColor; radius: 1 }
              // Bottom-left
              Rectangle { x: 0; anchors.bottom: parent.bottom; width: parent.armLen; height: parent.armThick; color: parent.reticleColor; radius: 1 }
              Rectangle { x: 0; anchors.bottom: parent.bottom; width: parent.armThick; height: parent.armLen; color: parent.reticleColor; radius: 1 }
              // Bottom-right
              Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: parent.armLen; height: parent.armThick; color: parent.reticleColor; radius: 1 }
              Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: parent.armThick; height: parent.armLen; color: parent.reticleColor; radius: 1 }
            }

            // Center states: Starting camera, Connecting, Connected, or Error
            ColumnLayout {
              anchors.centerIn: parent
              width: parent.width - Style.space(32)
              spacing: Style.space(10)
              visible: !cameraPreview.visible

              Text {
                textFormat: Text.PlainText
                text: root.scanState === "connected" ? "󰄬"
                  : (root.scanState === "connecting" ? "󰤨"
                  : (root.scanState === "error" ? "󰤮" : "󰄀"))
                color: root.scanState === "connected" ? root.onScrimSuccess
                  : (root.scanState === "error" ? root.onScrimUrgent : root.onScrim)
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                Layout.alignment: Qt.AlignHCenter
              }

              Text {
                textFormat: Text.PlainText
                visible: root.scannedSsid !== "" && (root.scanState === "connecting" || root.scanState === "connected")
                text: root.scannedSsid + " (" + Model.securityLabel(root.scannedSecurity, I18n.t("wifiqr.openNetwork")) + ")"
                color: root.onScrim
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
              }

              Text {
                textFormat: Text.PlainText
                text: {
                  if (root.scanState === "starting") return I18n.t("wifiqr.startingCamera")
                  if (root.scanState === "connecting") return I18n.t("wifiqr.connectingTo").arg(root.scannedSsid)
                  if (root.scanState === "connected") return I18n.t("wifiqr.connectedTo").arg(root.scannedSsid)
                  if (root.scanState === "error") return root.localizedScanError(root.scanErrorCode, root.scanErrorText)
                  return ""
                }
                color: root.scanState === "error" ? root.onScrimUrgent
                  : (root.scanState === "connected" ? root.onScrimSuccess : root.onScrimDim)
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
              }
            }
          }

          // Scan mode hint / non-fatal warning below the viewfinder
          Text {
            textFormat: Text.PlainText
            visible: root.mode === "scan" && (root.scanState === "scanning" || root.scanState === "starting")
            text: root.scanHintError !== "" ? root.scanHintError : I18n.t("wifiqr.pointCamera")
            color: root.scanHintError !== "" ? root.onScrimUrgent : root.onScrimDim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.maximumWidth: Style.space(320)
            horizontalAlignment: Text.AlignHCenter
          }

          // Scan mode bottom action buttons (Scan again, Switch camera)
          RowLayout {
            visible: root.mode === "scan" && root.webcamAvailable && root.scanState !== "connecting" && root.scanState !== "connected" && (root.scanState === "error" || root.cameras.length > 1)
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.space(8)

            ActionPill {
              visible: root.scanState === "error"
              iconGlyph: "󰑐"
              labelText: I18n.t("wifiqr.scanAgain")
              onClicked: root.startScan(root.activeCameraDevice)
            }

            ActionPill {
              visible: root.cameras.length > 1
              iconGlyph: "󰄀"
              labelText: I18n.t("wifiqr.switchCamera")
              onClicked: root.switchCamera()
            }
          }
        }
      }
    }
  }

  component ActionPill: Rectangle {
    id: actionPill
    required property string iconGlyph
    required property string labelText
    signal clicked()

    implicitWidth: actionRow.implicitWidth + Style.space(20)
    implicitHeight: actionRow.implicitHeight + Style.space(10)
    radius: Style.cornerRadius
    color: actionMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.22)

    RowLayout {
      id: actionRow
      anchors.centerIn: parent
      spacing: Style.space(6)

      Text {
        textFormat: Text.PlainText
        text: actionPill.iconGlyph
        color: root.onScrim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      Text {
        textFormat: Text.PlainText
        text: actionPill.labelText
        color: root.onScrim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

    MouseArea {
      id: actionMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: actionPill.clicked()
    }
  }
}
