pragma Singleton

import QtQuick
import Quickshell
import "LimitResetModel.js" as LimitResetModel

Item {
  id: root
  visible: false

  property var clients: []
  readonly property var owner: clients.length > 0 ? clients[0] : null
  property var pendingLimitResets: ({})

  function register(client) {
    if (clients.indexOf(client) < 0) clients = clients.concat([client])
  }

  function unregister(client) {
    clients = clients.filter(function(value) { return value !== client })
  }

  onOwnerChanged: {
    if (owner) schedule(owner)
    else pendingLimitResets = ({})
  }

  function schedule(client) {
    if (!owner || client !== owner) return
    var records = []
    for (var i = 0; i < owner.agents.length; i++) {
      records.push(owner.agents[i] ? owner.agents[i].record : null)
    }
    // Discovery is authoritative for presence; delegates and their FileViews
    // can still be loading (or temporarily unreadable) during recordsChanged.
    for (var j = 0; j < owner.agentIds.length; j++) {
      records.push({ id: owner.agentIds[j] })
    }
    pendingLimitResets = LimitResetModel.schedule(
      pendingLimitResets, records, Date.now(),
      owner.limitResetNotificationsEnabled(),
      function(id) { return owner.providerEnabled(id) }
    )
  }

  function announcePassedLimitResets() {
    if (!owner) return
    var result = LimitResetModel.announce(
      pendingLimitResets, Date.now(), owner.limitResetNotificationsEnabled(),
      function(id) { return owner.providerEnabled(id) }
    )
    pendingLimitResets = result.pending
    for (var i = 0; i < result.notifications.length; i++) {
      var notification = result.notifications[i]
      Quickshell.execDetached(["omarchy-notification-send", "--app-name", "Omarchy Agents",
        notification.title, notification.body])
    }
  }

  Timer {
    interval: 15000
    running: root.owner !== null && root.owner.limitResetNotificationsEnabled()
    repeat: true
    onTriggered: root.announcePassedLimitResets()
    onRunningChanged: if (root.owner) root.schedule(root.owner)
  }
}
