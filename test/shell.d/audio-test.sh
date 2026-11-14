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
const mediaPlayer = {
  trackTitle: 'Moonshot',
  trackArtist: 'The Murder Capital',
  isPlaying: true,
  canGoPrevious: true,
  canTogglePlaying: true,
  canGoNext: true
}
const shownFresh = (player) => audio.mediaPresentation(audio.emptyMediaCache(), audio.mediaLiveState(player, 'p'), ['p'])
assert(shownFresh(mediaPlayer).visible, 'audio shows media with live metadata')
assert(shownFresh({ trackTitle: 'Title only', isPlaying: false }).visible, 'audio shows title-only paused media')
assert(shownFresh({ trackArtist: 'Artist only', isPlaying: false }).visible, 'audio shows artist-only paused media')
assert(!shownFresh({ isPlaying: false }).visible, 'audio hides blank media without cache')
assert(!shownFresh(null).visible, 'audio hides media without a player')

// The media handoff on a fake clock: the panel's own step function, with its
// two timers fired the way Qt's are (restart reschedules, stop cancels).
function mediaHandoff() {
  const delays = audio.mediaHandoffDelays()
  const sim = { now: 0, cache: audio.emptyMediaCache(), player: null, open: [], due: { commit: null, clear: null } }
  const live = () => audio.mediaLiveState(sim.player, sim.player && sim.player.key)
  const step = (event) => {
    const result = audio.mediaHandoffStep(sim.cache, live(), event)
    for (const [timer, command] of [['commit', result.commitTimer], ['clear', result.clearTimer]]) {
      if (command === 'restart') sim.due[timer] = sim.now + delays[timer]
      else if (command === 'stop') sim.due[timer] = null
    }
    sim.cache = result.cache
  }
  const handoff = {
    play(player) {
      sim.player = player
      if (player && !sim.open.includes(player.key)) sim.open.push(player.key)
      step('sync')
      return handoff
    },
    close() {
      sim.open = sim.open.filter(key => !sim.player || key !== sim.player.key)
      sim.player = null
      step('sync')
      return handoff
    },
    metadata(fields) { Object.assign(sim.player, fields); step('sync'); return handoff },
    playback(fields) { Object.assign(sim.player, fields); step('refresh'); return handoff },
    openElsewhere(key) { sim.open.push(key); return handoff },
    advance(ms) {
      const until = sim.now + ms
      for (;;) {
        const next = ['commit', 'clear']
          .filter(timer => sim.due[timer] !== null && sim.due[timer] <= until)
          .sort((a, b) => sim.due[a] - sim.due[b])[0]
        if (!next) break
        sim.now = sim.due[next]
        sim.due[next] = null
        step(next === 'commit' ? 'commit' : 'clearExpired')
      }
      sim.now = until
      return handoff
    },
    shown: () => audio.mediaPresentation(sim.cache, live(), sim.open)
  }
  return handoff
}
const track = (key, title, artist, extra) => Object.assign(
  { key, trackTitle: title, trackArtist: artist, isPlaying: true, canGoPrevious: true, canTogglePlaying: true, canGoNext: true },
  extra || {}
)
const showing = (handoff) => [handoff.shown().title, handoff.shown().artist].join(' / ')
const { commit: commitDelay, clear: clearDelay } = audio.mediaHandoffDelays()

{
  const h = mediaHandoff().play(track('spotify', 'Moonshot', 'The Murder Capital')).advance(commitDelay)
  h.metadata({ trackTitle: 'Ethel' }).advance(30).metadata({ trackArtist: 'Fontaines D.C.' })
  assertEqual(showing(h), 'Moonshot / The Murder Capital', 'a track change is held until its fields settle')
  h.advance(commitDelay - 1)
  assertEqual(showing(h), 'Moonshot / The Murder Capital', 'the settling window restarts with each field')
  h.advance(1)
  assertEqual(showing(h), 'Ethel / Fontaines D.C.', 'title and artist change together once settled')
}
{
  const h = mediaHandoff().play(track('chromium.instance1', 'Song A', 'Artist A')).advance(commitDelay)
  h.close().advance(400)
  assert(h.shown().visible && showing(h) === 'Song A / Artist A', 'a Chromium skip keeps the last track through the gap')
  assert(!h.shown().canPlayPause && !h.shown().canGoNext, 'controls under the gap are disabled while their player is gone')
  h.play(track('chromium.instance2', '', '')).advance(300)
  assertEqual(showing(h), 'Song A / Artist A', 'a replacement player with blank metadata keeps the last track')
  h.metadata({ trackTitle: 'Song B', trackArtist: 'Artist B' }).advance(commitDelay)
  assertEqual(showing(h), 'Song B / Artist B', 'the replacement track shows once its metadata settles')
  assert(h.shown().live && h.shown().canGoNext && h.shown().targetKey === 'chromium.instance2', 'controls act on the replacement player')
  h.advance(clearDelay)
  assert(h.shown().visible, 'a gap that ended does not clear the section later')
}
{
  const h = mediaHandoff().play(track('spotify', 'Moonshot', 'The Murder Capital')).advance(commitDelay)
  h.openElsewhere('firefox').close().advance(clearDelay - 1)
  assert(h.shown().visible, 'the last track stays until the handoff window ends')
  assert(!h.shown().canPlayPause, 'cached controls do not fall through to another open player')
  h.advance(1)
  assert(!h.shown().visible && showing(h) === ' / ', 'a gap that outlasts the handoff window clears the section')
}
{
  const h = mediaHandoff().play(track('mpv', 'Intro', 'Band')).advance(commitDelay)
  h.metadata({ trackTitle: '', trackArtist: '' }).advance(clearDelay)
  assert(!h.shown().visible, 'a player that stays blank clears the section')
}
{
  const h = mediaHandoff().play(track('spotify', 'Moonshot', 'The Murder Capital')).advance(commitDelay)
  h.playback({ isPlaying: false, canGoNext: false })
  assert(!h.shown().playing && !h.shown().canGoNext, 'playback changes reach the section at once')
  h.close().advance(10)
  assert(!h.shown().playing && showing(h) === 'Moonshot / The Murder Capital', 'the gap keeps the last playback state')
}
{
  const h = mediaHandoff().play(track('spotify', 'Moonshot', 'The Murder Capital')).advance(commitDelay)
  h.openElsewhere('spotify')
  h.metadata({ trackTitle: '', trackArtist: '' }).advance(10)
  assert(h.shown().canPlayPause && h.shown().targetKey === 'spotify', 'cached controls act while their player is still open')
}
{
  const live = audio.mediaLiveState(track('spotify', 'Late', 'Arrival'), 'spotify')
  const result = audio.mediaHandoffStep(audio.emptyMediaCache(), live, 'clearExpired')
  assertEqual([result.cache.title, result.cache.artist].join(' / '), 'Late / Arrival', 'an expired gap with a live track commits it instead of clearing')
}
assert(audio.mediaTargetAvailable(true, '', []), 'live media controls act on the shown player')
assert(audio.mediaTargetAvailable(false, 'spotify', ['firefox', 'spotify']), 'cached media controls act while their player is open')
assert(!audio.mediaTargetAvailable(false, 'spotify', ['firefox']), 'cached media controls stop once their player closes')
assert(!audio.mediaTargetAvailable(false, '', ['firefox']), 'cached media controls without a player act on nothing')
assert(!audio.mediaTargetAvailable(false, 'spotify', undefined), 'cached media controls act on nothing before players load')
assertEqual(audio.firstEnabledMediaControl(mediaPlayer), 1, 'audio enters media controls on play/pause')
assertDeepEqual(audio.mediaActionNames(), ['previous', 'playPause', 'next'], 'audio uses canonical media action order')
const actionNames = audio.mediaActionNames()
actionNames.reverse()
assertDeepEqual(audio.mediaActionNames(), ['previous', 'playPause', 'next'], 'audio returns a copy of canonical media actions')
assertEqual(audio.firstEnabledMediaControl({ canGoPrevious: true }), 0, 'audio falls back to previous control')
assertEqual(audio.firstEnabledMediaControl({ canGoNext: true }), 2, 'audio falls back to next control')
assertEqual(audio.mediaActions({ canGoPrevious: true, canGoNext: true }).map(control => control.enabled).join(','), 'true,false,true', 'audio disables unsupported controls independently')
assertEqual(audio.nextEnabledMediaControl({ canGoPrevious: true, canGoNext: true }, 0, 1), 2, 'audio skips unsupported controls')
assertEqual(audio.nextEnabledMediaControl({ canGoPrevious: true, canGoNext: true }, 2, 1), 2, 'audio clamps at the next control')
assertEqual(audio.nextEnabledMediaControl({ canGoPrevious: true, canGoNext: true }, 0, -1), 0, 'audio clamps at the previous control')
assertEqual(audio.nextEnabledMediaControl({}, 1, 1), 1, 'audio safely keeps focus when no controls are enabled')
JS
