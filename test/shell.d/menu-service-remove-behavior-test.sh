#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stub_dir=$(mktemp -d)
calls=$(mktemp)
trap 'rm -rf "$stub_dir" "$calls"' EXIT

cat >"$stub_dir/pacman" <<'STUB'
#!/bin/bash
case "$1" in
-Qq)
  if [[ -n ${INSTALLED_PACKAGES:-} ]]; then
    printf '%s\n' $INSTALLED_PACKAGES
  fi
  ;;
-Qi)
  for package in ${INSTALLED_PACKAGES:-}; do
    printf 'Name            : %s\nProvides        : None\n' "$package"
  done
  ;;
-Q)
  shift
  [[ ${1:-} == "--" ]] && shift
  for package in "$@"; do
    [[ " ${INSTALLED_PACKAGES:-} " == *" $package "* ]] || exit 1
  done
  ;;
esac
STUB

cat >"$stub_dir/omarchy-launch-floating-terminal-with-presentation" <<'STUB'
#!/bin/bash
printf '<%s>\n' "$@" >>"$CALLS"
STUB
chmod +x "$stub_dir"/*
export CALLS="$calls"
export PATH="$stub_dir:$PATH"

run_node_test <<'JS'
const fs = require('fs')
const childProcess = require('child_process')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const serviceRows = items.filter(item => item.id.startsWith('remove.service.') && /^omarchy-pkg-present [a-z0-9@+_.-]+$/.test(item.when))

assert(serviceRows.length > 0, 'menu ships package-guarded service removal rows')

function evaluateGuard(row, installed) {
  const output = childProcess.execFileSync('bash', ['-c', menu.guardScript({ [row.id]: row })], {
    encoding: 'utf8',
    timeout: 5000,
    env: { ...process.env, XDG_RUNTIME_DIR: '', INSTALLED_PACKAGES: installed }
  }).trim()
  const match = new RegExp(`^${row.id.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}:w:([01])$`).exec(output)
  assert(match, `${row.id} guard batch returns its result`, output)
  return { [row.id]: match[1] === '1' }
}

for (const row of serviceRows) {
  assert(/^remove\.service\.[a-z0-9-]+$/.test(row.id), 'service removal ids are safe shell tokens', row.id)
  const packageName = row.when.split(' ')[1]
  const serviceName = row.id.slice('remove.service.'.length)
  const absentResults = evaluateGuard(row, '')
  const presentResults = evaluateGuard(row, packageName)

  assert(!menu.isVisible({ [row.id]: row }, [row.id], absentResults, row), `${row.id} is hidden when ${packageName} is absent`)
  assert(menu.isVisible({ [row.id]: row }, [row.id], presentResults, row), `${row.id} is visible when ${packageName} is present`)

  const expectedAction = `omarchy-launch-floating-terminal-with-presentation omarchy-remove-service-${serviceName}`
  assertEqual(row.action, expectedAction, `${row.id} has only its safe presentation-wrapped removal command`)

  fs.writeFileSync(process.env.CALLS, '')
  childProcess.execFileSync('bash', ['-c', row.action], { env: process.env, timeout: 5000 })
  assertEqual(
    fs.readFileSync(process.env.CALLS, 'utf8'),
    `<omarchy-remove-service-${serviceName}>\n`,
    `${row.id} dispatches its matching removal command through the presentation terminal`
  )
}
JS
