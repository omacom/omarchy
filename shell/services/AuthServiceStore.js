// Intentionally not `.pragma library`: QML JavaScript imports get a private
// module instance per importing component. shell.qml's instance retains the
// authentication services; a third-party plugin importing this file receives
// a separate empty store rather than a shared path to credential-bearing QML.

var services = ({})
var trustedIds = ({})

function has(id) {
  return services[String(id || "")] !== undefined
}

function put(id, service) {
  var key = String(id || "")
  if (!key || !service) return
  if (services[key] === service) return
  trustedIds[key] = true
  if (services[key]) destroy(key)
  services[key] = service
  watchLock(service, true)
  syncPolkitLock()
}

function isLock(service) {
  return service && typeof service.currentlyLocked === "function"
    && "strandedLockResolved" in service
}

function watchLock(service, watching) {
  if (!isLock(service)) return
  // Use the existing lock contract so already-created lock clones work too.
  var signals = ["lockRequestedChanged", "lockedChanged", "strandedLockChanged", "strandedLockResolvedChanged"]
  for (var i = 0; i < signals.length; i++) {
    if (watching) service[signals[i]].connect(syncPolkitLock)
    else service[signals[i]].disconnect(syncPolkitLock)
  }
}

// Coordinate only the privately retained authentication services. No shared
// singleton or host property may expose the lock or its credentials to plugins.
function syncPolkitLock() {
  var keys = ids()
  var hasLock = false
  var blocked = false
  for (var i = 0; i < keys.length; i++) {
    var service = services[keys[i]]
    if (!isLock(service)) continue
    hasLock = true
    blocked = blocked || !service.strandedLockResolved || service.strandedLock || service.currentlyLocked()
  }
  for (var j = 0; j < keys.length; j++) {
    var agent = services[keys[j]]
    if ("authenticationBlocked" in agent)
      agent.authenticationBlocked = !hasLock || blocked
  }
}

function isTrusted(id) {
  return trustedIds[String(id || "")] === true
}

function ids() {
  return Object.keys(services)
}

function updateManifest(id, manifest) {
  var service = services[String(id || "")]
  if (service && "manifest" in service) service.manifest = manifest
}

function destroy(id) {
  var key = String(id || "")
  var service = services[key]
  watchLock(service, false)
  delete services[key]
  syncPolkitLock()
  if (service && typeof service.destroy === "function") service.destroy()
}

function destroyAll() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++) destroy(keys[i])
}
