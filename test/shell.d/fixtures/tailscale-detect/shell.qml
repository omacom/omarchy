import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var service: null
  property int ticks: 0

  Item { id: host }

  function finish(ok, message) {
    var payload = JSON.stringify({ ok: ok, message: message })
    var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/panels/tailscale/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      finish(false, component.errorString())
      return
    }
    service = component.createObject(host, {})
    if (!service) finish(false, component.errorString())
    else poll.running = true
  }

  Timer {
    id: poll
    interval: 100
    repeat: true
    onTriggered: {
      root.ticks += 1
      if (root.service.installed) {
        running = false
        root.finish(true, "")
      } else if (root.ticks >= 50) {
        running = false
        root.finish(false, "tailscale on PATH was reported as not installed: " + root.service.statusText)
      }
    }
  }
}
