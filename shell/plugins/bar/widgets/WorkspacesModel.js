// The layout cycle for the workspaces widget, kept Qt-free so it can be unit
// tested under node (test/shell.d/hyprland-workspace-layout-test.sh).

// What omarchy-hyprland-workspace-layout-cycle accepts. The file it writes can
// still be edited by hand, so what is read back is checked here as well.
var modes = ["dwindle", "scrolling", "floating"]

// A layout named twice would stop the cycle on that layout twice, so repeats are
// kept once. A file naming no layout the cycle can hold means every layout,
// which is what no file at all means too.
function parseCycle(text) {
  var cycle = []

  String(text === undefined || text === null ? "" : text).split(/\s+/).forEach(function (word) {
    if (modes.indexOf(word) !== -1 && cycle.indexOf(word) === -1) cycle.push(word)
  })

  return cycle.length > 0 ? cycle : modes.slice()
}

// A press on the mark for a workspace changes its layout when the cycle names
// another layout to move to, or when the one layout it names is not the layout
// on screen: that press brings the workspace into the cycle, which is the way
// back out of a layout the cycle no longer holds.
function canChange(cycle, mode) {
  if (!Array.isArray(cycle) || cycle.length === 0) return false
  return cycle.length > 1 || cycle[0] !== mode
}

if (typeof module !== "undefined") {
  module.exports = {
    modes: modes,
    parseCycle: parseCycle,
    canChange: canChange
  }
}
