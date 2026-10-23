import QtQuick

Item {
  property var anchorItem
  property var owner
  property var bar
  property bool open: false
  property bool centerOnBar: false
  property var focusTarget
  property real contentWidth: 448
  property real contentHeight: 600
  property Component content
  readonly property Item loadedContent: loader.item
  readonly property real loadedContentHeight: loader.item ? loader.item.implicitHeight : 0
  function fittedContentWidth(value) { return value }
  function fittedContentHeight(value) { return value }
  function ensureContent() { return loader.item }
  Loader {
    id: loader
    width: parent.contentWidth
    height: parent.contentHeight
    active: parent.open
    sourceComponent: parent.content
  }
}
