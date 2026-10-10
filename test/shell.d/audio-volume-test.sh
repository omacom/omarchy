#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const volume = requireFromRoot('shell/Commons/AudioVolume.js')
const fs = require('fs')
const os = require('os')
const { spawnSync } = require('child_process')

function near(actual, expected, message) {
  assert(Math.abs(actual - expected) <= 1 / 65536, message + ': ' + actual + ' vs ' + expected)
}
const atDecibels = db => Math.pow(10, db / 60)

assertEqual(volume.scale({}), 'linear', 'the scale defaults to linear')
assertEqual(volume.scale({ audio: { volumeScale: 'bad' } }), 'linear', 'an unknown scale is linear')
assertEqual(volume.scale({ audio: { volumeScale: 'decibel' } }), 'decibel', 'the decibel scale is read from shell.json')

// Linear steps keep omarchy-audio-output-volume's rules.
near(volume.step(0.43, 1, 'linear', false), 0.48, 'linear steps 5%')
near(volume.step(0.48, -1, 'linear', true), 0.47, 'precise linear steps 1%')
near(volume.step(0.484, 1, 'linear', false), 0.53, 'linear steps land on whole percents')
assertEqual(volume.step(0.98, 1, 'linear', false), 1, 'raising stops at 100%')
assertEqual(volume.step(1.2, 1, 'linear', false), 1, 'raising brings a boosted output back to 100%')
near(volume.step(1.2, -1, 'linear', false), 1.15, 'lowering steps down from a boosted output')
assertEqual(volume.step(0.03, -1, 'linear', false), 0, 'lowering stops at silence')

// Decibel steps are 2 dB, 0.5 dB precise, with silence at -60 dB and below.
near(volume.step(atDecibels(-20), 1, 'decibel', false), atDecibels(-18), 'decibel steps 2 dB')
near(volume.step(atDecibels(-20), -1, 'decibel', true), atDecibels(-20.5), 'precise decibel steps 0.5 dB')
assertEqual(volume.step(atDecibels(-1), 1, 'decibel', false), 1, 'raising stops at 0 dB')
near(volume.step(1.2, -1, 'decibel', false), 1.2 * atDecibels(-2), 'lowering steps down from a boosted output')
near(volume.step(0, 1, 'decibel', false), atDecibels(-58), 'raising from silence starts one step above the floor')
assertEqual(volume.step(atDecibels(-58), -1, 'decibel', false), 0, 'lowering to the floor is silence')
assertEqual(volume.step(0, -1, 'decibel', false), 0, 'lowering silence stays silent')

// The decibel slider is linear in dB: silence, then -60 dB to 0 dB.
assertEqual(volume.position(0, 'decibel'), 0, 'silence is the left end')
near(volume.position(atDecibels(-30), 'decibel'), 0.5, '-30 dB is the middle')
assertEqual(volume.position(1, 'decibel'), 1, '0 dB is the right end')
assertEqual(volume.volume(0, 'decibel'), 0, 'the left end is silence')
for (const level of [0.2, 0.5, 1]) {
  near(volume.volume(volume.position(level, 'decibel'), 'decibel'), level, 'the slider round-trips ' + level)
  near(volume.volume(volume.position(level, 'linear'), 'linear'), level, 'the linear slider round-trips ' + level)
}

assertEqual(volume.readout(0.5, 'linear'), '50%', 'linear reads in percent')
assertEqual(volume.readout(0.5, 'decibel'), '-18.1 dB', 'decibel reads in dB')
assertEqual(volume.readout(0, 'decibel'), 'Silent', 'silence reads as silent')

// The command fallback steps like the shell does, against a pactl stub.
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-volume-'))
try {
  const bin = path.join(scratch, 'bin')
  const state = path.join(scratch, 'state')
  const osd = path.join(scratch, 'osd')
  fs.mkdirSync(bin)
  fs.mkdirSync(path.join(scratch, '.config/omarchy'), { recursive: true })
  const stub = (name, body) => fs.writeFileSync(path.join(bin, name), '#!/bin/bash\n' + body + '\n', { mode: 0o755 })
  stub('omarchy-audio-output-sink', 'echo sink')
  stub('omarchy-osd', 'printf "%s\\n" "$@" >"$TEST_OSD"')
  stub('pactl', `read -r raw muted <"$TEST_STATE"
case "$1" in
  get-sink-volume) echo "Volume: front-left: $raw / $(( (raw * 100 + 32768) / 65536 ))% / 0.00 dB" ;;
  get-sink-mute) echo "Mute: $muted" ;;
  set-sink-mute) echo "$raw no" >"$TEST_STATE" ;;
  set-sink-volume) echo "$(awk -v p="\${3%\\%}" 'BEGIN { printf "%d", p * 655.36 + 0.5 }') $muted" >"$TEST_STATE" ;;
esac`)

  function run(action, current, scale) {
    fs.writeFileSync(state, Math.round(current * 65536) + ' yes\n')
    fs.writeFileSync(path.join(scratch, '.config/omarchy/shell.json'), JSON.stringify({ version: 1, audio: { volumeScale: scale } }))
    const env = { ...process.env, HOME: scratch, XDG_RUNTIME_DIR: scratch, PATH: bin + ':' + process.env.PATH, TEST_STATE: state, TEST_OSD: osd }
    const result = spawnSync('bash', [path.join(root, 'bin/omarchy-audio-output-volume'), action], { env, encoding: 'utf8' })
    assertEqual(result.status, 0, 'the command succeeds: ' + scale + ' ' + action + ' ' + current + result.stderr)
    const [raw, muted] = fs.readFileSync(state, 'utf8').trim().split(' ')
    return { volume: Number(raw) / 65536, muted, osd: fs.readFileSync(osd, 'utf8').trim().split('\n') }
  }

  const actions = [['raise', 1, false], ['lower', -1, false], ['raise-precise', 1, true], ['lower-precise', -1, true]]
  for (const scale of ['linear', 'decibel']) {
    for (const [action, steps, precise] of actions) {
      for (const current of [0, atDecibels(-59), 0.5, 1, 1.2]) {
        const quantized = Math.round(current * 65536) / 65536
        const result = run(action, current, scale)
        near(result.volume, Math.round(volume.step(quantized, steps, scale, precise) * 65536) / 65536, 'the command matches the shell: ' + scale + ' ' + action + ' ' + current)
        assertEqual(result.muted, 'no', 'stepping unmutes')
      }
    }
  }
  assertDeepEqual(run('raise', 0.5, 'linear').osd, ['-i', 'volume-high', '-p', '55'], 'the linear OSD is unchanged')
  assertDeepEqual(run('raise', atDecibels(-32), 'decibel').osd, ['-i', 'volume-high', '-p', '50', '-t', '-30.0 dB'], 'the decibel OSD shows the slider position and dB')
  assertDeepEqual(run('lower', atDecibels(-58), 'decibel').osd, ['-i', 'volume-muted', '-p', '0', '-t', 'Silent'], 'the decibel OSD shows silence')
  near(run('+1', 0.5, 'decibel').volume, 0.51, 'explicit steps stay in percent')
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}
JS
