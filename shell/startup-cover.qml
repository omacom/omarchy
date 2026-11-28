import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// The startup cover: the boot splash's look (theme background, accent logo,
// progress bar) at the splash's size, from Hyprland's first frame until the
// desktop is ready. omarchy-launch-shell starts this small instance ahead of
// a session's first shell, whose plugins and services take a second or more to
// load. The shell (BackgroundIntro.qml) says over the socket below when to
// reveal the desktop; this fills its bar and fades out then, and quits, which
// tells the shell the reveal is over. It fades out after 10 seconds whatever
// the shell does.
ShellRoot {
  id: root

  // Where the boot splash's bar was as it was stopped (default/splash/stop), or
  // "none" where it showed no bar, and then this shows none. Without either, as
  // after the login screen, the bar starts empty, as the splash's does after
  // Enter.
  readonly property string splashBar: String(splashProgress.text() || "").trim()
  readonly property bool barShown: splashBar !== "none"
  readonly property real startProgress: Math.min(Math.max(Number(splashBar) || 0, 0), 0.95)
  // Fake progress, as nothing reports how far startup has got: from rest at
  // startProgress it picks up within half a second, then slows as it nears
  // 95%, which only the reveal passes. The shell is often ready a second or
  // so after this shows, by when the bar is near 90%.
  readonly property real fakeProgress: {
    const t = clock.elapsedTime / 0.5
    return startProgress + (0.95 - startProgress) * (1 - (1 + t) * Math.exp(-t))
  }
  // How far the reveal has filled the rest of the bar.
  property real finish: 0
  readonly property real progress: fakeProgress + (1 - fakeProgress) * finish
  property real coverOpacity: 1

  // The scale the boot splash's sway gave a monitor. Its config sets none, so
  // it is sway's default (compute_default_scale, sway/config/output.c): 2 for
  // a mode at least 1200 px tall at over 192 DPI both ways, else 1. Hyprland
  // reports the mode and the connector's size in mm that sway went by.
  function splashScale(monitor) {
    const info = monitor.lastIpcObject
    const mmWidth = info.physicalWidth
    const mmHeight = info.physicalHeight
    // Sizes some panels report as their aspect ratio instead.
    const ratios = [[1600, 900], [1600, 1000], [160, 90], [160, 100], [16, 9], [16, 10]]
    if (info.height < 1200 || !mmWidth || !mmHeight || ratios.some(([w, h]) => w === mmWidth && h === mmHeight)) return 1
    return info.width / (mmWidth / 25.4) > 192 && info.height / (mmHeight / 25.4) > 192 ? 2 : 1
  }

  // One of the splash's pixels in a window's, so the logo and bar are where
  // the splash drew them whatever scale Hyprland uses: 0 until Hyprland has
  // reported the monitor.
  function splashUnitFor(monitor) {
    if (!monitor || !(monitor.lastIpcObject.width > 0) || !(monitor.scale > 0)) return 0
    return splashScale(monitor) / monitor.scale
  }

  FileView {
    id: splashProgress
    path: "/run/omarchy-splash-progress"
    blockLoading: true
    watchChanges: false
    printErrors: false
  }

  FrameAnimation {
    id: clock
    running: !Style.reduceMotion
  }

  SequentialAnimation {
    id: reveal

    NumberAnimation {
      target: root
      property: "finish"
      to: 1
      duration: root.barShown ? Style.duration(200) : 0
      easing.type: Easing.OutQuad
    }

    NumberAnimation {
      target: root
      property: "coverOpacity"
      to: 0
      duration: Style.duration(420)
      easing.type: Easing.OutCubic
    }

    ScriptAction {
      script: Qt.quit()
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: cover

      // The screen, as Variants gives it. The scale is worked out from this
      // rather than from `screen`, which changes when the window is made, and
      // so while `visible` turns true.
      required property var modelData
      readonly property real splashUnit: root.splashUnitFor(Hyprland.monitorFor(modelData))

      screen: modelData
      // It maps once its first frame can be the splash's size; Hyprland's
      // startup hold keeps the splash's last frame on screen until then.
      visible: splashUnit > 0
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"

      // No pointer over the startup cover, as over the splash: the cover takes
      // the pointer, which also keeps clicks off the desktop it hides.
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.BlankCursor
      }

      Component.onCompleted: {
        // The first frame must use the theme, not the palette defaults.
        Commons.Color.colorsFile.waitForJob()

        // The MouseArea's cursor applies only once Qt Quick sees the pointer, which
        // at startup comes after Qt has answered the pointer's enter with an arrow.
        // A window cursor set before the window shows is the answer itself; the
        // window is made only after this, once the cover is visible. Set where
        // Quickshell has it, so the cover still loads where it doesn't.
        if ("cursorShape" in WlrLayershell) WlrLayershell.cursorShape = Qt.BlankCursor
      }

      Rectangle {
        anchors.fill: parent
        color: Commons.Color.splashBackground
        opacity: root.coverOpacity

        Image {
          id: logo
          anchors.centerIn: parent
          width: Math.min(810, Math.max(0, parent.width / cover.splashUnit - 80)) * cover.splashUnit
          height: width * 19 / 81
          source: Util.fileUrl(Quickshell.env("OMARCHY_PATH") + "/logo.svg")
          sourceSize.width: Math.ceil(width * Screen.devicePixelRatio)
          sourceSize.height: Math.ceil(height * Screen.devicePixelRatio)
          visible: false
          layer.enabled: true
        }

        Rectangle {
          anchors.fill: logo
          color: Commons.Color.splashAccent
          layer.enabled: true
          layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: logo
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
          }
        }

        Rectangle {
          visible: root.barShown
          width: 300 * cover.splashUnit
          height: 10 * cover.splashUnit
          x: (parent.width - width) / 2
          y: logo.y + logo.height + (40 + (48 - 10) / 2) * cover.splashUnit
          color: Qt.tint(Commons.Color.splashBackground, Qt.alpha(Commons.Color.splashForeground, 0.1))

          Rectangle {
            width: Math.max(1, Math.round(300 * root.progress)) * cover.splashUnit
            height: parent.height
            color: Commons.Color.splashForeground
          }
        }
      }
    }
  }

  SocketServer {
    active: true
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/hypr/" + Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") + "/startup-cover.sock"
    handler: Socket {
      parser: SplitParser {
        onRead: data => {
          if (data === "reveal") reveal.start()
        }
      }
    }
  }

  Timer {
    running: true
    interval: 10000
    onTriggered: reveal.start()
  }
}
