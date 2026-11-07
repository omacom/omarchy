import QtQuick

Rectangle {
  property var borderSpec
  property int padding: 0
  readonly property int contentTopInset: padding
  readonly property int contentRightInset: padding
  readonly property int contentBottomInset: padding
  readonly property int contentLeftInset: padding
  default property alias content: inner.data
  Item { id: inner; anchors.fill: parent }
}
