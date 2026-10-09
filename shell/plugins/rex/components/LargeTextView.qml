import QtQuick
import QtQuick.Controls
import qs.Commons

// The test text when it is too large to edit: a read-only view that only
// lays out the rows on screen, each painting just the matches inside it.
// Rows come from workers/rows.js, off the UI thread.
Rectangle {
  id: root

  property color foreground
  property color accent
  property string text: ""
  property var matches: []
  property int stride: 2
  property int count: 0
  property var groupColors: []
  property int selectedMatch: -1

  property var starts: []
  property var lineNumbers: []
  property int requestId: 0
  readonly property bool indexing: starts.length === 0 && text.length > 0

  color: Util.alpha(foreground, 0.03)
  border.width: 1
  border.color: Util.alpha(foreground, 0.08)
  radius: Style.cornerRadius

  onTextChanged: {
    starts = []
    lineNumbers = []
    rowWorker.sendMessage({ id: ++requestId, text: text })
  }

  WorkerScript {
    id: rowWorker
    source: "../workers/rows.js"
    onMessage: function(reply) {
      if (reply.id !== root.requestId) return
      root.lineNumbers = reply.lines
      root.starts = reply.starts
    }
    Component.onCompleted: if (root.text.length) sendMessage({ id: ++root.requestId, text: root.text })
  }

  function rowEnd(i) {
    if (i + 1 < starts.length) {
      var next = starts[i + 1]
      // Rows that end at a line break leave it out.
      return lineNumbers[i + 1] > 0 ? next - 1 : next
    }
    return text.length
  }

  function rowOf(offset) {
    var lo = 0, hi = starts.length - 1
    while (lo < hi) {
      var mid = (lo + hi + 1) >> 1
      if (starts[mid] <= offset) lo = mid
      else hi = mid - 1
    }
    return lo
  }

  function firstEndingAfter(offset) {
    var lo = 0, hi = count
    while (lo < hi) {
      var mid = (lo + hi) >> 1
      if (matches[mid * stride + 1] <= offset && matches[mid * stride] < offset) lo = mid + 1
      else hi = mid
    }
    return lo
  }

  function selectMatch(index) {
    if (index < 0 || index >= count || starts.length === 0) return
    list.positionViewAtIndex(rowOf(matches[index * stride]), ListView.Center)
  }

  readonly property real gutterWidth: lineMetrics.advanceWidth * Math.max(3, String(lineNumbers.length ? lineNumbers.length : 1).length + 1)

  TextMetrics {
    id: lineMetrics
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    text: "0"
  }

  ListView {
    id: list
    anchors.fill: parent
    anchors.margins: Style.spacing.lg
    clip: true
    model: root.starts.length
    boundsBehavior: Flickable.StopAtBounds
    reuseItems: true
    cacheBuffer: 400
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }

    delegate: Item {
      id: row
      required property int index
      readonly property int start: root.starts[index]
      readonly property int end: root.rowEnd(index)

      width: list.width - Style.spacing.lg
      height: Math.max(edit.implicitHeight, lineMetrics.height)

      function paint() {
        var rects = []
        if (root.count > 0) {
          var groups = root.stride / 2
          var drawn = 0
          for (var i = root.firstEndingAfter(row.start); i < root.count && drawn < 400; i++, drawn++) {
            var base = i * root.stride
            if (root.matches[base] > row.end) break
            spans(root.matches[base], root.matches[base + 1], i === root.selectedMatch ? Util.alpha(root.accent, 0.45) : Util.alpha(root.accent, i % 2 ? 0.2 : 0.3), "match", rects)
            for (var g = 1; g < groups; g++) {
              var gs = root.matches[base + g * 2], ge = root.matches[base + g * 2 + 1]
              if (gs < 0 || ge <= gs) continue
              spans(gs, ge, root.groupColors[(g - 1) % Math.max(1, root.groupColors.length)] || root.accent, "group", rects)
            }
          }
        }
        paintRepeater.model = rects
      }

      // The part of [s, e) inside this row, one rectangle per visual line.
      function spans(s, e, color, kind, out) {
        var a = Math.max(s, row.start) - row.start
        var b = Math.min(e, row.end) - row.start
        if (s === e && s >= row.start && s <= row.end) {
          var caret = edit.positionToRectangle(a)
          out.push({ x: caret.x - 1, y: caret.y, w: 2, h: caret.height, color: color, kind: "empty" })
          return
        }
        if (b <= a) return
        var ra = edit.positionToRectangle(a), rb = edit.positionToRectangle(b)
        if (Math.abs(ra.y - rb.y) < 1) {
          out.push({ x: ra.x, y: ra.y, w: Math.max(2, rb.x - ra.x), h: ra.height, color: color, kind: kind })
          return
        }
        out.push({ x: ra.x, y: ra.y, w: edit.width - ra.x, h: ra.height, color: color, kind: kind })
        if (rb.y - ra.y - ra.height > 0.5) out.push({ x: 0, y: ra.y + ra.height, w: edit.width, h: rb.y - ra.y - ra.height, color: color, kind: kind })
        if (rb.x > 0) out.push({ x: 0, y: rb.y, w: rb.x, h: rb.height, color: color, kind: kind })
      }

      Connections {
        target: root
        function onMatchesChanged() { paintTimer.restart() }
        function onCountChanged() { paintTimer.restart() }
        function onSelectedMatchChanged() { paintTimer.restart() }
      }

      Timer { id: paintTimer; interval: 0; onTriggered: row.paint() }
      onStartChanged: paintTimer.restart()
      ListView.onReused: paintTimer.restart()

      Text {
        width: root.gutterWidth - lineMetrics.advanceWidth
        horizontalAlignment: Text.AlignRight
        text: root.lineNumbers[row.index] > 0 ? root.lineNumbers[row.index] : "↪"
        textFormat: Text.PlainText
        color: Qt.darker(root.foreground, 2)
        font: lineMetrics.font
        y: (lineMetrics.height < edit.cursorRectangle.height) ? (edit.cursorRectangle.height - lineMetrics.height) / 2 : 0
      }

      Item {
        x: root.gutterWidth
        width: parent.width - root.gutterWidth
        height: edit.implicitHeight

        Repeater {
          id: paintRepeater
          model: []
          delegate: Rectangle {
            required property var modelData
            x: modelData.x
            y: modelData.y
            width: modelData.w
            height: modelData.h
            radius: modelData.kind === "empty" ? 0 : 2
            color: modelData.kind === "group" ? "transparent" : modelData.color

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
          width: parent.width
          readOnly: true
          selectByMouse: true
          wrapMode: TextEdit.WrapAnywhere
          textFormat: TextEdit.PlainText
          color: root.foreground
          selectionColor: Util.alpha(root.foreground, 0.25)
          selectedTextColor: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          text: root.text.substring(row.start, row.end)
          onTextChanged: paintTimer.restart()
          onWidthChanged: paintTimer.restart()
        }
      }
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.indexing
    text: "Reading the text…"
    color: Qt.darker(root.foreground, 1.5)
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
}
