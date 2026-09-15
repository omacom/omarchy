import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  property string label: ""
  property string shortcut: ""
  property bool selected: false
  property bool destructive: false
  property bool compact: false
  signal clicked()

  function activate() {
    if (root.enabled && root.visible) root.clicked()
  }

  implicitHeight: compact ? 28 : 34
  implicitWidth: content.implicitWidth + (compact ? 18 : 24)
  activeFocusOnTab: enabled && visible
  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.description: shortcut ? "Shortcut " + shortcut : ""
  Accessible.focusable: enabled && visible
  Accessible.focused: activeFocus
  Accessible.selected: selected
  Accessible.onPressAction: root.activate()
  Keys.onReturnPressed: root.activate()
  Keys.onEnterPressed: root.activate()
  Keys.onSpacePressed: root.activate()
  radius: 6
  color: selected
    ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.16)
    : Qt.rgba(Color.background.r, Color.background.g, Color.background.b, mouse.containsMouse ? 0.78 : 0.54)
  border.width: activeFocus ? 2 : 1
  border.color: activeFocus ? Color.accent : (destructive
    ? Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, enabled ? 0.7 : 0.25)
    : (selected ? Color.accent : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, enabled ? 0.2 : 0.09)))
  opacity: enabled ? 1 : 0.42

  RowLayout {
    id: content
    anchors.centerIn: parent
    spacing: 7

    Text {
      visible: root.shortcut.length > 0
      text: root.shortcut
      textFormat: Text.PlainText
      color: root.destructive ? Color.urgent : Color.accent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.weight: Font.DemiBold
    }

    Text {
      text: root.label
      textFormat: Text.PlainText
      color: root.destructive ? Color.urgent : Color.foreground
      font.family: Style.font.family
      font.pixelSize: root.compact ? Style.font.caption : Style.font.bodySmall
      font.weight: root.selected ? Font.DemiBold : Font.Normal
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      root.forceActiveFocus()
      root.activate()
    }
  }
}
