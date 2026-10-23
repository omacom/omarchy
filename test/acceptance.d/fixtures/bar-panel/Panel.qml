import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Ui
import qs.Commons

// An installed third-party widget exercising the actual scoped bar facade.
Panel {
  id: root
  moduleName: "acceptance.bar-panel"
  manageIpc: false
  implicitWidth: bar ? bar.barSize : 28
  implicitHeight: bar ? bar.barSize : 28

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "QA"
    onPressed: root.toggle()
  }
  KeyboardPanel {
    id: panel
    bar: root.bar
    owner: root
    anchorItem: button
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: 180
    contentHeight: 80
    content: PanelKeyCatcher {
      onCloseRequested: root.close()
      Text { anchors.centerIn: parent; text: "Bar anchor acceptance"; color: "white" }
    }
  }
  function cardGeometry() {
    var logical = bar && typeof bar.panelWindowFor === "function" ? bar.panelWindowFor(root) : null
    return {open:root.opened,mapped:panel.backingWindowVisible,instanceId:String(root),
      screen:panel.screen ? panel.screen.name : null,logicalScreen:logical && logical.screen ? logical.screen.name : null,
      x:panel.cardOrigin.x,y:panel.cardOrigin.y,width:panel.contentWidth,height:panel.contentHeight,
      anchorWidth:button.width,anchorHeight:button.height}
  }
  ShellIpc {
    target: "acceptance.bar-panel.geometry"
    function focusedScreen(): string {
      return Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    }
    function refreshMonitors(): void {
      Hyprland.refreshMonitors()
    }
    function states(): string {
      var widgets = root.bar ? root.bar.moduleWidgets(root.moduleName) : []
      return JSON.stringify(widgets.map(function(widget) { return widget.cardGeometry() }))
    }
  }
}
