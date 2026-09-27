import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Opened by faceauthd (root) through `omarchy-shell shell summon omarchy.faceauth`
// for every elevation request, so no sudo or polkit request can proceed without
// a window on the desktop. It informs and it can kill; it cannot approve. The
// approval is a nod the daemon watches for on its own camera, or the account
// password typed here and checked by the daemon against the system PAM stack.
// The window stays until the request is approved, refused, dismissed or the
// requester killed; it never times out on its own while a request is live.
Item {
  id: root

  property bool opened: false
  property string state: ""
  property string message: ""
  property var caller: ({})
  property real seconds: 0
  property var blocked: ({})   // exe path -> until (ms since epoch)

  readonly property string fontFamily: Style.font.menuFamily
  readonly property color background: Color.polkit.background
  readonly property color foreground: Color.polkit.text
  readonly property color accent: Color.polkit.accent
  readonly property color scrim: Color.polkit.scrim
  readonly property var borderSpec: Border.surfaceSpec("polkit", "border", Color.polkit.border, Math.max(1, Style.space(2)), "border-alpha")
  readonly property int cornerRadius: Style.cornerRadius
  readonly property int cardWidth: Math.min(Style.space(560), panel.width - Style.gapsOut * 2)

  readonly property string requesterLine: {
    var c = root.caller || {}
    var who = c.via ? String(c.via) : "unknown"
    var pid = c.kill_pid ? String(c.kill_pid) : (c.pid ? String(c.pid) : "?")
    return who + " (pid " + pid + ")" + (c.parents ? "  from  " + c.parents : "")
  }

  // The window owns its own lifetime. A final state lingers long enough to be
  // read (an approval briefly, a refusal longer so kill/block can still be
  // used); a live state stays up for the daemon, and if the daemon dies or
  // its hide call is lost the window still closes itself.
  Timer {
    id: autoClose
    interval: 30000
    repeat: false
    onTriggered: root.close()
  }

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(String(payloadJson || "{}")) } catch (e) { payload = {} }
    root.state = String(payload.state || "")
    // Pending states and refusals stay until a verdict, a button or Escape;
    // only an approval fades on its own. The long interval is a safety net for
    // a daemon that died mid-request.
    autoClose.interval = root.state === "approved" ? 700 : 300000
    autoClose.restart()
    root.message = String(payload.message || "")
    root.caller = payload.caller || {}
    root.seconds = Number(payload.seconds || 0)
    var exe = String(root.caller.exe || "")
    var until = root.blocked[exe] || 0
    if (exe.length > 0 && until > Date.now()) {
      // Blocked earlier: kill without showing anything.
      console.log("omarchy faceauth: blocked requester " + exe + ", killing pid " + root.caller.kill_pid)
      root.killRequester()
      return
    }
    var first = !root.opened
    root.opened = true
    // Focus the password field on the first open only; a state change while
    // the user is typing must not steal the field.
    if (first) Qt.callLater(function() { passwordField.forceActiveFocus() })
  }

  readonly property bool pending: root.state === "scanning" || root.state === "nod" || root.state === "password" || root.state === "locked"

  function close() {
    autoClose.stop()
    if (root.pending) root.answer(["--dismiss"], "")
    root.opened = false
    passwordField.text = ""
  }

  // Send an answer for the pending request to the daemon: a dismissal, or
  // the password over stdin (never argv). The daemon accepts it only while
  // this user's request is live, and only from this user's own uid.
  function answer(args, secret) {
    answerProc.secret = secret
    answerProc.command = ["faceauth", "consent-answer"].concat(args)
    answerProc.running = true
  }

  function submitPassword() {
    var pw = passwordField.text
    if (pw.length === 0 || !root.pending) return
    passwordField.text = ""
    root.answer([], pw)
  }

  Process {
    id: answerProc
    property string secret: ""
    stdinEnabled: true
    onStarted: {
      if (secret.length > 0) write(secret + "\n")
      secret = ""
    }
  }

  function killRequester() {
    var pid = Number((root.caller || {}).kill_pid || 0)
    if (pid > 1) {
      killProc.command = ["kill", "-TERM", String(pid)]
      killProc.running = true
    }
    root.close()
  }

  function blockRequester() {
    var exe = String((root.caller || {}).exe || "")
    if (exe.length > 0) {
      var b = root.blocked
      b[exe] = Date.now() + 10 * 60 * 1000
      root.blocked = b
    }
    root.killRequester()
  }

  Process { id: killProc }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-faceauth"
    WlrLayershell.layer: WlrLayer.Overlay
    // Never exclusive: this window informs and offers kill/block; it must not
    // be able to hold the keyboard hostage if the daemon fails to hide it.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    Rectangle { anchors.fill: parent; color: root.scrim }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: column.implicitHeight + Style.spacing.panelPadding * 2
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: Style.spacing.panelPadding

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            root.close()
            event.accepted = true
          }
        }
      }

      Column {
        id: column
        anchors.fill: parent
        anchors.margins: Style.spacing.panelPadding
        spacing: Style.spacing.md

        Text {
          width: parent.width
          text: "Root access requested"
          color: root.accent
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          width: parent.width
          text: String((root.caller || {}).command || "")
          textFormat: Text.PlainText
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          wrapMode: Text.Wrap
          maximumLineCount: 3
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: root.requesterLine
          textFormat: Text.PlainText
          color: root.foreground
          opacity: 0.6
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }

        Rectangle { width: parent.width; height: 1; color: root.foreground; opacity: 0.15 }

        Row {
          spacing: Style.spacing.md
          width: parent.width

          Text {
            text: root.state === "approved" ? "󰖎" : (root.state === "denied" ? "󰅙" : "󰵃")
            textFormat: Text.PlainText
            color: root.state === "denied" ? Color.polkit.textError : root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            width: parent.width - Style.space(48)
            text: root.message
            textFormat: Text.PlainText
            color: root.state === "denied" ? Color.polkit.textError : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.Wrap
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        TextField {
          id: passwordField
          width: parent.width
          visible: root.pending
          password: true
          placeholderText: "Password (instead of the nod)"
          foreground: root.foreground
          accent: root.accent
          font.family: root.fontFamily
          onAccepted: root.submitPassword()
          Keys.onEscapePressed: root.close()
        }

        Row {
          spacing: Style.spacing.sm
          anchors.right: parent.right

          Button {
            text: "Deny and kill"
            bordered: true
            foreground: Color.polkit.textError
            accent: Color.polkit.textError
            fontFamily: root.fontFamily
            onClicked: root.killRequester()
          }

          Button {
            text: "Block 10 min"
            bordered: true
            foreground: Color.polkit.textError
            accent: Color.polkit.textError
            fontFamily: root.fontFamily
            onClicked: root.blockRequester()
          }

          Button {
            text: "Dismiss"
            bordered: true
            foreground: root.foreground
            accent: root.accent
            fontFamily: root.fontFamily
            onClicked: root.close()
          }
        }
      }
    }
  }
}
