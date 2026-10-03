import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Ui
import "Animation.js" as AnimationModel

// Draws the current weather over the wallpaper, one surface per screen.
//
// The bar widget's panel owns the weather fetch and pushes what it already
// resolved through applyWeather(), so nothing here polls the network and the
// desktop never disagrees with the pill in the bar. With no weather widget on
// the bar there is no weather to draw, and this stays idle.
//
// The surfaces sit on the Bottom layer: above the wallpaper, below every
// window. They take no input — an empty mask keeps double-click-to-change
// wallpaper working through them — and they unmap entirely whenever nothing
// can see them.
Item {
  id: root

  // Injected by the first-party service loader.
  property var shell: null
  property var manifest: null

  // Pushed from Panel.qml. `enabled` is the widget's `animations` setting.
  property bool animationsEnabled: false
  property var currentWeather: null

  // Set by the preview IPC; overrides the real conditions while present.
  property var previewOverride: null

  readonly property var liveProfile: AnimationModel.profileForCurrent(currentWeather)
  readonly property var profile: previewOverride || liveProfile

  // Same reasons a video wallpaper stops decoding: a locked or screensaved
  // session covers every output, and power-saving on battery should not be
  // spending anything on decoration. Fullscreen is decided per output below,
  // because it only covers its own.
  readonly property var lockService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.lock") : null
  readonly property var idleService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.idle") : null
  readonly property var batteryService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.battery") : null
  readonly property bool lockActive: lockService ? lockService.locked : false
  readonly property bool screensaverActive: idleService ? idleService.screensaverWindowCount > 0 : false
  readonly property bool powerSaverActive: batteryService ? batteryService.powerSaverOnBattery : false
  readonly property bool sessionObscured: lockActive || screensaverActive

  readonly property bool active: animationsEnabled
    && profile !== null
    && !sessionObscured
    && !powerSaverActive

  // Panel.qml hands over the `current` object it renders the pill from, plus
  // the widget's setting, whenever either changes — and re-asserts both on a
  // heartbeat, which is what sourceTimeout below is watching for.
  function applyWeather(current, enabled) {
    root.currentWeather = current || null
    root.animationsEnabled = enabled === true
    sourceTimeout.restart()
  }

  // A widget taken off the bar destroys its panel without telling anyone, and
  // there is nothing left to draw the weather from. Rather than bookkeeping
  // live panels — there is one per bar surface, so they come and go with
  // monitors — treat a lapsed heartbeat as the source going away. Any
  // surviving panel keeps this restarted, so unplugging one monitor never
  // clears the desktop the others are still showing.
  Timer {
    id: sourceTimeout

    interval: 70000
    onTriggered: {
      root.currentWeather = null
      root.animationsEnabled = false
    }
  }

  IpcHandler {
    target: "omarchy.weather-animation"

    // Preview a condition without waiting for the weather to turn. Clears
    // itself after ten minutes so a forgotten preview cannot outlive the
    // session's real conditions.
    function preview(condition: string): string {
      var profile = AnimationModel.previewProfile(condition)
      if (!profile) return "unknown condition (expected one of: " + AnimationModel.previewNames().join(", ") + ")"
      root.previewOverride = profile
      previewExpiry.restart()
      return "ok"
    }

    function clear(): string {
      previewExpiry.stop()
      root.previewOverride = null
      return "ok"
    }

    function status(): string {
      return JSON.stringify({
        enabled: root.animationsEnabled,
        active: root.active,
        previewing: root.previewOverride !== null,
        condition: root.profile ? root.profile.condition : "",
        intensity: root.profile ? root.profile.intensity : 0
      })
    }
  }

  Timer {
    id: previewExpiry

    interval: 600000
    onTriggered: root.previewOverride = null
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: surface

      required property var modelData

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"

      // Nothing on this layer is interactive, and an input region would
      // swallow the background's double-click-to-change-wallpaper.
      mask: Region { }
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.namespace: "omarchy-weather-animation"
      // Above the wallpaper, below every window: weather on the desktop, and
      // nothing falling across whatever the user is actually working in.
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      // A fullscreen window on the workspace this output is showing hides the
      // wallpaper, so there is nothing left to animate over. Decided per
      // output rather than per focus, or a fullscreen video on one screen
      // would freeze the desktop still on show next to it.
      readonly property var hyprlandMonitor: Hyprland.monitorFor(modelData)
      readonly property var visibleWorkspace: hyprlandMonitor ? hyprlandMonitor.activeWorkspace : null
      readonly property bool fullscreenHere: visibleWorkspace ? visibleWorkspace.hasFullscreen : false

      // Unmapping when idle is the point: no surface, no compositing, no
      // wakeups. Unlike the wallpaper there is no buffer worth keeping alive,
      // because the next map starts a fresh fade-in anyway.
      visible: root.active && !fullscreenHere && !remapGuard.remapping

      ScreenMoveRemap {
        id: remapGuard

        window: surface
      }

      WeatherAnimation {
        anchors.fill: parent
        profile: root.profile
        running: surface.visible
      }
    }
  }
}
