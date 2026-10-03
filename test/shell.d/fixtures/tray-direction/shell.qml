import QtQuick
import Quickshell
import "widgets"

ShellRoot {
  id: test
  property int caseIndex: -1
  property int frameCount: 0
  property real fixedExtent: 0
  property real pinnedPosition: 0
  property var cases: []
  property var savedEntry: null
  property var savedId: null
  property string captureDir: Quickshell.env("OMARCHY_TRAY_CAPTURE_DIR")

  function check(condition, message) {
    if (!condition) {
      console.error("FAIL: case " + caseIndex + ": " + message)
      Qt.quit()
      throw new Error(message)
    }
  }

  function layout() {
    for (var i = 0; i < tray.children.length; i++) {
      if (tray.children[i].item) return tray.children[i].item
    }
    throw new Error("tray layout not loaded")
  }

  function axis(item) { return host.vertical ? item.y : item.x }
  function extent(item) { return host.vertical ? item.height : item.width }

  function verifyFrame() {
    var content = layout(), drawer = content.children[0], pins = content.children[1]
    var chevron = drawer.children[0], clip = drawer.children[1]
    check(extent(tray) === fixedExtent, "tray extent changed during animation")
    check(axis(pins) === pinnedPosition, "pinned targets moved during animation")
    check(chevron.textRotation === (host.vertical ? (tray.drawerReversed ? 270 : 90) : (tray.drawerReversed ? 180 : 0)), "chevron direction")
    var revealed = tray.revealExtent
    var iconEnd = axis(clip) + axis(clip.children[0]) + tray.drawerExtent
    if (tray.drawerReversed) {
      check(Math.abs(iconEnd - axis(chevron)) < 0.001, "drawer icons overlap reversed chevron")
      check(axis(drawer) === extent(pins), "reversed drawer must follow pins")
    } else {
      check(Math.abs(axis(clip) + axis(clip.children[0]) - axis(chevron) - extent(chevron)) < 0.001, "drawer icons overlap forward chevron")
    }
    for (var p = 0.5; p < fixedExtent; p++) {
      var point = host.vertical ? Qt.point(tray.width / 2, p) : Qt.point(p, tray.height / 2)
      var expected = tray.drawerReversed
        ? p <= extent(pins) + extent(chevron) + revealed
        : p >= tray.drawerExtent - revealed
      check(content.containmentMask.contains(point) === expected, "reserved-space hit mask at " + p)
    }
    frameCount++
  }

  function capture(state, done) {
    if (captureDir && tray.pinnedIds.length && tray.testDrawerCount) {
      canvas.grabToImage(function(result) {
        result.saveToFile(test.captureDir + "/case-" + test.caseIndex + "-" + state + ".png")
        done()
      })
    } else done()
  }

  function nextCase() {
    caseIndex++
    if (caseIndex === cases.length) {
      check(frameCount > 100, "animation frames exercised")
      console.log("PASS: tray direction, stationary pins, clipping, hit masks, settings; " + frameCount + " frames")
      Qt.quit()
      return
    }
    var c = cases[caseIndex]
    host.vertical = c.vertical
    tray.settings = {drawerReversed: c.reversed, pinned: c.pins ? ["pin-1", "pin-2"] : [], hidden: [], customSetting: "keep"}
    tray.testDrawerCount = c.drawers
    tray.expanded = false
    settle.restart()
  }

  function verifyPersistence() {
    for (var forced of [false, true]) {
      tray.settings = {id: "stale-id", drawerReversed: forced, pinned: [], hidden: [], customSetting: "keep"}
      for (var action of ["togglePin", "togglePin", "toggleHide", "toggleHide"]) {
        tray[action]("pin-1")
        check(savedId === "test.tray" && savedEntry.id === "test.tray", "clone entry id preserved")
        check(savedEntry.drawerReversed === forced && savedEntry.customSetting === "keep", "settings preserved by " + action)
        tray.settings = savedEntry
      }
      check(savedEntry.pinned.length === 0 && savedEntry.hidden.length === 0, "pin/hide toggles round trip")
    }
    tray.settings = {}
    for (var region of ["left", "center", "right"]) {
      var config = {left: [], center: [], right: []}
      config[region] = ["test.tray"]
      host.layoutConfig = config
      check(tray.drawerReversed === (region === "left"), "clone region detection: " + region)
      config = {left: [], center: [], right: []}
      config[region] = [{id: "test.tray"}]
      host.layoutConfig = config
      check(tray.drawerReversed === (region === "left"), "object entry region detection: " + region)
    }
  }

  QtObject {
    id: host
    property bool vertical: false
    property int barSize: 36
    property color foreground: "#ffffff"
    property color barForeground: "#ffffff"
    property color urgent: "#ff0000"
    property bool foregroundAnimationEnabled: false
    function hideTooltip(item) {}
    function showTooltip(item, text) {}
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string position: vertical ? "right" : "top"
    property var layoutConfig: ({left: ["test.tray"], center: [], right: []})
    property var shell: QtObject {
      function updateEntryInline(id, entry) { test.savedId = id; test.savedEntry = entry }
    }
  }

  FloatingWindow {
    visible: true
    implicitWidth: 440
    implicitHeight: 260
    color: "#202020"

    Item {
      id: canvas
      anchors.fill: parent
      Rectangle { anchors.fill: parent; color: "#202020" }
      Text { x: 20; y: 12; color: "white"; text: (host.vertical ? "Vertical" : "Horizontal") + (tray.drawerReversed ? " reversed" : " forward") + (tray.expanded ? " open" : " closed") }
      Tray {
        id: tray
        x: 30; y: 50
        width: implicitWidth; height: implicitHeight
        bar: host
        moduleName: "test.tray"
        property int testDrawerCount: 3
        function bucket(category) {
          var pins = [], drawers = []
          for (var i = 0; i < pinnedIds.length; i++) pins.push(fakeItem(pinnedIds[i], "#70e090", i + 1))
          for (var j = 0; j < testDrawerCount; j++) drawers.push(fakeItem("drawer-" + j, "#f0a050", j + 1))
          return category === "pinned" ? pins : category === "drawer" ? drawers : pins.concat(drawers)
        }
        function fakeItem(id, color, number) {
          return {id: id, status: 1, title: id, icon: "data:image/svg+xml," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><rect width="24" height="24" rx="4" fill="' + color + '"/><text x="12" y="18" text-anchor="middle" font-size="18">' + number + '</text></svg>')}
        }
      }
    }
  }

  Timer {
    id: settle
    interval: 750
    onTriggered: {
      test.fixedExtent = test.extent(tray)
      test.pinnedPosition = test.axis(test.layout().children[1])
      test.verifyFrame()
      test.capture("closed", function() {
        tray.expanded = true
        frames.start()
        opened.start()
      })
    }
  }
  Timer { id: frames; interval: 16; repeat: true; onTriggered: test.verifyFrame() }
  Timer {
    id: opened
    interval: 750
    onTriggered: {
      test.verifyFrame()
      test.capture("open", function() {
        tray.expanded = false
        closed.start()
      })
    }
  }
  Timer {
    id: closed
    interval: 750
    onTriggered: { test.verifyFrame(); frames.stop(); test.nextCase() }
  }
  Timer {
    interval: 100
    running: true
    onTriggered: {
      test.verifyPersistence()
      var list = []
      for (var vertical of [false, true])
        for (var reversed of [false, true])
          for (var pins of [false, true])
            for (var drawers of [0, 3])
              list.push({vertical: vertical, reversed: reversed, pins: pins, drawers: drawers})
      test.cases = list
      test.nextCase()
    }
  }
}
