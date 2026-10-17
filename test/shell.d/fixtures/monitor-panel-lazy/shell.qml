import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: test
  property int phase: 0
  property int ticks: 0
  property var first: null
  readonly property var ui: controls.item
  function check(ok, message) {
    if (!ok) { console.log("RESULT fail " + message); Qt.quit() }
  }
  QtObject {
    id: bar
    property bool foregroundAnimationEnabled: false
    property color background: "#222222"
    property color foreground: "white"
    property color barForeground: "white"
    property color urgent: "red"
    property string fontFamily: "monospace"
    property string position: "top"
    property bool vertical: false
    property int barSize: 24
    property var activePopout: null
    function requestPopout(item) { activePopout = item }
    function releasePopout(item) { activePopout = null }
    function hideTooltip(item) {}
  }
  Loader {
    id: controls
    source: "file://" + Quickshell.env("MONITOR_PANEL_SOURCE")
    onLoaded: { item.bar = bar; item.width = 32; item.height = 32 }
  }
  Timer {
    interval: 30
    repeat: true
    running: true
    onTriggered: {
      test.ticks++
      if (test.ticks > 300) { test.check(false, "timeout in phase " + test.phase); return }
      if (!ui || ui.displays.length !== 3) return
      switch (test.phase) {
      case 0:
        test.check(ui.arrangement === null, "closed panel has no Arrangement instance")
        test.check(JSON.parse(ui.stateIpc()).arrangement.expanded === false, "state IPC works before first open")
        ui.open()
        test.phase++
        break
      case 1:
        if (!ui.arrangement) return
        test.first = ui.arrangement
        ui.arrangement.expanded = true
        test.phase++
        break
      case 2:
        if (ui.arrangement.busy) return
        test.check(ui.arrangement.monitors.length === 3, "lazy content reads monitors")
        ui.arrangement.chooseSide("left")
        test.phase++
        break
      case 3:
        if (ui.arrangement.busy) return
        test.check(ui.arrangement.canApply, "lazy content builds a connected preview")
        ui.arrangement.applyDraft()
        ui.close()
        test.check(ui.arrangement === test.first, "close retains the running Arrangement")
        test.phase++
        break
      case 4:
        if (ui.arrangement.busy) return
        ui.open()
        test.phase++
        break
      case 5:
        if (ui.arrangement.busy) return
        test.check(ui.arrangement === test.first, "reopen reuses the same content")
        test.check(ui.arrangement.monitors[2].x === -1280, "close during Apply saves its layout")
        test.check(JSON.parse(ui.stateIpc()).arrangement.visible, "state IPC reaches lazy Arrangement")
        ui.close()
        console.log("RESULT pass")
        Qt.quit()
        break
      }
    }
  }
}
