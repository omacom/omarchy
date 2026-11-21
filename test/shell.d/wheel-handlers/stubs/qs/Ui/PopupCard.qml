import QtQuick

Item {
  property var anchorItem: null
  property var owner: null
  property QtObject bar: null
  property bool open: false
  property int contentWidth: 0
  property int contentHeight: 0

  visible: open

  function fittedContentWidth(width) { return width }
  function fittedContentHeight(height) { return height }
}
