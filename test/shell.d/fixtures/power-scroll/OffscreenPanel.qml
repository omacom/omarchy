import QtQuick

// Substitute only the Wayland window backend. The test instantiates the real
// power panel content in an offscreen Window with a capped viewport.
Item {
  property Item anchorItem: null
  property QtObject bar: null
  property var owner: null
  property bool open: false
  property Item focusTarget: null
  property int contentWidth: 0
  property int contentHeight: 0
  property Component content: null
  property var loadedContent: null
  readonly property int loadedContentHeight: 0
  function fittedContentWidth(value) { return value }
  function fittedContentHeight(value) { return value }
  function ensureContent() {}
}
