import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Opens the passphrase prompt on a network below the list's fold, then lets a
// scan land underneath it: strengths shift and a new access point appears.
// The prompt must stay where it is, in view, with the same field and focus.
ShellRoot {
  id: test
  property bool failed: false
  property var nets: []
  property string target: "Net 14"
  property int targetIndex: -1
  property Item row: null
  property Item field: null
  property real scrollY: 0
  property bool hadFocus: false

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Component {
    id: networkComponent
    QtObject {
      property string name
      property bool connected: false
      property bool known: false
      property bool stateChanging: false
      property real signalStrength: 0.5
      property int security: WifiSecurityType.Wpa2Psk
      signal connectionFailed(int reason)
      function connect() {}
      function connectWithPsk(psk) {}
    }
  }

  function makeNetwork(name, strength, connected) {
    return networkComponent.createObject(test, {
      name: name, signalStrength: strength, connected: connected, known: connected
    })
  }

  function passwordField(item) {
    if (!item) return null
    if (item.password === true) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = passwordField(item.children[i])
      if (found) return found
    }
    return null
  }

  // The row is on screen when it overlaps the list's visible window.
  function rowInView(list, item) {
    return !!item && item.y + item.height > list.contentY && item.y < list.contentY + list.height
  }

  // The field is in sight when all of it is inside that window.
  function fieldInView(list, item) {
    if (!item) return false
    var top = item.mapToItem(list.contentItem, 0, 0).y
    return top >= list.contentY && top + item.height <= list.contentY + list.height
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

  Component.onCompleted: {
    var list = [makeNetwork("Home", 0.9, true)]
    for (var i = 1; i <= 15; i++) list.push(makeNetwork("Net " + (i < 10 ? "0" : "") + i, 0.8 - i * 0.04, false))
    nets = list
    NetworkMock.wifi.networks = { values: nets }
    panel.open()
    settle.start()
  }

  // Past the deferred scan the panel runs on open.
  Timer {
    id: settle
    interval: 2200
    onTriggered: {
      panel.cursorActive = true
      panel.focusSection = "wifi"
      panel.selectedIndex = panel.wifiIndexForSsid(test.target)
      panel.activateSelected()
      prompted.start()
    }
  }

  Timer {
    id: prompted
    interval: 400
    onTriggered: {
      var list = panel.testList
      test.targetIndex = panel.wifiIndexForSsid(test.target)
      test.row = list.itemAtIndex(test.targetIndex)
      test.field = test.passwordField(test.row)
      test.check(panel.passwordSsid === test.target, "activating a protected network opens its prompt")
      test.check(!!test.field && test.field.visible, "the prompt shows a passphrase field")
      test.check(test.rowInView(list, test.row), "the prompted row is scrolled into view")
      test.check(test.fieldInView(list, test.field), "the passphrase field is scrolled into view")
      test.scrollY = list.contentY
      test.hadFocus = !!test.field && test.field.activeFocus
      test.check(test.hadFocus, "the passphrase field takes focus when the prompt opens")
      console.log("before scan: index " + test.targetIndex + ", contentY " + list.contentY + ", field focused " + test.hadFocus)
      if (test.field) test.field.text = "hunt"

      // A scan lands: the prompted network now outshines the rest, the
      // strongest stranger fades, and a new access point shows up.
      test.nets[14].signalStrength = 0.95
      test.nets[1].signalStrength = 0.05
      NetworkMock.wifi.networks = { values: test.nets.concat([test.makeNetwork("Net 16", 0.7, false)]) }
      scanned.start()
    }
  }

  Timer {
    id: scanned
    interval: 400
    onTriggered: {
      var list = panel.testList
      var index = panel.wifiIndexForSsid(test.target)
      var row = list.itemAtIndex(index)
      var field = test.passwordField(row)
      console.log("after scan: index " + index + ", contentY " + list.contentY + ", same row " + (row === test.row) + ", same field " + (!!field && field === test.field) + ", field focused " + (!!field && field.activeFocus))
      test.check(panel.passwordSsid === test.target, "the prompt survives a scan")
      test.check(index === test.targetIndex, "the prompted row keeps its place (was " + test.targetIndex + ", now " + index + ")")
      test.check(test.fieldInView(list, field), "the passphrase field stays in view")
      test.check(list.contentY === test.scrollY, "the list does not scroll under the prompt (was " + test.scrollY + ", now " + list.contentY + ")")
      test.check(!!field && field === test.field, "the passphrase field is not rebuilt")
      test.check(!!field && field.text === "hunt", "typed passphrase survives")
      test.check(!!field && field.activeFocus, "the passphrase field keeps focus")

      panel.cancelPasswordPrompt()
      Qt.callLater(test.closedChecks)
    }
  }

  // With the prompt gone the list catches up on what it held back.
  function closedChecks() {
    check(panel.wifiIndexForSsid("Net 16") >= 0, "a network found during the prompt appears once it closes")
    check(panel.wifiIndexForSsid(target) === 1, "the list re-sorts once the prompt closes")
    if (!failed) console.log("RESULT pass")
    done.start()
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
