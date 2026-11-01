// The blank delay: seconds the locked displays stay lit before they blank.
//
// An explicit zero disables the blank, but only a number means that. `null`,
// `false` and `""` all convert to zero through Number(), and would keep the
// displays lit forever instead of falling back to the default, so the value's
// type is checked before it is converted. Anything that is not a number or a
// non-blank string is the default.
function blankSeconds(value, fallback) {
  var numeric = typeof value === "number" || (typeof value === "string" && value.trim() !== "")
  if (!numeric) return fallback

  var seconds = Number(value)
  if (!isFinite(seconds) || seconds < 0) return fallback

  return Math.floor(seconds)
}

if (typeof module !== "undefined") {
  module.exports = {
    blankSeconds: blankSeconds
  }
}
