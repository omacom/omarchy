import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "OverviewModel.js" as OverviewModel

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool requested: false
  property string monitorName: ""
  property int workspaceId: -1
  property int selectedIndex: -1
  property var windows: []

  function open(payloadJson) {
    var monitor = Hyprland.focusedMonitor
    if (!monitor || !monitor.activeWorkspace || modeRead.running) return
    monitorName = monitor.name
    workspaceId = Number(monitor.activeWorkspace.id)
    if (workspaceId < 1) return
    requested = true
    modeRead.command = ["omarchy-hyprland-workspace-layout-current", String(workspaceId)]
    modeRead.running = true
  }
  function close() {
    requested = false
    opened = false
    windows = []
  }
  function refresh() {
    var next = OverviewModel.windowsOnWorkspace(Hyprland.toplevels.values, workspaceId)
    selectedIndex = OverviewModel.selectionAfterChange(windows, selectedIndex, next)
    windows = next
  }
  function choose(index) {
    var window = windows[index]
    if (!window || !window.wayland) return
    close()
    Qt.callLater(function() { if (window.wayland) window.wayland.activate() })
  }

  Process {
    id: modeRead
    stdout: StdioCollector {
      onStreamFinished: {
        var monitor = Hyprland.focusedMonitor
        if (!root.requested || text.trim() !== "floating" || !monitor
            || monitor.name !== root.monitorName || !monitor.activeWorkspace
            || Number(monitor.activeWorkspace.id) !== root.workspaceId) return
        root.refresh()
        root.opened = true
        Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      }
    }
  }
  Connections {
    target: Hyprland.toplevels
    function onValuesChanged() { if (root.opened) root.refresh() }
  }
  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() {
      if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name !== root.monitorName) root.close()
    }
    function onRawEvent(event) {
      if (!root.opened && !root.requested) return
      var name = event ? String(event.name) : ""
      if (name === "workspace" || name === "workspacev2" || name === "monitorremoved") root.close()
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-window-overview"
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.94)
    }
    MouseArea { anchors.fill: parent; onClicked: root.close() }
    FocusScope {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) root.close()
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.choose(root.selectedIndex)
        else if (root.windows.length && [Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down, Qt.Key_Tab].indexOf(event.key) >= 0) {
          var step = event.key === Qt.Key_Up ? -layout.columns : event.key === Qt.Key_Down ? layout.columns
            : event.key === Qt.Key_Left || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) ? -1 : 1
          root.selectedIndex = (root.selectedIndex + step + root.windows.length) % root.windows.length
        } else return
        event.accepted = true
      }
      Text {
        anchors.centerIn: parent
        visible: root.windows.length === 0
        text: Commons.I18n.t("overview.empty")
        textFormat: Text.PlainText
        color: Commons.Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
      }
      Grid {
        id: layout
        // Align every card edge to physical pixels on fractional-scale outputs.
        readonly property real pixelRatio: Math.max(1, panel.devicePixelRatio)
        function snap(value) { return Math.round(value * pixelRatio) / pixelRatio }
        x: snap((parent.width - width) / 2)
        y: snap((parent.height - height) / 2)
        columns: Math.max(1, Math.ceil(Math.sqrt(root.windows.length * panel.width / Math.max(1, panel.height))))
        readonly property int rowCount: Math.max(1, Math.ceil(root.windows.length / columns))
        spacing: snap(Style.space(20))
        readonly property real cellWidth: snap(Math.max(1, Math.min(Style.space(480), (panel.width - Style.space(80) - spacing * (columns - 1)) / columns)))
        readonly property real cellHeight: snap(Math.max(1, Math.min(cellWidth * 0.7, (panel.height - Style.space(80) - spacing * (rowCount - 1)) / rowCount)))
        Repeater {
          model: root.windows
          delegate: BorderSurface {
            id: tile
            required property var modelData
            required property int index
            width: layout.cellWidth
            height: layout.cellHeight
            radius: Style.cornerRadius
            antialiasing: true
            border.pixelAligned: false
            color: Commons.Color.popups.background
            borderSpec: index === root.selectedIndex
              ? Border.hyprlandActiveSpec(Commons.Color.accent, Style.normalBorderWidth)
              : Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.muted, Style.normalBorderWidth)
            clip: true
            ScreencopyView {
              captureSource: root.opened ? tile.modelData.wayland : null
              live: root.opened
              readonly property real ratio: sourceSize.height > 0 ? sourceSize.width / sourceSize.height : 1.6
              width: Math.min(tile.width - Style.space(16), Math.max(1, tile.height - Style.space(44)) * ratio)
              height: width / ratio
              anchors.horizontalCenter: parent.horizontalCenter
              y: Style.space(8)
            }
            Text {
              anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
              anchors.margins: Style.space(12)
              text: tile.modelData.wayland ? tile.modelData.wayland.title : ""
              textFormat: Text.PlainText
              color: Commons.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: root.selectedIndex = tile.index
              onClicked: root.choose(tile.index)
            }
          }
        }
      }
    }
  }
}
