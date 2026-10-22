// Notification preferences from the `notifications` object in shell.json.
// Every key is optional; a missing or invalid value falls back to its default.
.pragma library

var DEFAULTS = {
  displayMode: "active",
  displayName: "",
  fullscreenOverlay: "all",
  offerSnoozeWhenSharing: true,
  historyHours: 24
}

// The snooze choices, in minutes, and the hour "tomorrow" wakes at.
var SNOOZE_CHOICES = ["15", "60", "tomorrow"]
var WAKE_HOUR = 8

function oneOf(value, options, fallback) {
  return options.indexOf(value) >= 0 ? value : fallback
}

function flag(value, fallback) {
  return typeof value === "boolean" ? value : fallback
}

function resolve(raw) {
  var given = raw !== null && typeof raw === "object" && !Array.isArray(raw) ? raw : {}
  var d = DEFAULTS
  return {
    displayMode: oneOf(given.displayMode, ["active", "specific", "all"], d.displayMode),
    displayName: typeof given.displayName === "string" ? given.displayName.slice(0, 128) : d.displayName,
    fullscreenOverlay: oneOf(given.fullscreenOverlay, ["off", "all"], d.fullscreenOverlay),
    offerSnoozeWhenSharing: flag(given.offerSnoozeWhenSharing, d.offerSnoozeWhenSharing),
    historyHours: oneOf(Number(given.historyHours), [0, 1, 24, 168], d.historyHours)
  }
}

// Seconds a snooze choice lasts. "tomorrow" means the next wake hour.
function snoozeSeconds(choice, now) {
  var value = String(choice || "")
  if (value === "tomorrow") {
    var wake = new Date(now)
    wake.setDate(wake.getDate() + 1)
    wake.setHours(WAKE_HOUR, 0, 0, 0)
    return Math.round((wake.getTime() - now) / 1000)
  }
  var minutes = Number(value)
  return minutes > 0 ? Math.round(minutes * 60) : 0
}
