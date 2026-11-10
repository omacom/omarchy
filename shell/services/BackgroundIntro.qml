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
  readonly property bool shellReady: !host || (!host.pluginReloading && (!host.pluginRegistry || !host.pluginRegistry.scanning))
  readonly property bool barReady: !host || ((!("bar" in host) || !!host.bar) && host.pluginWidgetsLoaded !== false)
  // A bar that can fade itself in does so once its widgets are built, so the
  // desktop reveals without it; any other bar is waited for.
  readonly property bool barFadesItself: !!host && !!host.bar && ("startupRevealed" in host.bar) && ("startupRevealDuration" in host.bar)
  readonly property bool desktopReady: shellReady && (barReady || barFadesItself)
  // The bar shows only once the desktop has started fading in. Built by then,
  // it is uncovered with the desktop; built later, it fades in on its own.
  property bool barRevealed: sessionConsumed
  property int barRevealDuration: 0
  property int barReadyFrames: 0
  property bool barSettled: false
  // Startup work that would compete with the bar for the GUI thread waits for this.
  readonly property bool startupSettling: startupPending || !barRevealed
  // From OWE taking the background until the desktop has faded in, a widget
  // built on the GUI thread would hold up the reveal or stall its fade.
  readonly property bool holdingWidgetBuilds: startupFading || (startupPending && !!backgroundService && !backgroundActive)
  // The launcher reports the intro's first frame on screen, so the login
  // reveals on it rather than polling OWE for it.
  property bool introReported: false
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
  readonly property bool revealing: revealDelayFrames > 0 || themeFade.running || themeCutReveal.running || startupFading
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
    if (!startupPending || startupFading || !startupMediaReady || !desktopReady) return
    if (!startupCovers.instances.length) return
    for (var panel of startupCovers.instances)
      if (panel.readyFrames < 2) return
    startStartupFade()
  }

  // The two frames the reveal waits for are counted from the desktop last
  // becoming ready, so a reload that briefly reads ready reveals nothing.
  onDesktopReadyChanged: {
    for (var panel of startupCovers.instances) panel.readyFrames = 0
    revealStartup()
  }
  onBarReadyChanged: {
    barReadyFrames = 0
    barSettled = false
    barSettle.stop()
    barSettleLimit.stop()
  }

  function revealBar(duration) {
    if (barRevealed) return
    barRevealDuration = duration
    barRevealed = true
  }

  // Built widgets still fill in, as an update check or the weather returns,
  // so the bar shows once its layout has held still a moment, or a second on.
  function settleBar() {
    barSettle.stop()
    barSettleLimit.stop()
    barSettled = true
    if (startupFading || !startupPending) revealBar(barFadeDuration)
  }

  FrameAnimation {
    running: !root.barRevealed && root.barReady && root.barReadyFrames < 2
    onTriggered: {
      root.barReadyFrames += 1
      if (root.barReadyFrames < 2) return
      barSettle.restart()
      barSettleLimit.restart()
    }
  }

  Timer {
    id: barSettle
    interval: 200
    onTriggered: root.settleBar()
  }

  Timer {
    id: barSettleLimit
    interval: 1000
    onTriggered: root.settleBar()
  }

  Connections {
    target: root.host && root.host.bar && ("layoutRevision" in root.host.bar) ? root.host.bar : null
    function onLayoutRevisionChanged() {
      if (root.barRevealed || root.barReadyFrames < 2) return
      // A bar that changes after settling, while the login still waits, settles again.
      if (root.barSettled) {
        root.barSettled = false
        barSettleLimit.restart()
      }
      barSettle.restart()
    }
  }

  // A bar whose widgets never all build still shows, as the desktop does.
  Timer {
    interval: 10000
    running: !root.barRevealed && (root.startupFading || !root.startupPending)
    onTriggered: root.revealBar(root.barFadeDuration)
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

  // Each screen's cover fades on the render thread, where the shell still
  // loading plugins cannot stall it, and the login is over once every one
  // has, or a second after they all should have. The desktop fades in from
  // the black the boot splash faded out to, eased at both ends as that was.
  property bool startupFading: false
  readonly property int startupFadeDuration: Style.duration(500)
  // An entrance, as the motion guide times one.
  readonly property int barFadeDuration: Style.duration(250)

  function startStartupFade() {
    if (startupFading) return
    startupFading = true
    // Under the still opaque cover a settled bar needs no fade of its own.
    if (barSettled) revealBar(0)
    if (introReported) introPlay.running = true
    startupFadeDeadline.restart()
    finishStartupFade()
  }

  function finishStartupFade() {
    if (!startupFading) return
    for (var panel of startupCovers.instances)
      if (!panel.faded && startupFadeDeadline.running && startupFadeDuration > 0) return
    startupFadeDeadline.stop()
    startupFading = false
    startupPending = false
  }

  Timer {
    id: startupFadeDeadline
    interval: root.startupFadeDuration + 1000
    onTriggered: root.finishStartupFade()
  }

  // The launcher's intro holds its first frame until the reveal starts.
  Process {
    id: introPlay
    command: ["owe", "intro-play"]
  }

  // A missing wallpaper or failed plugin must not leave applications hidden.
  Timer {
    interval: 10000
    running: root.startupPending
    onTriggered: {
      root.cover = false
      if (!root.themeToken) root.themeBackground = ""
      root.startupMediaReady = true
      root.startStartupFade()
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
    interval: 16
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
    onStarted: token = root.themeToken
    stdout: StdioCollector { id: frameStatusOut }
    onExited: function(exitCode) {
      if (exitCode !== 0 || token !== root.themeToken || (!token && !root.cover)) return
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
      if (introReported && !themeToken) shownFallback.restart()
      else if (cover || themeToken) {
        framePoll.start()
        if (!frameStatus.running) frameStatus.running = true
      }
    }
  }

  // The launcher's word can arrive after OWE has already taken the background.
  onIntroReportedChanged: {
    if (!introReported || backgroundActive || !checked || themeToken) return
    framePoll.stop()
    shownFallback.restart()
  }

  // OWE answers well within this once it has taken the background; an OWE
  // that never reports the first frame is polled for it as before.
  Timer {
    id: shownFallback
    interval: 1500
    onTriggered: {
      if (!root.cover || root.themeToken) return
      framePoll.start()
      if (!frameStatus.running) frameStatus.running = true
    }
  }

  // Cover the bar as well as the wallpaper on a new login. Shell restarts
  // retain the current desktop and never map this startup cover.
  Variants {
    id: startupCovers
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      property int readyFrames: 0
      property bool faded: false
      screen: modelData
      visible: root.startupPending
      color: "transparent"
      mask: Region {}
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"

      Rectangle {
        id: startupShade
        anchors.fill: parent
        color: "black"

        OpacityAnimator {
          target: startupShade
          running: root.startupFading
          from: 1
          to: 0
          duration: root.startupFadeDuration
          easing.type: Easing.InOutQuad
          onFinished: {
            faded = true
            root.finishStartupFade()
          }
        }
      }

      FrameAnimation {
        running: root.startupPending && root.desktopReady && readyFrames < 2
        onTriggered: {
          readyFrames += 1
          if (readyFrames === 2) root.revealStartup()
        }
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
    stdout: SplitParser {
      onRead: function(line) {
        if (line === "intro") root.introReported = true
        else if (line === "shown" && root.cover && !root.themeToken) root.revealTheme()
      }
    }
    onExited: {
      root.startupSettled = true
      root.finishStartup()
    }
  }
}
