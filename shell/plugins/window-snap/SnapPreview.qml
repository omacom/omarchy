import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// While a floating window is dragged with the pointer on the top bar, the box
// it will fill if dropped there grows out of the window's own frame, as window
// snapping does on Windows. Hyprland asks for it from floating-bounds.lua with
// `omarchy-shell omarchy.window-snap show <json>` and takes it down with hide,
// both in the screen's logical coordinates:
// {"monitor":"DP-1","from":{"x":..,"y":..,"width":..,"height":..},"to":{..}}
Item {
  id: root

  property bool opened: false
  property string monitorName: ""
  property var fromBox: null
  property var toBox: null

  function screenNamed(name) {
    for (var i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i].name === name) return Quickshell.screens[i]
    }
    return null
  }

  function show(payloadJson) {
    var payload
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { return }
    if (!payload.from || !payload.to || !screenNamed(payload.monitor)) return

    var moving = root.opened && root.monitorName === payload.monitor
    root.monitorName = payload.monitor
    root.fromBox = payload.from
    root.toBox = payload.to
    if (moving) {
      frame.place(root.toBox, true)
      return
    }
    frame.place(root.fromBox, false)
    root.opened = true
    panel.targetScreen = screenNamed(payload.monitor)
  }

  function hide() {
    root.opened = false
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    shownKeyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-window-snap"
    // Only something to look at: clicks and the drag itself go to what is below.
    mask: Region {}

    // The box starts as the window's frame and grows once the surface is on
    // screen, so the growth is seen rather than spent on a hidden first frame.
    onContentRevealedChanged: if (contentRevealed && root.toBox) frame.place(root.toBox, true)

    Rectangle {
      id: frame

      property bool animated: false

      function place(box, animate) {
        frame.animated = animate
        frame.x = box.x
        frame.y = box.y
        frame.width = box.width
        frame.height = box.height
      }

      color: Style.selectionFill
      border.color: Commons.Color.accent
      border.width: Math.max(2, Style.space(2))
      radius: Style.cornerRadius

      Behavior on x { enabled: frame.animated; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on y { enabled: frame.animated; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on width { enabled: frame.animated; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on height { enabled: frame.animated; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    }
  }

  ShellIpc {
    target: "omarchy.window-snap"
    function show(payloadJson: string): string { root.show(payloadJson); return "ok" }
    function hide(): string { root.hide(); return "ok" }
  }
}
