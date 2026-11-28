import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "PolkitModel.js" as PolkitModel

Item {
  id: root

  property string fontFamily: Style.font.menuFamily
  // Bound to the central [polkit] section in shell.toml via Commons.Color.qml.
  property color accent: Commons.Color.polkit.accent
  property color background: Commons.Color.polkit.background
  property color foreground: Commons.Color.polkit.text
  property color border: Commons.Color.polkit.border
  property color borderError: Commons.Color.polkit.borderError
  property var borderSpec: Border.surfaceSpec("polkit", errorFlash ? "border-error" : "border", errorFlash ? borderError : border, Math.max(1, Style.space(2)), "border-alpha")
  property color scrim: Commons.Color.polkit.scrim
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  property int fieldHeight: Math.max(Style.space(42), Style.spacing.controlHeight)

  // Set immediately on polkit auth success or cancel so the overlay drops its
  // exclusive keyboard focus and pointer grab without waiting for polkitd to
  // finish tearing down the D-Bus flow.
  property bool dismissed: false
  property bool submitted: false
  property bool cancelRevealed: false
  property string currentMessage: ""
  // What a command asked its next prompt to say, as it knows what it's for
  // and pkexec names only the program: one prompt, for that program, within
  // a minute. Taken by the prompt it fits, which keeps it as currentLabel.
  property var expected: null
  property string currentLabel: ""
  // The coding agent a prompt comes from ({ mark, name, light }), whose icon
  // in the agents plugin takes the padlock's place. Looked up per prompt, and
  // the padlock waits for the answer so it doesn't flash before the mark.
  property var currentAgent: null
  property bool requesterPending: false
  property int requestSerial: 0
  readonly property url agentMarkSource: {
    if (!currentAgent) return ""
    var suffix = currentAgent.light && Util.luminance(background) >= 0.5 ? "-light.svg" : ".svg"
    return Qt.resolvedUrl("../agents/assets/" + currentAgent.mark + suffix)
  }
  property string currentPrompt: ""
  property string currentSupplementary: ""
  property bool responseRequired: false
  property bool responseVisible: false
  property bool failed: false
  property bool errorFlash: false
  // pam_fprintd appears in the polkit PAM stack (a sensor is enrolled).
  property bool fingerprintConfigured: false
  // Lid shut right now — the reader is physically unreachable, so we fall back
  // to the password even when a sensor is enrolled. Refreshed per request.
  property bool laptopClosed: false
  property int shakeOffset: 0
  // The encrypted drive being asked for (omarchy-drive-unlock), not polkit:
  // the card unlocks it with the password itself, so a wrong one is asked again.
  property string driveDevice: ""
  property string driveLabel: ""
  // Drives waiting their turn, as { device, label }: one card at a time.
  property var driveQueue: []

  readonly property bool dialogVisible: (polkitAgent.isActive && !dismissed) || driveDevice !== ""

  onSubmittedChanged: if (submitted) hideCancel()

  PointerMoveGate {
    id: pointerGate
    threshold: 8
  }

  function hideCancel() {
    cancelRevealed = false
    pointerGate.reset()
  }
  // We show one method at a time. Fingerprint owns the dialog while PAM is
  // waiting on the reader (lid open, sensor enrolled); the moment PAM asks for
  // a password — including immediately when the lid is shut and the clamshell
  // gate skips pam_fprintd — we switch to the password field instead.
  readonly property bool fingerprintMode: fingerprintConfigured && !laptopClosed && dialogVisible && !responseRequired && !submitted && !errorFlash
  readonly property int cardHeight: panel.height > 0 ? Math.min(fieldHeight + contentMargin * 2, panel.height - Style.gapsOut * 2) : fieldHeight + contentMargin * 2
  // Password mode is a wide field; fingerprint mode collapses to a square that
  // just frames the centered sensor icon.
  readonly property int cardWidth: fingerprintMode ? cardHeight : Math.min(Style.space(312), Math.max(Style.space(260), panel.width - Style.gapsOut * 2))

  // A pkexec prompt always shows what it runs on a dimmer second line under
  // either the caller's reason or the default authorization heading.
  function authorizationLabel(message) {
    var label = PolkitModel.singleLine(currentLabel)
    if (label !== "") return label
    var text = message ? PolkitModel.authorizationLabel(message, I18n.t, currentAgent ? currentAgent.name : "") : ""
    return text !== "" ? text : I18n.t("polkit.authenticationNeeded")
  }

  // The command a pkexec prompt runs, shown on the second line under the heading.
  readonly property string labelProgram: PolkitModel.singleLine(PolkitModel.promptProgram(currentMessage))

  ShellIpc {
    target: "omarchy.polkit"
    function expect(program: string, label: string): string {
      root.expected = { program: program, label: label, until: Date.now() + 60000 }
      return "ok"
    }
    function unlockDrive(device: string, label: string): string {
      root.queueDrive(device, label)
      return "ok"
    }
  }

  function loadPamConfig(raw) {
    fingerprintConfigured = PolkitModel.fingerprintConfiguredFromPamConfig(raw)
  }

  function refreshLidState() {
    if (!laptopClosedProc.running) laptopClosedProc.running = true
  }

  function clearRequester() {
    currentAgent = null
    requesterPending = false
    requesterTimeout.stop()
    // A lookup still running is for a prompt that's gone, not for what comes
    // next, a drive's card included.
    requestSerial++
  }

  function resetSnapshot() {
    currentMessage = ""
    currentLabel = ""
    clearRequester()
    currentPrompt = ""
    currentSupplementary = ""
    responseRequired = false
    responseVisible = false
    failed = false
    errorFlash = false
    submitted = false
    hideCancel()
    passwordInput.text = ""
  }

  function syncFromFlow() {
    var flow = polkitAgent.flow
    if (!flow) return

    currentMessage = String(flow.message || "")
    currentPrompt = String(flow.inputPrompt || "")
    currentSupplementary = String(flow.supplementaryMessage || "")
    responseRequired = !!flow.isResponseRequired
    responseVisible = !!flow.responseVisible
    failed = !!flow.failed

    if (responseRequired) submitted = false
  }

  function queueDrive(device, label) {
    if (device === driveDevice || driveQueue.some(function(d) { return d.device === device })) return
    driveQueue = driveQueue.concat([{ device: device, label: label }])
    nextDrive()
  }

  function nextDrive() {
    if (driveDevice !== "" || (polkitAgent.isActive && !dismissed) || driveQueue.length === 0) return
    var next = driveQueue[0]
    driveQueue = driveQueue.slice(1)
    beginDrive(next.device, next.label)
  }

  function beginDrive(device, label) {
    resetSnapshot()
    driveDevice = device
    driveLabel = label
    currentLabel = I18n.t("polkit.unlockDrive").replace("%1", label)
    responseRequired = true
    Qt.callLater(refocus)
  }

  function driveChecked(device, exitCode, error) {
    if (exitCode === 0) driveQueue = driveQueue.filter(function(d) { return d.device !== device })
    // An answer for a drive no longer asked for (cancelled, or set aside for polkit).
    if (device !== driveDevice) return
    if (exitCode !== 0 && /Incorrect passphrase|No passphrase/.test(error)) {
      triggerFailureFeedback()
      return
    }
    if (exitCode !== 0) console.warn("omarchy drive unlock failed: " + error.trim())
    driveDevice = ""
    resetSnapshot()
    nextDrive()
  }

  function beginFlow() {
    // Polkit's own request takes the card; a drive being asked for waits first in line.
    if (driveDevice !== "") {
      driveQueue = [{ device: driveDevice, label: driveLabel }].concat(driveQueue)
      driveDevice = ""
    }
    // A new request starts fresh even if the previous flow is still tearing down.
    dismissed = false
    submitted = false
    hideCancel()
    passwordInput.text = ""
    refreshLidState()
    syncFromFlow()
    // Each request takes the label it was expected with, or none, so one
    // arriving while the last dialog closes doesn't keep the last label. It is
    // taken here and not in syncFromFlow, which runs first: Quickshell sets the
    // flow, and with it isActive, before it says the request started.
    currentLabel = PolkitModel.expectedLabel(currentMessage, expected, Date.now())
    if (currentLabel !== "") expected = null
    findRequester()
    Qt.callLater(refocus)
  }

  // Only a pkexec prompt names the command line its process can be found by.
  // A lookup that hangs gives the padlock back after a second.
  function findRequester() {
    clearRequester()
    requesterPending = PolkitModel.promptProgram(currentMessage) !== ""
    if (!requesterPending) return
    requesterTimeout.restart()
    lookUpRequester()
  }

  // One lookup runs at a time: a prompt that starts while the last one's
  // still runs gets its own when that ends.
  function lookUpRequester() {
    if (requesterProc.running) return
    requesterProc.forSerial = requestSerial
    requesterProc.command = ["python3", Quickshell.env("OMARCHY_PATH") + "/shell/plugins/polkit/requester.py", PolkitModel.promptProgram(currentMessage)]
    requesterProc.running = true
  }

  function dismissPolkit() {
    dismissed = true
    // A queued drive may already have taken the card if cancelRequest() ran first.
    if (driveDevice === "") {
      resetSnapshot()
      nextDrive()
    }
  }

  function refocus() {
    if (!dialogVisible) return
    // In fingerprint mode there is no field to type into — park focus on the
    // key catcher so Escape still cancels; otherwise focus the password field.
    if (fingerprintMode) keyCatcher.forceActiveFocus()
    else passwordInput.forceActiveFocus()
  }

  function submitResponse() {
    if (driveDevice !== "") {
      if (submitted) return
      submitted = true
      errorFlash = false
      driveUnlock.secret = passwordInput.text
      driveUnlock.device = driveDevice
      driveUnlock.command = ["udisksctl", "unlock", "--no-user-interaction", "--block-device", driveDevice, "--key-file", "/dev/stdin"]
      driveUnlock.stdinEnabled = true
      driveUnlock.running = true
      passwordInput.text = ""
      keyCatcher.forceActiveFocus()
      return
    }
    var flow = polkitAgent.flow
    if (!flow || !flow.isResponseRequired) return
    submitted = true
    errorFlash = false
    flow.submit(passwordInput.text)
    passwordInput.text = ""
    keyCatcher.forceActiveFocus()
  }

  function cancelRequest() {
    var flow = polkitAgent.flow
    var hadDrive = driveDevice !== ""
    driveDevice = ""
    if (!hadDrive && polkitAgent.isActive) dismissed = true
    resetSnapshot()
    if (!hadDrive && flow) flow.cancelAuthenticationRequest()
    nextDrive()
  }

  function triggerFailureFeedback() {
    submitted = false
    errorFlash = true
    passwordInput.text = ""
    errorTimer.restart()
    shakeAnimation.restart()
    Qt.callLater(refocus)
  }

  Timer {
    id: errorTimer
    interval: 1200
    repeat: false
    onTriggered: root.errorFlash = false
  }

  SequentialAnimation {
    id: shakeAnimation
    NumberAnimation { target: root; property: "shakeOffset"; to: -8; duration: Style.duration(35); easing.type: Easing.OutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 8; duration: Style.duration(50); easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: Style.duration(55); easing.type: Easing.OutQuad }
  }
  FileView {
    path: "/etc/pam.d/polkit-1"
    watchChanges: true
    printErrors: false
    onLoaded: root.loadPamConfig(text())
    onLoadFailed: root.fingerprintConfigured = false
    onFileChanged: reload()
  }

  Process {
    id: requesterProc
    property int forSerial: 0
    stdout: StdioCollector { id: requesterOut; waitForEnd: true }
    onExited: {
      if (forSerial === root.requestSerial) {
        requesterTimeout.stop()
        if (root.dialogVisible) root.currentAgent = PolkitModel.parseRequester(requesterOut.text)
        root.requesterPending = false
      } else if (root.requesterPending) {
        Qt.callLater(root.lookUpRequester)
      }
    }
  }

  Timer {
    id: requesterTimeout
    interval: 1000
    repeat: false
    onTriggered: {
      root.requestSerial++
      root.requesterPending = false
    }
  }

  Process {
    id: laptopClosedProc
    command: ["bash", "-c", "omarchy-hw-laptop-closed && echo closed || echo open"]
    stdout: StdioCollector { id: laptopClosedOut; waitForEnd: true }
    onExited: root.laptopClosed = String(laptopClosedOut.text || "").trim() === "closed"
  }

  // The password goes over stdin, never argv, and closing stdin ends it.
  Process {
    id: driveUnlock
    property string secret: ""
    property string device: ""
    stderr: StdioCollector { id: driveUnlockError; waitForEnd: true }
    onStarted: {
      write(secret)
      secret = ""
      stdinEnabled = false
    }
    onExited: function(exitCode) { root.driveChecked(device, exitCode, String(driveUnlockError.text || "")) }
  }

  PolkitAgent {
    id: polkitAgent
    path: "/org/omarchy/PolkitAgent"

    onAuthenticationRequestStarted: root.beginFlow()
    onIsActiveChanged: {
      if (isActive) root.syncFromFlow()
      else {
        root.dismissed = false
        if (root.driveDevice === "") {
          root.resetSnapshot()
          root.nextDrive()
        }
      }
    }
    onIsRegisteredChanged: {
      if (isRegistered) console.log("omarchy polkit agent registered")
      else console.warn("omarchy polkit agent is not registered; another agent may be running")
    }
  }

  Connections {
    target: polkitAgent.flow

    function onIsResponseRequiredChanged() {
      root.syncFromFlow()
      if (!polkitAgent.flow || !polkitAgent.flow.isResponseRequired) passwordInput.text = ""
      Qt.callLater(root.refocus)
    }

    function onInputPromptChanged() { root.syncFromFlow() }
    function onResponseVisibleChanged() { root.syncFromFlow() }
    function onSupplementaryMessageChanged() { root.syncFromFlow() }
    function onFailedChanged() { root.syncFromFlow() }

    function onAuthenticationFailed() {
      root.syncFromFlow()
      root.triggerFailureFeedback()
    }

    function onAuthenticationSucceeded() {
      root.dismissPolkit()
    }

    function onAuthenticationRequestCancelled() {
      root.dismissPolkit()
    }
  }

  PanelWindow {
    id: panel
    // Right-to-left languages read this window mirrored.
    Binding { target: panel.contentItem; property: "LayoutMirroring.enabled"; value: Commons.I18n.rightToLeft }
    Binding { target: panel.contentItem; property: "LayoutMirroring.childrenInherit"; value: true }

    visible: root.dialogVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-polkit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    HoverHandler {
      onPointChanged: {
        if (hovered && !root.cancelRevealed && pointerGate.moved(panel.contentItem, point.position)) {
          root.cancelRevealed = true
        }
      }
    }

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        root.cancelRevealed = true
        root.refocus()
      }
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      anchors.horizontalCenterOffset: root.shakeOffset
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: root.refocus() }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            root.cancelRequest()
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.responseRequired) root.submitResponse()
            event.accepted = true
          }
        }
      }

      // Fingerprint mode shows just the sensor icon, centered and alone \u2014 no
      // padlock, no field, no prompt text.
      OpticalGlyph {
        anchors.centerIn: parent
        width: Math.round(root.fieldHeight * 0.7)
        height: width
        visible: root.fingerprintMode
        text: "\udb80\ude37"
        fontFamily: root.fontFamily
        fontSize: Math.round(root.fieldHeight * 0.7)
        color: root.errorFlash ? Commons.Color.polkit.textError : root.accent
      }

      Row {
        id: cardRow
        visible: !root.fingerprintMode
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.space(14)

        Item {
          width: Style.space(26)
          height: root.fieldHeight

          Image {
            id: agentMark
            anchors.centerIn: parent
            width: Style.font.iconLarge
            height: width
            source: root.agentMarkSource
            sourceSize.width: width * 2
            sourceSize.height: height * 2
            fillMode: Image.PreserveAspectFit
            visible: status === Image.Ready
          }

          Text {
            anchors.fill: parent
            visible: !agentMark.visible && !root.requesterPending
            text: "\uf023"
            color: root.errorFlash ? Commons.Color.polkit.textError : root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }

        Item {
          width: parent.width - Style.space(40)
          height: root.fieldHeight

          TextInput {
            id: passwordInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            selectByMouse: true
            clip: true
            selectionColor: Util.alpha(root.accent, 0.45)
            selectedTextColor: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            echoMode: root.responseVisible ? TextInput.Normal : TextInput.Password
            passwordCharacter: "\u2022"
            color: root.errorFlash ? Commons.Color.polkit.textError : root.foreground
            cursorVisible: activeFocus && !root.submitted && !root.errorFlash
            readOnly: root.submitted || root.errorFlash
            enabled: root.dialogVisible
            onAccepted: root.submitResponse()
            onTextEdited: root.hideCancel()
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                root.cancelRequest()
                event.accepted = true
              }
            }

            HoverHandler {
              enabled: !passwordInput.readOnly
              cursorShape: Qt.IBeamCursor
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.errorFlash ? I18n.t("polkit.wrong") : (root.submitted ? I18n.t("polkit.checking") : I18n.t("polkit.enterPassword"))
            color: root.errorFlash ? Commons.Color.polkit.textError : root.foreground
            opacity: root.errorFlash ? 1 : 0.36
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            elide: Text.ElideRight
            visible: passwordInput.text.length === 0
          }

          Rectangle {
            width: Math.max(1, Style.space(2))
            height: Style.space(24)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: root.errorFlash ? Commons.Color.polkit.textError : root.foreground
            visible: passwordInput.visible && passwordInput.activeFocus && passwordInput.text.length === 0 && !root.submitted && !root.errorFlash
          }
        }
      }
    }

    Rectangle {
      // Waits for the agent with the mark when its line names it, unless a
      // label is already known.
      visible: !root.requesterPending || PolkitModel.singleLine(root.currentLabel) !== ""
      // Measured apart from the lines, whose width follows this one.
      width: {
        var labelWidth = Math.max(labelMetrics.advanceWidth, labelMetrics.boundingRect.width)
        var programWidth = root.labelProgram !== "" ? Math.max(programMetrics.advanceWidth, programMetrics.boundingRect.width) : 0
        var naturalWidth = Math.ceil(Math.max(labelWidth, programWidth)) + Style.space(24)
        return panel.width > 0 ? Math.min(naturalWidth, Math.max(0, panel.width - Style.gapsOut * 2)) : naturalWidth
      }
      height: Math.max(Style.space(28), justificationLines.implicitHeight + Style.space(root.labelProgram !== "" ? 16 : 10))
      anchors.horizontalCenter: card.horizontalCenter
      anchors.bottom: card.top
      anchors.bottomMargin: Style.space(10)
      radius: root.cornerRadius
      color: root.background
      clip: true

      TextMetrics { id: labelMetrics; font: justificationText.font; text: justificationText.text }
      TextMetrics { id: programMetrics; font: programText.font; text: programText.text }

      Column {
        id: justificationLines
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(12)
        spacing: Style.space(3)

        Text {
          id: justificationText
          textFormat: Text.PlainText
          width: parent.width
          maximumLineCount: 1
          text: root.authorizationLabel(root.currentMessage)
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: root.labelProgram !== "" ? Style.font.body : Style.font.bodySmall
          horizontalAlignment: Text.AlignHCenter
          elide: root.labelProgram !== "" ? Text.ElideRight : Text.ElideMiddle
        }

        Text {
          id: programText
          textFormat: Text.PlainText
          width: parent.width
          maximumLineCount: 1
          visible: text !== ""
          text: root.labelProgram
          color: root.foreground
          opacity: 0.6
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideMiddle
        }
      }
    }

    Rectangle {
      id: cancelPill
      property real shown: root.cancelRevealed ? 1 : 0
      Behavior on shown {
        id: cancelShowing
        enabled: root.dialogVisible
        NumberAnimation {
          duration: Style.duration(cancelShowing.targetValue > 0 ? 180 : 120)
          easing.type: Easing.Bezier
          easing.bezierCurve: Style.easeOut
        }
      }
      visible: shown > 0
      opacity: shown
      width: Math.ceil(cancelText.implicitWidth) + Style.space(24)
      height: Math.max(Style.space(28), Math.ceil(cancelText.implicitHeight) + Style.space(10))
      anchors.horizontalCenter: card.horizontalCenter
      anchors.top: card.bottom
      anchors.topMargin: Style.space(10)
      radius: root.cornerRadius
      color: cancelMouse.containsMouse ? Qt.tint(root.background, Style.hoverFillFor(root.foreground, root.accent)) : root.background
      transform: Translate { y: -Style.space(4) * (1 - cancelPill.shown) }

      Behavior on color { ColorAnimation { duration: Style.duration(120); easing.type: Easing.InOutQuad } }

      Text {
        id: cancelText
        textFormat: Text.PlainText
        anchors.centerIn: parent
        text: I18n.t("common.cancel")
        color: root.foreground
        opacity: cancelMouse.containsMouse ? 1.0 : 0.72
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        Behavior on opacity { NumberAnimation { duration: Style.duration(120); easing.type: Easing.InOutQuad } }
      }

      MouseArea {
        id: cancelMouse
        anchors.fill: parent
        enabled: root.cancelRevealed
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.cancelRequest()
      }
    }
  }
}
