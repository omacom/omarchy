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

const AUX = 4096
assert(!audio.needsProcessMeter([3, 4], AUX), 'audio meters positioned channels natively')
assert(!audio.needsProcessMeter([], AUX), 'audio meters unbound nodes natively until channels are known')
assert(!audio.needsProcessMeter(null, AUX), 'audio meters nodes without a channel list natively')
assert(audio.needsProcessMeter([AUX, AUX + 1], AUX), 'audio meters AUX channels through the process')
assert(audio.needsProcessMeter([3, 0], AUX), 'audio meters unknown channels through the process')

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

const nodes = requireFromRoot('shell/Commons/AudioNodesModel.js')

for (const name of ['quickshell', 'quickshell-peak-monitor', 'omarchy-input-meter'])
  assert(nodes.isShellLevelMeter(name), 'audio knows the shell meter ' + name)
for (const name of ['Firefox', 'quickshell-other', 'pw-record', '', undefined])
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

// Source wiring (no Quickshell here): the hints come from the fixed platform
// root, and the audio code names no platform or hardware of its own.
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const audioNodes = read('shell/Commons/AudioNodes.qml')
assert(/path: "\/usr\/share\/omarchy-platform\/audio\.json"/.test(audioNodes) && !/Quickshell\.env|OMARCHY_/.test(audioNodes),
  'audio reads the platform hints from the fixed platform root')
assert(/onLoadFailed: missing = true/.test(audioNodes), 'a removed hints file hides nothing')
const sources = ['shell/plugins/panels/audio/Panel.qml', 'shell/plugins/panels/audio/Model.js', 'shell/Commons/AudioNodes.qml',
  'shell/Commons/AudioNodesModel.js', 'shell/Commons/UntypedInput.qml', 'shell/plugins/bar/widgets/Microphone.qml',
  'bin/omarchy-audio-input-set-default', 'bin/omarchy-audio-sink-availability']
for (const file of sources)
  assert(!/apple|asahi|macbook|j[0-9]{3}|omarchy-hw-|platform-sound/i.test(read(file)), file + ' names no platform')

const panel = read('shell/plugins/panels/audio/Panel.qml')
assert(/inputPeakNode: inputViaWpctl \? null : source/.test(panel) && /inputLevelShown: !!inputPeakNode/.test(panel) &&
  /visible: root\.inputLevelShown[^}]*inputMeter\.peak/.test(panel),
  'the input level bar is hidden when the input is driven through wpctl')
JS

# input-peak's arithmetic, with a stub pw-record on PATH standing in for the
# device: three 40 ms windows of stereo f32 samples, peaking at 0.5, 0.25 and a
# quiet 0.000001, which the panel still shows once the source volume is divided out.
# It emits nothing unless asked for the node, for headerless samples (without
# --raw pw-record writes an AU header) and for a latency pw-record can parse.
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
cat > "$stub_dir/pw-record" <<'STUB'
#!/bin/bash
[[ " $* " == *" --target stub-node "* && " $* " == *" --raw "* && " $* " =~ \ --latency\ [0-9]+(ns|us|ms|s)?\  ]] || exit 1
node -e '
  const frames = 640, channels = 2
  const out = new Float32Array(frames * channels * 3)
  out[0] = -0.5
  out[frames * channels + 1] = 0.25
  out[frames * channels * 2] = 0.000001
  process.stdout.write(Buffer.from(out.buffer))
'
STUB
chmod +x "$stub_dir/pw-record"

peaks=$(PATH="$stub_dir:$PATH" bash "$ROOT/shell/plugins/panels/audio/input-peak" stub-node 2 | tr '\n' ' ')
if [[ $peaks == "0.5 0.25 1e-06 " ]]; then
  pass "input-peak reports the largest magnitude per window across channels"
else
  fail "input-peak reports the largest magnitude per window across channels" "got: $peaks"
fi

peaks=$(PATH="$stub_dir:$PATH" bash "$ROOT/shell/plugins/panels/audio/input-peak" stub-node 0 | tr '\n' ' ')
if [[ $peaks == "0.5 0 0.25 0 1e-06 0 " ]]; then
  pass "input-peak treats a channel count below one as mono"
else
  fail "input-peak treats a channel count below one as mono" "got: $peaks"
fi

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping InputMeter process lifecycle"
  exit 0
fi

# InputMeter itself, offscreen, against a stand-in AUX node and a stub
# pw-record that streams a constant 0.5 for about ten seconds and logs each start.
work=$(mktemp -d)
work_exit=$(mktemp -d)
trap 'rm -rf "$stub_dir" "$work" "$work_exit"' EXIT
mkdir -p "$work/bin" "$work/config" "$work/runtime" "$work/home"
chmod 700 "$work/runtime"
node -e 'process.stdout.write(Buffer.from(new Float32Array(1280).fill(0.5).buffer))' > "$work/bin/chunk"
cat > "$work/bin/pw-record" <<'STUB'
#!/bin/bash
echo "$$" >> "${0%/*}/starts"
for _ in {1..250}; do
  cat "${0%/*}/chunk"
  sleep 0.04
done
STUB
chmod +x "$work/bin/pw-record"
cp "$SHELL_TEST_DIR/fixtures/input-meter/shell.qml" "$work/config/shell.qml"
ln -s "$ROOT/shell/plugins/panels/audio" "$work/config/audio"

PATH="$work/bin:$PATH" HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 15 quickshell -p "$work/config" --no-color >"$work/log" 2>&1 || true
starts=$(wc -l < "$work/bin/starts" 2>/dev/null || echo 0)
if grep -q 'INPUT_METER_TEST_PASS' "$work/log" && (( starts == 2 )); then
  pass "InputMeter restarts its capture after a stop and start in one turn"
else
  fail "InputMeter restarts its capture after a stop and start in one turn" "captures started: $starts; $(grep -E 'INPUT_METER|ERROR|WARN' "$work/log")"
fi

# A capture that exits while the panel stays open, as pw-record does when
# PipeWire restarts, is started again. The stub's first run lasts half a second.
mkdir -p "$work_exit/bin" "$work_exit/config" "$work_exit/runtime" "$work_exit/home"
chmod 700 "$work_exit/runtime"
cp "$work/bin/chunk" "$work_exit/bin/chunk"
cat > "$work_exit/bin/pw-record" <<'STUB'
#!/bin/bash
runs=12
[[ -f ${0%/*}/starts ]] && runs=250
echo "$$" >> "${0%/*}/starts"
for (( i = 0; i < runs; i++ )); do
  cat "${0%/*}/chunk"
  sleep 0.04
done
STUB
chmod +x "$work_exit/bin/pw-record"
cp "$SHELL_TEST_DIR/fixtures/input-meter-exit/shell.qml" "$work_exit/config/shell.qml"
ln -s "$ROOT/shell/plugins/panels/audio" "$work_exit/config/audio"

PATH="$work_exit/bin:$PATH" HOME="$work_exit/home" XDG_RUNTIME_DIR="$work_exit/runtime" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 15 quickshell -p "$work_exit/config" --no-color >"$work_exit/log" 2>&1 || true
starts=$(wc -l < "$work_exit/bin/starts" 2>/dev/null || echo 0)
if grep -q 'INPUT_METER_TEST_PASS' "$work_exit/log" && (( starts == 2 )); then
  pass "InputMeter starts its capture again after it exits on its own"
else
  fail "InputMeter starts its capture again after it exits on its own" "captures started: $starts; $(grep -E 'INPUT_METER|ERROR|WARN' "$work_exit/log")"
fi
