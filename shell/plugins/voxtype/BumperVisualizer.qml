// Adapted from omacom/atreyu; see LICENSE.atreyu.
import QtQuick
import QtQuick.Effects
import qs.Commons

Item {
  id: root

  property color accent: Color.accent
  property real level: 0.5
  property real intensity: 1
  property bool motionEnabled: true
  readonly property real boundedLevel: Math.max(0, Math.min(1, level))
  readonly property real visualLevel: boundedLevel * 0.78
  readonly property real trackWidth: width * 0.84
  readonly property real barWidth: trackWidth * (0.18 + visualLevel * 0.12)
  readonly property real barHeight: Math.max(6, Math.min(22, 13 + visualLevel * 9))
  readonly property real trackX: (width - trackWidth) * 0.5
  readonly property real centerY: height * 0.5
  readonly property bool running: sweepTimer.running
  property real phase: 0

  function alphaColor(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha)
  }

  function sweepX(offset) {
    var travel = (trackWidth - barWidth) * 0.5
    return trackX + trackWidth * 0.5 - barWidth * 0.5
      + Math.sin(phase * 1.5 + offset) * travel
  }

  Timer {
    id: sweepTimer
    interval: 33
    repeat: true
    running: root.motionEnabled && root.visible
    onTriggered: root.phase = (root.phase + 0.032) % (Math.PI * 200)
  }

  Rectangle {
    x: root.trackX
    y: root.centerY - root.barHeight * 0.5
    width: root.trackWidth
    height: root.barHeight
    color: root.alphaColor(root.accent, 0.035)
    border.width: 1
    border.color: root.alphaColor(root.accent, 0.16)
    radius: 0
    opacity: root.intensity
  }

  Repeater {
    model: [
      { offset: -0.32, alpha: 0.12 },
      { offset: -0.16, alpha: 0.22 }
    ]

    delegate: Rectangle {
      required property var modelData
      x: root.sweepX(modelData.offset)
      y: root.centerY - root.barHeight * 0.5
      width: root.barWidth
      height: root.barHeight
      opacity: root.intensity * modelData.alpha
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0; color: "transparent" }
        GradientStop { position: 0.5; color: root.accent }
        GradientStop { position: 1; color: "transparent" }
      }
    }
  }

  Item {
    id: sweepSource
    x: root.sweepX(0)
    y: root.centerY - root.barHeight * 0.5
    width: root.barWidth
    height: root.barHeight
    visible: false

    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0; color: "transparent" }
        GradientStop { position: 0.5; color: root.accent }
        GradientStop { position: 1; color: "transparent" }
      }
    }
  }

  MultiEffect {
    anchors.fill: sweepSource
    source: sweepSource
    autoPaddingEnabled: true
    blurEnabled: true
    blur: 1
    blurMax: 30
    blurMultiplier: 1 + root.visualLevel * 0.45
    brightness: 0.65
    opacity: root.intensity
  }

  ShaderEffectSource {
    anchors.fill: sweepSource
    sourceItem: sweepSource
    hideSource: false
    opacity: root.intensity
  }
}
