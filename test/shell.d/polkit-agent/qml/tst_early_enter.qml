import QtQuick
import QtTest
import Quickshell.Services.Polkit

// The real PolkitAgent.qml driven through a stand-in polkit: Enter pressed
// before PAM asks for the password. The dialog must keep showing that Enter
// was received, must still cancel on Escape, and must send the password once
// PAM asks.
Item {
  id: root
  width: 800
  height: 600

  Loader {
    id: loader
    anchors.fill: parent
    source: "PolkitAgentUnderTest.qml"
  }

  Component {
    id: flowComponent
    QtObject {
      property bool isResponseRequired: false
      property string message: "Authentication is needed to run `/usr/bin/true' as the super user"
      property string inputPrompt: "Password:"
      property string supplementaryMessage: ""
      property bool responseVisible: false
      property bool failed: false
      property var submissions: []
      property int cancels: 0
      signal authenticationFailed()
      signal authenticationSucceeded()
      signal authenticationRequestCancelled()
      function submit(password) { submissions = submissions.concat([password]) }
      function cancelAuthenticationRequest() { cancels++ }
    }
  }

  TestCase {
    name: "PolkitEarlyEnter"
    when: windowShown

    property var flow: null

    function dialog() { return loader.item }

    function findInput(item) {
      if (item.passwordCharacter !== undefined) return item
      for (var i = 0; i < item.children.length; i++) {
        var found = findInput(item.children[i])
        if (found) return found
      }
      return null
    }

    function input() { return findInput(dialog()) }

    function findText(item, text) {
      if (item.text === text && item.visible) return item
      for (var i = 0; i < item.children.length; i++) {
        var found = findText(item.children[i], text)
        if (found) return found
      }
      return null
    }

    // The padlock turns into an hourglass while an Enter waits for PAM.
    function hourglassShown() { return findText(dialog(), "\uf252") !== null }

    // A request arrives while PAM has not asked for anything yet.
    function startRequest() {
      flow = createTemporaryObject(flowComponent, root)
      var agent = PolkitHarness.agent
      agent.flow = flow
      agent.isActive = true
      agent.authenticationRequestStarted()
      tryVerify(function() { return input().activeFocus })
    }

    function endRequest() {
      var agent = PolkitHarness.agent
      agent.isActive = false
      agent.flow = null
      dialog().resetSnapshot()
    }

    function cleanup() {
      if (PolkitHarness.agent) endRequest()
    }

    function typeAndEnter(password) {
      for (var i = 0; i < password.length; i++) keyClick(password[i])
      keyClick(Qt.Key_Return)
    }

    function pamAsks() {
      flow.isResponseRequired = true
    }

    function test_0_dialogLoads() {
      var probe = Qt.createComponent("PolkitAgentUnderTest.qml")
      verify(loader.status === Loader.Ready, "the polkit dialog loads: " + probe.errorString())
      verify(PolkitHarness.agent !== null, "the dialog created its polkit agent")
    }

    function test_queuedEnterIsSentWhenPamAsks() {
      startRequest()
      typeAndEnter("hunter2")
      compare(dialog().submitQueued, true, "Enter before PAM asks is queued")
      compare(flow.submissions.length, 0, "nothing is sent before PAM asks")
      compare(dialog().dialogVisible, true, "the dialog stays visible while waiting")
      compare(input().visible, true, "the field stays on screen while waiting")
      compare(hourglassShown(), true, "an hourglass shows that Enter was received")
      compare(input().readOnly, true, "the field is read-only while waiting")
      compare(input().text, "hunter2", "the typed password stays in the field")

      pamAsks()
      tryCompare(flow, "submissions", ["hunter2"])
      compare(dialog().submitQueued, false, "the queue is consumed")
      compare(dialog().submitted, true, "the dialog shows it is checking")
      compare(hourglassShown(), false, "the hourglass goes once the password is sent")
      compare(dialog().dialogVisible, true, "the dialog stays visible while the answer is checked")
      compare(input().visible, true, "the field stays on screen while the answer is checked")
      compare(input().text, "", "the password does not stay in the field")
    }

    function test_escapeCancelsWhileQueued() {
      startRequest()
      typeAndEnter("hunter2")
      compare(dialog().submitQueued, true)

      keyClick(Qt.Key_Escape)
      compare(flow.cancels, 1, "Escape cancels the request while waiting")
      compare(dialog().submitQueued, false)
      compare(input().text, "", "the queued password is dropped")

      pamAsks()
      wait(50)
      compare(flow.submissions.length, 0, "a cancelled password is never sent")
    }

    function test_escapeCancelsWhileChecking() {
      startRequest()
      pamAsks()
      tryVerify(function() { return dialog().responseRequired })
      typeAndEnter("hunter2")
      compare(flow.submissions.length, 1)
      compare(dialog().submitted, true)
      compare(dialog().dialogVisible, true)

      keyClick(Qt.Key_Escape)
      compare(flow.cancels, 1, "Escape cancels while the password is being checked")
    }

    function test_wrongPasswordThenRetry() {
      startRequest()
      typeAndEnter("wrong")
      pamAsks()
      tryCompare(flow, "submissions", ["wrong"])

      flow.isResponseRequired = false
      flow.authenticationFailed()
      compare(dialog().errorFlash, true, "a wrong password flashes the error")
      compare(dialog().submitQueued, false)
      tryCompare(dialog(), "errorFlash", false)

      pamAsks()
      tryVerify(function() { return input().activeFocus })
      wait(50)
      compare(flow.submissions.length, 1, "the old password is not sent again")
      typeAndEnter("right")
      compare(flow.submissions.length, 2, "a retry is sent straight away")
      compare(flow.submissions[1], "right")
    }

    function test_cancelledByPolkitDropsTheQueue() {
      startRequest()
      typeAndEnter("hunter2")
      compare(dialog().submitQueued, true)

      flow.authenticationRequestCancelled()
      PolkitHarness.agent.isActive = false
      tryCompare(dialog(), "submitQueued", false)

      // The next request must not inherit the dropped password.
      startRequest()
      pamAsks()
      wait(50)
      compare(flow.submissions.length, 0)
    }

    function test_emptyEnterIsNotQueued() {
      startRequest()
      keyClick(Qt.Key_Return)
      compare(dialog().submitQueued, false)
      compare(input().readOnly, false)
    }
  }
}
