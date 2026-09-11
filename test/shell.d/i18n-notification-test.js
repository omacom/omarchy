const assert = require('assert')
const fs = require('fs')
const os = require('os')
const path = require('path')
const { execFileSync } = require('child_process')
const root = path.resolve(__dirname, '../..')
const catalog = require('../../default/i18n/zh_CN.json')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-i18n-'))
function stub(name, source) { fs.writeFileSync(path.join(temp, name), '#!/bin/bash\n' + source, { mode: 0o755 }) }
try {
  // Invoke helpers through the test Bash (Bash 5 is required by Omarchy).
  stub('omarchy-i18n', 'exec bash "$OMARCHY_PATH/bin/omarchy-i18n" "$@"\n')
  stub('omarchy-notification-send', 'printf "%s" "${@: -1}"\n')
  stub('omarchy-battery-status', `if [[ $1 == "--shell" ]]; then
  printf 'percentage\\t80%%\\nstate\\t%s\\nrate\\t20W\\nsize\\t52Wh\\ntime\\t%s\\nthreshold\\t80%%\\n' "$STATE" "$BATTERY_TIME"
else
  printf '%s' "$ORIGINAL_STATUS"
fi
`)
  const english = 'Battery 80%  ·  original CLI output 20W / 52Wh 2h'
  stub('date', `case "$1" in
  +%Y) echo 2026 ;;
  +%-m) echo 9 ;;
  +%-d) echo 9 ;;
  +%A) echo Wednesday ;;
  +%H:%M) echo 08:05 ;;
  +%-V) echo 37 ;;
  *) echo 'Wednesday 08:05  ·  09 September 2026  ·  Week 37' ;;
esac
`)
  for (const locale of ['zh_CN', 'en', 'zh_TW']) {
    const env = { ...process.env, PATH: temp + ':' + process.env.PATH, OMARCHY_PATH: root, OMARCHY_UI_LANGUAGE: locale, ORIGINAL_STATUS: english }
    const run = (file, extra = {}) => execFileSync('bash', [path.join(root, 'bin', file)], { env: { ...env, ...extra }, encoding: 'utf8' })
    assert.strictEqual(run('omarchy-notification-time'), locale === 'zh_CN' ? '2026年9月9日 星期三 08:05  ·  第37周' : 'Wednesday 08:05  ·  09 September 2026  ·  Week 37')
    for (const [state, time, expected] of [
      ['holding', '', '电池 80%  ·  保持在 80%  ·  20W / 52Wh'],
      ['charging', '2h', '电池 80%  ·  2h 后充满  ·   20W / 52Wh'],
      ['charging', '', '电池 80%  ·  正在充电  ·   20W / 52Wh'],
      ['discharging', '2h', '电池 80%  ·  剩余 2h  ·   20W / 52Wh'],
      ['discharging', '', '电池 80%  ·  正在放电  ·   20W / 52Wh']
    ]) assert.strictEqual(run('omarchy-notification-battery', { STATE: state, BATTERY_TIME: time }), locale === 'zh_CN' ? expected : english)
  }
  // Test only the modified notification function, never execute the privileged migration.
  const migration = fs.readFileSync(path.join(root, 'migrations/1787494718.sh'), 'utf8')
  const reportFunction = migration.match(/report_unrepairable\(\) \{[\s\S]*?\n\}/)[0]
  for (const locale of ['zh_CN', 'en', 'zh_TW']) {
    for (const key of ['notification.fido2.symlink', 'notification.fido2.not_regular']) {
      const output = execFileSync('bash', ['-c', reportFunction + '\nauthfile=/test/authfile\nreport_unrepairable "Original first sentence." "Original second sentence." "$1"', 'fixture', key], {
        env: { ...process.env, PATH: temp + ':' + process.env.PATH, OMARCHY_PATH: root, OMARCHY_UI_LANGUAGE: locale }, encoding: 'utf8'
      })
      assert.strictEqual(output, '  Original first sentence.\n  Original second sentence.\n' + (locale === 'zh_CN' ? catalog[key].replace('%1', '/test/authfile') : 'Original first sentence. Original second sentence.'))
    }
  }
  console.log('ok - migration notification function preserves terminal output and translates both body variants')
  for (const name of ['time', 'battery']) {
    const source = fs.readFileSync(path.join(root, 'bin/omarchy-notification-' + name), 'utf8')
    assert(!/\p{Script=Han}/u.test(source), 'Chinese must live in catalogs')
    assert(!source.includes('ui.' + name + '.locale'))
  }
  assert(!('ui.date.locale' in catalog)); assert(!('ui.battery.locale' in catalog))
  const arities = { 'notification.time.format': 6, 'notification.battery.holding': 4, 'notification.battery.charging_with_time': 4, 'notification.battery.charging': 3, 'notification.battery.discharging_with_time': 4, 'notification.battery.discharging': 3 }
  for (const [key, count] of Object.entries(arities)) {
    assert.deepStrictEqual([...catalog[key].matchAll(/%(\d+)/g)].map(m => Number(m[1])).sort(), Array.from({ length: count }, (_, i) => i + 1))
  }
  console.log('ok - date and all five battery states in zh_CN/en/zh_TW; template arities')
} finally { fs.rmSync(temp, { recursive: true, force: true }) }
