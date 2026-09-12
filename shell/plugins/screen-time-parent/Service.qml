import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// The parent's side of screen time: the PIN, the minutes, a pause, the lock,
// and the settings window. An authentication service, so it has no parent in
// the shell's scene and no entry in its service map: the PIN a parent types
// here is not a property a third-party bar widget can walk to, the same way
// the polkit agent keeps the parent password to itself. The bar widget asks
// for this window over IPC (omarchy-shell screen-time-parent open), which is
// the only way in.
Item {
  id: root

  property var shell: null

  // Status comes from the kid's own service, which is public: nothing in it
  // is secret, it is what the daemon publishes to the account anyway.
  readonly property var statusService: shell && shell.firstPartyServiceFor ? shell.firstPartyServiceFor("omarchy.screen-time") : null
  readonly property bool connected: statusService ? statusService.connected === true : false
  readonly property string phase: statusService ? String(statusService.phase) : ""
  readonly property bool together: statusService ? statusService.philosophy === "together" : false
  readonly property bool pinMissing: connected && statusService !== null && statusService.pinSet !== true

  property string fontFamily: Style.font.menuFamily
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

  readonly property bool lightTheme: {
    var bg = Color.background
    return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) > 0.5
  }
  readonly property color okColor: lightTheme ? "#3C7C4E" : "#5FA46B"
  readonly property color blockColor: lightTheme ? "#B03434" : "#E06C6C"
  readonly property string iconLock: "\uf023"
  readonly property string iconGear: "\uf013"
  readonly property string iconPause: "\uf04c"
  readonly property string iconPlay: "\uf04b"

  // The window's state. "pin" asks; "controls" is the drawer; "missing" says
  // there is no PIN and names the command. `after` is where a successful
  // PIN leads: the controls, or straight to the settings window.
  property bool open: false
  property string mode: "pin"
  property string after: "controls"
  property string parentPin: ""
  property bool submitted: false
  property bool errorFlash: false
  property string note: ""
  property color noteColor: foreground
  property int shakeOffset: 0

  readonly property bool dialogVisible: open
  readonly property bool settingsOpen: settingsWindow.opened

  function show(target) {
    after = target
    note = ""
    submitted = false
    errorFlash = false
    parentPin = ""
    pinInput.text = ""
    if (pinMissing) {
      // Agreement mode has nothing to gate, so the settings open outright.
      if (together && target === "settings") {
        settingsWindow.show("")
        return
      }
      mode = "missing"
    } else {
      mode = "pin"
    }
    open = true
    refocus()
  }

  function dismiss() {
    open = false
    parentPin = ""
    pinInput.text = ""
    note = ""
    submitted = false
    errorFlash = false
    mode = "pin"
  }

  function refocus() {
    if (!open) return
    if (mode === "pin") pinInput.forceActiveFocus()
    else keyCatcher.forceActiveFocus()
  }

  function submitPin() {
    if (submitted || mode !== "pin") return
    var pin = pinInput.text.trim()
    if (pin === "") return
    parentPin = pin
    submitted = true
    unlockProc.running = true
  }

  function failPin(message) {
    parentPin = ""
    pinInput.text = ""
    submitted = false
    note = message
    noteColor = blockColor
    errorFlash = true
    shake.restart()
    flashTimer.restart()
  }

  function unlocked() {
    submitted = false
    note = ""
    pinInput.text = ""
    if (after === "settings") {
      settingsWindow.show(parentPin)
      open = false
      // The settings window holds its own copy for its patches; this one is
      // done with it.
      parentPin = ""
      return
    }
    mode = "controls"
    refocus()
  }

  function grant(minutes) {
    if (actionProc.running) return
    actionProc.command = ["omarchy-screen-time", "--pin-stdin", "grant", String(minutes)]
    actionProc.pendingLabel = (minutes > 0 ? "+" : "") + minutes + " minutes"
    actionProc.running = true
  }

  function togglePause() {
    if (actionProc.running) return
    var cmd = phase === "paused" ? "resume" : "pause"
    actionProc.command = ["omarchy-screen-time", "--pin-stdin", cmd]
    actionProc.pendingLabel = cmd === "pause" ? "paused" : "resumed"
    actionProc.running = true
  }

  function lockNow() {
    if (actionProc.running) return
    actionProc.command = ["omarchy-screen-time", "--pin-stdin", "lock"]
    actionProc.pendingLabel = "locked"
    actionProc.running = true
  }

  function openSettings() {
    settingsWindow.show(parentPin)
    dismiss()
  }

  Timer {
    id: flashTimer
    interval: 900
    onTriggered: { root.errorFlash = false; root.refocus() }
  }

  SequentialAnimation {
    id: shake
    NumberAnimation { target: root; property: "shakeOffset"; to: -8; duration: 35; easing.type: Easing.OutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 8; duration: 50; easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 55; easing.type: Easing.OutQuad }
  }

  // Proving the PIN is a read the daemon gates: config get answers ok on the
  // right PIN and bad_pin or pin_locked_out otherwise, and changes nothing.
  Process {
    id: unlockProc
    command: ["omarchy-screen-time", "--pin-stdin", "config", "get"]
    stdinEnabled: true
    onStarted: write(root.parentPin + "\n")
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { root.failPin("Could not reach screen time."); return }
        if (payload.ok === true) root.unlocked()
        else if (payload.error === "pin_locked_out") root.failPin("Too many tries. Wait " + payload.retry_in_seconds + "s.")
        else if (payload.error === "no_pin_set") { root.mode = "missing"; root.submitted = false }
        else root.failPin("That is not the PIN.")
      }
    }
  }

  Process {
    id: actionProc
    property string pendingLabel: ""
    stdinEnabled: true
    onStarted: write(root.parentPin + "\n")
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        if (payload.ok === true) {
          root.note = actionProc.pendingLabel
          root.noteColor = root.okColor
        } else if (payload.error === "pin_locked_out" || payload.error === "bad_pin") {
          // The PIN changed under us, or the daemon locked it: back to the
          // field rather than a drawer that no longer works.
          root.mode = "pin"
          root.failPin(payload.error === "bad_pin" ? "The PIN changed. Enter it again." : "Too many tries. Wait " + payload.retry_in_seconds + "s.")
        } else {
          root.note = String(payload.error || "failed")
          root.noteColor = root.blockColor
        }
      }
    }
  }

  SettingsWindow {
    id: settingsWindow
    service: root.statusService
    clientPath: "omarchy-screen-time"
  }

  IpcHandler {
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

    // Clicking off the card closes it, and with it the PIN.
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
            color: root.errorFlash ? Color.polkit.textError : root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            textFormat: Text.PlainText
            // The title says what is going on: the parent is usually here
            // because the time ran out, so that is the first thing it says.
            text: root.mode === "missing" ? "No PIN yet"
              : root.phase === "empty" ? "Screen time is up"
              : root.phase === "bedtime" ? "Screen time is blocked"
              : root.phase === "paused" ? "Screen time is paused"
              : "Screen time"
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
            text: "Done"
            focusable: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.dismiss()
          }
        }

        // One line under the title that says what the PIN opens.
        Text {
          visible: root.mode === "pin"
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.WordWrap
          text: "Enter the parent PIN for extra minutes, a pause, the lock, or the settings."
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.6)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        // --- no PIN ------------------------------------------------------
        Text {
          visible: root.mode === "missing"
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.WordWrap
          text: "Nobody can hand out minutes until a parent sets a PIN from a terminal:\n\nsudo omarchy-parent screen-time pin set"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        // --- the PIN, in a box of its own -----------------------------------
        Rectangle {
          visible: root.mode === "pin"
          width: parent.width
          height: root.fieldHeight
          radius: root.cornerRadius
          color: pinInput.activeFocus && !root.errorFlash
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12) : "transparent"
          border.width: 1
          border.color: root.errorFlash ? Color.polkit.textError
            : (pinInput.activeFocus ? root.accent : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25))
          Behavior on color { ColorAnimation { duration: 100 } }

          TextInput {
            id: pinInput
            anchors.fill: parent
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            clip: true
            inputMethodHints: Qt.ImhDigitsOnly
            selectionColor: Util.alpha(root.accent, 0.45)
            selectedTextColor: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            echoMode: TextInput.Password
            passwordCharacter: "•"
            color: root.errorFlash ? Color.polkit.textError : root.foreground
            cursorVisible: activeFocus && !root.submitted && !root.errorFlash
            readOnly: root.submitted || root.errorFlash
            enabled: root.dialogVisible
            onAccepted: root.submitPin()
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) { root.dismiss(); event.accepted = true }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: root.errorFlash ? "Wrong" : (root.submitted ? "Checking..." : "PIN")
            color: root.errorFlash ? Color.polkit.textError : root.foreground
            opacity: root.errorFlash ? 1 : 0.36
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
            elide: Text.ElideRight
            visible: pinInput.text.length === 0
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: pinInput.forceActiveFocus()
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
              text: "Minutes"
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
                      Behavior on color { ColorAnimation { duration: 80 } }
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
              text: root.phase === "paused" ? "Resume" : "Pause"
              bordered: true
              focusable: true
              onClicked: root.togglePause()
            }
            Button {
              width: actionRow.third
              iconText: root.iconLock
              text: "Lock now"
              bordered: true
              focusable: true
              onClicked: root.lockNow()
            }
            Button {
              width: actionRow.third
              iconText: root.iconGear
              text: "Settings"
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
