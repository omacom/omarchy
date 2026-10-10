// Development helpers behind `omarchy-dev-panel-capture` and `-tree`: find a
// bar panel's open card, and describe its scene as a tree of plain objects.
// Pure functions over whatever looks like a Qt Quick item, so Node can test
// them with fakes.

// "QQuickText(0x55d4…)" and "PanelHero_QMLTYPE_37(0x…)" become "Text" and
// "PanelHero".
function typeName(item) {
  return String(item)
    .replace(/\(0x[0-9a-f]+.*$/, "")
    .replace(/_QML(TYPE)?_\d+.*$/, "")
    .replace(/^QQuick/, "")
}

// A bar panel keeps its KeyboardPanel or PopupCard among its resources, not
// its visual children, so look through data for the card that is open. A
// Loader's item is usually among its data too, but not when it isn't an Item,
// so follow that as well.
function findOpenCard(object, depth) {
  depth = depth || 0
  if (!object || depth > 6) return null
  if (object.cardItem && object.open === true) return object.cardItem
  var data = object.data || []
  for (var i = 0; i < data.length; i++) {
    var found = findOpenCard(data[i], depth + 1)
    if (found) return found
  }
  if (object.item) return findOpenCard(object.item, depth + 1)
  return null
}

// What a reader can see: hidden, fully transparent, and empty items are left
// out along with everything under them.
function shown(item) {
  return !!item && item.visible !== false && item.opacity > 0 && item.width > 0 && item.height > 0
}

// The overlap of two rectangles, or null when they don't meet. A null `clip`
// stands for no clipping at all.
function intersect(rect, clip) {
  if (!clip) return rect
  var x = Math.max(rect.x, clip.x), y = Math.max(rect.y, clip.y)
  var right = Math.min(rect.x + rect.w, clip.x + clip.w)
  var bottom = Math.min(rect.y + rect.h, clip.y + clip.h)
  return right > x && bottom > y ? { x: x, y: y, w: right - x, h: bottom - y } : null
}

// One node per item, positioned relative to the card: geometry always, then
// text, color, font size, and corner radius when the item has them. `clip` is
// the area, in card coordinates, that the item's clipping ancestors leave
// visible. An item wholly outside it, like a row a scrolled Flickable hides,
// is left out (null) unless something under it reaches back into view, and
// then keeps only its type and geometry, since none of its own text or color
// shows; the card itself is always there.
function itemTree(item, card, depth, clip) {
  depth = depth || 0
  clip = clip || null
  var origin = item === card ? { x: 0, y: 0 } : item.mapToItem(card, 0, 0)
  var bounds = { x: origin.x, y: origin.y, w: item.width, h: item.height }
  var inView = !clip || !!intersect(bounds, clip)
  if (item.clip === true) clip = intersect(bounds, clip)
  var node = {
    type: typeName(item),
    x: Math.round(origin.x), y: Math.round(origin.y),
    w: Math.round(item.width), h: Math.round(item.height)
  }
  if (inView) {
    if (typeof item.text === "string" && item.text !== "") node.text = item.text
    if (item.color !== undefined && item.color !== null && String(item.color) !== "#00000000") node.color = String(item.color)
    // A font sized in points, or left at the default, reports -1 pixels.
    if (item.font && typeof item.text === "string" && item.font.pixelSize > 0) node.px = item.font.pixelSize
    if (item.radius > 0) node.radius = item.radius
  }

  var children = []
  // A clipping item outside the view hides everything under it.
  if (depth < 40 && (inView || item.clip !== true)) {
    var list = item.children || []
    for (var i = 0; i < list.length; i++) {
      if (!shown(list[i])) continue
      var child = itemTree(list[i], card, depth + 1, clip)
      if (child) children.push(child)
    }
  }
  if (children.length > 0) node.children = children
  else if (!inView && depth > 0) return null
  return node
}

// The target size to capture an item at, in logical units. grabToImage multiplies
// it by the window's device pixel ratio itself, so `scale` 1 (the default) gives
// exactly the screen's pixels and 2 twice as many, sharp on a Retina display.
function captureSize(width, height, scale) {
  var factor = Number(scale)
  if (!(factor > 0)) factor = 1
  return { width: Math.ceil(width * factor), height: Math.ceil(height * factor), scale: factor }
}

// How long a capture still waits for a card's contents to finish animating
// in, given when it opened: the rest of `settle` ms, or all of it when the
// time isn't known.
function settleDelay(openedAt, now, settle) {
  if (!(openedAt > 0)) return settle
  return Math.max(0, Math.min(settle, settle - (now - openedAt)))
}

if (typeof module !== "undefined") {
  module.exports = {
    typeName: typeName,
    findOpenCard: findOpenCard,
    shown: shown,
    intersect: intersect,
    itemTree: itemTree,
    captureSize: captureSize,
    settleDelay: settleDelay
  }
}
