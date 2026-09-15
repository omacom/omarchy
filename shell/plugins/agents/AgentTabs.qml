import QtQuick
import qs.Commons
import qs.Ui

Grid {
  id: root
  required property var tabs
  required property string activeTab
  property bool expanded: false
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  signal selected(string tab)
  columns: expanded ? Math.min(tabs.length, Math.max(3, Math.floor(width / Style.space(82)))) : 3
  columnSpacing: Style.spacing.md
  rowSpacing: Style.spacing.sm
  readonly property real cellWidth: (width - columnSpacing * (columns - 1)) / columns
  Repeater {
    model: root.tabs
    Button {
      required property var modelData
      width: root.cellWidth
      text: modelData.label
      selected: root.activeTab === modelData.id
      bordered: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      fontSize: Style.font.bodySmall
      verticalPadding: Style.spacing.controlPaddingY
      onClicked: root.selected(modelData.id)
    }
  }
}
