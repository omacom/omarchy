import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

// The pattern explained as a tree. Hovering a row points at its part of the
// pattern; clicking selects it there. The row under the pattern's cursor is
// marked, so reading the pattern and reading its explanation stay together.
Item {
  id: root

  property color foreground
  property color accent
  property var rows: []
  property var groupColors: []
  property var kindColors: ({})
  property int cursor: -1

  readonly property color dim: Qt.darker(foreground, 1.5)

  signal hovered(int start, int end)
  signal picked(int start, int end)

  // The deepest row whose span holds the cursor.
  readonly property int cursorRow: {
    var best = -1
    for (var i = 0; i < rows.length; i++) {
      var r = rows[i]
      if (cursor >= r.start && cursor < r.end && r.type !== "alternative") best = i
    }
    return best
  }
  onCursorRowChanged: if (cursorRow >= 0) list.positionViewAtIndex(cursorRow, ListView.Contain)

  function colorFor(row) {
    if (row.kind === "group" && row.group > 0) return groupColors[(row.group - 1) % Math.max(1, groupColors.length)] || accent
    return kindColors[row.kind] || foreground
  }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    model: root.rows
    spacing: Style.spacing.xxs
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    delegate: Rectangle {
      id: row
      required property int index
      required property var modelData
      width: list.width - Style.spacing.lg
      height: content.implicitHeight + Style.spacing.sm * 2
      radius: Style.cornerRadius
      color: index === root.cursorRow ? Util.alpha(root.accent, 0.14) : (mouse.containsMouse ? Util.alpha(root.foreground, 0.06) : "transparent")

      MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: {
          if (containsMouse) root.hovered(row.modelData.start, row.modelData.end)
          else root.hovered(-1, -1)
        }
        onClicked: root.picked(row.modelData.start, row.modelData.end)
      }

      RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.spacing.md + row.modelData.depth * Style.spacing.xxl
        anchors.rightMargin: Style.spacing.md
        spacing: Style.spacing.md

        Rectangle {
          Layout.preferredWidth: Style.spacing.sm
          Layout.fillHeight: true
          radius: 1
          color: Util.alpha(root.colorFor(row.modelData), row.modelData.kind === "meta" ? 0.3 : 0.9)
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0

          Text {
            Layout.fillWidth: true
            text: row.modelData.title
            color: root.foreground
            wrapMode: Text.Wrap
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            textFormat: Text.PlainText
          }

          Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: row.modelData.detail
            color: root.dim
            wrapMode: Text.Wrap
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }
        }
      }
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.rows.length === 0
    text: "Type a pattern to see it explained"
    color: root.dim
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
}
