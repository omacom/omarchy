import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

// Every match with its groups: number or name, span, and the text matched.
// A ListView, so only the rows on screen exist however many matches there
// are.
Item {
  id: root

  property color foreground
  property color accent
  property string text: ""
  property var matches: []
  property int stride: 2
  property int count: 0
  property var groupNames: []
  property var groupColors: []
  property int selectedMatch: -1

  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property int previewLength: 160

  signal picked(int index)

  function preview(start, end) {
    if (start < 0) return "—"
    var s = root.text.substring(start, Math.min(end, start + previewLength))
    s = s.replace(/\n/g, "⏎").replace(/\t/g, "⇥").replace(/\r/g, "␍")
    if (end - start > previewLength) s += "…"
    return s === "" ? "(empty)" : s
  }

  function positionAt(index) {
    list.positionViewAtIndex(index, ListView.Contain)
  }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    model: root.count
    spacing: Style.spacing.md
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}
    reuseItems: true

    delegate: Rectangle {
      id: row
      required property int index
      readonly property int base: index * root.stride
      readonly property bool selected: index === root.selectedMatch

      width: list.width - Style.spacing.lg
      height: content.implicitHeight + Style.spacing.md * 2
      radius: Style.cornerRadius
      color: selected ? Util.alpha(root.accent, 0.14) : (mouse.containsMouse ? Util.alpha(root.foreground, 0.05) : Util.alpha(root.foreground, 0.025))

      MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.picked(row.index)
      }

      ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.spacing.md
        spacing: Style.spacing.xs

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.md

          Text {
            text: "Match " + (row.index + 1)
            textFormat: Text.PlainText
            color: root.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Text {
            text: root.matches[row.base] + "–" + root.matches[row.base + 1]
            textFormat: Text.PlainText
            color: root.dim
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Text {
            Layout.fillWidth: true
            text: root.preview(root.matches[row.base], root.matches[row.base + 1])
            color: root.foreground
            elide: Text.ElideRight
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            textFormat: Text.PlainText
          }
        }

        Repeater {
          model: root.stride / 2 - 1

          RowLayout {
            required property int index
            readonly property int group: index + 1
            readonly property int start: root.matches[row.base + group * 2]
            readonly property int end: root.matches[row.base + group * 2 + 1]

            Layout.fillWidth: true
            Layout.leftMargin: Style.spacing.lg
            spacing: Style.spacing.md

            Rectangle {
              Layout.preferredWidth: Style.spacing.sm
              Layout.preferredHeight: Style.font.bodySmall
              radius: 1
              color: root.groupColors[(group - 1) % Math.max(1, root.groupColors.length)] || root.accent
            }

            Text {
              text: root.groupNames[group] ? group + " " + root.groupNames[group] : "Group " + group
              textFormat: Text.PlainText
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Text {
              visible: start >= 0
              text: start + "–" + end
              textFormat: Text.PlainText
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Text {
              Layout.fillWidth: true
              // -2: the engine matched the group but does not say where.
              text: start === -2 ? "position not reported by this engine" : (start < 0 ? "did not take part" : root.preview(start, end))
              color: start < 0 ? root.dim : root.foreground
              font.italic: start < 0
              elide: Text.ElideRight
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              textFormat: Text.PlainText
            }
          }
        }
      }
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.count === 0
    text: "No matches"
    color: root.dim
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
}
