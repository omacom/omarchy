import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// Independent layer-shell popup: moving a bar or remapping its surface must
// not destroy an active preview's confirmation controls.
Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool focusPrimed: false
  property string screenName: ""
  readonly property string pluginId: manifest ? String(manifest.id) : "omarchy.display-settings"

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) {}
    var page = payload.page || "layout"
    if (editor.pages.indexOf(page) >= 0) editor.page = page
    screenName = payload.screen || (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "")
    focusPrimed = false
    opened = true
    focusPrime.restart()
    editor.refresh()
    Qt.callLater(function() { editor.forceActiveFocus() })
  }
  function close() { opened = false }
  function requestClose() {
    if (shell) shell.hide(pluginId)
    else close()
  }
  Timer { id: focusPrime; interval: 120; onTriggered: root.focusPrimed = true }

  PanelWindow {
    id: window
    visible: root.opened
    screen: Quickshell.screens.find(function(s) { return s.name === root.screenName }) || Quickshell.screens[0] || null
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "omarchy-display-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened ? (root.focusPrimed ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive) : WlrKeyboardFocus.None

    MouseArea {
      anchors.fill: parent
      // Accidental clicks must not dismiss the confirmation during preview.
      onClicked: if (!editor.pending) root.requestClose()
    }
    BorderSurface {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.rightMargin: Style.space(12)
      anchors.topMargin: Style.space(40)
      width: Math.min(Style.space(900), window.width - Style.space(24))
      height: Math.min(Style.space(720), window.height - Style.space(52))
      color: Commons.Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      MouseArea { anchors.fill: parent }
      Editor {
        id: editor
        anchors.fill: parent
        anchors.margins: Style.space(22)
        onCloseRequested: root.requestClose()
      }
    }
  }
}
