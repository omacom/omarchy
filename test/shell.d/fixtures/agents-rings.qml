import QtQuick
import QtQuick.Window
import "../../../shell/plugins/agents" as Agents
import "../../../shell/plugins/agents/GlanceModel.js" as Model

// Component visual fixture. Run with Qt's qml tool. It does not launch Omarchy
// or substitute for the compositor acceptance check.
Window {
  id: window
  width: 780
  height: 260
  visible: true
  title: "Agent usage ring states"
  color: "#17191e"

  Column {
    id: content
    anchors.fill: parent
    Repeater {
      model: [false, true]
      delegate: Rectangle {
        id: ringPalette
        required property bool modelData
        width: content.width
        height: content.height / 2
        color: modelData ? "#f4f1eb" : "#17191e"
        Row {
          anchors.centerIn: parent
          spacing: 18
          Repeater {
            model: [
              { label: "20% used", fraction: 0.2, known: true, activity: "unknown" },
              { label: "95% used", fraction: 0.95, known: true, activity: "unknown" },
              { label: "Needs input", fraction: 0.4, known: true, activity: "waiting" },
              { label: "Working", fraction: 0.4, known: true, activity: "working" },
              { label: "Stale", fraction: 0.95, known: true, stale: true },
              { label: "Unavailable", fraction: 0, known: false }
            ]
            delegate: Column {
              required property var modelData
              width: 104
              spacing: 14
              Agents.UsageRing {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 24
                height: width
                fraction: parent.modelData.fraction
                known: parent.modelData.known
                stale: parent.modelData.stale === true
                activity: parent.modelData.activity || "unknown"
                foreground: ringPalette.modelData ? "#282b32" : "#e0e2e6"
                trackColor: ringPalette.modelData ? "#d4d0c8" : "#42464e"
                ringColor: parent.modelData.fraction >= 0.9 ? "#c75151" : (ringPalette.modelData ? "#376985" : "#9cbcd0")
                attentionColor: "#c75151"
                glyph: "C"
              }
              Text {
                width: parent.width
                text: parent.modelData.label
                textFormat: Text.PlainText
                color: ringPalette.modelData ? "#282b32" : "#e0e2e6"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
              }
            }
          }
        }
      }
    }
  }
  Timer {
    interval: 500
    running: true
    onTriggered: content.grabToImage(function(result) {
      var args = Qt.application.arguments
      var target = args[args.length - 1]
      if (!target.endsWith(".png") || !result.saveToFile(target)) Qt.exit(1)
      else Qt.quit()
    })
  }
}
