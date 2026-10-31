pragma Singleton
import QtQuick

// Isolate theme state from the running shell; Border remains the real component.
QtObject {
  property var shellValues: ({})
  property color foreground: "#eeeeee"
  property color background: "#222222"
  property color accent: "#88bbff"
  property color urgent: "#ff5555"
  property QtObject popups: QtObject {
    property color text: "#eeeeee"
    property color background: "#222222"
    property color border: "#88bbff"
  }
}
