import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// A dropdown whose popup takes its height from its rows. qs.Ui's Dropdown sizes
// its list a couple of pixels short, so hovering the last row scrolls the list
// and every row jumps under the pointer. A list that always fits cannot scroll.
Item {
  id: picker

  property string label: ""
  property string value: ""
  // Plain strings or { value, label } objects, like the kit's Dropdown.
  property var options: []
  property color foreground: Commons.Color.popups.text
  property string fontFamily: Style.font.family
  property int rowHeight: Style.spacing.controlHeight

  signal picked(string value)

  function optionValue(o) { return (o && typeof o === "object") ? String(o.value) : String(o) }
  function optionLabel(o) { return (o && typeof o === "object") ? String(o.label) : String(o) }
  function labelFor(wanted) {
    for (var i = 0; i < options.length; i++)
      if (optionValue(options[i]) === String(wanted)) return optionLabel(options[i])
    return String(wanted)
  }

  implicitWidth: Style.spacing.dropdownWidth
  implicitHeight: label !== "" ? rowHeight + Style.spacing.huge : rowHeight

  Column {
    id: stack
    anchors.fill: parent
    spacing: Style.spacing.labelGap

    Text {
      textFormat: Text.PlainText
      visible: picker.label !== ""
      text: picker.label
      color: Qt.darker(picker.foreground, 1.4)
      font.family: picker.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    BorderSurface {
      id: trigger
      width: parent.width
      height: picker.rowHeight
      radius: Style.cornerRadius

      readonly property bool hot: triggerArea.containsMouse || menu.opened
      color: Style.controlFill(menu.opened, trigger.hot, picker.foreground, Commons.Color.accent)
      borderSpec: Border.controlSpec(menu.opened ? "focus" : trigger.hot ? "hover-cursor" : "normal",
                                     picker.foreground, Commons.Color.accent)

      Text {
        anchors.left: parent.left
        anchors.right: chevron.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: trigger.borderLeft + Style.spacing.controlPaddingX
        anchors.rightMargin: Style.spacing.md
        textFormat: Text.PlainText
        text: picker.labelFor(picker.value)
        elide: Text.ElideRight
        color: picker.foreground
        font.family: picker.fontFamily
        font.pixelSize: Style.font.body
      }

      Text {
        id: chevron
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: trigger.borderRight + Style.spacing.controlGap
        textFormat: Text.PlainText
        text: "\u{f0140}"
        color: Qt.darker(picker.foreground, 1.2)
        font.family: picker.fontFamily
        font.pixelSize: Style.font.body
      }

      MouseArea {
        id: triggerArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: menu.opened ? menu.close() : menu.open()
      }
    }
  }

  Popup {
    id: menu
    y: stack.y + trigger.y + trigger.height + Style.spacing.xxs
    width: picker.width
    padding: Style.spacing.hairline

    background: BorderSurface {
      color: Commons.Color.popups.background
      radius: Style.cornerRadius
      borderSpec: Border.controlSpec("normal", picker.foreground, Commons.Color.accent)
    }

    contentItem: Column {
      spacing: Style.spacing.labelGap

      Repeater {
        model: picker.options

        Rectangle {
          id: row
          required property var modelData
          readonly property bool chosen: picker.optionValue(modelData) === String(picker.value)
          width: menu.availableWidth
          height: Style.spacing.popupRowHeight
          radius: Style.cornerRadius
          color: rowArea.containsMouse ? Style.hoverFillFor(picker.foreground, Commons.Color.accent) : "transparent"

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.rightMargin: Style.spacing.controlPaddingX
            textFormat: Text.PlainText
            text: picker.optionLabel(row.modelData)
            elide: Text.ElideRight
            color: rowArea.containsMouse ? Style.hoverStateColor(picker.foreground, Commons.Color.accent) : picker.foreground
            font.family: picker.fontFamily
            font.pixelSize: Style.font.body
            font.bold: row.chosen
          }

          MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              menu.close()
              picker.picked(picker.optionValue(row.modelData))
            }
          }
        }
      }
    }
  }
}
