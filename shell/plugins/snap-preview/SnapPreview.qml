import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import "SnapPreviewModel.js" as SnapPreviewModel

// Where a window dragged on a floating workspace will land when it is let go:
// an outline in the theme's accent on that screen, from the drop target window
// snapping announces (default/hypr/window-snapping.lua). It takes no input and
// no focus, and a screen has a surface only while its outline shows.
Item {
  id: root

  property var shell: null
  property var manifest: null

  // { monitor, x, y, w, h } in layout coordinates, or null.
  property var target: null

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event) return
      if (String(event.name) === "configreloaded") {
        root.target = null
        return
      }
      var parsed = SnapPreviewModel.parse(event.name, event.data)
      if (parsed !== undefined) root.target = parsed
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: window
        required property var modelData
        screen: modelData

        readonly property bool here: root.target !== null && root.target.monitor === modelData.name
        // The last box shown here, kept while the outline fades out.
        property var box: null
        onHereChanged: if (here) box = root.target
        Connections {
          target: root
          function onTargetChanged() { if (window.here) window.box = root.target }
        }

        visible: here || outline.opacity > 0
        color: "transparent"
        WlrLayershell.namespace: "omarchy-snap-preview"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        mask: Region {}

        Rectangle {
          id: outline
          // Moves from one target to the next only while already out: a fresh
          // outline appears where it belongs.
          property bool out: false

          x: window.box ? window.box.x - window.modelData.x : 0
          y: window.box ? window.box.y - window.modelData.y : 0
          width: window.box ? window.box.w : 0
          height: window.box ? window.box.h : 0
          radius: Style.cornerRadius
          color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.15)
          border.color: Commons.Color.accent
          border.width: 2
          antialiasing: true

          opacity: window.here ? 1 : 0
          scale: window.here ? 1 : 0.97
          onOpacityChanged: out = opacity === 1

          Behavior on opacity {
            NumberAnimation { duration: Style.duration(window.here ? 180 : 120); easing.type: Easing.OutCubic }
          }
          Behavior on scale {
            NumberAnimation { duration: Style.duration(window.here ? 180 : 120); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }
          Behavior on x {
            enabled: outline.out
            NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }
          Behavior on y {
            enabled: outline.out
            NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }
          Behavior on width {
            enabled: outline.out
            NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }
          Behavior on height {
            enabled: outline.out
            NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }
        }
      }
    }
  }
}
