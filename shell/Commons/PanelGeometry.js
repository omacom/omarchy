.pragma library

// Placement of popouts opened from the bar. A floating bar sits `margins` off
// the screen edges it touches, so its window does not start at the screen's
// corner and its outer face is not at barSize from the edge.

// Top-left of the bar window on its screen.
function barOrigin(position, margins, barW, barH, screenW, screenH) {
  var m = margins || {}
  return {
    x: position === "right" ? screenW - (m.right || 0) - barW : (m.left || 0),
    y: position === "bottom" ? screenH - (m.bottom || 0) - barH : (m.top || 0)
  }
}

// Top-left of a popout card on screen: `gap` off the bar's outer face,
// centred on its anchor (or on the bar with centerOnBar), and kept `margin`
// inside the screen. `anchor` is in screen coordinates.
//   p: { position, centerOnBar, origin, barW, barH, anchor: { x, y, w, h },
//        width, height, gap, margin, screenW, screenH }
function cardOrigin(p) {
  var o = p.origin
  var position = p.position === "bottom" || p.position === "left" || p.position === "right" ? p.position : "top"
  var horizontal = position === "top" || position === "bottom"
  var x = 0, y = 0
  if (horizontal) {
    x = p.centerOnBar ? o.x + p.barW / 2 - p.width / 2 : p.anchor.x + p.anchor.w / 2 - p.width / 2
    y = position === "bottom" ? o.y - p.height - p.gap : o.y + p.barH + p.gap
  } else {
    x = position === "left" ? o.x + p.barW + p.gap : o.x - p.width - p.gap
    y = p.centerOnBar ? o.y + p.barH / 2 - p.height / 2 : p.anchor.y + p.anchor.h / 2 - p.height / 2
  }
  x = Math.max(p.margin, Math.min(x, p.screenW - p.width - p.margin))
  y = Math.max(p.margin, Math.min(y, p.screenH - p.height - p.margin))
  return { x: Math.round(x), y: Math.round(y) }
}

// Room for a card along one screen axis. Across a bar on that axis the card
// loses the bar, its edge margin and `awayReserve`; otherwise `crossReserve`.
function availableLength(screenLength, facesBar, barReach, awayReserve, crossReserve) {
  return Math.max(120, screenLength - (facesBar ? barReach + awayReserve : crossReserve))
}

// Depth from the anchored screen edge that counts as the bar for forwarding
// clicks while a popout is open: the bar, its edge margin and the gap.
function barStripSize(barSize, thickness, edgeMargin, gap) {
  return Math.max(barSize, thickness) + (edgeMargin || 0) + gap
}
