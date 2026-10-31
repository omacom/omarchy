import QtQuick
import Quickshell
import Quickshell.Io

// The layout each numbered workspace runs: the one the layout commands give it,
// or the default every other workspace follows.
//
// The commands (omarchy-hyprland-workspace-layout-toggle, -default and the
// menu's layout entries) save ~/.local/state/omarchy/workspace-layouts as one
// Lua file per workspace, named for the layout that workspace runs, plus
// default.lua for the workspaces without one of their own. This reads the same
// files, so the bar and the commands agree on what a workspace will come back
// with, and a layout set from anywhere - the keybind, the menu, the default -
// reaches the bar without a command having to tell it.
//
// A command writes its file and then reloads, rewriting every file, so the
// reads wait for that to settle and one pass afterwards serves them all. The
// whole directory is read by one small shell rather than one process per
// workspace, and only when something writes to it.
QtObject {
  id: root

  readonly property var layouts: ["dwindle", "scrolling", "floating"]

  // Workspace number -> layout, for the workspaces with one of their own, and
  // the layout every other workspace follows.
  property var overrides: ({})
  property string defaultLayout: "dwindle"

  readonly property string layoutsDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omarchy/workspace-layouts"

  function reload() {
    settle.start()
  }

  property Timer settle: Timer {
    id: settle
    interval: 120
    repeat: false
    onTriggered: root.readLayouts()
  }

  function readLayouts() {
    reader.command = ["bash", "-c", root.script, "bash", root.layoutsDir]
    reader.running = true
  }

  // The directory is watched for writes made without a command: a file edited
  // by hand, or a theme switch leaving one alone.
  property FileView watch: FileView {
    path: root.layoutsDir
    watchChanges: true
    printErrors: false
    onFileChanged: root.reload()
  }

  Component.onCompleted: root.reload()

  // The default comes first, then one line per workspace with a layout of its
  // own, after a heading each.
  readonly property string script: [
    "dir=$1",
    "default=dwindle",
    "if [[ -f $dir/default.lua ]]; then",
    "  mode=$(sed -n 's/.*default = \"\\([a-z]*\\)\".*/\\1/p' \"$dir/default.lua\" | head -n 1)",
    "  [[ -n $mode ]] && default=$mode",
    "fi",
    "printf 'default\\n%s\\noverrides\\n' \"$default\"",
    "for file in \"$dir\"/[0-9]*.lua; do",
    "  [[ -f $file ]] || continue",
    "  workspace=${file##*/}",
    "  workspace=${workspace%.lua}",
    "  mode=$(sed -n 's/.*mode = \"\\([a-z]*\\)\".*/\\1/p' \"$file\" | head -n 1)",
    "  [[ -n $mode ]] && printf '%s %s\\n' \"$workspace\" \"$mode\"",
    "done",
    "exit 0"
  ].join("\n")

  property Process reader: Process {
    id: reader
    stdout: StdioCollector {
      onStreamFinished: root.read(text)
    }
  }

  // A word that is not a layout is ignored, as a file may be caught half
  // written.
  function read(text) {
    var defaultLayout = "dwindle"
    var overrides = {}
    var heading = ""
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (line === "" || line.charAt(0) === "#") continue
      if (line === "default" || line === "overrides") {
        heading = line
        continue
      }
      if (heading === "default") {
        if (root.layouts.indexOf(line) !== -1) defaultLayout = line
      } else if (heading === "overrides") {
        var split = line.indexOf(" ")
        if (split <= 0) continue
        var id = parseInt(line.slice(0, split), 10)
        var mode = line.slice(split + 1)
        if (isFinite(id) && id > 0 && root.layouts.indexOf(mode) !== -1) overrides[id] = mode
      }
    }
    root.defaultLayout = defaultLayout
    root.overrides = overrides
  }

  function hasOwn(id) {
    return Object.prototype.hasOwnProperty.call(root.overrides, id)
  }

  function layoutOf(id) {
    return root.hasOwn(id) ? root.overrides[id] : root.defaultLayout
  }

  // The label for a workspace number: the number, then the mark of the layout
  // the workspace runs when that is its own. The mark is one character, so a
  // marked number is laid out like a two-digit one and simply sits a little
  // closer in its slot.
  function label(id, slot) {
    var text = slot === 10 ? "0" : String(slot)
    if (!root.hasOwn(id)) return text
    var marks = { dwindle: "d", scrolling: "s", floating: "f" }
    return text + (marks[root.layoutOf(id)] || "")
  }

  // Spelled out for a tooltip, in the words the layout commands use.
  function detail(id) {
    var layout = root.layoutOf(id)
    var name = layout.charAt(0).toUpperCase() + layout.slice(1)
    return name + " layout" + (root.hasOwn(id) ? "" : ", the default")
  }
}
