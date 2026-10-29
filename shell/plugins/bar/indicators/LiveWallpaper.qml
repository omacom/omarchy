import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  // Present while live wallpapers are turned off.
  property bool loopsOff: false

  active: loopsOff
  activeText: "󰕨"
  inactiveText: "󰕨"
  activeTooltipText: I18n.t("bar.liveWallpaperOn")
  inactiveTooltipText: I18n.t("bar.liveWallpaperOff")

  // Only omarchy-theme-bg-loop flips the flag, and it refreshes
  // omarchy.indicators afterwards, so the flag is read again then.
  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { flag.reload() }
  }

  FileView {
    id: flag
    path: Quickshell.env("HOME") + "/.local/state/omarchy/toggles/background-loops-off"
    printErrors: false
    onLoaded: root.loopsOff = true
    onLoadFailed: root.loopsOff = false
  }

  onPressed: function() { Quickshell.execDetached(["omarchy-theme-bg-loop", "toggle"]) }
}
