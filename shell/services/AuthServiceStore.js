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
  trustedIds[key] = true
  if (services[key] && services[key] !== service && typeof services[key].destroy === "function")
    services[key].destroy()
  services[key] = service
  watchState(service)
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
  if (service && typeof service.destroy === "function") service.destroy()
  delete services[key]
  if (service) notifyStateChanged()
}

function destroyAll() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++) destroy(keys[i])
}

// Scalar queries and a no-argument callback keep authentication QObjects
// private to this import. currentlyLocked() reads the lock afresh; its bound
// `locked` once missed a change.
var stateListener = null

function setStateListener(listener) {
  stateListener = typeof listener === "function" ? listener : null
}

function notifyStateChanged() {
  if (stateListener) stateListener()
}

function watchState(service) {
  var signals = ["lockedChanged", "lockRequestedChanged", "wakingChanged", "dialogVisibleChanged"]
  for (var i = 0; i < signals.length; i++) {
    var changed = service[signals[i]]
    if (changed && typeof changed.connect === "function") changed.connect(notifyStateChanged)
  }
}

function hasActiveLock() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++) {
    var service = services[keys[i]]
    if (typeof service.currentlyLocked === "function" ? service.currentlyLocked() : service.locked === true) return true
  }
  return false
}

// The polkit dialog stays open until a request succeeds or is cancelled, and
// through a drive unlock. Quickshell has answered polkitd by then, so a
// reload after it closes cancels nothing.
function hasOpenPrompt() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++)
    if (services[keys[i]].dialogVisible === true) return true
  return false
}

function isWaking() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++)
    if (services[keys[i]].waking === true) return true
  return false
}

function holdsEngineReload() {
  return hasActiveLock() || isWaking() || hasOpenPrompt()
}
