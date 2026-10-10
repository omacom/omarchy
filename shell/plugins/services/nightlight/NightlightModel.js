// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold.
var IDENTITY_TEMPERATURE = 6000

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

function isNightlight(temperature) {
  return temperature !== null && temperature !== undefined && temperature < IDENTITY_TEMPERATURE
}

// Starts this user's hyprsunset if needed, then applies the temperature.
// Another user's hyprsunset belongs to their Hyprland session, so only a
// process owned by this user counts as running.
function applyCommand(temperature) {
  return ["bash", "-lc",
    "pgrep -u \"$USER\" -x hyprsunset >/dev/null || { setsid uwsm-app -- hyprsunset >/dev/null 2>&1 & sleep 1; }; " +
    "hyprctl hyprsunset temperature " + Number(temperature)]
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    temperatureFromOutput: temperatureFromOutput,
    isNightlight: isNightlight,
    applyCommand: applyCommand
  }
}
