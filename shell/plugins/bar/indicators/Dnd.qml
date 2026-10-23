import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// The notification indicator: Do Not Disturb. Click to silence or resume;
// right-click for the notification panel.
BarIndicator {
  id: root

  readonly property var notificationService: bar?.shell?.firstPartyServiceFor("omarchy.notifications")
  readonly property bool dnd: notificationService ? notificationService.doNotDisturb : false
  // A built-in clone of the indicators widget gets a narrowed service proxy
  // with only the silence switch; the panel needs the real service.
  readonly property bool fullService: !!notificationService && typeof notificationService.requestPanel === "function"

  active: dnd
  activeText: "\u{f009b}"
  inactiveText: "\u{f009b}"
  activeTooltipText: I18n.t("bar.allowNotifications")
  inactiveTooltipText: I18n.t("bar.silenceNotifications")

  onPressed: function(button) {
    if (!root.notificationService) return
    if (button === Qt.RightButton) {
      if (root.fullService) root.notificationService.requestPanel("toggle", root.screenName)
    } else {
      root.notificationService.setDoNotDisturb(!root.notificationService.doNotDisturb)
    }
  }

  readonly property string screenName: {
    var window = root.QsWindow.window
    return window && window.screen ? String(window.screen.name || "") : ""
  }

  // Clicks, keybindings and IPC all go through the service; the indicator on
  // the requested monitor answers, building its panel the first time.
  Connections {
    target: root.fullService ? root.notificationService : null
    ignoreUnknownSignals: true
    function onPanelRequested(action, screenName) {
      if (!root.belongsInBlock || (screenName && root.screenName && root.screenName !== screenName)) return
      if (!panelLoader.item) {
        panelLoader.setSource(root.notificationService.panelUrl,
                              { anchorItem: root, bar: root.bar, service: root.notificationService })
      }
      var panel = panelLoader.item
      if (!panel) return
      panel.open()
    }
  }

  Loader { id: panelLoader }
}
