import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#1a1b26"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  // The greeter runs under Hyprland, where keyboard.capsLock never moves, so
  // read Caps Lock off the keys instead: a letter typed in the wrong case gives
  // it away, and the Caps Lock key flips what we know. Until a letter has been
  // typed the state is unknown and the icon stays hidden.
  property bool capsLockKnown: false
  property bool capsLockTyped: false

  function trackCapsLock(key, text, modifiers, autoRepeat) {
    if (autoRepeat)
      return
    if (key === Qt.Key_CapsLock) {
      if (capsLockKnown)
        capsLockTyped = !capsLockTyped
      return
    }
    // Only a letter whose two cases map to each other tells us anything. That
    // drops AZERTY's Shift+* micro sign µ, whose capital is Greek Μ, and also
    // that Μ, which Caps Lock turns the µ into.
    var lower = text.toLowerCase()
    var upper = text.toUpperCase()
    if (text.length !== 1 || lower === upper || upper.toLowerCase() !== lower
        || lower.toUpperCase() !== upper || upper === "Μ")
      return
    // A capital without Shift, or a lowercase letter with it, means Caps Lock.
    capsLockTyped = (text === text.toUpperCase()) !== ((modifiers & Qt.ShiftModifier) !== 0)
    capsLockKnown = true
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.focus = true
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: 40

    Image {
      id: logo
      source: "logo.png"
      width: Math.min(sourceSize.width, root.width * 0.8)
      height: sourceSize.width > 0 ? Math.round(width * sourceSize.height / sourceSize.width) : 0
      fillMode: Image.PreserveAspectFit
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 15

      Image {
        source: root.loginFailed ? "lock-failed.png" : "lock.png"
        width: 34
        height: 38
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
      }

      Item {
        width: entry.width
        height: entry.height

        Image {
          id: entry
          source: root.loginFailed ? "entry-failed.png" : "entry.png"
          anchors.centerIn: parent
        }

        Row {
          objectName: "passwordDots"
          anchors.left: parent.left
          anchors.leftMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Repeater {
            // Stop short of the Caps Lock icon so the dots never run under it.
            model: Math.min(password.text.length, capsLockIcon.visible ? 18 : 21)

            Image {
              source: "bullet.png"
              width: 7
              height: 7
            }
          }
        }

        // Caps Lock warning inside the field's right edge, in the red the
        // failed entry uses, so a mistyped password is no mystery.
        Text {
          id: capsLockIcon
          objectName: "capsLockIndicator"
          anchors.right: parent.right
          anchors.rightMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          visible: keyboard.capsLock || root.capsLockTyped
          text: "󰘲"
          color: "#f7768e"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
        }

        TextInput {
          id: password
          objectName: "passwordInput"
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          verticalAlignment: TextInput.AlignVCenter
          echoMode: TextInput.Password
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
          font.letterSpacing: 5
          passwordCharacter: "\u2022"
          color: "transparent"
          selectionColor: "transparent"
          selectedTextColor: "transparent"
          cursorDelegate: Item {}
          focus: true

          onTextChanged: root.loginFailed = false

          Keys.onPressed: {
            root.trackCapsLock(event.key, event.text, event.modifiers, event.isAutoRepeat)
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              sddm.login(root.currentUser, password.text, root.sessionIndex)
              event.accepted = true
            }
          }
        }
      }
    }

  }

  Component.onCompleted: password.forceActiveFocus()
}
