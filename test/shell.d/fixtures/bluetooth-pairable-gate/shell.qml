import QtQuick
import Quickshell
import "bluetooth" as BluetoothPlugin

ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // Stands in for Bluetooth.defaultAdapter: BlueZ brings it up pairable, and
  // quickshell applies a write to the property at once.
  QtObject {
    id: fake
    property bool pairable: true
    property int writes: 0
    onPairableChanged: writes += 1
  }

  // Bar widget instances share the one adapter. Each sees the others as
  // siblings the way Panel.qml's heldSibling does, by whether they hold
  // pairing, over one list so every instance computes the same answer.
  function otherHeld(self) {
    var holders = [gateA, gateB, extra.item]
    for (var i = 0; i < holders.length; i++) {
      var holder = holders[i]
      if (!holder) continue
      if (holder.gate === undefined ? holder !== self && holder.open : holder.gate !== self && holder.held) return true
    }
    return false
  }

  BluetoothPlugin.PairableGate {
    id: gateA
    adapter: null
    open: false
    siblingOpen: function() { return test.otherHeld(gateA) }
  }

  BluetoothPlugin.PairableGate {
    id: gateB
    adapter: null
    open: false
    siblingOpen: function() { return test.otherHeld(gateB) }
  }

  // A third instance that comes and goes, as a monitor's widget does. Like the
  // panel, it is created closed, drops its hold as it is torn down (the
  // parent's destruction runs before the gate's), and opens afterwards.
  Loader {
    id: extra
    active: false
    sourceComponent: Item {
      id: extraPanel
      property bool open: false
      property bool destroying: false
      readonly property bool held: !destroying && open
      readonly property var gate: extraGate
      Component.onDestruction: destroying = true
      BluetoothPlugin.PairableGate {
        id: extraGate
        adapter: fake
        open: extraPanel.held
        siblingOpen: function() { return test.otherHeld(extraGate) }
      }
    }
  }

  // Panel.qml creates one gate per controller through an Instantiator over
  // Bluetooth.adapters.values. The same shape here, over a list of stand-ins
  // that changes while pairing is held, as it does when a dongle is plugged in.
  QtObject { id: fake2; property bool pairable: true; property int writes: 0; onPairableChanged: writes += 1 }
  QtObject { id: fake3; property bool pairable: true; property int writes: 0; onPairableChanged: writes += 1 }
  QtObject { id: fake4; property bool pairable: true; property int writes: 0; onPairableChanged: writes += 1 }
  property var adapters: []

  Item {
    id: multiPanel
    property bool open: false
    property bool destroying: false
    readonly property bool held: !destroying && open
    Instantiator {
      model: test.adapters
      delegate: BluetoothPlugin.PairableGate {
        adapter: modelData
        open: multiPanel.held
        siblingOpen: function() { return false }
      }
    }
  }

  property int step: 0
  Timer {
    interval: 200
    running: true
    repeat: true
    onTriggered: {
      step += 1
      switch (step) {
      case 1:
        // No adapter yet: nothing to write and nothing to crash on.
        test.check(fake.pairable === true && fake.writes === 0, "a missing adapter is left alone")
        gateA.adapter = fake
        gateB.adapter = fake
        break
      case 2:
        // The adapter arrived pairable with every panel closed.
        test.check(fake.pairable === false && fake.writes === 1, "a late adapter is turned off while the panels are closed, writes " + fake.writes)
        gateA.open = true
        break
      case 3:
        test.check(fake.pairable === true && fake.writes === 2, "opening a panel turns pairing on, writes " + fake.writes)
        gateB.open = true
        break
      case 4:
        test.check(fake.pairable === true && fake.writes === 2, "a second open panel writes nothing, writes " + fake.writes)
        gateA.open = false
        break
      case 5:
        // B still holds it; A's close must not take it down or fight B.
        test.check(fake.pairable === true && fake.writes === 2, "pairing stays on for the panel still holding it, writes " + fake.writes)
        gateB.open = false
        break
      case 6:
        test.check(fake.pairable === false && fake.writes === 3, "pairing goes off once the last panel lets go, writes " + fake.writes)
        fake.pairable = true
        break
      case 7:
        // BlueZ reported it on behind the shell's back: one write puts it back.
        test.check(fake.pairable === false && fake.writes === 5, "pairing turned on behind the shell's back is turned off again, writes " + fake.writes)
        extra.active = true
        break
      case 8:
        test.check(fake.pairable === false && fake.writes === 5, "a new closed instance writes nothing, writes " + fake.writes)
        extra.item.open = true
        break
      case 9:
        test.check(fake.pairable === true && fake.writes === 6, "a new instance holding pairing turns it on, writes " + fake.writes)
        extra.active = false
        break
      case 10:
        test.check(fake.pairable === false && fake.writes === 7, "a destroyed instance turns pairing off when nothing else holds it, writes " + fake.writes)
        gateA.open = true
        extra.active = true
        break
      case 11:
        test.check(fake.pairable === true && fake.writes === 8, "a holder and a new closed instance write once, writes " + fake.writes)
        extra.item.open = true
        break
      case 12:
        test.check(fake.pairable === true && fake.writes === 8, "a second holder writes nothing, writes " + fake.writes)
        extra.active = false
        break
      case 13:
        test.check(fake.pairable === true && fake.writes === 8, "a destroyed instance leaves pairing on for a sibling holding it, writes " + fake.writes)
        test.adapters = [fake2, fake3]
        break
      case 14:
        test.check(fake2.pairable === false && fake3.pairable === false && fake2.writes === 1 && fake3.writes === 1, "a gate per controller turns each one off, writes " + fake2.writes + " " + fake3.writes)
        multiPanel.open = true
        break
      case 15:
        test.check(fake2.pairable === true && fake3.pairable === true && fake2.writes === 2 && fake3.writes === 2, "opening turns every controller on, writes " + fake2.writes + " " + fake3.writes)
        test.adapters = [fake2, fake3, fake4]
        break
      case 16:
        // The old gates are replaced while their panel still holds: they leave
        // the write to their successors, so nothing flaps and the new
        // controller is simply found already on.
        test.check(fake2.pairable === true && fake3.pairable === true && fake4.pairable === true, "a controller appearing while held leaves every controller on")
        test.check(fake2.writes === 2 && fake3.writes === 2 && fake4.writes === 0, "rebuilding the gates while held writes nothing, writes " + fake2.writes + " " + fake3.writes + " " + fake4.writes)
        multiPanel.open = false
        break
      case 17:
        test.check(fake2.pairable === false && fake3.pairable === false && fake4.pairable === false && fake2.writes === 3 && fake3.writes === 3 && fake4.writes === 1, "closing turns every controller off, writes " + fake2.writes + " " + fake3.writes + " " + fake4.writes)
        if (!test.failed) console.log("RESULT pass")
        Qt.quit()
        break
      }
    }
  }
}
