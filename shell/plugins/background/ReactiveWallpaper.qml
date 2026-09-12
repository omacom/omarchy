import QtQuick
import QtQuick.Shapes
import "ReactiveScene.js" as Scene

Item {
  id: root
  property var scene: null
  property var levels: ({ claude: 0, codex: 0 })
  property bool playbackEnabled: false
  property string previewLabel: ""
  clip: true

  Item {
    id: canvas
    width: root.scene ? root.scene.width : 1
    height: root.scene ? root.scene.height : 1
    anchors.centerIn: parent
    scale: Math.max(root.width / width, root.height / height)

    Repeater {
      model: root.scene ? root.scene.lights : []
      Item {
        id: light
        required property var modelData
        anchors.fill: parent
        readonly property real strength: !root.playbackEnabled ? 0 : modelData.channel === "combined"
          ? Math.min(1, (Scene.level(root.levels.claude) + Scene.level(root.levels.codex)) / 1.35)
          : Scene.level(root.levels[modelData.channel])
        opacity: strength
        visible: opacity > 0.001
        Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }

        // Fixed geometry, layered translucent strokes: only opacity animates.
        // No full-screen blur texture, particle timer, or idle render loop.
        Repeater {
          model: [ { width: 22, alpha: 0.035 }, { width: 14, alpha: 0.055 }, { width: 8, alpha: 0.10 }, { width: 4, alpha: 0.22 }, { width: 1.8, alpha: 0.7 }, { width: 0.65, alpha: 1 } ]
          Shape {
            id: strokeShape
            required property var modelData
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            opacity: modelData.alpha
            ShapePath {
              strokeColor: strokeShape.modelData.width < 1 ? "#fff5ef" : light.modelData.color
              strokeWidth: light.modelData.width * strokeShape.modelData.width
              fillColor: "transparent"
              capStyle: ShapePath.RoundCap
              joinStyle: ShapePath.RoundJoin
              PathSvg { path: light.modelData.path }
            }
          }
        }
      }
    }
  }

  Rectangle {
    visible: root.previewLabel !== ""
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 36
    width: caption.implicitWidth + 40
    height: caption.implicitHeight + 24
    color: "#eeeff1f5"
    border.color: "#9ca0b0"
    Text {
      id: caption
      anchors.centerIn: parent
      text: "CIRCUIT CITY   /   " + root.previewLabel + "   ·   SIMULATED ACTIVITY"
      textFormat: Text.PlainText
      color: "#4c4f69"
      font.pixelSize: Math.max(9, Math.min(22, root.width / 70))
      font.letterSpacing: 1
    }
  }
}
