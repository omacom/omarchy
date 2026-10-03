// Adapted from omacom/atreyu; see LICENSE.atreyu.
import QtQuick
import QtQuick.Effects
import qs.Commons

Item {
  id: root

  property color accent: Color.accent
  property real level: 0.5
  property bool levelMetered: false
  property real intensity: 1
  property bool compact: false
  property bool motionEnabled: true
  readonly property int columns: compact ? 18 : 72
  readonly property real boundedLevel: Math.max(0, Math.min(1, level))
  readonly property real visualLevel: levelMetered && boundedLevel > 0.025
    ? Math.min(1, Math.pow((boundedLevel - 0.025) / 0.975, 0.62) * 1.18)
    : (levelMetered ? 0 : boundedLevel * 0.78)
  readonly property real trackWidth: width * (compact ? 0.92 : 0.84)
  readonly property real columnStep: trackWidth / columns
  property real phase: 0

  function alphaColor(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha)
  }

  function barHeight(column) {
    var distance = Math.abs(column - (columns - 1) * 0.5) / ((columns - 1) * 0.5)
    var edge = 1 - distance * 0.74
    var wobble = 0.56 + 0.44 * Math.sin(column * 0.47 - phase * 4.2)
      * Math.sin(column * 0.13 + phase * 2.6)
    var activity = Math.max(0.02, (0.08 + visualLevel * 1.05) * edge * wobble)
    return Math.max(Style.spaceReal(2), Math.min(height * 0.84, height * 0.84 * activity))
  }

  Timer {
    interval: 33
    repeat: true
    running: root.motionEnabled && root.visible
    onTriggered: root.phase = (root.phase + 0.032) % (Math.PI * 200)
  }

  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    width: root.trackWidth
    height: 1
    color: root.alphaColor(root.accent, 0.18)
    opacity: root.intensity
  }

  Item {
    id: spectrumSource
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    width: root.trackWidth
    height: parent.height
    visible: false

    Repeater {
      model: root.columns

      delegate: Rectangle {
        required property int index
        readonly property real extent: root.barHeight(index)
        x: index * root.columnStep + (root.columnStep - width) * 0.5
        y: (parent.height - extent) * 0.5
        width: Math.max(1, Math.min(Style.spaceReal(2.5), root.columnStep * 0.34))
        height: extent
        gradient: Gradient {
          orientation: Gradient.Vertical
          GradientStop { position: 0; color: root.alphaColor(root.accent, 0.52) }
          GradientStop { position: 0.5; color: root.alphaColor(root.accent, 0.95) }
          GradientStop { position: 1; color: root.alphaColor(root.accent, 0.52) }
        }
      }
    }
  }

  MultiEffect {
    anchors.fill: spectrumSource
    source: spectrumSource
    autoPaddingEnabled: true
    blurEnabled: true
    blur: 1
    blurMax: 12
    blurMultiplier: 0.6
    brightness: 0.4
    opacity: root.intensity * 0.68
  }

  ShaderEffectSource {
    anchors.fill: spectrumSource
    sourceItem: spectrumSource
    hideSource: false
    opacity: root.intensity
  }
}
