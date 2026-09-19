// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold.
var IDENTITY_TEMPERATURE = 6000

// Defaults for shell.json `nightlight.night` / `nightlight.day` (kelvin).
var DEFAULT_NIGHT_TEMPERATURE = 4000
var DEFAULT_DAY_TEMPERATURE = 6500
var MIN_TEMPERATURE = 1000
var MAX_TEMPERATURE = 20000

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

function temperatureFromConfig(value, fallback) {
  var temp = Number(value)
  if (!Number.isInteger(temp) || temp < MIN_TEMPERATURE || temp > MAX_TEMPERATURE) return fallback
  return temp
}

// Resolves the configured night/day pair; invalid or inverted values fall
// back to the defaults so a typo in shell.json cannot leave the toggle stuck.
function temperaturesFromConfig(config) {
  var source = config && typeof config === "object" ? config : {}
  var night = temperatureFromConfig(source.night, DEFAULT_NIGHT_TEMPERATURE)
  var day = temperatureFromConfig(source.day, DEFAULT_DAY_TEMPERATURE)
  if (night >= day) {
    night = DEFAULT_NIGHT_TEMPERATURE
    day = DEFAULT_DAY_TEMPERATURE
  }
  return { night: night, day: day }
}

// Night light is on when the screen is warmer than both the identity point
// and the configured day temperature, so a warm `day` baseline (for people
// who never want a blue screen) still reads as "off".
function isNightlight(temperature, dayTemperature) {
  if (temperature === null || temperature === undefined) return false
  var day = temperatureFromConfig(dayTemperature, IDENTITY_TEMPERATURE)
  return temperature < Math.min(IDENTITY_TEMPERATURE, day)
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    DEFAULT_NIGHT_TEMPERATURE: DEFAULT_NIGHT_TEMPERATURE,
    DEFAULT_DAY_TEMPERATURE: DEFAULT_DAY_TEMPERATURE,
    temperatureFromOutput: temperatureFromOutput,
    temperaturesFromConfig: temperaturesFromConfig,
    isNightlight: isNightlight
  }
}
