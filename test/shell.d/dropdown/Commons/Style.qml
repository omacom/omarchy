pragma Singleton
import QtQuick

// Fixed theme tokens avoid loading Quickshell services or user configuration.
QtObject {
  property var styleOverrides: ({})
  property real normalBorderWidth: 1
  property real focusBorderWidth: 1
  property real hoverBorderWidth: 1
  property real normalBorderAlpha: 1
  property real focusBorderAlpha: 1
  property real hoverBorderAlpha: 1
  property real cornerRadius: 0
  property QtObject spacing: QtObject {
    property int controlHeight: 28
    property int popupRowHeight: 28
    property int dropdownWidth: 240
    property int huge: 18
    property int labelGap: 4
    property int controlPaddingX: 10
    property int controlGap: 8
    property int md: 6
    property int xxs: 2
    property int hairline: 1
  }
  property QtObject font: QtObject {
    property string family: "monospace"
    property int caption: 10
    property int body: 12
  }
  function normalStateColor(foreground, accent) { return foreground }
  function focusStateColor(foreground, accent) { return accent }
  function hoverStateColor(foreground, accent) { return accent }
  function hoverFillFor(foreground, accent) { return "#334455" }
  function controlFill(focused, hot, foreground, accent) { return "#222222" }
}
