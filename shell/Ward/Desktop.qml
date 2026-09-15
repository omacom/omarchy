pragma Singleton

import QtQuick
import Quickshell

// Same detached read interface as the worker adapter. The root host injects
// its one observer; importing this module does not create another observer.
QtObject {
  id: root
  property var source: null
  readonly property bool granted: true
  readonly property bool available: source !== null && source.snapshot !== null
  readonly property var toplevels: ({ values: available ? source.snapshot.windows.map(window => ({
    address: String(window.id),
    workspace: window.workspace === null ? null : {id: window.workspace},
    lastIpcObject: {
      at: [window.rect.x, window.rect.y], size: [window.rect.width, window.rect.height],
      mapped: window.mapped, hidden: window.hidden, fullscreen: window.fullscreen
    }
  })) : [] })
  signal changed()
  onToplevelsChanged: changed()

  function monitorFor(screen) {
    if (!available || !screen || !Quickshell.screens.some(candidate => candidate === screen)) return null
    const snapshot = source.forScreen(screen)
    const output = snapshot ? snapshot.outputs.find(output => output.id === snapshot.viewport) : null
    if (!output) return null
    return {
      id: output.id, x: output.rect.x, y: output.rect.y,
      width: output.rect.width, height: output.rect.height, scale: output.scale,
      activeWorkspace: output.activeWorkspaces.length ? {id: output.activeWorkspaces[0]} : null,
      lastIpcObject: {reserved: output.reserved.slice()}
    }
  }
}
