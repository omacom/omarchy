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

// Host-only lifecycle queries. Importers receive a private module instance, so
// third-party QML cannot use these functions to obtain authentication objects.
function sessionLockOwned(id) {
  var service = services[String(id || "")]
  return !!service && service.sessionLockOwned === true
}

function anySessionLockOwned() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++) {
    if (sessionLockOwned(keys[i])) return true
  }
  return false
}

function destroyUnlessSessionLockOwned(id) {
  if (sessionLockOwned(id)) return false
  destroy(id)
  return true
}

function destroy(id) {
  var key = String(id || "")
  var service = services[key]
  if (service && typeof service.destroy === "function") service.destroy()
  delete services[key]
}

function destroyAll() {
  var keys = ids()
  for (var i = 0; i < keys.length; i++) destroy(keys[i])
}
