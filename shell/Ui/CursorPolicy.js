// Pointer-to-cursor handoff shared by every panel row and control.
//
// A panel has one keyboard/mouse cursor. Pointer enter claims it so mouse and
// keyboard share a single highlight. Pointer leave releases it only while the
// item still owns it: moving to another row, or to an inline action button,
// claims the new target first, so the old item's leave must not clear the
// highlight the new item just took.
//
// `owns` is the item's own `hasCursor`-style predicate, evaluated at leave
// time. That keeps keyboard navigation intact: if a key moved the cursor
// elsewhere while the pointer rested here, this item no longer owns it and
// its leave is a no-op.
function applyHover(on, owns, claim, release) {
  if (on) {
    if (typeof claim === "function") claim()
    return
  }
  if (owns && typeof release === "function") release()
}

if (typeof module !== "undefined") {
  module.exports = { applyHover: applyHover }
}
