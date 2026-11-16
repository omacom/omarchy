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
const deadNode = new Proxy({}, {
  get() { throw new Error('destroyed PwNode QObject') }
})
const liveSink = { id: 11, name: 'alsa_output.speakers' }
const staleSink = { id: 10, name: 'alsa_output.old' }
assertEqual(audio.nodeRow(deadNode), null, 'audio drops a destroyed node that throws on property access')
assertDeepEqual(
  audio.rowSnapshot([staleSink, liveSink, deadNode], [liveSink]),
  [{ id: 11, name: 'alsa_output.speakers' }],
  'audio row snapshots keep only nodes still present in Pipewire.nodes'
)

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
assertEqual(audio.friendlyStreamLabel('PipeWire ALSA [cliamp]'), 'cliamp', 'audio strips the ALSA bridge prefix')
assertEqual(audio.friendlyStreamLabel('ALSA plug-in [mpv]'), 'mpv', 'audio strips the ALSA plug-in prefix')
assert(audio.streamRepresentsMprisPlayer('Chromium', 'Chromium Browser'), 'audio matches related stream and MPRIS labels')

// The mixer groups by application, so two browser tabs are one row and one
// mute action, while a stream without any identifying property stays alone.
const appStreams = [
  { id: 1, name: 'spotify', ready: true, properties: { 'application.name': 'Spotify', 'application.process.binary': 'spotify', 'application.icon_name': 'spotify' } },
  { id: 2, name: 'chromium', ready: true, properties: { 'application.name': 'Chromium', 'application.process.binary': 'chromium', 'application.icon_name': 'chromium-browser' } },
  { id: 3, name: 'chromium-tab', ready: true, properties: { 'application.name': 'Chromium' } },
  { id: 9, ready: true, properties: {} }
]
const appGroups = audio.groupStreamsByApp(appStreams)
assertEqual(appGroups.length, 3, 'audio groups streams by application')
assertEqual(appGroups[1].streams.length, 2, 'audio keeps every stream of one application together')
assertEqual(appGroups[2].key, 'node:9', 'audio keeps a stream without an application separate')
assertEqual(audio.streamAppKey({ ready: true, properties: {} }), '', 'audio has no app key for a stream without properties')
assertEqual(audio.streamAppKey({ ready: true, properties: { 'application.name': 'PipeWire ALSA [cliamp]' } }), 'cliamp', 'audio keys an ALSA client by its real name')

const iconCandidates = audio.streamAppIconCandidates({
  ready: true,
  name: 'Firefox',
  properties: {
    'application.name': 'Firefox',
    'application.process.binary': 'firefox',
    'application.desktop': 'firefox.desktop',
    'application.icon_name': 'firefox',
    'media.name': 'Some Song'
  }
})
assertEqual(iconCandidates[0], 'firefox', 'audio prefers the icon a client names')
assert(iconCandidates.includes('Firefox'), 'audio offers the display name as an icon fallback')
assert(!iconCandidates.includes('Some Song'), 'audio does not mistake a track title for an icon')
assertEqual(audio.streamAppIconCandidates({ ready: true, properties: { 'application.desktop': 'org.mozilla.firefox.desktop' } })[0], 'org.mozilla.firefox', 'audio strips the desktop-entry suffix')
assertEqual(
  audio.streamAppIconCandidates({ ready: true, properties: { 'application.icon_name': 'applications-games', 'application.process.binary': 'ffplay' } })[0],
  'ffplay',
  'audio skips category icons for the application itself'
)
assert(
  audio.streamAppIconCandidates({
    ready: true,
    name: 'alsa_playback.cliamp',
    properties: { 'application.name': 'PipeWire ALSA [cliamp]', 'node.name': 'alsa_playback.cliamp' }
  }).includes('cliamp'),
  'audio finds an ALSA client icon from its bridge names'
)
assertEqual(
  audio.streamMediaLabel({ ready: true, properties: { 'media.name': 'tone.wav - mpv' } }, 'mpv'),
  'tone.wav',
  'audio strips a player suffix from the media title'
)
assertEqual(
  audio.streamMediaLabel({ ready: true, properties: { 'media.name': 'tone.wav - mpv', 'application.name': 'mpv' } }, 'mpv Media Player'),
  'tone.wav',
  "audio strips the client's suffix even when the desktop name is longer"
)
assertEqual(
  audio.streamMediaLabel({ ready: true, properties: { 'media.name': 'audio-src' } }, 'Spotify'),
  '',
  'audio hides a generic media title'
)
assertEqual(
  audio.streamMediaLabel({ ready: true, properties: { 'media.name': 'audio stream #1' } }, 'Cyberpunk 2077'),
  '',
  'audio hides a numbered generic media title'
)
assertEqual(
  audio.streamMediaLabel({ ready: true, properties: { 'media.name': 'Spotify' } }, 'Spotify'),
  '',
  'audio does not repeat the app name as a media title'
)

// Workspaces come from Hyprland windows, matched to a stream by pid first and
// by the application names ALSA clients publish when they have no pid.
const hyprWindows = audio.workspaceWindows([
  {
    lastIpcObject: { pid: 4201, class: 'Spotify', title: 'Spotify Premium' },
    wayland: { appId: 'spotify' },
    workspace: { id: 2, name: '2' }
  },
  {
    lastIpcObject: { pid: 4202, class: 'foot', title: 'cliamp — music' },
    wayland: { appId: 'foot' },
    workspace: { id: 3, name: '3' }
  },
  {
    lastIpcObject: { pid: 4203, class: 'chromium', title: 'Gallery - Chromium' },
    wayland: { appId: 'chromium' },
    workspace: { id: 5, name: '5' }
  },
  {
    lastIpcObject: { pid: 4203, class: 'chromium', title: 'Docs - Chromium' },
    wayland: { appId: 'chromium' },
    workspace: { id: 1, name: '1' }
  },
  {
    lastIpcObject: { pid: 4204, class: 'spotify', title: 'Spotify' },
    wayland: { appId: 'spotify' },
    workspace: { id: -99, name: 'special:music' }
  }
])
assertEqual(hyprWindows.length, 5, 'audio projects every Hyprland window')
assertDeepEqual(audio.workspaceWindows(undefined), [], 'audio projects a missing window list to no windows')
// QML hands over a V4Sequence, which is array-like but fails Array.isArray.
assertEqual(
  audio.workspaceWindows({
    0: { lastIpcObject: { pid: 7, class: 'mpv', title: 'tone' }, wayland: { appId: 'mpv' }, workspace: { id: 7, name: '7' } },
    length: 1
  }).length,
  1,
  'audio accepts a QML sequence of windows'
)
assertDeepEqual(
  audio.nodeWorkspaces({ ready: true, properties: { 'application.process.id': '4201' } }, hyprWindows),
  [{ id: 2, name: '2' }],
  'audio maps a stream to its window workspace by pid'
)
assertDeepEqual(
  audio.nodeWorkspaces({
    ready: true,
    name: 'alsa_playback.cliamp',
    properties: { 'application.name': 'PipeWire ALSA [cliamp]', 'node.name': 'alsa_playback.cliamp' }
  }, hyprWindows),
  [{ id: 3, name: '3' }],
  'audio maps a pid-less ALSA client through its window title'
)
assertDeepEqual(
  audio.nodeWorkspaces({
    ready: true,
    properties: { 'application.process.id': '9999', 'application.name': 'Chromium', 'application.process.binary': 'chromium' }
  }, hyprWindows),
  [{ id: 1, name: '1' }, { id: 5, name: '5' }],
  'audio falls back to the app id for a renderer process and merges its windows'
)
assertDeepEqual(
  audio.nodeWorkspaces({ ready: true, properties: { 'application.name': 'mpv' } }, hyprWindows),
  [],
  'audio does not claim a window that merely mentions the application'
)
assertDeepEqual(
  audio.groupWorkspaces([
    { ready: true, properties: { 'application.process.id': '4201' } },
    { ready: true, properties: { 'application.process.id': '4204' } }
  ], hyprWindows),
  [{ id: 2, name: '2' }, { id: -99, name: 'special:music' }],
  'audio merges the workspaces of every stream in an app, specials last'
)
assertEqual(audio.workspaceShortLabel([{ id: -99, name: 'special:music' }]), 'music', 'audio names a special workspace')
assertEqual(
  audio.workspaceShortLabel([{ id: 1, name: '1' }, { id: 3, name: '3' }]),
  '1 · 3',
  'audio joins the workspaces of a multi-window app'
)
assertEqual(
  audio.workspaceTooltip([{ id: 3, name: '3' }]),
  'Workspace 3',
  'audio spells out a single workspace'
)
assertEqual(
  audio.workspaceTooltip([{ id: 1, name: '1' }, { id: 3, name: '3' }]),
  'Workspaces 1, 3',
  'audio spells out several workspaces'
)
assertEqual(
  audio.workspaceTooltip([{ id: 3, name: '3' }], undefined, function(n) { return String(n).padStart(2, '0') }),
  'Workspace 03',
  'audio formats workspace numbers for the language'
)

assertEqual(audio.groupVolume([{ audio: { volume: 0.8 } }, { audio: { volume: 0.2 } }]), 0.8, 'an app follows its loudest stream')
assertEqual(audio.groupVolume([{ audio: { volume: 1.5 } }]), 1, 'an app reads as full when a stream is boosted past 100%')
assertEqual(audio.groupMuted([{ audio: { muted: true } }, { audio: { muted: false } }]), false, 'an app is audible while any stream plays')
assertEqual(audio.groupMuted([{ audio: { muted: true } }, { audio: { muted: true } }]), true, 'an app is muted only when every stream is')
assertEqual(audio.groupMuted([]), false, 'an app without audio is not muted')
assertDeepEqual(
  audio.appGroupSnapshot([{ key: 'chromium', label: 'Chromium', streams: [appStreams[1]] }]),
  [{ key: 'chromium', label: 'Chromium', rows: [{ id: 2, name: 'chromium' }] }],
  'audio snapshots app groups to primitives'
)

// Routing pins every stream of an app to one output and keeps "follow default"
// first, so cycling always has a way back without remembering the old target.
assertDeepEqual(
  audio.routeCommand(64, '101'),
  ['pw-metadata', '-n', 'default', '--', '64', 'target.object', '101'],
  'audio pins a stream to an output'
)
assertDeepEqual(
  audio.routeCommand(64, audio.DEFAULT_ROUTE),
  ['pw-metadata', '-n', 'default', '--', '64', 'target.object', '-1'],
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
assertDeepEqual(audio.routeOptions([...routeSinks, { ready: true, name: 'mirror', properties: { 'object.serial': 101 } }]), [audio.DEFAULT_ROUTE, '101', '202'], 'audio offers each output once')
assertEqual(audio.nextRouteTarget(audio.routeOptions(routeSinks), audio.DEFAULT_ROUTE), '101', 'audio cycles from the default to the first output')
assertEqual(audio.nextRouteTarget(audio.routeOptions(routeSinks), '202'), audio.DEFAULT_ROUTE, 'audio cycles from the last output back to the default')
assertEqual(audio.routeLabel({ id: 999 }, routeSinks, null, routeTargets), 'Follow default output', 'audio labels an unpinned stream')
assertEqual(audio.routeLabel({ id: 120 }, routeSinks, null, routeTargets), 'Speakers', 'audio labels a pinned stream by device')
assertEqual(audio.routeLabel({ id: 999 }, routeSinks, routeSinks[1], routeTargets), 'HDMI', 'audio prefers the linked output over the pin')
assertEqual(audio.routeLabel({ id: 120 }, routeSinks, null, { '120': '101' }), 'Speakers', 'audio resolves serial targets to device labels')
assertEqual(audio.routePinnedLabel({ id: 999 }, routeSinks, routeTargets), 'Default', 'audio labels an unpinned stream as the default')
assertEqual(audio.routePinnedLabel({ id: 120 }, routeSinks, routeTargets), 'Speakers', 'audio labels a pinned stream by its device')

const routeNode = { id: 64, ready: true, name: 'chromium', properties: { 'object.serial': 500 } }
const queuedRoute = audio.queuedRoute(routeNode, '101')
assert(audio.queuedRouteIsCurrent([routeNode], 64, queuedRoute), 'a queued route waits for its own stream')
assert(!audio.queuedRouteIsCurrent([{ id: 64, ready: true, name: 'reused', properties: { 'object.serial': 501 } }], 64, queuedRoute), 'a queued route is dropped when another stream reuses its id')

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

{
  // A grouped app writes one pin per stream. The queue keeps the last click and
  // never lets a stale metadata read put an old target back on screen.
  const vm = require('vm')
  const call = (id, serial) => ({ id, ready: true, name: 'stream' + id, properties: { 'object.serial': serial } })
  const nodes = [call(1, 11), call(2, 12)]
  const writer = { running: false, command: null }
  const refreshes = []
  const state = {
    Model: audio,
    audioSinks: [
      { ready: true, name: 'sink.a', nickname: 'Speakers', properties: { 'object.serial': 500 } },
      { ready: true, name: 'sink.b', nickname: 'HDMI', properties: { 'object.serial': 600 } }
    ],
    nodes: nodes,
    routeTargets: {},
    pendingRoutes: {},
    routeGeneration: 0,
    nodesForApp: () => nodes,
    routeWriteProc: writer,
    routeTargetsProc: { restart() { refreshes.push(true) } }
  }
  for (const name of ['cycleAppRoute', 'runNextRoute', 'acceptRouteSnapshot']) {
    const method = panel.match(new RegExp('^  function ' + name + '\\([^]*?^  \\}', 'm'))
    if (!method) fail('audio panel provides ' + name)
    state[name] = vm.runInNewContext('(' + method[0] + ')', state)
  }

  state.cycleAppRoute({})
  assertEqual(writer.command.at(-1), '500', 'the first stream of an app is pinned to the next output')
  assertEqual(state.pendingRoutes['2'].target, '500', 'the second stream of the app is queued for the same output')
  assertEqual(state.routeTargets['2'], '500', 'the row follows the optimistic target while the writes run')

  writer.running = false
  state.runNextRoute()
  assertEqual(writer.command[4], '2', 'the second stream of the app is written after the first')
  assertEqual(writer.command.at(-1), '500', 'every stream of the app gets the same target')

  writer.running = false
  state.runNextRoute()
  assertEqual(refreshes.length, 1, 'the metadata is read once the queue drains')

  state.cycleAppRoute({})
  assertEqual(writer.command.at(-1), '600', 'a second click advances from the pinned target')
  writer.running = false
  state.runNextRoute()
  assertEqual(writer.command[4], '2', 'the second stream follows the new target')
  assertEqual(writer.command.at(-1), '600', 'both streams of the app move together')
  writer.running = false
  state.runNextRoute()
  assertEqual(refreshes.length, 2, 'the metadata is read again after the second cycle')

  const before = JSON.stringify(state.routeTargets)
  state.acceptRouteSnapshot("update: id:1 key:'target.object' value:'500'", 1)
  assertEqual(JSON.stringify(state.routeTargets), before, 'a stale metadata read cannot overwrite a newer click')
}
JS
