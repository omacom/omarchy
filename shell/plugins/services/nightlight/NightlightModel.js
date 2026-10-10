// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold.
var IDENTITY_TEMPERATURE = 6000
var DEFAULT_NIGHT_TEMPERATURE = 4000

function configuredNightTemperature(value) {
  var temperature = Number(value)
  if (!Number.isFinite(temperature) || !Number.isInteger(temperature) || temperature < 1000 || temperature >= IDENTITY_TEMPERATURE)
    return DEFAULT_NIGHT_TEMPERATURE
  return temperature
}

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

function isNightlight(temperature) {
  return temperature !== null && temperature !== undefined && temperature < IDENTITY_TEMPERATURE
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    DEFAULT_NIGHT_TEMPERATURE: DEFAULT_NIGHT_TEMPERATURE,
    configuredNightTemperature: configuredNightTemperature,
    temperatureFromOutput: temperatureFromOutput,
    isNightlight: isNightlight
  }
}
