import QtQuick

// Scalar-only view of the active bar for plugins that position independent
// windows. The active Bar QObject is never retained here.
QtObject {
  required property string ownerPluginId

  property bool barHidden: false
  // The configured size. A notch floor can make a top bar thicker on one
  // screen; barSizes holds each screen's thickness by screen name.
  property int barSize: 0
  property var barSizes: ({})
  property string fontFamily: ""
  property string position: "top"

  // The bar's thickness on the screen with this name, to clear the bar by;
  // barSize for a screen the bar reports none for.
  function barSizeFor(screenName) {
    var name = String(screenName || "")
    var size = barSizes && Object.prototype.hasOwnProperty.call(barSizes, name) ? Number(barSizes[name]) : 0
    return size > 0 ? size : barSize
  }
}
