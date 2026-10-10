// Output volume on the linear or decibel scale picked in the audio panel.
// PipeWire's volume is cubic, so its gain is 60·log10(volume): 100% is 0 dB.
// On the decibel scale, the floor and anything below it is silence.
var floor = -60

function scale(config) {
  return config && config.audio && config.audio.volumeScale === "decibel" ? "decibel" : "linear"
}

function clamp(value) {
  return Math.max(0, Math.min(1, value))
}

function decibels(volume) {
  return 60 * Math.log10(volume)
}

function fromDecibels(db) {
  // The margin absorbs backend rounding at the floor.
  return db <= floor + 0.01 ? 0 : Math.pow(10, db / 60)
}

// A slider position in 0..1, linear in dB on the decibel scale.
function position(volume, scale) {
  if (scale !== "decibel") return clamp(volume)
  return clamp(1 - decibels(volume) / floor)
}

function volume(position, scale) {
  if (scale !== "decibel") return clamp(position)
  return fromDecibels((1 - clamp(position)) * floor)
}

// Steps are 5% or 2 dB, 1% or 0.5 dB precise, by omarchy-audio-output-volume's
// rules: linear steps land on whole percents, and a boosted output steps down
// from where it is but never up past 100%.
function step(volume, steps, scale, precise) {
  var next = scale === "decibel"
    ? fromDecibels(Math.max(decibels(volume), floor) + steps * (precise ? 0.5 : 2))
    : (Math.round(volume * 100) + steps * (precise ? 1 : 5)) / 100
  return Math.max(0, steps > 0 ? Math.min(next, 1) : next)
}

function readout(volume, scale) {
  if (scale !== "decibel") return Math.round(volume * 100) + "%"
  return volume > 0 ? decibels(volume).toFixed(1) + " dB" : "Silent"
}

if (typeof module !== "undefined") {
  module.exports = { scale: scale, position: position, volume: volume, step: step, readout: readout }
}
