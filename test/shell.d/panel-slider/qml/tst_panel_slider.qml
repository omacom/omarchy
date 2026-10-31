import QtQuick
import QtQuick.Controls
import QtTest
import "../../../../shell/Ui"

// A slider with wheel input off lets the wheel scroll its view and writes
// nothing; clicks still pick a value, and default sliders still step.
Item {
  id: root
  width: 320
  height: 180

  ScrollView {
    id: scrollView
    anchors.fill: parent
    contentWidth: availableWidth
    contentHeight: 500
    clip: true

    Item {
      width: scrollView.availableWidth
      height: 500

      PanelSlider {
        id: disabledSlider
        x: 20
        y: 24
        width: 220
        height: 48
        value: 2
        minimum: 0
        maximum: 4
        step: 1
        integer: true
        wheelEnabled: false
      }

      PanelSlider {
        id: pointerSlider
        x: 20
        y: 100
        width: 220
        height: 48
        value: 3
        minimum: 0
        maximum: 4
        step: 1
        integer: true
        wheelEnabled: false
      }
    }
  }

  // Sits over the scroll view but stays hidden except in its own test, so it
  // never catches the wheel events aimed at the sliders underneath.
  PanelSlider {
    id: defaultSlider
    x: 20
    y: 8
    width: 220
    height: 48
    value: 2
    minimum: 0
    maximum: 4
    step: 1
    integer: true
    visible: false
  }

  SignalSpy { id: disabledMovedSpy; target: disabledSlider; signalName: "moved" }
  SignalSpy { id: disabledReleasedSpy; target: disabledSlider; signalName: "released" }
  SignalSpy { id: pointerReleasedSpy; target: pointerSlider; signalName: "released" }
  SignalSpy { id: defaultReleasedSpy; target: defaultSlider; signalName: "released" }

  TestCase {
    name: "PanelSlider"
    when: windowShown

    function init() {
      disabledSlider.value = 2
      pointerSlider.value = 3
      defaultSlider.value = 2
      defaultSlider.visible = false
      scrollView.contentItem.contentY = 0
      disabledMovedSpy.clear()
      disabledReleasedSpy.clear()
      pointerReleasedSpy.clear()
      defaultReleasedSpy.clear()
    }

    function test_unreadWheelPassesToScrollView() {
      mouseWheel(disabledSlider, disabledSlider.width / 2, disabledSlider.height / 2, 0, -120)
      compare(disabledMovedSpy.count, 0)
      compare(disabledReleasedSpy.count, 0)
      tryVerify(function() { return scrollView.contentItem.contentY > 0 }, 2000)
      compare(disabledSlider.liveValue, 2)
    }

    function test_unreadSliderStillAcceptsPointerSelection() {
      mousePress(pointerSlider, 70, pointerSlider.height / 2, Qt.LeftButton)
      mouseRelease(pointerSlider, 70, pointerSlider.height / 2, Qt.LeftButton)
      compare(pointerReleasedSpy.count, 1)
      compare(pointerReleasedSpy.signalArguments[0][0], 1)
    }

    function test_defaultWheelStillReleasesStep() {
      defaultSlider.visible = true
      mouseWheel(defaultSlider, defaultSlider.width / 2, defaultSlider.height / 2, 0, 120)
      compare(defaultReleasedSpy.count, 1)
      compare(defaultReleasedSpy.signalArguments[0][0], 3)
    }
  }
}
