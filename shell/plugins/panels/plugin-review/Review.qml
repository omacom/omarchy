import QtQuick
import Quickshell.Io

// UI draft only. The existing commands and Rust store own revisions, grants,
// admission and revocation. Each action passes an argument vector, not a shell.
QtObject {
  id: root
  property string pluginId: ""
  property string stage: ""
  property var revision: null
  property var current: null
  property bool network: false
  property bool networkProxy: false
  property var http: []
  property var exec: ({})
  readonly property var execRequests: {
    if (!revision) return []
    var rows = []
    function walk(name, ask, tree, args) {
      if (tree.end) rows.push({name: name, leaf: tree.end, executable: ask.executable, lifetime: ask.lifetime || "request",
        required: ask.required.indexOf(tree.end) !== -1,
        command: [commandLiteral(ask.executable)].concat(args.map(argumentPreview)).join(" ")})
      for (var step of tree.next) walk(name, ask, step.then, args.concat([step.arg]))
    }
    for (var name of Object.keys(revision.requests.exec)) {
      var ask = revision.requests.exec[name]
      walk(name, ask, ask.tree, [])
    }
    return rows
  }
  readonly property var httpRequests: revision ? Object.keys(revision.requests.http) : []
  property bool notifications: false
  property bool audioPlayback: false
  property bool microphone: false
  property bool audioCapture: false
  property var settings: ({read: [], write: []})
  property bool openUrls: false
  property bool storage: false
  property bool desktopGeometry: false
  property bool media: false
  property var folders: ({})
  readonly property var folderRequests: revision ? revision.requests.filesystem : []
  readonly property var settingRequests: {
    if (!revision) return []
    var result = []
    for (var access of ["read", "write"])
      for (var key of revision.requests.settings[access]) result.push({access: access, key: key})
    return result
  }
  property bool busy: false
  property string operation: ""
  property string error: ""
  property string notice: ""
  signal completed()
  readonly property bool requiredAccepted: hasRequiredPermissions()

  function hasRequiredPermissions() {
    if (!revision) return false
    var requests = revision.requests
    for (var name of ["network", "networkProxy", "notifications", "audioPlayback", "microphone", "audioCapture", "openUrls", "storage", "desktopGeometry", "media"])
      if (requests[name] && requests[name].required === true && !root[name]) return false
    for (var name of Object.keys(requests.http))
      if (requests.http[name].required && http.indexOf(name) === -1) return false
    for (var ask of folderRequests)
      if (ask.required && folders[ask.name] !== true) return false
    if (requests.settings.required)
      for (var access of ["read", "write"])
        for (var key of requests.settings[access])
          if (settings[access].indexOf(key) === -1) return false
    for (var ask of execRequests)
      if (ask.required && (!Object.prototype.hasOwnProperty.call(exec, ask.name) || exec[ask.name].indexOf(ask.leaf) === -1)) return false
    return true
  }

  function isRequired(name) {
    return !!(revision && revision.requests[name] && revision.requests[name].required === true)
  }

  function atomicEditable(name) {
    if (isRequired(name)) return false
    if (name === "network") return !isRequired("networkProxy") && !httpRequests.some(key => revision.requests.http[key].required)
    if (name === "networkProxy") return !isRequired("network")
    return true
  }

  function toggleAtomic(name) {
    if (!atomicEditable(name)) return
    root[name] = !root[name]
    if (name === "network" && network) { http = []; networkProxy = false }
    if (name === "networkProxy" && networkProxy) network = false
  }

  function selectRequiredPermissions() {
    for (var name of ["network", "networkProxy", "notifications", "audioPlayback", "microphone", "audioCapture", "openUrls", "storage", "desktopGeometry", "media"])
      root[name] = isRequired(name)
    http = httpRequests.filter(name => revision.requests.http[name].required)
    var commands = {}
    for (var ask of execRequests) {
      if (!ask.required) continue
      if (!Object.prototype.hasOwnProperty.call(commands, ask.name)) commands[ask.name] = []
      commands[ask.name].push(ask.leaf)
    }
    exec = commands
    settings = isRequired("settings")
      ? {read: revision.requests.settings.read.slice(), write: revision.requests.settings.write.slice()}
      : {read: [], write: []}
    var selectedFolders = {}
    for (var ask of folderRequests) if (ask.required) selectedFolders[ask.name] = true
    folders = selectedFolders
  }

  function requestLabel(name, label) {
    var request = revision ? revision.requests[name] : null
    return label + requirementLabel(request && request.required === true)
  }

  function requirementLabel(required) { return required ? " · Required" : " · Optional" }

  // Quotes preserve literal boundaries, including a complete bash -c program.
  // Placeholder text describes matchers; it is never an executable command.
  function commandLiteral(value) {
    return /^[A-Za-z0-9_./:@%+=,-]+$/.test(value) ? value : JSON.stringify(value)
  }

  function argumentPreview(arg) {
    if (arg.kind === "exact") return commandLiteral(arg.value)
    if (arg.kind === "oneOf") return "[" + arg.values.map(commandLiteral).join("|") + "]"
    if (arg.kind === "integer") return "<uint " + arg.min + "–" + arg.max + "; no leading zeros>"
    if (arg.kind === "pattern") return "<regex " + JSON.stringify(arg.value) + "; whole arg; ≤" + arg.max + " bytes>"
    return "<" + JSON.stringify(arg.prefix) + "…; " + arg.min + "–" + arg.max + " bytes>"
  }

  function httpField(field) {
    if (field.kind === "exact") return "exactly " + JSON.stringify(field.value)
    if (field.kind === "string") return "text, 0–" + field.max + " bytes"
    if (field.kind === "nullableString") return "null or text, 0–" + field.max + " bytes"
    return "object with exactly these fields: { " + Object.keys(field.fields).map(function(key) {
      return JSON.stringify(key) + ": " + httpField(field.fields[key])
    }).join("; ") + " }"
  }

  function httpDescription(scope) {
    var lines = [scope.method + " " + scope.origin + scope.path]
    lines.push(scope.subtree ? "Path: this root and all paths below it."
      : scope.path.indexOf("*") !== -1 ? "Path: each * matches exactly one nonempty segment." : "Path: exact match only.")
    var keys = Object.keys(scope.query)
    lines.push(keys.length ? "Query parameters (no others allowed):" : "Query parameters: none allowed.")
    for (var key of keys) {
      var field = scope.query[key]
      lines.push("  " + JSON.stringify(key) + (field.required ? " (required): " : " (optional): ") + httpField(field.value))
    }
    if (scope.body === null) lines.push("Request body: none allowed.")
    else {
      lines.push("JSON body: exactly these fields, all required.")
      if (Object.keys(scope.body).length === 0) lines.push("  Empty object {} only.")
      for (var name of Object.keys(scope.body)) lines.push("  " + JSON.stringify(name) + ": " + httpField(scope.body[name]))
    }
    return lines.join("\n")
  }

  readonly property string progressText: ({
    review: "Reading permissions…", status: "Checking plugin status…",
    publish: "Enabling…", approve: "Enabling…", enable: "Enabling…", remove: "Removing…", discard: "Removing…"
  })[operation] || "Working…"

  function load(id, stagedCheckout) {
    if (busy) return false
    if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(id) || id.indexOf("..") !== -1) {
      error = "Choose an installed plugin."
      return false
    }
    pluginId = id
    stage = stagedCheckout || ""
    if (stage && !/^\.add\.[A-Za-z0-9]{8}$/.test(stage)) {
      stage = ""
      error = "Invalid review checkout. Clone the plugin again."
      return false
    }
    revision = null
    current = null
    network = false
    networkProxy = false
    http = []
    exec = ({})
    notifications = false
    audioPlayback = false
    microphone = false
    audioCapture = false
    settings = ({read: [], write: []})
    openUrls = false
    storage = false
    desktopGeometry = false
    media = false
    folders = ({})
    return run("review", stage ? ["omarchy-plugin-stage", "review", stage] : ["omarchy-plugin-review", id, "--json"])
  }

  function setFolder(slot, allowed) {
    if (!allowed && folderRequests.some(ask => ask.name === slot && ask.required)) return
    var next = Object.assign({}, folders)
    next[slot] = allowed === true
    folders = next
  }

  function toggleSetting(access, key) {
    if (isRequired("settings")) return
    var next = {read: settings.read.slice(), write: settings.write.slice()}
    var index = next[access].indexOf(key)
    if (index < 0) next[access].push(key)
    else next[access].splice(index, 1)
    settings = next
  }

  function toggleHttp(name) {
    if (revision.requests.http[name].required || isRequired("network")) return
    var next = http.slice()
    var index = next.indexOf(name)
    if (index < 0) { next.push(name); network = false }
    else next.splice(index, 1)
    http = next
  }

  function toggleExec(name, leaf) {
    if (revision.requests.exec[name].required.indexOf(leaf) !== -1) return
    var next = Object.assign({}, exec)
    var selected = (Object.prototype.hasOwnProperty.call(exec, name) ? exec[name] : []).slice()
    var index = selected.indexOf(leaf)
    if (index < 0) selected.push(leaf)
    else selected.splice(index, 1)
    next[name] = selected
    exec = next
  }

  function approve() {
    if (!revision || busy) return
    var args = ["omarchy-plugin-approve", pluginId, "--revision", revision.revision, "--yes"]
    if (network) args.push("--allow-network")
    if (networkProxy) args.push("--allow-network-proxy")
    for (var name of http) args.push("--http", name)
    for (var name of Object.keys(exec))
      for (var leaf of exec[name]) args.push("--exec", name + ":" + leaf)
    if (notifications) args.push("--allow-notifications")
    if (audioPlayback) args.push("--allow-audio-playback")
    if (microphone) args.push("--allow-microphone")
    if (audioCapture) args.push("--allow-audio-capture")
    for (var access of ["read", "write"])
      for (var key of settings[access]) args.push("--" + access + "-setting", key)
    if (openUrls) args.push("--allow-open-urls")
    if (storage) args.push("--allow-storage")
    if (desktopGeometry) args.push("--allow-desktop-geometry")
    if (media) args.push("--allow-media")
    for (var ask of folderRequests) if (folders[ask.name] === true)
      args.push(ask.access === "readwrite" ? "--write" : "--read", ask.name)
    run("approve", args)
  }

  function enable() {
    if (!requiredAccepted || busy || (current && current.enabled)) return
    if (stage) run("publish", ["omarchy-plugin-stage", "publish", stage, revision.revision])
    else approve()
  }

  function remove() {
    if (pluginId && !busy) {
      if (stage) run("discard", ["omarchy-plugin-stage", "discard", stage])
      else run("remove", ["omarchy-plugin-remove", pluginId, "--yes"])
    }
  }

  function run(kind, args) {
    if (busy) return false
    busy = true
    operation = kind
    error = ""
    if (kind !== "status") notice = ""
    process.out = ""
    process.err = ""
    process.outDone = false
    process.errDone = false
    process.exited = false
    process.command = ["timeout", "20s"].concat(args)
    process.running = true
    return true
  }

  function finish() {
    if (!busy || !process.exited || !process.outDone || !process.errDone) return
    var kind = operation
    busy = false
    if (process.exitCode !== 0) {
      error = process.err.trim() || (process.exitCode === 124 ? "The action timed out." : "The action failed.")
      return
    }
    try {
      if (kind === "review") {
        var info = JSON.parse(process.out)
        if (info.id !== pluginId || !/^[0-9a-f]{64}$/.test(info.revision) || !info.requests)
          throw new Error("Invalid review response")
        revision = info
        selectRequiredPermissions()
        notice = ""
      } else if (kind === "status") {
        var rows = JSON.parse(process.out)
        current = rows.find(function(row) { return row.id === root.pluginId }) || null
        return
      } else if (kind === "publish") {
        var published = JSON.parse(process.out)
        if (published.id !== pluginId || published.stage !== stage || published.installed !== true || published.mode !== "ward")
          throw new Error("Invalid installation response")
        stage = ""
        approve()
        return
      } else if (kind === "approve") {
        run("enable", ["omarchy-plugin-enable", pluginId])
        return
      } else if (kind === "enable" || kind === "remove" || kind === "discard") {
        stage = ""
        completed()
        return
      }
      run("status", ["omarchy-plugin-list", "--json"])
    } catch (e) {
      error = "Could not read the result: " + e
    }
  }

  property Process process: Process {
    property string out: ""
    property string err: ""
    property bool outDone: false
    property bool errDone: false
    property bool exited: false
    property int exitCode: -1
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { root.process.out = text; root.process.outDone = true; root.finish() }
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: { root.process.err = text; root.process.errDone = true; root.finish() }
    }
    onExited: function(code) { exitCode = code; exited = true; root.finish() }
  }
}
