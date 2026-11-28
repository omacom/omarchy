pragma Singleton
import QtQuick
import Quickshell

// Holds that omarchy-bluetooth-device takes over IPC for the pairings it runs.
// The Bluetooth bar widget turns the adapters' Pairable property on while a
// hold is live, so a Low Energy device bonds even with every panel closed.
// Kept here rather than on a widget instance: the instance that answered the
// IPC call can go away with its monitor before the pairing finishes, and the
// widgets left on screen must still see the hold.
Singleton {
  id: root

  // One token per hold, so a command releases only the hold it took and two
  // pairings at once cannot release each other. A command whose hold request
  // got no answer has no token and leaves its hold to the expiry below.
  property var tokens: []
  readonly property int holds: tokens.length

  function hold() {
    var token = ""
    for (var i = 0; i < 4; i++) token += Math.floor(Math.random() * 0x100000000).toString(16).padStart(8, "0")
    tokens = tokens.concat([token])
    expiry.restart()
    return token
  }

  function release(token) {
    var index = tokens.indexOf(String(token || ""))
    if (index === -1) return "unknown"
    tokens = tokens.slice(0, index).concat(tokens.slice(index + 1))
    if (tokens.length === 0) expiry.stop()
    return "ok"
  }

  // A pairing that dies without releasing its hold must not leave pairing on.
  Timer {
    id: expiry
    interval: 90000
    repeat: false
    onTriggered: root.tokens = []
  }
}
