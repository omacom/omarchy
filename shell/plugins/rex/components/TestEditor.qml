import QtQuick
import QtQuick.Controls
import qs.Commons

// The editable test text with matches and groups painted behind it. Only the
// matches inside the visible part of the text are drawn, so a text with a
// hundred thousand matches costs no more than one with ten.
Rectangle {
  id: root

  property color foreground
  property color accent
  property string text: ""
  // Flat match array, stride numbers per match; see Engine.qml.
  property var matches: []
  property int stride: 2
  property int count: 0
  // Qt colors for groups 1..n.
  property var groupColors: []
  property int selectedMatch: -1

  readonly property alias editor: edit
  readonly property int maxDrawn: 600

  signal edited(string value)

  color: Util.alpha(foreground, 0.03)
  border.width: 1
  border.color: edit.activeFocus ? Util.alpha(accent, 0.5) : Util.alpha(foreground, 0.08)
  radius: Style.cornerRadius

  function selectMatch(index) {
    if (index < 0 || index >= count) return
    var start = matches[index * stride], end = matches[index * stride + 1]
    edit.select(start, end)
    var rect = edit.positionToRectangle(start)
    if (rect.y < flick.contentY || rect.y + rect.height > flick.contentY + flick.height)
      flick.contentY = Math.max(0, Math.min(rect.y - flick.height / 3, flick.contentHeight - flick.height))
  }

  // The first match whose end is past offset, by binary search: matches are
  // ordered and do not overlap.
  function firstEndingAfter(offset) {
    var lo = 0, hi = count
    while (lo < hi) {
      var mid = (lo + hi) >> 1
      if (matches[mid * stride + 1] <= offset && matches[mid * stride] < offset) lo = mid + 1
      else hi = mid
    }
    return lo
  }

  // Rectangles covering [start, end), one per visual line.
  function spanRects(start, end, out, color, kind) {
    var a = edit.positionToRectangle(start)
    if (start === end) {
      out.push({ x: a.x - 1, y: a.y, w: 2, h: a.height, color: color, kind: "empty" })
      return
    }
    var b = edit.positionToRectangle(end)
    if (Math.abs(a.y - b.y) < 1) {
      out.push({ x: a.x, y: a.y, w: Math.max(2, b.x - a.x), h: a.height, color: color, kind: kind })
      return
    }
    var right = edit.width
    out.push({ x: a.x, y: a.y, w: Math.max(2, right - a.x), h: a.height, color: color, kind: kind })
    var y = a.y + a.height
    if (b.y - y > 0.5) out.push({ x: 0, y: y, w: right, h: b.y - y, color: color, kind: kind })
    if (b.x > 0) out.push({ x: 0, y: b.y, w: b.x, h: b.height, color: color, kind: kind })
  }

  function rebuild() {
    var rects = []
    if (count > 0 && edit.length > 0) {
      var first = edit.positionAt(0, flick.contentY)
      var last = edit.positionAt(edit.width, flick.contentY + flick.height)
      var groups = stride / 2
      var drawn = 0
      for (var i = firstEndingAfter(first); i < count && drawn < maxDrawn; i++, drawn++) {
        var base = i * stride
        var start = matches[base], end = matches[base + 1]
        if (start > last) break
        spanRects(start, end, rects, i === selectedMatch ? Util.alpha(accent, 0.45) : Util.alpha(accent, i % 2 ? 0.2 : 0.3), "match")
        for (var g = 1; g < groups; g++) {
          var gs = matches[base + g * 2], ge = matches[base + g * 2 + 1]
          if (gs < 0 || ge <= gs) continue
          var color = groupColors[(g - 1) % Math.max(1, groupColors.length)] || accent
          spanRects(gs, ge, rects, color, "group")
        }
      }
    }
    highlights.model = rects
  }

  Timer {
    id: rebuildTimer
    interval: 0
    onTriggered: root.rebuild()
  }

  function scheduleRebuild() { rebuildTimer.restart() }

  onMatchesChanged: scheduleRebuild()
  onCountChanged: scheduleRebuild()
  onSelectedMatchChanged: scheduleRebuild()
  onGroupColorsChanged: scheduleRebuild()

  Flickable {
    id: flick
    anchors.fill: parent
    anchors.margins: Style.spacing.lg
    contentWidth: width
    contentHeight: edit.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}
    onContentYChanged: root.scheduleRebuild()
    onWidthChanged: root.scheduleRebuild()
    onHeightChanged: root.scheduleRebuild()

    Item {
      width: edit.width
      height: edit.height

      Repeater {
        id: highlights
        model: []
        delegate: Rectangle {
          required property var modelData
          x: modelData.x
          y: modelData.y
          width: modelData.w
          height: modelData.h
          color: modelData.kind === "group" ? Util.alpha(modelData.color, 0.0) : modelData.color
          radius: modelData.kind === "empty" ? 0 : 2

          // Groups are underlined in their color rather than filled, so a
          // group inside a match stays readable on top of the match fill.
          Rectangle {
            visible: modelData.kind === "group"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.max(2, Math.round(parent.height * 0.12))
            color: modelData.color
          }
        }
      }

      TextEdit {
        id: edit
        width: flick.width
        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
        color: root.foreground
        selectionColor: Util.alpha(root.foreground, 0.25)
        selectedTextColor: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        textFormat: TextEdit.PlainText
        selectByMouse: true
        persistentSelection: true
        text: root.text
        onTextChanged: {
          if (text !== root.text) root.edited(text)
          root.scheduleRebuild()
        }
        onCursorRectangleChanged: {
          if (!activeFocus) return
          if (cursorRectangle.y < flick.contentY) flick.contentY = cursorRectangle.y
          else if (cursorRectangle.y + cursorRectangle.height > flick.contentY + flick.height)
            flick.contentY = cursorRectangle.y + cursorRectangle.height - flick.height
        }
      }
    }
  }

  Text {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.margins: Style.spacing.lg
    visible: edit.length === 0
    text: "Paste or type the text to search"
    color: Qt.darker(root.foreground, 1.8)
    font.family: Style.font.family
    font.pixelSize: Style.font.subtitle
  }
}
