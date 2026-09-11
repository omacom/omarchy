import QtQuick
import Quickshell.Io

// Host presentation for authenticated Ward decisions. Worker notification
// grants and worker-provided messages cannot synthesize this signal.
QtObject {
  id: root
  required property var manager
  property double windowStarted: 0
  property int delivered: 0
  property var lastEvent: null
  property Connections events: Connections {
    target: root.manager
    function onBlocked(pluginId, action) { root.report(pluginId, action) }
  }

  function description(action) {
    const actions = {
      1: "tried to send a notification without permission",
      2: "tried to change a setting outside its approved permissions",
      3: "tried to open a link without permission",
      4: "made an HTTP request outside its approved permissions",
      5: "tried to run a command outside its approved permissions"
    }
    return actions[action] || ""
  }

  function report(id, action) {
    if (!/^[A-Za-z0-9][A-Za-z0-9._-]{0,95}$/.test(id) || id.indexOf("..") !== -1) return false
    const detail = description(action)
    if (!detail) return false
    const now = Date.now()
    lastEvent = {id: id, action: action, timestamp: now}
    // Also bound the desktop-wide notification rate across plugin sessions.
    if (now - windowStarted >= 30000) { windowStarted = now; delivered = 0 }
    if (delivery.running || delivered >= 2) return false
    delivered++
    delivery.command = ["timeout", "2s", "omarchy-notification-send", "--app-name", "Omarchy Ward",
      "-u", "normal", "-t", "6000", "Ward blocked a request", id + " " + detail + "."]
    delivery.running = true
    return true
  }

  property Process delivery: Process {}
}
