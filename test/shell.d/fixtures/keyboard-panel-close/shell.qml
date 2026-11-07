import QtQuick
import Quickshell
import qs.Ui

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  component FakeBar: QtObject {
    property string position: "top"
    property int barSize: 30
    property var activePopout: null

    function requestPopout(key) { activePopout = key }
    function releasePopout(key) { if (activePopout === key) activePopout = null }
  }

  Item { id: anchor; width: 40; height: 30 }

  FakeBar { id: throwingBar }
  FakeBar { id: workingBar }

  QtObject {
    id: throwingOwner
    property bool opened: true
    function close() { throw new Error("owner close failed") }
  }

  QtObject {
    id: workingOwner
    property bool opened: true
    property int closes: 0
    function close() {
      closes += 1
      opened = false
    }
  }

  KeyboardPanel {
    id: throwingPanel
    anchorItem: anchor
    bar: throwingBar
    owner: throwingOwner
    open: throwingOwner.opened
  }

  KeyboardPanel {
    id: workingPanel
    anchorItem: anchor
    bar: workingBar
    owner: workingOwner
    open: workingOwner.opened
  }

  function runChecks() {
    assertTrue(throwingPanel.open && workingPanel.open, "both panels start open")

    try {
      throwingPanel.close()
    } catch (e) {
      fail("KeyboardPanel.close() let the owner's exception escape: " + e)
    }
    assertTrue(!throwingPanel.open, "a throwing owner close() still closes the panel")
    assertTrue(throwingBar.activePopout === null, "a throwing owner close() releases the bar popout")

    workingPanel.close()
    assertTrue(workingOwner.closes === 1, "a working owner close() is delegated exactly once")
    assertTrue(!workingPanel.open, "a working owner close() closes the panel through its binding")

    settle.start()
  }

  // The card fades out before the window unmaps, so check visibility after it.
  Timer {
    id: settle
    interval: 1000
    onTriggered: {
      root.assertTrue(!throwingPanel.visible, "the overlay of a panel whose owner threw is unmapped")
      root.assertTrue(!workingPanel.visible, "the overlay of a panel whose owner closed is unmapped")
      root.writeResult()
      quitTimer.start()
    }
  }

  Timer {
    id: quitTimer
    interval: 300
    onTriggered: Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)
}
