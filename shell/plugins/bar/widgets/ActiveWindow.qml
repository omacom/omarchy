import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.active-window"

  // Wayland foreign-toplevel focus is global; map it onto Hyprland so this
  // per-monitor bar instance can keep the title on the output that owns it.
  readonly property var activeWayland: ToplevelManager.activeToplevel
  readonly property var barWindow: QsWindow.window
  readonly property var barScreen: barWindow ? barWindow.screen : null
  readonly property string barScreenName: barScreen ? String(barScreen.name || "") : ""

  function hyprlandToplevelFor(waylandToplevel) {
    if (!waylandToplevel) return null

    var values = Hyprland.toplevels.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].wayland === waylandToplevel) return values[i]
    }

    return null
  }

  readonly property var hyprlandToplevel: hyprlandToplevelFor(activeWayland)
  readonly property var activeMonitor: hyprlandToplevel ? hyprlandToplevel.monitor : null
  readonly property string activeMonitorName: activeMonitor ? String(activeMonitor.name || "") : ""
  // Missing Hyprland match or null monitor: hide rather than mirror globally.
  readonly property bool onThisScreen: barScreenName !== "" && activeMonitorName !== "" && barScreenName === activeMonitorName
  readonly property var toplevel: onThisScreen ? activeWayland : null
  readonly property string title: toplevel ? (toplevel.title || toplevel.appId || "") : ""
  readonly property int maxLabelWidth: Number(setting("maxWidth", 280))

  visible: title !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, labelText.implicitWidth) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Text {
      id: labelText
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      width: parent.width
      text: root.title
      color: root.bar ? root.bar.barForeground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      opacity: 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton) {
        root.toplevel.close()
      } else if (mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
