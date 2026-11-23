// %1, %2, … filled by number, in one pass.
//
// QML's String.arg (QString::arg) does not do that. Each call replaces the
// lowest-numbered hole still in the string, whatever its number, and the
// next call also sees a hole that the previous value introduced. A plural
// form that says the count as a word and keeps only %2 therefore shows the
// count where the next value belongs. omarchy-i18n substitutes by number
// and never twice; this is the same rule for the shell.

function fill(text, values) {
  var args = values || []
  return String(text == null ? "" : text).replace(/%([1-9]\d*)/g, function(match, number) {
    var index = Number(number) - 1
    if (index >= args.length || args[index] == null) return match
    return String(args[index])
  })
}

if (typeof module !== "undefined") {
  module.exports = { fill: fill }
}
