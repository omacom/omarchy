import QtQuick
import QtTest

// The daylight strip's arrows over its scrub MouseArea, with synthetic mouse
// events: a click on an arrow must not scrub the clocks.
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

    // A TapHandler's passive grab does not let the press through to the bar.
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

    // Arrows hide off-row and under the now-marker; the bar must still work.
    function test_a_hidden_arrow_lets_the_bar_through() {
      root.reset()
      arrow.visible = false
      mouseClick(root, arrow.x + arrow.width / 2, 20)
      arrow.visible = true
      compare(root.arrowTaps, 0, "an invisible arrow is not tapped")
      compare(root.barPresses, 1, "the press belongs to the bar")
    }

    // Past the drag threshold the handler gives up, so a drag can still scrub.
    function test_a_drag_from_the_arrow_is_not_a_tap() {
      root.reset()
      mousePress(root, arrow.x + arrow.width / 2, 20)
      mouseMove(root, arrow.x + 60, 20)
      mouseRelease(root, arrow.x + 60, 20)
      compare(root.arrowTaps, 0, "a drag is not a tap")
    }
  }
}
