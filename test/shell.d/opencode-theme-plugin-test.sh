#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const pluginTs = fs.readFileSync(path.join(root, 'config/opencode/tui-plugins/omarchy-theme.ts'), 'utf8')

assert(
  !/if \(filename && filename !==/.test(pluginTs),
  'theme watcher reacts to every directory event (Bun misses the atomic rename onto omarchy.json)'
)
assert(
  /fs\.watch\(dir/.test(pluginTs) && /schedule\(\)/.test(pluginTs),
  'theme watcher keeps a debounced apply behind directory events'
)
assert(
  /text = fs\.readFileSync\(file, "utf8"\)/.test(pluginTs),
  'theme apply re-reads omarchy.json from disk on every run'
)
JS
