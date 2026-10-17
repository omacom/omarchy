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
const outputProfiles = audio.parseOutputProfiles(JSON.stringify([
  { cardName: 'alsa_card.gpu', profileName: 'output:hdmi-stereo-extra1', label: 'Right Monitor', description: 'Digital Stereo (HDMI 2) Output' }
]))
assertEqual(outputProfiles[0].label, 'Right Monitor', 'audio parses inactive output profile labels')
assertEqual(outputProfiles[0].description, 'Digital Stereo (HDMI 2)', 'audio cleans inactive output profile descriptions')
assertDeepEqual(audio.parseOutputProfiles('{bad json'), [], 'audio rejects malformed output profile data')
assertEqual(
  audio.outputProfileSinkName('alsa_card.pci-0000_29_00.1', 'output:hdmi-stereo-extra1'),
  'alsa_output.pci-0000_29_00.1.hdmi-stereo-extra1',
  'audio derives the sink name created by an ALSA output profile'
)

const activeSink = {
  name: 'alsa_output.gpu.hdmi-stereo',
  ready: false
}
const outputRows = audio.outputRows([activeSink], [
  { cardName: 'alsa_card.gpu', profileName: 'output:hdmi-stereo', label: 'Left Monitor', description: 'Digital Stereo' },
  { cardName: 'alsa_card.gpu', profileName: 'output:hdmi-stereo-extra1', label: 'Right Monitor', description: 'Digital Stereo' }
])
assertEqual(outputRows.length, 2, 'audio combines active sinks with inactive card profiles')
assertEqual(outputRows[0].kind, 'sink', 'audio keeps active sinks as selectable output rows')
assertEqual(outputRows[0].label, 'Left Monitor', 'audio labels active sinks from their card ports')
assertEqual(outputRows[1].kind, 'profile', 'audio exposes inactive profiles as selectable output rows')
assertEqual(outputRows[1].label, 'Right Monitor', 'audio keeps monitor names on profile rows')

const reorderedRows = audio.outputRows([{ ...activeSink, name: 'alsa_output.gpu.hdmi-stereo-extra1' }], [
  { cardName: 'alsa_card.gpu', profileName: 'output:hdmi-stereo', label: 'Left Monitor', description: 'Digital Stereo' },
  { cardName: 'alsa_card.gpu', profileName: 'output:hdmi-stereo-extra1', label: 'Right Monitor', description: 'Digital Stereo' }
])
assertEqual(reorderedRows[0].label, 'Left Monitor', 'audio keeps output rows sorted when the active profile changes')
assertEqual(reorderedRows[1].label, 'Right Monitor', 'audio does not move the selected output to the front')
// A duplex profile keeps the microphone on, but its sink is named after the
// output mapping alone and reports only that as its device.profile.name.
assertEqual(
  audio.outputProfileSinkName('alsa_card.pci-0000_00_1f.3', 'output:hdmi-stereo+input:analog-stereo'),
  'alsa_output.pci-0000_00_1f.3.hdmi-stereo',
  'audio derives the sink name created by a duplex output profile'
)
const duplexSink = {
  name: 'alsa_output.pci-0000_00_1f.3.hdmi-stereo',
  ready: true,
  properties: { 'device.name': 'alsa_card.pci-0000_00_1f.3', 'device.profile.name': 'hdmi-stereo' }
}
assertEqual(
  audio.sinkProfileKey(duplexSink),
  audio.outputProfileKey('alsa_card.pci-0000_00_1f.3', 'output:hdmi-stereo+input:analog-stereo'),
  'audio matches a sink to its duplex output profile'
)
const duplexProfiles = [
  { cardName: 'alsa_card.pci-0000_00_1f.3', profileName: 'output:analog-stereo+input:analog-stereo', label: 'Speakers', description: 'Analog Stereo Duplex' },
  { cardName: 'alsa_card.pci-0000_00_1f.3', profileName: 'output:hdmi-stereo+input:analog-stereo', label: 'DELL U2720Q', description: 'Digital Stereo (HDMI) Output + Analog Stereo Input' }
]
const duplexRows = audio.outputRows([duplexSink], duplexProfiles)
assertEqual(duplexRows.length, 2, 'audio shows an active duplex output once')
assertEqual(duplexRows[0].kind, 'sink', 'audio keeps the active duplex output as its sink row')
assertEqual(duplexRows[0].label, 'DELL U2720Q', 'audio labels the active duplex sink from its card port')
assertEqual(duplexRows[1].profileName, 'output:analog-stereo+input:analog-stereo', 'audio activates the full duplex profile to keep the microphone')
const unboundDuplexRows = audio.outputRows([{ ...duplexSink, ready: false }], duplexProfiles)
assertEqual(unboundDuplexRows.length, 2, 'audio matches an unbound duplex sink by name')
// Rows sharing a label still keep a fixed order, whichever one is active and
// however the graph happens to list the sinks.
const twinProfiles = [
  { cardName: 'alsa_card.a', profileName: 'output:hdmi-stereo', label: 'HDMI / DisplayPort', description: 'Digital Stereo' },
  { cardName: 'alsa_card.b', profileName: 'output:hdmi-stereo', label: 'HDMI / DisplayPort', description: 'Digital Stereo' }
]
const twinSinkA = { name: 'alsa_output.a.hdmi-stereo', ready: true, properties: { 'device.name': 'alsa_card.a', 'device.profile.name': 'hdmi-stereo' } }
const twinSinkB = { name: 'alsa_output.b.hdmi-stereo', ready: true, properties: { 'device.name': 'alsa_card.b', 'device.profile.name': 'hdmi-stereo' } }
const twinsAActive = audio.outputRows([twinSinkA], twinProfiles).map((row) => audio.outputProfileSinkName(row.cardName || row.node.properties['device.name'], 'output:hdmi-stereo'))
const twinsBActive = audio.outputRows([twinSinkB], twinProfiles.slice().reverse()).map((row) => audio.outputProfileSinkName(row.cardName || row.node.properties['device.name'], 'output:hdmi-stereo'))
assertDeepEqual(twinsAActive, ['alsa_output.a.hdmi-stereo', 'alsa_output.b.hdmi-stereo'], 'audio orders equal labels by sink when the first output is active')
assertDeepEqual(twinsBActive, twinsAActive, 'audio keeps equal labels in the same order when the other output is active')

// A speaker tuning hides the physical speaker sink and makes its own sink the
// default. The speaker profile is in use, so it must not come back as a second row.
const tuningSink = { name: 'omarchy_speaker_tuning', ready: false }
const speakerSink = {
  name: 'alsa_output.pci-0000_00_1f.3.analog-stereo',
  ready: true,
  properties: { 'device.name': 'alsa_card.pci-0000_00_1f.3', 'device.profile.name': 'analog-stereo' }
}
const tunedProfiles = [
  { cardName: 'alsa_card.pci-0000_00_1f.3', profileName: 'output:analog-stereo+input:analog-stereo', label: 'Speakers', description: 'Analog Stereo Duplex' },
  { cardName: 'alsa_card.pci-0000_00_1f.3', profileName: 'output:hdmi-stereo+input:analog-stereo', label: 'DELL U2720Q', description: 'Digital Stereo (HDMI) Output' }
]
const tunedRows = audio.outputRows([tuningSink], tunedProfiles, [tuningSink, speakerSink])
assertEqual(tunedRows.length, 2, 'audio does not offer the speaker profile beside an active speaker tuning')
assertEqual(tunedRows.filter((row) => row.kind === 'profile').map((row) => row.label).join(','), 'DELL U2720Q', 'audio still offers the other outputs while a speaker tuning is active')
assertEqual(audio.outputRows([tuningSink], tunedProfiles).length, 3, 'audio offers the speaker profile when no hidden sink uses it')
// The panel's Repeater holds primitives only, never the live PipeWire node.
const outputSnapshot = audio.outputRowSnapshot(audio.outputRows([{ ...duplexSink, id: 56 }], duplexProfiles))
assertDeepEqual(
  outputSnapshot,
  [
    { id: 56, name: 'alsa_output.pci-0000_00_1f.3.hdmi-stereo', kind: 'sink', label: 'DELL U2720Q', description: 'Digital Stereo (HDMI) Output + Analog Stereo Input' },
    { kind: 'profile', cardName: 'alsa_card.pci-0000_00_1f.3', profileName: 'output:analog-stereo+input:analog-stereo', label: 'Speakers', description: 'Analog Stereo Duplex' }
  ],
  'audio snapshots output rows to primitives'
)
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

// Source wiring (no Quickshell here): the hints come from the fixed platform
// root, and the audio code names no platform or hardware of its own.
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const audioNodes = read('shell/Commons/AudioNodes.qml')
assert(/path: "\/usr\/share\/omarchy-platform\/audio\.json"/.test(audioNodes) && !/Quickshell\.env|OMARCHY_/.test(audioNodes),
  'audio reads the platform hints from the fixed platform root')
assert(/onLoadFailed: \{\s*missing = true\s*root\.hints = Model\.parsePlatformAudio\(""\)/.test(audioNodes), 'a removed hints file hides nothing')
assert(/property var hints: Model\.parsePlatformAudio\(hintsFile\.text\(\)\)/.test(audioNodes), 'audio reads the platform hints synchronously at startup')
const sources = ['shell/plugins/panels/audio/Panel.qml', 'shell/plugins/panels/audio/Model.js', 'shell/Commons/AudioNodes.qml',
  'shell/Commons/AudioNodesModel.js', 'shell/Commons/UntypedInput.qml', 'shell/plugins/bar/widgets/Microphone.qml',
  'bin/omarchy-audio-input-set-default', 'bin/omarchy-audio-sink-availability']
for (const file of sources)
  assert(!/apple|asahi|macbook|j[0-9]{3}|omarchy-hw-|platform-sound/i.test(read(file)), file + ' names no platform')

const panel = read('shell/plugins/panels/audio/Panel.qml')
assert(/inputPeakNode: inputViaWpctl \? null : source/.test(panel) && /inputLevelShown: !!inputPeakNode/.test(panel) &&
  /visible: root\.inputLevelShown[^}]*inputPeakMonitor\.peak/.test(panel),
  'the input level bar is hidden when the input is driven through wpctl')
assert(!/Timer \{[^}]*repeat: true[^}]*resolveVolumeSink/.test(panel), 'no timer polls the volume sink')
assert(panel.includes('onNodesChanged: volumeSinkResolveTimer.restart()') && /target: Pipewire\.linkGroups\s*function onValuesChanged\(\) \{ volumeSinkResolveTimer\.restart\(\) \}/.test(panel),
  'node and link changes resolve the volume sink again')
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
assert(/path: [^\n]*"\/easyeffects\/db\/easyeffectsrc"\s*watchChanges: true\s*printErrors: false\s*onFileChanged: volumeSinkResolveTimer\.restart\(\)/.test(panel),
  "EasyEffects' configured output is watched, since an idle EasyEffects resolves through it")
JS
