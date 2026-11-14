pragma Singleton

import QtQml

QtObject {
  property QtObject bar: QtObject {
    property int sizeHorizontal: 26
    property int sizeVertical: 28
    property int iconSlot: 27
    property int iconCanvas: 16
    property int iconSize: 12
  }

  property QtObject font: QtObject {
    property string family: "monospace"
    property real body: 12
  }

  function space(value) { return Number(value) }
  function spaceReal(value) { return Number(value) }
  function duration(ms) { return ms }
}
