// Hyprland lists a monitor's reserved space as left, top, right, bottom: the
// config error banner, any `reserved_area` monitor rule and every exclusive
// zone, the bar's own included. The bar is laid out inside whatever was
// reserved before it, so that space moves it in from the screen edges.

function sides(reserved) {
  var r = reserved || []
  return {
    left: Number(r[0]) || 0,
    top: Number(r[1]) || 0,
    right: Number(r[2]) || 0,
    bottom: Number(r[3]) || 0
  }
}

// How far the bar sits in from each screen edge: that edge's reserved space,
// less the zone the bar claims on its own edge. A hidden bar claims none.
function barInsets(reserved, position, ownZone) {
  var insets = sides(reserved)
  var edge = insets[position] === undefined ? "top" : position
  insets[edge] = Math.max(0, insets[edge] - (Number(ownZone) || 0))
  return insets
}

// Top-left of the bar window on its screen. The window is anchored to its own
// edge and both neighbours (a top bar to top, left and right), so it starts
// at the insets on those edges and its far side follows from its size.
function barWindowOrigin(insets, position, screenW, screenH, windowW, windowH) {
  return {
    x: position === "right" ? screenW - insets.right - windowW : insets.left,
    y: position === "bottom" ? screenH - insets.bottom - windowH : insets.top
  }
}

if (typeof module !== "undefined") module.exports = { barInsets: barInsets, barWindowOrigin: barWindowOrigin }
