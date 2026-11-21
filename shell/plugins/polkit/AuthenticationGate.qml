import QtQuick

QtObject {
  property bool blocked: true
  property var flow: null
  property var activeFlow: null

  signal rejected()

  function pending(request) {
    return request && !request.isCompleted && !request.isCancelled
  }

  function rejectBlockedRequest() {
    var current = flow
    var previous = activeFlow
    var overlap = pending(current) && pending(previous) && current !== previous
    if (!blocked && !overlap) {
      activeFlow = pending(current) ? current : null
      return false
    }
    activeFlow = null
    // Quickshell exposes only the newest request. Reject overlapping requests
    // before an older completion can discard that flow without canceling it.
    // Cancel the current flow first: completion clears Quickshell's active flow.
    if (pending(current)) current.cancelAuthenticationRequest()
    if (previous !== current && pending(previous)) previous.cancelAuthenticationRequest()
    rejected()
    return true
  }

  onBlockedChanged: {
    if (blocked) rejectBlockedRequest()
  }
  // A native flow can arrive while already blocked. Defer until Quickshell
  // has connected its completion handler; beginFlow also checks synchronously.
  onFlowChanged: Qt.callLater(rejectBlockedRequest)
}
