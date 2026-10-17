import QtQuick

// Capability-scoped shell surface for installed third-party plugins.
//
// The callbacks are closed over one plugin id by shell.qml. A plugin can call
// them directly, but it cannot widen their scope: ordinary plugins are limited
// to their own id, and full-bar callbacks independently enforce their explicit
// non-authentication UI scope. This object avoids directly injecting the host
// shell, but it is not a QML sandbox: visual plugins share the host object tree.
QtObject {
  id: api

  required property string pluginId

  property var appLibrary: null
  property var bar: null
  property var barConfig: ({})
  property var idleConfig: ({})

  property var _serviceLookup: null
  property var _firstPartyServiceLookup: null
  property var _barEntryShellLookup: null
  property var _summon: null
  property var _hide: null
  property var _toggle: null
  property var _isOpen: null
  property var _updateSettings: null
  property var _mutateBarConfig: null
  property var _warnedLookups: ({})

  // Denied lookups return null, which looks the same as a service that isn't
  // loaded yet. Say so once, so a plugin cloned before the API was scoped can
  // be diagnosed from the log instead of silently doing nothing.
  function warnDenied(lookup, id, hint) {
    var key = lookup + ":" + id
    if (_warnedLookups[key]) return
    _warnedLookups[key] = true
    console.warn("Plugin " + pluginId + " was denied " + lookup + "(\"" + id + "\"). " + hint)
  }

  function serviceFor(id) {
    var requested = String(id || "")
    var service = _serviceLookup ? _serviceLookup(requested) : null
    if (!service && requested && requested !== pluginId)
      warnDenied("serviceFor", requested, "Plugins can only look up their own service; "
        + "bar widgets use firstPartyServiceFor() for omarchy.idle, omarchy.media, "
        + "omarchy.nightlight and omarchy.notifications.")
    return service
  }

  // Only full-bar facades receive narrow proxies for the specific
  // non-authentication services used by the built-in bar widgets.
  function firstPartyServiceFor(id) {
    var requested = String(id || "")
    var service = _firstPartyServiceLookup ? _firstPartyServiceLookup(requested) : null
    if (!service && requested && requested !== pluginId)
      warnDenied("firstPartyServiceFor", requested, "Only bar widgets can reach "
        + "omarchy.idle, omarchy.media, omarchy.nightlight and omarchy.notifications.")
    return service
  }

  function pluginShellForBarEntry(ownerId, moduleName) {
    return _barEntryShellLookup
      ? _barEntryShellLookup(String(ownerId || ""), String(moduleName || "")) : null
  }

  function summon(id, payloadJson) {
    return _summon ? _summon(String(id || ""), String(payloadJson || "")) : false
  }

  function hide(id) {
    return _hide ? _hide(String(id || "")) : false
  }

  function toggle(id, payloadJson) {
    return _toggle ? _toggle(String(id || ""), String(payloadJson || "")) : false
  }

  function isPluginOpen(id) {
    return _isOpen ? _isOpen(String(id || "")) : false
  }

  function updateEntryInline(id, settings) {
    return _updateSettings ? _updateSettings(String(id || ""), settings) : false
  }

  function mutateShellConfig(mutator) {
    return _mutateBarConfig && typeof mutator === "function"
      ? _mutateBarConfig(mutator) : false
  }
}
