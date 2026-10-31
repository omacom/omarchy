import QtQuick
import QtTest
import Quickshell
import qs.Ui
import "Monitor" as Monitor

FloatingWindow {
  id: root
  implicitWidth: 600
  implicitHeight: 200
  visible: true
  property var moves: []
  property var writes: []

  Monitor.BrightnessController { id: brightness }

  PanelSlider {
    id: slider
    anchors.fill: parent
    minimum: 1
    maximum: 100
    integer: true
    value: brightness.percent
    onMoved: function(value) { root.moves.push(value); brightness.preview(value) }
    onReleased: function(value) { root.writes.push(value); brightness.request(value) }
  }

  SignalSpy {
    id: verified
    target: brightness
    signalName: "verified"
  }

  TestCase {
    name: "BrightnessRuntime"
    when: root.visible

    function test_lifecycle() {
      brightness.acceptRead("A", "30", brightness.readGeneration())
      compare(brightness.percent, 30)
      if (Quickshell.env("OMARCHY_BRIGHTNESS_TEST_MODE") === "missing") {
        brightness.request(50, true)
        compare(brightness.percent, 50)
        tryCompare(brightness, "percent", 30)
        compare(verified.count, 0, "failed start cannot confirm or show an OSD")
        brightness.request(70)
        tryCompare(brightness, "percent", 30)
        console.log("BRIGHTNESS_RUNTIME_PASS")
        return
      }

      brightness.request(50, true)
      brightness.request(70)
      tryCompare(verified, "count", 1)
      compare(verified.signalArguments[0][0], 70, "normal exit confirms the trailing target and preserves wheel OSD")
      brightness.request(80, true)
      tryCompare(brightness, "percent", 70)
      compare(verified.count, 1, "failure rolls back without an OSD")
      brightness.request(60, true)
      tryCompare(brightness, "percent", 70)
      compare(verified.count, 1, "a crash cannot confirm brightness")

      brightness.preview(75)
      tryVerify(function() { return brightness.state.active === null && brightness.state.latest === null })
      brightness.request(80)
      tryCompare(brightness, "percent", 75)

      mousePress(slider, 200, 100, Qt.LeftButton)
      verify(slider.dragging)
      brightness.acceptRead("B", "85", brightness.readGeneration())
      slider.cancelDrag()
      wait(30)
      compare(slider.liveValue, 85)
      verify(!slider.dragging)
      var moveCount = root.moves.length
      mouseMove(slider, 300, 100, 10, Qt.LeftButton)
      mouseRelease(slider, 300, 100, Qt.LeftButton)
      wait(30)
      compare(root.moves.length, moveCount, "cancelled gesture cannot preview on the new monitor")
      compare(root.writes.length, 0, "cancelled release cannot write to the new monitor")

      mousePress(slider, 220, 100, Qt.LeftButton)
      brightness.acceptRead("A", "30", brightness.readGeneration())
      slider.cancelDrag()
      brightness.acceptRead("B", "85", brightness.readGeneration())
      slider.cancelDrag()
      wait(30)
      mouseRelease(slider, 220, 100, Qt.LeftButton)
      compare(root.writes.length, 0, "returning to a monitor cannot revive its old drag")
      mousePress(slider, 400, 100, Qt.LeftButton)
      mouseRelease(slider, 400, 100, Qt.LeftButton)
      compare(root.writes.length, 1, "a fresh drag writes normally")
      tryVerify(function() { return brightness.state.active === null && brightness.state.latest === null })
      console.log("BRIGHTNESS_RUNTIME_PASS")
    }
  }
}
