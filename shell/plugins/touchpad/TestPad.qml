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
    text: Commons.I18n.t("touchpad.tryIt")
    foreground: root.foreground
    font.letterSpacing: 1
  }

  Caption { text: Commons.I18n.t("touchpad.testPadHint") }

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
          text: Commons.I18n.t("touchpad.scrollTestLine").arg(Commons.I18n.formatNumber(index + 1))
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
      text: Commons.I18n.formatNumber(Math.round(scrollList.visibleArea.yPosition / Math.max(0.001, 1 - scrollList.visibleArea.heightRatio) * 100)) + "%"
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
        text: root.lastClick === "" ? Commons.I18n.t("touchpad.tapOrClickHere") : root.lastClick
        color: root.lastClick === "" ? root.dim : root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: root.lastClick !== ""
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.clickCount > 0 ? Commons.I18n.tn("touchpad.clicks", root.clickCount).arg(Commons.I18n.formatNumber(root.clickCount)) : Commons.I18n.t("touchpad.tryFingers")
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
        root.lastClick = mouse.button === Qt.RightButton ? Commons.I18n.t("touchpad.rightClick")
          : mouse.button === Qt.MiddleButton ? Commons.I18n.t("touchpad.middleClick")
          : Commons.I18n.t("touchpad.leftClick")
      }
      onDoubleClicked: function(mouse) {
        if (mouse.button === Qt.LeftButton) root.lastClick = Commons.I18n.t("touchpad.doubleClick")
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
      text: dragArea.drag.active ? Commons.I18n.t("touchpad.dragging") : Commons.I18n.t("touchpad.dragTheDot")
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
