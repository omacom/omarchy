// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold and
// reads the same nightlight.temperature setting.
var IDENTITY_TEMPERATURE = 6000
var DEFAULT_NIGHT_TEMPERATURE = 4000
// hyprsunset rejects anything below 1000K
var MIN_TEMPERATURE = 1000

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

function isNightlight(temperature) {
  return temperature !== null && temperature !== undefined && temperature < IDENTITY_TEMPERATURE
}

// A night temperature at or above the identity point would read back as off,
// so the toggle could never turn it off again.
function nightTemperatureFromConfig(value) {
  if (typeof value !== "number" || Math.floor(value) !== value) return DEFAULT_NIGHT_TEMPERATURE
  if (value < MIN_TEMPERATURE || value >= IDENTITY_TEMPERATURE) return DEFAULT_NIGHT_TEMPERATURE
  return value
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    temperatureFromOutput: temperatureFromOutput,
    isNightlight: isNightlight,
    nightTemperatureFromConfig: nightTemperatureFromConfig
  }
}
