import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property color themeForeground: "#333333"
  property color themeContrastForeground: "#eeeeee"
  property color transparentForeground: "#909090"
  property bool requestedTransparent: false
  property bool useTransparentForeground: false
  property bool transparent: false
  property bool foregroundAnimationEnabled: true
  property string position: "top"
  property int barSize: 30
  property string scenario: Quickshell.env("SCENARIO")
  property int phase: 0
  property int ticks: 0
  property int samples: 0
  property bool staleApplied: false

  QtObject {
    id: util
    function clamp(value, low, high) { return Math.max(low, Math.min(value, high)) }
  }

  // PRODUCTION_SAMPLER

  onTransparentForegroundChanged: {
    if (phase > 0 && String(transparentForeground) === "#111111") staleApplied = true
  }

  Connections {
    target: transparentForegroundProc
    function onRunningChanged() {
      if (transparentForegroundProc.running) root.samples++
    }
  }

  Process {
    id: releaseSample
    command: ["touch", Quickshell.env("SAMPLE_GATE")]
  }

  Component.onCompleted: setRequestedTransparency(true)

  Timer {
    interval: 20
    repeat: true
    running: true
    onTriggered: {
      root.ticks++
      if (root.phase === 0 && transparentForegroundProc.running) {
        root.phase = 1
        root.ticks = 0
        if ((root.scenario === "foreground" || root.scenario === "early")) root.themeForeground = "#444444"
        else if (root.scenario === "contrast") root.themeContrastForeground = "#dddddd"
        else if (root.scenario === "position") root.position = "bottom"
        else if (root.scenario === "size") root.barSize = 42
        else if ((root.scenario === "background" || root.scenario === "failure-latest")) root.scheduleTransparentForegroundRefresh()
        else if (root.scenario === "rapid") {
          root.themeForeground = "#444444"
          root.themeContrastForeground = "#dddddd"
          root.position = "right"
          root.barSize = 42
          root.scheduleTransparentForegroundRefresh()
        } else if (root.scenario === "toggle") {
          root.setRequestedTransparency(false)
          root.setRequestedTransparency(true)
        } else if (root.scenario === "off") root.setRequestedTransparency(false)
      }
      if (root.phase === 1 && root.ticks >= (root.scenario === "early" ? 2 : 12)) {
        releaseSample.running = true
        root.phase = 2
        root.ticks = 0
      }
      if (root.phase === 2 && root.ticks >= 45) {
        var passive = root.scenario === "off" || root.scenario === "failure"
        var expected = root.scenario === "off" ? "#333333" : root.scenario === "failure" ? "#909090" : "#222222"
        if (root.staleApplied || String(root.transparentForeground) !== expected
            || root.samples !== (passive ? 1 : 2) || transparentForegroundProc.running
            || (root.scenario === "off" && (root.useTransparentForeground || root.transparent))) {
          console.log("RESULT fail " + root.scenario + " color=" + root.transparentForeground
                      + " samples=" + root.samples + " stale=" + root.staleApplied)
        } else console.log("RESULT pass " + root.scenario)
        Qt.quit()
      }
    }
  }
  Timer { interval: 5000; running: true; onTriggered: { console.log("RESULT fail timeout"); Qt.quit() } }
}
