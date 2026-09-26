#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')

assert(audio.isPlaybackStream({ isStream: true, isSink: true }), 'audio detects sink-backed playback streams')
assert(audio.isPlaybackStream({ isStream: true, type: 'Stream/Output/Audio' }), 'audio detects typed playback streams')
assert(!audio.isPlaybackStream({ isStream: false, isSink: true }), 'audio rejects non-stream playback nodes')
assert(audio.isAudioSource({ audio: {} }), 'audio detects nodes with audio as sources')
assert(audio.isAudioSource({ type: 'Audio/Source' }), 'audio detects typed source nodes')

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

assertDeepEqual(
  audio.outputVolumeCommand('alsa_output.speakers', 0.456),
  ['pactl', 'set-sink-volume', 'alsa_output.speakers', '46%'],
  'audio builds a pactl sink-volume argv with a rounded percent'
)
assertDeepEqual(audio.outputVolumeCommand('sink', -0.2)[3], '0%', 'audio clamps negative output volume to zero')
assertDeepEqual(audio.outputVolumeCommand('sink', 1.4)[3], '100%', 'audio clamps output volume to the panel maximum')

const panelSource = fs.readFileSync(root + '/shell/plugins/panels/audio/Panel.qml', 'utf8')
assert(
  /Model\.outputVolumeCommand\(/.test(panelSource),
  'audio panel writes output volume through pactl, not the node-bound setter that drops Bluetooth writes'
)
assert(
  /Process\s*\{[^}]*id:\s*outputVolumeWriter/s.test(panelSource),
  'audio panel coalesces volume writes through a single writer process'
)
assert(
  /pendingOutputVolume\s*!==\s*root\.sentOutputVolume/.test(panelSource) ||
  /pendingOutputVolume\s*!==\s*sentOutputVolume/.test(panelSource),
  'audio volume writer replays the last queued percentage on exit'
)
assert(
  /root\.pendingOutputVolume\s*=\s*-1/.test(panelSource) && /root\.sentOutputVolume\s*=\s*-1/.test(panelSource),
  'audio clears the pending volume once the writer catches up so steps resume from the live volume'
)
assert(
  /pendingOutputVolume\s*>=\s*0\s*\?\s*root\.pendingOutputVolume\s*\/\s*100\s*:\s*root\.outputVolume/.test(panelSource) &&
  /pendingOutputVolume\s*>=\s*0\s*\?\s*pendingOutputVolume\s*\/\s*100\s*:\s*outputVolume/.test(panelSource),
  'audio relative volume steps accumulate on the queued value, not the stale sink reading'
)
assert(
  !/volumeSink\.audio\.volume\s*=/.test(panelSource),
  'audio panel no longer relies on volumeSink.audio.volume'
)
assert(
  !/Quickshell\.execDetached\(\["pactl",\s*"set-sink-volume"/.test(panelSource),
  'audio panel no longer spawns a pactl per volume event'
)
JS
