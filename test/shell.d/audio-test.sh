#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')

assert(audio.isPlaybackStream({ isStream: true, isSink: true }), 'audio detects sink-backed playback streams')
assert(audio.isPlaybackStream({ isStream: true, type: 'Stream/Output/Audio' }), 'audio detects typed playback streams')
assert(!audio.isPlaybackStream({ isStream: false, isSink: true }), 'audio rejects non-stream playback nodes')
assert(audio.isAudioSource({ audio: {} }), 'audio detects nodes with audio as sources')
assert(audio.isAudioSource({ type: 'Audio/Source' }), 'audio detects typed source nodes')

// A destroyed PwNode stays truthy but reads back no id, which is the shape the
// third entry stands in for: it must not reach a Repeater row. The first carries
// an object like a live node's audio, so a row that is the node itself fails here.
assertDeepEqual(
  audio.rowSnapshot([{ id: 0, name: 'alsa_output', audio: { volume: 1 } }, { id: 42 }, {}, null]),
  [{ id: 0, name: 'alsa_output' }, { id: 42, name: '' }],
  'audio projects nodes to primitive rows and drops nodes without an id'
)
assertDeepEqual(audio.rowSnapshot(undefined), [], 'audio projects a missing list to no rows')
assert(audio.nodeRow({ id: 7, name: 'bluez_output' }).name === 'bluez_output', 'audio rows carry the node name that identifies them')

assertEqual(audio.outputVolumeName(0, false), 'Silenced', 'audio labels silent output')
assertEqual(audio.outputVolumeName(0.9, false), 'Party mode', 'audio labels loud output')
assertEqual(audio.outputVolumeName(0.5, true), 'Muted', 'audio labels muted output')

assertDeepEqual(audio.parseSinkAvailability('alsa_output\t1\nhdmi_output\t0\n'), { alsa_output: true, hdmi_output: false }, 'audio parses sink availability')
assertEqual(audio.friendlyDeviceLabel('Built-in Audio Speakers Output'), 'Speakers', 'audio cleans device labels')
assertEqual(
  audio.nodeLabel({ ready: true, properties: { 'node.nick': 'Built-in Audio Microphones Input' }, name: 'alsa_input' }),
  'Microphone',
  'audio chooses friendly node labels'
)

const headphones = { ready: true, name: 'bluez_output.airpods', properties: { 'device.product.name': 'AirPods Headphones' } }
assert(audio.isHeadphones(headphones), 'audio detects headphone devices')
assertEqual(audio.sinkGlyph(headphones), '󰋋', 'audio uses headphone sink glyph')
assert(audio.sourceGlyph({ ready: true, properties: { 'device.icon-name': 'camera-webcam' } }).length > 0, 'audio maps webcam source glyph')

assertEqual(audio.friendlyStreamLabel('spotify'), 'Spotify', 'audio normalizes known stream labels')
assert(audio.streamRepresentsMprisPlayer('Chromium', 'Chromium Browser'), 'audio matches related stream and MPRIS labels')

const players = [
  { identity: 'Spotify', canPlay: true, isPlaying: true, dbusName: 'org.mpris.MediaPlayer2.spotify' },
  { identity: 'Chromium', canPlay: true, isPlaying: false, dbusName: 'org.mpris.MediaPlayer2.chromium' }
]
const streams = [
  { ready: true, properties: { 'application.name': 'Chromium' } },
  { ready: true, properties: { 'application.name': 'audio-src' } }
]

assertEqual(audio.matchingMprisStreamLabel('Chromium', players), 'Chromium', 'audio finds matching MPRIS labels')
assertEqual(audio.unmatchedMprisStreamLabel('audio-src', players, streams), 'Spotify', 'audio uses unmatched MPRIS player for generic streams')
assertEqual(audio.streamLabel(streams[1], players, streams), 'Spotify', 'audio labels generic streams from MPRIS')
assert(audio.streamRepresentsPlayer(streams[1], players[0], players, streams), 'audio links generic streams to active player')

// A virtual source is untyped in Quickshell (no audio); PulseAudio's source
// listing is what names it a source.
const availability = { virtual_mic: true, 'alsa_input.usb': false }
assert(audio.isUntypedSource({ name: 'virtual_mic', isSink: false, isStream: false }, availability), 'audio finds an untyped source PulseAudio lists')
assert(audio.isUntypedSource({ name: 'unplugged_virtual', isSink: false, isStream: false }, { unplugged_virtual: false }), 'an untyped source PulseAudio lists as unavailable is still a source')
assert(!audio.isUntypedSource({ name: 'v4l2_input.camera', isSink: false, isStream: false }, availability), 'audio skips an untyped node PulseAudio does not list')
assert(!audio.isUntypedSource({ name: 'virtual_mic', audio: {}, isSink: false, isStream: false }, availability), 'a typed source is not untyped')
assert(!audio.isUntypedSource({ name: 'virtual_mic', isSink: false, isStream: true }, availability), 'a stream is never an untyped source')
assert(!audio.isUntypedSource({ name: '', isSink: false, isStream: false }, { '': true }), 'a nameless node is never an untyped source')
assert(!audio.isUntypedSource({ name: 'virtual_mic', isSink: false, isStream: false }, {}), 'nothing is untyped before the listing')

// An unplugged jack input leaves the list unless it is the current one.
const mic = { name: 'alsa_input.mic' }
const headset = { name: 'alsa_input.headset' }
const jacks = { 'alsa_input.mic': true, 'alsa_input.headset': false }
assertDeepEqual(audio.availableDevices([mic, headset], jacks, mic), [mic], 'audio leaves out an unplugged headset microphone')
assertDeepEqual(audio.availableDevices([mic, headset], jacks, headset), [headset, mic], 'audio keeps the current device even when unplugged')

const nodes = requireFromRoot('shell/Commons/AudioNodesModel.js')

for (const name of ['quickshell', 'quickshell-peak-monitor'])
  assert(nodes.isShellLevelMeter(name), 'audio knows the shell meter ' + name)
for (const name of ['Firefox', 'quickshell-other', '', undefined])
  assert(!nodes.isShellLevelMeter(name), 'audio counts ' + name + ' as a recording')

// Platform hints: none by default, whole-name patterns, and "replaced" only
// while its replacement exists.
const none = nodes.parsePlatformAudio('')
assertDeepEqual([none.hidden.length, none.replaced.length], [0, 0], 'audio has no platform hints without the file')
for (const text of ['not json', '[]', 'null', '{"hidden": "x"}', '{"replaced": [1, {"node": "a"}, {"node": "(", "by": "b"}]}']) {
  const parsed = nodes.parsePlatformAudio(text)
  assertEqual(parsed.hidden.length + parsed.replaced.length, 0, 'audio ignores platform hints ' + text)
}
const hints = nodes.parsePlatformAudio(JSON.stringify({
  hidden: ['dsp_capture\\.[a-z]+', 'raw_speakers', '(', 7],
  replaced: [{ node: 'dsp_mic\\.[0-9]+', by: 'stereo_mic' }]
}))
assertEqual(hints.hidden.length, 2, 'audio skips invalid hidden patterns')
const names = ['dsp_capture.mic', 'dsp_mic.1', 'stereo_mic', 'raw_speakers']
assert(nodes.platformHidesNode('dsp_capture.mic', hints, names), 'platform hints hide a matching node')
assert(nodes.platformHidesNode('raw_speakers', hints, []), 'platform hints hide a literal name')
assert(!nodes.platformHidesNode('raw_speakers.monitor', hints, []), 'platform patterns match whole names only')
assert(!nodes.platformHidesNode('xdsp_capture.mic', hints, []), 'platform patterns are anchored at the start')
assert(nodes.platformHidesNode('dsp_mic.1', hints, names), 'platform hints hide a replaced node while its replacement exists')
assert(!nodes.platformHidesNode('dsp_mic.1', hints, ['dsp_mic.1']), 'platform hints keep a replaced node without its replacement')
assert(!nodes.platformHidesNode('stereo_mic', hints, names), 'platform hints keep the replacement')
for (const name of ['Firefox', 'alsa_input.pci-0000_00_1f.3.analog-stereo', '', undefined])
  assert(!nodes.platformHidesNode(name, hints, names), 'platform hints keep ' + name)
assert(!nodes.platformHidesNode('dsp_capture.mic', none, names), 'no platform hints hide nothing')

// An untyped source's level is read from wpctl.
assertDeepEqual(nodes.parseWpctlVolume('Volume: 0.50\n'), { volume: 0.5, muted: false }, 'audio reads a wpctl volume')
assertDeepEqual(nodes.parseWpctlVolume('Volume: 1.00 [MUTED]'), { volume: 1, muted: true }, 'audio reads a muted wpctl volume')
for (const text of ['', 'Translate ID error: 404', 'Volume: loud', 'Volume: 0.50 [muted]'])
  assertEqual(nodes.parseWpctlVolume(text), null, 'audio rejects wpctl output ' + JSON.stringify(text))

const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
// Platform quirks arrive as hints; the audio code names no platform or hardware of its own.
const sources = ['shell/plugins/panels/audio/Panel.qml', 'shell/plugins/panels/audio/Model.js', 'shell/Commons/AudioNodes.qml',
  'shell/Commons/AudioNodesModel.js', 'shell/Commons/UntypedInput.qml', 'shell/plugins/bar/widgets/Microphone.qml',
  'bin/omarchy-audio-input-set-default', 'bin/omarchy-audio-sink-availability']
for (const file of sources)
  assert(!/apple|asahi|macbook|j[0-9]{3}|omarchy-hw-|platform-sound/i.test(read(file)), file + ' names no platform')

const panel = read('shell/plugins/panels/audio/Panel.qml')
{
  const body = panel.match(/function resolveVolumeSink\(\) \{([\s\S]*?)\n  \}/)[1]
  const resolve = new Function('sink', 'volumeSinkProc', 'state', body.replace(/\b(volumeSinkName|volumeSinkStale|volumeSinkGeneration|volumeSinkRequest)\b/g, 'state.$1'))
  const finished = new Function('root', 'text', panel.match(/onStreamFinished: \{\s*(if \(root\.volumeSinkRequest[^\n]*)/)[1])
  const proc = { running: false }
  const state = { volumeSinkName: '', volumeSinkStale: false, volumeSinkGeneration: 0, volumeSinkRequest: -1 }
  resolve({ name: 'alsa_output.pci-0000_00_1f.3.analog-stereo' }, proc, state)
  assert(!proc.running && state.volumeSinkName === 'alsa_output.pci-0000_00_1f.3.analog-stereo', 'a hardware output resolves to itself without the script')
  resolve({ name: 'bluez_output.AA_BB_CC_DD_EE_FF.1' }, proc, state)
  assert(!proc.running && state.volumeSinkName === 'bluez_output.AA_BB_CC_DD_EE_FF.1', 'a bluetooth output resolves to itself without the script')
  resolve({ name: 'omarchy_speaker_tuning' }, proc, state)
  assert(proc.running, 'a DSP output resolves through the script')
  resolve({ name: 'omarchy_speaker_tuning' }, proc, state)
  assert(state.volumeSinkStale, 'a change during a resolve is marked for a rerun')
  {
    // Quickshell still reports the process running while it signals exit.
    const exited = new Function('root', 'Qt', panel.match(/id: volumeSinkProc[\s\S]*?onExited: \{([\s\S]*?)\n    \}/)[1])
    const deferred = []
    const sink = { name: 'omarchy_speaker_tuning' }
    state.resolveVolumeSink = () => resolve(sink, proc, state)
    const requestBefore = state.volumeSinkRequest
    exited(state, { callLater: callback => deferred.push(callback) })
    proc.running = false
    assert(deferred.length === 1 && !state.volumeSinkStale, 'the rerun waits until the read has exited')
    deferred.shift()()
    assert(proc.running && state.volumeSinkRequest > requestBefore, 'a change during a resolve runs it again afterwards')
  }
  resolve({ name: 'alsa_output.usb-headset' }, proc, state)
  finished(state, 'alsa_output.speakers\n')
  assertEqual(state.volumeSinkName, 'alsa_output.usb-headset', 'a script read that predates a switch to hardware cannot overwrite it')
}

const volume = requireFromRoot('shell/Commons/AudioVolumeModel.js')
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
// PanelSlider's wheel steps from the position and clamps it to 1.
for (const scale of ['linear', 'decibel']) {
  const notch = scale === 'decibel' ? 2 / 60 : 0.05
  assertEqual(volume.volume(Math.min(1, volume.position(1.2, scale) - notch), scale), 1, 'a wheel notch down brings a boosted output to 100%: ' + scale)
}
for (const level of [0.2, 0.5, 1]) {
  near(volume.volume(volume.position(level, 'decibel'), 'decibel'), level, 'the slider round-trips ' + level)
  near(volume.volume(volume.position(level, 'linear'), 'linear'), level, 'the linear slider round-trips ' + level)
}

assertEqual(volume.readout(0.5, 'linear'), '50%', 'linear reads in percent')
assertEqual(volume.readout(0.5, 'decibel'), '-18.1 dB', 'decibel reads in dB')
assertEqual(volume.readout(0, 'decibel'), 'Silent', 'silence reads as silent')
const danish = (v, d) => (d === undefined ? String(v) : v.toFixed(d)).replace('.', ',')
const tr = (key, english) => ({ 'audio.volume.decibels': '%1 dB (da)', 'audio.volume.silent': 'Stille' })[key] || english
assertEqual(volume.readout(0.5, 'decibel', tr, danish), '-18,1 dB (da)', 'the dB readout is translated and localized')
assertEqual(volume.readout(0, 'decibel', tr, danish), 'Stille', 'silence is translated')
assertEqual(volume.readout(0.5, 'linear', tr, danish), '50%', 'the percent readout takes localized digits')

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
    const env = { ...process.env, HOME: scratch, XDG_RUNTIME_DIR: scratch, OMARCHY_PATH: root, PATH: bin + ':' + path.join(root, 'bin') + ':' + process.env.PATH, TEST_STATE: state, TEST_OSD: osd }
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
