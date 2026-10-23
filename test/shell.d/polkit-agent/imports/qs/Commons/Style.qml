pragma Singleton
import QtQuick

// Just the Style names PolkitAgent.qml reads, with fixed sizes.
QtObject {
  readonly property int cornerRadius: 8
  readonly property int gapsOut: 8
  readonly property QtObject font: QtObject {
    readonly property int bodySmall: 12
    readonly property int iconLarge: 20
    readonly property string menuFamily: "sans"
  }
  readonly property QtObject spacing: QtObject {
    readonly property int controlHeight: 36
    readonly property int panelPadding: 12
  }
  function space(n) { return n }
  function duration(n) { return n }
}
