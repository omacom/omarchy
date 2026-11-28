// How much lifetime a card has left after one tick. The wall clock, not the
// timer's interval, says how much passed: a suspend stops the timer without
// stopping time, so the tick after the machine wakes must charge the whole
// sleep, or the toast survives it and outlives its lifetime by that much.
//
// The timer stopping on purpose is different, and the caller says so by
// re-baselining `since`: an open deck holds the remaining time instead of
// charging the pause. A clock that went backwards charges nothing rather than
// crediting the card with the jump.
.pragma library

function charge(remaining, since, now) {
  var elapsed = now - since
  return remaining - (elapsed > 0 ? elapsed : 0)
}
