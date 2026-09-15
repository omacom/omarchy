import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Ui
import "BackgroundVariants.js" as BackgroundVariants

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
  property var displayedCandidates: []
  signal captureBackground()

  BackgroundVariantCatalog {
    id: variantCatalog
    path: root.currentBackground
    revision: root.backgroundVersion
    onResolved: {
      if (!root.incomingBackground) root.displayedCandidates = candidates
    }
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
    // Capture what each output actually shows, including its selected variant.
    // The theme command's old snapshot contains only the default image.
    captureBackground()
    currentBackground = finalPath
    backgroundVersion += 1
    revealStartedVersion = -1

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
      displayedCandidates = []
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

  function finishTransition() {
    if (!finishingTransition) return
    for (var i = 0; i < backgroundPanels.instances.length; i++) {
      if (!backgroundPanels.instances[i].backgroundReady) return
    }
    incomingBackground = ""
    oldBackground = ""
    finishingTransition = false
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
    duration: 420
    easing.type: Easing.InOutCubic
    onFinished: {
      if (root.incomingBackground) {
        root.displayedReloads += 1
        root.displayedCandidates = variantCatalog.candidates
        root.displayedBackground = root.currentBackground || root.incomingBackground
        root.finishingTransition = true
      }
      root.revealProgress = 1
      Qt.callLater(root.finishTransition)
    }
  }

  Component.onCompleted: refreshBackground()

  Variants {
    id: backgroundPanels
    model: Quickshell.screens
    onInstancesChanged: Qt.callLater(root.finishTransition)

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
      readonly property bool backgroundReady: base.ready
      property var failedVariants: []
      readonly property real pixelScale: modelData.devicePixelRatio
      readonly property string displayedPath: BackgroundVariants.choose(
        root.displayedCandidates.filter(function(candidate) { return panel.failedVariants.indexOf(candidate.path) === -1 }),
        root.displayedBackground, modelData.width, modelData.height, pixelScale)
      readonly property string incomingPath: BackgroundVariants.choose(
        variantCatalog.candidates.filter(function(candidate) { return panel.failedVariants.indexOf(candidate.path) === -1 }),
        root.incomingBackground, modelData.width, modelData.height, pixelScale)

      function rejectVariant(path) {
        if (failedVariants.indexOf(path) === -1) failedVariants = failedVariants.concat([path])
      }

      function maybeStartReveal() {
        if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
        if (variantCatalog.busy) return
        if (incomingFrame.status !== Image.Ready) return
        Qt.callLater(function() {
          if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
          if (variantCatalog.busy) return
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
        path: panel.displayedPath
        reloads: root.displayedReloads
        playbackEnabled: !root.sessionObscured && !root.powerSaverActive && !panel.fullscreenHere
        audioEnabled: panel.firstScreen
        onReadyChanged: {
          if (ready) Qt.callLater(root.finishTransition)
        }
      }

      Connections {
        target: base.current
        ignoreUnknownSignals: true
        function onStatusChanged() {
          if (base.current && base.current.status === Image.Error) panel.rejectVariant(panel.displayedPath)
        }
      }

      ShaderEffectSource {
        id: oldFrame
        anchors.fill: parent
        sourceItem: root.oldBackground !== "" ? base : null
        live: false
        smooth: true
        visible: root.oldBackground !== "" && root.revealProgress < 1
      }

      Item {
        id: incomingLayer
        anchors.fill: parent
        visible: root.incomingBackground !== "" && incomingFrame.status === Image.Ready && (root.revealProgress >= 1 || panel.maskReady)
        layer.enabled: root.incomingBackground !== "" && root.revealProgress < 1
        layer.smooth: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: revealMask
          maskThresholdMin: 0.5
          maskSpreadAtMin: 0.02
        }

        Image {
          id: incomingFrame
          anchors.fill: parent
          source: root.incomingBackground && !variantCatalog.busy ? root.imageUrl(panel.incomingPath) : ""
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: false
          smooth: true
          mipmap: true
          onStatusChanged: {
            if (status === Image.Error) panel.rejectVariant(panel.incomingPath)
            panel.maybeStartReveal()
          }
        }
      }

      Item {
        id: revealMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        readonly property real slant: -0.18
        readonly property real centerTop: width / 2 - slant * height / 2
        readonly property real centerBottom: width / 2 + slant * height / 2
        readonly property real reach: width / 2 + Math.abs(slant) * height / 2 + 4
        readonly property real spread: reach * root.revealProgress

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
        function onCaptureBackground() {
          oldFrame.scheduleUpdate()
          panel.failedVariants = []
        }
        function onIncomingBackgroundChanged() {
          panel.maskReady = false
          panel.maybeStartReveal()
        }
      }

      Connections {
        target: variantCatalog
        function onResolved() { panel.maybeStartReveal() }
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
