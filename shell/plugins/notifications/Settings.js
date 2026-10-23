// Notification preferences from the `notifications` object in shell.json.
// Every key is optional; a missing or invalid value falls back to its default.
.pragma library

var DEFAULTS = {
  displayMode: "active",
  displayName: "",
  fullscreenOverlay: "all",
  historyHours: 24
}

function oneOf(value, options, fallback) {
  return options.indexOf(value) >= 0 ? value : fallback
}

function resolve(raw) {
  var given = raw !== null && typeof raw === "object" && !Array.isArray(raw) ? raw : {}
  var d = DEFAULTS
  return {
    displayMode: oneOf(given.displayMode, ["active", "specific", "all"], d.displayMode),
    displayName: typeof given.displayName === "string" ? given.displayName.slice(0, 128) : d.displayName,
    fullscreenOverlay: oneOf(given.fullscreenOverlay, ["off", "all"], d.fullscreenOverlay),
    historyHours: oneOf(Number(given.historyHours), [0, 1, 24, 168], d.historyHours)
  }
}
