import QtQuick
import qs.Commons

// Provisional placements are presentation state, never saved enable intent.
// The shell remains the sole writer of its canonical config.
QtObject {
  id: root
  required property var manager
  required property var registry
  required property var config
  required property var writeConfig
  property var pending: ({})
  readonly property var previewConfig: preview(config, pending)
  onConfigChanged: Qt.callLater(settle)

  property Connections managerChanges: Connections {
    target: root.manager
    function onChanged() { Qt.callLater(root.settle) }
  }
  property Connections registryChanges: Connections {
    target: root.registry
    function onPluginsChanged() { Qt.callLater(root.settle) }
  }

  function entry(config, id) {
    const location = registry.findEntryLocation(config, id)
    return location.kind === "bar" ? config.bar.layout[location.section][location.index]
      : location.kind === "plugin" ? config.plugins[location.index] : { id: id }
  }

  function snapshot(config, id) {
    const entries = []
    const layout = config.bar && config.bar.layout || {}
    for (const section of ["left", "center", "right"]) {
      for (const value of layout[section] || []) {
        if (value && value.id === id) entries.push({ section: section, entry: value })
      }
    }
    for (const value of config.plugins || []) {
      if (value && value.id === id) entries.push({ section: "plugins", entry: value })
    }
    return JSON.stringify({ entries: entries, disabled: (config.disabledPlugins || []).indexOf(id) !== -1 })
  }

  function proposal(config, id, placement) {
    const manifest = registry.installedPlugins[id]
    if (!manifest || !registry.isSandboxed(id)) return { error: "unknown sandbox plugin" }
    const placed = manifest.entryPoints.barWidget && !manifest.sandbox?.entryPoint
    if (!placed && Object.keys(placement).length) return { error: "this plugin has no shared bar widget" }
    const copy = JSON.parse(JSON.stringify(config))
    if (placed) {
      const error = registry.placeSandboxedWidgetIn(copy, id, placement)
      if (error) return { error: error }
    } else {
      const existing = entry(copy, id)
      if (!Array.isArray(copy.plugins)) copy.plugins = []
      copy.plugins = copy.plugins.filter(value => value.id !== id)
      copy.plugins.push(Object.assign({}, existing, { id: id, sandbox: true }))
    }
    return { config: copy, placed: !!placed }
  }

  function preview(config, pending) {
    let next = config
    for (const id of Object.keys(pending)) {
      const result = proposal(next, id, pending[id].placement)
      if (!result.error) next = result.config
    }
    return next
  }

  function forget(id) {
    const next = Object.assign({}, pending)
    delete next[id]
    pending = next
  }

  function enable(id, placement) {
    if (!Util.isPlainObject(placement)) return "invalid placement"
    if (pending[id] && manager.status(id).state === "starting")
      return "plugin is already starting; wait before changing placement"
    const result = proposal(config, id, placement)
    if (result.error) return result.error
    const state = manager.enable(id, entry(config, id), result.placed)
    if (state === "ok") {
      writeConfig(result.config)
      forget(id)
    } else if (state === "starting") {
      const next = Object.assign({}, pending)
      next[id] = {
        placement: JSON.parse(JSON.stringify(placement)),
        instance: manager.instances[id], original: snapshot(config, id)
      }
      pending = next
      Qt.callLater(settle)
    }
    return state
  }

  function disable(id) {
    forget(id)
    manager.disable(id)
  }

  function status(id) {
    const state = manager.status(id)
    return pending[id] && state.state === "running" ? { state: "starting", error: "" } : state
  }

  function settle() {
    for (const id of Object.keys(pending)) {
      const request = pending[id]
      if (!request) continue
      // A stale completion must not commit for a replacement or cancelled run.
      if (manager.instances[id] !== request.instance) {
        forget(id)
        continue
      }
      const result = proposal(config, id, request.placement)
      const state = manager.status(id)
      const error = state.error || result.error
        || (snapshot(config, id) !== request.original ? "plugin configuration changed during startup" : "")
      if (error) {
        forget(id)
        manager.fail(id, error)
      } else if (state.state === "running") {
        // Rebase only this operation on the latest config. Other pending
        // placements and concurrent settings changes never enter this write.
        writeConfig(result.config)
        forget(id)
      }
    }
  }
}
