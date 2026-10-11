import QtQuick
import QtTest

// The bar's full-size WheelHandler under a widget that handles the wheel the
// way WidgetButton does, with synthetic wheel events: empty space fades the
// background, a widget keeps its own scroll.
Item {
  id: root
  width: 300
  height: 30

  property int steps: 0
  property int widgetWheels: 0

  function reset() {
    steps = 0; widgetWheels = 0; fader.pending = 0
  }

  WheelHandler {
    id: fader
    property int pending: 0
    target: null
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: function(event) {
      pending += event.angleDelta.y
      var steps = Math.trunc(pending / 120)
      pending -= steps * 120
      root.steps += steps
    }
  }

  Item {
    id: widget
    x: 200
    width: 30
    height: parent.height
    MouseArea {
      anchors.fill: parent
      onWheel: function(wheel) { root.widgetWheels++ }
    }
  }

  TestCase {
    name: "BarWheel"
    when: windowShown

    function test_a_notch_over_empty_space_steps_the_background() {
      root.reset()
      mouseWheel(root, 50, 15, 0, 120)
      compare(root.steps, 1, "one notch up is one step up")
      mouseWheel(root, 50, 15, 0, -240)
      compare(root.steps, -1, "two notches down are two steps down")
    }

    // Touchpads send many small deltas; only a full notch's worth steps.
    function test_small_deltas_add_up_to_a_notch() {
      root.reset()
      for (var i = 0; i < 7; i++) mouseWheel(root, 50, 15, 0, 15)
      compare(root.steps, 0, "less than a notch does nothing")
      mouseWheel(root, 50, 15, 0, 15)
      compare(root.steps, 1, "the eighth small delta completes the notch")
    }

    function test_a_widget_keeps_its_own_scroll() {
      root.reset()
      mouseWheel(root, widget.x + 15, 15, 0, 120)
      compare(root.widgetWheels, 1, "the widget gets the wheel")
      compare(root.steps, 0, "and the background stays put")
    }
  }
}
