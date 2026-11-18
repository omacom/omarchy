pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons
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
      function(id) { return owner.providerEnabled(id) },
      function(key) { return Commons.I18n.t(key) }
    )
    pendingLimitResets = result.pending
    for (var i = 0; i < result.notifications.length; i++) {
      var notification = result.notifications[i]
      Quickshell.execDetached(["omarchy-notification-send", "--app-name", "Omarchy Agents",
        notification.title, notification.body])
    }
  }

  onPendingLimitResetsChanged: {
    deadlineTimer.stop()
    var earliest = Infinity
    for (var key in pendingLimitResets)
      earliest = Math.min(earliest, pendingLimitResets[key].deadline)
    if (isFinite(earliest)) {
      // QML intervals are signed 32-bit milliseconds. A distant deadline
      // re-arms for the remaining time when the first interval expires.
      deadlineTimer.interval = Math.max(1, Math.min(2147483647, earliest - Date.now()))
      deadlineTimer.start()
    }
  }

  // A relative Qt timer pauses during suspend. On resume, compare the
  // stored wall-clock deadlines again, even if no usage file changed.
  Process {
    running: Object.keys(root.pendingLimitResets).length > 0
    command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1",
      "--object-path", "/org/freedesktop/login1"]
    stdout: SplitParser {
      onRead: line => {
        if (line.trim().endsWith("org.freedesktop.login1.Manager.PrepareForSleep (false,)"))
          root.announcePassedLimitResets()
      }
    }
  }

  Timer {
    id: deadlineTimer
    onTriggered: root.announcePassedLimitResets()
  }
}
