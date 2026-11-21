function sourceChangedForPath(filePath) {
  return /(?:\.(?:qml|js|mjs)|(?:^|\/)qmldir)$/i.test(String(filePath || "").trim())
}

// Quiet period after the last watcher event. An engine reload resets every
// panel, so source edits wait for a burst of writes (a save, a checkout, a
// fast-forward) to settle and then reload once. It cannot tell when an
// `omarchy plugin update` has finished validating: a validation slower than
// this reloads onto the new code first, and a rollback reloads again. Edits
// that only need a registry rescan stay quick.
function quietInterval(sourcePending) {
  return sourcePending ? 500 : 150
}

// Return whether the engine reload is still pending. An engine reload tears
// down every authentication service, so it never runs while one is held: the
// session lock owned or being acquired, its unlock wake, or a polkit prompt.
function flush(sourcePending, held, reloadShell, reloadPlugins) {
  if (sourcePending && held) return true
  if (sourcePending) reloadShell()
  else reloadPlugins()
  return false
}

if (typeof module !== "undefined") {
  module.exports = {
    sourceChangedForPath: sourceChangedForPath,
    quietInterval: quietInterval,
    flush: flush
  }
}
