import QtQuick
import QtQuick.Window
import Quickshell
import "Commons" as Commons

ShellRoot {
  id: test
  property var failures: []
  property var body: null
  property int attempts: 0
  property int stage: 0

  function check(condition, message) {
    if (!condition) failures.push(message)
  }

  function find(item, predicate) {
    if (predicate(item)) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = find(children[i], predicate)
      if (found) return found
    }
    return null
  }

  function finish() {
    checks.stop()
    Quickshell.execDetached(["/bin/bash", "-c", 'printf %s "$1" > "$2"', "result",
      JSON.stringify({ ok: failures.length === 0, failures: failures }), Quickshell.env("OMARCHY_QML_TEST_RESULT")])
  }

  QtObject {
    id: host
    property bool contributions: true
    function panelExtensionsFor(point) {
      return contributions ? [
        { id: "test.first", source: Qt.resolvedUrl("TallExtension.qml").toString(), settings: {} },
        { id: "test.second", source: Qt.resolvedUrl("TallExtension.qml").toString(), settings: {} }
      ] : []
    }
    function configurePanelExtension(item, id) {}
  }

  QtObject {
    id: fixtureBar
    property var shell: host
    property color foreground: Commons.Color.foreground
    property color barForeground: foreground
    property color background: Commons.Color.background
    property color urgent: Commons.Color.urgent
    property string fontFamily: "monospace"
    property string position: "top"
    property bool vertical: false
    property int barSize: 30
    property bool transparent: false
    property bool foregroundAnimationEnabled: false
    function hideTooltip(item) {}
  }

  PowerPanel {
    id: power
    bar: fixtureBar
    profiles: ["power-saver", "balanced", "performance"]
  }

  Window {
    id: window
    visible: true
    width: 420
    height: 200
    Item { id: viewport; anchors.fill: parent }
  }

  Timer {
    id: checks
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      test.attempts++
      if (test.attempts > 80) {
        test.check(false, "popup content did not settle at stage " + test.stage)
        test.finish()
        return
      }
      if (!test.body) {
        for (var i = 0; i < power.data.length; i++) {
          if (typeof power.data[i].ensureContent === "function") {
            test.body = power.data[i].content.createObject(viewport)
            break
          }
        }
        return
      }
      if (test.body.implicitHeight < 1000 && test.stage === 0) return
      var flick = test.find(test.body, function(item) { return item.contentY !== undefined && item.contentHeight !== undefined })
      test.check(flick !== null, "capped popup content provides a scrollable viewport")
      if (!flick) { test.finish(); return }
      if (test.stage === 0) {
        test.check(flick.height <= viewport.height, "scroll viewport fits the capped popup")
        test.check(flick.contentHeight > flick.height, "tall contributions remain in the scrollable content")
        flick.contentY = flick.contentHeight - flick.height
        var last = test.find(test.body, function(item) { return item.text === "Performance" && item.hasCursor !== undefined })
        test.check(last !== null, "power profile controls remain present")
        if (last) {
          var point = last.mapToItem(flick.contentItem, 0, 0)
          test.check(point.y >= flick.contentY && point.y + last.height <= flick.contentY + flick.height + 1,
            "scrolling reaches the final power profile control")
        }
        flick.contentY = 0
        test.body.moveRequested(0, 1)
        test.stage = 1
      } else if (test.stage === 1) {
        var selected = test.find(test.body, function(item) { return item.hasCursor === true })
        test.check(selected !== null, "keyboard navigation selects a power profile")
        if (selected) {
          var selectedPoint = selected.mapToItem(flick.contentItem, 0, 0)
          test.check(selectedPoint.y >= flick.contentY && selectedPoint.y + selected.height <= flick.contentY + flick.height + 1,
            "keyboard selection is scrolled into view")
        }
        host.contributions = false
        window.height = 1000
        test.stage = 2
      } else if (test.stage === 2 && test.body.implicitHeight < 1000) {
        test.check(flick.contentY === 0, "short content returns to the top after extensions collapse")
        test.check(flick.contentWidth <= flick.width, "popup does not require horizontal scrolling")
        test.finish()
      }
    }
  }
}
