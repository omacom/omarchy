#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the host's real configuration functions with the user read delayed
# behind defaults and an automatic widget save. No live config is touched.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
function extract(name) {
  const start = source.indexOf('  function ' + name + '(')
  const end = source.indexOf('\n  }', start)
  if (start < 0 || end < 0) throw new Error('missing function ' + name)
  return source.slice(start, end + 4)
}
const fileView = source.slice(source.indexOf('    id: userConfigFile'), source.indexOf('\n  Component.onCompleted:'))
function callback(signature, declaration) {
  const start = fileView.indexOf(signature)
  const end = fileView.indexOf('\n    }', start)
  if (start < 0 || end < 0) throw new Error('missing callback ' + signature)
  return declaration + fileView.slice(start + signature.length, end) + '\n}'
}
const errors = { Success: 0, FileNotFound: 1, PermissionDenied: 2, NotAFile: 3 }
const defaults = { version: 1, plugins: [], bar: { layout: { center: [{ id: 'omarchy.elsewhen' }] } } }
const user = { version: 1, plugins: [{ id: 'acme.wallpaper' }], notifications: { font: 'system' }, bar: { layout: { right: [{ id: 'acme.phone' }] } } }
let text = ''
const writes = []
const host = {
  builtinShellConfig: defaults, defaultsConfig: defaults, shellConfig: defaults,
  userConfigReady: false, shellConfigWritable: false, userConfigLoadError: errors.Success,
  FileViewError: errors, console: { warn() {} },
  Util: { isPlainObject: v => v !== null && typeof v === 'object' && !Array.isArray(v) },
  userConfigFile: { text: () => text, setText: v => writes.push(JSON.parse(v)) }
}
host.shell = host
vm.createContext(host)
for (const name of ['applyShellConfig', 'loadDefaults', 'persistShellConfig', 'mutateShellConfig'])
  vm.runInContext(extract(name), host)
vm.runInContext(callback('onLoaded: {', 'function loaded() {'), host)
vm.runInContext(callback('onLoadFailed: function(error) {', 'function loadFailed(error) {'), host)

host.loadDefaults(JSON.stringify(defaults))
host.mutateShellConfig(c => { c.bar.layout.center[0].zones = 'Amsterdam|Europe/Amsterdam' })
assertEqual(writes.length, 0, 'an automatic widget save cannot overwrite a pending user read')
text = JSON.stringify(user)
host.loaded()
assertEqual(host.userConfigReady, true, 'successful-read callback marks the user config ready')
host.mutateShellConfig(c => { c.notifications.font = 'Inter' })
assertDeepEqual(writes[0].plugins, user.plugins, 'a save after loading preserves enabled third-party services')
assertDeepEqual(writes[0].bar, user.bar, 'a save after loading preserves custom bar widgets')
assertEqual(writes[0].notifications.font, 'Inter', 'valid configuration remains editable')

for (const invalid of ['{broken', '{"version":2}', '']) {
  text = invalid
  host.loaded()
  const count = writes.length
  host.mutateShellConfig(c => { c.notifications = { font: 'default' } })
  assertEqual(writes.length, count, 'fallback display does not overwrite invalid user JSON: ' + JSON.stringify(invalid))
}
for (const error of [errors.PermissionDenied, errors.NotAFile]) {
  host.userConfigReady = false
  host.loadFailed(error)
  assertEqual(host.userConfigReady, true, 'failed-read callback finishes the initial read')
  assertEqual(host.userConfigLoadError, error, 'failed-read callback retains the read error')
  const count = writes.length
  host.persistShellConfig(defaults)
  assertEqual(writes.length, count, 'a failed read cannot be replaced by defaults: ' + error)
}
host.loadFailed(errors.FileNotFound)
const count = writes.length
host.mutateShellConfig(c => { c.plugins.push({ id: 'acme.new' }) })
assertEqual(writes.length, count + 1, 'first-run configuration can still be created when the file is missing')
host.loadFailed(errors.PermissionDenied)
text = JSON.stringify(user)
host.loaded()
assertEqual(host.userConfigLoadError, errors.Success, 'successful-read callback clears a previous read error')
assertDeepEqual(host.shellConfig.plugins, user.plugins, 'a repaired file restores the configured plugins')
const repairedCount = writes.length
assertEqual(host.mutateShellConfig(c => { c.notifications.font = 'Inter' }), true, 'saving resumes after a successful read following a failure')
assertEqual(writes.length, repairedCount + 1, 'recovery actually writes the settings change')
assertDeepEqual(writes[repairedCount].plugins, user.plugins, 'the recovery save preserves custom services')
JS
