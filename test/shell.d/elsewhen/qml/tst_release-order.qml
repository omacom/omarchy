import QtQuick
import QtTest

Item {
  id: root
  width: 300
  height: 100
  property int spacing: 0

  QtObject {
    id: panel
    property var events: []
    property bool armedAtCall: true
    function beginRowDrag(index, pitch) {}
    function moveRowDrag(offset) {}
    function record(name) {
      events.push(name)
      armedAtCall = row.grab.armed
    }
    function focusOn(index) { record("focusOn") }
    function releaseRowDrag() { record("releaseRowDrag") }
    function cancelRowDrag() { record("cancelRowDrag") }
  }

  CityRowGrab { id: row; panel: panel }

  TestCase {
    name: "CityRowReleaseEndsGestureFirst"
    when: windowShown

    function init() {
      panel.events = []
      panel.armedAtCall = true
    }

    function test_release_data() {
      return [{ tag: "click", drag: false }, { tag: "drag", drag: true }]
    }

    function test_release(data) {
      mousePress(row, 20, 20)
      if (data.drag) mouseMove(row, 20, 50)
      mouseRelease(row, 20, data.drag ? 50 : 20)
      compare(panel.events, ["finish", data.drag ? "releaseRowDrag" : "focusOn"])
      verify(!panel.armedAtCall, "cleanup completes before the panel can replace the row")
    }

    function test_cancel() {
      row.grab.armed = true
      row.grab.canceled()
      compare(panel.events, ["finish", "cancelRowDrag"])
      verify(!panel.armedAtCall)
    }
  }
}
