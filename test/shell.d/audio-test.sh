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


let volumeWrites = audio.newVolumeWriteState()

// Rapid movement before the first external write starts coalesces to one value.
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 20)
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 45)
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 80)
volumeWrites = audio.beginVolumeWrite(volumeWrites)
assertEqual(volumeWrites.activePercent, 80, 'audio volume queue starts only the newest pre-launch value')
assertEqual(volumeWrites.pendingPercent, -1, 'audio volume queue consumes the pending value when it starts')

// Movement during an active write retains only the newest pending value.
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 35)
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 60)
volumeWrites = audio.queueVolumeWrite(volumeWrites, 'bluez_output.speaker', 95)
assertEqual(volumeWrites.activePercent, 80, 'active audio volume write is not replaced mid-process')
assertEqual(volumeWrites.pendingPercent, 95, 'audio volume queue keeps only the newest in-flight update')

volumeWrites = audio.finishVolumeWrite(volumeWrites)
volumeWrites = audio.beginVolumeWrite(volumeWrites)
assertEqual(volumeWrites.activePercent, 95, 'next audio volume write is the final slider value')
assertEqual(volumeWrites.pendingPercent, -1, 'final slider value leaves no older pending write')

volumeWrites = audio.finishVolumeWrite(volumeWrites)
assert(!volumeWrites.running, 'audio volume queue becomes idle after the final write')
assertEqual(volumeWrites.pendingPercent, -1, 'no stale volume write remains after the final value')

const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/audio/Panel.qml', 'utf8')
assert(
  /Process \{[\s\S]*id: outputVolumeWriteProc[\s\S]*command: \["pactl", "set-sink-volume"/.test(panelSource),
  'audio panel uses one reusable pactl process for output volume writes'
)
assert(
  /onExited:[\s\S]*finishVolumeWrite[\s\S]*flushOutputVolumeWrite/.test(panelSource),
  'audio panel starts the latest pending write only after the active process exits'
)
assert(
  !/Quickshell\.execDetached\(\["pactl", "set-sink-volume"/.test(panelSource),
  'audio panel no longer spawns detached pactl writers per slider event'
)
JS
