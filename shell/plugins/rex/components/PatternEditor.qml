import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons

// The pattern, with its syntax tinted: groups in their match colors,
// classes, quantifiers, anchors, escapes and errors each their own way. A
// TextEdit rather than a TextField so long patterns wrap and free-spacing
// patterns can span lines.
Rectangle {
  id: root

  property color foreground
  property color accent
  property string text: ""
  // From Explain.tokens(): { start, end, kind, group }
  property var tokens: []
  property var errors: []
  property var groupColors: []
  property var kindColors: ({})
  // [start, end] of the span to point at (hovered in the explanation), or [].
  property var highlight: []
  // Free-spacing mode lets Enter start a new line.
  property bool multiline: false
  property string placeholder: "Type a regular expression"

  readonly property alias cursorPosition: edit.cursorPosition
  readonly property alias editor: edit

  signal edited(string value)

  implicitHeight: Math.max(edit.implicitHeight, Style.font.title * 1.6) + Style.spacing.controlPaddingY * 2 + 2
  color: Style.controlFill(edit.activeFocus, hover.hovered, foreground, accent)
  border.width: 1
  border.color: edit.activeFocus ? Util.alpha(accent, 0.6) : Util.alpha(foreground, 0.15)
  radius: Style.cornerRadius

  function focusEditor() { edit.forceActiveFocus() }

  function select(start, end) {
    edit.forceActiveFocus()
    edit.select(start, end)
  }

  function colorFor(token) {
    if (token.kind === "group" && token.group > 0) return groupColors[(token.group - 1) % Math.max(1, groupColors.length)] || accent
    return kindColors[token.kind] || foreground
  }

  function rects(start, end, out, props) {
    var a = edit.positionToRectangle(start), b = edit.positionToRectangle(end)
    if (Math.abs(a.y - b.y) < 1) { out.push(Object.assign({ x: a.x, y: a.y, w: Math.max(2, b.x - a.x), h: a.height }, props)); return }
    out.push(Object.assign({ x: a.x, y: a.y, w: edit.width - a.x, h: a.height }, props))
    if (b.x > 0) out.push(Object.assign({ x: 0, y: b.y, w: b.x, h: b.height }, props))
  }

  function rebuild() {
    var out = []
    var len = edit.length
    for (var i = 0; i < tokens.length; i++) {
      var t = tokens[i]
      if (t.start >= len) continue
      rects(t.start, Math.min(t.end, len), out, { color: colorFor(t), kind: "token" })
    }
    for (var e = 0; e < errors.length; e++) {
      var er = errors[e]
      var s = Math.min(er.start, Math.max(0, len - 1)), en = Math.max(s + 1, Math.min(er.end, len))
      if (len === 0) continue
      rects(s, en, out, { color: Commons.Color.urgent, kind: "error" })
    }
    if (highlight.length === 2 && highlight[1] > highlight[0])
      rects(highlight[0], Math.min(highlight[1], len), out, { color: foreground, kind: "highlight" })
    tints.model = out
  }

  Timer { id: rebuildTimer; interval: 0; onTriggered: root.rebuild() }
  onTokensChanged: rebuildTimer.restart()
  onErrorsChanged: rebuildTimer.restart()
  onHighlightChanged: rebuildTimer.restart()
  onGroupColorsChanged: rebuildTimer.restart()

  HoverHandler { id: hover }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.spacing.controlPaddingX
    anchors.rightMargin: Style.spacing.controlPaddingX
    anchors.topMargin: Style.spacing.controlPaddingY + 1
    anchors.bottomMargin: Style.spacing.controlPaddingY + 1

    Repeater {
      id: tints
      model: []
      delegate: Item {
        required property var modelData
        x: modelData.x
        y: modelData.y
        width: modelData.w
        height: modelData.h

        Rectangle {
          anchors.fill: parent
          visible: modelData.kind === "token"
          radius: 2
          color: Util.alpha(modelData.color, 0.22)
        }
        Rectangle {
          visible: modelData.kind === "token"
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 1
          color: Util.alpha(modelData.color, 0.8)
        }
        Rectangle {
          visible: modelData.kind === "error"
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 2
          color: modelData.color
        }
        Rectangle {
          anchors.fill: parent
          visible: modelData.kind === "highlight"
          color: "transparent"
          border.width: 1
          border.color: Util.alpha(modelData.color, 0.8)
          radius: 2
        }
      }
    }

    TextEdit {
      id: edit
      width: parent.width
      wrapMode: TextEdit.WrapAnywhere
      textFormat: TextEdit.PlainText
      color: root.foreground
      selectionColor: Util.alpha(root.foreground, 0.25)
      selectedTextColor: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
      selectByMouse: true
      persistentSelection: true
      text: root.text
      onTextChanged: {
        if (text !== root.text) root.edited(text)
        rebuildTimer.restart()
      }
      onWidthChanged: rebuildTimer.restart()
      Keys.onReturnPressed: function(event) { event.accepted = !root.multiline }
      Keys.onEnterPressed: function(event) { event.accepted = !root.multiline }
    }

    Text {
      visible: edit.length === 0
      text: root.placeholder
      color: Qt.darker(root.foreground, 1.8)
      font: edit.font
    }
  }
}
