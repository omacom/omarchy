// Keep every top-level window on this workspace, without depending on the
// dock's pinned apps, grouping preference, or desktop-entry matching.
function windowsOnWorkspace(toplevels, workspaceId) {
  return (toplevels || []).filter(function(window) {
    return window.wayland && !window.wayland.parent && window.workspace
      && Number(window.workspace.id) === workspaceId
  })
}

function selectionAfterChange(previous, selected, windows) {
  if (!windows.length) return -1
  var address = previous[selected] ? previous[selected].address : null
  for (var i = 0; i < windows.length; i++) {
    if (windows[i].address === address) return i
  }
  return Math.max(0, Math.min(selected, windows.length - 1))
}

function moveSelection(selected, step, count) {
  return count > 0 ? ((selected + step) % count + count) % count : -1
}

if (typeof module !== "undefined") module.exports = { windowsOnWorkspace: windowsOnWorkspace, selectionAfterChange: selectionAfterChange, moveSelection: moveSelection }
