#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/panels/plugin-review/Review.qml'), 'utf8')
const panel = fs.readFileSync(path.join(root, 'shell/plugins/panels/plugin-review/Panel.qml'), 'utf8')
const context = {}
vm.createContext(context)
for (const name of ['commandLiteral', 'argumentPreview', 'httpField', 'httpDescription', 'hasRequiredPermissions', 'isRequired', 'atomicEditable', 'toggleAtomic', 'selectRequiredPermissions', 'toggleSetting', 'toggleHttp', 'toggleExec', 'setFolder', 'enable', 'remove', 'finish']) {
  const start = source.indexOf(`  function ${name}(`)
  const end = source.indexOf('\n  }', start) + 4
  vm.runInContext(source.slice(start, end), context)
}
const script = 'printf "%s\\n" "approved text"; test "$HOME" = /home/example'
assertEqual(context.argumentPreview({kind: 'exact', value: script}), JSON.stringify(script), 'bash program is displayed completely as one literal argument')
for (const arg of [
  {kind: 'oneOf', values: ['one', 'two with spaces']},
  {kind: 'integer', min: 0, max: 123},
  {kind: 'pattern', value: '/repos/[a-z]+/[a-z]+', max: 400},
  {kind: 'text', prefix: 'query=', min: 6, max: 100}
]) {
  const shown = context.argumentPreview(arg)
  for (const key of Object.keys(arg).filter(key => key !== 'kind')) {
    for (const value of [].concat(arg[key])) assert(shown.includes(String(value)), `command display retains ${arg.kind}.${key}: ${value}`)
  }
}
assert(context.argumentPreview({kind: 'pattern', value: 'x+', max: 8}).includes('whole arg'), 'regex pattern states full-argument matching')
assertEqual(context.argumentPreview({kind: 'oneOf', values: ['one', 'two with spaces']}), '[one|"two with spaces"]', 'alternatives use compact command notation with literal boundaries')
assert(context.argumentPreview({kind: 'integer', min: 0, max: 10}).includes('uint 0–10; no leading zeros'), 'integer pattern includes lexical restrictions')
assertEqual(context.commandLiteral('/usr/bin/printf'), '/usr/bin/printf', 'ordinary command tokens do not need quotes')
for (const value of ['', 'a b', '[option]', '$(command)', 'a\nb']) assertEqual(context.commandLiteral(value), JSON.stringify(value), 'special literal tokens stay quoted and escaped')
const scope = {method: 'POST', origin: 'https://example.test:8443', path: '/repos/*/actions', subtree: false,
  query: {label: {required: false, value: {kind: 'string', max: 40}}, mode: {required: true, value: {kind: 'exact', value: 'summary'}}},
  body: {details: {kind: 'object', fields: {note: {kind: 'nullableString', max: 120}, exact: {kind: 'exact', value: {safe: true}}}}}}
const shown = context.httpDescription(scope)
for (const text of ['POST https://example.test:8443/repos/*/actions', 'exactly one nonempty segment', '"label" (optional): text, 0–40 bytes', '"mode" (required): exactly "summary"', 'no others allowed', 'all required', '"note": null or text, 0–120 bytes', '"exact": exactly {"safe":true}']) {
  assert(shown.includes(text), `HTTP display includes ${text}`)
}
assert(context.httpDescription({method: 'GET', origin: 'http://127.0.0.1:8080', path: '/status', subtree: false, query: {}, body: null}).includes('Request body: none allowed.'), 'absent body is explicitly denied, not an unspecified value')
assert(context.httpDescription({method: 'GET', origin: 'https://example.test', path: '/root/', subtree: true, query: {}, body: null}).includes('this root and all paths below'), 'subtree authority is distinguished from an exact path')
assert(panel.includes('Any destination, port and protocol, including local services'), 'raw networking plainly discloses unrestricted scope')
assert(panel.includes('Any public destination and TCP port') && panel.includes('No site, URL or body restrictions'), 'public proxy plainly discloses broad bidirectional scope')
assert(panel.includes('The selected public proxy is not limited by this HTTP scope'), 'combined proxy and HTTP selection cannot imply a false scope restriction')
assert(panel.includes('Any HTTP(S) URL') && panel.includes('No domain or path restriction'), 'browser handoff exposes its broad destination scope')
assert(!panel.includes('TextField') && !source.includes('writableFolders'), 'filesystem and media approval have no user-entered resource or access override')
assert(panel.includes('label: "Command"') && panel.includes('text: modelData.command') && panel.includes('delegate: PermissionBlock'), 'full command pattern expands within its permission block')
assert(!panel.includes('10-second') && !panel.includes('modelData.lifetime'), 'reviewer has no execution-time limit copy')
assert(source.includes('[commandLiteral(ask.executable)].concat(args.map(argumentPreview))'), 'command pattern starts with executable and preserves argument order')
assert(panel.includes('textFormat: Text.PlainText'), 'plugin-authored permission strings cannot render markup')
assert(panel.includes('sourceComponent: permission.fixed ? fixedRow : optionalRow'), 'required grants instantiate a static row instead of a toggle')
const fixedRow = panel.slice(panel.indexOf('      id: fixedRow'), panel.indexOf('  component PermissionBlock'))
assert(fixedRow.includes('Accessible.role: Accessible.StaticText'), 'required grants are exposed as static information')
assert(!/Toggle|MouseArea|HoverHandler|Keys\.|activeFocusOnTab/.test(fixedRow), 'required rows contain no switch, pointer or keyboard activation affordances')
for (const name of ['network', 'networkProxy', 'notifications', 'audioPlayback', 'microphone', 'audioCapture', 'openUrls', 'media', 'storage', 'desktopGeometry', 'settings']) {
  assert(panel.includes(`fixed: review.isRequired("${name}")`), `${name} uses the static treatment when required`)
}
assertEqual((panel.match(/fixed: modelData.required/g) || []).length, 2, 'required host-command and filesystem grants use static rows')
assert(panel.includes('fixed: ask.required'), 'required HTTP grants use static rows')
context.root = context
context.stage = ''
context.revision = {requests: {http: {}, settings: {read: [], write: []}}}
context.folderRequests = []
context.execRequests = []
context.http = []
context.httpRequests = []
context.exec = {}
context.folders = {}
context.settings = {read: [], write: []}
assert(context.hasRequiredPermissions(), 'an optional-only plugin can be enabled with no grants')
for (const name of ['network', 'networkProxy', 'notifications', 'audioPlayback', 'microphone', 'audioCapture', 'openUrls', 'storage', 'desktopGeometry', 'media']) {
  context.revision.requests[name] = {required: true}
  context[name] = false
  assert(!context.hasRequiredPermissions(), `missing required ${name} blocks Enable`)
  context[name] = true
  assert(context.hasRequiredPermissions(), `selected required ${name} unlocks Enable`)
  delete context.revision.requests[name]
}
context.revision.requests.http.catalog = {required: true}
assert(!context.hasRequiredPermissions(), 'raw network cannot satisfy a required HTTP scope')
context.http = ['catalog']
assert(context.hasRequiredPermissions(), 'selected required HTTP scope unlocks Enable')
context.folderRequests = [{name: 'notes', required: true}]
assert(!context.hasRequiredPermissions(), 'missing required folder blocks Enable')
context.folders.notes = true
context.revision.requests.settings = {required: true, read: ['theme'], write: ['width']}
context.settings.read = ['theme']
assert(!context.hasRequiredPermissions(), 'all required settings keys and access modes must be selected')
context.settings.write = ['width']
context.execRequests = [{name: 'helper', leaf: 'status', required: true}]
assert(!context.hasRequiredPermissions(), 'missing required command leaf blocks Enable')
context.exec.helper = ['status']
assert(context.hasRequiredPermissions(), 'all required selections unlock Enable')
context.requiredAccepted = false
context.busy = false
context.current = null
let approved = 0
context.approve = () => approved++
context.enable()
assertEqual(approved, 0, 'Enable refuses missing required selections')
context.requiredAccepted = true
context.enable()
assertEqual(approved, 1, 'one Enable action starts approval')
let calls = []
context.pluginId = 'test.review'
context.run = (kind, args) => calls.push({kind, args})
context.operation = 'approve'
context.busy = true
context.process = {exited: true, outDone: true, errDone: true, exitCode: 0}
context.finish()
assertDeepEqual(calls, [{kind: 'enable', args: ['omarchy-plugin-enable', 'test.review']}], 'successful approval automatically enables through the canonical CLI')
let completed = 0
context.completed = () => completed++
for (const kind of ['approve', 'enable', 'remove']) {
  context.operation = kind
  context.busy = true
  context.process.exitCode = 1
  context.process.err = 'fixture failure'
  context.finish()
  assertEqual(completed, 0, `${kind} failure keeps the reviewer open`)
}
context.remove()
assertDeepEqual(calls[1], {kind: 'remove', args: ['omarchy-plugin-remove', 'test.review', '--yes']}, 'Deny & Remove targets only the reviewed plugin')
context.operation = 'remove'
context.busy = true
context.process.exitCode = 0
context.finish()
assertEqual(completed, 1, 'successful removal dismisses the reviewer')
assert(!panel.includes('Off means') && !panel.includes('Approve permissions') && !panel.includes('text: "Refresh"'), 'reviewer omits tutorials and intermediate lifecycle actions')
assert(panel.includes('label: "Host command" +') && panel.includes('label: "HTTP request" +'), 'permission headings identify the type without plugin-authored names')
assert(!panel.includes('review.commandLabel') && !panel.includes('modelData.name + review.requirementLabel') && !panel.includes('"Permission: "'), 'internal grant identifiers are not presented as permission descriptions')
context.revision = {requests: {
  notifications: {required: true}, storage: true, network: true, networkProxy: true,
  settings: {read: ['theme'], write: ['width'], required: true},
  http: {catalog: {required: true}, extra: {required: false}},
  exec: {helper: {required: ['status']}}
}}
context.httpRequests = ['catalog', 'extra']
context.execRequests = [{name: 'helper', leaf: 'status', required: true}, {name: 'helper', leaf: 'extra', required: false}]
context.folderRequests = [{name: 'notes', required: true}, {name: 'extra', required: false}]
context.selectRequiredPermissions()
assertEqual(context.notifications, true, 'required atomic permissions start on')
assertEqual(context.storage, false, 'optional atomic permissions start off')
assertDeepEqual(context.http, ['catalog'], 'only required HTTP scopes start on')
assertDeepEqual(context.exec, {helper: ['status']}, 'only required command leaves start on')
assertDeepEqual(context.folders, {notes: true}, 'only required folders start on')
assertDeepEqual(context.settings, {read: ['theme'], write: ['width']}, 'all required setting keys start on')
context.toggleAtomic('notifications')
context.toggleAtomic('network')
context.toggleHttp('catalog')
context.toggleExec('helper', 'status')
context.toggleSetting('write', 'width')
context.setFolder('notes', false)
assert(context.hasRequiredPermissions(), 'required permissions cannot be turned off by any draft control')
assertEqual(context.network, false, 'optional raw networking cannot clear a required scoped HTTP grant')
context.toggleAtomic('storage')
context.toggleHttp('extra')
context.toggleExec('helper', 'extra')
context.setFolder('extra', true)
assertEqual(context.storage, true, 'optional atomic permission remains editable')
assertDeepEqual(context.http, ['catalog', 'extra'], 'optional HTTP permission remains editable')
assertDeepEqual(context.exec.helper, ['status', 'extra'], 'optional command remains editable')
assertEqual(context.folders.extra, true, 'optional folder remains editable')
assertEqual(calls.length, 2, 'required defaults and toggle changes never approve or execute anything')
JS
