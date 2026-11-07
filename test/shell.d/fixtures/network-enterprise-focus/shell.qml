import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Types an enterprise credential into the real panel, then churns the scan
// results and fails a connect, asserting the caret stays in Passphrase.
ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }
  function focused() {
    var item = panel.testFocus
    return item && item.placeholderText !== undefined ? item.placeholderText : "<" + item + ">"
  }

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

  Timer {
    interval: 250
    running: true
    onTriggered: {
      panel.open()
      prompt.start()
    }
  }

  Timer {
    id: prompt
    interval: 750
    onTriggered: {
      panel.openPasswordPrompt("Corp")
      typeIdentity.start()
    }
  }

  Timer {
    id: typeIdentity
    interval: 300
    onTriggered: {
      test.check(test.focused() === "Identity (user@domain)", "an enterprise prompt opens on Identity (got " + test.focused() + ")")
      if (test.failed) { Qt.quit(); return }
      panel.testFocus.insert(0, "me@corp")
      panel.testFocus.accepted()
      typePassphrase.start()
    }
  }

  Timer {
    id: typePassphrase
    interval: 300
    onTriggered: {
      test.check(test.focused() === "Passphrase", "Enter in Identity moves to Passphrase (got " + test.focused() + ")")
      if (test.failed) { Qt.quit(); return }
      panel.testFocus.insert(0, "hunter")
      test.check(panel.identityText === "me@corp" && panel.passwordText === "hunter", "typed credentials reach the panel")
      // A scan reorders the list: a new array model rebuilds every delegate.
      NetworkMock.cafe.signalStrength = 0.9
      NetworkMock.wifi.networks = { values: [NetworkMock.cafe, NetworkMock.corp] }
      afterScan.start()
    }
  }

  Timer {
    id: afterScan
    interval: 300
    onTriggered: {
      test.check(test.focused() === "Passphrase", "a scan leaves the caret in Passphrase (got " + test.focused() + ")")
      test.check(panel.identityText === "me@corp" && panel.passwordText === "hunter", "a scan keeps the typed credentials")
      panel.failureSsid = "Corp"
      panel.failureReason = "Wrong password"
      afterFailure.start()
    }
  }

  Timer {
    id: afterFailure
    interval: 2600
    onTriggered: {
      test.check(test.focused() === "Passphrase", "a failed connect returns the caret to Passphrase (got " + test.focused() + ")")
      // A fresh prompt, submitted with the caret still in Identity.
      panel.cancelPasswordPrompt()
      panel.openPasswordPrompt("Corp")
      reopened.start()
    }
  }

  Timer {
    id: reopened
    interval: 300
    onTriggered: {
      test.check(test.focused() === "Identity (user@domain)", "a reopened prompt starts on Identity (got " + test.focused() + ")")
      panel.passwordText = "hunter"
      panel.testFocus.insert(0, "me@corp")
      panel.failureSsid = "Corp"
      panel.failureReason = "Wrong password"
      afterIdentityFailure.start()
    }
  }

  Timer {
    id: afterIdentityFailure
    interval: 2600
    onTriggered: {
      test.check(test.focused() === "Passphrase", "a failed connect from Identity moves the caret to Passphrase (got " + test.focused() + ")")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
