// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold.
var IDENTITY_TEMPERATURE = 6000

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

// `hyprctl hyprsunset identity get` answers true or false.
function identityFromOutput(output) {
  return String(output === undefined || output === null ? "" : output).trim() === "true"
}

// Off is the identity matrix, which leaves the temperature where it was.
function isNightlight(temperature, identity) {
  return !identity && temperature !== null && temperature !== undefined && temperature < IDENTITY_TEMPERATURE
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    temperatureFromOutput: temperatureFromOutput,
    identityFromOutput: identityFromOutput,
    isNightlight: isNightlight
  }
}
