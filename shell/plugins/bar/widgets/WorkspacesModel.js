// Flash math for the workspace buttons (shell/plugins/bar/widgets/Workspaces.qml),
// kept Qt-free so it can be unit tested under node (test/shell.d/workspaces-model-test.sh).

// A workspace in need of attention pulses the button's opacity all the way down
// to this value, so the flash stays visible against a dimmed empty workspace.
var FLASH_MIN_OPACITY = 0.4

// Pulse step in each direction; a full flash cycle runs twice this long.
var FLASH_DIRECTION_MS = 400

// The resting opacity of a workspace button: full for the focused or occupied
// workspace, dimmed while empty and unused. This is the value the pulse walks
// to and from when a workspace demands attention.
function baseOpacity(occupied, focused) {
  return occupied || focused ? 1 : 0.5
}

// Whether the button should flash: the workspace has a window marked urgent
// (HyprlandWorkspace.urgent, which Quickshell clears once the workspace is
// focused) and the user is not looking at it. Treating a missing or undefined
// urgency source as "needs no attention" keeps old Quickshell builds quiet.
function shouldFlash(urgent, focused) {
  return urgent === true && !focused
}

if (typeof module !== "undefined") {
  module.exports = {
    FLASH_MIN_OPACITY: FLASH_MIN_OPACITY,
    FLASH_DIRECTION_MS: FLASH_DIRECTION_MS,
    baseOpacity: baseOpacity,
    shouldFlash: shouldFlash
  }
}