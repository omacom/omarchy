import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons

// Keep startup and theme covers alive across background service handoffs.
Item {
  id: root

  property var host: null
  property bool cover: true
  readonly property bool sessionConsumed: String(sessionMarker.text() || "").trim() === (Quickshell.env("OMARCHY_SESSION_ID") || Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
  property bool startupSettled: sessionConsumed
  property bool startupPending: !sessionConsumed
  property bool startupMediaReady: false
  readonly property bool desktopReady: !host || (!host.pluginReloading && (!host.pluginRegistry || !host.pluginRegistry.scanning) && (!("bar" in host) || !!host.bar))
  property bool checked: false
  property string themeToken: ""
  property string transitionToken: ""
  readonly property string startupBackgroundPath: Quickshell.env("OMARCHY_STARTUP_BACKGROUND")
  property string themeBackground: sessionConsumed && !Util.isVideoPath(startupBackgroundPath) ? startupBackgroundPath : ""
  property var themeNativeSize: null
  property string themeColors: ""
  property string themeShell: ""
  property real themeOpacity: 1
  // A finished switch whose wallpaper is still hidden or decoding keeps its
  // cover until the wallpaper is on screen, so the fade never reveals a gap.
  property bool themeFinishing: false
  // A switch to a still without an intro of its own opens the cover with the
  // same slanted cut as an ordinary background transition, not the intro fade.
  property bool themeCut: false
  property real themeCutProgress: 0
  // A new palette restyles the whole shell in the frame it lands, and an
  // animation started in that frame begins already advanced by its length,
  // about 40% of the fade. The reveal starts two frames later instead.
  property int revealDelayFrames: 0
  readonly property bool revealing: revealDelayFrames > 0 || themeFade.running || themeCutReveal.running || startupRevealing
  // The outgoing frame reached, or failed to reach, the screen.
  signal coverPresented()
  readonly property var backgroundService: host && host.services ? host.firstPartyServiceFor("omarchy.background") : null
  readonly property bool backgroundActive: !!backgroundService && !backgroundService.suspended
  readonly property bool backgroundReady: backgroundActive && backgroundService.ready !== false

  function finishStartup() {
    if (!cover || !startupSettled) return
    var registry = host ? host.pluginRegistry : null
    var backgroundId = registry ? registry.resolveEnabledId("omarchy.background") : ""
    var disabled = registry && registry.installedPlugins[backgroundId] && !registry.isEnabled(backgroundId)
    if (!backgroundReady && !disabled) return
    cover = false
    if (!themeToken) themeBackground = ""
    startupMediaReady = true
    revealStartup()
  }

  function revealStartup() {
    if (!startupPending || startupRevealing || !startupMediaReady || !desktopReady || startupReadyFrames < 2) return
    startupRevealing = true
    // A cover not listening yet gets the reveal once it connects (startupCover).
    if (!startupCover.send("reveal") && (startupCoverSeen || startupCoverTries > startupCoverMaxTries)) endStartup()
  }

  function endStartup() {
    startupRevealing = false
    startupPending = false
  }

  onDesktopReadyChanged: revealStartup()

  // startup-cover.qml covers the screen from before this shell has loaded
  // until the reveal. It fades out when told, quitting once it has, which
  // ends the startup. Without it, the startup ends at the reveal.
  property bool startupRevealing: false
  // Frames drawn since the desktop became ready, so the reveal shows it whole.
  property int startupReadyFrames: 0
  property bool startupCoverSeen: false
  property int startupCoverTries: 0
  readonly property int startupCoverMaxTries: 20

  FrameAnimation {
    running: root.startupPending && root.desktopReady && root.startupReadyFrames < 2
    onTriggered: {
      root.startupReadyFrames += 1
      if (root.startupReadyFrames === 2) root.revealStartup()
    }
  }

  Socket {
    id: startupCover
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/hypr/" + Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") + "/startup-cover.sock"

    function send(line) {
      if (!connected) return false
      write(line + "\n")
      flush()
      return true
    }

    onConnectionStateChanged: {
      if (connected) {
        root.startupCoverSeen = true
        if (root.startupRevealing) send("reveal")
      } else if (root.startupRevealing && root.startupCoverSeen) {
        root.endStartup()
      }
    }
  }

  // The cover starts with this shell, so it may not be listening yet. Each
  // try that finds nothing logs a socket warning. The tick after the last try
  // gives it time to answer; with no cover by then, a reveal has none to tell.
  Timer {
    interval: 100
    repeat: true
    triggeredOnStart: true
    running: root.startupPending && !root.startupCoverSeen && root.startupCoverTries <= root.startupCoverMaxTries
    onTriggered: {
      root.startupCoverTries += 1
      if (root.startupCoverTries <= root.startupCoverMaxTries) startupCover.connected = true
      else if (root.startupRevealing) root.endStartup()
    }
  }

  onBackgroundReadyChanged: {
    finishStartup()
    if (themeFinishing && backgroundReady) revealTheme()
  }
  Connections {
    target: root.host && root.host.pluginRegistry ? root.host.pluginRegistry : null
    function onPluginsChanged() { root.finishStartup() }
  }

  function prepareTheme(fromPath, token, colors, shell) {
    framePoll.stop()
    frameStatus.consecutiveFailures = 0
    themeFade.stop()
    themeCutReveal.stop()
    revealDelayFrames = 0
    themeCut = false
    themeCutProgress = 0
    themeToken = token
    transitionToken = token
    if (themeBackground !== fromPath) {
      themeNativeSize = backgroundService && backgroundService.nativeSizes ? backgroundService.nativeSizes[backgroundService.displayedBackground] : null
    }
    themeBackground = fromPath
    themeColors = colors
    themeShell = shell
    themeOpacity = 1
    themeFinishing = false
    themeFallback.restart()
  }

  function revealTheme() {
    if (!themeToken && !cover) return
    themeFinishing = false
    framePoll.stop()
    frameStatus.consecutiveFailures = 0
    themeFallback.stop()
    // A background change keeps the theme, so it hands over no palette.
    if (themeToken && (themeColors || themeShell)) {
      Commons.Color.loadColors(Util.decodeBase64(themeColors))
      Commons.Color.loadShell(Util.decodeBase64(themeShell))
      Style.scheduleRefresh()
    }
    cover = false
    themeToken = ""
    themeColors = ""
    themeShell = ""
    if (startupPending) {
      // The login reveal starts on moving video, without showing its final still.
      themeBackground = ""
      startupMediaReady = true
      revealStartup()
    } else {
      revealDelayFrames = 2
    }
  }

  // OWE hands the desktop back to the shell when an intro ends or is cut
  // short, and the new still may still be decoding then.
  function finishTheme(token, cut) {
    if (token !== themeToken) return
    themeCut = !!cut
    if (backgroundReady || !backgroundService) revealTheme()
    else themeFinishing = true
  }

  function themeStatus(token) {
    return token === transitionToken && (themeToken || revealing) ? "pending" : "ready"
  }

  function themeCoverStatus(token) {
    if (token !== themeToken) return "superseded"
    if (!themeBackground) return "ready"
    for (var panel of covers.instances) {
      if (panel.coverFailed) return "error"
      if (!panel.coverReady) return "loading"
    }
    return covers.instances.length > 0 ? "ready" : "loading"
  }

  function cancelTheme() {
    themeFinishing = false
    framePoll.stop()
    frameStatus.consecutiveFailures = 0
    themeFallback.stop()
    themeFade.stop()
    themeCutReveal.stop()
    revealDelayFrames = 0
    themeCut = false
    themeCutProgress = 0
    themeToken = ""
    transitionToken = ""
    themeBackground = ""
    themeColors = ""
    themeShell = ""
  }

  // A missing wallpaper or failed plugin must not leave applications hidden.
  Timer {
    interval: 10000
    running: root.startupPending
    onTriggered: {
      root.cover = false
      if (!root.themeToken) root.themeBackground = ""
      root.startupMediaReady = true
      root.endStartup()
    }
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

  // Matches the background service's own transition.
  NumberAnimation {
    id: themeCutReveal
    target: root
    property: "themeCutProgress"
    from: 0
    to: 1
    duration: Style.duration(840)
    easing.type: Easing.OutCubic
    onFinished: {
      root.themeBackground = ""
      root.themeCut = false
      root.themeCutProgress = 0
    }
  }

  FrameAnimation {
    running: root.revealDelayFrames > 0
    onTriggered: {
      root.revealDelayFrames -= 1
      if (root.revealDelayFrames > 0) return
      if (root.themeCut) themeCutReveal.restart()
      else themeFade.restart()
    }
  }

  Timer {
    id: themeFallback
    interval: 10000
    onTriggered: root.revealTheme()
  }

  // A renderer left over from another intro can first fade from its still.
  // Keep that preparation hidden until the actual video is fully revealed.
  // Stop once nothing is covered: a still wallpaper never reports video.
  Timer {
    id: framePoll
    interval: 50
    repeat: true
    onTriggered: {
      if (!root.cover && !root.themeToken) stop()
      else if (!frameStatus.running) frameStatus.running = true
    }
  }

  Process {
    id: frameStatus
    command: ["owe", "render-status"]
    property string token: ""
    property int consecutiveFailures: 0
    onStarted: token = root.themeToken
    stdout: StdioCollector { id: frameStatusOut }
    onExited: function(exitCode) {
      if (token !== root.themeToken || (!token && !root.cover)) return
      if (exitCode !== 0) {
        consecutiveFailures += 1
        if (consecutiveFailures >= 5) {
          framePoll.stop()
          root.revealTheme()
        }
        return
      }
      consecutiveFailures = 0
      try {
        var status = JSON.parse(frameStatusOut.text)
        if (status.kind === "video" && status.ready && !status.has_transition && status.time_pos > 0)
          root.revealTheme()
      } catch (e) {}
    }
  }

  // A shell restart shares this compositor session; a new login does not.
  FileView {
    id: sessionMarker
    path: Quickshell.env("HOME") + "/.local/state/omarchy/background-intro.session-id"
    blockLoading: true
    watchChanges: false
    printErrors: false
  }

  Process {
    id: startupBackground
    command: ["readlink", "-f", Quickshell.env("HOME") + "/.local/state/omarchy/current/background"]
    stdout: StdioCollector { id: startupBackgroundOut }
    onExited: function(exitCode) {
      var path = String(startupBackgroundOut.text || "").trim()
      if (exitCode === 0 && root.cover && !root.startupPending && !root.themeToken && !Util.isVideoPath(path))
        root.themeBackground = path
    }
  }

  Component.onCompleted: {
    checked = true
    if (!startupBackgroundPath && !startupPending) startupBackground.running = true
    introProc.running = true
  }

  onBackgroundActiveChanged: {
    if (!backgroundActive && checked) {
      if (cover || themeToken) {
        frameStatus.consecutiveFailures = 0
        framePoll.start()
        if (!frameStatus.running) frameStatus.running = true
      }
    }
  }

  Variants {
    id: covers
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      property int coverFrames: 0
      readonly property bool coverReady: outgoingFrame.status === Image.Ready && coverFrames >= 2
      readonly property bool coverFailed: outgoingFrame.status === Image.Error
      onCoverReadyChanged: root.coverPresented()
      onCoverFailedChanged: root.coverPresented()
      screen: modelData
      visible: (!root.startupPending && root.cover) || root.themeBackground !== ""
      // Keep the window transparent throughout the fade. Paint the startup
      // color inside it so changing the window format cannot flash black.
      color: "transparent"
      mask: Region {}
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"

      Rectangle {
        anchors.fill: parent
        visible: root.cover
        color: Commons.Color.background
      }

      Image {
        id: outgoingFrame
        anchors.fill: parent
        source: root.themeBackground ? Util.fileUrl(root.themeBackground) : ""
        sourceSize: {
          var w = Math.ceil((parent.width || modelData.width) * modelData.devicePixelRatio)
          var h = Math.ceil((parent.height || modelData.height) * modelData.devicePixelRatio)
          var native = root.themeNativeSize
          return native && (native.width < w || native.height < h) ? Qt.size(native.width, native.height) : Qt.size(w, h)
        }
        fillMode: Image.PreserveAspectCrop
        opacity: root.themeOpacity
        // Start decoding while the remaining theme configs render.
        asynchronous: true
        // One-shot cover snapshots are unlinked once settled; keep them out of QQuickPixmapCache.
        cache: false
        onStatusChanged: panel.coverFrames = 0
        layer.enabled: root.themeCut && root.themeCutProgress > 0
        layer.smooth: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskInverted: true
          maskSource: cutMask
          maskThresholdMin: 0.5
          maskSpreadAtMin: 0.02
        }
      }

      // The background service's reveal band, opening a hole in the cover.
      Item {
        id: cutMask
        anchors.fill: parent
        visible: false
        layer.enabled: root.themeCut

        readonly property real slant: -0.18
        readonly property real centerTop: width / 2 - slant * height / 2
        readonly property real centerBottom: width / 2 + slant * height / 2
        readonly property real reach: width / 2 + Math.abs(slant) * height / 2 + 4
        readonly property real spread: reach * root.themeCutProgress

        Shape {
          anchors.fill: parent
          antialiasing: true
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            fillColor: "white"
            strokeColor: "transparent"
            startX: cutMask.centerTop - cutMask.spread; startY: 0
            PathLine { x: cutMask.centerTop + cutMask.spread; y: 0 }
            PathLine { x: cutMask.centerBottom + cutMask.spread; y: cutMask.height }
            PathLine { x: cutMask.centerBottom - cutMask.spread; y: cutMask.height }
            PathLine { x: cutMask.centerTop - cutMask.spread; y: 0 }
          }
        }
      }

      // Give the ready image a frame to reach the compositor before OWE
      // releases the shell's wallpaper underneath this cover.
      FrameAnimation {
        running: outgoingFrame.status === Image.Ready && panel.coverFrames < 2
        onTriggered: panel.coverFrames += 1
      }
    }
  }

  Process {
    id: introProc
    command: ["omarchy-theme-bg-boot-intro"]
    onExited: {
      root.startupSettled = true
      root.finishStartup()
    }
  }
}
