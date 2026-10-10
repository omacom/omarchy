.pragma library

// Shared by every network panel in the shell, including newly added screens.
var connection = ""
var launched = false

function claimAutomatic(key, connectivity, enabled) {
  if (connection !== key || connectivity === "none" || connectivity === "full") {
    connection = key
    launched = false
  }
  if (!key || connectivity !== "portal" || !enabled || launched) return false
  launched = true
  return true
}

function markOpened(key) {
  connection = key
  launched = true
}
