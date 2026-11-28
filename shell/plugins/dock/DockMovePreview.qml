import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// Where the dock would land while it is dragged by its apps button: an
// outline of it on the nearest edge, jumping between edges as the pointer
// does. The dock itself does not move until the drop, so without this the
// drag shows nothing until it is over. Mapped only for the drag, covering the
// screen and letting every click through.
PanelWindow {
  id: preview

  property var dock: null
  // The screen this preview is for. Its own `screen` settles as the window
  // maps, so reading that to decide whether to map loops back on itself.
  property var showOn: null

  readonly property string edge: dock ? dock.moveEdge : ""
  readonly property bool vertical: edge === "left" || edge === "right"
  readonly property var monitor: Hyprland.monitorFor(screen)
  // The space other surfaces, such as the bar, reserve: left, top, right,
  // bottom. The dock keeps clear of it, and so does its outline.
  readonly property var reserved: monitor && monitor.lastIpcObject && monitor.lastIpcObject.reserved ? monitor.lastIpcObject.reserved : [0, 0, 0, 0]

  visible: !!dock && dock.moveScreen === showOn && edge !== ""
  color: "transparent"
  WlrLayershell.namespace: "omarchy-dock-preview"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore
  mask: Region {}

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  Rectangle {
    readonly property real thickness: preview.dock ? preview.dock.moveThickness : 0
    readonly property real length: preview.dock ? preview.dock.moveLength : 0
    readonly property real gap: Style.spacing.xs
    readonly property real keepLeft: preview.reserved[0] || 0
    readonly property real keepTop: preview.reserved[1] || 0
    readonly property real keepRight: preview.reserved[2] || 0
    readonly property real keepBottom: preview.reserved[3] || 0

    x: preview.edge === "left" ? keepLeft + gap
      : preview.edge === "right" ? preview.width - keepRight - gap - width
      : keepLeft + Math.round((preview.width - keepLeft - keepRight - width) / 2)
    y: preview.edge === "top" ? keepTop + gap
      : preview.edge === "bottom" ? preview.height - keepBottom - gap - height
      : keepTop + Math.round((preview.height - keepTop - keepBottom - height) / 2)
    width: preview.vertical ? thickness : length
    height: preview.vertical ? length : thickness
    radius: Style.cornerRadius
    color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
    border.color: Commons.Color.accent
    border.width: Style.normalBorderWidth
  }
}
