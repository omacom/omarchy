#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs'), os = require('os'), cp = require('child_process')
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'keyring-'))
const trusted = '40DFB630FF42BCFFB047046CF0134EE680CAC571'
try {
  const bin = path.join(tmp, 'bin'), log = path.join(tmp, 'calls'), rings = path.join(tmp, 'rings')
  fs.mkdirSync(bin)
  function stub(name, body) {
    fs.writeFileSync(path.join(bin, name), '#!/bin/bash\nset -e\n' + body + '\n', {mode: 0o755})
  }
  stub('sudo', 'exec "$@"')
  stub('omarchy-hw-apple-silicon', '[[ ${APPLE:-0} == 1 ]]')
  stub('pacman-key', `echo "key $*" >> "$CALLS"
[[ "$*" != "\${FAIL_STEP:-}" ]] || exit 42
case $1 in
  --populate)
    shift
    for ring in "$@"; do [[ -f "$RINGS/$ring.gpg" ]] || exit 43; done ;;
  --recv-keys) touch "$RINGS/received" ;;
  --list-keys)
    if [[ -f "$RINGS/refreshed" && \${FINAL_LIST_FAIL:-0} == 1 ]]; then exit 44; fi
    [[ \${MISSING_KEY:-0} == 0 || -f "$RINGS/received" ]] ;;
esac`)
  stub('pacman', `echo "pacman $*" >> "$CALLS"
[[ \${PACMAN_STATUS:-0} == 0 ]] || exit "$PACMAN_STATUS"
touch "$RINGS/omarchy.gpg" "$RINGS/archlinux.gpg" "$RINGS/archlinuxarm.gpg" "$RINGS/asahi-alarm.gpg" "$RINGS/refreshed"`)
  stub('gpg', `echo "pub:::::::::"
echo "fpr:::::::::\${FINGERPRINT:-${trusted}}:"`)
  // Redirect only the system keyring payload directory to a disposable fixture.
  const script = path.join(tmp, 'update-keyring')
  fs.writeFileSync(script, fs.readFileSync(path.join(root, 'bin/omarchy-update-keyring'), 'utf8')
    .replaceAll('/usr/share/pacman/keyrings/', rings + '/'))
  const env = {...process.env, PATH: bin + ':' + process.env.PATH, CALLS: log, RINGS: rings}
  function run(extra = {}, payloads = ['omarchy', 'archlinux', 'archlinuxarm', 'asahi-alarm']) {
    fs.rmSync(rings, {recursive: true, force: true})
    fs.mkdirSync(rings)
    for (const ring of payloads) fs.writeFileSync(path.join(rings, ring + '.gpg'), '')
    fs.writeFileSync(log, '')
    const result = cp.spawnSync('bash', [script], {env: {...env, ...extra}, encoding: 'utf8'})
    return {...result, log: fs.readFileSync(log, 'utf8')}
  }
  for (const apple of ['0', '1']) {
    const ring = apple === '1' ? 'archlinuxarm' : 'archlinux'
    const activeRings = apple === '1' ? ['omarchy', ring, 'asahi-alarm'] : ['omarchy', ring]
    const packages = activeRings.map(name => name + '-keyring').join(' ')
    const populated = activeRings.join(' ')
    for (const payloads of [activeRings, [ring], ['omarchy'], []]) {
      for (const missing of ['0', '1']) {
        const r = run({APPLE: apple, MISSING_KEY: missing}, payloads)
        assertEqual(r.status, 0, `${ring} recovers with payloads [${payloads}] and missing key ${missing}`, r.stderr)
        assert(r.log.includes(`pacman -Sy --noconfirm ${packages}`), 'all repository keyring packages are refreshed')
        const beforeInstall = r.log.split('pacman -Sy')[0]
        for (const candidate of activeRings) {
          assertEqual(beforeInstall.includes(`key --populate ${candidate}\n`), payloads.includes(candidate), 'only available payloads are populated before reinstall')
        }
        assert(r.log.indexOf(`key --populate ${populated}`) > r.log.indexOf('pacman -Sy'), 'updated payloads are populated after reinstall')
        assertEqual(r.log.includes('--recv-keys'), missing === '1', 'bootstrap fetch is limited to missing keys')
        assert(r.stdout.includes('Keys are correct'), 'healthy keyring reports success')
      }
    }
    for (const extra of [
      {PACMAN_STATUS: '42'},
      {FAIL_STEP: `--populate ${ring}`},
      {FAIL_STEP: '--populate omarchy'},
      {FAIL_STEP: `--populate ${populated}`},
      {FAIL_STEP: `--lsign-key ${trusted}`},
      {MISSING_KEY: '1', FAIL_STEP: `--recv-keys ${trusted} --keyserver keys.openpgp.org`}
    ]) {
      const r = run({APPLE: apple, ...extra})
      assertEqual(r.status, 42, 'keyring operation failures propagate', r.stderr)
      assert(!r.stdout.includes('Keys are correct'), 'failed update never reports success')
      if (extra.FAIL_STEP?.startsWith('--recv-keys')) {
        assert(!r.log.includes('--lsign-key') && !r.log.includes('pacman -Sy'), 'failed key retrieval stops signing and package installation')
      }
    }
    if (apple === '1') {
      const asahi = run({APPLE: apple, FAIL_STEP: '--populate asahi-alarm'})
      assertEqual(asahi.status, 42, 'Asahi keyring population failures stop the update')
      assert(!asahi.stdout.includes('Keys are correct'), 'Asahi failure cannot report success')
    }
    const final = run({APPLE: apple, FINAL_LIST_FAIL: '1'})
    assertEqual(final.status, 44, 'upstream final key check failure propagates')
    assert(!final.stdout.includes('Keys are correct'), 'final verification failure cannot report success')
    const wrong = run({APPLE: apple, FINGERPRINT: '0000000000000000000000000000000000000000'})
    assertEqual(wrong.status, 1, 'wrong signing fingerprint is rejected')
    assert(!wrong.log.includes('--lsign-key') && !wrong.log.includes('pacman -Sy'), 'wrong fingerprint cannot be trusted or used to update')
  }
} finally {
  fs.rmSync(tmp, {recursive: true, force: true})
}
JS
