import QtQuick

Column {
  readonly property bool extensionMarker: true
  property bool initiallyVisible: false
  Component.onCompleted: initiallyVisible = visible
  Rectangle { width: 100; height: 49 }
}
