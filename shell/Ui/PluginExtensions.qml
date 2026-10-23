import QtQuick
import "PluginExtensions.js" as Extensions

// One contribution point a plugin can offer to other plugins.
//
// The host names itself and renders whatever comes back; it never learns what
// an extension does. An extension is a plugin whose manifest declares
//
//   "kinds": ["extension"],
//   "entryPoints": { "extension": "MyExtension.qml" },
//   "extension": { "host": "omarchy.clipboard" }
//
// and whose entry point exposes `label`, optionally `shortcut`, plus
// `supports(entry)` and `activate(entry)`. `host` is injected on load: an
// extension calls host.openPane(component, entry) to take over the host's
// detail surface, host.closePane() to hand it back, and host.requestClose()
// to dismiss the host itself.
//
// With nothing installed `items` is empty, `paneOpen` is false, and every host
// binding collapses to the behavior the host had before it offered a slot.
QtObject {
  id: extensions

  property var pluginRegistry: null
  property string hostId: ""

  // The surface an extension has taken over, and the entry it took it for.
  property Component paneComponent: null
  property var paneEntry: null
  readonly property bool paneOpen: paneComponent !== null

  signal paneClosed()
  signal closeRequested()

  // Bumped when an extension loads so host bindings pick up the new item.
  property int revision: 0

  readonly property var manifests: {
    var registry = extensions.pluginRegistry
    if (!registry) return []
    // Read the revision so this rebuilds when plugins are installed, enabled,
    // or hot-reloaded.
    var registryRevision = registry.registryRevision
    return Extensions.hostedExtensions(registry.installedPlugins, extensions.hostId,
      function(id) { return registry.isEnabled(id) })
  }

  readonly property var items: {
    var revision = extensions.revision
    var loaded = []
    for (var i = 0; i < extensions.hosted.count; i++) {
      var holder = extensions.hosted.objectAt(i)
      var item = holder && holder.extensionLoader ? holder.extensionLoader.item : null
      if (item) loaded.push(item)
    }
    return loaded
  }

  property Instantiator hosted: Instantiator {
    model: extensions.manifests
    active: true

    // Additions land in `items` from the Loader below. A removal has no load to
    // hook, and the delegate is still alive when this fires, so the refresh
    // waits for the teardown to finish rather than re-reading a dying object.
    onObjectRemoved: Qt.callLater(function() { extensions.revision++ })

    delegate: QtObject {
      id: holder
      required property var modelData

      readonly property string extensionId: String(modelData.id || "")
      readonly property string sourceUrl: extensions.pluginRegistry
        ? extensions.pluginRegistry.entryPointUrl(modelData, "extension") : ""

      property Loader extensionLoader: Loader {
        source: holder.sourceUrl
        active: holder.sourceUrl !== ""
        onLoaded: {
          if (!item) return
          if ("host" in item) item.host = extensions
          if ("manifest" in item) item.manifest = holder.modelData
          extensions.revision++
        }
        onStatusChanged: {
          if (status !== Loader.Error) return
          // A broken extension costs only itself: it stays unloaded and the
          // host keeps the UI it had without one.
          console.warn("plugin extension " + holder.extensionId + " failed to load:",
            errorString && errorString() ? errorString() : "")
        }
      }
    }
  }

  // ------------------------------------------------------- called by extensions

  function openPane(component, entry) {
    extensions.paneEntry = entry === undefined ? null : entry
    extensions.paneComponent = component
  }

  function closePane() {
    if (!extensions.paneComponent) return
    extensions.paneComponent = null
    extensions.paneEntry = null
    extensions.paneClosed()
  }

  function requestClose() {
    extensions.closePane()
    extensions.closeRequested()
  }

  // ------------------------------------------------------------ called by hosts

  // Extensions that will act on this entry, in id order. A supports() that
  // throws drops that extension from the row rather than the row itself.
  function available(entry) {
    var offered = []
    var loaded = extensions.items
    for (var i = 0; i < loaded.length; i++) {
      var item = loaded[i]
      if (!item || !item.label) continue
      try {
        if (typeof item.supports !== "function" || item.supports(entry)) offered.push(item)
      } catch (error) {
        console.warn("plugin extension supports() threw:", error)
      }
    }
    return offered
  }

  function activate(item, entry) {
    if (!item || typeof item.activate !== "function") return false
    try {
      item.activate(entry)
    } catch (error) {
      console.warn("plugin extension activate() threw:", error)
      return false
    }
    return true
  }

  function handleKey(event, entry) {
    var candidates = available(entry)
    for (var i = 0; i < candidates.length; i++) {
      if (matchesShortcut(candidates[i].shortcut, event)) return activate(candidates[i], entry)
    }
    return false
  }

  function matchesShortcut(spec, event) {
    var shortcut = Extensions.parseShortcut(spec)
    if (!shortcut) return false
    if (shortcut.ctrl !== ((event.modifiers & Qt.ControlModifier) !== 0)) return false
    if (shortcut.shift !== ((event.modifiers & Qt.ShiftModifier) !== 0)) return false
    if (shortcut.alt !== ((event.modifiers & Qt.AltModifier) !== 0)) return false
    if (shortcut.meta !== ((event.modifiers & Qt.MetaModifier) !== 0)) return false
    return keyMatches(shortcut.key, event.key)
  }

  // Qt.Key_A..Z and Qt.Key_0..9 are their own ASCII codes, so a one-character
  // spec needs no table. Both Enter keys answer to one name; nobody writes
  // "Ctrl+KeypadEnter" in a manifest.
  function keyMatches(name, key) {
    if (name.length === 1) return key === name.charCodeAt(0)
    if (name === "ENTER" || name === "RETURN") return key === Qt.Key_Return || key === Qt.Key_Enter
    if (name === "ESC" || name === "ESCAPE") return key === Qt.Key_Escape
    if (name === "SPACE") return key === Qt.Key_Space
    if (name === "TAB") return key === Qt.Key_Tab
    if (name === "DELETE") return key === Qt.Key_Delete
    if (name === "BACKSPACE") return key === Qt.Key_Backspace
    return false
  }
}
