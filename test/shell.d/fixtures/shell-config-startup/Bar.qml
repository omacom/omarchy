import QtQuick

// The startup test exercises the real shell host and service loader. Keep the
// bar inert so its unrelated layer-shell widgets do not add runtime noise.
Item {
  property string omarchyPath: ""
  property var barWidgetRegistry: null
  property var pluginRegistry: null
  property var barConfig: ({})
  property var shell: null
  property var manifest: null
}
