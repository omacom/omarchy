import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons

Item {
  id: root

  property var shell: null
  property var manifest: null
  property var pluginRegistry: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") + "/voxtype"
  property bool enabled: false
  property bool suppressed: true
  property string daemonState: "idle"
  property real audioLevel: 0
  property bool connected: false
  property color thinkingColor: Color.accent
  readonly property bool recording: daemonState === "recording" || daemonState === "streaming"
  readonly property bool tracking: enabled && !suppressed && (recording || daemonState === "transcribing")
  readonly property string focusedScreenName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
  readonly property var activeScreen: {
    var screens = Quickshell.screens
    for (var i = 0; i < screens.length; i++) {
      if (screens[i].name === focusedScreenName) return screens[i]
    }
    return screens.length ? screens[0] : null
  }

  onTrackingChanged: {
    audioLevel = 0
    connected = false
    retry.stop()
    bridge.running = tracking
  }

  // Explicit opt-in keeps existing Voxtype installations using their chosen OSD.
  FileView {
    id: optIn
    path: Quickshell.env("HOME") + "/.config/voxtype/omarchy-osd"
    watchChanges: true
    printErrors: false
    onLoaded: root.enabled = true
    onLoadFailed: root.enabled = false
    onFileChanged: reload()
  }

  FileView {
    id: suppression
    path: root.runtimeDir + "/osd_suppressed"
    watchChanges: true
    printErrors: false
    onLoaded: root.suppressed = true
    onLoadFailed: root.suppressed = false
    onFileChanged: reload()
  }

  FileView {
    id: stateFile
    path: root.runtimeDir + "/state"
    watchChanges: true
    printErrors: false
    onLoaded: {
      // The --no-osd marker is written before the state transition.
      suppression.reload()
      root.daemonState = text().trim()
    }
    onLoadFailed: root.daemonState = "idle"
    onFileChanged: reload()
  }

  // Recover watches when Voxtype is installed or its runtime directory recreated.
  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: {
      optIn.reload()
      if (root.enabled) {
        suppression.reload()
        stateFile.reload()
      }
    }
  }

  FileView {
    path: Color.currentThemePath + "/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var orange = text().match(/^orange\s*=\s*["'](#[0-9a-fA-F]{6})["']/m)
      var yellow = text().match(/^(?:yellow|color3)\s*=\s*["'](#[0-9a-fA-F]{6})["']/m)
      root.thinkingColor = orange ? orange[1] : (yellow ? yellow[1] : Color.accent)
    }
    onLoadFailed: root.thinkingColor = Color.accent
  }

  Process {
    id: bridge
    command: ["voxtype-audio-bridge"]
    stdout: SplitParser {
      onRead: data => {
        try {
          var frame = JSON.parse(data)
          if (typeof frame.peak === "number" && isFinite(frame.peak)) {
            root.connected = true
            root.audioLevel = Math.min(1, Math.max(0, frame.peak))
            staleAudio.restart()
          } else if (frame.status === "disconnected") {
            root.audioLevel = 0
            root.connected = false
          } else if (frame.status === "connected") {
            root.connected = true
          }
        } catch (_) {}
      }
    }
    onExited: {
      root.audioLevel = 0
      root.connected = false
      if (root.tracking) retry.restart()
    }
  }

  Timer {
    id: retry
    interval: 1000
    onTriggered: if (root.tracking) bridge.running = true
  }
  Timer {
    id: staleAudio
    interval: 250
    onTriggered: root.audioLevel = 0
  }

  VoiceNode {
    phase: !root.enabled || root.suppressed || !root.connected ? "dormant"
      : root.recording ? "listening"
      : root.daemonState === "transcribing" ? "thinking" : "dormant"
    listeningLevel: root.audioLevel
    thinkingColor: root.thinkingColor
    targetScreen: root.activeScreen
  }
}
