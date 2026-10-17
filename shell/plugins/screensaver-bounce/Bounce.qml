import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "BounceModel.js" as BounceModel

// The screensaver's bouncing DVD logo. omarchy-screensaver summons it for its
// own monitor and keeps its terminal black underneath, still watching for
// input and focus as it does for every effect. Drawing here instead of in the
// terminal lets the logo glide a pixel at a time at the display's frame rate
// rather than jump a character cell at a time.
Item {
  id: root

  property string omarchyPath: ""
  property var shell: null
  property var manifest: null

  property bool opened: false
  // Monitor name -> time (ms since the epoch) to stop bouncing on it.
  property var stopTimes: ({})
  property var art: BounceModel.parseArt("")

  function focusedMonitorName() {
    var monitor = Hyprland.focusedMonitor
    return monitor ? String(monitor.name || "") : ""
  }

  // Payload: {"monitor": "DP-1", "seconds": 30}. Without a monitor it bounces
  // on the focused one.
  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) {}
    var name = String(payload.monitor || "") || focusedMonitorName()
    var seconds = Number(payload.seconds) > 0 ? Number(payload.seconds) : 30
    var next = ({})
    for (var k in stopTimes) next[k] = stopTimes[k]
    next[name] = Date.now() + seconds * 1000
    stopTimes = next
    opened = true
    artFile.reload()
    // The monitors' scale and refresh rate set the logo's step.
    Hyprland.refreshMonitors()
  }

  function close() {
    opened = false
    stopTimes = ({})
  }

  function stopOn(name) {
    var next = ({})
    for (var k in stopTimes) if (k !== name) next[k] = stopTimes[k]
    stopTimes = next
    if (Object.keys(next).length > 0) return
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.screensaver-bounce")
    else
      root.close()
  }

  // A screensaver closed without saying so (killed, say) takes its logo with it.
  readonly property bool screensaverShowing: {
    var toplevels = ToplevelManager.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      if (toplevels[i].appId === "org.omarchy.screensaver") return true
    }
    return false
  }
  onScreensaverShowingChanged: if (opened && !screensaverShowing) stopTimes = ({})

  FileView {
    id: artFile
    path: Quickshell.env("HOME") + "/.config/omarchy/branding/screensaver.txt"
    watchChanges: false
    onLoaded: root.art = BounceModel.parseArt(text())
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property var modelData
      readonly property real stopTime: root.stopTimes[modelData.name] || 0
      readonly property bool bouncing: root.opened && stopTime > 0 && root.art.columns > 0

      screen: modelData
      visible: bouncing
      anchors { top: true; left: true; bottom: true; right: true }
      // Solid black, like the terminal underneath, so the compositor has
      // nothing to blend and only redraws this surface each frame.
      color: "black"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-screensaver-bounce"
      // Visual only: keys and pointer motion still reach the screensaver
      // terminal underneath, which is what ends it.
      mask: Region {}

      Timer {
        running: window.bouncing
        interval: Math.max(0, window.stopTime - Date.now())
        onTriggered: root.stopOn(window.modelData.name)
      }

      Item {
        id: logo

        readonly property var monitorInfo: {
          var monitors = Hyprland.monitors.values
          for (var i = 0; i < monitors.length; i++) {
            if (monitors[i].name === window.modelData.name) return monitors[i].lastIpcObject || null
          }
          return null
        }
        // Screen pixels per logical pixel. Qt rounds its own ratio to a whole
        // number on a fractionally scaled screen, so ask Hyprland.
        readonly property real dpr: logo.monitorInfo && logo.monitorInfo.scale > 0
          ? logo.monitorInfo.scale
          : Math.max(1, window.devicePixelRatio)
        // A block pixel is half a character wide and half a row tall, so it
        // is drawn twice as tall as it is wide. Sizes are whole device pixels,
        // so neighbouring rows meet without seams.
        readonly property real pixelWidth: Math.max(1, Math.floor(window.width * logo.dpr / 3 / Math.max(1, root.art.columns))) / logo.dpr
        readonly property real pixelHeight: logo.pixelWidth * 2

        readonly property real refreshRate: logo.monitorInfo && logo.monitorInfo.refreshRate > 0
          ? logo.monitorInfo.refreshRate
          : 60
        // The logo moves the same whole number of screen pixels along each
        // axis every frame, so no step is longer than the next: about a fifth
        // of the screen's height a second, as fast as a DVD player's.
        readonly property int step: Math.max(1, Math.round(window.height * logo.dpr * 0.22 / logo.refreshRate))
        // The same, in logical pixels a second.
        readonly property real speed: logo.step * logo.refreshRate / logo.dpr
        readonly property real rangeX: Math.max(0, Math.floor((window.width - logo.width) * logo.dpr) / logo.dpr)
        readonly property real rangeY: Math.max(0, Math.floor((window.height - logo.height) * logo.dpr) / logo.dpr)

        property real hue: 0
        property real partyHue: 0
        property bool party: false
        // Where each axis is on its own timeline (ms of animation) when it
        // last met a wall and when it next will, and how long a crossing takes.
        // Only used to tell a perfect corner from two walls met apart.
        property real lastHitX: -Infinity
        property real lastHitY: -Infinity
        property real nextHitX: 0
        property real nextHitY: 0
        property real sweepX: 0
        property real sweepY: 0

        width: root.art.blocks ? root.art.columns * logo.pixelWidth : textArt.implicitWidth
        height: root.art.blocks ? root.art.rows * logo.pixelHeight : textArt.implicitHeight

        // Drawn once into a texture, so each frame only moves one image.
        layer.enabled: true
        layer.smooth: false

        readonly property color tint: BounceModel.colorFor(logo.party ? logo.partyHue : logo.hue)

        // The path is straight lines between walls, so each leg is handed to
        // an animator once. Animators run on the render thread and place the
        // logo from the display's own frame clock, so nothing the rest of the
        // shell is busy with can hold a frame back.
        function plan(first, out, back, position, heading, range) {
          var path = BounceModel.legs(position, heading, range, logo.speed)
          first.from = path.first.from
          first.to = path.first.to
          first.duration = Math.round(path.first.duration)
          out.from = path.out.from
          out.to = path.out.to
          out.duration = Math.round(path.out.duration)
          back.from = path.back.from
          back.to = path.back.to
          back.duration = Math.round(path.back.duration)
          return path
        }

        function start() {
          logo.hue = Math.random() * 360
          logo.party = false
          logo.lastHitX = -Infinity
          logo.lastHitY = -Infinity
          var x = Math.round(Math.random() * logo.rangeX * logo.dpr) / logo.dpr
          var y = Math.round(Math.random() * logo.rangeY * logo.dpr) / logo.dpr
          var pathX = logo.plan(firstX, outX, backX, x, Math.random() < 0.5 ? 1 : -1, logo.rangeX)
          var pathY = logo.plan(firstY, outY, backY, y, Math.random() < 0.5 ? 1 : -1, logo.rangeY)
          logo.x = x
          logo.y = y
          logo.nextHitX = Math.round(pathX.first.duration)
          logo.nextHitY = Math.round(pathY.first.duration)
          logo.sweepX = Math.round(pathX.out.duration)
          logo.sweepY = Math.round(pathY.out.duration)
          motionX.restart()
          motionY.restart()
        }

        function stop() {
          motionX.stop()
          motionY.stop()
          partyTimer.stop()
        }

        // A wall changes the color; two walls within a couple of frames of
        // each other are a perfect corner, and a rainbow. Each runs straight
        // after the leg that reaches the wall, in the same animation, so the
        // color turns on the frame the logo touches.
        function hitX() {
          logo.lastHitX = logo.nextHitX
          logo.nextHitX += logo.sweepX
          logo.hit(logo.lastHitX, logo.lastHitY, logo.nextHitY)
        }

        function hitY() {
          logo.lastHitY = logo.nextHitY
          logo.nextHitY += logo.sweepY
          logo.hit(logo.lastHitY, logo.lastHitX, logo.nextHitX)
        }

        function hit(at, otherLast, otherNext) {
          var slack = 2000 / logo.refreshRate
          if (BounceModel.isCorner(at, otherLast, slack)) return
          if (BounceModel.isCorner(at, otherNext, slack)) {
            logo.party = true
            partyTimer.restart()
          } else if (!logo.party) {
            logo.hue = BounceModel.nextHue(logo.hue, Math.random())
          }
        }

        // The window only learns its size once it is mapped, and it can arrive
        // in steps, so the path is planned once the sizes settle (callLater
        // folds a burst of changes into one plan), and again if they change.
        readonly property bool ready: window.bouncing && logo.width > 0 && logo.rangeX > 0 && logo.rangeY > 0
        property bool planned: false
        function replan() {
          logo.planned = false
          if (!logo.ready) logo.stop()
        }
        // The motion starts on a frame that is actually being drawn.
        FrameAnimation {
          running: logo.ready && !logo.planned
          onTriggered: {
            logo.planned = true
            logo.start()
          }
        }
        onReadyChanged: Qt.callLater(logo.replan)
        onRangeXChanged: Qt.callLater(logo.replan)
        onRangeYChanged: Qt.callLater(logo.replan)
        onSpeedChanged: Qt.callLater(logo.replan)

        SequentialAnimation {
          id: motionX
          XAnimator { id: firstX; target: logo }
          ScriptAction { script: logo.hitX() }
          SequentialAnimation {
            loops: Animation.Infinite
            XAnimator { id: outX; target: logo }
            ScriptAction { script: logo.hitX() }
            XAnimator { id: backX; target: logo }
            ScriptAction { script: logo.hitX() }
          }
        }

        SequentialAnimation {
          id: motionY
          YAnimator { id: firstY; target: logo }
          ScriptAction { script: logo.hitY() }
          SequentialAnimation {
            loops: Animation.Infinite
            YAnimator { id: outY; target: logo }
            ScriptAction { script: logo.hitY() }
            YAnimator { id: backY; target: logo }
            ScriptAction { script: logo.hitY() }
          }
        }

        Timer {
          id: partyTimer
          interval: 3000
          onTriggered: logo.party = false
        }

        NumberAnimation on partyHue {
          running: logo.party
          from: 0
          to: 1080
          duration: 3000
        }

        Repeater {
          model: root.art.blocks ? root.art.runs : []

          Rectangle {
            required property var modelData
            x: modelData.x * logo.pixelWidth
            y: modelData.y * logo.pixelHeight
            width: modelData.width * logo.pixelWidth
            height: logo.pixelHeight
            color: logo.tint
          }
        }

        Text {
          id: textArt
          visible: !root.art.blocks
          text: root.art.blocks ? "" : root.art.text
          textFormat: Text.PlainText
          font.family: "monospace"
          font.pixelSize: Math.max(8, window.height / 40)
          color: logo.tint
        }
      }
    }
  }
}
