import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property var failures: []
  property int stage: 0
  property var gate: null

  QtObject {
    id: request
    property int cancellations: 0
    function cancelAuthenticationRequest() { cancellations += 1 }
  }

  function check(condition, message) {
    if (!condition) failures.push(message)
  }

  Timer {
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      if (root.stage === 0) {
        var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/polkit/AuthenticationGate.qml", Component.PreferSynchronous)
        root.gate = component.createObject(null)
        root.check(root.gate !== null, component.errorString())
        if (!root.gate) { root.stage = 4; return }
        root.check(root.gate.blocked, "authentication fails closed during discovery")
        root.gate.blocked = false
        root.gate.flow = request
      } else if (root.stage === 1) {
        root.check(request.cancellations === 0, "unlocked requests stay active")
        root.gate.blocked = true
        root.check(request.cancellations === 1, "locking cancels the active flow immediately")
        root.gate.flow = null
      } else if (root.stage === 2) {
        root.gate.flow = request
      } else if (root.stage === 3) {
        root.check(request.cancellations === 2, "a new flow while already locked is canceled")
        root.gate.blocked = false
        root.check(!root.gate.rejectBlockedRequest(), "unlock permits a fresh authorization")
        root.check(request.cancellations === 2, "unlock does not cancel or replay an old flow")
        root.gate.destroy()
      } else {
        result.setText(JSON.stringify({ok: root.failures.length === 0, failures: root.failures}))
        stop()
      }
      root.stage += 1
    }
  }

  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }
}
