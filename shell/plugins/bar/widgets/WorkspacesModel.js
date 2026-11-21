// Which workspaces a bar shows, kept Qt-free so it can be unit tested under
// node (test/shell.d/workspaces-test.sh).
//
// Each monitor owns a block of ten workspace ids (see
// default/hypr/monitor-workspaces.lua). A bar shows its monitor's persistent
// slots and any other of its block that exist, then the workspaces only
// visiting it from another block.
//
// The persistent setting on the bar entry lists the slots (1-10) shown even
// before their workspace exists, 1-5 by default. An empty list shows only the
// workspaces that exist.

var SLOTS = 10
var DEFAULT_PERSISTENT = [1, 2, 3, 4, 5]

function blockOf(id) {
  return Math.floor((id - 1) / SLOTS)
}

function persistentSlots(value) {
  if (!(value instanceof Array)) return DEFAULT_PERSISTENT.slice()

  var slots = []
  for (var i = 0; i < value.length; i++) {
    var slot = value[i]
    if (typeof slot === "number" && slot % 1 === 0 && slot >= 1 && slot <= SLOTS && slots.indexOf(slot) === -1) slots.push(slot)
  }
  return slots
}

// workspaces: [{ id, monitor }] where monitor is the output name.
function workspaceIds(workspaces, settings, block, monitorName) {
  settings = settings || {}
  var ids = []
  var guests = []

  var slots = persistentSlots(settings.persistent)
  for (var i = 0; i < slots.length; i++) ids.push(block * SLOTS + slots[i])

  for (var j = 0; j < workspaces.length; j++) {
    var id = workspaces[j].id
    if (id <= 0) continue
    if (blockOf(id) === block) {
      if (ids.indexOf(id) === -1) ids.push(id)
    } else if (workspaces[j].monitor === monitorName && monitorName !== "") {
      guests.push(id)
    }
  }

  ids.sort(function(left, right) { return left - right })
  guests.sort(function(left, right) { return left - right })
  return ids.concat(guests)
}

if (typeof module !== "undefined") {
  module.exports = {
    blockOf: blockOf,
    persistentSlots: persistentSlots,
    workspaceIds: workspaceIds
  }
}
