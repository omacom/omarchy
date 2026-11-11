import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The parent's side of screen time: the minutes, a pause, the lock, and the
// settings window, each behind a grown-up's password. An authentication
// service, so it has no parent in the shell's scene and no entry in its
// service map: the password typed here is not a property a third-party bar
// widget can walk to, the same way the polkit agent keeps its password to
// itself. The bar widget asks for this window over IPC (omarchy-shell
// screen-time-parent open), which is the only way in.
Item {
  id: root

  property var shell: null

  // Status comes from the kid's own service, which is public: nothing in it
  // is secret, it is what the daemon publishes to the account anyway.
  readonly property var statusService: shell && shell.firstPartyServiceFor ? shell.firstPartyServiceFor("omarchy.screen-time") : null
  readonly property bool connected: statusService ? statusService.connected === true : false
  readonly property string phase: statusService ? String(statusService.phase) : ""
  readonly property bool together: statusService ? statusService.philosophy === "together" : false

  property string fontFamily: Style.font.menuFamily
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

  readonly property bool lightTheme: {
    var bg = Commons.Color.background
    return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) > 0.5
  }
  readonly property color okColor: lightTheme ? "#3C7C4E" : "#5FA46B"
  readonly property color blockColor: lightTheme ? "#B03434" : "#E06C6C"
  readonly property string iconLock: "\uf023"
  readonly property string iconGear: "\uf013"
  readonly property string iconPause: "\uf04c"
  readonly property string iconPlay: "\uf04b"

  // The window's state. "controls" is the drawer; "password" asks for a
  // grown-up's password for the one action in `pendingArgs`. The password
  // is never kept: it goes from the field to that one request's stdin.
  property bool open: false
  property string mode: "controls"
  property var pendingArgs: []
  property string pendingLabel: ""
  property bool submitted: false
  property bool errorFlash: false
  property string note: ""
  property color noteColor: foreground
  property int shakeOffset: 0

  readonly property bool dialogVisible: open
  readonly property bool settingsOpen: settingsWindow.opened

  function show(target) {
    if (target === "settings") {
      settingsWindow.show()
      return
    }
    note = ""
    reset()
    open = true
    refocus()
  }

  function reset() {
    mode = "controls"
    pendingArgs = []
    pendingLabel = ""
    submitted = false
    errorFlash = false
    passwordInput.text = ""
  }

  function dismiss() {
    open = false
    note = ""
    reset()
  }

  function refocus() {
    if (!open) return
    if (mode === "password") passwordInput.forceActiveFocus()
    else keyCatcher.forceActiveFocus()
  }

  // An action asks for the password first, except in agreement mode, which
  // the daemon lets through without one.
  function request(args, label) {
    if (actionProc.running) return
    note = ""
    pendingArgs = args
    pendingLabel = label
    if (together) {
      run("")
      return
    }
    mode = "password"
    refocus()
  }

  function submitPassword() {
    if (submitted || mode !== "password") return
    var password = passwordInput.text
    if (password === "") return
    passwordInput.text = ""
    submitted = true
    run(password)
  }

  function run(password) {
    actionProc.secret = password
    actionProc.label = pendingLabel
    actionProc.command = ["/usr/bin/omarchy-screen-time", "--password-stdin"].concat(pendingArgs)
    actionProc.running = true
  }

  function failPassword(message) {
    passwordInput.text = ""
    submitted = false
    note = message
    noteColor = blockColor
    errorFlash = true
    shake.restart()
    flashTimer.restart()
  }

  function grant(minutes) {
    request(["grant", String(minutes)], I18n.t("screenTime.grantedMinutes").arg(minutes))
  }

  function togglePause() {
    if (phase === "paused") request(["resume"], I18n.t("screenTime.resumed"))
    else request(["pause"], I18n.t("screenTime.paused"))
  }

  function lockNow() {
    request(["lock"], I18n.t("screenTime.locked"))
  }

  // Saving there takes the password, not opening it: what it shows is the
  // status the account can already read.
  function openSettings() {
    settingsWindow.show()
    dismiss()
  }

  Timer {
    id: flashTimer
    interval: 900
    onTriggered: { root.errorFlash = false; root.refocus() }
  }

  SequentialAnimation {
    id: shake
    NumberAnimation { target: root; property: "shakeOffset"; to: -8; duration: Style.duration(35); easing.type: Easing.OutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 8; duration: Style.duration(50); easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: Style.duration(55); easing.type: Easing.OutQuad }
  }

  Process {
    id: actionProc
    property string secret: ""
    property string label: ""
    stdinEnabled: true
    onStarted: {
      write(secret + "\n")
      secret = ""
    }
    onRunningChanged: if (!running) secret = ""
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        root.submitted = false
        try { payload = JSON.parse(text) } catch (e) { root.failPassword(I18n.t("screenTime.unreachable")); return }
        if (payload.ok === true) {
          root.reset()
          root.note = actionProc.label
          root.noteColor = root.okColor
          root.refocus()
        } else if (payload.error === "bad_password") {
          root.failPassword(I18n.t("screenTime.notAdultPassword"))
        } else if (payload.error === "locked_out") {
          root.failPassword(I18n.t("screenTime.tooManyTries").arg(payload.retry_in_seconds))
        } else {
          root.reset()
          root.note = payload.error ? String(payload.error) : I18n.t("screenTime.failed")
          root.noteColor = root.blockColor
        }
      }
    }
  }

  SettingsWindow {
    id: settingsWindow
    service: root.statusService
    clientPath: "/usr/bin/omarchy-screen-time"
  }

  ShellIpc {
    target: "screen-time-parent"

    function open(): string {
      if (!root.connected) return "not-running"
      root.show("controls")
      return "ok"
    }

    function openSettings(): string {
      if (!root.connected) return "not-running"
      root.show("settings")
      return "ok"
    }

    function close(): string {
      root.dismiss()
      settingsWindow.close()
      return "ok"
    }
  }

  readonly property int cardWidth: Math.min(Style.space(340), Math.max(Style.space(280), panel.width - Style.gapsOut * 2))

  PanelWindow {
    id: panel
    visible: root.dialogVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-screen-time-parent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    // Clicking off the card closes it, and with it anything typed.
    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: cardColumn.implicitHeight + root.contentMargin * 2
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
          if (event.key === Qt.Key_Escape) { root.dismiss(); event.accepted = true }
        }
      }

      Column {
        id: cardColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: card.contentTopInset
        anchors.leftMargin: card.contentLeftInset
        anchors.rightMargin: card.contentRightInset
        spacing: Style.space(12)

        Item {
          width: parent.width
          implicitHeight: titleRow.implicitHeight

          Row {
            id: titleRow
            spacing: Style.space(10)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

          Text {
            textFormat: Text.PlainText
            text: root.iconLock
            color: root.errorFlash ? Commons.Color.polkit.textError : root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            textFormat: Text.PlainText
            // The title says what is going on: the parent is usually here
            // because the time ran out, so that is the first thing it says.
            text: root.phase === "empty" ? I18n.t("screenTime.titleUp")
              : root.phase === "bedtime" ? I18n.t("screenTime.titleBlocked")
              : root.phase === "paused" ? I18n.t("screenTime.titlePaused")
              : I18n.t("screenTime.title")
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
          }

          // The way out, top right, once the controls are open.
          Button {
            visible: root.mode === "controls"
            text: I18n.t("screenTime.done")
            focusable: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.dismiss()
          }
        }

        // One line under the title: what the controls take, or which one
        // the password is for.
        Text {
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.mode === "password" ? root.pendingLabel : I18n.t("screenTime.controlsHint")
          visible: root.mode === "password" || !root.together
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.6)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        // --- the password, in a box of its own --------------------------------
        Rectangle {
          visible: root.mode === "password"
          width: parent.width
          height: root.fieldHeight
          radius: root.cornerRadius
          color: passwordInput.activeFocus && !root.errorFlash
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12) : "transparent"
          border.width: 1
          border.color: root.errorFlash ? Commons.Color.polkit.textError
            : (passwordInput.activeFocus ? root.accent : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25))
          Behavior on color { ColorAnimation { duration: Style.duration(100) } }

          TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            clip: true
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            selectionColor: Util.alpha(root.accent, 0.45)
            selectedTextColor: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            echoMode: TextInput.Password
            passwordCharacter: "•"
            color: root.errorFlash ? Commons.Color.polkit.textError : root.foreground
            cursorVisible: activeFocus && !root.submitted && !root.errorFlash
            readOnly: root.submitted || root.errorFlash
            enabled: root.dialogVisible
            onAccepted: root.submitPassword()
            // Escape steps back to the controls rather than closing them.
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) { root.reset(); root.refocus(); event.accepted = true }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: root.submitted ? I18n.t("screenTime.checking") : I18n.t("screenTime.adultPassword")
            color: root.errorFlash ? Commons.Color.polkit.textError : root.foreground
            opacity: root.errorFlash ? 1 : 0.36
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
            visible: passwordInput.text.length === 0
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: passwordInput.forceActiveFocus()
          }
        }

        // --- the controls -----------------------------------------------
        Column {
          visible: root.mode === "controls"
          width: parent.width
          spacing: Style.space(12)

          // Minutes: one bar of three, to hand out.
          Column {
            width: parent.width
            spacing: Style.space(4)

            Text {
              textFormat: Text.PlainText
              text: I18n.t("screenTime.minutes")
              color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.6)
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Rectangle {
              width: parent.width
              height: Style.space(36)
              radius: root.cornerRadius
              color: "transparent"
              border.width: 1
              border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25)
              clip: true

              Row {
                anchors.fill: parent
                anchors.margins: 1

                Repeater {
                  model: [{ label: "+ 5", minutes: 5 }, { label: "+ 15", minutes: 15 }, { label: "+ 30", minutes: 30 }]

                  delegate: Item {
                    id: minuteCell
                    required property var modelData
                    required property int index
                    width: parent.width / 3
                    height: parent.height
                    activeFocusOnTab: true
                    Keys.onPressed: function(event) {
                      if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.grant(minuteCell.modelData.minutes); event.accepted = true
                      }
                    }

                    Rectangle {
                      anchors.fill: parent
                      color: minuteArea.pressed
                        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3)
                        : (minuteArea.containsMouse || minuteCell.activeFocus
                           ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14) : "transparent")
                      Behavior on color { ColorAnimation { duration: Style.duration(80) } }
                    }

                    Rectangle {
                      visible: minuteCell.index > 0
                      width: 1
                      height: parent.height
                      anchors.left: parent.left
                      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
                    }

                    Text {
                      textFormat: Text.PlainText
                      anchors.centerIn: parent
                      text: minuteCell.modelData.label
                      color: root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.body
                      font.bold: true
                    }

                    MouseArea {
                      id: minuteArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.grant(minuteCell.modelData.minutes)
                    }
                  }
                }
              }
            }
          }

          // The rest as bordered buttons with a glyph each, so they read
          // as things to press and not as words in a row.
          Row {
            id: actionRow
            width: parent.width
            spacing: Style.space(8)
            readonly property int third: Math.floor((width - spacing * 2) / 3)

            Button {
              width: actionRow.third
              iconText: root.phase === "paused" ? root.iconPlay : root.iconPause
              text: root.phase === "paused" ? I18n.t("screenTime.resume") : I18n.t("screenTime.pause")
              bordered: true
              focusable: true
              onClicked: root.togglePause()
            }
            Button {
              width: actionRow.third
              iconText: root.iconLock
              text: I18n.t("screenTime.lockNow")
              bordered: true
              focusable: true
              onClicked: root.lockNow()
            }
            Button {
              width: actionRow.third
              iconText: root.iconGear
              text: I18n.t("screenTime.settings")
              bordered: true
              focusable: true
              onClicked: root.openSettings()
            }
          }

        }

        Text {
          textFormat: Text.PlainText
          visible: root.note !== ""
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.note
          color: root.noteColor
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
