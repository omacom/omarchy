import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "BootSplash.js" as BootSplash

// Keep startup and theme covers alive across background service handoffs.
Item {
  id: root

  property var host: null
  property bool cover: true
  readonly property bool sessionConsumed: String(sessionMarker.text() || "").trim() === (Quickshell.env("OMARCHY_SESSION_ID") || Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
  property bool startupSettled: sessionConsumed
  property bool startupPending: !sessionConsumed
  property bool startupMediaReady: false
  property real startupOpacity: startupPending ? 1 : 0
  readonly property bool desktopReady: !host || (!host.pluginReloading && (!host.pluginRegistry || !host.pluginRegistry.scanning) && (!("bar" in host) || !!host.bar))
  property bool checked: false
  property string themeToken: ""
  property string transitionToken: ""
  readonly property string startupBackgroundPath: Quickshell.env("OMARCHY_STARTUP_BACKGROUND")
  // Set by the compositor while Omarchy's Plymouth theme is active: the cover
  // then continues the boot splash instead of starting from black.
  readonly property string splashBackground: Quickshell.env("OMARCHY_SPLASH_BACKGROUND") || ""
  readonly property string splashTheme: "/usr/share/plymouth/themes/omarchy/"
  // The splash's progress bar, carried on from where Plymouth's would be now
  // and filled before the cover lifts. Whether Plymouth showed one is known once
  // the helper answers, and the logo waits for that to arrive with the bar.
  property bool splashKnown: false
  property bool splashBar: false
  property bool splashBarFilling: false
  property bool splashBarFull: false
  property real splashBarStart: 0
  property bool splashBarWaited: false
  readonly property int splashBarFillDuration: Style.duration(350)
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
  readonly property bool revealing: revealDelayFrames > 0 || themeFade.running || themeCutReveal.running || startupFade.running
  // The outgoing frame reached, or failed to reach, the screen.
  signal coverPresented()
  readonly property var backgroundService: host && host.services ? host.firstPartyServiceFor("omarchy.background") : null
  readonly property bool backgroundActive: !!backgroundService && !backgroundService.suspended
  readonly property bool backgroundReady: backgroundActive && backgroundService.ready !== false

  function restoreStartupCursor() {
    Quickshell.execDetached(["hyprctl", "eval", "if omarchy_startup_cursor_restore then omarchy_startup_cursor_restore() end"])
  }

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
    if (!startupPending || startupFade.running || !startupMediaReady || !desktopReady) return
    if (!startupCovers.instances.length) return
    for (var panel of startupCovers.instances)
      if (panel.readyFrames < 2) return
    if (splashBackground && !splashKnown) return
    // A bar the helper just reported is drawn on the next frame; fill it then.
    if (splashBar && !splashBarShown() && !splashBarWaited) {
      splashBarWait.start()
      return
    }
    liftStartupCover()
  }

  // The splash's bar reaches full before the cover lifts, as a finished boot.
  function liftStartupCover() {
    if (startupFade.running || splashBarFilling) return
    if (splashBarShown()) {
      splashBarFilling = true
      splashBarFillDeadline.start()
    } else {
      startupFade.start()
    }
  }

  function splashBarShown() {
    for (var panel of startupCovers.instances)
      if (panel.splashBarShown) return true
    return false
  }

  // The first cover whose bar is full lifts them all.
  function finishSplashBar() {
    if (!splashBarFilling || splashBarFull) return
    splashBarFull = true
    splashBarFillDeadline.stop()
    startupFade.start()
  }

  onSplashKnownChanged: revealStartup()

  function splashBarElapsed() {
    return (Date.now() - splashBarStart) / 1000
  }

  onDesktopReadyChanged: revealStartup()
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

  Timer {
    id: splashBarWait
    interval: 500
    onTriggered: {
      root.splashBarWaited = true
      root.revealStartup()
    }
  }

  // A cover that never gets to draw its fill must not hold the desktop.
  Timer {
    id: splashBarFillDeadline
    interval: root.splashBarFillDuration + 1500
    onTriggered: root.finishSplashBar()
  }

  Process {
    id: splashProgress
    command: ["omarchy-boot-splash-progress"]
    stdout: StdioCollector { id: splashProgressOut }
    onExited: function(exitCode) {
      var start = parseFloat(splashProgressOut.text)
      if (exitCode === 0 && isFinite(start) && root.startupPending && !root.splashKnown && !startupFade.running) {
        root.splashBarStart = start
        root.splashBar = true
      }
      root.splashKnown = true
    }
  }

  // A helper stuck behind a busy systemd costs the bar, never the logo.
  Timer {
    interval: 500
    running: root.startupPending && root.splashBackground !== "" && !root.splashKnown
    onTriggered: root.splashKnown = true
  }

  NumberAnimation {
    id: startupFade
    target: root
    property: "startupOpacity"
    to: 0
    duration: Style.duration(420)
    easing.type: Easing.OutCubic
    onStarted: root.restoreStartupCursor()
    onFinished: root.startupPending = false
  }

  // A missing wallpaper or failed plugin must not leave applications hidden.
  Timer {
    interval: 10000
    running: root.startupPending
    onTriggered: {
      root.cover = false
      if (!root.themeToken) root.themeBackground = ""
      root.startupMediaReady = true
      root.liftStartupCover()
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
    if (sessionConsumed) restoreStartupCursor()
    if (!startupBackgroundPath && !startupPending) startupBackground.running = true
    if (startupPending && splashBackground) {
      Hyprland.refreshMonitors()
      splashProgress.running = true
    }
    introProc.running = true
  }

  Component.onDestruction: if (startupPending) restoreStartupCursor()

  onBackgroundActiveChanged: {
    if (!backgroundActive && checked) {
      if (cover || themeToken) {
        framePoll.start()
        if (!frameStatus.running) frameStatus.running = true
      }
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
      readonly property bool splashBarShown: splash.barStarted
      onSplashBarShownChanged: root.revealStartup()
      screen: modelData
      visible: root.startupPending
      color: "transparent"
      mask: Region {}
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"

      Item {
        anchors.fill: parent
        opacity: root.startupOpacity

        Rectangle {
          anchors.fill: parent
          color: root.splashBackground || "black"
        }

        // Plymouth's layout(): the logo centred, and the bar centred on where
        // the password field sat, 40 px below it, all at Plymouth's own scale.
        Item {
          id: splash
          readonly property var monitor: Hyprland.monitorFor(modelData)
          readonly property real unit: BootSplash.pixelUnit(monitor ? monitor.lastIpcObject : null)
          readonly property real barTop: height / 2 + unit * (logo.implicitHeight / 2 + 40 + entry.implicitHeight / 2 - progressBox.implicitHeight / 2)
          readonly property bool barLoaded: root.splashBar && entry.status === Image.Ready && progressBox.status === Image.Ready && progressBar.status === Image.Ready
          // "run" or "fill", started on the next frame's tick: an animation
          // started while the shell is busy would begin from a stale value.
          property string barStart: ""
          property bool barStarted: false
          anchors.fill: parent
          visible: root.splashBackground !== "" && root.splashKnown && unit > 0

          Image {
            id: logo
            visible: !splash.barLoaded || splash.barStarted
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            source: root.splashBackground ? Util.fileUrl(root.splashTheme + "logo.png") : ""
            width: implicitWidth * splash.unit
            height: implicitHeight * splash.unit
            smooth: true
            cache: false
          }

          // Only its height places the bar.
          Image {
            id: entry
            visible: false
            source: root.splashBar ? Util.fileUrl(root.splashTheme + "entry.png") : ""
            cache: false
          }

          Image {
            id: progressBox
            visible: splash.barStarted
            x: (parent.width - width) / 2
            y: splash.barTop
            source: root.splashBar ? Util.fileUrl(root.splashTheme + "progress_box.png") : ""
            width: implicitWidth * splash.unit
            height: implicitHeight * splash.unit
            smooth: true
            cache: false
          }

          // Plymouth squeezes the bar image into the filled width. The image is
          // one colour, so sliding it out of a clip draws the same, and lets the
          // render thread move it while the shell is busy starting up.
          Item {
            visible: splash.barStarted
            x: (parent.width - progressBar.width) / 2
            y: splash.barTop + splash.unit * (progressBox.implicitHeight - progressBar.implicitHeight) / 2
            width: progressBar.width
            height: progressBar.height
            clip: true

            Image {
              id: progressBar
              source: root.splashBar ? Util.fileUrl(root.splashTheme + "progress_bar.png") : ""
              width: implicitWidth * splash.unit
              height: implicitHeight * splash.unit
              smooth: true
              cache: false
            }
          }

          function barOffset(progress) {
            return (progress - 1) * progressBar.width
          }

          function queueBar() {
            if (splash.visible && barLoaded && progressBar.width > 0) barStart = root.splashBarFilling ? "fill" : "run"
          }

          // Plymouth's ease-out from the password onwards. What remains of a
          // quadratic ease-out is itself one, so the bar picks it up mid-way.
          function runBar() {
            var elapsed = root.splashBarElapsed()
            barFill.stop()
            barRun.stop()
            barRun.from = barOffset(BootSplash.progressAt(elapsed))
            barRun.to = barOffset(BootSplash.progressLimit)
            // With animations off the bar holds where Plymouth's stood.
            barRun.to = Style.reduceMotion ? barRun.from : barRun.to
            barRun.duration = Style.reduceMotion ? 0 : Math.max(0, (BootSplash.progressDuration - elapsed) * 1000)
            progressBar.x = barRun.from
            barRun.start()
          }

          function fillBar() {
            barRun.stop()
            barFill.stop()
            barFill.from = barOffset(BootSplash.progressAt(root.splashBarElapsed()))
            progressBar.x = barFill.from
            barFill.start()
          }

          XAnimator {
            id: barRun
            target: progressBar
            easing.type: Easing.OutQuad
          }

          XAnimator {
            id: barFill
            target: progressBar
            to: 0
            duration: root.splashBarFillDuration
            easing.type: Easing.OutCubic
            onFinished: root.finishSplashBar()
          }

          FrameAnimation {
            running: splash.barStart !== ""
            onTriggered: {
              var start = splash.barStart
              splash.barStart = ""
              if (start === "fill") splash.fillBar()
              else splash.runBar()
              splash.barStarted = true
            }
          }

          // A busy or software-rendered shell draws its frames late, and the
          // render thread then steps the bar behind the clock.
          Timer {
            interval: 1000
            repeat: true
            running: splash.barStarted && !root.splashBarFilling && !Style.reduceMotion
            onTriggered: splash.queueBar()
          }

          onVisibleChanged: queueBar()
          onBarLoadedChanged: queueBar()
          Connections {
            target: root
            function onSplashBarFillingChanged() { splash.queueBar() }
          }
          Connections {
            target: progressBar
            function onWidthChanged() { splash.queueBar() }
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
    onExited: {
      root.startupSettled = true
      root.finishStartup()
    }
  }
}
