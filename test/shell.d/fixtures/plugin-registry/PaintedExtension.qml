import QtQuick

Item {
  readonly property bool extensionMarker: true
  property bool panelOpen: false
  property var settings: ({})
  implicitHeight: panelOpen ? 49 : (settings.partial ? 10 : 0)
  Rectangle { width: 100; height: 49; color: "red" }
}
