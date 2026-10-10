// Intentionally not `.pragma library`: this file is loaded both by shell.qml
// and, as plain text, by the plugin authentication boundary test's runtime
// checks. It holds no state, so a private module instance per importer costs
// nothing.
//
// The service a bar-capable plugin may be handed for one of its hosted
// entries, if any. Three checks:
//
// The manifest must be a third-party bar-widget plugin. Bars write their own
// layout (mutatePluginBarConfig), so a manifest check is the only boundary
// that survives the bar staging arbitrary ids into it: first-party services
// hold the host shell itself, service-only plugins and bars are not widgets,
// and authentication services never enter the service map.
//
// It must not be an authentication service, alongside the service-map
// absence.
//
// A clone of a first-party plugin has a third-party manifest, but the
// service behind the built-in name stays first-party property. First-party
// services are reachable only through the narrow firstPartyServiceFor()
// proxies, and a replacement bar holding a raw instance of one would step
// around that narrowing — so the built-in name stays denied and the proxy
// remains the channel for it. The clone's own instance is different: it
// holds a scoped shell, not the host's, and the widget that is the clone may
// reach its own service by naming itself, the way pluginOwnsTarget() grants
// it under the trusted bar.
//
// The bar must actually host the widget. An entry can be named by any of the
// three ids the same hosted widget answers to: the id the caller used, the
// enabled clone that took its place, or the built-in the clone was made
// from. resolveEnabledId routes every call to the enabled implementation, so
// the service itself always comes from the clone when one is enabled — that
// is what the rendered widget runs.
//
// registry supplies resolveEnabledId and installedPlugins;
// isAuthenticationService(manifest, id) and entryConfigured(id) are the
// host's own classifiers, injected so this module stays decoupled from QML.
function hostedWidgetServiceId(requestedId, registry, isAuthenticationService, entryConfigured) {
  var requested = String(requestedId || "")
  var id = registry.resolveEnabledId(requested)
  var manifest = registry.installedPlugins[id]
  if (!manifest || manifest.__isFirstParty) return null
  if (!Array.isArray(manifest.kinds) || manifest.kinds.indexOf("bar-widget") === -1) return null
  if (isAuthenticationService(manifest, id)) return null

  var metadata = manifest.omarchy
  var clonedFrom = metadata ? String(metadata.clonedFrom || "") : ""
  if (clonedFrom) {
    var source = registry.installedPlugins[clonedFrom]
    // A clone of a first-party widget may reach its own service by naming
    // itself — the same grant pluginOwnsTarget() gives it under the trusted
    // bar, and its instance holds a scoped shell, not the host's. The
    // built-in name is the first-party service asking to be let out past the
    // narrow proxy, so that name stays denied; the proxy is the channel for
    // it.
    if (source && source.__isFirstParty && requested !== id) return null
  }
  if (entryConfigured(requested) || entryConfigured(id)
      || (!!clonedFrom && entryConfigured(clonedFrom)))
    return id
  return null
}