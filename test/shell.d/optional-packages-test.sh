#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Package conditions retain complete targets and independent ARM support cases.
run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = new Map(items.map(item => [item.id, item]))
const transactions = new Map(items.filter(item => (item.when || '').startsWith('omarchy-pkg-available '))
  .map(item => [item.id, item.when.split(/\s+/).slice(1)]))
const required = fs.readFileSync(path.join(root, 'test/fixtures/optional-aarch64-required'), 'utf8')
  .split('\n').filter(line => line.startsWith('install.'))
for (const id of required) assert(transactions.has(id), `ARM support case retains package guard: ${id}`)
const unguarded = items.filter(item => item.id.startsWith('install.') && /omarchy-pkg-present /.test(item.disabled || ''))
  .filter(item => !/^(omarchy-pkg-available |\[\[ \$\(uname -m\))/.test(item.when || '')).map(item => item.id)
assertDeepEqual(unguarded, [], 'package installs have package or architecture guards')

// The secondary packages are the ones a port loses first, and the ones a
// presence check on the primary package would never notice.
const requiredSecondaryPackages = {
  'install.service.1password': ['1password-cli'],
  'install.service.dropbox': ['dropbox-cli', 'libappindicator-gtk3', 'python-gpgme', 'nautilus-dropbox'],
  'install.service.bitwarden': ['bitwarden-cli'],
  'install.ai.dictation': ['wtype'],
  'install.gaming.retroarch': ['libretro-blastem', 'libretro-ppsspp', 'libretro-fbneo-git', 'retroarch-joypad-autoconfig-git'],
  'install.gaming.lutris': ['umu-launcher', 'wine-staging', 'wine-mono', 'wine-gecko', 'winetricks', 'python-protobuf'],
  'install.development.php.php': ['composer', 'php-sqlite', 'xdebug'],
  'install.development.php.symfony': ['composer', 'php-sqlite', 'xdebug', 'symfony-cli']
}
for (const [id, expected] of Object.entries(requiredSecondaryPackages)) {
  assertDeepEqual(
    expected.filter(packageName => !transactions.get(id).includes(packageName)),
    [],
    `optional package transaction includes secondary packages: ${id}`
  )
}
JS

# Runtime and batch behavior is exercised in optional-availability-test.sh.
