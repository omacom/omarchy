import QtQuick
import QtTest

// Pointer behaviour, with synthetic mouse events.
//
// This project spent a long time believing its interactions could not be
// tested: no pointer can be injected into the running shell, so every handler
// question was answered by reading Qt's documentation and reasoning. That was
// wrong. `qmltestrunner` synthesises real mouse events into an offscreen
// window, and the structures worth checking are small enough to rebuild here.
//
//   QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input tests/qml
//
// Use that path. `/usr/bin/qmltestrunner` is the Qt5 binary, and it exits 0
// having run nothing and printed nothing, which looks exactly like success.
//
// What is modelled: the daylight strip. A MouseArea fills the bar and drags
// time; the sunrise and sunset arrows are separate Items drawn on top of it,
// declared later and raised with z. The question that mattered was whether a
// click on an arrow also reaches the bar - if it did, clicking "sunrise" would
// scrub every clock in the list back to sunrise.
Item {
  id: root
  width: 300
  height: 40

  property int barPresses: 0
  property int barReleases: 0
  property int barCancels: 0
  property int arrowTaps: 0

  function reset() {
    barPresses = 0; barReleases = 0; barCancels = 0; arrowTaps = 0
  }

  MouseArea {
    id: bar
    anchors.fill: parent
    preventStealing: true
    onPressed: root.barPresses++
    onReleased: root.barReleases++
    onCanceled: root.barCancels++
  }

  Item {
    id: arrow
    x: 100
    width: 14
    height: parent.height
    z: 1
    visible: true
    TapHandler { onTapped: root.arrowTaps++ }
  }

  TestCase {
    name: "ArrowsOverTheScrubBar"
    when: windowShown

    // The finding this file exists for. A TapHandler takes only a passive grab,
    // which reads in the documentation as though the item underneath must see
    // the press as well. It does not: the click stops at the arrow.
    function test_a_click_on_the_arrow_does_not_reach_the_bar() {
      root.reset()
      mouseClick(root, arrow.x + arrow.width / 2, 20)
      compare(root.arrowTaps, 1, "the arrow's tap fires")
      compare(root.barPresses, 0, "and the bar underneath sees no press at all")
      compare(root.barReleases, 0, "nor a release")
    }

    function test_a_click_on_the_bar_is_a_press_on_the_bar() {
      root.reset()
      mouseClick(root, 20, 20)
      compare(root.arrowTaps, 0, "no tap away from the arrow")
      compare(root.barPresses, 1, "the bar gets its own press")
      compare(root.barReleases, 1, "and its own release")
    }

    // A hidden arrow is not a hole in the bar. The arrows are only drawn while
    // the pointer is on the row, and they disappear under the now-marker; the
    // bar has to keep working in both cases.
    function test_a_hidden_arrow_lets_the_bar_through() {
      root.reset()
      arrow.visible = false
      mouseClick(root, arrow.x + arrow.width / 2, 20)
      arrow.visible = true
      compare(root.arrowTaps, 0, "an invisible arrow is not tapped")
      compare(root.barPresses, 1, "the press belongs to the bar")
    }

    // Dragging from an arrow is a drag, not a tap: the handler gives up past
    // the drag threshold, so a gesture that starts on an arrow can still become
    // a scrub.
    function test_a_drag_from_the_arrow_is_not_a_tap() {
      root.reset()
      mousePress(root, arrow.x + arrow.width / 2, 20)
      mouseMove(root, arrow.x + 60, 20)
      mouseRelease(root, arrow.x + 60, 20)
      compare(root.arrowTaps, 0, "a drag is not a tap")
    }
  }
}
