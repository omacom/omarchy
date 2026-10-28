import QtQuick
import QtTest
import "LayoutModel.js" as Layout
Item {
  id: root
  width: 600; height: 320
  property int commits: 0
  LayoutCanvas {
    id: canvas
    anchors.fill: parent
    displays: [{name: "DP-1", mode: "1920x1080@60", scale: 1, transform: 0, x: 0, y: 0}]
    onMoveRequested: function(name, x, y) {
      root.commits++
      displays = Layout.move(displays, name, x, y)
    }
  }
  TestCase {
    name: "DisplayCanvas"; when: windowShown
    function test_continuous_drag() {
      var tile = findChild(canvas, "display-tile-DP-1")
      verify(tile !== null)
      var start = tile.mapToItem(canvas, tile.width / 2, tile.height / 2)
      var ratio = canvas.ratio
      mousePress(canvas, start.x, start.y)
      mouseMove(canvas, start.x + 20, start.y + 5, 30)
      mouseMove(canvas, start.x + 70, start.y + 25, 30)
      compare(root.commits, 0, "drag changes temporary position only")
      compare(canvas.displays[0].x, 0)
      verify(canvas.dragging)
      mouseRelease(canvas, start.x + 70, start.y + 25)
      compare(root.commits, 1, "release commits once")
      compare(canvas.displays[0].x, Math.round(70 / ratio))
      compare(canvas.displays[0].y, Math.round(25 / ratio))
      compare(findChild(canvas, "display-tile-DP-1"), tile, "delegate survives array update")
      verify(!canvas.dragging, "pointer grab released")
    }
  }
}
