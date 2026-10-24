import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#1a1b26"

  // The last user, when that account still exists (removing one doesn't
  // clear SDDM's memory of it); with one account, that account.
  property string currentUser: userNames.indexOf(userModel.lastUser) !== -1 ? userModel.lastUser
    : (userNames.length === 1 ? userNames[0] : "")
  property bool loginFailed: false
  // With more than one account the screen asks who is logging in, starting
  // from the last user. A name is typed, not picked from a list, so it works
  // for any number of accounts, also ones the list doesn't show.
  // Also on request: SDDM lists only the accounts it is told to show
  // (HideUsers, the UID range), so someone it doesn't list asks for the name
  // box with Up or Shift+Tab from the password box.
  property bool nameRequested: false
  property bool askUser: users.count > 1 || nameRequested
  property var userNames: []
  // #ffffff is the theme's text color: omarchy-plymouth-set swaps it in.
  property color textColor: "#ffffff"
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  Repeater {
    id: users
    model: userModel
    Item {
      Component.onCompleted: root.userNames = root.userNames.concat([model.name])
    }
  }

  // The first account whose name starts with what was typed, for completion.
  function completeUser(typed) {
    if (typed.length === 0) return ""
    var names = userNames.slice().sort()
    for (var i = 0; i < names.length; i++)
      if (names[i].indexOf(typed) === 0) return names[i]
    return ""
  }

  function loginUser() {
    return askUser ? username.text : currentUser
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
      visible: root.askUser
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 15

      // Lines the name up with the password box beside the lock.
      Item {
        width: 34
        height: 38
      }

      Item {
        width: nameEntry.width
        height: nameEntry.height

        Image {
          id: nameEntry
          source: root.loginFailed ? "entry-failed.png" : "entry.png"
          anchors.centerIn: parent
        }

        TextInput {
          id: username
          property bool deleting: false
          anchors.fill: parent
          clip: true
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          verticalAlignment: TextInput.AlignVCenter
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 24
          color: root.textColor
          selectionColor: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.25)
          selectedTextColor: root.textColor
          text: root.currentUser
          // Reached from the password box, the box offers its name selected,
          // so typing replaces it and Tab keeps it.
          onActiveFocusChanged: if (activeFocus) selectAll()
          KeyNavigation.tab: password
          KeyNavigation.backtab: password
          KeyNavigation.down: password

          // Complete as the name is typed, leaving the completion selected so
          // the next key replaces it. Deleting never completes.
          onTextEdited: {
            root.loginFailed = false
            var wasDeleting = deleting
            deleting = false
            if (wasDeleting || cursorPosition !== text.length) return
            var match = root.completeUser(text)
            if (match !== "" && match !== text) {
              var typed = text.length
              text = match
              select(typed, match.length)
            }
          }

          Keys.onPressed: {
            deleting = event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              deselect()
              password.forceActiveFocus()
              event.accepted = true
            }
          }
        }
      }
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
          KeyNavigation.tab: username
          KeyNavigation.backtab: username
          KeyNavigation.up: username

          Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              sddm.login(root.loginUser(), password.text, root.sessionIndex)
              event.accepted = true
            } else if (!root.askUser && (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab)) {
              root.nameRequested = true
              username.forceActiveFocus()
              event.accepted = true
            }
          }
        }
      }
    }

  }

  // The last user only types their password; with nobody remembered, the
  // name comes first.
  Component.onCompleted: {
    if (askUser && currentUser === "")
      username.forceActiveFocus()
    else
      password.forceActiveFocus()
  }
}
