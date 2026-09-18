#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const styleSource = fs.readFileSync(root + '/shell/Commons/Style.qml', 'utf8')
const barConfigBranch = styleSource.match(
  /else if \(section === .bar.\) \{([\s\S]*?)else if \(section === .spacing.\)/
)[1]

for (const token of ['size-horizontal', 'size-vertical', 'icon-slot', 'icon-canvas', 'icon-font', 'status-slot']) {
  assert(
    barConfigBranch.includes(token),
    `[bar] ${token} is accepted from shell.toml`
  )
}
JS
