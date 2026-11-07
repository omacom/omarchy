pragma Singleton
import QtQuick

QtObject {
  readonly property QtObject polkit: QtObject {
    readonly property color accent: "#88f"
    readonly property color background: "#111"
    readonly property color border: "#444"
    readonly property color borderError: "#f44"
    readonly property color scrim: "#80000000"
    readonly property color text: "#eee"
    readonly property color textError: "#f44"
  }
}
