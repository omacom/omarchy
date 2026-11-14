import QtQuick
import QtTest

// A city row's release must end its own gesture before the panel hears about
// it: focusOn/releaseRowDrag rebuild the row's delegate, and any component
// function called afterwards lands in a dead QML context (a QQmlVMEMetaObject
// "invalid context" warning plus "Property 'finish' … is not a function").
// This mirrors CityRow's grab MouseArea handler order.
Item {
  id: root
  width: 300
  height: 60

  property var events: []

  QtObject {
    id: panel

    // The real panel rebuilds the row here; recording the call is enough to
    // assert which side of it the gesture cleanup lands on.
    property bool armedAtCall: true

    function focusOn() {
      root.events.push("focusOn")
      armedAtCall = delegate.armed
    }

    function releaseRowDrag() {
      root.events.push("releaseRowDrag")
      armedAtCall = delegate.armed
    }
  }

  Item {
    id: delegate

    property bool armed: false

    function finish() {
      armed = false
      root.events.push("finish")
    }

    function press() {
      armed = true
      root.events.push("press")
    }

    function release() {
      // The order under test: finish() first, panel second.
      var wasArmed = armed
      finish()
      if (wasArmed) panel.releaseRowDrag()
      else panel.focusOn()
    }
  }

  TestCase {
    name: "CityRowReleaseEndsGestureFirst"

    function init() { root.events = [] }

    function test_plain_release_finishes_before_focus() {
      delegate.release()
      compare(root.events, ["finish", "focusOn"])
    }

    function test_drag_release_finishes_before_reorder() {
      delegate.press()
      delegate.release()
      compare(root.events, ["press", "finish", "releaseRowDrag"])
    }

    function test_release_clears_armed_before_panel_rebuilds() {
      delegate.press()
      delegate.release()
      verify(!panel.armedAtCall, "the gesture must be disarmed before the panel rebuilds the row")
    }
  }
}
