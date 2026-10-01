pragma ComponentBehavior: Bound

import QtQuick

// The 15 × 15 geometry follows Omarchy's icon.png. Only presentation state
// crosses this boundary; the character never receives password text.
Item {
  id: root

  property color color: "white"
  property bool motionEnabled: true
  property bool eyesClosed: false
  property int failedAttempts: 0

  readonly property bool animate: visible && motionEnabled
  readonly property real unit: width / 15
  property real bob: 0
  property real shake: 0
  property bool blinking: false

  onFailedAttemptsChanged: {
    if (failedAttempts > 0 && animate) refusal.restart()
  }
  onAnimateChanged: {
    if (!animate) {
      refusal.stop()
      bob = 0
      shake = 0
      blinking = false
    }
  }

  Item {
    width: root.width
    height: root.height
    x: root.shake
    y: root.bob

    Repeater {
      // x, y, width, height in the original icon's grid.
      model: [
        [0, 0, 15, 1], [0, 1, 1, 13], [14, 1, 1, 13],
        [0, 14, 8, 1], [9, 14, 6, 1],
        [7, 1, 1, 1], [2, 2, 6, 1], [11, 2, 2, 1],
        [2, 3, 1, 9], [12, 3, 1, 9], [1, 7, 1, 1],
        [2, 12, 11, 1], [7, 13, 1, 1]
      ]
      Rectangle {
        required property var modelData
        x: modelData[0] * root.unit
        y: modelData[1] * root.unit
        width: modelData[2] * root.unit
        height: modelData[3] * root.unit
        color: root.color
      }
    }

    Repeater {
      model: [5, 9]
      Rectangle {
        required property int modelData
        x: modelData * root.unit
        y: 5.5 * root.unit
        width: root.unit
        height: 2 * root.unit
        color: root.color
        transform: Scale {
          origin.y: root.unit
          yScale: root.eyesClosed || root.blinking ? 0.15 : 1
          Behavior on yScale {
            NumberAnimation { duration: root.animate ? 100 : 0 }
          }
        }
      }
    }
  }

  SequentialAnimation on bob {
    running: root.animate
    loops: Animation.Infinite
    NumberAnimation { from: 0; to: -3; duration: 1800; easing.type: Easing.InOutSine }
    NumberAnimation { from: -3; to: 0; duration: 1800; easing.type: Easing.InOutSine }
  }

  Timer {
    interval: 4200
    repeat: true
    running: root.animate && !root.eyesClosed
    onTriggered: root.blinking = true
  }
  Timer {
    interval: 140
    running: root.blinking
    onTriggered: root.blinking = false
  }

  SequentialAnimation {
    id: refusal
    NumberAnimation { target: root; property: "shake"; to: -5; duration: 60 }
    NumberAnimation { target: root; property: "shake"; to: 5; duration: 90 }
    NumberAnimation { target: root; property: "shake"; to: -3; duration: 90 }
    NumberAnimation { target: root; property: "shake"; to: 0; duration: 60 }
  }
}
