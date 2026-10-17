import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "EnrollModel.js" as EnrollModel

// Fingerprint enrollment overlay. Drives `fprintd-enroll` and turns its
// per-stage results into a print that fills in press by press, the way a
// phone does it, with a placement hint for the next press. Summon with:
//
//   omarchy-shell shell summon omarchy.fingerprint-enroll \
//     '{"finger":"right-index-finger","doneFile":"/tmp/x","expires":<epoch ms>}'
//
// When doneFile is given, "ok" or "failed" is written to it on exit so a
// script can wait on the result (the same round-trip the image picker uses).
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string finger: "right-index-finger"
  readonly property string user: Quickshell.env("USER")
  property string doneFile: ""
  property bool resultSent: false
  // which step a failure came from, so Enter retries the right one
  property string failedStep: ""
  property int totalStages: 5
  property int stagesPassed: 0
  // idle | checking | setup | installing | starting | waiting | confirm |
  // enabling | done | failed | pick
  property string phase: "idle"
  // first-time flow: install, enroll, confirm with a touch, enable PAM
  property bool setupFlow: false
  property int confirmTries: 0
  // picker state: hand 0 left / 1 right, finger 0 thumb .. 4 little
  property int pickHand: 1
  property int pickFinger: 1
  property var enrolled: []
  // true when opened without a finger: return to the picker after each
  // enrollment instead of closing
  property bool pickerMode: false
  property string message: ""
  property string hint: ""
  property bool errorFlash: false
  property bool passFlash: false
  property bool fingerPresent: false
  property string devicePath: ""
  property string fontFamily: Style.font.family

  readonly property real progress: (phase === "done" || phase === "confirm" || phase === "enabling") ? 1
                                   : (phase === "setup" || phase === "checking" || phase === "installing") ? 0
                                   : Math.min(1, totalStages > 0 ? stagesPassed / totalStages : 0)
  readonly property int glyphSize: Style.space(170)
  readonly property int cardWidth: Math.min(Style.space(380), panel.width - Style.gapsOut * 2)
  readonly property int cardHeight: Math.min(Style.space(root.phase === "pick" ? 330 : 390), panel.height - Style.gapsOut * 2)
  readonly property int contentMargin: Style.spacing.panelPadding
  readonly property color accent: Color.polkit.accent
  readonly property color foreground: Color.polkit.text
  readonly property color errorColor: Color.polkit.textError
  readonly property color dimGlyph: Util.alpha(Color.polkit.text, 0.28)

  // Model text is { key, text }: a catalog key and its English fallback.
  function tr(m) { return I18n.t(m.key, m.text) }
  function fingerName(finger) { return root.tr(EnrollModel.fingerName(finger)) }
  function pressHint(stagesPassed) {
    return I18n.t("fingerprint.pressAt", "Press %1 on the sensor").arg(root.tr(EnrollModel.placementFor(stagesPassed)))
  }

  // A request arriving while the overlay is open is refused rather than
  // allowed to take over: the shell delivers every summon to open(), and
  // replacing the state would leave the first caller without a result. A
  // second plain summon just keeps the open overlay.
  function reject(doneFile) {
    if (doneFile) Quickshell.execDetached(["bash", "-c", "printf '%s\\n' failed > \"$1\"", "_", doneFile])
  }

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }

    // The caller stops waiting at the request's deadline and may already be
    // running the text flow, so a request the shell delivers later is
    // refused: two enrollments would compete for the reader.
    if (EnrollModel.expired(payload, Date.now())) {
      root.reject(payload.doneFile || "")
      if (!root.opened) Qt.callLater(function() { if (!root.opened) root.hideFromShell() })
      return
    }

    if (root.opened) {
      root.reject(payload.doneFile || "")
      Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      return
    }

    root.stopAll()
    root.failedStep = ""
    root.doneFile = payload.doneFile || ""
    root.resultSent = false
    root.pickerMode = !EnrollModel.validFinger(payload.finger)
    root.setupFlow = false
    root.opened = true
    root.queryReader()

    if (root.pickerMode) {
      root.phase = "checking"
      root.message = I18n.t("fingerprint.checking", "Checking fingerprint login")
      root.hint = ""
      statusProc.running = true
    } else {
      root.startEnroll(payload.finger)
    }
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function showSetup() {
    root.phase = "setup"
    root.setupFlow = true
    root.message = I18n.t("fingerprint.loginOff", "Fingerprint login is off")
    root.hint = I18n.t("fingerprint.turnOnHint", "Press Enter to turn it on. You will be asked for your password")
    root.errorFlash = false
    listProc.running = true
  }

  function queryReader() {
    if (!stagesProc.running) stagesProc.running = true
  }

  function beginSetup() {
    root.phase = "installing"
    root.message = I18n.t("fingerprint.settingUp", "Setting up")
    root.hint = ""
    helperProc.command = ["omarchy-fingerprint-setup-helper", "install"]
    helperProc.running = true
  }

  readonly property int confirmMaxTries: 5

  function beginConfirm() {
    root.phase = "confirm"
    root.confirmTries += 1
    root.message = root.confirmTries === 1 ? I18n.t("fingerprint.confirmTouch", "Touch the sensor once to confirm")
                 : I18n.t("fingerprint.confirmAgain", "Didn't match, touch again (%1 of %2)").arg(I18n.formatNumber(root.confirmTries)).arg(I18n.formatNumber(root.confirmMaxTries))
    root.hint = I18n.t("fingerprint.confirmHint", "Press the way you normally would")
    root.fingerPresent = false
    verifyProc.running = true
  }

  function beginEnable() {
    root.phase = "enabling"
    root.message = I18n.t("fingerprint.turningOn", "Turning fingerprint login on")
    root.hint = ""
    helperProc.command = ["omarchy-fingerprint-setup-helper", "enable-login"]
    helperProc.running = true
  }

  function showPicker() {
    root.phase = "pick"
    root.message = root.setupFlow ? I18n.t("fingerprint.chooseFirst", "Choose the finger to enroll first") : I18n.t("fingerprint.choose", "Choose a finger to enroll")
    root.hint = I18n.t("fingerprint.pickerHint", "Arrow keys and Enter, or click. Esc closes")
    root.errorFlash = false
    listProc.running = true
  }

  function startEnroll(finger) {
    root.finger = finger
    root.stagesPassed = 0
    root.phase = "starting"
    root.message = I18n.t("fingerprint.starting", "Starting the reader")
    root.hint = ""
    root.errorFlash = false
    root.passFlash = false
    root.fingerPresent = false
    enrollProc.running = true
  }

  function pickMove(dh, df) {
    root.pickHand = Math.max(0, Math.min(1, root.pickHand + dh))
    root.pickFinger = Math.max(0, Math.min(4, root.pickFinger + df))
  }

  function isEnrolled(fingerId) {
    return root.enrolled.indexOf(fingerId) !== -1
  }

  // Package installation and turning login on run as root through pkexec;
  // closing then would unload the overlay and cut them off mid-transaction.
  readonly property bool privileged: root.phase === "installing" || root.phase === "enabling"

  // Stop everything one session started, so nothing fires into the next.
  function stopAll() {
    var timers = [errorFlashTimer, passFlashTimer, liftTimer, closeTimer, retryConfirmTimer]
    for (var i = 0; i < timers.length; i++) timers[i].stop()
    var procs = [enrollProc, verifyProc, monitorProc, stagesProc, statusProc, listProc]
    for (var j = 0; j < procs.length; j++) {
      if (procs[j].running) procs[j].signal(15)
    }
    root.errorFlash = false
    root.passFlash = false
    root.fingerPresent = false
  }

  function close() {
    root.opened = false
    root.stopAll()
  }

  // Scripts ask whether the overlay is still there, so a request it can no
  // longer answer (load failure, shell restart) fails fast instead of waiting.
  function isOpen() { return root.opened ? "open" : "closed" }
  function handles(doneFile) { return root.opened && doneFile !== "" && doneFile === root.doneFile ? "yes" : "no" }

  function dismiss() {
    if (root.privileged) return
    if (root.phase !== "done" && root.phase !== "failed") root.finish("failed")
    root.close()
    root.hideFromShell()
  }

  function hideFromShell() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.fingerprint-enroll")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  // Report the result once. execDetached runs outside this plugin, so the
  // write completes even when hiding the overlay unloads the plugin right
  // after (keepLoaded is false); a waiting caller never sits out a timeout.
  function finish(result) {
    if (!root.doneFile || root.resultSent) return
    root.resultSent = true
    Quickshell.execDetached(["bash", "-c", "printf '%s\\n' \"$1\" > \"$2\"", "_", result, root.doneFile])
  }

  function applyStep(step) {
    if (!step) return
    switch (step.kind) {
    case "passed":
      root.stagesPassed += 1
      root.phase = "waiting"
      root.message = root.tr(step.message)
      root.hint = root.pressHint(root.stagesPassed)
      passFlashTimer.restart()
      break
    case "retry":
      root.phase = "waiting"
      root.message = root.tr(step.message)
      errorFlashTimer.restart()
      break
    case "done":
      if (root.setupFlow) {
        root.confirmTries = 0
        root.beginConfirm()
        break
      }
      root.phase = "done"
      root.message = root.tr(step.message)
      root.hint = I18n.t("fingerprint.fingerReady", "Your %1 is ready for sudo, admin prompts and the lock screen").arg(root.fingerName(root.finger))
      root.finish("ok")
      closeTimer.restart()
      break
    case "cancelled":
      // fprintd refused: the password prompt was cancelled or failed (it
      // reports both the same way). One Esc in total, and say why.
      root.finish("failed")
      if (root.pickerMode) {
        root.showPicker()
        root.message = root.tr(step.message)
        errorFlashTimer.restart()
      } else {
        root.dismiss()
      }
      break
    case "failed":
      root.phase = "failed"
      root.failedStep = "enroll"
      root.message = root.tr(step.message)
      root.hint = root.pickerMode ? I18n.t("fingerprint.escBack", "Press Esc to go back") : I18n.t("fingerprint.escClose", "Press Esc to close")
      errorFlashTimer.restart()
      root.finish("failed")
      break
    }
  }

  Timer {
    id: errorFlashTimer
    interval: 600
    onTriggered: root.errorFlash = false
    onRunningChanged: if (running) root.errorFlash = true
  }

  Timer {
    id: passFlashTimer
    interval: 350
    onTriggered: root.passFlash = false
    onRunningChanged: if (running) root.passFlash = true
  }

  Timer {
    id: liftTimer
    interval: 250
    onTriggered: root.fingerPresent = false
  }

  Timer {
    id: closeTimer
    interval: 1800
    onTriggered: {
      if (root.pickerMode) root.showPicker()
      else root.dismiss()
    }
  }

  // Where the machine stands: "ready" (PAM on), "enroll" (packages in, PAM
  // off) or "install". Anything but ready starts the first-run flow.
  Process {
    id: statusProc
    command: ["omarchy-fingerprint-setup-helper", "status"]
    stdout: StdioCollector { id: statusStdout; waitForEnd: true }
    onExited: {
      var state = String(statusStdout.text || "").trim()
      if (!root.opened) return
      if (state === "enroll" || state === "install") root.showSetup()
      else root.showPicker()
    }
  }

  // The privileged steps: the helper re-runs itself through pkexec, which
  // shows the password prompt on screen. 126 = prompt dismissed, 127 = not
  // authorized.
  // Its output is English from shell scripts; the overlay shows its own
  // translated phase messages instead.
  Process {
    id: helperProc
    onExited: function(exitCode) {
      if (!root.opened) return
      if (root.phase === "installing") {
        if (exitCode === 0) {
          // fprintd may only now exist: ask the reader for its stage count
          // and start the finger-present watch that the first query missed.
          root.queryReader()
          if (root.enrolled.length > 0) {
            root.finger = root.enrolled[0]
            root.confirmTries = 0
            root.beginConfirm()
          } else {
            root.showPicker()
            root.message = I18n.t("fingerprint.chooseFirst", "Choose the finger to enroll first")
          }
        } else {
          root.showSetup()
          root.message = exitCode === 126 || exitCode === 127 ? I18n.t("fingerprint.setupCancelled", "Setup was cancelled") : I18n.t("fingerprint.setupFailed", "Setup failed. Check your internet connection and try again")
          errorFlashTimer.restart()
        }
      } else if (root.phase === "enabling") {
        if (exitCode === 0) {
          root.phase = "done"
          root.setupFlow = false
          root.message = I18n.t("fingerprint.loginOn", "Fingerprint login is on")
          root.hint = I18n.t("fingerprint.loginOnHint", "Use it for sudo, admin prompts and the lock screen. Add more fingers next")
          root.finish("ok")
          closeTimer.restart()
        } else {
          root.phase = "failed"
          root.failedStep = "enable"
          root.message = exitCode === 126 || exitCode === 127 ? I18n.t("fingerprint.turnOnCancelled", "Turning it on was cancelled") : I18n.t("fingerprint.turnOnFailed", "Could not turn on fingerprint login")
          root.hint = I18n.t("fingerprint.retryHint", "Press Enter to try again, Esc to close")
          errorFlashTimer.restart()
        }
      }
    }
  }

  // one touch against the print just enrolled, before PAM is switched on
  Process {
    id: verifyProc
    command: ["fprintd-verify", "-f", root.finger]
    stdout: SplitParser {
      onRead: function(line) {
        var m = String(line).match(/Verify result:\s*(\S+)/)
        if (!m || root.phase !== "confirm") return
        if (m[1] === "verify-match") {
          root.message = I18n.t("fingerprint.matched", "Matched")
          passFlashTimer.restart()
          root.beginEnable()
        } else if (m[1] === "verify-no-match") {
          errorFlashTimer.restart()
          if (root.confirmTries < root.confirmMaxTries) {
            retryConfirmTimer.restart()
          } else {
            root.phase = "failed"
            root.failedStep = "enroll"
            root.message = I18n.t("fingerprint.couldNotVerify", "Couldn't verify your %1").arg(root.fingerName(root.finger))
            root.hint = I18n.t("fingerprint.reenrollHint", "Press Enter to enroll it again, Esc to close")
          }
        }
      }
    }
    onExited: function(exitCode) {
      if (root.phase !== "confirm" || !root.opened) return
      if (exitCode !== 0 && !retryConfirmTimer.running) {
        root.phase = "failed"
        root.failedStep = "enroll"
        root.message = I18n.t("fingerprint.noResponse", "The reader did not respond")
        root.hint = I18n.t("fingerprint.reenrollHint", "Press Enter to enroll it again, Esc to close")
      }
    }
  }

  Timer {
    id: retryConfirmTimer
    interval: 900
    onTriggered: if (root.phase === "confirm") root.beginConfirm()
  }

  Process {
    id: listProc
    command: ["fprintd-list", root.user]
    stdout: StdioCollector { id: listStdout; waitForEnd: true }
    onExited: root.enrolled = EnrollModel.enrolledFromList(listStdout.text)
  }

  // Ask fprintd which device and how many stages it needs, so the fill is
  // honest, then watch that device for the finger landing and lifting.
  Process {
    id: stagesProc
    command: ["bash", "-c",
      "dev=$(busctl --system call net.reactivated.Fprint /net/reactivated/Fprint/Manager net.reactivated.Fprint.Manager GetDefaultDevice 2>/dev/null | sed -n 's/^o \"\\(.*\\)\"$/\\1/p'); " +
      "[[ -n $dev ]] || exit 1; n=$(busctl --system get-property net.reactivated.Fprint \"$dev\" net.reactivated.Fprint.Device num-enroll-stages 2>/dev/null | awk '{print $2}'); echo \"$dev $n\""]
    stdout: StdioCollector { id: stagesStdout; waitForEnd: true }
    onExited: {
      var parts = String(stagesStdout.text || "").trim().split(/\s+/)
      if (parts.length >= 1 && parts[0].indexOf("/") === 0) {
        root.devicePath = parts[0]
        if (root.opened && !monitorProc.running) monitorProc.running = true
      }
      var n = parseInt(parts[1] || "", 10)
      if (isFinite(n) && n > 0) root.totalStages = n
    }
  }

  // fprintd flips finger-present the moment the sensor sees skin, long
  // before a stage result exists; that is the feedback that makes the
  // overlay feel alive.
  Process {
    id: monitorProc
    command: ["gdbus", "monitor", "--system", "--dest", "net.reactivated.Fprint", "--object-path", root.devicePath]
    stdout: SplitParser {
      onRead: function(line) {
        var m = String(line).match(/'finger-present': <(true|false)>/)
        if (!m) return
        var present = m[1] === "true"
        // fprintd flips this per captured frame on some drivers; only a
        // lift that lasts is a lift
        if (present) {
          liftTimer.stop()
          if (!root.fingerPresent) {
            root.fingerPresent = true
            if (root.phase === "waiting") root.message = I18n.t("fingerprint.holdStill", "Hold still")
          }
        } else {
          liftTimer.restart()
        }
      }
    }
  }

  Process {
    id: enrollProc
    // No username: fprintd then enrolls the caller, which polkit allows
    // with the user's own password (auth_self_keep). Naming the user, even
    // yourself, trips the stricter setusername rule (auth_admin_keep).
    command: ["fprintd-enroll", "-f", root.finger]
    stdout: SplitParser {
      onRead: function(line) {
        var step = EnrollModel.stepForLine(line)
        if (step) {
          root.applyStep(step)
        } else if (/^Enrolling /.test(String(line))) {
          root.phase = "waiting"
          root.message = I18n.t("fingerprint.placeFinger", "Place the finger on the sensor")
          root.hint = root.pressHint(0)
        }
      }
    }
    stderr: SplitParser {
      onRead: function(line) {
        var step = EnrollModel.stepForLine(line)
        if (step && (step.kind === "failed" || step.kind === "cancelled")) root.applyStep(step)
      }
    }
    onExited: function(exitCode) {
      if (!root.opened) return
      if (root.phase !== "starting" && root.phase !== "waiting") return
      root.applyStep({ kind: "failed", message: EnrollModel.t("fingerprint.enrollStopped", "Enrollment stopped. Try again") })
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-fingerprint-enroll"

    Binding { target: panel.contentItem; property: "LayoutMirroring.enabled"; value: I18n.rightToLeft }
    Binding { target: panel.contentItem; property: "LayoutMirroring.childrenInherit"; value: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: Color.polkit.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: Style.cornerRadius
      anchors.centerIn: parent
      color: Color.polkit.background
      borderSpec: Border.surfaceSpec("polkit", root.errorFlash ? "border-error" : "border",
                                     root.errorFlash ? Color.polkit.borderError : Color.polkit.border,
                                     Math.max(1, Style.space(2)))
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.privileged) root.hint = I18n.t("fingerprint.pleaseWait", "Please wait until this finishes")
            else if (root.phase === "failed" && root.pickerMode) root.showPicker()
            else root.dismiss()
            event.accepted = true
            return
          }
          if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.phase !== "pick") {
            event.accepted = true
            if (root.phase === "setup") root.beginSetup()
            else if (root.phase === "failed" && root.setupFlow) {
              if (root.failedStep === "enable") root.beginEnable()
              else root.startEnroll(root.finger)
            }
            return
          }
          if (root.phase !== "pick") return
          event.accepted = true
          switch (event.key) {
          case Qt.Key_Up: root.pickMove(0, -1); break
          case Qt.Key_Down: root.pickMove(0, 1); break
          case Qt.Key_Left: root.pickHand = 0; break
          case Qt.Key_Right: root.pickHand = 1; break
          case Qt.Key_Tab: root.pickHand = 1 - root.pickHand; break
          case Qt.Key_Return: case Qt.Key_Enter: root.startEnroll(EnrollModel.fingerId(root.pickHand, root.pickFinger)); break
          default: event.accepted = false
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.space(14)

        Text {
          textFormat: Text.PlainText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          text: root.phase === "pick" ? I18n.t("fingerprint.title.picker", "Fingerprints")
              : (root.phase === "checking" || root.phase === "setup" || root.phase === "installing" || root.phase === "enabling") ? I18n.t("fingerprint.title.login", "Fingerprint login")
              : root.phase === "confirm" ? I18n.t("fingerprint.title.confirm", "Confirm your %1").arg(root.fingerName(root.finger))
              : I18n.t("fingerprint.title.enroll", "Enroll your %1").arg(root.fingerName(root.finger))
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
        }

        // Finger picker: two hands side by side, enrolled fingers marked.
        Row {
          id: picker
          visible: root.phase === "pick"
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(24)

          Repeater {
            model: 2
            Column {
              id: handColumn
              required property int index
              spacing: Style.space(4)

              Text {
                textFormat: Text.PlainText
                width: Style.space(140)
                horizontalAlignment: Text.AlignHCenter
                text: handColumn.index === 0 ? I18n.t("fingerprint.hand.left", "Left hand") : I18n.t("fingerprint.hand.right", "Right hand")
                color: root.foreground
                opacity: 0.66
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }

              Repeater {
                model: 5
                Rectangle {
                  id: fingerRow
                  required property int index
                  readonly property string fingerId: EnrollModel.fingerId(handColumn.index, index)
                  readonly property bool selected: root.pickHand === handColumn.index && root.pickFinger === index
                  width: Style.space(140)
                  height: Style.space(30)
                  radius: Style.cornerRadius
                  color: selected ? Color.menu.selectedBackground : "transparent"

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(10)
                    anchors.rightMargin: Style.space(10)
                    spacing: Style.space(8)

                    Text {
                      textFormat: Text.PlainText
                      anchors.verticalCenter: parent.verticalCenter
                      text: root.isEnrolled(fingerRow.fingerId) ? "󰈷" : "󰈸"
                      color: root.isEnrolled(fingerRow.fingerId) ? root.accent : Util.alpha(root.foreground, 0.35)
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.body
                    }
                    Text {
                      textFormat: Text.PlainText
                      anchors.verticalCenter: parent.verticalCenter
                      text: [
                        I18n.t("fingerprint.short.thumb", "Thumb"),
                        I18n.t("fingerprint.short.index", "Index"),
                        I18n.t("fingerprint.short.middle", "Middle"),
                        I18n.t("fingerprint.short.ring", "Ring"),
                        I18n.t("fingerprint.short.little", "Little")
                      ][fingerRow.index]
                      color: fingerRow.selected ? Color.menu.selectedText : root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.body
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { root.pickHand = handColumn.index; root.pickFinger = fingerRow.index }
                    onClicked: root.startEnroll(fingerRow.fingerId)
                  }
                }
              }
            }
          }
        }

        // The print: thin ridges that fill in scattered order per accepted
        // press; brighter and slightly larger while the finger is down.
        FingerprintGlyph {
          id: glyph
          visible: root.phase !== "pick"
          width: Math.round(root.glyphSize * 0.74)
          height: root.glyphSize
          anchors.horizontalCenter: parent.horizontalCenter
          progress: root.progress
          scanning: root.fingerPresent
          ridgeColor: root.errorFlash ? Util.alpha(root.errorColor, 0.55) : root.dimGlyph
          fillColor: root.errorFlash ? root.errorColor : root.accent
          scale: root.fingerPresent ? 1.03 : 1.0
          Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          visible: root.phase === "starting" || root.phase === "waiting" || root.phase === "done" || root.phase === "failed"
          text: root.phase === "done" ? I18n.t("fingerprint.done", "Done") : root.phase === "failed" ? I18n.t("fingerprint.failed", "Failed")
              : I18n.t("fingerprint.stageCount", "%1 of %2").arg(I18n.formatNumber(root.stagesPassed)).arg(I18n.formatNumber(root.totalStages))
          color: root.errorFlash ? root.errorColor : root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          text: root.message
          color: root.errorFlash ? root.errorColor : root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          text: root.hint
          color: root.foreground
          opacity: 0.66
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
