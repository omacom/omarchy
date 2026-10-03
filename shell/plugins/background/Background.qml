import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string currentBackgroundLink: stateHome + "/omarchy/current/background"

  property string currentBackground: ""
  property string displayedBackground: ""
  property string incomingBackground: ""
  property string oldBackground: ""
  // A theme switch names its next background before it has staged the rest of
  // the theme, so the incoming frame can decode while that work runs. A large
  // WebP takes ~130ms to decode at any sourceSize, which the reveal would
  // otherwise wait out after the transition arrives.
  property string preparedBackground: ""
  // The prepare and transition calls travel as separate IPC clients, so a
  // prepare can land after its transition. The path it names then must not be
  // decoded again.
  property string lastTransitionPath: ""
  // Native pixel size per wallpaper path, read from the file header before
  // the image loads. Decoding at screen size only saves memory for wallpapers
  // at least as large as the screen: with PreserveAspectCrop Qt scales the
  // decode up to cover sourceSize, so a smaller wallpaper would cost the
  // screen's worth of pixels instead of its own.
  property var nativeSizes: ({})
  property var sizeQueue: []
  property bool finishingTransition: false
  property int backgroundVersion: 0
  // Bumps whenever displayedBackground is assigned, even to an identical
  // string: a forced theme transition can re-render the same canonical path
  // in place (new SVG raster, new mtime), so the displayed resolvers must
  // re-resolve on assignment, not only on string change.
  property int displayedVersion: 0
  property int revealStartedVersion: -1
  property int pendingThemeVersion: -1
  property string pendingColorsRaw: ""
  property string pendingShellRaw: ""
  property real revealProgress: 1

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
    if (path !== preparedBackground) preparedBackground = ""
    preparedBackgroundTimer.stop()
    lastTransitionPath = path
    // The incoming frame gates the reveal, so its size is read first.
    requestNativeSize(path)
    requestNativeSize(fromPath || displayedBackground)
    requestNativeSize(finalPath)
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
      preparedBackground = ""
      displayedBackground = finalPath
      displayedVersion += 1
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

  function maybeFinishTransition() {
    // Multi-monitor resolves and decodes land with real skew (a large panel's
    // cold SVG raster can trail a small one by hundreds of ms), so the shared
    // incoming/old sources are only cleared once EVERY panel's base layer has
    // settled on the final background — clearing on the first ready panel
    // would yank the slower panels back to the old wallpaper.
    if (!finishingTransition) return
    const panels = panelVariants.instances
    for (let i = 0; i < panels.length; i++) {
      if (!panels[i].baseSettled()) return
    }
    incomingBackground = ""
    oldBackground = ""
    preparedBackground = ""
    finishingTransition = false
    pruneNativeSizes()
  }

  function prepareBackground(path) {
    path = String(path || "").trim()
    // Only a still that is not already on screen is worth decoding ahead.
    if (!path || isVideo(path) || path === lastTransitionPath || path === displayedBackground) return
    requestNativeSize(path)
    preparedBackground = path
    preparedBackgroundTimer.restart()
  }

  function requestNativeSize(path) {
    if (!path || isVideo(path) || nativeSizes[path] !== undefined || sizeQueue.indexOf(path) !== -1) return
    sizeQueue = sizeQueue.concat([path])
    probeNextSize()
  }

  function probeNextSize() {
    if (sizeProbe.running || sizeQueue.length === 0) return
    sizeProbe.path = sizeQueue[0]
    sizeProbe.command = ["magick", "identify", "-ping", "-format", "%w %h", sizeProbe.path]
    sizeProbe.running = true
  }

  // Each theme switch names fresh snapshot paths, so keep only the sizes of
  // the wallpapers still in play.
  function pruneNativeSizes() {
    var kept = {}
    var paths = [displayedBackground, incomingBackground, oldBackground, preparedBackground]
    for (var i = 0; i < paths.length; i++) {
      if (paths[i] && nativeSizes[paths[i]] !== undefined) kept[paths[i]] = nativeSizes[paths[i]]
    }
    const panels = panelVariants.instances
    for (let i = 0; i < panels.length; i++) {
      for (const path of [panels[i].lastDisplayedPath, panels[i].incomingPath]) {
        if (path && nativeSizes[path] !== undefined) kept[path] = nativeSizes[path]
      }
    }
    nativeSizes = kept
  }

  function openSelector() {
    if (!bgSwitchProc.running) bgSwitchProc.running = true
  }

  function openThemeSwitcher() {
    var payload = JSON.stringify({ source: "themes" })

    // A cloned background may not summon the picker in-process, so it takes
    // the IPC route instead.
    if (!root.shell || !root.shell.summon("omarchy.image-picker", payload))
      Util.execArgv(["omarchy-shell", "shell", "summon", "omarchy.image-picker", payload])
  }

  Process {
    id: bgSwitchProc
    command: ["bash", "-c", "background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set \"$background\""]
    onExited: root.refreshBackground()
  }

  Process {
    id: sizeProbe
    property string path: ""
    stdout: StdioCollector { id: sizeProbeOut }
    onExited: function(exitCode) {
      var parts = String(sizeProbeOut.text || "").trim().split(/\s+/)
      var width = exitCode === 0 ? parseInt(parts[0], 10) : 0
      var height = exitCode === 0 ? parseInt(parts[1], 10) : 0
      var known = Object.assign({}, root.nativeSizes)
      // An unreadable header records 0x0, which decodes at screen size.
      known[path] = { width: width > 0 ? width : 0, height: height > 0 ? height : 0 }
      root.nativeSizes = known
      root.sizeQueue = root.sizeQueue.filter(function(queued) { return queued !== sizeProbe.path })
      root.probeNextSize()
    }
  }

  Process {
    id: readlinkProc
    command: ["readlink", "-f", root.currentBackgroundLink]
    stdout: StdioCollector {
      onStreamFinished: root.setBackground(String(text || "").trim(), false)
    }
  }

  ShellIpc {
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

    function prepare(path: string): void {
      root.prepareBackground(path)
    }
  }

  // A prepared frame that no transition claims, say from a theme switch that
  // failed after naming it, must not hold its decoded texture indefinitely.
  Timer {
    id: preparedBackgroundTimer
    interval: 5000
    repeat: false
    onTriggered: root.preparedBackground = ""
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
    duration: Style.duration(420)
    easing.type: Easing.InOutCubic
    onFinished: {
      if (root.incomingBackground) {
        const finalPath = root.currentBackground || root.incomingBackground
        root.displayedBackground = finalPath
        root.displayedVersion += 1
        root.finishingTransition = true
      }
      root.revealProgress = 1
      root.maybeFinishTransition()
    }
  }

  Component.onCompleted: refreshBackground()

  Variants {
    id: panelVariants
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
      // wallpaper costs nothing to keep enabled. OWE manages video layers.
      updatesEnabled: true

      readonly property bool sized: width > 0 && height > 0
      readonly property int decodeWidth: sized ? Math.ceil(width * screen.devicePixelRatio) : 0
      readonly property int decodeHeight: sized ? Math.ceil(height * screen.devicePixelRatio) : 0

      function decodeSize(path) {
        if (!sized || !path) return Qt.size(0, 0)
        var native = root.nativeSizes[path]
        if (native === undefined) return Qt.size(0, 0)
        if (native.width > 0 && (native.width < decodeWidth || native.height < decodeHeight)) return Qt.size(native.width, native.height)
        return Qt.size(decodeWidth, decodeHeight)
      }

      property bool maskReady: false

      // Last successful displayed resolution for this panel. It drives the
      // base layer throughout the outgoing reveal and supplies fallback meta
      // for an incoming snapshot whose directory carries no metadata.
      property string lastDisplayedCanonical: ""
      property string lastDisplayedPath: ""
      property int lastDisplayedVersion: 0
      property string lastDisplayedFill: "crop"
      property string lastDisplayedBackdrop: "solid"
      property color lastDisplayedFillColor: Color.background
      property real lastDisplayedFocalX: 0.5
      property real lastDisplayedFocalY: 0.5

      // Commit incoming pixels with their own metadata once per transition.
      // Keep the outgoing layer while resolving instead of revealing a new
      // image using the previous wallpaper's fill and focal settings.
      property int incomingLockedVersion: -1
      property string incomingPath: ""
      property string incomingFill: "crop"
      property string incomingBackdrop: "solid"
      property color incomingFillColor: Color.background
      property real incomingFocalX: 0.5
      property real incomingFocalY: 0.5

      function lockIncoming(path, fillMode, backdropMode, tint, fx, fy) {
        if (incomingLockedVersion === root.backgroundVersion) return
        incomingLockedVersion = root.backgroundVersion
        root.requestNativeSize(path)
        incomingPath = path
        incomingFill = fillMode
        incomingBackdrop = backdropMode
        incomingFillColor = tint
        incomingFocalX = fx
        incomingFocalY = fy
        maybeStartReveal()
      }

      // True once this panel's base layer is painting the final background:
      // its resolver has published for the current displayed canonical and
      // the decode is no longer in flight.
      function baseSettled() {
        if (root.displayedBackground === "") return true
        if (!displayedResolver.ready || lastDisplayedCanonical !== root.displayedBackground) return false
        return base.status === Image.Ready || base.status === Image.Error
      }

      function maybeStartReveal() {
        // Join tolerance: a panel whose incoming frame becomes ready after
        // the reveal's first tick still raises its mask at the current
        // spread instead of staying hidden for the rest of the animation.
        if (!root.incomingBackground || root.revealProgress >= 1 || maskReady) return
        if (panel.incomingLockedVersion !== root.backgroundVersion || incomingFrame.status !== Image.Ready) return
        Qt.callLater(function() {
          if (!root.incomingBackground || root.revealProgress >= 1 || maskReady) return
          if (panel.incomingLockedVersion !== root.backgroundVersion || incomingFrame.status !== Image.Ready) return
          root.startReveal(panel)
        })
      }

      WlrLayershell.namespace: "omarchy-background"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      BackgroundResolver {
        id: displayedResolver
        canonicalPath: root.displayedBackground
        screenWidth: panel.modelData.width
        screenHeight: panel.modelData.height
        refreshToken: root.displayedVersion
        onResolveVersionChanged: {
          if (ready && resolvedPath !== "") {
            root.requestNativeSize(resolvedPath)
            panel.lastDisplayedCanonical = canonicalPath
            panel.lastDisplayedPath = resolvedPath
            panel.lastDisplayedVersion = root.displayedVersion
            panel.lastDisplayedFill = fill
            panel.lastDisplayedBackdrop = backdrop
            panel.lastDisplayedFillColor = fillColor
            panel.lastDisplayedFocalX = focalX
            panel.lastDisplayedFocalY = focalY
          }
          root.maybeFinishTransition()
        }
      }

      // A theme switch hands transitionBackground a snapshot copy for pixels
      // while root.currentBackground already holds the real post-swap
      // canonical, whose directory carries the variants and metadata — so the
      // incoming layer resolves against the final path and only falls back to
      // the snapshot when that resolve fails or has not landed yet.
      BackgroundResolver {
        id: incomingResolver
        canonicalPath: root.currentBackground !== "" ? root.currentBackground : root.incomingBackground
        screenWidth: panel.modelData.width
        screenHeight: panel.modelData.height
        // A forced theme transition can keep the canonical string identical
        // while re-rendering its content in place; keying on the version
        // guarantees a fresh resolve for every transition.
        refreshToken: root.backgroundVersion
        onResolveVersionChanged: {
          if (!ready || root.incomingBackground === "") return
          panel.lockIncoming(usedFallback || resolvedPath === canonicalPath ? root.incomingBackground : resolvedPath, fill, backdrop, fillColor, focalX, focalY)
        }
      }

      // Keep the already-decoded per-screen pixels beneath the reveal. The
      // canonical snapshot can differ from this variant, and the old theme
      // directory may already have been replaced. Only advance the base once
      // the reveal finishes; no outgoing source needs to be decoded again.
      BackgroundMedia {
        id: base
        anchors.fill: parent
        path: panel.lastDisplayedPath
        version: panel.lastDisplayedVersion
        fill: panel.lastDisplayedFill
        backdrop: panel.lastDisplayedBackdrop
        fillColor: panel.lastDisplayedFillColor
        focalX: panel.lastDisplayedFocalX
        focalY: panel.lastDisplayedFocalY
        cached: true
        constrainDecode: true
        decodeSize: panel.decodeSize(panel.lastDisplayedPath)
        onStatusChanged: root.maybeFinishTransition()
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

        WallpaperImage {
          id: incomingFrame
          anchors.fill: parent
          // Lock the resolved pixels and metadata for the whole reveal.
          // Canonical raster snapshots retain the predecoded preparation;
          // variants and SVG rasters come from the per-screen resolver.
          readonly property string framePath: panel.incomingPath || root.preparedBackground
          path: framePath
          useSourceSizeCap: true
          constrainDecode: true
          decodeSize: panel.decodeSize(framePath)
          fill: panel.incomingFill
          backdrop: panel.incomingBackdrop
          fillColor: panel.incomingFillColor
          focalX: panel.incomingFocalX
          focalY: panel.incomingFocalY
          asynchronous: true
          cache: false
          smooth: true
          mipmap: true
          onStatusChanged: panel.maybeStartReveal()
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
        function onIncomingBackgroundChanged() {
          panel.maskReady = false
            panel.incomingLockedVersion = -1
          panel.incomingPath = ""
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
