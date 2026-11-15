import QtQuick

QtObject {
  property bool blocked: true
  property var flow: null

  signal rejected()

  function rejectBlockedRequest() {
    if (!blocked) return false
    if (flow) {
      console.log("omarchy polkit request rejected: session locked or lock state unavailable")
      flow.cancelAuthenticationRequest()
    }
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
