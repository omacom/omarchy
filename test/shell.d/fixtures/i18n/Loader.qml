import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  Component.onCompleted: {
    console.log("NETWORK=" + I18n.tr("Network"))
    console.log("UNKNOWN=" + I18n.tr("Uncatalogued message"))
    console.log("CONFIRM=" + I18n.tr("Do you want to uninstall %1?", ["example"]))
  }
  Timer { interval: 1; running: true; onTriggered: Qt.quit() }
}
