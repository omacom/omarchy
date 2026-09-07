import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Ui

Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string currentBackgroundLink: stateHome + "/omarchy/current/background"

  property string currentBackground: ""
  property string displayedBackground: ""
  property int displayedReloads: 0
  property string incomingBackground: ""
  property string oldBackground: ""
  property bool finishingTransition: false
  property int backgroundVersion: 0
  property int revealStartedVersion: -1
  property int pendingThemeVersion: -1
  property string pendingColorsRaw: ""
  property string pendingShellRaw: ""
  property real revealProgress: 1

  readonly property real slant: -0.18

  // The wipe is one front travelling across the whole output layout rather
  // than an independent wipe per output. It starts at the centre of the output
  // the change was made on and continues onto the others according to where
  // Hyprland places them, so a layout with a vertical offset or a gap between
  // outputs is followed rather than ignored. originScreenName is snapshotted
  // when a transition begins, so moving focus mid-wipe cannot drag the origin
  // along with it.
  property string originScreenName: ""

  readonly property var originScreen: screenByName(originScreenName)
  readonly property real originX: originScreen
    ? originScreen.x + originScreen.width / 2
    : layoutCenter(true)
  readonly property real originY: originScreen
    ? originScreen.y + originScreen.height / 2
    : layoutCenter(false)

  // How far the front must travel to clear every output, and how far it would
  // have travelled to clear the origin output alone. Scaling the duration by
  // the ratio keeps the edge moving at the speed it has on a single screen
  // instead of racing across the whole layout in the same 420ms; the cap stops
  // a wide layout from turning the wipe into a crawl.
  readonly property real globalReach: reachOver(Quickshell.screens, originX, originY)
  readonly property real originReach: reachOver(
    originScreen ? [originScreen] : Quickshell.screens, originX, originY)
  readonly property int revealDuration: originReach > 0
    ? Math.min(900, Math.round(420 * (globalReach / originReach)))
    : 420

  function screenByName(name) {
    if (!name) return null
    var list = Quickshell.screens
    for (var i = 0; i < list.length; i++) {
      if (String(list[i].name || "") === name) return list[i]
    }
    return null
  }

  function layoutCenter(horizontal) {
    var list = Quickshell.screens
    if (!list.length) return 0
    var low = horizontal ? list[0].x : list[0].y
    var high = low + (horizontal ? list[0].width : list[0].height)
    for (var i = 1; i < list.length; i++) {
      var start = horizontal ? list[i].x : list[i].y
      low = Math.min(low, start)
      high = Math.max(high, start + (horizontal ? list[i].width : list[i].height))
    }
    return (low + high) / 2
  }

  // Largest horizontal distance from the slanted front line to any corner of
  // the given outputs: how far spread has to grow to cover all of them.
  function reachOver(screens, ox, oy) {
    var furthest = 0
    for (var i = 0; i < screens.length; i++) {
      var s = screens[i]
      var xs = [s.x, s.x + s.width]
      var ys = [s.y, s.y + s.height]
      for (var a = 0; a < 2; a++) {
        for (var b = 0; b < 2; b++) {
          furthest = Math.max(furthest, Math.abs(xs[a] - (ox + slant * (ys[b] - oy))))
        }
      }
    }
    return furthest + 4
  }

  function focusedScreenName() {
    var monitor = Hyprland.focusedMonitor
    return monitor ? String(monitor.name || "") : ""
  }

  // Injected by the first-party service loader; used to reach the lock and idle
  // services so playback can stop whenever nothing can see the wallpaper.
  property var shell: null

  // Stop a video wallpaper's decoding whenever it is covered. Qt's FFmpeg
  // engine drives its own clock, so an unseen player keeps decoding until it
  // is told not to — a locked laptop would otherwise decode until it died.
  readonly property var lockService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.lock") : null
  readonly property var idleService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.idle") : null
  readonly property var batteryService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.battery") : null
  readonly property bool lockActive: lockService ? lockService.locked : false
  readonly property bool screensaverActive: idleService ? idleService.screensaverWindowCount > 0 : false
  readonly property bool powerSaverActive: batteryService ? batteryService.powerSaverOnBattery : false
  // A lock or a screensaver covers every output, so it is decided once here.
  // Fullscreen is decided per output below, because it only covers its own.
  readonly property bool sessionObscured: lockActive || screensaverActive

  function isVideo(path) {
    return Util.isVideoPath(path)
  }

  function imageUrl(path) {
    return Util.fileUrl(path)
  }

  function refreshBackground() {
    if (!readlinkProc.running) readlinkProc.running = true
  }

  function setBackground(path, instant) {
    transitionBackground("", path, path, instant, false)
  }

  function transitionBackground(fromPath, path, finalPath, instant, force) {
    path = String(path || "").trim()
    finalPath = String(finalPath || path).trim()
    fromPath = String(fromPath || "").trim()
    if (!path || (!force && finalPath === currentBackground)) return
    currentBackground = finalPath
    backgroundVersion += 1
    revealStartedVersion = -1
    originScreenName = focusedScreenName()

    revealAnimation.stop()
    finishingTransition = false

    // Video frames are not fed through the image-only reveal stack. Switching
    // instantly also avoids decoding two full videos during a transition.
    if (instant || !displayedBackground || isVideo(path) || isVideo(displayedBackground)) {
      oldBackground = ""
      incomingBackground = ""
      // A theme switch can replace the file behind an unchanged path, which
      // an unchanged property would never pick up.
      if (displayedBackground === finalPath) displayedReloads += 1
      displayedBackground = finalPath
      revealProgress = 1
      return
    }

    oldBackground = fromPath || displayedBackground
    incomingBackground = path
    revealProgress = 0
  }

  function setPendingTheme(colorsB64, shellB64) {
    pendingColorsRaw = Util.decodeBase64(colorsB64)
    pendingShellRaw = Util.decodeBase64(shellB64)
    pendingThemeVersion = backgroundVersion
    pendingThemeFallbackTimer.restart()
  }

  function applyPendingTheme() {
    // Background polling can advance backgroundVersion while a theme switch is
    // pending; the latest theme payload should still apply.
    if (pendingThemeVersion < 0) return
    pendingThemeFallbackTimer.stop()
    Color.loadColors(pendingColorsRaw)
    // Color.loadShell also refreshes Style so the type scale flips with the
    // background reveal instead of waiting for a separate reload path.
    Color.loadShell(pendingShellRaw)
    Style.scheduleRefresh()
    pendingThemeVersion = -1
    pendingColorsRaw = ""
    pendingShellRaw = ""
  }

  function transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64) {
    transitionBackground(fromPath, path, finalPath, false, true)
    setPendingTheme(colorsB64, shellB64)
    if (!incomingBackground || revealProgress >= 1) applyPendingTheme()
  }

  function startReveal(panel) {
    if (!incomingBackground) return
    panel.maskReady = true
    if (revealStartedVersion === backgroundVersion) return
    revealStartedVersion = backgroundVersion
    applyPendingTheme()
    revealAnimation.restart()
  }

  function openSelector() {
    if (!bgSwitchProc.running) bgSwitchProc.running = true
  }

  function openThemeSwitcher() {
    if (!themeSwitchProc.running) themeSwitchProc.running = true
  }

  Process {
    id: bgSwitchProc
    command: ["bash", "-c", "background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set \"$background\""]
    onExited: root.refreshBackground()
  }

  Process {
    id: themeSwitchProc
    command: ["bash", "-c", "theme=$(omarchy-theme-switcher); [[ -n $theme ]] && omarchy-theme-set \"$theme\" >/dev/null 2>&1 &"]
    onExited: root.refreshBackground()
  }

  Process {
    id: readlinkProc
    command: ["readlink", "-f", root.currentBackgroundLink]
    stdout: StdioCollector {
      onStreamFinished: root.setBackground(String(text || "").trim(), false)
    }
  }

  IpcHandler {
    target: "background"

    function refresh(): void {
      root.refreshBackground()
    }

    function set(path: string): void {
      root.setBackground(path, false)
    }

    function setInstant(path: string): void {
      root.setBackground(path, true)
    }

    function transition(fromPath: string, path: string): void {
      root.transitionBackground(fromPath, path, path, false, false)
    }

    function themeTransition(fromPath: string, path: string, finalPath: string, colorsB64: string, shellB64: string): void {
      root.transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64)
    }
  }

  Timer {
    id: pendingThemeFallbackTimer
    interval: 300
    repeat: false
    onTriggered: root.applyPendingTheme()
  }

  NumberAnimation {
    id: revealAnimation
    target: root
    property: "revealProgress"
    from: 0
    to: 1
    duration: root.revealDuration
    easing.type: Easing.InOutCubic
    onFinished: {
      if (root.incomingBackground) {
        root.displayedBackground = root.currentBackground || root.incomingBackground
        root.finishingTransition = true
      }
      root.revealProgress = 1
    }
  }

  Component.onCompleted: refreshBackground()

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      visible: !remapGuard.remapping
      anchors { top: true; bottom: true; left: true; right: true }

      ScreenMoveRemap {
        id: remapGuard
        window: panel
      }
      color: "transparent"
      // Keep render updates enabled. The background layer has been observed to
      // lose its committed buffer while parked with updatesEnabled=false,
      // leaving a black desktop until omarchy-shell is restarted. A still
      // wallpaper costs nothing to keep enabled, and a video one is throttled
      // by pausing playback rather than by parking the layer.
      updatesEnabled: true

      // Pausing every wallpaper for one fullscreen window would freeze the one
      // still on show next to it, which costs a viewer more than it saves. The
      // workspace on show here knows whether a fullscreen window covers it,
      // wherever focus happens to be.
      readonly property var hyprlandMonitor: Hyprland.monitorFor(modelData)
      readonly property var visibleWorkspace: hyprlandMonitor ? hyprlandMonitor.activeWorkspace : null
      readonly property bool fullscreenHere: visibleWorkspace ? visibleWorkspace.hasFullscreen : false

      // A sound track plays from one output only, or every monitor would
      // layer its own copy of it.
      readonly property bool firstScreen: Quickshell.screens.length > 0
        && String(Quickshell.screens[0].name || "") === String(modelData.name || "")

      property bool maskReady: false

      // Every output that has decoded the incoming image joins the wipe, even
      // one that gets there after the animation has started. Each output
      // decodes its own copy, so requiring revealProgress to still be 0 let
      // whichever output decoded first claim the reveal and locked the rest
      // out of it: they kept the old wallpaper and jumped to the new one when
      // the transition ended. startReveal still restarts the animation only
      // once per backgroundVersion, so a late output picks up the front where
      // it already is.
      function maybeStartReveal() {
        if (!root.incomingBackground || maskReady) return
        if (incomingFrame.status !== Image.Ready) return
        Qt.callLater(function() {
          if (!root.incomingBackground || maskReady) return
          if (incomingFrame.status !== Image.Ready) return
          root.startReveal(panel)
        })
      }

      WlrLayershell.namespace: "omarchy-background"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      BackgroundMedia {
        id: base
        anchors.fill: parent
        path: root.displayedBackground
        reloads: root.displayedReloads
        playbackEnabled: !root.sessionObscured && !root.powerSaverActive && !panel.fullscreenHere
        audioEnabled: panel.firstScreen
        onReadyChanged: {
          if (ready && root.finishingTransition) {
            root.incomingBackground = ""
            root.oldBackground = ""
            root.finishingTransition = false
          }
        }
      }

      Image {
        id: oldFrame
        anchors.fill: parent
        source: root.imageUrl(root.oldBackground)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
        visible: root.oldBackground !== "" && root.revealProgress < 1
        onStatusChanged: panel.maybeStartReveal()
      }

      Item {
        id: incomingLayer
        anchors.fill: parent
        visible: root.incomingBackground !== "" && incomingFrame.status === Image.Ready && (root.revealProgress >= 1 || panel.maskReady)
        layer.enabled: root.incomingBackground !== "" && root.revealProgress < 1
        layer.smooth: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: revealMaskSource
          maskThresholdMin: 0.5
          maskSpreadAtMin: 0.02
        }

        Image {
          id: incomingFrame
          anchors.fill: parent
          source: root.imageUrl(root.incomingBackground)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: false
          smooth: true
          mipmap: true
          onStatusChanged: panel.maybeStartReveal()
        }
      }

      // The mask has to stay in the render tree for the wipe to animate. An
      // item kept out of it with visible: false can change its geometry
      // without dirtying the window, so an output whose scene is otherwise
      // static never schedules a frame: it held the old wallpaper for the
      // whole transition and jumped when the reveal ended. hideSource keeps
      // the mask off the screen while leaving it live, and the effect samples
      // it from here instead of from the item's own layer.
      ShaderEffectSource {
        id: revealMaskSource
        anchors.fill: parent
        sourceItem: revealMask
        live: true
        hideSource: true
        visible: false
      }

      Item {
        id: revealMask
        anchors.fill: parent

        // Local coordinates of the global front. The front at global y sits at
        // originX + slant * (y - originY); dx and originDy carry this panel's
        // offset within the layout, so an output away from the origin sees only
        // the leading edge sweep in, at the y offset its position implies. For
        // the origin output this reduces to the single-screen centre-out wipe.
        readonly property real slant: root.slant
        readonly property real dx: root.originX - (panel.screen ? panel.screen.x : 0)
        readonly property real originDy: (panel.screen ? panel.screen.y : 0) - root.originY
        readonly property real centerTop: dx + slant * originDy
        readonly property real centerBottom: dx + slant * (originDy + height)
        readonly property real spread: root.globalReach * root.revealProgress

        Shape {
          anchors.fill: parent
          antialiasing: true
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            fillColor: "white"
            strokeColor: "transparent"
            startX: revealMask.centerTop - revealMask.spread; startY: 0
            PathLine { x: revealMask.centerTop + revealMask.spread; y: 0 }
            PathLine { x: revealMask.centerBottom + revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerBottom - revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerTop - revealMask.spread; y: 0 }
          }
        }
      }

      Connections {
        target: root
        function onIncomingBackgroundChanged() {
          panel.maskReady = false
          panel.maybeStartReveal()
        }
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onDoubleClicked: function(mouse) {
          if (mouse.button === Qt.RightButton) root.openThemeSwitcher()
          else root.openSelector()
          mouse.accepted = true
        }
      }
    }
  }
}
