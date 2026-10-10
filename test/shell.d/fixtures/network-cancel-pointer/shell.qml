import QtQuick
import QtTest
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Pointer-event regression for the Cancel/Forget right-edge slot.
//
// The slot reuses one MouseArea for Cancel (while connecting) and Forget
// (afterwards, on a saved row). Clearing the keyboard focus on cancel does
// not stop pointer dispatch, so a Qt-recognized double-click on Cancel used
// to cancel once and then Forget the network. The slot's onDoubleClicked
// handler suppresses that second clicked event; these steps send real Qt
// mouse events at the real Panel.qml to prove it.
//
// Glyphs are written as unicode escapes so the file stays ASCII-only.
// NETWORK_CANCEL_POINTER_OUT receives a line per assertion; the runner
// requires every one of them and no "FAIL" lines.
ShellRoot {
  id: test
  property int failures: 0

  // Keep in sync with the lockIndicator glyphs in Panel.qml.
  readonly property string cancelGlyph: "󰅖"
  readonly property string forgetGlyph: "󰅙"

  function check(ok, message) {
    if (!ok) failures++
    console.log((ok ? "PASS " : "FAIL ") + message)
  }

  Window {
    id: win
    visible: true
    width: 720
    height: 1400
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

  TestEvent { id: ev }

  function arm() {
    NetworkMock.cafe.connected = false
    NetworkMock.cafe.known = true
    NetworkMock.cafe.stateChanging = false
    NetworkMock.cafe.state = ConnectionState.Disconnected
    NetworkMock.home.connected = false
    NetworkMock.home.known = true
    NetworkMock.home.stateChanging = false
    NetworkMock.home.state = ConnectionState.Disconnected
    NetworkMock.device.connected = false
    NetworkMock.device.state = ConnectionState.Disconnected
    NetworkMock.device.disconnects = 0
    NetworkMock.device.refusedDisconnects = 0
    NetworkMock.cafe.disconnects = 0
    NetworkMock.cafe.refusedDisconnects = 0
    NetworkMock.cafe.forgets = 0
    NetworkMock.cafe.refusedForgets = 0
    NetworkMock.home.forgets = 0
    NetworkMock.home.refusedForgets = 0
    panel.actionSsid = ""
    panel.actionKind = ""
    panel.forgetActive = false
    panel.forgetSsid = ""
    panel.failureSsid = ""
    panel.failureReason = ""
    panel.passwordSsid = ""
    panel.passwordText = ""
    panel.identityText = ""
    panel.cursorActive = true
    panel.focusSection = "wifi"
    panel.wifiActionFocused = false
    panel.syncWifiNetworks()
  }

  function indexOf(ssid) {
    for (var i = 0; i < panel.wifiNetworks.length; i++)
      if (panel.wifiNetworks[i].ssid === ssid) return i
    return -1
  }

  function focusRow(ssid) {
    panel.cursorActive = true
    panel.focusSection = "wifi"
    panel.selectedIndex = indexOf(ssid)
    panel.wifiActionFocused = false
  }

  // The delegate row carrying this SSID's snapshot. Rows are primitives, so
  // match on the snapshot rather than the live WifiNetwork object.
  function rowItem(ssid) {
    function walk(it) {
      if (!it) return null
      if (it.net && it.net.ssid === ssid) return it
      var kids = it.children
      for (var i = 0; i < kids.length; i++) {
        var found = walk(kids[i])
        if (found) return found
      }
      return null
    }
    return walk(win.contentItem)
  }

  // The right-edge slot showing this glyph on this row's subtree. The prompt
  // Cancel button carries the same Cancel glyph but is a focusable
  // PanelActionButton, so it is excluded: only the slot MouseArea's parent
  // (which has no focusable property) matches.
  function slotFor(ssid, glyph) {
    var row = rowItem(ssid)
    if (!row) return null
    function walk(it) {
      if (!it) return null
      if (it.text === glyph && it.visible && it.parent && it.parent.focusable === undefined) return it.parent
      var kids = it.children
      for (var i = 0; i < kids.length; i++) {
        var found = walk(kids[i])
        if (found) return found
      }
      return null
    }
    return walk(row)
  }

  // A prompt action button (Cancel/Connect) on this row's subtree, found by
  // tooltip. Unlike the right-edge slot glyph, the prompt Cancel button is a
  // focusable PanelActionButton, so the tooltip match is unambiguous.
  function actionButton(ssid, tip) {
    var row = rowItem(ssid)
    if (!row) return null
    function walk(it) {
      if (!it) return null
      if (it.tooltipText === tip) return it
      var kids = it.children
      for (var i = 0; i < kids.length; i++) {
        var found = walk(kids[i])
        if (found) return found
      }
      return null
    }
    return walk(row)
  }

  // A credential field on this row's subtree, found by placeholder text.
  function credentialField(ssid, placeholder) {
    var row = rowItem(ssid)
    if (!row) return null
    function walk(it) {
      if (!it) return null
      if (it.placeholderText === placeholder) return it
      var kids = it.children
      for (var i = 0; i < kids.length; i++) {
        var found = walk(kids[i])
        if (found) return found
      }
      return null
    }
    return walk(row)
  }

  function singleClick(slot) {    ev.mouseMove(slot, slot.width / 2, slot.height / 2, -1, Qt.NoButton, Qt.NoModifier)
    ev.mouseClick(slot, slot.width / 2, slot.height / 2, Qt.LeftButton, Qt.NoModifier, -1)
  }

  function doubleClick(slot) {
    ev.mouseMove(slot, slot.width / 2, slot.height / 2, -1, Qt.NoButton, Qt.NoModifier)
    ev.mouseDoubleClickSequence(slot, slot.width / 2, slot.height / 2, Qt.LeftButton, Qt.NoModifier, 60)
  }

  property int step: 0

  Timer {
    interval: 350
    repeat: true
    running: true
    onTriggered: {
      if (step === 0) {
        panel.open()
        check(panel.wifiNetworks.length === 2, "two rows are listed")
        arm()
      } else if (step === 1) {
        // Saved open network, single click on Cancel.
        panel.connectDirectly("Cafe WiFi")
        var slot = slotFor("Cafe WiFi", cancelGlyph)
        check(slot !== null, "the connecting row shows a Cancel slot")
        if (slot) singleClick(slot)
        check(NetworkMock.device.disconnects === 1,
          "single click on Cancel cancels exactly once")
        check(NetworkMock.cafe.forgets === 0,
          "single click on Cancel never invokes Forget")
        check(panel.actionKind === "" && panel.forgetActive === false,
          "single click on Cancel leaves both lanes idle")
        arm()
      } else if (step === 2) {
        // Saved open network, Qt-recognized double-click on Cancel.
        panel.connectDirectly("Cafe WiFi")
        var slot2 = slotFor("Cafe WiFi", cancelGlyph)
        check(slot2 !== null, "the connecting row still shows a Cancel slot")
        if (slot2) doubleClick(slot2)
        check(NetworkMock.device.disconnects === 1,
          "double-click on Cancel cancels exactly once")
        check(NetworkMock.cafe.forgets === 0,
          "double-click on Cancel never invokes Forget")
        check(panel.actionKind === "" && panel.forgetActive === false,
          "double-click on Cancel leaves both lanes idle")
        arm()
      } else if (step === 3) {
        // Saved WPA2 network, double-click on Cancel preserves the profile.
        panel.connectDirectly("HomeNet")
        var slot3 = slotFor("HomeNet", cancelGlyph)
        check(slot3 !== null, "the WPA2 row shows a Cancel slot while connecting")
        if (slot3) doubleClick(slot3)
        check(NetworkMock.device.disconnects === 1,
          "double-click on the WPA2 Cancel cancels exactly once")
        check(NetworkMock.home.forgets === 0,
          "double-click on the WPA2 Cancel never invokes Forget")
        check(NetworkMock.home.known === true,
          "double-click on the WPA2 Cancel preserves the saved profile")
        arm()
      } else if (step === 4) {
        // Explicit Forget stays functional on the passwordless row.
        var forgetSlot = slotFor("Cafe WiFi", forgetGlyph)
        check(forgetSlot !== null, "the saved open row shows a Forget slot when idle")
        if (forgetSlot) singleClick(forgetSlot)
        check(NetworkMock.cafe.forgets === 1,
          "an explicit click still forgets the saved open network")
        check(panel.forgetActive === true && panel.forgetSsid === "Cafe WiFi",
          "the explicit Forget tracks its own lane")
        NetworkMock.cafe.known = false
        panel.checkActionCompletion(NetworkMock.cafe)
        check(panel.forgetActive === false,
          "the Forget lane clears once NetworkManager confirms it")
        arm()
      } else if (step === 5) {
        // Explicit Forget stays functional on the saved WPA2 row. Its glyph
        // only appears once the action is focused or hovered, which is what
        // hovering the slot sets; drive the same state directly, then prove
        // the click path with a real event.
        panel.selectedIndex = indexOf("HomeNet")
        panel.wifiActionFocused = true
        var homeSlot = slotFor("HomeNet", forgetGlyph)
        check(homeSlot !== null, "the saved WPA2 row reveals a Forget slot on focus")
        if (homeSlot) singleClick(homeSlot)
        check(NetworkMock.home.forgets === 1,
          "an explicit click still forgets the saved WPA2 network")
        NetworkMock.home.known = false
        panel.checkActionCompletion(NetworkMock.home)
        check(panel.forgetActive === false,
          "the WPA2 Forget lane clears once NetworkManager confirms it")
        arm()
      } else if (step === 6) {
        // Two rapid Enter activations cannot Forget: the first cancels, and
        // the cleared keyboard focus keeps the second off the Forget lane.
        panel.connectDirectly("Cafe WiFi")
        focusRow("Cafe WiFi")
        NetworkMock.device.disconnects = 0
        panel.activateSelected()
        check(panel.actionKind === "" && NetworkMock.device.disconnects === 1,
          "Enter on the connecting row cancels and reaches NetworkManager")
        panel.activateSelected()
        check(NetworkMock.cafe.forgets === 0 && NetworkMock.home.forgets === 0,
          "a second Enter does not Forget the network")
        arm()
      } else if (step === 7) {
        // Prompt Cancel stays keyboard-reachable while connecting. Real key
        // injection reaches no QML item on the offscreen platform (verified
        // with a bare focused Item), so this drives the exact handlers the
        // keys reach and asserts the focus chain around them instead: the
        // Cancel button must actually hold focus when it appears, and the
        // passphrase field must take it back after the abort for the retry.
        panel.openPasswordPrompt("HomeNet")
        check(panel.passwordSsid === "HomeNet", "the passphrase prompt opens")
        panel.connectWithPassphrase("HomeNet", "hunter2")
        check(panel.isConnectTarget("HomeNet"), "the passphrase connect arms the lane")
      } else if (step === 8) {
        var cancelBtn = actionButton("HomeNet", "Cancel")
        check(cancelBtn !== null, "the prompt shows a Cancel button while connecting")
        check(cancelBtn !== null && cancelBtn.activeFocus,
          "the prompt Cancel button takes keyboard focus when it appears")
        panel.cancelNetworkAction()
        check(NetworkMock.device.disconnects === 1,
          "the prompt Cancel aborts the activation")
        check(panel.actionKind === "",
          "the prompt Cancel clears the connect lane")
        check(panel.passwordSsid === "HomeNet",
          "the prompt stays open so the credentials can be corrected")
      } else if (step === 9) {
        var pwField = credentialField("HomeNet", "Passphrase")
        check(pwField !== null && pwField.visible && pwField.enabled,
          "the passphrase field is back after the abort")
        check(pwField !== null && pwField.activeFocus,
          "focus returns to the passphrase field for correcting the credentials")
        panel.cancelPasswordPrompt()
        check(panel.passwordSsid === "",
          "a following Esc can still close the prompt")
        done()
      }
      step++
    }
  }

  function done() {
    if (failures > 0) {
      console.log("RESULT fail " + failures + " assertion(s)")
      Qt.quit()
      return
    }
    console.log("RESULT pass cancel-pointer-regression")
    Qt.quit()
  }

  Timer { interval: 25000; running: true; onTriggered: { console.log("RESULT fail timeout"); Qt.quit() } }
}
