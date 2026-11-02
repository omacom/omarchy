import QtQuick

// The real intro opens a layer-shell window, which an offscreen test shell cannot create.
Item {
  property var host: null
  signal coverPresented()
  property string themeToken: ""
  property string themeBackground: ""
  property bool revealing: false
  readonly property var backgroundService: null
  function prepareTheme(fromPath, token, colors, shell) {}
  function finishTheme(token, cut) {}
  function cancelTheme() {}
  function themeStatus(token) { return "" }
  function themeCoverStatus(token) { return "" }
}
