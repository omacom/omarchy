function sourceChangedForPath(filePath) {
  return /(?:\.(?:qml|js|mjs)|(?:^|\/)qmldir)$/i.test(String(filePath || "").trim())
}

// Quiet period after the last watcher event. An engine reload resets every
// panel, so a source edit waits until an `omarchy plugin update` has finished
// its fast-forward, validation and (on a failed validation) reset, then reloads
// once. Edits that only need a registry rescan stay quick.
function quietInterval(sourcePending) {
  return sourcePending ? 500 : 150
}

// Return whether the engine reload is still pending. Never tear down the
// ext-session-lock client while it owns (or is acquiring) the session lock.
function flush(sourcePending, locked, reloadShell, reloadPlugins) {
  if (sourcePending && locked) return true
  if (sourcePending) reloadShell()
  else reloadPlugins()
  return false
}
