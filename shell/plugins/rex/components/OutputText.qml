import QtQuick
import QtQuick.Controls
import qs.Commons

// Read-only, selectable text in a scrolling box, with optional spans painted
// behind it (the replacements in a substitution, say).
Rectangle {
  id: root

  property color foreground
  property color accent
  property string text: ""
  // Flat [start, end, ...] spans to paint.
  property var spans: []
  property string placeholder: ""
  readonly property int maxDrawn: 600

  color: Util.alpha(foreground, 0.03)
  border.width: 1
  border.color: Util.alpha(foreground, 0.08)
  radius: Style.cornerRadius

  function rebuild() {
    var rects = []
    if (spans.length && edit.length) {
      var first = edit.positionAt(0, flick.contentY)
      var last = edit.positionAt(edit.width, flick.contentY + flick.height)
      var drawn = 0
      for (var i = 0; i < spans.length && drawn < maxDrawn; i += 2) {
        var s = spans[i], e = spans[i + 1]
        if (e < first || s === e) continue
        if (s > last) break
        drawn++
        var a = edit.positionToRectangle(s), b = edit.positionToRectangle(e)
        if (Math.abs(a.y - b.y) < 1) rects.push({ x: a.x, y: a.y, w: Math.max(2, b.x - a.x), h: a.height })
        else {
          rects.push({ x: a.x, y: a.y, w: edit.width - a.x, h: a.height })
          if (b.y - a.y - a.height > 0.5) rects.push({ x: 0, y: a.y + a.height, w: edit.width, h: b.y - a.y - a.height })
          if (b.x > 0) rects.push({ x: 0, y: b.y, w: b.x, h: b.height })
        }
      }
    }
    painted.model = rects
  }

  Timer { id: rebuildTimer; interval: 0; onTriggered: root.rebuild() }
  onSpansChanged: rebuildTimer.restart()
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
    onContentYChanged: rebuildTimer.restart()
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
          color: Util.alpha(root.accent, 0.25)
        }
      }

      TextEdit {
        id: edit
        width: flick.width
        readOnly: true
        selectByMouse: true
        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
        textFormat: TextEdit.PlainText
        color: root.foreground
        selectionColor: Util.alpha(root.foreground, 0.25)
        selectedTextColor: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        text: root.text
      }
    }
  }

  Text {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.margins: Style.spacing.lg
    visible: root.text === "" && root.placeholder !== ""
    text: root.placeholder
    color: Qt.darker(root.foreground, 1.8)
    font.family: Style.font.family
    font.pixelSize: Style.font.subtitle
  }
}
