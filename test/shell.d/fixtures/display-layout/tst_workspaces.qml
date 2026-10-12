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
      var dropdown = findChild(assignments, "workspace-owner-1")
      verify(dropdown !== null)
      dropdown.open()
      wait(50)
      keyClick(Qt.Key_Down)
      keyClick(Qt.Key_Return)
      compare(assignments.workspaces[0].monitor, "DP-1")
      compare(assignments.transfer.to, "DP-2")
      compare(dropdown.value, "DP-1", "unconfirmed selection still shows actual owner")
      assignments.transfer = null
      compare(assignments.workspaces[0].monitor, "DP-1", "cancel preserves owner")
      compare(dropdown.value, "DP-1", "cancel preserves displayed owner")
      assignments.requestAssignment(1, "DP-2")
      assignments.confirmTransfer()
      compare(assignments.workspaces.length, 1)
      compare(assignments.workspaces[0].monitor, "DP-2")
      compare(assignments.transfer, null)
      compare(dropdown.value, "DP-2", "confirmed owner updates binding")
      assignments.workspaces = [{id: 1, monitor: "DP-1"}]
      compare(dropdown.value, "DP-1", "subsequent state refresh updates binding")
    }
  }
}
