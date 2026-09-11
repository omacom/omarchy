// Pure projection of host observations. Never copy an IPC object wholesale.
// Incomplete/oversized observations are unavailable, not a truncated desktop.
function snapshot(outputs, workspaces, windows, identity) {
  try {
    if (!outputs.length || outputs.length > 32 || workspaces.length > 256 || windows.length > 256) return null
    const monitors = new Set(outputs.map(value => value.monitor))
    const spaces = new Set(workspaces)
    function reference(value, known) {
      if (value === null || value === undefined) return null
      if (!known.has(value)) throw new Error("incomplete geometry")
      return identity(value)
    }
    function number(value) {
      if (typeof value !== "number" || !Number.isFinite(value) || Math.abs(value) > 1048576)
        throw new Error("invalid geometry")
      return value
    }
    function extent(value) {
      value = number(value)
      if (value < 0 || value > 65536) throw new Error("invalid extent")
      return value
    }
    function rect(x, y, width, height) {
      return { x: number(x), y: number(y), width: extent(width), height: extent(height) }
    }
    function vector(value, length) {
      // Qt's QVariantList is an array-like sequence, not a JS Array.
      if (!value || typeof value !== "object" || value.length !== length) throw new Error("incomplete geometry vector")
      return Array.from(value)
    }
    const result = {
      outputs: outputs.map(value => {
        const screen = value.screen, monitor = value.monitor, ipc = monitor.lastIpcObject
        if (!ipc || !(monitor.scale >= 0.25 && monitor.scale <= 8) || screen.width <= 0 || screen.height <= 0)
          throw new Error("incomplete output geometry")
        const special = ipc.specialWorkspace && ipc.specialWorkspace.id !== 0
          ? workspaces.find(space => space.monitor === monitor && space.id === ipc.specialWorkspace.id) : null
        if (ipc.specialWorkspace && ipc.specialWorkspace.id !== 0 && !special) throw new Error("incomplete special workspace")
        const active = workspaces.filter(space => space.monitor === monitor
          && (space === monitor.activeWorkspace || space === special))
        if (monitor.activeWorkspace && !spaces.has(monitor.activeWorkspace)) throw new Error("incomplete workspace geometry")
        return {
          id: identity(monitor), rect: rect(monitor.x, monitor.y, screen.width, screen.height),
          scale: number(monitor.scale), reserved: vector(ipc.reserved, 4).map(extent),
          activeWorkspaces: active.map(identity)
        }
      }),
      workspaces: workspaces.map(space => ({id: identity(space), output: reference(space.monitor, monitors)})),
      windows: windows.map(window => {
        const ipc = window.lastIpcObject
        if (!ipc || typeof ipc.mapped !== "boolean" || typeof ipc.hidden !== "boolean" || typeof ipc.fullscreen !== "number")
          throw new Error("incomplete window geometry")
        const at = vector(ipc.at, 2), size = vector(ipc.size, 2)
        return {
          id: identity(window), workspace: reference(window.workspace, spaces),
          rect: rect(at[0], at[1], size[0], size[1]),
          mapped: ipc.mapped, hidden: ipc.hidden, fullscreen: ipc.fullscreen !== 0
        }
      })
    }
    // All emitted values are ASCII numbers/keys. Leave space for viewport ID.
    return JSON.stringify(result).length <= 48 * 1024 - 64 ? result : null
  } catch (_) { return null }
}
