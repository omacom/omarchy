import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "EnrollModel.js" as EnrollModel

// Fingerprint enrolment overlay. Drives `fprintd-enroll` and turns its
// per-stage results into a print that fills in from the bottom, the way a
// phone does it, with a placement hint for the next press. Summon with:
//
//   omarchy-shell shell summon omarchy.fingerprint-enroll \
//     '{"finger":"right-index-finger","doneFile":"/tmp/x"}'
//
// When doneFile is given, "ok" or "failed" is written to it on exit so a
// script can wait on the result (the same round-trip the image picker uses).
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string finger: "right-index-finger"
  property string user: Quickshell.env("USER")
  property string doneFile: ""
  property int totalStages: 5
  property int stagesPassed: 0
  // idle | checking | setup | installing | starting | waiting | confirm |
  // enabling | done | failed | pick
  property string phase: "idle"
  // first-time flow: install, enrol, confirm with a touch, enable PAM
  property bool setupFlow: false
  property string helper: ""
  property int confirmTries: 0
  // picker state: hand 0 left / 1 right, finger 0 thumb .. 4 little
  property int pickHand: 1
  property int pickFinger: 1
  property var enrolled: []
  // true when opened without a finger: return to the picker after each
  // enrolment instead of closing
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

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }

    root.user = payload.user || Quickshell.env("USER")
    root.doneFile = payload.doneFile || ""
    if (payload.totalStages > 0) root.totalStages = payload.totalStages
    root.pickerMode = !EnrollModel.validFinger(payload.finger)
    root.setupFlow = false
    root.opened = true
    stagesProc.running = true

    if (root.pickerMode) {
      root.phase = "checking"
      root.message = "Checking fingerprint login"
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
    root.message = "Fingerprint login is off"
    root.hint = "Press Enter to turn it on. You will be asked for your password once"
    root.errorFlash = false
    listProc.running = true
  }

  function beginSetup() {
    root.phase = "installing"
    root.message = "Setting up"
    root.hint = ""
    helperProc.command = ["pkexec", root.helper, "install"]
    helperProc.running = true
  }

  readonly property int confirmMaxTries: 5

  function beginConfirm() {
    root.phase = "confirm"
    root.confirmTries += 1
    root.message = root.confirmTries === 1 ? "Touch the sensor once to confirm"
                 : "Didn't match, touch again (" + root.confirmTries + " of " + root.confirmMaxTries + ")"
    root.hint = "Press the way you normally would"
    root.fingerPresent = false
    verifyProc.running = true
  }

  function beginEnable() {
    root.phase = "enabling"
    root.message = "Turning fingerprint login on"
    root.hint = ""
    helperProc.command = ["pkexec", root.helper, "enable-pam"]
    helperProc.running = true
  }

  function showPicker() {
    root.phase = "pick"
    root.message = root.setupFlow ? "Choose the finger to enrol first" : "Choose a finger to enrol"
    root.hint = "Arrow keys and Enter, or click. Esc closes"
    root.errorFlash = false
    listProc.running = true
  }

  function startEnroll(finger) {
    root.finger = finger
    root.stagesPassed = 0
    root.phase = "starting"
    root.message = "Starting the reader"
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

  function close() {
    root.opened = false
    if (enrollProc.running) enrollProc.signal(15)
    if (verifyProc.running) verifyProc.signal(15)
    if (monitorProc.running) monitorProc.signal(15)
  }

  function dismiss() {
    if (root.phase !== "done" && root.phase !== "failed") root.finish("failed")
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.fingerprint-enroll")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function finish(result) {
    if (root.doneFile) doneWriter.command = ["bash", "-c", "printf '%s\\n' \"$1\" > \"$2\"", "_", result, root.doneFile]
    if (root.doneFile) doneWriter.running = true
  }

  function applyStep(step) {
    if (!step) return
    switch (step.kind) {
    case "passed":
      root.stagesPassed += 1
      root.phase = "waiting"
      root.message = step.message
      root.hint = EnrollModel.placementHint(root.stagesPassed, root.totalStages)
      passFlashTimer.restart()
      break
    case "retry":
      root.phase = "waiting"
      root.message = step.message
      errorFlashTimer.restart()
      break
    case "done":
      if (root.setupFlow) {
        root.confirmTries = 0
        root.beginConfirm()
        break
      }
      root.phase = "done"
      root.message = step.message
      root.hint = EnrollModel.fingerLabel(root.finger) + " is ready for sudo, polkit and the lock screen"
      root.finish("ok")
      closeTimer.restart()
      break
    case "failed":
      root.phase = "failed"
      root.message = step.message
      root.hint = "Press Esc to close"
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

  // Which helper exists, and where the machine stands: "ready" (PAM on and
  // a finger enrolled elsewhere is irrelevant here), "enrol" (packages in,
  // PAM off), "install". Without a helper the widget only enrols.
  Process {
    id: statusProc
    command: ["bash", "-c",
      "for h in /usr/bin/omarchy-fingerprint-setup-helper /usr/local/bin/omarchy-fingerprint-setup-helper; do " +
      "[[ -x $h ]] && { echo \"$h $($h status 2>/dev/null)\"; exit 0; }; done; echo 'none ready'"]
    stdout: StdioCollector { id: statusStdout; waitForEnd: true }
    onExited: {
      var parts = String(statusStdout.text || "").trim().split(/\s+/)
      root.helper = parts[0] === "none" ? "" : parts[0]
      var state = parts[1] || "ready"
      if (!root.opened) return
      if (state === "ready" || !root.helper) root.showPicker()
      else root.showSetup()
    }
  }

  // root steps through polkit: one admin password, remembered a few minutes
  Process {
    id: helperProc
    stdout: SplitParser {
      onRead: function(line) {
        var t = String(line).trim()
        if (t) root.message = t
      }
    }
    onExited: function(exitCode) {
      if (!root.opened) return
      if (root.phase === "installing") {
        if (exitCode === 0) {
          if (root.enrolled.length > 0) {
            root.finger = root.enrolled[0]
            root.confirmTries = 0
            root.beginConfirm()
          } else {
            root.showPicker()
            root.message = "Choose the finger to enrol first"
          }
        } else {
          root.showSetup()
          root.message = exitCode === 126 || exitCode === 127 ? "Set-up was cancelled" : "Set-up failed (" + exitCode + ")"
          errorFlashTimer.restart()
        }
      } else if (root.phase === "enabling") {
        if (exitCode === 0) {
          root.phase = "done"
          root.setupFlow = false
          root.message = "Fingerprint login is on"
          root.hint = "Use it for sudo, the lock screen and admin prompts. Add more fingers next"
          root.finish("ok")
          closeTimer.restart()
        } else {
          root.phase = "failed"
          root.message = exitCode === 126 || exitCode === 127 ? "Turning it on was cancelled" : "Could not turn on fingerprint login (" + exitCode + ")"
          root.hint = "Press Enter to try again, Esc to close"
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
          root.message = "Matched"
          passFlashTimer.restart()
          root.beginEnable()
        } else if (m[1] === "verify-no-match") {
          errorFlashTimer.restart()
          if (root.confirmTries < root.confirmMaxTries) {
            retryConfirmTimer.restart()
          } else {
            root.phase = "failed"
            root.message = "Couldn't verify " + EnrollModel.fingerLabel(root.finger).toLowerCase()
            root.hint = "Press Enter to enrol it again with more coverage, Esc to close"
          }
        }
      }
    }
    onExited: function(exitCode) {
      if (root.phase !== "confirm" || !root.opened) return
      if (exitCode !== 0 && !retryConfirmTimer.running) {
        root.phase = "failed"
        root.message = "Verification did not run (" + exitCode + ")"
        root.hint = "Press Enter to enrol again, Esc to close"
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
        if (root.opened) monitorProc.running = true
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
            if (root.phase === "waiting") root.message = "Hold still"
          }
        } else {
          liftTimer.restart()
        }
      }
    }
  }

  Process {
    id: enrollProc
    // No username: fprintd then enrols the caller, which polkit allows
    // with the user's own password (auth_self_keep). Naming the user, even
    // yourself, trips the stricter setusername rule (auth_admin_keep).
    command: root.user && root.user !== Quickshell.env("USER")
      ? ["fprintd-enroll", "-f", root.finger, root.user]
      : ["fprintd-enroll", "-f", root.finger]
    stdout: SplitParser {
      onRead: function(line) {
        var step = EnrollModel.stepForLine(line)
        if (step) {
          root.applyStep(step)
        } else if (/^Enrolling /.test(String(line))) {
          root.phase = "waiting"
          root.message = "Place the finger on the sensor"
          root.hint = EnrollModel.placementHint(0, root.totalStages)
        }
      }
    }
    stderr: SplitParser {
      onRead: function(line) {
        var step = EnrollModel.stepForLine(line)
        if (step && step.kind === "failed") root.applyStep(step)
      }
    }
    onExited: function(exitCode) {
      if (!root.opened) return
      if (root.phase !== "starting" && root.phase !== "waiting") return
      root.applyStep({ kind: "failed", message: exitCode === 0 ? "Enrolment ended early" : "Enrolment failed (fprintd-enroll exited " + exitCode + ")" })
    }
  }

  Process {
    id: doneWriter
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-fingerprint-enroll"
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
            if (root.phase === "failed" && root.pickerMode) root.showPicker()
            else root.dismiss()
            event.accepted = true
            return
          }
          if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.phase !== "pick") {
            event.accepted = true
            if (root.phase === "setup") root.beginSetup()
            else if (root.phase === "failed" && root.setupFlow) {
              if (root.message.indexOf("turn on") !== -1 || root.message.indexOf("Turning") !== -1) root.beginEnable()
              else root.startEnroll(root.finger)
            }
            return
          }
          if (root.phase !== "pick") return
          event.accepted = true
          switch (event.key) {
          case Qt.Key_Up: root.pickMove(0, -1); break
          case Qt.Key_Down: root.pickMove(0, 1); break
          case Qt.Key_Left: root.pickMove(-1, 0); break
          case Qt.Key_Right: case Qt.Key_Tab: root.pickMove(root.pickHand === 1 ? -1 : 1, 0); break
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
          text: root.phase === "pick" ? "Fingerprints"
              : (root.phase === "checking" || root.phase === "setup" || root.phase === "installing" || root.phase === "enabling") ? "Fingerprint login"
              : root.phase === "confirm" ? "Confirm " + EnrollModel.fingerLabel(root.finger).toLowerCase()
              : "Enrol " + EnrollModel.fingerLabel(root.finger).toLowerCase()
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
                text: handColumn.index === 0 ? "Left hand" : "Right hand"
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
                      text: ["Thumb", "Index", "Middle", "Ring", "Little"][fingerRow.index]
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
          text: root.phase === "done" ? "Done" : root.phase === "failed" ? "Failed" : (root.stagesPassed + " of " + root.totalStages)
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
