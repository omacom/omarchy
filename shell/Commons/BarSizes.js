// A bar's thickness per screen, published by screen name. A notch floor can
// make a top bar thicker on one screen than its configured size; the bar, its
// widget facade and the plugin state facade all answer from here.

// The bar's thickness on the screen with this name, from the sizes a bar
// publishes by screen name, or `fallback` (its configured size) for a screen
// it has none for.
function sizeFor(sizes, screenName, fallback) {
  var name = String(screenName || "")
  var size = sizes && Object.prototype.hasOwnProperty.call(sizes, name) ? Number(sizes[name]) : 0
  return size > 0 ? size : fallback
}

// A copy of a bar's per-screen thickness (screen name -> number), so a
// facade holds no reference into the bar. A bar that reports none gives an
// empty map.
function detached(sizes) {
  var copy = ({})
  if (!sizes || typeof sizes !== "object" || Array.isArray(sizes)) return copy
  for (var name in sizes) {
    var size = Number(sizes[name])
    if (size > 0) copy[name] = size
  }
  return copy
}

if (typeof module !== "undefined") {
  module.exports = {
    sizeFor: sizeFor,
    detached: detached
  }
}
