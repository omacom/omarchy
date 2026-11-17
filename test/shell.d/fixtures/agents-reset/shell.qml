import QtQuick
import Quickshell
import "Agents" as Agents

ShellRoot {
  id: root
  property var failures: []
  property double deadline: Date.now() + 60000

  function check(value, message) {
    if (!value) failures.push(message)
  }

  property var first
  property var second
  Component { id: mainComponent; Agents.Main {} }
  Component.onCompleted: {
    first = mainComponent.createObject(root, { settings: { notifyOnLimitReset: true } })
    second = mainComponent.createObject(root, { settings: { notifyOnLimitReset: true } })
  }

  function records() {
    return [{ record: { id: "codex", name: "Codex", limits: [
      { label: "Session", resetsAt: new Date(deadline).toISOString() }
    ] } }]
  }

  Timer {
    interval: 200
    running: true
    onTriggered: {
      first.agents = root.records()
      second.agents = root.records()
      first.recordsChanged()
      second.recordsChanged()
      root.check(Agents.LimitResetNotifier.clients.length === 2, "two widgets share one notifier")
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 1, "one pending queue")
      var owner = Agents.LimitResetNotifier.owner
      owner.settings = { notifyOnLimitReset: "false" }
      root.check(!owner.limitResetNotificationsEnabled(), "plain CLI false disables notifications")
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 0, "disabling clears the queue")
      owner.settings = { notifyOnLimitReset: "true" }
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 1, "re-enabling queues current records immediately")
      owner.settings = { notifyOnLimitReset: true, providers: { codex: { enabled: false } } }
      Agents.LimitResetNotifier.announcePassedLimitResets()
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 0, "disabled provider drops queued reset")
      owner.settings = { notifyOnLimitReset: true, providers: { codex: { enabled: true } } }
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 1, "provider re-enable queues current records")
      owner.destroy()
      Qt.callLater(function() {
        root.check(Agents.LimitResetNotifier.owner !== owner, "another monitor takes over when its owner is destroyed")
        root.check(Agents.LimitResetNotifier.clients.length === 1, "destroyed widget unregisters itself")
        root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 1, "handover preserves queue")
        // The timer must pick up an earlier deadline after ownership changes.
        root.deadline = Date.now() + 250
        Agents.LimitResetNotifier.owner.agents = root.records()
        Agents.LimitResetNotifier.owner.recordsChanged()
        finish.start()
      })
    }
  }

  Timer {
    id: finish
    interval: 2000
    onTriggered: {
      root.check(Object.keys(Agents.LimitResetNotifier.pendingLimitResets).length === 0, "new deadline fires without a manual refresh")
      Agents.LimitResetNotifier.announcePassedLimitResets()
      console.log("RESULT " + JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
      Qt.quit()
    }
  }
}
