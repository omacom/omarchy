#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

function functionBody(name) {
  const match = shellQml.match(new RegExp(`function ${name}\\([^)]*\\)[^{]*\\{[\\s\\S]*?\\n  \\}`))
  return match ? match[0] : ''
}

assert(
  /property bool pluginsPaused:\s*false/.test(shellQml),
  'the shell tracks whether plugin loads are paused'
)

// Every path that can create plugin QML from a manifest must respect the
// pause. Otherwise an update can still hot-load the half-installed tree into
// the running engine, which is the failure this guard exists to prevent.
for (const name of [
  'reloadPlugins',
  'finishPluginReload',
  '_syncServices',
  'syncPanelEntries',
  'syncPluginWidgets',
  'loadPluginWidget',
  'ensureService'
]) {
  const body = functionBody(name)
  assert(body.length > 0, `${name} is defined`)
  assert(
    /pluginsPaused/.test(body),
    `${name} refuses to load plugin code while plugin loads are paused`
  )
}

const summon = functionBody('summon')
assert(summon.length > 0, 'summon is defined')
assert(
  /pluginsPaused[\s\S]*panelLoaders[\s\S]*\.item/.test(summon),
  'summon still opens an already-loaded panel but loads no new plugin while paused'
)

const scan = shellQml.match(/function onScanFinished\(\) \{[\s\S]*?\n    \}/)
assert(!!scan, 'the plugin registry scan completion handler is defined')
assert(
  /pluginsPaused/.test(scan[0]),
  'scan completion does not sync plugin entries while paused'
)

const pause = shellQml.match(/function pausePlugins\(\): string \{[\s\S]*?\n    \}/)
assert(!!pause, 'the shell IPC target exposes pausePlugins')
assert(
  /shell\.pluginsPaused = true/.test(pause[0]),
  'pausePlugins stops further plugin loads'
)
assert(
  /return "ok"/.test(pause[0]),
  'pausePlugins answers ok so the update guard can tell a supported shell from an old one'
)
JS
