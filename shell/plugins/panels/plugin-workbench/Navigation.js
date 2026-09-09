.pragma library

// Prefer controls in the same row/column before diagonally adjacent ones.
function nearest(items, origin, dx, dy) {
  var best = null
  var bestScore = Infinity
  items.forEach(function(candidate) {
    if (candidate.item === origin.item) return
    var across = dx ? candidate.cy - origin.cy : candidate.cx - origin.cx
    var forward = dx ? (candidate.cx - origin.cx) * dx : (candidate.cy - origin.cy) * dy
    if (forward < 1) return
    var overlap = dx
      ? candidate.y < origin.y + origin.height && candidate.y + candidate.height > origin.y
      : candidate.x < origin.x + origin.width && candidate.x + candidate.width > origin.x
    var score = forward + Math.abs(across) * (overlap ? 0.01 : 2) + (overlap ? 0 : 10000)
    if (score < bestScore) { best = candidate.item; bestScore = score }
  })
  return best
}
