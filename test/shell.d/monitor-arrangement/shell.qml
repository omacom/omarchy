import QtQuick
import QtTest
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons as Commons

// Real controls + real Python backend; only the compositor is simulated.
ShellRoot {
  id: root
  property int phase: 0
  property int ticks: 0
  property int beforeTicks: 0
  property double beforeTime: 0
  property var failures: []
  property var checks: []
  property bool finished: false
  property bool keyboardFixtureActive: false
  property int droppedY: 0
  property int keyboardX: 0
  readonly property var ui: controls.item
  readonly property var secondUi: secondControls.item
  readonly property string testDir: Quickshell.env("ARRANGEMENT_TEST_DIR")
  readonly property string resultPath: Quickshell.env("ARRANGEMENT_TEST_RESULT")

  function check(condition, message) {
    if (!condition) {
      failures.push(message)
      console.warn(message + ": " + JSON.stringify({phase: phase, busy: ui.busy, message: ui.message, monitors: ui.monitors, preview: ui.preview}))
    }
  }
  function child(name, item) {
    item = item || ui
    if (item.objectName === name) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = child(name, item.children[i])
      if (found) return found
    }
    return null
  }
  function screen(name) {
    return ui.monitors.filter(function(m) { return m.name === name })[0]
  }
  function configure(values) {
    control.command = ["python3", testDir + "/fake-hyprctl.py", "--control", JSON.stringify(values)]
    control.running = true
  }
  function done(name) { checks.push(name) }
  function finish() {
    if (finished) return
    finished = true
    writer.command = ["python3", "-c", "import pathlib,sys; pathlib.Path(sys.argv[1]).write_text(sys.argv[2])",
                      resultPath, JSON.stringify({ok: failures.length === 0, checks: checks, failures: failures})]
    writer.running = true
  }

  Process { id: control }
  Process { id: writer; onExited: Qt.quit() }

  FloatingWindow {
    implicitWidth: 400
    implicitHeight: 650
    visible: true
    PanelKeyCatcher {
      id: keyboard
      anchors.fill: parent
      blocked: root.ui && (root.ui.popupOpen || root.ui.coordinateEditing)
      onActivateRequested: if (root.ui) root.ui.activate(root.ui.cursorIndex)
    }
    Connections {
      target: root.ui
      function onCoordinateEditingFinished() { keyboard.forceActiveFocus() }
      function onCursorRequested(index, item) {
        if (root.keyboardFixtureActive) root.ui.cursorIndex = index
      }
    }
    TestCase { id: pointer; name: "Arrangement pointer input"; when: false }
    Loader {
      id: controls
      parent: keyboard
      width: 380
      active: false
      source: "file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/panels/monitor/Arrangement.qml"
      onLoaded: { item.width = width; item.identificationScreens = []; item.displayCount = 3; item.expanded = true; item.showPresets = true; item.active = true }
    }
    Loader {
      id: secondControls
      width: 380
      active: false
      source: controls.source
      onLoaded: { item.width = width; item.identificationScreens = []; item.displayCount = 3; item.expanded = true; item.showPresets = true; item.active = true }
    }
  }

  Timer {
    interval: 20
    running: !root.finished
    repeat: true
    onTriggered: {
      root.ticks++
      if (root.ticks > 2800) { root.failures.push("Timed out in phase " + root.phase); root.finish(); return }
      if (control.running) return
      switch (root.phase) {
      case 0:
        root.configure({reset: true, delay: 0.6})
        root.phase++
        break
      case 1:
        controls.active = true
        root.beforeTicks = root.ticks
        root.phase++
        break
      case 2:
        if (!ui || ui.busy) return
        root.check(root.ticks - root.beforeTicks >= 15, "Delayed query leaves the event loop responsive")
        root.check(ui.monitors.length === 3 && !ui.canApply, "Startup loads three displays without applying")
        root.check(ui.moving === "DP-3" && ui.reference === "eDP-1", "Defaults choose distinct moving/reference screens")
        root.done("responsive startup")
        root.configure({delay: 0})
        root.phase++
        break
      case 3:
        root.child("arrangementLeft").clicked()
        root.phase++
        break
      case 4:
        if (ui.busy) return
        root.check(ui.canApply && ui.preview[2].x === -1280 && root.screen("DP-3").x === 3840, "Left previews without changing the displays")
        var englishMessage = ui.message
        var originalStrings = Commons.I18n.strings
        var originalDigit = Commons.I18n.zeroDigit
        var translatedStrings = Object.assign({}, originalStrings)
        translatedStrings["monitor.arrangementPreviewLeft"] = "%3 / %2 / %1"
        translatedStrings["monitor.arrangeTop"] = "HAUT"
        Commons.I18n.strings = translatedStrings
        Commons.I18n.zeroDigit = "٠"
        root.check(ui.displayMessage() === "HAUT / eDP-1 / DP-3", "Preset status supports translated placeholder order")
        root.check(root.child("arrangementMoving").options[0].label.indexOf("١") === 0, "Displayed screen numbers follow locale digits")
        root.check(ui.message === englishMessage, "Translation preserves the English IPC message")
        Commons.I18n.strings = originalStrings
        Commons.I18n.zeroDigit = originalDigit
        root.child("arrangementMoving").changed("DP-2")
        root.check(ui.moving === "DP-2" && ui.canApply && ui.preview.length === 3, "Changing selection retains other unsaved screen moves")
        root.done("preview and selection")
        root.child("arrangementDiscard").clicked()
        ui.selectScreen("DP-3")
        root.child("arrangementBelow").clicked()
        root.phase++
        break
      case 5:
        if (ui.busy) return
        root.check(ui.canApply, "Below preview can be applied")
        root.child("arrangementApply").clicked()
        root.check(ui.busy && !root.child("arrangementApply").enabled && !root.child("arrangementMoving").enabled, "Apply disables conflicting controls")
        root.phase++
        break
      case 6:
        if (root.child("arrangementApply").text === "Keep layout") { root.check(false, "One Apply click must save without asking for Keep"); root.finish(); return }
        if (ui.busy) return
        root.check(root.screen("DP-3").y === 1080 && ui.message.indexOf("saved") >= 0 && !ui.canApply, "Apply saves and refreshes the actual layout")
        root.done("successful Apply")
        root.configure({reloadError: true})
        root.child("arrangementLeft").clicked()
        root.phase++
        break
      case 7:
        if (ui.busy) return
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 8:
        if (ui.busy) return
        root.check(ui.error && ui.message.indexOf("restored") >= 0 && !ui.canApply, "Failed Apply reports rollback and clears preview")
        root.child("arrangementRefresh").clicked()
        root.phase++
        break
      case 9:
        if (ui.busy) return
        root.check(root.screen("DP-3").y === 1080, "Rollback restored the saved display layout")
        root.child("arrangementLeft").clicked()
        root.phase++
        break
      case 10:
        if (ui.busy) return
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 11:
        if (ui.busy) return
        root.check(!ui.error && root.screen("DP-3").x === -1280, "Apply can be retried after rollback")
        root.done("rollback and retry")
        root.child("arrangementAbove").clicked()
        root.phase++
        break
      case 12:
        if (ui.busy) return
        root.configure({move: true})
        root.phase++
        break
      case 13:
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 14:
        if (ui.busy) return
        root.check(ui.error && ui.message.indexOf("changed since") >= 0 && !ui.canApply, "Apply rejects a stale preview")
        root.done("stale preview")
        root.configure({disconnect: true, delay: 0.5})
        root.phase++
        break
      case 15:
        root.child("arrangementRefresh").clicked()
        root.beforeTicks = root.ticks
        root.check(ui.busy && !ui.ready, "Refresh disables arrangement controls")
        root.phase++
        break
      case 16:
        if (ui.busy) return
        root.check(root.ticks - root.beforeTicks >= 10 && ui.monitors.length === 1 && !ui.ready && ui.preview.length === 0, "Delayed refresh handles a disconnected screen")
        root.done("responsive refresh and disconnection")
        root.configure({readError: true, delay: 0})
        root.phase++
        break
      case 17:
        root.child("arrangementRefresh").clicked()
        root.phase++
        break
      case 18:
        if (ui.busy) return
        root.check(ui.error && ui.monitors.length === 0 && !ui.canApply && root.child("arrangementRefresh").enabled, "Failed refresh leaves a usable retry control")
        root.configure({reset: true})
        root.phase++
        break
      case 19:
        root.child("arrangementRefresh").clicked()
        root.phase++
        break
      case 20:
        if (ui.busy) return
        root.check(!ui.error && ui.ready, "Refresh recovers after query failure")
        root.done("refresh recovery")
        root.configure({delay: 0.5})
        root.phase++
        break
      case 21:
        root.child("arrangementRefresh").clicked()
        ui.active = false
        root.check(ui.busy, "Closing does not block on an in-flight query")
        root.phase++
        break
      case 22:
        if (ui.busy) return
        ui.active = true
        root.phase++
        break
      case 23:
        if (ui.busy) return
        root.check(ui.ready && !ui.canApply, "Reopening refreshes the screens without applying")
        root.done("close and reopen during query")
        root.configure({reset: true, reloadDelay: 0.5})
        root.phase++
        break
      case 24:
        ui.refresh()
        secondControls.active = true
        root.phase++
        break
      case 25:
        if (ui.busy || !secondUi || secondUi.busy) return
        ui.selectScreen("DP-3")
        root.child("arrangementLeft").clicked()
        root.child("arrangementBelow", secondUi).clicked()
        root.phase++
        break
      case 26:
        if (ui.busy || secondUi.busy) return
        root.check(ui.canApply && secondUi.canApply, "Two panel instances can each preview a layout")
        root.child("arrangementApply").clicked()
        root.child("arrangementApply", secondUi).clicked()
        root.phase++
        break
      case 27:
        if (ui.busy || secondUi.busy) return
        root.check(ui.error !== secondUi.error && (ui.error ? secondUi : ui).message.indexOf("saved") >= 0,
                   "Only one competing panel transaction saves its preview")
        var rejected = (ui.error ? ui : secondUi).message
        root.check((rejected.indexOf("in progress") >= 0 || rejected.indexOf("changed since") >= 0) && !ui.canApply && !secondUi.canApply,
                   "The competing panel reports a lock or stale preview and clears its preview")
        root.done("competing panel instances")
        secondControls.active = false
        root.configure({reset: true})
        root.phase++
        break
      case 28:
        ui.refresh()
        root.phase++
        break
      case 29:
        if (ui.busy) return
        ui.selectScreen("DP-3")
        root.child("arrangementLeft").clicked()
        root.phase++
        break
      case 30:
        if (ui.busy) return
        root.check(ui.alignmentOptions.join(",") === "top,center,bottom", "Horizontal positions offer vertical alignment")
        root.child("arrangementAlignment").changed("bottom")
        root.phase++
        break
      case 31:
        if (ui.busy) return
        root.check(ui.preview[2].x === -1280 && ui.preview[2].y === 360 && root.screen("DP-3").y === 0,
                   "Bottom alignment previews unequal display heights without applying")
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 32:
        if (ui.busy) return
        root.check(root.screen("DP-3").y === 360 && ui.message.indexOf("saved") >= 0, "Apply saves the chosen bottom alignment")
        root.child("arrangementAbove").clicked()
        root.phase++
        break
      case 33:
        if (ui.busy) return
        root.check(ui.alignmentOptions.join(",") === "left,center,right" && ui.alignment === "left",
                   "Vertical positions offer horizontal alignment and clear incompatible choices")
        root.child("arrangementAlignment").changed("right")
        root.phase++
        break
      case 34:
        if (ui.busy) return
        root.check(ui.preview[2].x === 640 && ui.preview[2].y === -720, "Right alignment previews unequal display widths")
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 35:
        if (ui.busy) return
        root.check(root.screen("DP-3").x === 640 && root.screen("DP-3").y === -720, "Apply saves the chosen right alignment")
        root.child("arrangementLeft").clicked()
        root.phase++
        break
      case 36:
        if (ui.busy) return
        root.child("arrangementAlignment").changed("center")
        root.phase++
        break
      case 37:
        if (ui.busy) return
        root.check(ui.preview[2].y === 180 && root.screen("DP-3").y === -720, "Center alignment previews without applying")
        root.done("edge and center alignment")
        root.child("arrangementIdentify").clicked()
        root.check(ui.identifying, "Identify starts the screen labels")
        root.beforeTime = Date.now()
        root.phase++
        break
      case 38:
        if (Date.now() - root.beforeTime < 2000) return
        root.check(ui.identifying, "Labels remain visible briefly")
        root.child("arrangementIdentify").clicked()
        root.beforeTime = Date.now()
        root.phase++
        break
      case 39:
        if (Date.now() - root.beforeTime < 1000) return
        root.check(ui.identifying, "Clicking Identify again restarts its timeout")
        root.phase++
        break
      case 40:
        if (ui.identifying) return
        root.check(Date.now() - root.beforeTime >= 3500 && ui.canApply && root.screen("DP-3").y === -720,
                   "Labels hide automatically without changing the preview or applying it")
        root.done("timed screen identification")
        root.child("arrangementToggle").clicked()
        root.check(!ui.expanded && !ui.ready && !ui.identifying, "Chevron closes the controls")
        ui.displayCount = 1
        root.check(!ui.visible && !ui.expanded, "One enabled display hides the entire Arrangement section")
        ui.displayCount = 3
        root.check(ui.visible && !ui.expanded && !ui.busy, "Multiple displays show a collapsed row without querying")
        root.child("arrangementToggle").clicked()
        root.phase++
        break
      case 41:
        if (ui.busy) return
        root.check(ui.expanded && ui.ready && !ui.canApply, "Chevron opens controls and refreshes the current layout")
        ui.displayCount = 1
        root.check(!ui.visible && !ui.expanded, "Losing the second display also closes the controls")
        root.done("conditional collapsible Arrangement")
        root.configure({reset: true})
        ui.displayCount = 3
        root.child("arrangementToggle").clicked()
        root.phase++
        break
      case 42:
        if (ui.busy) return
        ui.refresh()
        root.phase++
        break
      case 43:
        if (ui.busy) return
        var tile = root.child("arrangementScreenDP-3")
        var diagram = root.child("arrangementDiagram")
        var origin = tile.mapToItem(diagram, tile.width / 2, tile.height / 2)
        pointer.mousePress(tile, tile.width / 2, tile.height / 2)
        pointer.mouseMove(diagram, origin.x - 5120 * diagram.fit, origin.y + 123 * diagram.fit)
        pointer.mouseRelease(diagram, origin.x - 5120 * diagram.fit, origin.y + 123 * diagram.fit)
        root.phase++
        break
      case 44:
        if (ui.busy) return
        root.check(ui.canApply && ui.preview[2].x === -1280 && ui.preview[2].y >= 110 && ui.preview[2].y <= 140 && root.screen("DP-3").x === 3840,
                   "Mouse drag snaps the contacting edge while retaining an arbitrary offset")
        root.droppedY = ui.preview[2].y
        ui.selectScreen("DP-2")
        root.child("arrangementBelow").clicked()
        root.phase++
        break
      case 45:
        if (ui.busy) return
        root.check(ui.preview[2].x === -1280 && ui.preview[1].y === 1080, "A second move retains the first draft screen")
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 46:
        if (ui.busy) return
        root.check(root.child("arrangementApply").text === "Apply layout" && root.child("arrangementDiscard").text === "Discard changes",
                   "Apply completes without Keep or Revert controls")
        root.check(root.screen("DP-3").x === -1280 && root.screen("DP-3").y === root.droppedY && root.screen("DP-2").y === 1080,
                   "One Apply click saves all drafted screens together")
        root.phase++
        break
      case 47:
        root.done("mouse drag, arbitrary offsets and single-click Apply")
        ui.selectScreen("DP-3")
        root.child("arrangementAbove").clicked()
        root.phase++
        break
      case 48:
        if (ui.busy) return
        root.child("arrangementApply").clicked()
        root.phase++
        break
      case 49:
        if (ui.busy) return
        root.check(root.screen("DP-3").y === -720 && ui.message.indexOf("saved") >= 0, "Apply saves the next arrangement immediately")
        root.beforeTime = Date.now()
        ui.active = false
        root.phase++
        break
      case 50:
        if (Date.now() - root.beforeTime < 21000) return
        root.done("saved layout persists past the former confirmation deadline")
        ui.active = true
        root.phase++
        break
      case 51:
        if (ui.busy) return
        root.check(root.screen("DP-3").y === -720 && ui.ready, "Reopening after 21 seconds reads the saved layout without reverting")
        root.keyboardX = root.screen("DP-3").x
        ui.nudge(1, 0)
        root.phase++
        break
      case 52:
        if (ui.busy) return
        root.check(ui.preview[2].x === root.keyboardX + 1, "Keyboard movement changes one logical pixel")
        root.child("arrangementDiscard").clicked()
        root.check(!ui.canApply && ui.preview.length === 0 && root.screen("DP-3").x === root.keyboardX,
                   "Discard clears the draft without moving physical screens")
        root.done("precise keyboard movement and Discard")
        ui.nudge(1, 0)
        root.phase++
        break
      case 53:
        if (ui.busy) return
        root.child("arrangementApply").clicked()
        ui.active = false
        root.phase++
        break
      case 54:
        if (ui.busy) return
        ui.active = true
        root.phase++
        break
      case 55:
        if (ui.busy) return
        root.check(root.screen("DP-3").x === root.keyboardX + 1, "Closing during Apply still finishes saving the layout")
        root.keyboardX += 1
        root.done("closing during immediate Apply")
        ui.nudge(1, 0)
        root.phase++
        break
      case 56:
        if (ui.busy) return
        ui.selectScreen("DP-2")
        root.child("arrangementAbove").clicked()
        root.phase++
        break
      case 57:
        if (ui.busy) return
        root.check(ui.error && ui.canApply && ui.preview[2].x === root.keyboardX + 1 && ui.preview[1].y === 1080,
                   "A rejected second preset keeps the earlier valid draft moves")
        root.child("arrangementDiscard").clicked()
        root.done("invalid preset preserves earlier draft")
        ui.selectScreen("DP-3")
        ui.nudge(1, 0)
        root.phase++
        break
      case 58:
        if (ui.busy) return
        root.keyboardFixtureActive = true
        ui.cursorIndex = ui.indexOf(root.child("arrangementDiagram"))
        keyboard.forceActiveFocus()
        pointer.keyClick(Qt.Key_Return)
        root.check(ui.keyboardEditing, "Enter starts editing the selected diagram")
        var apply = root.child("arrangementApply")
        pointer.mouseMove(apply, apply.width / 2, apply.height / 2)
        root.phase++
        break
      case 59:
        root.check(ui.cursorIndex === ui.indexOf(root.child("arrangementApply")), "Actual mouse hover selects Apply")
        root.check(!ui.keyboardEditing, "Leaving the diagram ends keyboard editing before another control is highlighted")
        // An activation arriving before the cursor binding settles must still end editing.
        ui.keyboardEditing = true
        keyboard.forceActiveFocus()
        pointer.keyClick(Qt.Key_Return)
        root.check(!ui.keyboardEditing && !ui.busy && ui.canApply,
                   "Enter finishes editing without starting the highlighted Apply action")
        root.child("arrangementDiscard").clicked()
        root.done("hover and Enter end keyboard editing safely")
        ui.showPresets = true
        root.keyboardFixtureActive = false
        root.child("arrangementMoving").open()
        root.phase++
        break
      case 60:
        pointer.keyClick(Qt.Key_Up)
        pointer.keyClick(Qt.Key_Return)
        root.check(ui.moving === "DP-2" && root.child("arrangementMoving").value === "DP-2", "Actual dropdown selection updates moving screen")
        ui.selectScreen("eDP-1")
        root.check(root.child("arrangementMoving").value === "eDP-1", "Diagram selection refreshes dropdown after its own selection")
        root.child("arrangementReference").open()
        root.phase++
        break
      case 61:
        pointer.keyClick(Qt.Key_Down)
        pointer.keyClick(Qt.Key_Return)
        ui.selectScreen(ui.reference)
        root.check(root.child("arrangementReference").value === ui.reference && ui.reference !== ui.moving, "Changing moving screen refreshes the reference picker binding")
        ui.selectScreen("DP-3")
        ui.reference = "eDP-1"
        ui.chooseSide("left")
        root.phase++
        break
      case 62:
        if (ui.busy) return
        root.child("arrangementAlignment").open()
        root.phase++
        break
      case 63:
        pointer.keyClick(Qt.Key_Down)
        pointer.keyClick(Qt.Key_Down)
        pointer.keyClick(Qt.Key_Return)
        root.phase++
        break
      case 64:
        if (ui.busy) return
        root.check(ui.alignment === "bottom" && root.child("arrangementAlignment").value === "bottom", "Actual alignment selection updates draft")
        ui.discard()
        root.check(ui.alignment === "top" && root.child("arrangementAlignment").value === "top", "Discard restores alignment dropdown binding")
        root.done("real dropdown selection and binding restoration")
        var y = root.child("arrangementY")
        y.field.contentItem.forceActiveFocus()
        y.field.contentItem.selectAll()
        pointer.keyClick(Qt.Key_Minus); pointer.keyClick(Qt.Key_7); pointer.keyClick(Qt.Key_2); pointer.keyClick(Qt.Key_0)
        pointer.keyClick(Qt.Key_Return)
        root.phase++
        break
      case 65:
        if (ui.busy) return
        var x = root.child("arrangementX")
        x.field.contentItem.forceActiveFocus()
        x.field.contentItem.selectAll()
        pointer.keyClick(Qt.Key_1); pointer.keyClick(Qt.Key_2); pointer.keyClick(Qt.Key_3)
        pointer.keyClick(Qt.Key_Return)
        root.phase++
        break
      case 66:
        if (ui.busy) return
        root.check(ui.preview[2].x === 123 && ui.preview[2].y === -720 && ui.canApply, "Typed X/Y builds a connected read-only preview")
        ui.discard()
        root.check(root.child("arrangementX").field.value === root.screen("DP-3").x, "Discard resets the numeric editor to live geometry")
        root.done("exact X/Y input and Discard")
        ui.selectScreen("DP-2")
        ui.reference = "eDP-1"
        ui.chooseCoordinate("x", 6000)
        root.phase++
        break
      case 67:
        if (ui.busy) return
        root.check(!ui.connected && !ui.canApply && ui.message.indexOf("disconnected") >= 0, "An isolated screen keeps a draft but disables Apply")
        ui.chooseCoordinate("x", 123)
        root.phase++
        break
      case 68:
        if (ui.busy) return
        root.check(ui.connected && ui.canApply && ui.preview[1].x === 123 && ui.preview[1].y === 1080, "A subsequent move repairs the disconnected layout")
        root.done("disconnected drafts and whole-layout repair")
        ui.discard()
        root.child("arrangementX").field.contentItem.forceActiveFocus()
        pointer.keyClick(Qt.Key_Return)
        root.phase++
        break
      case 69:
        root.check(!ui.coordinateEditing && keyboard.activeFocus, "Unchanged coordinate Enter restores panel keyboard navigation")
        root.child("arrangementX").field.contentItem.forceActiveFocus()
        pointer.keyClick(Qt.Key_Escape)
        root.phase++
        break
      case 70:
        root.check(!ui.coordinateEditing && keyboard.activeFocus, "Coordinate Escape restores panel keyboard navigation")
        root.done("coordinate keyboard focus return")
        root.finish()
        break
      }
    }
  }
}
