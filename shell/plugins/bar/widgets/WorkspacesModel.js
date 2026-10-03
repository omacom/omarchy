// Workspace list for the workspaces bar widget, kept Qt-free so it can be unit
// tested under node (test/shell.d/workspaces-test.sh).

// Maps each monitor name to the numbered workspaces (1-10) that a Hyprland
// workspace rule binds to it, from `hyprctl workspacerules -j` and
// `hyprctl monitors -j`:
//
//   hl.workspace_rule({ workspace = "6", monitor = "desc:Dell Inc. DELL P2417H" })
//
// A rule names its monitor either by connector or by a `desc:` prefix of the
// monitor description. Rules without a monitor, for a named or special
// workspace, or for a monitor that is not connected are ignored.
function monitorRuleIds(rules, monitors) {
  var byMonitor = {}

  function monitorName(selector) {
    selector = String(selector || "")
    if (!selector) return ""

    for (var i = 0; i < monitors.length; i++) {
      var monitor = monitors[i]
      if (selector === monitor.name) return monitor.name
      if (selector.indexOf("desc:") === 0 && String(monitor.description || "").indexOf(selector.slice(5)) === 0) return monitor.name
    }

    return ""
  }

  ;(rules || []).forEach(function (rule) {
    var workspace = String(rule.workspaceString || "")
    if (!/^([1-9]|10)$/.test(workspace)) return

    var name = monitorName(rule.monitor)
    if (!name) return

    var id = parseInt(workspace, 10)
    if (!byMonitor[name]) byMonitor[name] = []
    if (byMonitor[name].indexOf(id) === -1) byMonitor[name].push(id)
  })

  return byMonitor
}

// The workspace ids one bar shows. `workspaces` is the live list as
// { id, monitor } pairs, where monitor is the name of the monitor the
// workspace lives on.
//
// Without monitor-bound rules every bar shows 1-5 plus any other existing
// workspace up to 10. With them, a bar shows the workspaces bound to its
// monitor, drops one that was moved to another monitor, and adds any
// workspace up to 10 that currently lives on it.
function workspaceIds(ruleIdsByMonitor, monitorName, workspaces) {
  var ids = []
  var bound = Object.keys(ruleIdsByMonitor || {}).length > 0 && monitorName

  function byId(id) {
    for (var i = 0; i < workspaces.length; i++) {
      if (workspaces[i].id === id) return workspaces[i]
    }

    return null
  }

  if (bound) {
    ;(ruleIdsByMonitor[monitorName] || []).forEach(function (id) {
      var workspace = byId(id)
      if (workspace && workspace.monitor && workspace.monitor !== monitorName) return
      ids.push(id)
    })
  } else {
    ids = [1, 2, 3, 4, 5]
  }

  workspaces.forEach(function (workspace) {
    var id = workspace.id
    if (!(id > 0 && id <= 10) || ids.indexOf(id) !== -1) return
    if (bound && workspace.monitor !== monitorName) return
    ids.push(id)
  })

  ids.sort(function (left, right) { return left - right })
  return ids
}

if (typeof module !== "undefined") {
  module.exports = {
    monitorRuleIds: monitorRuleIds,
    workspaceIds: workspaceIds
  }
}
