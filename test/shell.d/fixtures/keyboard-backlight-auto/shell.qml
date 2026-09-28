import QtQuick
import Quickshell

// Loads the real keyboard backlight service against a stub monitor-sensor and
// brightnessctl, a synthetic LED directory, and a short settle time.
ShellRoot {
  id: root

  QtObject {
    id: mockShell
    property var shellConfig: ({ keyboardBacklight: { settleSeconds: 0.3 } })
  }

  Component.onCompleted: {
    var url = Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/keyboard-backlight/Service.qml"
    var component = Qt.createComponent(url, Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      console.error("KEYBOARD_BACKLIGHT_LOAD_FAILED " + component.errorString())
      Qt.exit(1)
      return
    }
    component.createObject(root, { shell: mockShell })
  }
}
