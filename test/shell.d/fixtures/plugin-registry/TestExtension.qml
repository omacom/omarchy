import QtQuick

Item {
  readonly property bool extensionMarker: true
  property bool panelOpen: false
  property int draft: 0
  property var settings: ({})
  property var shell: null
  implicitHeight: panelOpen ? (settings.height || 37) : 0
}
