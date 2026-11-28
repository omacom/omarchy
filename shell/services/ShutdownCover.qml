import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons

// Fullscreen shutdown/reboot cover: fades straight from the desktop into the
// exact Omarchy logo screen Plymouth renders (default/plymouth/shutdown.png),
// matching Plymouth's device-scale and integer-scale geometry so the handoff
// from Hyprland to Plymouth has no black gap or icon jump.
Item {
  id: root

  readonly property size imageSize: Qt.size(3840, 2160)
  readonly property string imageUrl: {
    var path = Quickshell.env("OMARCHY_PATH")
    return path ? Util.fileUrl(path + "/default/plymouth/shutdown.png") : ""
  }

  property bool active: false
  property bool fadeStarted: false
  property real coverOpacity: 0

  // Mirror plymouth 26.134's ply_guess_device_scale / get_device_scale (libply
  // ply-utils.c) so the icon renders at the physical pixel size Plymouth picks.
  function plymouthDeviceScale(width, height, mmWidth, mmHeight) {
    if (!(width > 0) || !(height > 0) || !(mmWidth > 0) || !(mmHeight > 0)) return 1
    if ((mmWidth === 160 && (mmHeight === 90 || mmHeight === 100)) ||
        (mmWidth === 16 && (mmHeight === 9 || mmHeight === 10))) {
      return 1
    }

    var dpiX = Math.floor((254 * width) / (10 * mmWidth + 10))
    var dpiY = Math.floor((254 * height) / (10 * mmHeight + 10))
    if (dpiX <= 96 || dpiY <= 96) {
      var big = Math.max(width, height)
      var small = Math.min(width, height)
      if (big / small === 1.5) return (big > 1799 && small > 1199) ? 2 : 1
      return (big > 2879 && small > 1619) ? 2 : 1
    }

    var diagInches = Math.sqrt(mmWidth * mmWidth + mmHeight * mmHeight) / 25.4
    var dpi = Math.sqrt(width * width + height * height) / diagInches
    return (dpi / (diagInches < 20.0 ? 135.0 : 110.0)) > 1.625 ? 2 : 1
  }

  // Mirror default/plymouth/omarchy.script: native size unless the window is
  // larger than shutdown.png, in which case scale up by the smallest whole factor.
  function imageUnitFor(monitor, screen) {
    var info = monitor ? monitor.lastIpcObject : null
    var dpr = screen && screen.devicePixelRatio > 0 ? screen.devicePixelRatio : 1
    var physW = info && info.width > 0 ? info.width : Math.round((screen ? screen.width : 0) * dpr)
    var physH = info && info.height > 0 ? info.height : Math.round((screen ? screen.height : 0) * dpr)
    var hyprScale = monitor && monitor.scale > 0 ? monitor.scale : dpr
    var plyScale = plymouthDeviceScale(physW, physH, info ? (info.physicalWidth || 0) : 0, info ? (info.physicalHeight || 0) : 0)
    var scale = Math.max((physW / plyScale) / imageSize.width, (physH / plyScale) / imageSize.height)
    var imgScale = scale <= 1 ? 1 : Math.ceil(scale)
    return (imgScale * plyScale) / hyprScale
  }

  function show() {
    Hyprland.refreshMonitors()
    if (!active) {
      fadeIn.stop()
      coverOpacity = 0
      fadeStarted = false
      active = true
      safetyTimer.restart()
      Qt.callLater(startFadeIfReady)
    }
    return String(fadeIn.duration)
  }

  // Snap straight back to the desktop when an exit is rejected so the failure
  // notification is immediately visible.
  function hide() {
    safetyTimer.stop()
    fadeIn.stop()
    active = false
    fadeStarted = false
    coverOpacity = 0
  }

  function startFadeIfReady() {
    if (!active || fadeStarted) return
    if (Quickshell.screens.length > 0 && covers.instances.length < Quickshell.screens.length) return
    for (var i = 0; i < covers.instances.length; i++) {
      if (!covers.instances[i].imageReady) return
    }
    fadeStarted = true
    if (fadeIn.duration > 0) fadeIn.restart()
    else coverOpacity = 1
  }

  // Full-screen transition rather than a repeated UI control; matches
  // startup-cover.qml's 420 ms fade-out (agents/skills/motion.md).
  NumberAnimation {
    id: fadeIn
    target: root
    property: "coverOpacity"
    from: 0
    to: 1
    duration: Style.duration(400)
    easing.type: Easing.OutCubic
  }

  // Never leave the desktop permanently covered if the exit request is aborted.
  Timer {
    id: safetyTimer
    interval: 15000
    onTriggered: root.hide()
  }

  Variants {
    id: covers
    model: root.active ? Quickshell.screens : []

    PanelWindow {
      id: panel
      required property var modelData
      readonly property real imageUnit: root.imageUnitFor(Hyprland.monitorFor(modelData), modelData)
      readonly property bool imageReady: !root.imageUrl ||
        shutdownImage.status === Image.Ready ||
        shutdownImage.status === Image.Error

      screen: modelData
      // Keep the window surface transparent and animate opacity on the inner
      // rectangle so mapping the window cannot flash black before the fade.
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "omarchy-shutdown"

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.BlankCursor
      }

      Component.onCompleted: {
        if ("cursorShape" in WlrLayershell) WlrLayershell.cursorShape = Qt.BlankCursor
        root.startFadeIfReady()
      }

      onImageReadyChanged: root.startFadeIfReady()

      Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.coverOpacity
        clip: true

        Image {
          id: shutdownImage
          anchors.centerIn: parent
          width: root.imageSize.width * panel.imageUnit
          height: root.imageSize.height * panel.imageUnit
          source: root.imageUrl
          smooth: false
          asynchronous: true
        }
      }
    }
  }
}
