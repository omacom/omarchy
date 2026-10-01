import QtQuick
import Quickshell
import Quickshell.Io
import "Agents" as Agents

ShellRoot {
  id: root
  property var failures: []
  property int phase: 0
  property int ticks: 0
  property var client
  readonly property string usageDir: Quickshell.env("XDG_STATE_HOME") + "/omarchy/agents/usage"

  function check(value, message) {
    if (!value) failures.push(message)
  }

  function pendingCount() {
    return Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length
  }

  function codexAgent() {
    for (var i = 0; i < client.agents.length; i++) {
      if (client.agents[i].agentId === "codex") return client.agents[i]
    }
    return null
  }

  Component { id: mainComponent; Agents.Main {} }
  Component.onCompleted: client = mainComponent.createObject(root)

  Process {
    id: mutation
    onExited: {
      if (root.phase === 2) root.client.rescanAgents()
    }
  }

  Timer {
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      root.ticks++
      if (root.ticks > 250) {
        root.failures.push("inventory lifecycle timed out at phase " + root.phase)
        root.phase = 4
      }
      if (root.phase === 0 && root.client.agents.length === 2 && root.pendingCount() === 2) {
        root.phase = 1
        // A still-listed file can fail to parse without being removed.
        mutation.command = ["bash", "-c", "printf invalid > \"$1\"", "inventory-test", root.usageDir + "/codex.json"]
        mutation.running = true
      } else if (root.phase === 1 && !mutation.running && root.codexAgent() && root.codexAgent().record === null) {
        root.check(root.pendingCount() === 2, "unreadable present record retains its deadline")
        var queued = Agents.LimitResetNotifier.pendingLimitResets
        for (var key in queued) {
          if (key.split("\n", 1)[0] === "codex") queued[key].deadline = Date.now() - 1
        }
        Agents.LimitResetNotifier.pendingLimitResets = queued
        root.phase = 2
        mutation.command = ["rm", root.usageDir + "/codex.json"]
        mutation.running = true
      } else if (root.phase === 2 && !mutation.running && root.client.agentIds.length === 1 && root.client.agents.length === 1) {
        root.check(root.pendingCount() === 1, "rescan removes the absent provider's already-due reset")
        var remaining = Agents.LimitResetNotifier.pendingLimitResets
        for (var remainingKey in remaining) {
          root.check(remainingKey.split("\n", 1)[0] === "codex-team", "shared-prefix provider survives removal")
        }
        Agents.LimitResetNotifier.announcePassedLimitResets()
        root.check(root.pendingCount() === 1, "announce retains only the live provider's future reset")
        // recordsChanged can observe a delegate population in transition.
        root.client.agents = []
        root.client.recordsChanged()
        root.check(root.pendingCount() === 1, "authoritative inventory survives a temporarily empty delegate view")
        root.client.rebuildAgents()
        root.phase = 3
        mutation.command = ["bash", "-c", "printf '%s' '{\"id\":\"codex-team\",\"limits\":[]}' > \"$1\"", "inventory-test", root.usageDir + "/codex-team.json"]
        mutation.running = true
      } else if (root.phase === 3 && !mutation.running && root.client.agents[0].record && root.client.agents[0].record.limits.length === 0) {
        root.check(root.pendingCount() === 1, "present record with empty limits retains its reset")
        root.phase = 4
      }
      if (root.phase === 4) {
        console.log("RESULT " + JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
        Qt.quit()
      }
    }
  }
}
