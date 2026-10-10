import QtQml
import Quickshell.Io

// Mutation reads are independent of the asynchronous FileView used to watch
// the running config. Never turn an unreadable/invalid file into defaults.
QtObject {
  id: store

  property string path
  property string lastError: ""
  property int loadError: 0
  property int saveError: 0
  property FileView file: FileView {
    path: store.path
    preload: false
    blockAllReads: true
    blockWrites: true
    atomicWrites: true
    printErrors: false
    onLoadFailed: function(error) { store.loadError = error }
    onSaveFailed: function(error) { store.saveError = error }
  }

  function read() {
    loadError = 0
    // text() alone returns cached contents. With preload disabled and
    // blockAllReads, reload() invalidates them and text() reads synchronously.
    file.reload()
    var text = file.text()
    return { text: text, error: loadError }
  }

  function reject(message) {
    lastError = message
    console.warn("shell.json mutation refused: " + message + " path=" + path)
    return null
  }

  function mutate(mutator, defaults) {
    lastError = ""
    var source = read()
    var config
    if (source.error === FileViewError.FileNotFound) {
      config = JSON.parse(JSON.stringify(defaults))
    } else if (source.error) {
      return reject("read failed: " + source.error)
    } else {
      try {
        config = JSON.parse(source.text)
      } catch (e) {
        return reject("invalid JSON: " + e)
      }
      if (!config || typeof config !== "object" || Array.isArray(config) || config.version !== 1)
        return reject("expected a config object with version: 1")
    }

    try {
      // Returning false cancels a no-op mutation without writing the file.
      if (mutator(config) === false) return null
      config.version = 1
      var text = JSON.stringify(config, null, 2) + "\n"
    } catch (e) {
      return reject("mutation failed: " + e)
    }

    var current = read()
    if (current.error !== source.error || current.text !== source.text)
      return reject("file changed during mutation; retry the action")
    if (text !== current.text) {
      saveError = 0
      file.setText(text)
      if (saveError) return reject("write failed: " + saveError)
    }
    // Atomic writes protect against partial output, not other writers after
    // the comparison above. Writers do not currently share a config lock.
    return config
  }
}
