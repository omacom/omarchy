pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Explicit read-only compatibility view, not Quickshell.Hyprland. Both files
// are controller-authored, read-only mounts. No compositor socket is opened.
QtObject {
  id: root
  readonly property bool granted: permission.selected
  readonly property bool available: granted && context.snapshot !== null
  readonly property var toplevels: ({ values: available ? context.snapshot.windows.map(window => ({
    address: String(window.id),
    workspace: window.workspace === null ? null : { id: window.workspace },
    lastIpcObject: {
      at: [window.rect.x, window.rect.y], size: [window.rect.width, window.rect.height],
      mapped: window.mapped, hidden: window.hidden, fullscreen: window.fullscreen
    }
  })) : [] })

  // A notification to rebuild observations, not a raw compositor event log.
  signal changed()
  onToplevelsChanged: changed()

  function monitorFor(screen) {
    if (!available || !screen || !Quickshell.screens.some(candidate => candidate === screen)) return null
    // Association is stripped with the observation grant. Private names alone
    // confer presentation geometry, never windows or workspace observations.
    const privateId = /^ward-([1-9][0-9]*)$/.exec(screen.name)
    const observedId = privateId ? context.outputs[privateId[1]]
      : Quickshell.screens.length === 1 ? context.snapshot.viewport : null
    const output = context.snapshot.outputs.find(output => output.id === observedId)
    if (!output) return null
    return {
      id: output.id, x: output.rect.x, y: output.rect.y,
      width: output.rect.width, height: output.rect.height, scale: output.scale,
      activeWorkspace: output.activeWorkspaces.length ? { id: output.activeWorkspaces[0] } : null,
      lastIpcObject: { reserved: output.reserved.slice() }
    }
  }

  property FileView permission: FileView {
    property bool selected: false
    path: "/run/plugin/grants.json"
    onLoaded: selected = JSON.parse(text()).desktopGeometry === true
    onLoadFailed: selected = false
  }
  property FileView context: FileView {
    property var snapshot: null
    property var outputs: ({})
    path: "/context/state.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      const state = JSON.parse(text())
      const next = state.geometry || null
      outputs = state.geometryOutputs || {}
      if (JSON.stringify(next) !== JSON.stringify(snapshot)) snapshot = next
    }
    onLoadFailed: { snapshot = null; outputs = {} }
  }
}
