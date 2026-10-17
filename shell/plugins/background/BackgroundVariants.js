// The default image remains the selected design; rendering never changes its
// symlink. Screen dimensions are already rotated and expressed in logical pixels.
function choose(candidates, fallback, width, height, scale) {
  width *= scale || 1
  height *= scale || 1
  if (!(width > 0 && height > 0)) return fallback

  var best = null
  var bestFit = -1
  var bestScale = Infinity
  for (var i = 0; i < candidates.length; i++) {
    var candidate = candidates[i]
    if (!(candidate.width > 0 && candidate.height > 0)) continue
    var ratio = candidate.width / candidate.height
    var target = width / height
    var fit = Math.min(ratio / target, target / ratio)
    var enlargement = Math.max(width / candidate.width, height / candidate.height)
    var tied = Math.abs(fit - bestFit) < 0.000000001
    // At the same shape, choose the smallest sufficient image. If none is
    // sufficient, choose the largest available one.
    var betterSize = enlargement <= 1
      ? bestScale > 1 || enlargement > bestScale
      : bestScale > 1 && enlargement < bestScale
    if (!best || fit > bestFit + 0.000000001 || (tied && (betterSize
        || (enlargement === bestScale && candidate.path < best.path)))) {
      best = candidate
      bestFit = fit
      bestScale = enlargement
    }
  }
  return best ? best.path : fallback
}

if (typeof module !== "undefined") module.exports = { choose: choose }
