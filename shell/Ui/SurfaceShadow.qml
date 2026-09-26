import QtQuick
import QtQuick.Effects

// An outer-only shadow. Masking out the card avoids tinting translucent fills.
// The padded source includes the complete blur; this item never handles input.
// Instantiate through a Loader only when spec.enabled is true.
Item {
  id: root
  required property var spec
  property real radius: 0

  Item {
    id: padded
    x: -root.spec.left
    y: -root.spec.top
    width: root.width + root.spec.left + root.spec.right
    height: root.height + root.spec.top + root.spec.bottom

    Item {
      id: shadowSource
      anchors.fill: parent

      RectangularShadow {
        x: root.spec.left
        y: root.spec.top
        width: root.width
        height: root.height
        radius: Math.min(root.radius, root.width / 2, root.height / 2)
        color: root.spec.color
        blur: root.spec.blur
        spread: root.spec.spread
        offset: Qt.vector2d(root.spec.offsetX, root.spec.offsetY)
      }
    }

    Item {
      id: maskSource
      anchors.fill: parent

      Rectangle {
        x: root.spec.left
        y: root.spec.top
        width: root.width
        height: root.height
        radius: Math.min(root.radius, root.width / 2, root.height / 2)
        color: "white"
        antialiasing: true
      }
    }

    ShaderEffectSource {
      id: shadowTexture
      sourceItem: shadowSource
      hideSource: true
      visible: false
    }

    ShaderEffectSource {
      id: maskTexture
      sourceItem: maskSource
      hideSource: true
      visible: false
    }

    MultiEffect {
      anchors.fill: parent
      source: shadowTexture
      maskEnabled: true
      maskSource: maskTexture
      maskInverted: true
      maskThresholdMin: 0.0
      maskSpreadAtMin: 0.0
      maskThresholdMax: 1.0
      maskSpreadAtMax: 0.0
    }
  }
}
