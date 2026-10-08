import QtQuick
import qs.Ui
import qs.Commons
import "LayoutModel.js" as Layout

BorderSurface {
  id: canvas
  objectName: "display-layout-canvas"
  property var displays: []
  property string selected: ""
  property bool dragging: false
  property string dragName: ""
  property real dragX: 0
  property real dragY: 0
  property var dragExtent: null
  readonly property var extent: Layout.bounds(displays)
  readonly property var view: dragging ? dragExtent : extent
  readonly property real ratio: Math.min((width - 48) / Math.max(1, view.width), (height - 48) / Math.max(1, view.height))
  readonly property real offsetX: (width - view.width * ratio) / 2
  readonly property real offsetY: (height - view.height * ratio) / 2
  signal selectedDisplay(string name)
  signal moveRequested(string name, int x, int y)

  color: Color.popups.background
  borderSpec: Border.localOrSurfaceSpec("popups", "border", Color.popups.border, Color.popups.border, Style.normalBorderWidth)
  radius: Style.cornerRadius
  clip: true

  Repeater {
    // Keep delegates alive when positions change. Array models rebuild their
    // delegates and destroy a MouseArea while it still owns the pointer grab.
    model: canvas.displays.length
    Rectangle {
      id: tile
      required property int index
      readonly property var display: canvas.displays[index]
      readonly property var logicalSize: Layout.size(display)
      readonly property bool moving: canvas.dragging && canvas.dragName === display.name
      objectName: "display-tile-" + display.name
      x: canvas.offsetX + ((moving ? canvas.dragX : display.x) - canvas.view.x) * canvas.ratio
      y: canvas.offsetY + ((moving ? canvas.dragY : display.y) - canvas.view.y) * canvas.ratio
      width: logicalSize.width * canvas.ratio
      height: logicalSize.height * canvas.ratio
      z: moving ? 1 : 0
      color: display.name === canvas.selected ? Style.selectedFillFor(Color.popups.text, Color.accent) : Style.hoverFillFor(Color.popups.text, Color.accent)
      border.color: display.name === canvas.selected ? Color.accent : Color.popups.text
      border.width: 2
      radius: Style.cornerRadius
      Text {
        anchors.centerIn: parent
        width: parent.width - 8
        textFormat: Text.PlainText
        text: tile.display.name
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeAllCursor
        preventStealing: true
        property point start
        property point origin
        onPressed: function(mouse) {
          canvas.selectedDisplay(tile.display.name)
          start = mapToItem(canvas, mouse.x, mouse.y)
          origin = Qt.point(tile.display.x, tile.display.y)
          canvas.dragExtent = canvas.extent
          canvas.dragName = tile.display.name
          canvas.dragX = origin.x
          canvas.dragY = origin.y
          canvas.dragging = true
        }
        onPositionChanged: function(mouse) {
          if (!pressed) return
          var p = mapToItem(canvas, mouse.x, mouse.y)
          var target = Layout.snapPosition(canvas.displays, canvas.dragName,
            origin.x + (p.x - start.x) / canvas.ratio,
            origin.y + (p.y - start.y) / canvas.ratio, Math.min(80, 10 / canvas.ratio))
          canvas.dragX = target.x
          canvas.dragY = target.y
        }
        onReleased: {
          var name = canvas.dragName, x = canvas.dragX, y = canvas.dragY
          canvas.dragging = false
          canvas.dragName = ""
          canvas.moveRequested(name, x, y)
        }
        onCanceled: { canvas.dragging = false; canvas.dragName = "" }
      }
    }
  }
}
