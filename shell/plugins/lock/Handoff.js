// Mapping the lock surface reports the pointer's existing position. Ignore
// that until the secure lock has settled; later movement may reveal auth.
function ignoresPointerWake(concealed, pointerArmed) {
  return !!(concealed && !pointerArmed)
}

if (typeof module !== "undefined") {
  module.exports = {
    ignoresPointerWake: ignoresPointerWake
  }
}
