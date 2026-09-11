import QtQuick
import Quickshell
import Quickshell.Hyprland
import "PluginGeometry.js" as Geometry

// One trusted observer for all isolated plugins, never a worker import.
// Quickshell itself permits at most one in-flight refresh per model.
QtObject {
  id: root
  property bool active: false
  property var snapshot: null
  // Qt's WeakMap can retain invalid QObject keys after model removal and GC.
  // Keep strong keys only while their objects are present in the live models.
  property var identities: new Map()
  property int nextIdentity: 0
  property int tick: 0

  function identity(object) {
    if (!identities.has(object)) {
      if (nextIdentity >= 2147483647) throw new Error("geometry identity limit")
      identities.set(object, ++nextIdentity)
    }
    return identities.get(object)
  }

  function forScreen(screen) {
    if (!snapshot || !screen) return null
    const monitor = Hyprland.monitorFor(screen)
    if (!monitor || !identities.has(monitor)
      || !snapshot.outputs.some(output => output.id === identities.get(monitor))) return null
    return Object.assign({ viewport: identities.get(monitor) }, snapshot)
  }

  function refresh() {
    if (!active || !Hyprland.requestSocketPath) { snapshot = null; return }
    // Let Quickshell finish its initial model queries. Starting a non-creating
    // refresh first can suppress its initial creating query via the IPC guard.
    if (!Hyprland.monitors.values.some(monitor => monitor.lastIpcObject.name !== undefined)) { snapshot = null; return }
    Hyprland.refreshToplevels()
    if (tick++ % 10 === 0) {
      Hyprland.refreshMonitors()
      Hyprland.refreshWorkspaces()
    }
    const outputs = Quickshell.screens.map(screen => ({screen: screen, monitor: Hyprland.monitorFor(screen)}))
    const workspaces = Hyprland.workspaces.values
    const windows = Hyprland.toplevels.values
    const live = outputs.map(output => output.monitor).concat(workspaces, windows)
    for (const object of identities.keys()) {
      if (live.indexOf(object) === -1) identities.delete(object)
    }
    const next = Geometry.snapshot(outputs, workspaces, windows, identity)
    if (JSON.stringify(next) !== JSON.stringify(snapshot)) snapshot = next
  }

  onActiveChanged: { tick = 0; refresh() }
  property Timer poll: Timer { interval: 100; repeat: true; running: root.active; onTriggered: root.refresh() }
}
