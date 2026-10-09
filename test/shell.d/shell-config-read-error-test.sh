#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Run the actual config methods and FileView event handlers without starting a
# desktop. FileView state is a fixture; its setText boundary records writes.
run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')

function check(condition, description) { if (!condition) fail(description) }
function checkEqual(actual, expected, description) {
  if (actual !== expected) fail(description, JSON.stringify({ actual, expected }))
}

function extract(signature) {
  const start = source.indexOf(`  ${signature}`)
  const end = source.indexOf('\n  }', start)
  check(start >= 0 && end > start, `found production ${signature}`)
  return source.slice(start, end + '\n  }'.length)
}

const viewStart = source.indexOf('    id: userConfigFile')
const userView = source.slice(viewStart, source.indexOf('  Component.onCompleted:', viewStart))
const loadedHandler = userView.match(/onLoaded:\s*([\s\S]*?)\s+onLoadFailed:/)
const failedHandler = userView.match(/onLoadFailed:\s*([\s\S]*?)\n\s*onFileChanged:/)
check(loadedHandler && failedHandler, 'found production user FileView event handlers')
// Quickshell.Io FileViewError values. Existing unreadable files can still have
// loaded=true: FileView bases that property on existence, not read success.
const FileViewError = { Unknown: 1, FileNotFound: 2, PermissionDenied: 3, NotAFile: 4 }
const methods = ['function applyShellConfig() {', 'function loadDefaults(raw) {',
  'function persistShellConfig(nextConfig) {', 'function mutateShellConfig(mutator) {']

function harness(writer) {
  const defaults = { version: 1, bar: { position: 'top', layout: { center: [{ id: 'omarchy.clock', format: 'dddd HH:mm' }] } } }
  const state = { text: '', writes: [] }
  const context = {
    builtinShellConfig: defaults, defaultsConfig: defaults, shellConfig: defaults,
    userConfigReadFailed: false, userConfigUnreadable: false, FileViewError,
    console: { warn() {} },
    Util: { isPlainObject: value => value !== null && typeof value === 'object' && !Array.isArray(value) },
    userConfigFile: {
      loaded: true, text: () => state.text,
      setText: value => { state.writes.push(value); if (writer) writer(value) }
    }
  }
  context.shell = context
  vm.createContext(context)
  vm.runInContext(methods.map(extract).join('\n') +
    '\nfunction loadedEvent() { ' + loadedHandler[1] + ' }' +
    '\nvar failedEvent = ' + failedHandler[1], context)
  return {
    context, state,
    loaded(text) { state.text = text; context.userConfigFile.loaded = true; context.loadedEvent() },
    failed(error) { state.text = ''; context.userConfigFile.loaded = error !== FileViewError.FileNotFound; context.failedEvent(error) },
    change(format) { context.mutateShellConfig(config => { config.bar.layout.center[0].format = format }) }
  }
}

const userText = JSON.stringify({ version: 1, userMarker: 'hand-edited-settings', bar: { position: 'bottom', layout: { center: [{ id: 'omarchy.clock', format: 'H:mm' }] } } }) + '\n'
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-shell-read-error-'))
try {
  const config = path.join(scratch, 'shell.json')
  fs.writeFileSync(config, userText, { mode: 0o600 })
  fs.chmodSync(config, 0o200)
  let errorCode = ''
  try { fs.readFileSync(config, 'utf8') } catch (error) { errorCode = error.code }
  if (errorCode === 'EACCES') {
    fs.accessSync(config, fs.constants.W_OK)
    const test = harness(value => {
      // Model the atomic writer in this private directory, so an accidental
      // setText would really replace our owned write-only file.
      const temporary = path.join(scratch, 'replacement')
      fs.writeFileSync(temporary, value, { mode: 0o200 })
      fs.renameSync(temporary, config)
    })
    test.failed(FileViewError.PermissionDenied)
    test.change('HH:mm')
    fs.chmodSync(config, 0o600)
    checkEqual(fs.readFileSync(config, 'utf8'), userText, 'read failure preserves the owned write-only config bytes')
    checkEqual(test.state.writes.length, 0, 'read failure does not request an atomic write')
    checkEqual(test.context.shellConfig.bar.layout.center[0].format, 'HH:mm', 'blocked persistence still changes clock settings in memory')
    pass('read failure preserves an owned write-only file while session settings remain available')
  } else if (!errorCode) {
    pass('owned write-only filesystem case requires read-permission enforcement # SKIP process can read mode 0200')
  } else {
    fail('owned write-only filesystem fixture failed unexpectedly', errorCode)
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}

for (const error of [FileViewError.PermissionDenied, FileViewError.Unknown, FileViewError.NotAFile]) {
  const test = harness()
  test.failed(error)
  test.change('HH:mm')
  checkEqual(test.state.writes.length, 0, `read error ${error} blocks writes despite empty text and loaded=true`)
  checkEqual(test.context.shellConfig.bar.layout.center[0].format, 'HH:mm', `read error ${error} keeps changes in memory`)
  test.context.loadDefaults(JSON.stringify(test.context.builtinShellConfig))
  test.change('H:mm')
  checkEqual(test.state.writes.length, 0, `defaults reload does not clear read error ${error}`)
  pass(`read error ${error} blocks persistence across repeated config/default application`)
}

for (const recovery of ['valid', 'empty', 'missing']) {
  const test = harness()
  test.failed(FileViewError.PermissionDenied)
  if (recovery === 'missing') test.failed(FileViewError.FileNotFound)
  else test.loaded(recovery === 'valid' ? userText : '')
  test.change('HH:mm')
  checkEqual(test.state.writes.length, 1, `${recovery} recovery resumes persistence`)
  const saved = JSON.parse(test.state.writes[0])
  checkEqual(saved.bar.layout.center[0].format, 'HH:mm', `${recovery} recovery saves current settings`)
  if (recovery === 'valid') checkEqual(saved.userMarker, 'hand-edited-settings', 'valid recovery retains user customization')
  pass(`${recovery} recovery clears the read failure and permits saving`)
}

for (const text of ['{', '{"bar":{}}']) {
  const test = harness()
  test.failed(FileViewError.PermissionDenied)
  test.loaded(text)
  test.change('HH:mm')
  checkEqual(test.state.writes.length, 0, 'successful reading of unusable text still blocks saving')
  checkEqual(test.context.shellConfig.bar.layout.center[0].format, 'HH:mm', 'unusable text still permits in-memory changes')
  test.loaded(userText)
  test.change('H:mm')
  checkEqual(test.state.writes.length, 1, 'repairing unusable text resumes saving')
  pass(`loaded ${text === '{' ? 'invalid JSON' : 'missing version'} remains protected until repaired`)
}

const missing = harness()
missing.failed(FileViewError.FileNotFound)
missing.change('HH:mm')
checkEqual(missing.state.writes.length, 1, 'first-run missing file initializes normally')
pass('a first-run missing config can be initialized')

const transition = harness()
transition.loaded(userText)
transition.failed(FileViewError.PermissionDenied)
transition.change('HH:mm')
checkEqual(transition.state.writes.length, 0, 'a read failure after a successful load prevents persistence')
pass('a later read failure protects a previously loaded config')
JS
