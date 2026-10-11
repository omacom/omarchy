import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  ShellIpc {
    enabled: root.ipcOwner
    target: "test.widget"

    function ping(): string { return "pong" }
  }
}
