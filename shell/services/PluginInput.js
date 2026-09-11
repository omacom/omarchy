// Worker regions are not authority. The host separately authorizes panels,
// roaming pixels and roaming pointer input; only a panel gets keyboard focus.
function outputPolicy(opened, ownsPanel, ownsOverlay, overlayMode, overlayOutputs) {
  var panel = opened === true && ownsPanel === true
  var roaming = (overlayMode === "visual" || overlayMode === "pointer")
    && (ownsOverlay === true || overlayOutputs === "all")
  return {render: panel || roaming, pointer: panel || (roaming && overlayMode === "pointer"), keyboard: panel}
}

function intersect(rect, area) {
  var x = Math.max(rect.x, area.x), y = Math.max(rect.y, area.y)
  var right = Math.min(rect.x + rect.width, area.x + area.width)
  var bottom = Math.min(rect.y + rect.height, area.y + area.height)
  return right > x && bottom > y ? {x: x, y: y, width: right - x, height: bottom - y} : null
}

function barSlots(bars, width, height) {
  var bounds = {x: 0, y: 0, width: width, height: height}
  var result = []
  for (var bar of bars) {
    if (!bar || !bar.visible) continue
    var slot = {x: bar.x, y: bar.y, width: bar.width, height: bar.height}
    if (bar.position === "bottom") slot.y += height - bar.size
    if (bar.position === "right") slot.x += width - bar.size
    var clipped = intersect(slot, bounds)
    if (clipped) result.push(clipped)
  }
  return result
}

// All slots form a union; applying the single-slot mask repeatedly would erase
// two instances of the same plugin sharing one bar edge.
function barMasks(rectangles, bars, width, height, panelsAllowed) {
  var content = {x: 0, y: 0, width: width, height: height}
  var left = 0, right = 0, top = 0, bottom = 0
  for (var bar of bars) {
    if (!bar || !bar.visible) continue
    if (bar.position === "left") left = Math.max(left, bar.size)
    else if (bar.position === "right") right = Math.max(right, bar.size)
    else if (bar.position === "bottom") bottom = Math.max(bottom, bar.size)
    else top = Math.max(top, bar.size)
  }
  content = {x: left, y: top, width: Math.max(0, width - left - right), height: Math.max(0, height - top - bottom)}
  var areas = barSlots(bars, width, height)
  if (panelsAllowed) areas.push(content)
  var result = []
  for (var rect of rectangles) {
    for (var area of areas) {
      var clipped = intersect(rect, area)
      if (clipped) result.push(clipped)
      if (result.length > 512) return []
    }
  }
  return result
}
