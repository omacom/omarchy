import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#1a1b26"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property bool userPicked: false
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }
  // Committed user selection; falls back to lastUser when the picker
  // has no rows yet (single-user installs behave exactly as before).
  property string selectedName: (userCombo.index >= 0 && userCombo.index < userPickModel.count) ? userPickModel.get(userCombo.index).name : root.currentUser

  function selectLastUser() {
    if (userPicked || userPickModel.count === 0) {
      return
    }
    for (var i = 0; i < userPickModel.count; i++) {
      if (userPickModel.get(i).name === userModel.lastUser) {
        userCombo.index = i
        return
      }
    }
    userCombo.index = 0
  }

  function doLogin() {
    if (selectedName === "") {
      root.loginFailed = true
      userCombo.forceActiveFocus()
      return
    }
    sddm.login(selectedName, password.text, sessionCombo.index)
  }

  function cycleIndex(combo, count, delta) {
    if (count <= 0) {
      return
    }
    var i = combo.index + delta
    if (i < 0) {
      i = count - 1
    } else if (i >= count) {
      i = 0
    }
    combo.index = i
  }

  function focusNext() {
    if (password.activeFocus) {
      userCombo.forceActiveFocus()
    } else if (userCombo.activeFocus) {
      sessionCombo.forceActiveFocus()
    } else {
      password.forceActiveFocus()
    }
  }

  function focusPrev() {
    if (password.activeFocus) {
      sessionCombo.forceActiveFocus()
    } else if (sessionCombo.activeFocus) {
      userCombo.forceActiveFocus()
    } else {
      password.forceActiveFocus()
    }
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.loginFailed = true
      password.text = ""
      password.forceActiveFocus()
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  ListModel {
    id: userPickModel
    onCountChanged: selectLastUser()
  }

  Item {
    Repeater {
      model: userModel
      delegate: Item {
        property string userName: (model.name !== undefined && model.name !== "") ? model.name : model.display
        property string userLabel: (model.realName !== undefined && model.realName !== "") ? model.realName : userName
        Component.onCompleted: {
          if (userName !== undefined && userName !== "") {
            userPickModel.append({ "display": userName, "name": userName, "label": userLabel })
          }
        }
      }
    }
  }

  Component {
    id: userRow
    Text {
      anchors.fill: parent
      anchors.margins: 5
      verticalAlignment: Text.AlignVCenter
      color: "#c0caf5"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: parent.modelItem.label
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
        id: entryBox
        width: entry.width
        height: entry.height

        // Shared password-field geometry so the bullet row and the caret stay
        // locked to the same advance: a 7px bullet plus the row's 5px spacing.
        property int bulletW: 7
        property bool caretBlink: true

        Image {
          id: entry
          source: root.loginFailed ? "entry-failed.png" : "entry.png"
          anchors.centerIn: parent
        }

        // Focus ring: transparent at rest, blue when the password box
        // is active, red after a failed login.
        Rectangle {
          id: passwordRing
          anchors.fill: parent
          anchors.margins: -4
          color: "transparent"
          radius: 8
          border.width: 2
          border.color: root.loginFailed ? "#f7768e" : (password.activeFocus ? "#7aa2f7" : "transparent")
        }

        Row {
          id: bulletRow
          anchors.left: parent.left
          anchors.leftMargin: 20
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Repeater {
            model: Math.min(password.text.length, 21)

            Image {
              source: "bullet.png"
              width: entryBox.bulletW
              height: entryBox.bulletW
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
          activeFocusOnPress: true
          // Native caret hidden: its font metrics differ from the bullet
          // advance, so it drifts from the visible bullets. A caret aligned
          // to the bullet row is drawn below instead.
          cursorVisible: false
          focus: true

          onTextChanged: {
            root.loginFailed = false
            entryBox.caretBlink = true
            caretBlinkTimer.restart()
          }

          Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              doLogin()
              event.accepted = true
            } else if (event.key === Qt.Key_Tab) {
              if (event.modifiers & Qt.ShiftModifier) {
                focusPrev()
              } else {
                focusNext()
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Backtab) {
              focusPrev()
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              userCombo.forceActiveFocus()
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              sessionCombo.forceActiveFocus()
              event.accepted = true
            }
          }
        }

        // Password caret, drawn aligned to the bullet row. The native
        // TextInput caret is hidden above (its 24px/5px metrics drift from the
        // 12px bullet advance); this uses cursorPosition on the same 12px step
        // as the bullets and blinks while the field has focus.
        Rectangle {
          id: caret
          width: 2
          height: entryBox.bulletW
          color: "#7aa2f7"
          anchors.verticalCenter: parent.verticalCenter
          x: Math.min(bulletRow.x + password.cursorPosition * (entryBox.bulletW + bulletRow.spacing),
                      parent.width - width - 4)
          visible: password.activeFocus
          opacity: entryBox.caretBlink ? 1 : 0
        }
        Timer {
          id: caretBlinkTimer
          interval: 530
          running: password.activeFocus
          repeat: true
          onTriggered: entryBox.caretBlink = !entryBox.caretBlink
        }
      }
    }

    // User + session pickers. On single-user installs this still shows
    // one row preselected to lastUser with the uwsm session preferred,
    // so default behaviour is unchanged; on multi-user machines Up/Down
    // cycles the committed selection with wrap-around (works open and
    // closed). Enter is handled on Released so an open dropdown commits
    // its highlight (SDDM ComboBox closes on Pressed) before login.
    Row {
      id: pickerRow
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 10

      Item {
        width: 180
        height: 34

        ComboBox {
          id: userCombo
          anchors.fill: parent
          model: userPickModel
          color: "#24283b"
          borderColor: "#334155"
          borderWidth: 1
          focusColor: "#7aa2f7"
          hoverColor: "#334155"
          textColor: "#c0caf5"
          menuColor: "#24283b"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 14
          rowDelegate: userRow
          onValueChanged: root.userPicked = true
          Keys.onPressed: {
            if (event.key === Qt.Key_Tab) {
              if (event.modifiers & Qt.ShiftModifier) {
                focusPrev()
              } else {
                focusNext()
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Backtab) {
              focusPrev()
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              cycleIndex(userCombo, userPickModel.count, 1)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              cycleIndex(userCombo, userPickModel.count, -1)
              event.accepted = true
            }
          }
          Keys.onReleased: {
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
              doLogin()
              event.accepted = true
            }
          }
        }
      }

      Item {
        width: 180
        height: 34

        ComboBox {
          id: sessionCombo
          anchors.fill: parent
          model: sessionModel
          index: root.sessionIndex
          color: "#24283b"
          borderColor: "#334155"
          borderWidth: 1
          focusColor: "#7aa2f7"
          hoverColor: "#334155"
          textColor: "#c0caf5"
          menuColor: "#24283b"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 14
          Keys.onPressed: {
            if (event.key === Qt.Key_Tab) {
              if (event.modifiers & Qt.ShiftModifier) {
                focusPrev()
              } else {
                focusNext()
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Backtab) {
              focusPrev()
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              cycleIndex(sessionCombo, sessionModel.count, 1)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              cycleIndex(sessionCombo, sessionModel.count, -1)
              event.accepted = true
            }
          }
          Keys.onReleased: {
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
              doLogin()
              event.accepted = true
            }
          }
        }
      }
    }

  }

  Component.onCompleted: {
    selectLastUser()
    password.forceActiveFocus()
  }
}
