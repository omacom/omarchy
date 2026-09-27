.pragma library

// The Earth as one more city, whose day is 4.54 billion years long.
//
// The panel already draws a row as a name, a clock and a 24-hour strip. Give
// that row the whole planet and the clock reads a minute before midnight: not
// as a gimmick, but because at this scale that is the honest reading, and it
// is the only way to get the whole span into a line of a panel without
// cheating the arithmetic somewhere.
//
// The numbers that make it worth looking at, all of them consequences of the
// one division:
//
//   one hour   = 189 million years
//   one minute = 3.15 million years   - the entire genus Homo
//   one second = 52,500 years         - longer than every city ever built
//
// So all of recorded history is the last tenth of a second of the day, and
// the row's minute hand has not moved since before there were people to read
// it. Nothing here ticks. That is the point of it.
//
// Ages are the ICS chart (v2023/07), in millions of years before present, and
// they are the published boundaries rather than round numbers - 538.8 for the
// base of the Cambrian, not 540. `tests/deeptime_check.js` checks that every
// division is contiguous with its neighbours and nested inside its parent,
// which is the property a hand-typed table actually loses.

// The age of the Earth. Everything below is a fraction of this.
var AGE_MA = 4540

// Eons. The four bands the strip is drawn in - and, conveniently, four bands
// wide enough to see at the width of a panel: the shortest, the Phanerozoic,
// is still 12% of the day.
var EONS = [
  { name: "Hadean",       from: 4540,  to: 4031 },
  { name: "Archean",      from: 4031,  to: 2500 },
  { name: "Proterozoic",  from: 2500,  to: 538.8 },
  { name: "Phanerozoic",  from: 538.8, to: 0 }
]

var ERAS = [
  { name: "Eoarchean",         from: 4031,  to: 3600 },
  { name: "Paleoarchean",      from: 3600,  to: 3200 },
  { name: "Mesoarchean",       from: 3200,  to: 2800 },
  { name: "Neoarchean",        from: 2800,  to: 2500 },
  { name: "Paleoproterozoic",  from: 2500,  to: 1600 },
  { name: "Mesoproterozoic",   from: 1600,  to: 1000 },
  { name: "Neoproterozoic",    from: 1000,  to: 538.8 },
  { name: "Paleozoic",         from: 538.8, to: 251.902 },
  { name: "Mesozoic",          from: 251.902, to: 66 },
  { name: "Cenozoic",          from: 66,    to: 0 }
]

var PERIODS = [
  { name: "Cambrian",       from: 538.8,   to: 486.85 },
  { name: "Ordovician",     from: 486.85,  to: 443.1 },
  { name: "Silurian",       from: 443.1,   to: 419.62 },
  { name: "Devonian",       from: 419.62,  to: 358.86 },
  { name: "Carboniferous",  from: 358.86,  to: 298.9 },
  { name: "Permian",        from: 298.9,   to: 251.902 },
  { name: "Triassic",       from: 251.902, to: 201.4 },
  { name: "Jurassic",       from: 201.4,   to: 143.1 },
  { name: "Cretaceous",     from: 143.1,   to: 66 },
  { name: "Paleogene",      from: 66,      to: 23.03 },
  { name: "Neogene",        from: 23.03,   to: 2.58 },
  { name: "Quaternary",     from: 2.58,    to: 0 }
]

var EPOCHS = [
  { name: "Pleistocene", from: 2.58,   to: 0.0117 },
  { name: "Holocene",    from: 0.0117, to: 0 }
]

// The Holocene's three ages. The one we are in was ratified in 2018 and
// starts at a drought that ended several civilisations at once, which is a
// better answer to "what is now called" than most people expect there to be.
var AGES = [
  { name: "Greenlandian",  from: 0.0117,   to: 0.008326 },
  { name: "Northgrippian", from: 0.008326, to: 0.0042 },
  { name: "Meghalayan",    from: 0.0042,   to: 0 }
]

var LEVELS = [EONS, ERAS, PERIODS, EPOCHS, AGES]

// Which division of a given level a moment falls in. Boundaries belong to the
// younger division, the way the chart reads them: 66 Ma is the first instant
// of the Cenozoic, not the last of the Mesozoic.
function divisionAt(level, ma) {
  for (var i = 0; i < level.length; i++)
    if (ma <= level[i].from && ma > level[i].to) return level[i]
  // The present sits exactly on the `to` of every innermost division.
  for (var j = 0; j < level.length; j++)
    if (level[j].to === 0 && ma <= level[j].from) return level[j]
  return null
}

// Eon down to age, skipping the levels that do not cover this moment - the
// Hadean has no named eras, and only the Holocene is divided into ages.
function breadcrumb(ma) {
  var out = []
  for (var i = 0; i < LEVELS.length; i++) {
    var found = divisionAt(LEVELS[i], ma)
    if (found) out.push(found.name)
  }
  return out
}

// How far through the day a moment is, 0 at formation and 1 now.
function dayFraction(ma) {
  return Math.max(0, Math.min(1, (AGE_MA - ma) / AGE_MA))
}

// The clock face for a moment. The present is midnight of the following day -
// 24:00:00, which no clock shows - so it is held one second short, which is
// also the truth to the nearest 52,000 years.
function clockAt(ma) {
  var seconds = Math.min(86399, Math.floor(dayFraction(ma) * 86400))
  return {
    hour: Math.floor(seconds / 3600),
    minute: Math.floor(seconds / 60) % 60,
    second: seconds % 60
  }
}

// Years of real time per unit of this clock.
function yearsPer(unit) {
  var seconds = { day: 86400, hour: 3600, minute: 60, second: 1 }[unit]
  return seconds === undefined ? 0 : AGE_MA * 1e6 * seconds / 86400
}

// A real span, measured in this clock's units: 300,000 years of humans is
// 5.7 seconds of the day.
function asClockSpan(years) {
  return years / yearsPer("second")
}

// The strip: eons as fractions of the width, oldest first.
function bands() {
  var out = []
  for (var i = 0; i < EONS.length; i++)
    out.push({ name: EONS[i].name,
               x0: dayFraction(EONS[i].from),
               x1: dayFraction(EONS[i].to) })
  return out
}
