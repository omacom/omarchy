import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#1a1b26"

  // A password alone, as at the disk prompt: it is tried for the last account
  // and then each other one until one logs in. omarchy-login-match ends an
  // attempt at once when the password is another account's, so only a
  // password that is nobody's counts as a failed login.
  property bool loginFailed: false
  property var candidates: []
  property int attempt: 0
  property string pending: ""
  property bool awaiting: false
  property int resends: 0
  // SDDM sends LoginFailed twice for one failure. The second is consumed as
  // such even if it arrives after the next account was sent, so it is never
  // taken for that account's answer.
  property int duplicates: 0

  function login() {
    var names = [userModel.lastUser]
    for (var i = 0; i < userNames.count; i++) {
      var name = userNames.itemAt(i) ? userNames.itemAt(i).userName : ""
      if (name && names.indexOf(name) === -1)
        names.push(name)
    }
    candidates = names.filter(function(name) { return !!name })
    if (candidates.length === 0)
      return
    pending = password.text
    attempt = 0
    resends = 0
    send()
  }

  function fail() {
    pending = ""
    awaiting = false
    password.text = ""
    loginFailed = true
    password.focus = true
  }

  function send() {
    awaiting = true
    sddm.login(candidates[attempt], pending, sessionIndex)
    unanswered.restart()
  }

  Repeater {
    id: userNames
    model: userModel

    Item {
      property string userName: model.name
    }
  }
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      if (root.duplicates > 0) {
        root.duplicates--
        return
      }
      root.duplicates = 1
      pairWindow.restart()
      if (!root.awaiting)
        return
      root.awaiting = false
      unanswered.stop()
      if (root.pending !== "" && root.attempt + 1 < root.candidates.length) {
        root.attempt++
        root.resends = 0
        nextAttempt.start()
        return
      }
      root.fail()
    }
    function onLoginSucceeded() {
      root.awaiting = false
      unanswered.stop()
      root.pending = ""
      root.loginFailed = false
    }
  }

  // SDDM reports a failure before its helper has exited, and silently drops a
  // login sent before then, so the next account waits a moment; an attempt
  // still unanswered after pam_unix's failure delay was dropped, and is sent
  // again, a few times at most. One sent while the first is still running is
  // dropped the same way.
  Timer {
    id: nextAttempt
    interval: 300
    onTriggered: root.send()
  }

  Timer {
    id: unanswered
    interval: 5000
    onTriggered: {
      if (root.pending === "")
        return
      if (root.resends >= 3)
        return root.fail()
      root.resends++
      root.send()
    }
  }

  Timer {
    id: pairWindow
    interval: 1000
    onTriggered: root.duplicates = 0
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
          anchors.left: parent.left
          anchors.leftMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Repeater {
            model: Math.min(password.text.length, 21)

            Image {
              source: "bullet.png"
              width: 7
              height: 7
            }
          }
        }

        TextInput {
          id: password
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

          Keys.onPressed: function(event) {
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.pending === "" && !root.awaiting) {
              root.login()
              event.accepted = true
            }
          }
        }
      }
    }

  }

  Component.onCompleted: password.forceActiveFocus()
}
