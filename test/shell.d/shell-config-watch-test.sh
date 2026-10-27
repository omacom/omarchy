#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

function fileView(id) {
  const match = shellQml.match(new RegExp(`FileView \\{\\s*id: ${id}\\b[\\s\\S]*?\\n  \\}`))
  return match ? match[0] : ''
}

const defaults = fileView('defaultsFile')
const user = fileView('userConfigFile')

assert(defaults.length > 0, 'shell.qml defines the default shell.json FileView')
assert(user.length > 0, 'shell.qml defines the user shell.json FileView')

// The default shell.json belongs to the package. Watching it makes a running
// shell apply a half-installed plugin list during an update; the shell is
// restarted after the transaction instead.
assert(
  /watchChanges:\s*false/.test(defaults) && !/onFileChanged\s*:/.test(defaults),
  'the package-owned default shell.json is read at startup, not watched for changes'
)

// A user's own shell.json is theirs to edit while the shell runs.
assert(
  /watchChanges:\s*true/.test(user) && /onFileChanged\s*:\s*reload\(\)/.test(user),
  'the user shell.json keeps live reload'
)

const reloadConfig = shellQml.match(/function reloadConfig\(\): string \{[\s\S]*?\n    \}/)
assert(!!reloadConfig, 'shell.qml defines reloadConfig')
assert(
  /userConfigFile\.reload\(\)/.test(reloadConfig[0]) && !/defaultsFile\.reload\(\)/.test(reloadConfig[0]),
  'reloadConfig only reloads the user shell.json'
)
JS
