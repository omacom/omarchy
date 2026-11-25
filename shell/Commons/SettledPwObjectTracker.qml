import QtQuick
import Quickshell.Services.Pipewire

// A PwObjectTracker that takes its list one event-loop turn after `objects`
// changes, instead of inside the change itself.
//
// After a PipeWire error (a failed Bluetooth audio transport, a daemon
// restart), Quickshell's PwRegistry::reset() destroys the registry proxy and
// then deletes the nodes one by one. Each deletion updates Pipewire.nodes and
// re-runs the bindings built on it, so a tracker bound straight to such a list
// is handed a new one mid-teardown and refs every entry. Ref'ing a node that is
// not bound yet binds it through the destroyed registry, which segfaults the
// shell (#15838). Settling first lets the teardown finish; meanwhile the
// tracker drops each dying node itself, through its own destroyed connection.
QtObject {
  id: root

  property var objects: []

  function settle() {
    var list = []
    var source = root.objects || []
    for (var i = 0; i < source.length; i++)
      if (source[i]) list.push(source[i])
    root.tracker.objects = list
  }

  onObjectsChanged: root.settleTimer.restart()
  Component.onCompleted: settle()

  readonly property Timer settleTimer: Timer {
    interval: 0
    repeat: false
    onTriggered: root.settle()
  }

  readonly property PwObjectTracker tracker: PwObjectTracker {}
}
