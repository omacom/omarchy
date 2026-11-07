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

assertDeepEqual(
  audio.routeCommand(64, '101'),
  ['pw-metadata', '-n', 'default', '64', 'target.object', '101'],
  'audio pins a stream to an output'
)
assertDeepEqual(
  audio.routeCommand(64, audio.DEFAULT_ROUTE),
  ['pw-metadata', '-n', 'default', '64', 'target.object', '-1'],
  'audio hands a stream back to the default output'
)
const routeMetadata = [
  "update: id:120 key:'target.object' value:'sink.a' type:'(null)'",
  "update: id:121 key:'target.object' value:'-1' type:'(null)'",
  "update: id:122 key:'volume' value:'0.5' type:'(null)'"
].join('\n')
const routeTargets = audio.parseRouteTargets(routeMetadata)

assertDeepEqual(routeTargets, { '120': 'sink.a', '121': '-1' }, 'audio reads routing out of the default metadata object')
assertDeepEqual(audio.parseRouteTargets(''), {}, 'audio handles empty metadata')
assertEqual(audio.routeTargetOf({ id: 120 }, routeTargets), 'sink.a', 'audio reads a pinned stream')
assertEqual(audio.routeTargetOf({ id: 121 }, routeTargets), audio.DEFAULT_ROUTE, 'audio reads a cleared pin as following the default')
assertEqual(audio.routeTargetOf({ id: 999 }, routeTargets), audio.DEFAULT_ROUTE, 'audio reads an unlisted stream as following the default')
assert(audio.routeIsPinned({ id: 120 }, routeTargets), 'audio reports a pinned stream')
assert(!audio.routeIsPinned({ id: 999 }, routeTargets), 'audio reports an unpinned stream')

const routeSinks = [
  { ready: true, name: 'sink.a', nickname: 'Speakers', properties: { 'object.serial': 101 } },
  { ready: true, name: 'sink.b', nickname: 'HDMI', properties: { 'object.serial': 202 } }
]
assertDeepEqual(audio.routeOptions(routeSinks), [audio.DEFAULT_ROUTE, '101', '202'], 'audio offers the default output first')
assertEqual(audio.nextRouteTarget(audio.routeOptions(routeSinks), audio.DEFAULT_ROUTE), '101', 'audio cycles from the default to the first output')
assertEqual(audio.nextRouteTarget(audio.routeOptions(routeSinks), '202'), audio.DEFAULT_ROUTE, 'audio cycles from the last output back to the default')
assertEqual(audio.routeLabel({ id: 999 }, routeSinks, null, routeTargets), 'Follow default output', 'audio labels an unpinned stream')
assertEqual(audio.routeLabel({ id: 120 }, routeSinks, null, routeTargets), 'Speakers', 'audio labels a pinned stream by device')
assertEqual(audio.routeLabel({ id: 999 }, routeSinks, routeSinks[1], routeTargets), 'HDMI', 'audio prefers the linked output over the pin')
assertEqual(audio.routeLabel({ id: 120 }, routeSinks, null, { '120': '101' }), 'Speakers', 'audio resolves serial targets to device labels')

{
  const fs = require('fs')
  const vm = require('vm')
  const source = fs.readFileSync(path.join(root, 'shell/plugins/panels/audio/Panel.qml'), 'utf8')
  const panel = { audioSinks: routeSinks, routeTargets: {}, pendingRoutes: {}, routeGeneration: 0 }
  let reads = 0
  const writer = { running: false, command: null }
  const context = { root: panel, Model: audio, routeWriteProc: writer, routeTargetsProc: { restart() { reads++ } } }
  for (const name of ['cycleStreamRoute', 'runNextRoute', 'acceptRouteSnapshot']) {
    const method = source.match(new RegExp('^  function ' + name + '\\([^]*?^  \x7d', 'm'))
    if (!method) fail('audio panel provides ' + name)
    panel[name] = vm.runInNewContext('(' + method[0] + ')', context)
  }
  panel.cycleStreamRoute({ id: 120 })
  assertEqual(writer.command[5], '101', 'first route write uses the sink serial')
  panel.cycleStreamRoute({ id: 120 })
  assertEqual(writer.command[5], '101', 'rapid clicks wait for the running writer')
  assertEqual(panel.pendingRoutes['120'], '202', 'rapid clicks advance from the optimistic target')
  assertEqual(reads, 0, 'metadata is not read before route writes complete')
  panel.acceptRouteSnapshot('', 0)
  assertEqual(panel.routeTargets['120'], '202', 'a stale metadata read cannot overwrite a newer click')
  writer.running = false
  panel.runNextRoute()
  assertEqual(writer.command[5], '202', 'the queued route starts after the first writer finishes')
  writer.running = false
  panel.runNextRoute()
  assertEqual(reads, 1, 'metadata refresh follows the final write')
  panel.acceptRouteSnapshot("update: id:120 key:'target.object' value:'101'", 2)
  assertEqual(panel.routeTargets['120'], '101', 'external metadata changes update the current target')
}
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
JS

require_command jq
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
cat >"$scratch/bin/timeout" <<'STUB'
#!/bin/bash
shift
"$@"
STUB
cat >"$scratch/bin/wpctl" <<'STUB'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$AUDIO_SWITCH_LOG"
STUB
cat >"$scratch/bin/pactl" <<'STUB'
#!/bin/bash
if [[ $* == "-f json list sink-inputs" ]]; then
  cat "$AUDIO_INPUTS"
elif [[ $* == "list sink-inputs" ]]; then
  cat "${AUDIO_INPUTS%.json}.txt"
else
  printf 'pactl %s\n' "$*" >>"$AUDIO_SWITCH_LOG"
fi
STUB
cat >"$scratch/bin/pw-metadata" <<'STUB'
#!/bin/bash
[[ ${AUDIO_METADATA_FAIL:-0} == "0" ]] || exit 1
cat "$AUDIO_METADATA"
STUB
chmod +x "$scratch/bin/"*
cat >"$scratch/inputs.json" <<'JSON'
[
  {"index":11,"properties":{"application.name":"Call","object.id":"120"}},
  {"index":12,"properties":{"application.name":"Music","object.id":"121"}},
  {"index":13,"properties":{"application.name":"Browser","object.id":"122"}},
  {"index":14,"properties":{"application.name":"EasyEffects","object.id":"123"}},
  {"index":15,"properties":{"object.id":"124"}},
  {"index":16,"properties":{"application.name":"Unknown node"}}
]
JSON
cat >"$scratch/inputs.txt" <<'INPUTS'
Sink Input #11
  application.name = "Call"
  object.id = "120"
Sink Input #12
  application.name = "Music"
  object.id = "121"
Sink Input #13
  application.name = "Browser"
  object.id = "122"
Sink Input #14
  application.name = "EasyEffects"
  object.id = "123"
Sink Input #15
  object.id = "124"
Sink Input #16
  application.name = "Unknown node"
INPUTS
cat >"$scratch/metadata" <<'META'
update: id:120 key:'target.object' value:'101' type:'(null)'
update: id:121 key:'target.object' value:'-1' type:'(null)'
update: id:122 key:'volume' value:'0.5' type:'(null)'
META
export AUDIO_SWITCH_LOG="$scratch/switch.log" AUDIO_INPUTS="$scratch/inputs.json" AUDIO_METADATA="$scratch/metadata"
PATH="$scratch/bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-set-default" 42 sink.new
expected=$(printf 'wpctl set-default 42\npactl set-default-sink sink.new\npactl move-sink-input 12 sink.new\npactl move-sink-input 13 sink.new')
[[ $(<"$AUDIO_SWITCH_LOG") == "$expected" ]] || fail "changing the default preserves pins and DSP streams while moving followers" "$(<"$AUDIO_SWITCH_LOG")"
pass "changing the default preserves pins and DSP streams while moving followers"

printf "update: id:120 key:'target.object' value:'-1' type:'(null)'\n" >"$AUDIO_METADATA"
: >"$AUDIO_SWITCH_LOG"
PATH="$scratch/bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-set-default" 42 sink.new
grep -Fx 'pactl move-sink-input 11 sink.new' "$AUDIO_SWITCH_LOG" >/dev/null || fail "clearing a pin makes its stream follow the next default"
pass "clearing a pin makes its stream follow the next default"

: >"$AUDIO_SWITCH_LOG"
AUDIO_METADATA_FAIL=1 PATH="$scratch/bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-set-default" 42 sink.new
! grep -q 'move-sink-input' "$AUDIO_SWITCH_LOG" || fail "unreadable pin metadata does not force streams onto the default"
pass "unreadable pin metadata does not force streams onto the default"
