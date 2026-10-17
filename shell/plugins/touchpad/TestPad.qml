import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// A place to feel a change right after making it: a list to scroll, a pad
// that names the click it received, and a dot to drag. Settings apply live,
// so each of these responds to the new values as soon as they are saved.
ColumnLayout {
  id: root

  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property color cardFill: Util.alpha(foreground, 0.035)
  readonly property var cardBorder: Border.flat(Util.alpha(foreground, 0.10), 1)

  property string lastClick: ""
  property int clickCount: 0

  spacing: Style.spacing.md

  component Caption: Text {
    textFormat: Text.PlainText
    color: root.dim
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
  }

  PanelSectionHeader {
    text: "TRY IT"
    foreground: root.foreground
    font.letterSpacing: 1
  }

  Caption { text: "Changes apply as you make them. Scroll, tap, and drag here to feel them." }

  // ---- Scroll ----
  BorderSurface {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: Style.space(140)
    color: root.cardFill
    radius: Style.cornerRadius
    borderSpec: root.cardBorder
    clip: true

    ListView {
      id: scrollList
      anchors.fill: parent
      anchors.margins: Style.spacing.md
      model: 80
      boundsBehavior: Flickable.StopAtBounds
      spacing: Style.spacing.xs

      delegate: Rectangle {
        required property int index
        width: scrollList.width
        height: Style.space(26)
        radius: Style.cornerRadius
        color: index % 2 === 0 ? Util.alpha(root.foreground, 0.04) : "transparent"

        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: Style.spacing.md
          textFormat: Text.PlainText
          text: "Scroll test line " + (index + 1)
          color: index % 10 === 0 ? root.accent : root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }
    }

    // Where in the list you are, so speed changes are easy to compare.
    Text {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: Style.spacing.md
      textFormat: Text.PlainText
      text: Math.round(scrollList.visibleArea.yPosition / Math.max(0.001, 1 - scrollList.visibleArea.heightRatio) * 100) + "%"
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  // ---- Click ----
  BorderSurface {
    id: clickPad
    Layout.fillWidth: true
    Layout.preferredHeight: Style.space(92)
    color: clickArea.pressed ? Util.alpha(root.accent, 0.18) : root.cardFill
    radius: Style.cornerRadius
    borderSpec: root.cardBorder

    Behavior on color { ColorAnimation { duration: Style.duration(120) } }

    Column {
      anchors.centerIn: parent
      spacing: Style.spacing.xs

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.lastClick === "" ? "Tap or click here" : root.lastClick
        color: root.lastClick === "" ? root.dim : root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: root.lastClick !== ""
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.clickCount > 0 ? root.clickCount + (root.clickCount === 1 ? " click" : " clicks") : "Try one, two, and three fingers"
        color: root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    MouseArea {
      id: clickArea
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      onPressed: function(mouse) {
        root.clickCount++
        root.lastClick = mouse.button === Qt.RightButton ? "Right click"
          : mouse.button === Qt.MiddleButton ? "Middle click"
          : "Left click"
      }
      onDoubleClicked: function(mouse) {
        if (mouse.button === Qt.LeftButton) root.lastClick = "Double click"
      }
    }
  }

  // ---- Drag ----
  BorderSurface {
    id: dragPad
    Layout.fillWidth: true
    Layout.preferredHeight: Style.space(72)
    color: root.cardFill
    radius: Style.cornerRadius
    borderSpec: root.cardBorder

    Caption {
      anchors.centerIn: parent
      width: implicitWidth
      text: dragArea.drag.active ? "Dragging" : "Drag the dot"
    }

    Rectangle {
      id: dot
      width: Style.space(26)
      height: width
      radius: width / 2
      x: Style.spacing.md
      y: (parent.height - height) / 2
      color: dragArea.drag.active ? root.accent : root.foreground

      MouseArea {
        id: dragArea
        anchors.fill: parent
        cursorShape: Qt.OpenHandCursor
        drag.target: dot
        drag.minimumX: Style.spacing.sm
        drag.maximumX: dragPad.width - dot.width - Style.spacing.sm
        drag.minimumY: Style.spacing.sm
        drag.maximumY: dragPad.height - dot.height - Style.spacing.sm
      }
    }
  }
}
