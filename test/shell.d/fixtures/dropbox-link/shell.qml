import QtQuick
import Quickshell
import qs.Commons
import "dropbox" as Dropbox

ShellRoot {
  id: test
  property int step: 0
  property int loginStarts: 0
  property int statusStarts: 0
  property int statusExits: 0
  property int settledPolls: 0
  property int idleTicks: 0
  property var service: panel.testService

  function check(ok, message) {
    if (!ok) {
      console.log("RESULT fail " + message)
      Qt.quit()
      throw new Error(message)
    }
  }

  function status(linked) {
    return JSON.stringify({ ok: true, installed: true, running: true,
      authenticated: linked, statusText: linked ? "Up to date" : "Unlinked", files: [] })
  }

  Item {
    Dropbox.Panel {
      id: panel
      omarchyPath: Quickshell.env("DROPBOX_TEST_ROOT")
      bar: QtObject {
        property color foreground: Color.foreground
        property color barForeground: Color.foreground
        property color urgent: Color.urgent
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

  Connections {
    target: service.testLoginProcess
    function onRunningChanged() { if (target.running) test.loginStarts += 1 }
  }
  Connections {
    target: service.testStatusProcess
    function onRunningChanged() { if (target.running) test.statusStarts += 1 }
    function onExited() { test.statusExits += 1 }
  }

  Timer {
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      if (service.busy) return
      switch (test.step) {
      case 0:
        // Keep the real repeating timer and process callbacks, but advance
        // time faster and exclude unrelated startup/periodic refreshes.
        service.testRefreshTimer.stop()
        service.testStartupRamp.stop()
        service.testLinkWait.interval = 50
        service.applyStatus(test.status(false))
        test.statusExits = 0
        service.login()
        test.step = 1
        break
      case 1:
        test.check(service.linkPending && !service.linkUrlKnown, "a successful no-URL login waits for authentication")
        service.testDelayedRefresh.stop()
        service.testLinkWait.ticks = 20
        service.login()
        test.step = 2
        break
      case 2:
        if (test.statusExits < 2) return
        // These completions must come from linkWait, not a manual refresh.
        test.check(test.loginStarts === 1, "a pending no-URL click does not start another daemon")
        test.check(service.testLinkWait.ticks >= 20, "a pending click does not extend the deadline")
        service.applyStatus(test.status(true))
        test.check(!service.linkPending, "authentication completes the pending link")
        test.settledPolls = test.statusStarts
        test.step = 3
        break
      case 3:
        if (++test.idleTicks < 8) return
        test.check(test.statusStarts === test.settledPolls, "authentication stops fast polling")
        service.applyStatus(test.status(false))
        service.login()
        test.step = 4
        break
      case 4:
        service.testDelayedRefresh.stop()
        test.check(service.linkPending && service.linkUrlKnown, "a captured URL starts the link wait")
        test.check(service.testOpenedUrls.length === 1, "the initial login opens its captured URL")
        service.testLinkWait.ticks = 20
        service.login()
        test.check(test.loginStarts === 2, "reopening a known URL does not start another daemon")
        test.check(service.testOpenedUrls.length === 2 && service.testOpenedUrls[0] === service.testOpenedUrls[1], "a pending click reopens the same URL")
        test.check(service.testLinkWait.ticks === 20, "reopening the URL does not extend the deadline")
        service.actionStatus = "Unrelated control failure"
        service.applyStatus(test.status(true))
        test.step = 5
        break
      case 5:
        test.check(panel.testMessage.text === "Unrelated control failure", "link completion preserves unrelated action errors")
        service.applyStatus(test.status(false))
        service.beginLinkWait()
        service.testLinkWait.ticks = 99
        service.testLinkWait.triggered()
        test.step = 6
        break
      case 6:
        test.check(!service.linkPending && service.linkError !== "", "the deadline ends the wait and reports a link failure")
        service.applyStatus(test.status(false))
        test.step = 7
        break
      case 7:
        test.check(panel.testMessage.text === service.linkError && panel.testMessage.text !== "", "an unlinked poll preserves the visible timeout error")
        test.check(panel.testMessage.color.toString() === panel.urgent.toString(), "the timeout is presented as an error")
        // Also models a successful poll that was in flight at the deadline.
        service.applyStatus(test.status(true))
        test.step = 8
        break
      case 8:
        test.check(panel.testMessage.text === "", "late authentication removes the visible timeout error")
        service.applyStatus(test.status(false))
        service.beginLinkWait()
        service.testLinkWait.ticks = 99
        service.testLinkWait.triggered()
        service.login()
        test.step = 9
        break
      case 9:
        service.testDelayedRefresh.stop()
        test.check(test.loginStarts === 3 && service.linkPending && service.linkError === "", "a fresh attempt after timeout is allowed and clears the old failure")
        service.applyStatus(test.status(true))
        stop()
        console.log("RESULT pass")
        if (Quickshell.env("DROPBOX_TEST_PREVIEW")) {
          panel.open()
          previewState.start()
        } else {
          Qt.quit()
        }
        break
      }
    }
  }

  // Render only synthetic account state; never open a browser or touch Dropbox.
  Timer {
    id: previewState
    interval: 250
    onTriggered: {
      var state = Quickshell.env("DROPBOX_TEST_PREVIEW")
      service.applyStatus(test.status(state === "linked"))
      if (state !== "linked") {
        service.beginLinkWait()
        if (state === "timeout") {
          service.testLinkWait.ticks = 99
          service.testLinkWait.triggered()
        }
        service.testLinkWait.stop()
      }
      previewCapture.start()
    }
  }
  Timer {
    id: previewCapture
    interval: 250
    onTriggered: {
      var card = panel.testKeys.parent.parent
      card.grabToImage(function(result) {
        test.check(result.saveToFile(Quickshell.env("DROPBOX_TEST_SCREENSHOT")), "save panel preview")
        Qt.quit()
      })
    }
  }
  Timer {
    interval: 15000
    running: true
    onTriggered: { console.log("RESULT fail fixture timed out"); Qt.quit() }
  }
}
