// Manifest predicates for the shell's plugin loader.
//
// A manifest reaches most of the shell through a QML model, where its arrays are V4Sequences rather
// than JS arrays: `Array.isArray(manifest.kinds)` is false for a panel plugin's manifest even though
// `kinds` is a perfectly good list, which left third-party menu plugins without an app library
// (#15360). Read the list by length and index instead, and take anything list-shaped.
function hasKind(manifest, kind) {
  var kinds = manifest && manifest.kinds
  if (!kinds || typeof kinds.length !== "number") return false
  for (var i = 0; i < kinds.length; i++) {
    if (kinds[i] === kind) return true
  }
  return false
}

if (typeof module !== "undefined") {
  module.exports = {
    hasKind: hasKind
  }
}
