import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons

// Keep startup and cover state in the persistent host, including handoffs
// with older OWE versions that destroy and recreate the background service.
Item {
  id: root

  property var host: null
  property bool cover: String(bootMarker.text() || "").trim() !== (Quickshell.env("OMARCHY_BOOT_ID") || String(bootId.text() || "").trim())
  property bool checked: false
  property string themeToken: ""
  property string transitionToken: ""
  property string themeBackground: ""
  property var themeNativeSize: null
  property string themeColors: ""
  property string themeShell: ""
  property real themeOpacity: 1
  readonly property var backgroundService: host && host.services ? host.firstPartyServiceFor("omarchy.background") : null
  readonly property bool backgroundActive: !!backgroundService && !backgroundService.suspended

  function prepareTheme(fromPath, token, colors, shell) {
    framePoll.stop()
    themeFade.stop()
    themeToken = token
    transitionToken = token
    if (themeBackground !== fromPath) {
      themeNativeSize = backgroundService && backgroundService.nativeSizes ? backgroundService.nativeSizes[backgroundService.displayedBackground] : null
    }
    themeBackground = fromPath
    themeColors = colors
    themeShell = shell
    themeOpacity = 1
    themeFallback.restart()
  }

  function revealTheme() {
    if (!themeToken) return
    framePoll.stop()
    themeFallback.stop()
    Color.loadColors(Util.decodeBase64(themeColors))
    Color.loadShell(Util.decodeBase64(themeShell))
    Style.scheduleRefresh()
    themeToken = ""
    themeColors = ""
    themeShell = ""
    themeFade.restart()
  }

  function finishTheme(token) {
    if (token === themeToken) revealTheme()
  }

  function themeStatus(token) {
    return token === transitionToken && (themeToken || themeFade.running) ? "pending" : "ready"
  }

  function cancelTheme() {
    framePoll.stop()
    themeFallback.stop()
    themeFade.stop()
    themeToken = ""
    transitionToken = ""
    themeBackground = ""
    themeColors = ""
    themeShell = ""
  }

  NumberAnimation {
    id: themeFade
    target: root
    property: "themeOpacity"
    to: 0
    duration: Style.duration(420)
    easing.type: Easing.OutCubic
    onFinished: root.themeBackground = ""
  }

  Timer {
    id: themeFallback
    interval: 10000
    onTriggered: root.revealTheme()
  }

  // A renderer left over from another intro can first fade from its still.
  // Keep that preparation hidden until the actual video is fully revealed.
  Timer {
    id: framePoll
    interval: 16
    repeat: true
    onTriggered: if (!frameStatus.running) frameStatus.running = true
  }

  Process {
    id: frameStatus
    command: ["owe", "render-status"]
    property string token: ""
    onStarted: token = root.themeToken
    stdout: StdioCollector { id: frameStatusOut }
    onExited: function(exitCode) {
      if (exitCode !== 0 || token !== root.themeToken || !token) return
      try {
        var status = JSON.parse(frameStatusOut.text)
        if (status.kind === "video" && status.ready && !status.has_transition && status.time_pos > 0)
          root.revealTheme()
      } catch (e) {}
    }
  }

  // Snapshot startup state: the launcher records this boot before playback.
  FileView {
    id: bootMarker
    path: Quickshell.env("HOME") + "/.local/state/omarchy/background-intro.boot-id"
    blockLoading: true
    watchChanges: false
    printErrors: false
  }

  FileView {
    id: bootId
    path: "/proc/sys/kernel/random/boot_id"
    blockLoading: true
    watchChanges: false
  }

  Component.onCompleted: {
    checked = true
    introProc.running = true
  }

  onBackgroundActiveChanged: {
    if (!backgroundActive && checked) {
      cover = false
      if (themeToken) {
        framePoll.start()
        if (!frameStatus.running) frameStatus.running = true
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: root.cover || root.themeBackground !== ""
      color: root.cover ? "black" : "transparent"
      mask: Region {}
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"

      Image {
        anchors.fill: parent
        source: root.themeBackground ? Util.fileUrl(root.themeBackground) : ""
        sourceSize: {
          var w = Math.ceil(parent.width * modelData.devicePixelRatio)
          var h = Math.ceil(parent.height * modelData.devicePixelRatio)
          var native = root.themeNativeSize
          return native && (native.width < w || native.height < h) ? Qt.size(native.width, native.height) : Qt.size(w, h)
        }
        fillMode: Image.PreserveAspectCrop
        opacity: root.themeOpacity
        // Start decoding while the remaining theme configs render.
        asynchronous: true
      }
    }
  }

  Process {
    id: introProc
    command: ["omarchy-theme-bg-boot-intro"]
    onExited: root.cover = false
  }
}
