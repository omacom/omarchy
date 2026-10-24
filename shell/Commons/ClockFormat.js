function configuredClockFormat(settings, vertical) {
  var value = settings ? settings[vertical ? "verticalFormat" : "format"] : undefined
  return value === undefined || value === null
    ? (vertical ? "HH\n—\nmm" : "dddd HH:mm") : String(value)
}

function compactTimeFormat(format) {
  var tokens = String(format || "").replace(/'[^']*'?/g, "")
  var period = tokens.match(/[Aa][Pp]?/)
  return period && !/H/.test(tokens) ? "h:mm " + period[0] : "HH:mm"
}

if (typeof module !== "undefined") {
  module.exports = { configuredClockFormat: configuredClockFormat, compactTimeFormat: compactTimeFormat }
}
