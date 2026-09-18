#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const registrySource = fs.readFileSync(root + '/shell/services/PluginRegistry.qml', 'utf8')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

assert(
  /function localPluginQmlChangedForPath\(filePath\) \{[\s\S]*?\/\\\.qml\$\/i\.test/.test(registrySource),
  'the plugin watcher identifies QML changes case-insensitively'
)
assert(
  /localPluginChanged\(pluginId, registry\.localPluginQmlChangedForPath\(path\)\)/.test(registrySource),
  'the plugin watcher reports whether changed content is QML'
)
assert(
  /if \(qmlSourceChanged\) shell\.localPluginQmlReloadPending = true/.test(shellSource),
  'QML changes request an engine reload'
)
assert(
  /if \(shell\.localPluginQmlReloadPending\) \{[\s\S]*?Quickshell\.reload\(false\)[\s\S]*?\} else \{[\s\S]*?shell\.reloadPlugins\(\)/.test(shellSource),
  'only QML changes soft-reload the shell engine'
)
assert(
  !shellSource.includes('Qt.clearComponentCache'),
  'plugin reload does not call the unavailable QML cache API'
)
JS
