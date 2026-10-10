pragma Singleton
import QtQuick

// Stands in for Quickshell.Bluetooth. Setting defaultAdapter to null is what
// BlueZ does when a platform rfkill switch cuts power to the controller.
QtObject {
  property QtObject adapter: QtObject {
    property bool enabled: true
    property bool discovering: false
  }
  property var defaultAdapter: adapter
  property var devices: ({ values: [] })
}
