#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

assert(
  /pluginRegistry\.installedPlugins\[key\]/.test(qml),
  'pluginShellFor prefers the registry manifest over Instantiator modelData'
)
assert(
  /typeof kinds\.indexOf === "function"/.test(qml) ||
    /kinds\.length/.test(qml) && /QVariantList/.test(qml),
  'manifestHasKind accepts QVariantList kinds from a panel Instantiator'
)
assert(
  !/return !!manifest && Array\.isArray\(manifest\.kinds\)/.test(qml),
  'manifestHasKind no longer requires a JS Array, which Instantiator modelData is not'
)
JS
