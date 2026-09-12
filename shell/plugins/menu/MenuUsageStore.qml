import QtQuick
import Quickshell
import Quickshell.Io
import "MenuUsage.js" as MenuUsage

// Persists menu activation frecency to ~/.local/state/omarchy/launcher-usage.json.
// Scoring lives in MenuUsage.js; this holds the loaded records and the file.
Item {
  id: root

  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
  readonly property string statePath: stateDir + "/launcher-usage.json"
  property var records: ({})
  property bool directoryReady: false
  property bool loaded: false

  function load(rawText) {
    root.records = MenuUsage.parse(rawText)
    root.loaded = true
  }

  function score(itemId) {
    return MenuUsage.score(root.records, itemId, Date.now())
  }

  function lastUsedAt(itemId) {
    return MenuUsage.lastUsedAt(root.records, itemId)
  }

  function record(itemId, kind) {
    // Writing before the file has loaded would persist a fresh empty map over
    // the real history.
    if (!root.loaded || !itemId) return
    var now = Date.now()
    var next = MenuUsage.prune(MenuUsage.record(root.records, itemId, kind, now), now)
    root.records = next
    stateFile.setText(MenuUsage.serialize(next))
  }

  Process {
    id: initDir
    command: ["install", "-d", "-m", "0700", root.stateDir]
    onExited: root.directoryReady = true
  }

  FileView {
    id: stateFile
    path: root.directoryReady ? root.statePath : ""
    atomicWrites: true
    printErrors: false
    onLoaded: root.load(text())
    // No file yet on first run: start from empty rather than staying unloaded,
    // or record() would refuse to write and history would never begin.
    onLoadFailed: if (root.directoryReady) root.load("{}")
  }

  Component.onCompleted: initDir.running = true
}
