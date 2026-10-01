#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const childProcess = require('child_process')
const vm = require('vm')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panel = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-enterprise-trust-'))

try {
  const cert = path.join(scratch, 'private CA.pem')
  fs.writeFileSync(cert, 'fixture CA')
  fs.writeFileSync(path.join(scratch, 'uuidgen'), '#!/bin/bash\nprintf "fixture-uuid\\n"\n', {mode: 0o755})
  fs.writeFileSync(path.join(scratch, 'nmcli'), `#!/bin/bash
count=0
[[ ! -f $TEST_NM_LOG.count ]] || read -r count <"$TEST_NM_LOG.count"
(( count += 1 ))
printf '%s\\n' "$count" >"$TEST_NM_LOG.count"
printf '%s\\0' "$@" >"$TEST_NM_LOG.$count"
if [[ $2 == "$TEST_NM_HANG" ]]; then
  [[ $TEST_NM_IGNORE_TERM != 1 ]] || trap '' TERM
  printf '%s\\n' "$BASHPID" >"$TEST_NM_LOG.pids"
  sleep 30 &
  printf '%s\\n' "$!" >>"$TEST_NM_LOG.pids"
  wait
fi
if [[ $2 == "edit" ]]; then cat >"$TEST_NM_LOG.stdin"; fi
[[ $2 != "$TEST_NM_FAIL" ]]
`, {mode: 0o755})

  const password = 'literal $() \\" secret'
  function connect(caCert, serverName, failAction, hangAction, ignoreTerm) {
    const log = path.join(scratch, 'nmcli-log')
    for (const name of fs.readdirSync(scratch)) {
      if (name.startsWith('nmcli-log')) fs.unlinkSync(path.join(scratch, name))
    }
    const script = hangAction ? network.enterpriseConnectScript.replace('--kill-after=1s 150s', '--kill-after=0.1s 0.1s') : network.enterpriseConnectScript
    const command = ['bash', '-c', script,
      'nmcli-eap', 'Enterprise WiFi', 'person@example.org', caCert, serverName]
    // Accelerate the production timeout for the fixture, preserving its
    // process-group behavior and escalation while executing the real helper.
    const result = childProcess.spawnSync(command.shift(), command, {
      input: password + '\n', encoding: 'utf8', timeout: 2000,
      env: {...process.env, PATH: scratch + ':' + process.env.PATH,
        TEST_NM_LOG: log, TEST_NM_FAIL: failAction || '',
        TEST_NM_HANG: hangAction || '', TEST_NM_IGNORE_TERM: ignoreTerm ? '1' : '0'}
    })
    const count = fs.existsSync(log + '.count') ? Number(fs.readFileSync(log + '.count', 'utf8')) : 0
    const calls = []
    for (let i = 1; i <= count; i++) calls.push(fs.readFileSync(log + '.' + i, 'utf8').split('\0').slice(0, -1))
    const stdin = fs.existsSync(log + '.stdin') ? fs.readFileSync(log + '.stdin', 'utf8') : ''
    const pids = fs.existsSync(log + '.pids') ? fs.readFileSync(log + '.pids', 'utf8').trim().split('\n') : []
    return {result, calls, stdin, pids}
  }

  for (const [caCert, serverName] of [
    ['', ''], ['', 'radius.example.org'], [cert, ''],
    ['relative.pem', 'radius.example.org'], [scratch, 'radius.example.org'],
    [cert + '.missing', 'radius.example.org'],
    [cert, '*.example.org'], [cert, 'radius.example.org;evil.example.org'],
    [cert, 'radius.example.org\nevil.example.org'], [cert, 'radius..example.org'],
    [cert, '-radius.example.org'], [cert, 'radius-.example.org'],
    [cert, 'r'.repeat(64) + '.example.org'], [cert, 'râdius.example.org']
  ]) {
    const attempt = connect(caCert, serverName)
    assert(attempt.result.status !== 0 && !attempt.result.error && attempt.calls.length === 0,
      'enterprise refuses invalid trust before any NetworkManager call: ' + JSON.stringify([caCert, serverName]))
  }

  const good = connect(cert, 'radius.example.org')
  assertEqual(connect(cert + '.missing', 'radius.example.org').result.status, 64, 'enterprise distinguishes unreadable CA input from connection failures')
  assertEqual(connect(cert, '*.example.org').result.status, 65, 'enterprise distinguishes invalid server input from connection failures')
  assertEqual(good.result.status, 0, 'enterprise accepts administrator-provided private CA and exact server')
  assertDeepEqual(good.calls.map(call => call[1]), ['add', 'edit', 'up'], 'enterprise creates, writes credentials, then activates')
  const add = good.calls[0]
  for (const [name, value] of [
    ['ssid', 'Enterprise WiFi'], ['802-1x.identity', 'person@example.org'],
    ['802-1x.ca-cert', cert], ['802-1x.domain-match', 'radius.example.org'],
    ['802-1x.system-ca-certs', 'no'], ['802-1x.eap', 'peap'], ['802-1x.phase2-auth', 'mschapv2']
  ]) assertEqual(add[add.indexOf(name) + 1], value, 'enterprise profile sets ' + name)
  assert(!good.calls.some(call => call.some(arg => arg.includes(password))), 'enterprise password never enters a subprocess argument')
  assertEqual(good.stdin, 'set 802-1x.password ' + password + '\nsave\nquit\n', 'enterprise password reaches the editor literally through stdin')

  for (const action of ['add', 'edit', 'up']) {
    const failed = connect(cert, 'radius.example.org', action)
    assert(failed.result.status !== 0 && failed.calls.at(-1)[1] === 'delete', 'enterprise cleans up a failed ' + action)
    if (action !== 'up') assert(!failed.calls.some(call => call[1] === 'up'), 'enterprise never activates after failed ' + action)
  }

  for (const [action, ignoreTerm] of [['add', false], ['edit', false], ['up', false], ['up', true]]) {
    const stalled = connect(cert, 'radius.example.org', '', action, ignoreTerm)
    assert(!stalled.result.error && (stalled.result.status === 124 || stalled.result.status === 137),
      'enterprise deadline ends a stalled ' + action + (ignoreTerm ? ' even when TERM is ignored' : '')
        + ' ' + JSON.stringify({status: stalled.result.status, signal: stalled.result.signal, error: stalled.result.error && stalled.result.error.code}))
    assertEqual(stalled.pids.length, 2, 'stalled enterprise fixture started nmcli and its child')
    assert(stalled.calls.at(-1)[1] === 'delete' && stalled.calls.at(-1)[3] === 'fixture-uuid',
      'enterprise supervisor cleans its own profile after stalled ' + action + (ignoreTerm ? ' and forced KILL' : ''))
    for (const pid of stalled.pids) {
      const stat = '/proc/' + pid + '/stat'
      assert(!fs.existsSync(stat) || fs.readFileSync(stat, 'utf8').split(') ')[1].startsWith('Z'),
        'enterprise deadline leaves no running nmcli descendant ' + pid)
    }
    assertEqual(connect(cert, 'radius.example.org').result.status, 0, 'enterprise can retry after stalled ' + action)
  }

  for (const serverName of ['radius.example.org', 'RADIUS.example.org', 'radius', 'xn--radius-9za.example.org']) {
    assert(network.enterpriseTrustValid(cert, serverName), 'enterprise UI accepts exact administrator server ' + serverName)
  }
  for (const serverName of ['', '*.example.org', 'radius.example.org;evil.example.org', 'radius.example.org\n', 'a'.repeat(254)]) {
    assert(!network.enterpriseTrustValid(cert, serverName), 'enterprise UI rejects invalid server ' + JSON.stringify(serverName))
  }
  assert(!network.enterpriseTrustValid('', 'radius.example.org'), 'enterprise UI requires a CA certificate path')

  // Exercise the production caller as well as the subprocess boundary.
  const Model = network
  var cancelSignals = 0
  const enterpriseConnect = {running: false, secret: '', command: [], cancelling: false, signal: function(signal) { assertEqual(signal, 15, 'enterprise cancellation signals its supervisor'); cancelSignals++ }}
  var enterpriseRetry = null
  var actionCount = 0
  var actionRevision = 0
  var actionKind = ''
  var failureSsid = ''
  var failureReason = ''
  function runNetworkAction(kind, ssidNetwork, callback) { if (actionKind !== '') return; actionKind = kind; actionCount++; actionRevision++; callback({name: ssidNetwork}) }
  function networkForSsid(ssid) { return ssid }
  const caller = panel.match(/function connectEnterprise\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(caller, 'enterprise has a production connection caller')
  eval(caller[0])
  connectEnterprise('Enterprise WiFi', 'person@example.org', password, '', '')
  assertEqual(actionCount, 0, 'enterprise caller cannot start without trust settings')
  connectEnterprise('Enterprise WiFi', 'person@example.org', password, cert, 'radius.example.org')
  assertEqual(actionCount, 1, 'enterprise caller starts with valid trust settings')
  assertDeepEqual(enterpriseConnect.command.slice(-4), ['Enterprise WiFi', 'person@example.org', cert, 'radius.example.org'], 'enterprise caller passes explicit trust settings to the process')
  assert(!enterpriseConnect.command.includes(password), 'enterprise caller keeps the password out of argv')
  assertDeepEqual(enterpriseConnect.command.slice(0, 2), ['bash', '-c'], 'enterprise caller keeps the cleanup supervisor outside the worker timeout')
  assert(network.enterpriseConnectScript.includes('timeout --kill-after=1s 150s bash -c'),
    'enterprise worker deadline accommodates the normal 90-second nmcli activation wait')

  const firstCommand = enterpriseConnect.command.slice()
  const firstRevision = enterpriseConnect.actionRevision
  connectEnterprise('Enterprise WiFi', 'retry@example.org', 'new password', cert, 'radius.example.org')
  assertEqual(actionCount, 1, 'enterprise does not reuse a still-running process for a retry')
  assertDeepEqual(enterpriseConnect.command, firstCommand, 'enterprise retains the running process command')
  assertEqual(enterpriseConnect.actionRevision, firstRevision, 'enterprise retains the running attempt revision')
  assertEqual(enterpriseRetry, null, 'a busy enterprise action does not queue an overlapping retry')
  actionKind = '' // The panel's informational timeout has expired.
  connectEnterprise('Enterprise WiFi', 'retry@example.org', 'new password', cert, 'radius.example.org')
  assertEqual(cancelSignals, 1, 'retry cancels a stale attempt instead of remaining blocked')
  assertEqual(enterpriseRetry.identity, 'retry@example.org', 'enterprise queues the retry until old cleanup exits')
  assertEqual(actionCount, 1, 'queued retry does not reuse the live Process')
  connectEnterprise('Enterprise WiFi', 'latest@example.org', 'latest password', cert, 'radius.example.org')
  assertEqual(cancelSignals, 1, 'additional retry requests do not interrupt cancellation cleanup')
  assertEqual(enterpriseRetry.identity, 'latest@example.org', 'enterprise retains the latest requested retry')

  const exitHandler = panel.match(/onExited: function\(exitCode, exitStatus\) \{([\s\S]*?)\n {4}\}/)
  assert(exitHandler, 'enterprise has an exit handler')
  const onExited = new Function('exitCode', 'exitStatus', 'root', 'actionRevision', 'ssid', 'actionTimeout', 'secret', 'cancelling', 'Qt', exitHandler[1])
  var stopped = 0
  const timer = {stop: function() { stopped++ }}
  const retry = {actionRevision: firstRevision + 1, actionKind: 'connect', actionSsid: 'Enterprise WiFi', failureSsid: '', failureReason: '', enterpriseRetry: null}
  const beforeLateExit = JSON.stringify(retry)
  onExited(1, 0, retry, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(JSON.stringify(retry), beforeLateExit, 'enterprise late exit cannot clear a newer same-SSID attempt')
  assertEqual(stopped, 0, 'enterprise late exit cannot stop the newer attempt timer')

  onExited(64, 0, retry, retry.actionRevision, 'Enterprise WiFi', timer, '')
  assertEqual(retry.failureReason, 'CA certificate must be a readable file', 'enterprise displays the specific CA path error')
  assertEqual(retry.actionKind, '', 'enterprise current failure clears its own busy state')
  assertEqual(stopped, 1, 'enterprise current failure stops its own timer')
  retry.actionKind = 'connect'
  retry.actionSsid = 'Enterprise WiFi'
  onExited(124, 0, retry, retry.actionRevision, 'Enterprise WiFi', timer, '')
  assertEqual(retry.failureReason, 'Timed out connecting', 'enterprise deadline reports a timeout instead of invalid credentials')
  assertEqual(retry.actionKind, '', 'enterprise timeout clears its own busy state for retry')

  const lateSuccess = {actionRevision: firstRevision, actionKind: '', actionSsid: '', failureSsid: 'Enterprise WiFi',
    failureReason: 'Timed out connecting', passwordSsid: 'Enterprise WiFi', enterpriseRetry: null,
    clearNetworkAction: function() { this.failureSsid = ''; this.failureReason = ''; this.refreshed = true }}
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(lateSuccess.failureReason, '', 'late enterprise success removes its informational timeout error')
  assertEqual(lateSuccess.passwordSsid, '', 'late enterprise success closes its password prompt')
  assert(lateSuccess.refreshed, 'late enterprise success refreshes connection details')
  lateSuccess.failureSsid = 'Enterprise WiFi'
  lateSuccess.failureReason = 'Timed out connecting'
  lateSuccess.passwordSsid = 'Other WiFi'
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(lateSuccess.passwordSsid, 'Other WiFi', 'late enterprise success preserves another network credentials prompt')
  assertEqual(lateSuccess.failureReason, '', 'late enterprise success still removes its own timeout while another prompt is open')
  lateSuccess.actionRevision++
  lateSuccess.failureSsid = 'Enterprise WiFi'
  lateSuccess.failureReason = 'Newer action failed'
  lateSuccess.passwordSsid = 'Enterprise WiFi'
  const beforeOldSuccess = JSON.stringify(lateSuccess)
  onExited(0, 0, lateSuccess, firstRevision, 'Enterprise WiFi', timer, '')
  assertEqual(JSON.stringify(lateSuccess), beforeOldSuccess, 'old enterprise success preserves a newer action failure and prompt')

  const deferred = []
  const queued = {actionRevision: firstRevision, actionKind: '', actionSsid: '', enterpriseRetry,
    connectEnterprise: function() { connectEnterprise(...arguments) }}
  onExited(124, 0, queued, firstRevision, 'Enterprise WiFi', timer, '', true, {callLater: fn => deferred.push(fn)})
  assertEqual(queued.enterpriseRetry, null, 'old exit releases its queued retry payload')
  assertEqual(actionCount, 1, 'retry waits until after the old exit callback completes')
  enterpriseConnect.running = false
  deferred[0]()
  assertEqual(actionCount, 2, 'enterprise automatically starts the queued retry after cleanup exits')
  assertEqual(enterpriseConnect.command.at(-3), 'latest@example.org', 'enterprise starts the latest queued identity')
  assert(enterpriseConnect.actionRevision > firstRevision, 'enterprise retry records a new attempt revision')

  for (const laterKind of ['disconnect', '']) {
    var resumed = 0
    const callbacks = []
    const superseded = {actionRevision: firstRevision, actionKind: '', actionSsid: '',
      enterpriseRetry: {ssid: 'Enterprise WiFi', actionRevision: firstRevision},
      connectEnterprise: function() { resumed++ }}
    onExited(124, 0, superseded, firstRevision, 'Enterprise WiFi', timer, '', true, {callLater: fn => callbacks.push(fn)})
    superseded.actionRevision++
    superseded.actionKind = laterKind
    callbacks[0]()
    assertEqual(resumed, 0, 'queued enterprise retry cannot override a later action that is ' + (laterKind ? 'busy' : 'finished'))
  }

  const actionHelper = panel.match(/function runNetworkAction\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(actionHelper, 'network has a production action helper')
  const actionContext = vm.createContext({actionKind: '', actionRevision: 0,
    actionSsid: '', failureSsid: '', failureReason: '', enterpriseRetry: {ssid: 'Old request'}, actionTimeout: {restart: function() {}}})
  vm.runInContext(actionHelper[0], actionContext)
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 1, 'production action helper advances the attempt revision')
  assertEqual(actionContext.enterpriseRetry, null, 'an accepted network action discards the queued enterprise request')
  actionContext.enterpriseRetry = {ssid: 'Pending request'}
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 1, 'production action helper does not advance a rejected busy attempt')
  assertEqual(actionContext.enterpriseRetry.ssid, 'Pending request', 'a rejected action does not discard an existing enterprise request')
  actionContext.actionKind = ''
  actionContext.runNetworkAction('connect', {name: 'Enterprise WiFi'}, function() {})
  assertEqual(actionContext.actionRevision, 2, 'production action helper advances a later same-SSID retry')
  assertEqual(actionContext.enterpriseRetry, null, 'a later accepted action retires the old enterprise retry')

  const clearHelper = panel.match(/function clearNetworkAction\([^)]*\) \{[\s\S]*?\n {2}\}/)
  assert(clearHelper, 'network has a production completion helper')
  const clearContext = vm.createContext({actionKind: 'connect', actionSsid: 'Enterprise WiFi', passwordSsid: 'Other WiFi',
    failureSsid: '', failureReason: '', actionTimeout: {stop: function() {}}, refresh: function() {}})
  vm.runInContext(clearHelper[0], clearContext)
  clearContext.clearNetworkAction()
  assertEqual(clearContext.passwordSsid, 'Other WiFi', 'network completion preserves another credentials prompt')
  clearContext.actionKind = 'connect'
  clearContext.actionSsid = 'Enterprise WiFi'
  clearContext.passwordSsid = 'Enterprise WiFi'
  clearContext.clearNetworkAction()
  assertEqual(clearContext.passwordSsid, '', 'network completion closes its own credentials prompt')
} finally {
  fs.rmSync(scratch, {recursive: true, force: true})
}
JS
