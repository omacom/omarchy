import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons

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
  property string stateHome: Quickshell.env("HOME") + "/.local/state"
  // PRODUCTION_GEOMETRY
  property string scenario: Quickshell.env("SCENARIO")
  property int phase: 0
  property int ticks: 0
  property int samples: 0
  property bool staleApplied: false
  property color initialSampleForeground: "#909090"
  property bool samplerStarted: false
  // The real bar's palette bindings instantiate Color. Our literal palette
  // must still load its shell.toml before sampling the bound Style dimensions.
  readonly property bool styleReady: Commons.Color.shellValues && Commons.Color.shellValues["bar.size-horizontal"] === "30" && Style.bar.sizeHorizontal === 30

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

  Process {
    id: changeBackground
    command: ["ln", "-nsf", Quickshell.env("BACKGROUND_NEXT"), root.stateHome + "/omarchy/current/background"]
  }

  function startSampling() {
    if (!styleReady || samplerStarted) return
    samplerStarted = true
    setRequestedTransparency(true)
  }

  onStyleReadyChanged: Qt.callLater(startSampling)
  Component.onCompleted: Qt.callLater(startSampling)

  Timer {
    interval: 20
    repeat: true
    running: true
    onTriggered: {
      root.ticks++
      if (root.phase === 0 && transparentForegroundProc.running) {
        root.initialSampleForeground = root.transparentForeground
        root.phase = 1
        root.ticks = 0
        if ((root.scenario === "foreground" || root.scenario === "early")) root.themeForeground = "#444444"
        else if (root.scenario === "contrast") root.themeContrastForeground = "#dddddd"
        else if (root.scenario === "position") root.position = "bottom"
        else if (root.scenario === "orientation") root.position = "left"
        else if (root.scenario === "size") Commons.Color.loadShell("[bar]\nsize-horizontal = 42\nsize-vertical = 36\nscale-with-font = false")
        else if (root.scenario === "orientation-size") {
          root.position = "right"
          Commons.Color.loadShell("[bar]\nsize-horizontal = 30\nsize-vertical = 42\nscale-with-font = false")
        }
        else if (root.scenario === "background") changeBackground.running = true
        else if (root.scenario === "failure-latest") root.scheduleTransparentForegroundRefresh()
        else if (root.scenario === "rapid") {
          root.themeForeground = "#444444"
          root.themeContrastForeground = "#dddddd"
          root.position = "right"
          Commons.Color.loadShell("[bar]\nsize-horizontal = 30\nsize-vertical = 42\nscale-with-font = false")
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
        var expected = root.scenario === "off" ? "#333333" : root.scenario === "failure" ? String(root.initialSampleForeground) : "#222222"
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
