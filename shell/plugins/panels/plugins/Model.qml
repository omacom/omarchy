import QtQuick
import Quickshell.Io

// Presentation state only. Installation provenance and execution mode belong
// to the CLI, and exact-revision capability approval belongs to Ward.
QtObject {
  id: root
  property var plugins: []
  property string source: ""
  property bool yolo: false
  property bool trustConfirmed: false
  property var inspected: null
  property var pendingAdd: null
  property string selectedId: ""
  readonly property var selected: plugins.find(row => row.id === selectedId) || null
  property bool adding: false
  property bool confirmRemove: false
  property bool busy: false
  property string operation: ""
  property string error: ""
  property string notice: ""
  property bool abandoned: false
  signal installed(string id, bool sandboxed)
  signal staged(string id, string stage)

  onSourceChanged: { inspected = null; trustConfirmed = false; error = "" }
  onYoloChanged: { inspected = null; trustConfirmed = false; error = "" }
  onSelectedIdChanged: confirmRemove = false

  function modeLabel(mode) {
    if (mode === "ward") return "Ward · sandboxed"
    if (mode === "yolo") return "YOLO · unsandboxed"
    if (mode === "trusted-local") return "Trusted local · unsandboxed"
    if (mode === "blocked") return "Blocked · installation needs attention"
    return "Legacy · unsandboxed"
  }

  function load(add) {
    if (busy) return false
    abandoned = false
    setAdding(!!add)
    inspected = null
    trustConfirmed = false
    confirmRemove = false
    return refresh()
  }

  function setAdding(value) {
    adding = value
    if (value) { source = ""; yolo = false; inspected = null; pendingAdd = null; trustConfirmed = false }
    confirmRemove = false
    error = ""
    notice = ""
    abandoned = false
  }

  readonly property string progressText: ({
    list: "Loading plugins…", stage: "Cloning plugin…", inspect: "Cloning plugin…", add: "Adding plugin…", discard: "Discarding review…",
    remove: "Removing plugin…", enable: "Enabling plugin…",
    disable: selected?.sandboxed ? "Disabling plugin and revoking permissions…" : "Disabling plugin…"
  })[operation] || "Working…"

  function refresh() { return run("list", ["omarchy-plugin-list", "--json"]) }

  function add() {
    if (busy) return false
    if (!source.trim()) { error = "Enter a Git URL or local repository path."; return false }
    if (yolo && !trustConfirmed) { error = "Confirm that you trust this plugin to run without a sandbox."; return false }
    pendingAdd = { source: source.trim(), yolo: yolo }
    inspected = null
    let args = ["omarchy-plugin-add", pendingAdd.source, yolo ? "--inspect" : "--stage", "--json"]
    if (yolo) args.push("--yolo")
    return run(yolo ? "inspect" : "stage", args)
  }

  function action(name) {
    if (!selected || ["enable", "disable", "remove"].indexOf(name) === -1) return false
    if (name === "remove" && !confirmRemove) { confirmRemove = true; return false }
    let args = ["omarchy-plugin-" + name, selected.id]
    if (name === "remove") args.push("--yes")
    return run(name, args)
  }

  function run(kind, args) {
    if (busy) return false
    busy = true
    operation = kind
    error = ""
    notice = ""
    command.command = args
    command.running = true
    return true
  }

  function finish(code, output, errors) {
    const kind = operation
    busy = false
    operation = ""
    if (code !== 0) {
      if (kind === "stage" || kind === "inspect" || kind === "add") pendingAdd = null
      error = String(errors || output || "Could not complete this action.").trim()
      return
    }
    try {
      if (kind === "list") {
        const rows = JSON.parse(output)
        if (!Array.isArray(rows)) throw new Error("Invalid plugin list")
        // Orphaned records remain manageable until explicit removal purges
        // them; a successful uninstall leaves no row to hide locally.
        plugins = rows.filter(row => !row.firstParty)
        if (!plugins.some(row => row.id === selectedId)) selectedId = ""
      } else if (kind === "stage") {
        const result = JSON.parse(output)
        if (!result.id || !/^([0-9a-f]{40}|[0-9a-f]{64})$/.test(result.commit || "")
          || !/^\.add\.[A-Za-z0-9]{8}$/.test(result.stage || "") || result.installed !== false || result.mode !== "ward") throw new Error("Invalid clone result")
        if (abandoned || !pendingAdd || source.trim() !== pendingAdd.source || yolo !== pendingAdd.yolo) {
          pendingAdd = null
          run("discard", ["omarchy-plugin-stage", "discard", result.stage])
          return
        }
        selectedId = result.id
        adding = false
        inspected = null
        pendingAdd = null
        staged(result.id, result.stage)
      } else if (kind === "discard") {
        return
      } else if (kind === "inspect") {
        const result = JSON.parse(output)
        if (!pendingAdd || source.trim() !== pendingAdd.source || yolo !== pendingAdd.yolo || (yolo && !trustConfirmed)) {
          pendingAdd = null
          error = "The source or execution mode changed. Clone the plugin again."
          return
        }
        if (!result.id || !/^([0-9a-f]{40}|[0-9a-f]{64})$/.test(result.commit || "")
          || result.installed !== false || result.mode !== (pendingAdd.yolo ? "yolo" : "ward")) throw new Error("Invalid clone result")
        inspected = result
        let args = ["omarchy-plugin-add", pendingAdd.source, "--commit", result.commit, "--json", "--yes"]
        if (pendingAdd.yolo) args.push("--yolo")
        run("add", args)
      } else if (kind === "add") {
        const result = JSON.parse(output)
        if (!pendingAdd || !inspected || result.id !== inspected.id || result.commit !== inspected.commit
          || result.mode !== (pendingAdd.yolo ? "yolo" : "ward") || result.installed !== true) throw new Error("Invalid installation result")
        selectedId = result.id
        adding = false
        inspected = null
        pendingAdd = null
        trustConfirmed = false
        // Ward hands off to review, which unloads this panel. Finish all
        // local work before emitting the handoff signal.
        if (result.mode !== "ward") Qt.callLater(refresh)
        installed(result.id, result.mode === "ward")
      } else {
        confirmRemove = false
        Qt.callLater(refresh)
      }
    } catch (e) { pendingAdd = null; error = "Could not read the result: " + e }
  }

  property Process command: Process {
    stdout: StdioCollector { id: output }
    stderr: StdioCollector { id: errors }
    onExited: (code, status) => root.finish(code, output.text, errors.text)
  }
}
