import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

ShellRoot {
  id: test
  property bool failed: false
  property var passwordRow: null
  property var passwordField: null
  property var revealButton: null
  property bool awaitingEscape: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function findChild(item, name) {
    if (!item) return null
    if (item.objectName === name) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = findChild(children[i], name)
      if (found) return found
    }
    return null
  }

  component Ap: QtObject {
    property string name: "Cafe"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.8
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
  }

  Ap { id: cafe }

  Item {
    Network.Panel {
      id: panel
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property color urgent: Commons.Color.urgent
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
        property bool foregroundAnimationEnabled: false
        property var activePopout: null
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }

  Component.onCompleted: {
    NetworkMock.wifi.connected = false
    NetworkMock.wifi.networks = { values: [cafe] }
    panel.open()
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      check(panel.testNetworkList !== null, "the panel builds its network list")
      panel.selectedIndex = 0
      panel.openPasswordPrompt("Cafe")
      panel.passwordText = "hunter"
      Qt.callLater(opened)
    }
  }

  function opened() {
    var delegate = panel.testNetworkList.itemAtIndex(0)
    passwordRow = delegate ? delegate.children[0].children[1] : null
    check(passwordRow !== null, "the password row has a delegate")
    if (!passwordRow) return done.start()
    passwordField = findChild(passwordRow, "testPasswordField")
    revealButton = findChild(passwordRow, "testRevealButton")
    check(passwordField !== null && revealButton !== null, "the password controls are available")
    if (!passwordField || !revealButton) return done.start()
    check(passwordField.password, "the passphrase starts masked")
    check(passwordField.text === "hunter", "the passphrase text remains entered")
    check(revealButton.tooltipText === "Show password", "the reveal action starts labelled")
    check(revealButton.Accessible.role === Accessible.Button, "the reveal action exposes its button role")
    check(revealButton.Accessible.name === "Show password", "the reveal action exposes its current label")
    revealButton.Accessible.pressAction()
    Qt.callLater(revealed)
  }

  function revealed() {
    check(!passwordField.password, "the reveal action unmasks the passphrase")
    check(passwordField.text === "hunter", "revealing does not change the passphrase")
    check(revealButton.tooltipText === "Hide password", "the reveal action describes its next state")
    check(passwordField.activeFocus, "revealing returns focus to passphrase entry")
    if (Quickshell.env("NETWORK_TEST_PREVIEW")) {
      console.log("RESULT preview")
      return
    }
    revealButton.clicked()
    Qt.callLater(hidden)
  }

  function hidden() {
    check(passwordField.password, "a second reveal action masks the passphrase again")
    check(passwordField.activeFocus, "hiding returns focus to passphrase entry")
    revealButton.forceActiveFocus()
    check(revealButton.activeFocus, "the reveal action can own keyboard focus")
    awaitingEscape = true
    console.log("INPUT escape")
  }

  Timer {
    interval: 50
    repeat: true
    running: test.awaitingEscape
    onTriggered: {
      if (panel.passwordSsid !== "") return
      stop()
      check(!panel.passwordVisible, "Escape on the reveal action closes and resets the prompt")
      if (!failed) console.log("RESULT pass")
      done.start()
    }
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
