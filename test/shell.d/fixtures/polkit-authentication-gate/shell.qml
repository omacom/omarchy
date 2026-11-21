import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property var failures: []
  property var cancellations: []
  property int stage: 0
  property var gate: null
  property var lockedRequest: null

  Component {
    id: requestComponent
    QtObject {
      property string name
      property bool isCompleted: false
      property bool isCancelled: false
      property int cancellations: 0
      function cancelAuthenticationRequest() {
        cancellations += 1
        root.cancellations.push(name)
        isCancelled = true
        isCompleted = true
        // Cancellation may synchronously clear the native agent's flow.
        if (root.gate.flow === this) root.gate.flow = null
      }
    }
  }

  function request(name) { return requestComponent.createObject(root, {name: name}) }
  function check(condition, message) {
    if (!condition) failures.push(message)
  }
  function begin(request) {
    gate.flow = request
    return gate.rejectBlockedRequest()
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
        if (!root.gate) { root.stage = 3; return }
        root.check(root.gate.blocked, "authentication fails closed during discovery")
        var discovery = root.request("discovery")
        root.check(root.begin(discovery), "startup requests are rejected")
        root.check(discovery.cancellations === 1, "startup cancels exactly once")

        root.gate.blocked = false
        var first = root.request("first")
        root.check(!root.begin(first), "unlocked requests stay active")
        var second = root.request("second")
        root.check(root.begin(second), "overlapping requests are rejected")
        root.check(root.cancellations.slice(-2).join(",") === "second,first", "overlap cancels newest before previous")
        root.check(first.cancellations === 1 && second.cancellations === 1, "both overlapping callers are canceled once")
        var third = root.request("third")
        root.check(!root.begin(third), "a fresh request is admitted after overlap")
        var fourth = root.request("fourth")
        root.check(root.begin(fourth), "several arrivals in one event turn cannot strand a flow")
        root.check(root.cancellations.slice(-2).join(",") === "fourth,third", "repeated overlap retains cancellation order")

        var completed = root.request("completed")
        root.check(!root.begin(completed), "normal request is admitted")
        completed.isCompleted = true
        var active = root.request("active")
        root.check(!root.begin(active), "completed requests do not reject their successor")
        root.check(completed.cancellations === 0, "successful requests are never canceled")
        root.gate.blocked = true
        root.check(active.cancellations === 1, "locking cancels the active flow synchronously")
        root.gate.rejectBlockedRequest()
        root.check(active.cancellations === 1, "repeated checks do not cancel a completed flow again")

        root.lockedRequest = root.request("locked")
        root.gate.flow = root.lockedRequest
      } else if (root.stage === 1) {
        root.check(root.lockedRequest.cancellations === 1, "a new flow while already locked is canceled by the deferred guard")
        root.gate.blocked = false
        var fresh = root.request("fresh")
        root.check(!root.begin(fresh), "unlock permits a fresh authorization")
        root.check(fresh.cancellations === 0, "unlock does not cancel or replay old flows")
      } else {
        root.gate.destroy()
        result.setText(JSON.stringify({ok: root.failures.length === 0, failures: root.failures}))
        stop()
      }
      root.stage += 1
    }
  }

  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }
}
