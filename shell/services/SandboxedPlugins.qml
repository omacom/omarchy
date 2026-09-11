import QtQuick
import Quickshell
import Quickshell.Hyprland

// Trusted lifecycle adapter. It selects only a host-owned component; plugin
// paths and QML never enter this engine. Rust owns admission and supervision.
QtObject {
  id: root
  property var instances: ({})
  property var lastErrors: ({})
  property var component: null
  property var bar: null
  property QtObject geometrySource: PluginDesktopGeometry {
    active: Object.values(root.instances).some(instance => !instance.error && instance.nativeSession.ready && instance.nativeSession.desktopGeometry)
  }
  property Connections workspaceChanges: Connections {
    target: Hyprland
    function onFocusedWorkspaceChanged() { root.dismissAll() }
    function onFocusedMonitorChanged() { root.dismissAll() }
    function onRawEvent(event) { root.handleHostEvent(event) }
  }
  property Connections popoutChanges: Connections {
    target: root.bar
    ignoreUnknownSignals: true
    function onActivePopoutChanged() {
      if (root.bar && root.bar.activePopout) root.dismissAll(root.bar.activePopout)
    }
  }
  property string store: Quickshell.env("OMARCHY_WARD_STORE")
    || (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/ward"
  property string controller: Quickshell.env("OMARCHY_WARD_HOST")
    || Quickshell.env("OMARCHY_PATH") + "/lib/omarchy-ward"
  signal changed()
  signal activated(string pluginId)
  signal blocked(string pluginId, int action)

  function status(id) {
    var instance = instances[id]
    if (!instance) return lastErrors[id] ? { state: "error", error: lastErrors[id] } : { state: "disabled", error: "" }
    return { state: instance.state, error: instance.error }
  }

  function ownSettings(entry) {
    var settings = JSON.parse(JSON.stringify(entry || {}))
    delete settings.id
    delete settings.sandbox
    delete settings.sandboxPresentation
    return settings
  }

  function overlayMode(entry) {
    var mode = entry && entry.sandboxPresentation && entry.sandboxPresentation.overlayMode
    return mode === "visual" || mode === "pointer" ? mode : "none"
  }

  function coordinate(instance) {
    const owner = instance.barOwner || instance
    // Worker state alone cannot acquire host popup ownership.
    if (instance.opened && instance.focusHeld) {
      dismissAll(instance)
      if (bar && typeof bar.requestPopout === "function") bar.requestPopout(owner)
    } else if (bar && typeof bar.releasePopout === "function") bar.releasePopout(owner)
  }

  function enable(id, entry, placed) {
    if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(id) || id.indexOf("..") !== -1)
      return "invalid plugin id"
    const errors = Object.assign({}, lastErrors)
    delete errors[id]
    lastErrors = errors
    var previous = instances[id]
    if (previous && previous.state !== "error") return previous.state === "running" ? "ok" : "starting"
    if (!component) component = Qt.createComponent("native/SandboxedPluginSession.qml")
    if (component.status !== Component.Ready)
      return "native plugin host unavailable: " + component.errorString()
    if (previous) disable(id)
    if (Object.keys(instances).length >= 16) return "too many active sandbox plugins"
    var instance = component.createObject(root, {
      pluginId: id, store: store, controller: controller, settings: ownSettings(entry), geometrySource: geometrySource,
      overlayOutputs: entry && entry.sandboxPresentation && entry.sandboxPresentation.overlayOutputs === "all" ? "all" : "owner",
      overlayMode: overlayMode(entry)
    })
    if (!instance) return "could not create native plugin host: " + component.errorString()
    var next = Object.assign({}, instances)
    next[id] = instance
    instances = next
    instance.statusChanged.connect(function() {
      if (instances[id] !== instance) return
      changed()
      if (instance.state === "running") activated(id)
    })
    instance.operationBlocked.connect(function(action) {
      if (instances[id] === instance) root.blocked(id, action)
    })
    var coordinate = function() {
      if (instances[id] !== instance) return
      root.coordinate(instance)
    }
    instance.openedChanged.connect(coordinate)
    instance.focusHeldChanged.connect(coordinate)
    let lastOwner = instance.barOwner || instance
    instance.barOwnerChanged.connect(function() {
      if (bar && typeof bar.releasePopout === "function") bar.releasePopout(lastOwner)
      lastOwner = instance.barOwner || instance
      coordinate()
    })
    instance.panelSwitchRequested.connect(function(direction) {
      if (instances[id] === instance && instance.barOwner && bar && typeof bar.switchPanelFrom === "function")
        bar.switchPanelFrom(instance.barOwner, direction)
    })
    changed()
    return "starting"
  }

  function disable(id) {
    const errors = Object.assign({}, lastErrors)
    delete errors[id]
    lastErrors = errors
    var instance = instances[id]
    if (!instance) return
    if (bar && typeof bar.releasePopout === "function") bar.releasePopout(instance.barOwner || instance)
    var next = Object.assign({}, instances)
    delete next[id]
    instances = next
    instance.stop()
    instance.destroy()
    changed()
  }

  function fail(id, error) {
    disable(id)
    const errors = Object.assign({}, lastErrors)
    errors[id] = String(error)
    lastErrors = errors
    changed()
  }

  function show(id, payload, owner) {
    var instance = instances[id]
    if (!instance || instance.state === "error") return false
    return instance.setPanel(true, payload, owner || null)
  }

  function hide(id) {
    var instance = instances[id]
    if (!instance) return false
    return instance.dismiss()
  }

  // Closing private panels must not unmap their persistent bar widgets.
  function handleHostEvent(event) {
    if (String(event && event.name || "") !== "openwindow") return
    var parts
    try { parts = event.parse(4) }
    catch (error) { parts = String(event && event.data || "").split(",") }
    // Lifecycle policy stays in the host: no compositor events cross the boundary.
    if (String(parts && parts[2] || "") === "org.omarchy.screensaver") dismissAll()
  }

  function dismissAll(except) {
    for (var id in instances) {
      if (instances[id] !== except && instances[id].barOwner !== except) instances[id].dismiss()
    }
  }

  function isOpen(id) { return !!instances[id] && instances[id].opened }

  function sync(entries, barEntries) {
    barEntries = barEntries || []
    const placedIds = barEntries.map(entry => entry.id)
    entries = entries.concat(barEntries)
    var desired = ({})
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      if (entry && entry.sandbox === true) {
        desired[String(entry.id)] = true
        if (!instances[entry.id]) {
          if (!lastErrors[entry.id]) {
            var result = enable(String(entry.id), entry, placedIds.indexOf(entry.id) !== -1)
            if (result !== "starting" && result !== "ok") console.warn(result)
          }
        } else {
          instances[entry.id].settings = ownSettings(entry)
          instances[entry.id].overlayOutputs = entry.sandboxPresentation && entry.sandboxPresentation.overlayOutputs === "all" ? "all" : "owner"
          instances[entry.id].overlayMode = overlayMode(entry)
        }
      }
    }
    for (var id in instances) if (!desired[id]) disable(id)
  }
}
