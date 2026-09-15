import QtQuick

Item {
  objectName: "service"
  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  property var barWidgetRegistry: null
  property var pluginRegistry: null
  property string observedHostPath: shell ? shell.omarchyPath : ""

  Component.onDestruction: parent.serviceDestroyed(objectName)
}
