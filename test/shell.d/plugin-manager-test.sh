#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const functions = file => [...fs.readFileSync(path.join(root, file), 'utf8').matchAll(/^  function \w+\([^\n]*\) \{[\s\S]*?^  \}/gm)].map(match => match[0]).join('\n')
const installedCalls = []
const stagedCalls = []
const c = vm.createContext({
  plugins: [], selected: null, source: 'https://example.test/plugin', yolo: false, trustConfirmed: false,
  inspected: null, pendingAdd: null, selectedId: '', adding: true, confirmRemove: false, busy: false, operation: '', error: '', notice: '', abandoned: false,
  command: {}, installed(id, sandboxed) { installedCalls.push([id, sandboxed]) }, staged(id, stage) { stagedCalls.push([id, stage]) }, Qt: {callLater() {}}
})
vm.runInContext(functions('shell/plugins/panels/plugins/Model.qml'), c)
const result = (installed = false, mode = 'ward', id = 'test.demo', commit = 'a'.repeat(40)) => JSON.stringify({id, commit, installed, mode, stage: '.add.abcdefgh'})
assertEqual(c.add(), true, 'Clone and review starts from a source with one action')
assertDeepEqual(c.command.command, ['omarchy-plugin-add', c.source, '--stage', '--json'], 'one clone stages the source without installing, approving or enabling')
assertEqual(c.add(), false, 'UI never overlaps clone and installation commands')
c.finish(0, result(), '')
assertEqual(c.busy, false, 'staging stops before publication')
assertDeepEqual(stagedCalls, [['test.demo', '.add.abcdefgh']], 'Ward hands its unique temporary checkout to permission review')
assertEqual(installedCalls.length, 0, 'Ward staging never emits an installation result')
assertEqual(c.adding, false, 'staging leaves the source form for permission review')
assertEqual(c.pendingAdd, null, 'staging clears the pending source request')
assertEqual(c.inspected, null, 'staging cannot reuse an old inspection')

c.setAdding(true)
c.source = 'https://example.test/yolo-plugin'
c.yolo = true
assertEqual(c.add(), false, 'YOLO requires separate explicit trust confirmation')
assertEqual(c.busy, false, 'unconfirmed YOLO performs no source operation')
c.trustConfirmed = true
assertEqual(c.add(), true, 'confirmed YOLO starts the same one-action clone workflow')
assertDeepEqual(c.command.command, ['omarchy-plugin-add', c.source, '--inspect', '--json', '--yolo'], 'automatic inspection retains explicit YOLO mode')
c.finish(0, result(false, 'yolo'), '')
assertDeepEqual(c.command.command, ['omarchy-plugin-add', c.source, '--commit', 'a'.repeat(40), '--json', '--yes', '--yolo'], 'install pins the inspected commit and explicitly selects YOLO')
c.finish(1, '', 'source changed since validation')
assertEqual(c.error, 'source changed since validation', 'failed installation keeps actionable feedback')
assertEqual(c.adding, true, 'failed installation keeps the form open')
assertEqual(c.pendingAdd, null, 'failed installation discards the pending source request')
assertEqual(c.add(), true, 'retry starts a fresh inspection rather than reusing the old commit')
c.finish(0, result(false, 'yolo'), '')
c.finish(0, result(true, 'yolo'), '')
assertDeepEqual(installedCalls[0], ['test.demo', false], 'YOLO installation is not sent through Ward permission review')
assertEqual(c.trustConfirmed, false, 'completed YOLO installation clears its trust acknowledgment')

c.setAdding(true)
c.source = 'https://example.test/bad-plugin'
assertEqual(c.add(), true, 'invalid source begins the normal clone workflow')
c.finish(1, '', 'unsupported sandbox manifest')
assertEqual(c.error, 'unsupported sandbox manifest', 'automatic validation errors remain visible')
assertEqual(c.operation, '', 'validation failure never advances to installation')
assertEqual(c.pendingAdd, null, 'validation failure clears its pending request')

c.add()
c.source = 'https://example.test/replaced-plugin'
c.finish(0, result(), '')
assertDeepEqual(c.command.command, ['omarchy-plugin-stage', 'discard', '.add.abcdefgh'], 'a source change discards only the completed temporary attempt')
c.finish(0, '', '')
assertEqual(c.operation, '', 'changed source is not installed')
c.add()
c.yolo = true
c.finish(0, result(), '')
assertEqual(c.operation, 'discard', 'a mode change discards the old staged source')
c.finish(0, '', '')
assertEqual(c.operation, '', 'a mode change during inspection cannot continue the installation')
c.trustConfirmed = true
c.add()
c.trustConfirmed = false
c.finish(0, result(false, 'yolo'), '')
assertEqual(c.operation, '', 'withdrawing YOLO trust before installation stops the sequence')

c.setAdding(true)
c.source = 'https://example.test/malformed-result'
c.add()
c.finish(0, result(false, 'ward', 'test.demo', 'not-a-commit'), '')
assert(c.error.includes('Invalid clone result'), 'malformed inspected commits never reach installation')
c.add()
c.finish(0, result(false, 'yolo'), '')
assert(c.error.includes('Invalid clone result'), 'an unexpected execution mode never reaches installation')
c.add()
c.finish(0, result(true), '')
assert(c.error.includes('Invalid clone result'), 'staging cannot claim that it installed a plugin')
c.yolo = true
c.trustConfirmed = true
c.add()
c.finish(0, result(false, 'yolo'), '')
c.finish(0, result(true, 'yolo', 'test.other'), '')
assert(c.error.includes('Invalid installation result'), 'installation identity must match the inspected plugin')
assertEqual(installedCalls.length, 1, 'invalid installation output cannot hand off to another plugin')

c.setAdding(true)
c.source = '/fixture/closed-during-clone'
c.add()
c.abandoned = true
c.finish(0, result(), '')
assertDeepEqual(c.command.command, ['omarchy-plugin-stage', 'discard', '.add.abcdefgh'], 'closing during cloning discards a late result instead of opening the reviewer')
assertEqual(stagedCalls.length, 1, 'an abandoned add never hands off to review')
c.finish(0, '', '')

c.selected = {id:'test.demo'}
assertEqual(c.action('remove'), false, 'first remove click only asks for confirmation')
assertEqual(c.action('remove'), true, 'confirmed removal invokes the lifecycle command')
assertDeepEqual(c.command.command, ['omarchy-plugin-remove', 'test.demo', '--yes'], 'removal is scoped to the selected identity')
c.finish(0, 'Removed', '')
assertEqual(c.confirmRemove, false, 'removal confirmation clears after completion')
c.finish(0, 'not-json', '') // Previous remove result does not parse external prose.
c.operation = 'list'
c.plugins = [{id:'kept'}]
c.finish(0, 'not-json', '')
assertEqual(c.plugins[0].id, 'kept', 'invalid list results preserve last good state')
c.selectedId = 'removed'
c.operation = 'list'
c.finish(0, JSON.stringify([
  {id:'builtin', firstParty:true, installed:true},
  {id:'broken', installed:true, approved:false, enabled:false},
  {id:'approved', installed:false, approved:true, enabled:false},
  {id:'unknown', installed:false, approved:null, enabled:false},
  {id:'running', installed:false, approved:false, enabled:true}
]), '')
assertDeepEqual(c.plugins.map(row => row.id), ['broken', 'approved', 'unknown', 'running'], 'removal clears its records instead of hiding rows in the manager')
assertEqual(c.selectedId, '', 'a removed row clears its stale selection')
c.selectedId = 'broken'
c.operation = 'list'
c.finish(0, JSON.stringify(c.plugins), '')
assertEqual(c.selectedId, 'broken', 'refresh preserves a still-installed selection')
c.operation = 'list'
c.finish(0, JSON.stringify([{id:'orphaned', installed:false, approved:false, enabled:false}]), '')
assertEqual(c.plugins[0].id, 'orphaned', 'orphaned old records remain available for explicit full removal')

c.source = '/previous/plugin'
c.yolo = true
c.trustConfirmed = true
c.inspected = {id: 'previous.plugin', commit: 'b'.repeat(40)}
c.pendingAdd = {source: '/previous/plugin', yolo: true}
c.confirmRemove = true
c.error = 'Old failure'
c.notice = 'Old success'
c.setAdding(true)
assertEqual(c.adding, true, 'Add opens a fresh form')
assertEqual(c.source, '', 'Add clears the previous source')
assertEqual(c.yolo, false, 'Add defaults to Ward even after a YOLO installation')
assertEqual(c.trustConfirmed, false, 'Add never carries trust to another plugin')
assertEqual(c.inspected, null, 'Add requires a new inspected commit')
assertEqual(c.pendingAdd, null, 'Add clears the previous in-flight source snapshot')
assertEqual(c.confirmRemove, false, 'Add clears removal confirmation')
assertEqual(c.error + c.notice, '', 'Add clears stale feedback')
assertEqual(c.add(), false, 'a fresh form cannot install an old revision')
assertEqual(c.modeLabel('ward'), 'Ward · sandboxed', 'Ward mode states isolation')
assertEqual(c.modeLabel('yolo'), 'YOLO · unsandboxed', 'YOLO mode plainly states its missing sandbox')
assertEqual(c.modeLabel('blocked'), 'Blocked · installation needs attention', 'blocked provenance is not presented as trusted')

const panel = fs.readFileSync(path.join(root, 'shell/plugins/panels/plugins/Panel.qml'), 'utf8')
assert(!panel.includes('plugin-validate') && !panel.includes('manager.inspect()'), 'manager exposes no separate validation control')
assert(panel.includes('"Clone & review"'), 'Ward action names the clone-to-review workflow')
assert(panel.includes('enabled: !manager.busy && !!manager.source.trim()'), 'clone action needs a source, not a previous check')
assert(panel.includes('if (manager.yolo) root.confirmYolo = true; else manager.add()'), 'YOLO clone opens a separate confirmation before running any command')
assert(panel.includes('Do you trust this plugin to execute unsandboxed?'), 'YOLO confirmation explicitly asks about unsandboxed execution')
assert(panel.includes('manager.trustConfirmed = true; root.confirmYolo = false; manager.add()'), 'only the final confirmation permits a YOLO clone')

JS
