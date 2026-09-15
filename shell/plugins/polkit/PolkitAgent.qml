import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "PolkitModel.js" as PolkitModel

Item {
  id: root

  property string fontFamily: Style.font.menuFamily
  // Bound to the central [polkit] section in shell.toml via Color.qml.
  property color accent: Color.polkit.accent
  property color background: Color.polkit.background
  property color foreground: Color.polkit.text
  property color border: Color.polkit.border
  property color borderError: Color.polkit.borderError
  property var borderSpec: Border.surfaceSpec("polkit", errorFlash ? "border-error" : "border", errorFlash ? borderError : border, Math.max(1, Style.space(2)), "border-alpha")
  property color scrim: Color.polkit.scrim
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  property int fieldHeight: Math.max(Style.space(42), Style.spacing.controlHeight)

  property bool closing: false
  property bool submitted: false
  property string currentMessage: ""
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
  // The processes that ran pkexec, found by omarchy-polkit-caller. Any process
  // can name itself anything, so the prompt says the chain isn't verified.
  property string requestedBy: ""
  // Bumped per prompt and on close, so a lookup still finishing for an earlier
  // prompt can't fill in this one.
  property int promptSerial: 0
  property int callerSerial: 0
  // The full command pkexec was given, shell-quoted, from a pkexec whose command
  // matches what the message shows; the message itself shortens and flattens it.
  property string callerCommand: ""
  property bool callerShortened: false
  // The default agent, when it can explain a command without tools, and its
  // answer. It's only asked when the user presses Tab or clicks the hint.
  property string agentName: ""
  property string explanation: ""
  property string explainError: ""
  property bool explaining: false
  property int explainSerial: 0
  // Offered once the caller lookup is done, so the full command is used when it
  // can be.
  readonly property bool canExplain: hasCommand && agentName !== "" && !callerProc.running

  readonly property bool dialogVisible: polkitAgent.isActive || closing
  // We show one method at a time. Fingerprint owns the dialog while PAM is
  // waiting on the reader (lid open, sensor enrolled); the moment PAM asks for
  // a password — including immediately when the lid is shut and the clamshell
  // gate skips pam_fprintd — we switch to the password field instead.
  readonly property bool fingerprintMode: fingerprintConfigured && !laptopClosed && dialogVisible && !responseRequired && !submitted && !errorFlash
  // What is being authorized: a title, plus the program and its arguments when
  // the request comes from pkexec. Shown at the top of the card.
  readonly property var request: PolkitModel.authorizationRequest(currentMessage)
  readonly property bool hasHeader: request.title !== ""
  readonly property bool hasCommand: request.program !== ""
  readonly property int headerSpacing: Style.space(12)
  readonly property int contentHeight: fieldHeight + (hasHeader ? header.implicitHeight + headerSpacing : 0)
  readonly property int cardHeight: panel.height > 0 ? Math.min(contentHeight + contentMargin * 2, panel.height - Style.gapsOut * 2) : contentHeight + contentMargin * 2
  // Password mode is a wide field, wider still when it has a command to show;
  // fingerprint mode without a header collapses to a square that just frames
  // the centered sensor icon.
  readonly property int cardWidth: fingerprintMode && !hasHeader ? cardHeight : Math.min(Style.space(hasCommand ? 480 : 312), Math.max(Style.space(260), panel.width - Style.gapsOut * 2))

  function loadPamConfig(raw) {
    fingerprintConfigured = PolkitModel.fingerprintConfiguredFromPamConfig(raw)
  }

  function refreshLidState() {
    if (!laptopClosedProc.running) laptopClosedProc.running = true
  }

  function clearRequest() {
    requestedBy = ""
    callerCommand = ""
    callerShortened = false
    explaining = false
    explanation = ""
    explainError = ""
    if (explainProc.running) explainProc.running = false
  }

  function inspectRequest() {
    promptSerial++
    clearRequest()
    agentName = ""
    // A lookup still running for an earlier prompt is stopped first, and
    // onRunningChanged starts this one once it has.
    if (callerProc.running) callerProc.running = false
    else if (hasCommand) startCallerLookup()
    if (hasCommand && !explainCheckProc.running) explainCheckProc.running = true
  }

  function startCallerLookup() {
    callerSerial = promptSerial
    // Bounded, so a lookup stuck on a hung process can't hold up later prompts.
    callerProc.command = ["timeout", "-k", "1", "2", "omarchy-polkit-caller", request.program, request.command]
    callerProc.running = true
  }

  function explain() {
    if (!canExplain || explaining || explanation !== "" || submitted || closing) return
    explaining = true
    explainError = ""
    // An answer still running for an earlier prompt is stopped first, and
    // onRunningChanged starts this one once it has.
    if (explainProc.running) explainProc.running = false
    else startExplaining()
  }

  function startExplaining() {
    explainSerial = promptSerial
    var exact = callerCommand !== ""
    var shortened = exact ? callerShortened : request.command.indexOf(" ... ") !== -1
    explainProc.command = ["omarchy-agent-explain"].concat(
      exact ? ["--exact"] : [],
      shortened ? ["--shortened"] : [],
      ["--", exact ? callerCommand : request.command, requestedBy, request.title])
    explainProc.running = true
  }

  function resetSnapshot() {
    promptSerial++
    clearRequest()
    currentMessage = ""
    currentPrompt = ""
    currentSupplementary = ""
    responseRequired = false
    responseVisible = false
    failed = false
    errorFlash = false
    submitted = false
    passwordInput.text = ""
  }

  function syncFromFlow() {
    var flow = polkitAgent.flow
    if (!flow) return

    currentMessage = String(flow.message || "Authentication is needed...")
    currentPrompt = String(flow.inputPrompt || "")
    currentSupplementary = String(flow.supplementaryMessage || "")
    responseRequired = !!flow.isResponseRequired
    responseVisible = !!flow.responseVisible
    failed = !!flow.failed

    if (responseRequired) submitted = false
  }

  function beginFlow() {
    closeTimer.stop()
    closing = false
    submitted = false
    passwordInput.text = ""
    refreshLidState()
    syncFromFlow()
    inspectRequest()
    Qt.callLater(refocus)
  }

  function refocus() {
    if (!dialogVisible) return
    // In fingerprint mode there is no field to type into — park focus on the
    // key catcher so Escape still cancels; otherwise focus the password field.
    if (fingerprintMode) keyCatcher.forceActiveFocus()
    else passwordInput.forceActiveFocus()
  }

  function submitResponse() {
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
    passwordInput.text = ""
    submitted = false
    closing = true
    closeTimer.restart()
    if (flow) flow.cancelAuthenticationRequest()
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
    id: closeTimer
    interval: 300
    repeat: false
    onTriggered: {
      closing = false
      resetSnapshot()
    }
  }

  Timer {
    id: errorTimer
    interval: 1200
    repeat: false
    onTriggered: root.errorFlash = false
  }

  SequentialAnimation {
    id: shakeAnimation
    NumberAnimation { target: root; property: "shakeOffset"; to: -8; duration: 35; easing.type: Easing.OutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 8; duration: 50; easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 55; easing.type: Easing.OutQuad }
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
    id: laptopClosedProc
    command: ["bash", "-c", "omarchy-hw-laptop-closed && echo closed || echo open"]
    stdout: StdioCollector { id: laptopClosedOut; waitForEnd: true }
    onExited: root.laptopClosed = String(laptopClosedOut.text || "").trim() === "closed"
  }

  Process {
    id: callerProc
    stdout: StdioCollector { id: callerOut; waitForEnd: true }
    onExited: function(exitCode) {
      if (root.callerSerial !== root.promptSerial) return
      var caller = PolkitModel.callerFromOutput(exitCode, callerOut.text)
      root.requestedBy = caller.requestedBy
      root.callerCommand = caller.command
      root.callerShortened = caller.shortened
    }
    // A new prompt arrived while an earlier lookup was still running.
    onRunningChanged: if (!running && root.hasCommand && root.callerSerial !== root.promptSerial) root.startCallerLookup()
  }

  Process {
    id: explainCheckProc
    command: ["timeout", "-k", "1", "5", "omarchy-agent-explain", "--check"]
    stdout: StdioCollector { id: explainCheckOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.agentName = exitCode === 0 ? String(explainCheckOut.text || "").trim() : ""
    }
  }

  Process {
    id: explainProc
    stdout: StdioCollector { id: explainOut; waitForEnd: true }
    stderr: StdioCollector { id: explainErr; waitForEnd: true }
    onExited: function(exitCode) {
      // Stopped because the prompt moved on or closed; nothing to show it in.
      if (!root.explaining || root.explainSerial !== root.promptSerial) return
      root.explaining = false
      var answer = String(explainOut.text || "").trim()
      if (exitCode === 0 && answer !== "") {
        root.explanation = answer
      } else {
        var lines = String(explainErr.text || "").trim().split("\n")
        root.explainError = (lines[lines.length - 1] || root.agentName + " couldn't explain this command").replace(/\.$/, "")
      }
    }
    onRunningChanged: {
      if (running || !root.explaining) return
      if (root.explainSerial !== root.promptSerial && !root.closing && !root.submitted) {
        // Tab was pressed while an answer for an earlier prompt was stopping.
        root.startExplaining()
      } else {
        // It never started, or the prompt is closing or submitted: no answer is
        // coming.
        root.explaining = false
        if (root.explainSerial === root.promptSerial) root.explainError = root.agentName + " couldn't start"
      }
    }
  }

  PolkitAgent {
    id: polkitAgent
    path: "/org/omarchy/PolkitAgent"

    onAuthenticationRequestStarted: root.beginFlow()
    onIsActiveChanged: {
      if (isActive) root.syncFromFlow()
      else if (!root.closing) root.resetSnapshot()
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
      root.closing = true
      closeTimer.restart()
    }

    function onAuthenticationRequestCancelled() {
      root.closing = true
      closeTimer.restart()
    }
  }

  PanelWindow {
    id: panel
    visible: root.dialogVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-polkit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.refocus()
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
          } else if (event.key === Qt.Key_Tab) {
            root.explain()
            event.accepted = true
          }
        }
      }

      Column {
        id: header
        visible: root.hasHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.leftMargin: card.contentLeftInset
        // On a short screen the card stops growing, so the header is cut off
        // rather than drawn over the password field.
        height: Math.min(implicitHeight, card.height - card.contentTopInset - card.contentBottomInset - cardRow.height - root.headerSpacing)
        clip: true
        spacing: Style.space(8)

        Text {
          textFormat: Text.PlainText
          width: parent.width
          text: root.request.title
          color: root.foreground
          opacity: 0.6
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
          maximumLineCount: 3
          elide: Text.ElideRight
        }

        Rectangle {
          visible: root.hasCommand
          width: parent.width
          height: commandFlow.implicitHeight + Style.space(8) * 2
          radius: root.cornerRadius
          color: Util.alpha(root.foreground, 0.06)

          // The program stays on the first line; its arguments follow on the
          // same line when they fit and wrap below it when they don't. The
          // arguments are never cut off: this is what the user is approving,
          // and pkexec already caps the command line at about 80 bytes.
          Flow {
            id: commandFlow
            x: Style.space(10)
            y: Style.space(8)
            width: parent.width - Style.space(10) * 2
            spacing: Style.space(8)

            Text {
              textFormat: Text.PlainText
              width: Math.min(implicitWidth, commandFlow.width)
              text: root.request.program
              color: root.accent
              font.family: Style.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              wrapMode: Text.WrapAnywhere
            }

            Text {
              textFormat: Text.PlainText
              visible: text !== ""
              width: Math.min(implicitWidth, commandFlow.width)
              text: root.request.args
              color: root.foreground
              font.family: Style.fontFamily
              font.pixelSize: Style.font.body
              wrapMode: Text.WrapAnywhere
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: root.requestedBy !== ""
          width: parent.width
          clip: true
          text: "Not verified: requested by " + root.requestedBy
          color: root.foreground
          opacity: 0.6
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          visible: root.canExplain && root.explanation === "" && !root.submitted
          width: parent.width
          text: root.explaining ? "Asking " + root.agentName + "..."
            : root.explainError !== "" ? root.explainError + ". Press Tab to retry."
            : "Press Tab to ask " + root.agentName + " what this does"
          color: root.explainError !== "" ? Color.polkit.textError : root.accent
          opacity: root.explaining ? 0.6 : 1
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight

          MouseArea {
            anchors.fill: parent
            enabled: !root.explaining
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.explain()
              root.refocus()
            }
          }
        }

        // The answer is labeled as a guess: the command it describes was written
        // by whatever asked for root.
        Text {
          textFormat: Text.PlainText
          visible: root.explanation !== ""
          width: parent.width
          clip: true
          text: root.agentName + "'s guess, which may be wrong: " + root.explanation
          color: root.foreground
          opacity: 0.8
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
          maximumLineCount: 7
          elide: Text.ElideRight
        }
      }

      // Fingerprint mode shows just the sensor icon in place of the field \u2014 no
      // padlock, no field, no prompt text.
      OpticalGlyph {
        anchors.centerIn: cardRow
        width: Math.round(root.fieldHeight * 0.7)
        height: width
        visible: root.fingerprintMode
        text: "\udb80\ude37"
        fontFamily: root.fontFamily
        fontSize: Math.round(root.fieldHeight * 0.7)
        color: root.errorFlash ? Color.polkit.textError : root.accent
      }

      Row {
        id: cardRow
        visible: !root.fingerprintMode
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        height: root.fieldHeight - card.borderTop - card.borderBottom
        spacing: Style.space(14)

        Text {
          text: "\uf023"
          color: root.errorFlash ? Color.polkit.textError : root.accent
          font.family: root.fontFamily
          font.pixelSize: Style.font.iconLarge
          width: Style.space(26)
          height: root.fieldHeight
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }

        Item {
          width: parent.width - Style.space(40)
          height: root.fieldHeight

          TextInput {
            id: passwordInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            clip: true
            selectionColor: Util.alpha(root.accent, 0.45)
            selectedTextColor: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            echoMode: root.responseVisible ? TextInput.Normal : TextInput.Password
            passwordCharacter: "\u2022"
            color: root.errorFlash ? Color.polkit.textError : root.foreground
            cursorVisible: activeFocus && !root.submitted && !root.errorFlash
            readOnly: root.submitted || root.errorFlash
            enabled: root.dialogVisible
            onAccepted: root.submitResponse()
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                root.cancelRequest()
                event.accepted = true
              } else if (event.key === Qt.Key_Tab) {
                root.explain()
                event.accepted = true
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.errorFlash ? "Wrong" : (root.submitted ? "Checking..." : "Enter password")
            color: root.errorFlash ? Color.polkit.textError : root.foreground
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
            color: root.errorFlash ? Color.polkit.textError : root.foreground
            visible: passwordInput.visible && passwordInput.activeFocus && passwordInput.text.length === 0 && !root.submitted && !root.errorFlash
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            enabled: passwordInput.visible
            onClicked: passwordInput.forceActiveFocus()
          }
        }
      }
    }
  }
}
