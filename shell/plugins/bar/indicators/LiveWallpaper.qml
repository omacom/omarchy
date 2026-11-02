import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  // Present while live wallpapers are turned on.
  property bool loopsOn: false

  active: loopsOn
  activeText: "󰞍"
  inactiveText: "󰞍"
  activeTooltipText: I18n.t("bar.liveWallpaperOff")
  inactiveTooltipText: I18n.t("bar.liveWallpaperOn")

  // Only omarchy-theme-bg-loop flips the flag, and it refreshes
  // omarchy.indicators afterwards, so the flag is read again then.
  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { flag.reload() }
  }

  FileView {
    id: flag
    path: Quickshell.env("HOME") + "/.local/state/omarchy/toggles/background-loops-on"
    printErrors: false
    onLoaded: root.loopsOn = true
    onLoadFailed: root.loopsOn = false
  }

  onPressed: function() { Quickshell.execDetached(["omarchy-theme-bg-loop", "toggle"]) }
}
