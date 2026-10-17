// Which workspace numbers a bar shows, kept Qt-free so it can be unit tested
// under node (test/shell.d/workspaces-test.sh).
//
// Settings on the bar entry:
// - persistent: numbers shown even before their workspace exists (default 1-5).
//   An empty list shows only the workspaces that exist.
// - perMonitor: each bar lists only the workspaces on its own monitor. A
//   persistent number whose workspace is open on another monitor shows there.

var DEFAULT_PERSISTENT = [1, 2, 3, 4, 5]

function validId(id) {
  return typeof id === "number" && id % 1 === 0 && id > 0 && id <= 10
}

function persistentIds(value) {
  if (!(value instanceof Array)) return DEFAULT_PERSISTENT.slice()

  var ids = []
  for (var i = 0; i < value.length; i++) {
    if (validId(value[i]) && ids.indexOf(value[i]) === -1) ids.push(value[i])
  }
  return ids
}

// workspaces: [{ id, monitor }] where monitor is the output name.
function workspaceIds(workspaces, settings, screenName) {
  settings = settings || {}
  var perMonitor = settings.perMonitor === true && !!screenName
  var monitorOf = {}
  var ids = []

  for (var i = 0; i < workspaces.length; i++) {
    var workspace = workspaces[i]
    if (!validId(workspace.id)) continue
    monitorOf[workspace.id] = workspace.monitor
    if (perMonitor && workspace.monitor !== screenName) continue
    if (ids.indexOf(workspace.id) === -1) ids.push(workspace.id)
  }

  var persistent = persistentIds(settings.persistent)
  for (var j = 0; j < persistent.length; j++) {
    var id = persistent[j]
    var elsewhere = perMonitor && monitorOf[id] !== undefined && monitorOf[id] !== screenName
    if (!elsewhere && ids.indexOf(id) === -1) ids.push(id)
  }

  ids.sort(function(left, right) { return left - right })
  return ids
}

if (typeof module !== "undefined") {
  module.exports = {
    persistentIds: persistentIds,
    workspaceIds: workspaceIds
  }
}
