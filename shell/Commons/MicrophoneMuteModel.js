// PulseAudio source snapshots include physical and virtual inputs, and output
// monitors. A monitor captures playback and is not a microphone mute target.
function parseSources(text) {
  try {
    var values = JSON.parse(text)
    if (!Array.isArray(values)) return null
    var sources = []
    for (var i = 0; i < values.length; i++) {
      var value = values[i]
      if (value.monitor_source || (value.properties && value.properties["device.class"] === "monitor")) continue
      if (value.monitor_of_sink !== null && value.monitor_of_sink !== undefined && value.monitor_of_sink !== 4294967295) continue
      if (typeof value.name !== "string" || !value.name || typeof value.mute !== "boolean") return null
      sources.push({ name: value.name, muted: value.mute })
    }
    return sources
  } catch (e) {
    return null
  }
}

function allMuted(sources) {
  return sources.length > 0 && sources.every(function(source) { return source.muted })
}

if (typeof module !== "undefined") module.exports = { parseSources: parseSources, allMuted: allMuted }
