#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Every service the menu can install, and that ships a removal script, must
# also be removable from Remove > Services. 1Password shipped
# omarchy-remove-service-1password with only the install row (#15485).

run_node_test <<'JS'
const fs = require('fs')
const MenuModel = requireFromRoot('shell/plugins/menu/MenuModel.js')

const items = MenuModel.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const ids = new Set(items.map((item) => item.id))

const installed = items
  .map((item) => /^install\.service\.([^.]+)$/.exec(item.id))
  .filter(Boolean)
  .map((match) => match[1])
assert(installed.includes('1password'), 'Install > Services offers 1Password')

const removable = installed.filter((name) => fs.existsSync(path.join(root, 'bin', `omarchy-remove-service-${name}`)))
assert(removable.length > 0, 'at least one installable service ships a removal script')

const missing = removable.filter((name) => !ids.has(`remove.service.${name}`))
assert(missing.length === 0, 'every installable service with a removal script has a Remove > Services row', JSON.stringify(missing))

for (const name of removable) {
  const row = items.find((item) => item.id === `remove.service.${name}`)
  if (!row) continue
  assert(
    typeof row.action === 'string' && row.action.includes(`omarchy-remove-service-${name}`),
    `remove.service.${name} runs omarchy-remove-service-${name}`,
    row.action
  )
}
JS
