import QtQuick
import QtTest
Item {
  width: 900; height: 720
  WorkspaceAssignments {
    id: assignments
    anchors.fill: parent
    displays: [{name: "DP-1"}, {name: "DP-2"}]
    workspaces: [{id: 1, monitor: "DP-1"}]
    onAssignmentsChanged: function(next) { workspaces = next }
  }
  TestCase {
    name: "WorkspaceAssignments"; when: windowShown
    function test_transfer_requires_confirmation() {
      assignments.requestAssignment(1, "DP-2")
      compare(assignments.workspaces[0].monitor, "DP-1")
      compare(assignments.transfer.to, "DP-2")
      assignments.transfer = null
      compare(assignments.workspaces[0].monitor, "DP-1", "cancel preserves owner")
      assignments.requestAssignment(1, "DP-2")
      assignments.confirmTransfer()
      compare(assignments.workspaces.length, 1)
      compare(assignments.workspaces[0].monitor, "DP-2")
      compare(assignments.transfer, null)
    }
  }
}
