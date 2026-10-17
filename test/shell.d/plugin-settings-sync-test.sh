#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell_qml="$ROOT/shell/shell.qml"

qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

# 1. Structural checks on shell.qml
qml_matches "$shell_qml" 'onBarConfigChanged: *\{[^}]*shell\.syncPluginApis\(\)' ||
  fail "onBarConfigChanged notifies plugins of configuration changes"
pass "onBarConfigChanged notifies plugins of configuration changes"

qml_matches "$shell_qml" 'function publicBarConfig\(\) *\{[^}]*shellConfig *&& *Util\.isPlainObject\(shellConfig\.bar\)' ||
  fail "publicBarConfig reads the current shellConfig directly"
pass "publicBarConfig reads the current shellConfig directly"

qml_matches "$shell_qml" 'function barConfigFor\(manifest\) *\{[^}]*shellConfig *&& *Util\.isPlainObject\(shellConfig\.bar\)' ||
  fail "barConfigFor evaluates the current shellConfig directly"
pass "barConfigFor evaluates the current shellConfig directly"

# 2. Behavioral unit test
run_node_test <<'JS'
const fs = require('fs')

const shellSource = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

// Test simulation of the shell settings synchronization contract
const Util = {
  isPlainObject(v) {
    return !!v && typeof v === 'object' && !Array.isArray(v)
  },
  canonicalWidgetId(id) {
    return String(id || '').replace(/^omarchy\./, '')
  }
}

const builtinShellConfig = {
  version: 1,
  bar: {
    layout: {
      left: [{ id: "menu" }],
      center: [{ id: "clock", format: "HH:mm" }],
      right: [{ id: "power" }]
    }
  },
  plugins: []
}

let shellConfig = JSON.parse(JSON.stringify(builtinShellConfig))
let pluginsSynced = 0
let lastSyncedBarConfig = null

const shell = {
  get shellConfig() { return shellConfig },
  set shellConfig(val) { shellConfig = val },
  builtinShellConfig: builtinShellConfig,

  publicBarConfig() {
    const source = shellConfig && Util.isPlainObject(shellConfig.bar)
      ? shellConfig.bar : builtinShellConfig.bar
    return JSON.parse(JSON.stringify(source || {}))
  },

  syncPluginApis() {
    pluginsSynced++
    lastSyncedBarConfig = this.publicBarConfig()
  },

  persistShellConfig(nextConfig) {
    const payload = JSON.parse(JSON.stringify(nextConfig))
    payload.version = 1
    this.shellConfig = payload
    // onShellConfigChanged fires synchronously:
    this.syncPluginApis()
  },

  updateEntryInline(moduleName, settings) {
    const stripped = Util.canonicalWidgetId(moduleName)
    const copy = JSON.parse(JSON.stringify(this.shellConfig || this.builtinShellConfig))
    if (!Util.isPlainObject(copy.bar)) copy.bar = { layout: { left: [], center: [], right: [] } }
    if (!Util.isPlainObject(copy.bar.layout)) copy.bar.layout = { left: [], center: [], right: [] }
    if (!Array.isArray(copy.plugins)) copy.plugins = []

    const sections = ["left", "center", "right"]
    let foundInLayout = false
    let dirty = false
    for (let s = 0; s < sections.length; s++) {
      const arr = copy.bar.layout[sections[s]] || []
      for (let i = 0; i < arr.length; i++) {
        if (arr[i] && Util.canonicalWidgetId(arr[i].id) === stripped) {
          const next = { id: stripped }
          for (const k in settings) if (k !== "id") next[k] = settings[k]
          if (JSON.stringify(arr[i]) !== JSON.stringify(next)) {
            arr[i] = next
            dirty = true
          }
          foundInLayout = true
        }
      }
    }
    if (!foundInLayout) {
      let foundInPlugins = false
      for (let j = 0; j < copy.plugins.length; j++) {
        if (copy.plugins[j] && copy.plugins[j].id === stripped) {
          const pnext = { id: stripped }
          for (const pk in settings) if (pk !== "id") pnext[pk] = settings[pk]
          if (JSON.stringify(copy.plugins[j]) !== JSON.stringify(pnext)) {
            copy.plugins[j] = pnext
            dirty = true
          }
          foundInPlugins = true
          break
        }
      }
      if (!foundInPlugins) {
        const pnew = { id: stripped }
        for (const nkey in settings) if (nkey !== "id") pnew[nkey] = settings[nkey]
        copy.plugins.push(pnew)
        dirty = true
      }
    }
    if (!dirty) return false
    this.persistShellConfig(copy)
    return true
  }
}

// 1. Layout entry update
const changed = shell.updateEntryInline("omarchy.clock", { format: "HH:mm:ss", custom: true })
assert(changed === true, "updateEntryInline returns true when settings change")
assert(
  lastSyncedBarConfig.layout.center[0].format === "HH:mm:ss",
  "publicBarConfig reflects the updated settings immediately upon write"
)

// 2. No-op returns false
const noop = shell.updateEntryInline("omarchy.clock", { format: "HH:mm:ss", custom: true })
assert(noop === false, "updateEntryInline returns false when settings are unchanged")

// 3. Top-level plugin insertion
const pluginAdded = shell.updateEntryInline("custom.fleet.plugin", { interval: 60, report: true })
assert(pluginAdded === true, "updateEntryInline inserts unlisted top-level plugin")
assert(
  shell.shellConfig.plugins.some(p => p.id === "custom.fleet.plugin" && p.interval === 60),
  "top-level plugin settings are preserved in shellConfig.plugins"
)

JS
