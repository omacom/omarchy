import Quickshell
import Quickshell.Io
import QtQuick
import "ReactiveScene.js" as Scene

Item {
  id: root
  property string path: ""
  property bool playbackEnabled: false
  property var scene: null
  property var levels: ({ claude: 0, codex: 0 })
  property int previewSecond: -1
  readonly property bool previewing: previewSecond >= 0
  readonly property string previewLabel: !previewing ? "" : previewSecond < 3 ? "IDLE" : previewSecond < 8 ? "CLAUDE WORKING" : previewSecond < 13 ? "CODEX JOINS" : previewSecond < 19 ? "BOTH COOKING" : "BACK TO IDLE"
  readonly property var output: !playbackEnabled ? ({ claude: 0, codex: 0 }) : previewing
    ? ({ claude: previewSecond < 3 || previewSecond >= 19 ? 0 : previewSecond < 13 ? 0.5 : 1,
         codex: previewSecond < 8 || previewSecond >= 19 ? 0 : previewSecond < 13 ? 0.6 : 1 }) : levels

  onPathChanged: {
    scene = null
    levels = ({ claude: 0, codex: 0 })
    previewSecond = -1
  }
  onPlaybackEnabledChanged: if (!playbackEnabled) { levels = ({ claude: 0, codex: 0 }); previewSecond = -1 }

  FileView {
    path: root.path && !/\.(mp4|webm|mov|mkv)$/i.test(root.path) ? root.path + ".reactive.json" : ""
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.scene = Scene.parse(text())
    onLoadFailed: root.scene = null
  }

  Process {
    id: activity
    command: ["python3", decodeURIComponent(Qt.resolvedUrl("activity.py").toString().replace(/^file:\/\//, ""))]
    running: root.scene !== null && root.playbackEnabled && !root.previewing
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var record = JSON.parse(line)
          root.levels = ({ claude: Scene.level(record.levels.claude), codex: Scene.level(record.levels.codex) })
          watchdog.restart()
        } catch (_) { root.levels = ({ claude: 0, codex: 0 }) }
      }
    }
    onExited: root.levels = ({ claude: 0, codex: 0 })
  }

  Timer {
    id: watchdog
    interval: 4000
    onTriggered: root.levels = ({ claude: 0, codex: 0 })
  }
  Timer {
    interval: 1000
    repeat: true
    running: root.previewing
    onTriggered: root.previewSecond = root.previewSecond >= 24 ? -1 : root.previewSecond + 1
  }
  IpcHandler {
    target: "background-activity"
    function preview(): void {
      if (root.scene && root.playbackEnabled) root.previewSecond = 0
    }
    function stopPreview(): void { root.previewSecond = -1 }
  }
}
