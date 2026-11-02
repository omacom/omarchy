import QtQuick

// The pairing agent in default/systemd/user/bt-agent.service answers every
// incoming pairing request without asking, so a nearby device must only be
// able to bond while someone is at the Bluetooth panel, or a pairing started
// from this machine is under way. BlueZ brings adapters up pairable with no
// timeout and nothing else in Omarchy touches the property, so this owns it:
// on while held, off the rest of the time, including right after login and
// when the adapter appears later.
//
// quickshell applies a pairable write to adapter.pairable at once and sends
// the D-Bus Set behind it, so the property reads as the requested state, a
// write never needs a retry, and a change BlueZ reports (a late adapter, or a
// `bluetoothctl pairable on` behind the shell's back) arrives as a change to
// react to. A Set that BlueZ refuses is only logged by quickshell and leaves
// the property reading the requested value, so that case is not recovered.
Item {
  id: gate

  visible: false

  // Bluetooth.defaultAdapter, or a stand-in with a writable pairable property.
  property var adapter: null
  // True while this instance needs pairing possible.
  property bool open: false
  // One widget instance exists per monitor and they share the default adapter,
  // so a closing instance leaves pairing on for another instance that holds it.
  property var siblingOpen: function() { return false }

  // Every instance must compute the same answer, or two of them write each
  // other's value back forever; the panel's heldSibling reads one shared list
  // for that. The guard keeps a write's own change notification from
  // re-entering here, so even a disagreement cannot recurse.
  property bool applying: false

  function apply() {
    if (adapter === null || applying) return
    applying = true
    var wanted = open || siblingOpen()
    if (adapter.pairable !== wanted) adapter.pairable = wanted
    applying = false
  }

  onOpenChanged: apply()
  onAdapterChanged: apply()
  Component.onCompleted: apply()

  Connections {
    target: gate.adapter
    ignoreUnknownSignals: true
    function onPairableChanged() { gate.apply() }
  }

  // A destroyed instance is no longer counted among the siblings, so it turns
  // pairing off itself when it was the last one holding it. One replaced while
  // its panel still holds (a controller appeared, and the gates were rebuilt)
  // leaves that to its successor.
  Component.onDestruction: {
    if (adapter !== null && adapter.pairable === true && !open && !siblingOpen()) adapter.pairable = false
  }
}
