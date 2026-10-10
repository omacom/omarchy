pragma Singleton
import QtQuick

QtObject {
  property QtObject screen: QtObject {
    property string name: "fixture-display"
    property int x: 0
    property int y: 0
  }
  property var screens: [screen]
  property QtObject monitor: QtObject {
    property QtObject activeWorkspace: QtObject {
      property bool hasFullscreen: false
    }
  }
  function monitorFor(screen) { return monitor }
}
