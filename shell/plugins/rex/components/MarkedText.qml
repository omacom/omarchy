import QtQuick
import QtQuick.Controls
import qs.Commons

// Read-only text with colored spans and position markers painted behind
// it, for the debugger's pattern and text.
Rectangle {
  id: root

  property color foreground
  property string text: ""
  property real fontSize: Style.font.subtitle
  // [{ start, end, color, outline }]: filled spans, or outlined ones
  property var spans: []
  // [{ at, color }]: thin vertical markers at positions
  property var markers: []
  // Keep this position in view.
  property int follow: -1

  implicitHeight: Math.min(edit.implicitHeight + Style.spacing.lg * 2, maximumHeight)
  property real maximumHeight: 10000

  color: Util.alpha(foreground, 0.03)
  border.width: 1
  border.color: Util.alpha(foreground, 0.08)
  radius: Style.cornerRadius

  function rects(start, end, out, props) {
    var a = edit.positionToRectangle(start), b = edit.positionToRectangle(end)
    function add(x, y, w, h) {
      var r = { x: x, y: y, w: w, h: h }
      for (var k in props) r[k] = props[k]
      out.push(r)
    }
    if (Math.abs(a.y - b.y) < 1) { add(a.x, a.y, Math.max(2, b.x - a.x), a.height); return }
    add(a.x, a.y, edit.width - a.x, a.height)
    if (b.y - a.y - a.height > 0.5) add(0, a.y + a.height, edit.width, b.y - a.y - a.height)
    if (b.x > 0) add(0, b.y, b.x, b.height)
  }

  function rebuild() {
    var out = []
    var len = edit.length
    for (var i = 0; i < spans.length; i++) {
      var s = spans[i]
      if (s.start < 0 || s.end < s.start) continue
      if (s.start === s.end) { var c = edit.positionToRectangle(Math.min(s.start, len)); out.push({ x: c.x - 1, y: c.y, w: 2, h: c.height, color: s.color, outline: false }); continue }
      rects(Math.min(s.start, len), Math.min(s.end, len), out, { color: s.color, outline: s.outline === true })
    }
    for (var m = 0; m < markers.length; m++) {
      var at = Math.min(markers[m].at, len)
      if (at < 0) continue
      var r = edit.positionToRectangle(at)
      out.push({ x: r.x - 1, y: r.y - 2, w: 2, h: r.height + 4, color: markers[m].color, outline: false })
    }
    painted.model = out
    if (follow >= 0) {
      var f = edit.positionToRectangle(Math.min(follow, len))
      if (f.y < flick.contentY || f.y + f.height > flick.contentY + flick.height)
        flick.contentY = Math.max(0, Math.min(f.y - flick.height / 3, flick.contentHeight - flick.height))
    }
  }

  Timer { id: rebuildTimer; interval: 0; onTriggered: root.rebuild() }
  onSpansChanged: rebuildTimer.restart()
  onMarkersChanged: rebuildTimer.restart()
  onTextChanged: rebuildTimer.restart()

  Flickable {
    id: flick
    anchors.fill: parent
    anchors.margins: Style.spacing.lg
    contentWidth: width
    contentHeight: edit.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}
    onWidthChanged: rebuildTimer.restart()

    Item {
      width: edit.width
      height: edit.height

      Repeater {
        id: painted
        model: []
        delegate: Rectangle {
          required property var modelData
          x: modelData.x
          y: modelData.y
          width: modelData.w
          height: modelData.h
          radius: 2
          color: modelData.outline ? "transparent" : modelData.color
          border.width: modelData.outline ? 2 : 0
          border.color: modelData.color
        }
      }

      TextEdit {
        id: edit
        width: flick.width
        readOnly: true
        selectByMouse: true
        wrapMode: TextEdit.WrapAnywhere
        textFormat: TextEdit.PlainText
        color: root.foreground
        selectionColor: Util.alpha(root.foreground, 0.25)
        font.family: Style.font.family
        font.pixelSize: root.fontSize
        text: root.text
      }
    }
  }
}
