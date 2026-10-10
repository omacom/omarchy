function sourceChangedForPath(filePath) {
  return /(?:\.(?:qml|js|mjs)|(?:^|\/)qmldir)$/i.test(String(filePath || "").trim())
}

// Return whether the engine reload is still pending. Never tear down the
// ext-session-lock client while it owns (or is acquiring) the session lock.
function flush(sourcePending, locked, reloadShell, reloadPlugins) {
  if (sourcePending && locked) return true
  if (sourcePending) reloadShell()
  else reloadPlugins()
  return false
}
