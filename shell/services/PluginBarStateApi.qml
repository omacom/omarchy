import QtQuick

// Scalar-only view of the active bar for plugins that position independent
// windows. The active Bar QObject is never retained here.
QtObject {
  required property string ownerPluginId

  property bool barHidden: false
  property int barSize: 0
  // Gap between a floating bar and the screen edges; only the edge it is
  // anchored to and the two it spans apply, and all are 0 for a flush bar.
  // The bar's outer face is barSize + barMargins[position] from its edge.
  property var barMargins: ({ top: 0, right: 0, bottom: 0, left: 0 })
  property string fontFamily: ""
  property string position: "top"
}
