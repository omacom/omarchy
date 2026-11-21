import QtQuick

Item {
  id: root
  property var anchorItem: null
  property var owner: null
  property QtObject bar: null
  property bool open: false
  property bool centerOnBar: false
  property Item focusTarget: null
  property int contentWidth: 0
  property int contentHeight: 0
  property Component content: null
  property bool contentRequested: false
  readonly property Item loadedContent: contentLoader.item
  readonly property real loadedContentHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0
  default property alias contentItem: contentHolder.children

  width: contentWidth
  height: contentHeight

  function fittedContentWidth(width) { return width }
  function fittedContentHeight(height) { return height }
  function ensureContent() {
    if (content) contentRequested = true
    return contentLoader.item
  }

  Item {
    id: contentHolder
    anchors.fill: parent
    Loader {
      id: contentLoader
      anchors.fill: parent
      active: !!root.content && (root.open || root.contentRequested)
      sourceComponent: root.content
    }
  }
}
