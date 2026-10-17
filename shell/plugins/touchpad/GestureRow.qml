import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

// One gesture binding: fingers, direction, an optional held key, and the
// action, each a dropdown. Emits field-level edits; the window owns the list.
Item {
  id: root

  property var binding: ({})
  property int number: 1
  property string problem: ""
  property bool divided: false
  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent

  readonly property bool popupOpen: fingers.popupOpen || direction.popupOpen || mods.popupOpen || action.popupOpen

  signal edited(string field, var value)
  signal removed()

  implicitHeight: layout.implicitHeight + Style.spacing.lg * 2

  Rectangle {
    visible: root.divided
    anchors.top: parent.top
    width: parent.width
    height: 1
    color: Util.alpha(root.foreground, 0.08)
  }

  ColumnLayout {
    id: layout
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.sm

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.md

      Dropdown {
        id: fingers
        showLabel: false
        options: Model.FINGERS
        value: String(root.binding.fingers)
        Layout.fillWidth: true
        Layout.preferredWidth: Style.space(110)
        Layout.minimumWidth: Style.space(64)
        onChanged: function(v) { root.edited("fingers", Number(v)) }
      }

      Dropdown {
        id: direction
        showLabel: false
        options: Model.DIRECTIONS
        value: root.binding.direction || ""
        Layout.fillWidth: true
        Layout.preferredWidth: Style.space(140)
        Layout.minimumWidth: Style.space(64)
        onChanged: function(v) { root.edited("direction", v) }
      }

      Dropdown {
        id: mods
        showLabel: false
        options: Model.MODIFIERS
        value: root.binding.mods || ""
        Layout.fillWidth: true
        Layout.preferredWidth: Style.space(96)
        Layout.minimumWidth: Style.space(64)
        onChanged: function(v) { root.edited("mods", v) }
      }

      Text {
        textFormat: Text.PlainText
        text: "→"
        color: Qt.darker(root.foreground, 1.5)
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }

      Dropdown {
        id: action
        showLabel: false
        options: Model.ACTIONS
        value: root.binding.action || ""
        Layout.fillWidth: true
        Layout.preferredWidth: Style.space(180)
        Layout.minimumWidth: Style.space(96)
        onChanged: function(v) { root.edited("action", v) }
      }

      Button {
        iconText: "󰆴"
        tooltipText: "Remove gesture"
        focusable: true
        foreground: root.foreground
        accent: root.accent
        horizontalPadding: Style.spacing.md
        onClicked: root.removed()
      }
    }

    Text {
      visible: root.problem !== ""
      textFormat: Text.PlainText
      text: root.problem
      color: Commons.Color.urgent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }
  }
}
