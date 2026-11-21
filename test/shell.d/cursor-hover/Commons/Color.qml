pragma Singleton
import QtQuick

// Fixed theme state for the cursor hover fixture; Border stays the real
// component from shell/Commons.
QtObject {
  property color foreground: "#eeeeee"
  property color accent: "#88bbff"
  property color urgent: "#ff5555"
  property color background: "#101010"
  property var shellValues: ({})
}
