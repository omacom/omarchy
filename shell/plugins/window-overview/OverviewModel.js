// Keep every top-level window on this workspace, without depending on the
// dock's pinned apps, grouping preference, or desktop-entry matching.
function normalizeAddress(address) {
  var value = String(address || "").trim()
  if (!value) return ""
  if (value.indexOf("0x") !== 0 && value.indexOf("0X") !== 0) value = "0x" + value
  return /^0x[0-9a-fA-F]+$/.test(value) ? value.toLowerCase() : ""
}

function effectiveWorkspaceId(window, pendingMoves) {
  if (!window) return -1
  var actual = window.workspace ? Number(window.workspace.id) : -1
  var addr = normalizeAddress(window.address)
  if (pendingMoves && addr && pendingMoves[addr]) {
    var target = Number(pendingMoves[addr].targetWorkspaceId)
    if (target > 0) return target
  }
  return actual
}

function windowsOnWorkspace(toplevels, workspaceId, pendingMoves) {
  return (toplevels || []).filter(function(window) {
    return window && window.wayland && !window.wayland.parent
      && effectiveWorkspaceId(window, pendingMoves) === workspaceId
  })
}

function parseMonitorBlocks(text) {
  var blocks = {}
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var fields = lines[i].split("\t")
    if (fields.length >= 3 && fields[1] !== "") {
      var parsed = parseInt(fields[0], 10)
      if (isFinite(parsed) && parsed >= 0) blocks[fields[1]] = parsed
    }
  }
  return blocks
}

function blockOf(id, slots) {
  var span = slots > 0 ? slots : 10
  return Math.floor((Number(id) - 1) / span)
}

function slotOf(id, slots) {
  var span = slots > 0 ? slots : 10
  return ((Number(id) - 1) % span) + 1
}

function monitorBlock(monitorName, blocks, activeWorkspaceId, slots) {
  if (blocks && monitorName && blocks[monitorName] !== undefined) return Number(blocks[monitorName])
  if (activeWorkspaceId > 0) return blockOf(activeWorkspaceId, slots)
  return 0
}

function workspaceEntries(workspaces, toplevels, monitorName, blocks, activeWorkspaceId, pendingMoves) {
  var slots = 10
  var block = monitorBlock(monitorName, blocks, activeWorkspaceId, slots)
  var base = block * slots
  var counts = {}
  var list = toplevels || []
  for (var i = 0; i < list.length; i++) {
    var win = list[i]
    if (!win || !win.wayland || win.wayland.parent) continue
    var wsId = effectiveWorkspaceId(win, pendingMoves)
    if (wsId > 0) counts[wsId] = (counts[wsId] || 0) + 1
  }

  var ownSet = {}
  var guestSet = {}
  for (var s = 1; s <= 5; s++) ownSet[base + s] = true
  if (activeWorkspaceId > 0 && blockOf(activeWorkspaceId, slots) === block) ownSet[activeWorkspaceId] = true

  var wsList = workspaces || []
  for (var j = 0; j < wsList.length; j++) {
    var ws = wsList[j]
    var id = ws ? Number(ws.id) : -1
    if (!(id > 0)) continue
    if (blockOf(id, slots) === block) ownSet[id] = true
    else if (ws.monitor && ws.monitor.name === monitorName) guestSet[id] = true
  }

  for (var key in counts) {
    var countId = Number(key)
    if (countId > 0 && blockOf(countId, slots) === block) ownSet[countId] = true
  }

  var ownIds = Object.keys(ownSet).map(Number).sort(function(a, b) { return a - b })
  var hasEmpty = false
  for (var k = 0; k < ownIds.length; k++) {
    if (!(counts[ownIds[k]] > 0)) { hasEmpty = true; break }
  }
  var newSlotId = -1
  if (!hasEmpty) {
    for (var slot = 1; slot <= slots; slot++) {
      var candidate = base + slot
      if (!ownSet[candidate]) {
        ownIds.push(candidate)
        ownIds.sort(function(a, b) { return a - b })
        newSlotId = candidate
        break
      }
    }
  }

  var guestIds = Object.keys(guestSet).map(Number).sort(function(a, b) { return a - b })
  var entries = []
  for (var m = 0; m < ownIds.length; m++) {
    var ownId = ownIds[m]
    var ownCount = counts[ownId] || 0
    entries.push({
      id: ownId,
      slot: slotOf(ownId, slots),
      label: String(slotOf(ownId, slots)),
      guest: false,
      windowCount: ownCount,
      occupied: ownCount > 0,
      isNewSlot: ownId === newSlotId
    })
  }
  for (var g = 0; g < guestIds.length; g++) {
    var guestId = guestIds[g]
    var guestCount = counts[guestId] || 0
    entries.push({
      id: guestId,
      slot: slotOf(guestId, slots),
      label: String(slotOf(guestId, slots)),
      guest: true,
      windowCount: guestCount,
      occupied: guestCount > 0,
      isNewSlot: false
    })
  }
  return entries
}

function reorderShiftSlots(index, fromIndex, toIndex) {
  if (fromIndex < 0 || toIndex < 0 || fromIndex === toIndex) return 0
  if (index === fromIndex) return toIndex - fromIndex
  if (fromIndex < toIndex && index > fromIndex && index <= toIndex) return -1
  if (fromIndex > toIndex && index >= toIndex && index < fromIndex) return 1
  return 0
}

function workspaceDropTarget(entries, localX, localY, rowWidth, rowHeight, cardWidth, spacing, mirrored, topPad, bottomPad) {
  var list = entries || []
  if (!(cardWidth > 0)) return { index: -1, id: -1 }
  var regularIndices = []
  for (var i = 0; i < list.length; i++) {
    if (list[i] && !list[i].guest && !list[i].isNewSlot) regularIndices.push(i)
  }
  if (regularIndices.length < 2) return { index: -1, id: -1 }

  var yTop = isFinite(Number(topPad)) ? Number(topPad) : 64
  var yBottom = isFinite(Number(bottomPad)) ? Number(bottomPad) : 80
  if (localY < -yTop || localY > rowHeight + yBottom) return { index: -1, id: -1 }

  var width = rowWidth > 0 ? rowWidth : (list.length * cardWidth + Math.max(0, list.length - 1) * spacing)
  var alongX = mirrored ? (width - localX) : localX
  var step = cardWidth + spacing
  var minSpan = regularIndices[0] * step
  var maxSpan = regularIndices[regularIndices.length - 1] * step + cardWidth
  if (alongX < minSpan - cardWidth * 0.5 || alongX > maxSpan + cardWidth * 0.5) {
    return { index: -1, id: -1 }
  }

  var bestIndex = regularIndices[0]
  var bestDistance = Infinity
  for (var r = 0; r < regularIndices.length; r++) {
    var idx = regularIndices[r]
    var center = idx * step + cardWidth / 2
    var dist = Math.abs(alongX - center)
    if (dist < bestDistance) {
      bestDistance = dist
      bestIndex = idx
    }
  }
  return { index: bestIndex, id: list[bestIndex].id }
}

function reorderWorkspacePlan(entries, sourceWorkspaceId, targetWorkspaceId, workspaces, toplevels, pendingMoves) {
  var regular = (entries || []).filter(function(entry) {
    return entry && !entry.guest && !entry.isNewSlot
  })
  var fromIndex = -1
  var toIndex = -1
  for (var i = 0; i < regular.length; i++) {
    if (regular[i].id === sourceWorkspaceId) fromIndex = i
    if (regular[i].id === targetWorkspaceId) toIndex = i
  }
  if (fromIndex < 0 || toIndex < 0 || fromIndex === toIndex) return null

  var slotIds = regular.map(function(entry) { return entry.id })
  var reordered = regular.slice()
  var moved = reordered.splice(fromIndex, 1)[0]
  reordered.splice(toIndex, 0, moved)

  var idMap = {}
  var changedPairs = []
  for (var j = 0; j < reordered.length; j++) {
    var oldId = reordered[j].id
    var newId = slotIds[j]
    idMap[oldId] = newId
    if (oldId !== newId) changedPairs.push({ fromId: oldId, toId: newId })
  }
  if (!changedPairs.length) return null

  var usedIds = {}
  var maxUsed = 0
  function markUsed(id) {
    var n = Number(id)
    if (n > 0) {
      usedIds[n] = true
      if (n > maxUsed) maxUsed = n
    }
  }
  for (var e = 0; e < (entries || []).length; e++) markUsed(entries[e].id)
  for (var w = 0; w < (workspaces || []).length; w++) markUsed(workspaces[w].id)
  var list = toplevels || []
  for (var t = 0; t < list.length; t++) {
    if (!list[t]) continue
    if (list[t].workspace) markUsed(list[t].workspace.id)
    markUsed(effectiveWorkspaceId(list[t], pendingMoves))
  }

  var nextTemp = Math.max(9900, maxUsed + 100)
  var stageOps = []
  for (var p = 0; p < changedPairs.length; p++) {
    while (usedIds[nextTemp]) nextTemp++
    usedIds[nextTemp] = true
    stageOps.push({
      fromId: changedPairs[p].fromId,
      tempId: nextTemp,
      toId: changedPairs[p].toId
    })
  }

  var windowMoves = []
  for (var k = 0; k < list.length; k++) {
    var win = list[k]
    if (!win || !win.wayland || win.wayland.parent) continue
    var addr = normalizeAddress(win.address)
    if (!addr) continue
    var currentWs = effectiveWorkspaceId(win, pendingMoves)
    var destWs = idMap[currentWs]
    if (destWs > 0 && destWs !== currentWs) {
      windowMoves.push({ address: addr, fromId: currentWs, toId: destWs })
    }
  }

  var luaOps = stageOps.map(function(op) {
    return "{ from = " + op.fromId + ", temp = " + op.tempId + ", to = " + op.toId + " }"
  })
  var luaDispatch = "function() o.workspaces.reorder({ " + luaOps.join(", ") + " }) end"

  return {
    fromIndex: fromIndex,
    toIndex: toIndex,
    idMap: idMap,
    changedPairs: changedPairs,
    stageOps: stageOps,
    windowMoves: windowMoves,
    luaDispatch: luaDispatch
  }
}

function applyWindowMoves(pendingMoves, moves, timestamp) {
  var next = Object.assign({}, pendingMoves || {})
  var at = isFinite(Number(timestamp)) ? Number(timestamp) : Date.now()
  for (var i = 0; i < (moves || []).length; i++) {
    var move = moves[i]
    var addr = normalizeAddress(move && move.address)
    var target = Number(move && move.toId)
    if (addr && target > 0) next[addr] = { targetWorkspaceId: target, at: at }
  }
  return next
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value))
}

function miniWindowRects(windows, monitorBounds) {
  var list = (windows || []).slice(0, 8)
  if (!list.length) return []
  list.sort(function(a, b) {
    var fa = a.lastIpcObject && isFinite(Number(a.lastIpcObject.focusHistoryID)) ? Number(a.lastIpcObject.focusHistoryID) : 0
    var fb = b.lastIpcObject && isFinite(Number(b.lastIpcObject.focusHistoryID)) ? Number(b.lastIpcObject.focusHistoryID) : 0
    return fb - fa
  })
  var mx = monitorBounds && isFinite(Number(monitorBounds.x)) ? Number(monitorBounds.x) : 0
  var my = monitorBounds && isFinite(Number(monitorBounds.y)) ? Number(monitorBounds.y) : 0
  var mw = monitorBounds && Number(monitorBounds.width) > 0 ? Number(monitorBounds.width) : 1920
  var mh = monitorBounds && Number(monitorBounds.height) > 0 ? Number(monitorBounds.height) : 1080
  var rects = []
  var cols = list.length <= 1 ? 1 : list.length <= 4 ? 2 : 3
  var rows = Math.ceil(list.length / cols)
  for (var i = 0; i < list.length; i++) {
    var win = list[i]
    var ipc = win && win.lastIpcObject ? win.lastIpcObject : null
    var rx, ry, rw, rh
    if (ipc && Array.isArray(ipc.at) && Array.isArray(ipc.size) && Number(ipc.size[0]) > 0 && Number(ipc.size[1]) > 0) {
      rw = clamp(Number(ipc.size[0]) / mw, 0.18, 0.90)
      rh = clamp(Number(ipc.size[1]) / mh, 0.22, 0.90)
      rx = clamp((Number(ipc.at[0]) - mx) / mw, 0.05, 0.95 - rw)
      ry = clamp((Number(ipc.at[1]) - my) / mh, 0.05, 0.95 - rh)
    } else {
      var col = i % cols
      var row = Math.floor(i / cols)
      rw = Math.max(0.20, 0.86 / cols - 0.04)
      rh = Math.max(0.24, 0.82 / rows - 0.05)
      rx = 0.07 + col * (0.86 / cols)
      ry = 0.09 + row * (0.82 / rows)
    }
    rects.push({
      x: rx,
      y: ry,
      width: rw,
      height: rh,
      address: normalizeAddress(win.address),
      appId: win.wayland && win.wayland.appId ? String(win.wayland.appId) : ""
    })
  }
  return rects
}

function selectionAfterChange(previous, selected, windows) {
  if (!windows.length) return -1
  var address = previous[selected] ? previous[selected].address : null
  for (var i = 0; i < windows.length; i++) {
    if (windows[i].address === address) return i
  }
  return Math.max(0, Math.min(selected, windows.length - 1))
}

function moveSelection(selected, step, count) {
  return count > 0 ? ((selected + step) % count + count) % count : -1
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeAddress: normalizeAddress,
    effectiveWorkspaceId: effectiveWorkspaceId,
    windowsOnWorkspace: windowsOnWorkspace,
    parseMonitorBlocks: parseMonitorBlocks,
    blockOf: blockOf,
    slotOf: slotOf,
    monitorBlock: monitorBlock,
    workspaceEntries: workspaceEntries,
    reorderShiftSlots: reorderShiftSlots,
    workspaceDropTarget: workspaceDropTarget,
    reorderWorkspacePlan: reorderWorkspacePlan,
    applyWindowMoves: applyWindowMoves,
    miniWindowRects: miniWindowRects,
    selectionAfterChange: selectionAfterChange,
    moveSelection: moveSelection
  }
}
