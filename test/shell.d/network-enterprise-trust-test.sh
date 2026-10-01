#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const childProcess = require('child_process')
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
if [[ $2 == "edit" ]]; then cat >"$TEST_NM_LOG.stdin"; fi
[[ $2 != "$TEST_NM_FAIL" ]]
`, {mode: 0o755})

  const password = 'literal $() \\" secret'
  function connect(caCert, serverName, failAction) {
    const log = path.join(scratch, 'nmcli-log')
    for (const name of fs.readdirSync(scratch)) {
      if (name.startsWith('nmcli-log')) fs.unlinkSync(path.join(scratch, name))
    }
    const result = childProcess.spawnSync('bash', ['-c', network.enterpriseConnectScript,
      'nmcli-eap', 'Enterprise WiFi', 'person@example.org', caCert, serverName], {
      input: password + '\n', encoding: 'utf8', timeout: 2000,
      env: {...process.env, PATH: scratch + ':' + process.env.PATH,
        TEST_NM_LOG: log, TEST_NM_FAIL: failAction || ''}
    })
    const count = fs.existsSync(log + '.count') ? Number(fs.readFileSync(log + '.count', 'utf8')) : 0
    const calls = []
    for (let i = 1; i <= count; i++) calls.push(fs.readFileSync(log + '.' + i, 'utf8').split('\0').slice(0, -1))
    const stdin = fs.existsSync(log + '.stdin') ? fs.readFileSync(log + '.stdin', 'utf8') : ''
    return {result, calls, stdin}
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

  for (const serverName of ['radius.example.org', 'RADIUS.example.org', 'radius', 'xn--radius-9za.example.org']) {
    assert(network.enterpriseTrustValid(cert, serverName), 'enterprise UI accepts exact administrator server ' + serverName)
  }
  for (const serverName of ['', '*.example.org', 'radius.example.org;evil.example.org', 'radius.example.org\n', 'a'.repeat(254)]) {
    assert(!network.enterpriseTrustValid(cert, serverName), 'enterprise UI rejects invalid server ' + JSON.stringify(serverName))
  }
  assert(!network.enterpriseTrustValid('', 'radius.example.org'), 'enterprise UI requires a CA certificate path')

  // Exercise the production caller as well as the subprocess boundary.
  const Model = network
  const enterpriseConnect = {running: false, secret: '', command: []}
  var actionCount = 0
  function runNetworkAction(kind, ssidNetwork, callback) { actionCount++; callback({name: ssidNetwork}) }
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
} finally {
  fs.rmSync(scratch, {recursive: true, force: true})
}
JS
