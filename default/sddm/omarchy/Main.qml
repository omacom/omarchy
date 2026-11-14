import QtQuick 2.0

Rectangle {
  id: root
  width: 640
  height: 480
  color: "#1a1b26"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property bool passwordBusy: false
  property bool fingerprintActive: false
  property bool loginComplete: false
  property string submittedPassword: ""
  property string fingerprintSelection: ""
  property bool awaitingCapability: false
  readonly property bool parallelAvailable: sddm.parallelFingerprint === true
    && typeof sddm.startFingerprint === "function"

  function armFingerprint() {
    if (!parallelAvailable) {
      fingerprintSelection = ""
      fingerprintActive = false
      return
    }
    if (loginComplete || awaitingCapability) return
    var selection = currentUser + ":" + sessionIndex
    if (fingerprintSelection === selection) return
    fingerprintSelection = selection
    fingerprintActive = false
    // Empty users and invalid sessions revoke the previous selection too.
    sddm.startFingerprint(currentUser, sessionIndex)
  }

  function selectionChanged(clearPassword) {
    if (clearPassword) password.text = ""
    passwordBusy = false
    submittedPassword = ""
    loginFailed = false
    armFingerprint()
  }

  function submitPassword() {
    if (loginComplete || passwordBusy || awaitingCapability || currentUser.length === 0
        || sessionIndex < 0 || sessionIndex >= sessionModel.rowCount()) return
    submittedPassword = password.text
    passwordBusy = true
    loginFailed = false
    // An explicit empty submission retains stock PAM/passwordless behavior.
    sddm.login(currentUser, submittedPassword, sessionIndex)
  }

  onParallelAvailableChanged: armFingerprint()
  onCurrentUserChanged: selectionChanged(true)
  onSessionIndexChanged: selectionChanged(false)

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
    ignoreUnknownSignals: true
    function onParallelFingerprintChanged() {
      // A reconnect can announce true again without changing the property.
      root.awaitingCapability = false
      root.armFingerprint()
    }
    function onHostNameChanged() {
      // Legacy daemons announce the hostname on Connect, but no parallel API.
      if (typeof sddm.startFingerprint !== "function") root.awaitingCapability = false
    }
    function onFingerprintActiveChanged(active) {
      root.fingerprintActive = active && root.parallelAvailable
        && !root.awaitingCapability && !root.loginComplete
    }
    function onLoginFailed() {
      if (root.loginComplete) return
      var unchanged = root.passwordBusy && password.text === root.submittedPassword
      root.passwordBusy = false
      if (unchanged) password.text = ""
      root.loginFailed = unchanged
      root.submittedPassword = ""
      password.forceActiveFocus()
    }
    function onLoginSucceeded() {
      root.loginFailed = false
      root.loginComplete = true
      root.passwordBusy = false
      root.fingerprintActive = false
      root.submittedPassword = ""
      password.text = ""
    }
    function onSocketDisconnected() {
      // Do not cache requests the disconnected proxy would silently drop.
      root.awaitingCapability = true
      root.fingerprintSelection = ""
      root.fingerprintActive = false
      root.passwordBusy = false
      root.submittedPassword = ""
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

      Text {
        objectName: "fingerprintIndicator"
        width: 36
        height: 38
        anchors.verticalCenter: parent.verticalCenter
        visible: root.parallelAvailable && root.fingerprintActive
        text: "󰈷"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 29
        color: "#ffffff"
        opacity: root.fingerprintActive ? 1 : 0.45
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Accessible.role: Accessible.StaticText
        Accessible.name: root.fingerprintActive ? qsTr("Fingerprint reader active") : qsTr("Fingerprint reader inactive")
      }

      Item {
        objectName: "passwordStatus"
        width: 34
        height: 38
        anchors.verticalCenter: parent.verticalCenter
        Accessible.role: Accessible.StaticText
        Accessible.name: root.passwordBusy ? qsTr("Checking password") : (root.loginFailed ? qsTr("Authentication failed") : qsTr("Password"))

        Image {
          anchors.fill: parent
          visible: !root.passwordBusy
          source: root.loginFailed ? "lock-failed.png" : "lock.png"
          fillMode: Image.PreserveAspectFit
        }

        Text {
          anchors.fill: parent
          visible: root.passwordBusy
          text: ""
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 29
          color: "#ffffff"
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
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
          objectName: "passwordInput"
          enabled: !root.loginComplete
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
          Accessible.name: qsTr("Password")
          Accessible.description: root.loginFailed ? qsTr("Authentication failed") : ""

          onTextChanged: root.loginFailed = false

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.submitPassword()
              event.accepted = true
            }
          }
        }
      }
    }

  }

  Component.onCompleted: {
    password.forceActiveFocus()
    Qt.callLater(armFingerprint)
  }
}
