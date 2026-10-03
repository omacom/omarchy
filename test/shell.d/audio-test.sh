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

assertDeepEqual(audio.parseOutputPorts('{"alsa_output":{"activePort":"lineout","ports":[]}}'), { alsa_output: { activePort: 'lineout', ports: [] } }, 'audio parses output ports')
assertDeepEqual(audio.parseOutputPorts('not json'), {}, 'audio ignores malformed output ports')

const analog = { id: 50, name: 'alsa_output.analog-stereo', ready: true, properties: { 'node.nick': 'Built-in Audio Analog Stereo' } }
const hdmi = { id: 51, name: 'alsa_output.hdmi-stereo', ready: true, properties: { 'node.nick': 'HDMI / DisplayPort' } }
const lineOut = { name: 'analog-output-lineout', description: 'Line Out', type: 'Line', available: true }
const headphonesPort = { name: 'analog-output-headphones', description: 'Headphones', type: 'Headphones', available: true }
const ports = {
  'alsa_output.analog-stereo': { activePort: 'analog-output-headphones', ports: [lineOut, headphonesPort] },
  'alsa_output.hdmi-stereo': { activePort: 'hdmi-output-0', ports: [{ name: 'hdmi-output-0', description: 'HDMI / DisplayPort', type: 'HDMI', available: true }] }
}

const entries = audio.outputEntries([analog, hdmi], ports)
assertDeepEqual(entries.map(e => [e.node.id, e.port && e.port.name]), [[50, 'analog-output-lineout'], [50, 'analog-output-headphones'], [51, null]], 'audio lists each port of a multi-jack sink as an output')
assertDeepEqual(audio.outputEntries([analog], {}).map(e => e.port), [null], 'audio keeps sinks without port data whole')

const unplugged = { 'alsa_output.analog-stereo': { activePort: 'analog-output-lineout', ports: [lineOut, { ...headphonesPort, available: false }] } }
assertDeepEqual(audio.outputEntries([analog], unplugged).map(e => e.port.name), ['analog-output-lineout'], 'audio drops unplugged ports')
const nothingPlugged = { 'alsa_output.analog-stereo': { activePort: 'analog-output-lineout', ports: [{ ...lineOut, available: false }, { ...headphonesPort, available: false }] } }
assertDeepEqual(audio.outputEntries([analog], nothingPlugged).map(e => e.port), [null], 'audio keeps a sink whole when none of its ports are plugged in')

assertEqual(audio.outputEntryLabel(entries[1]), 'Headphones', 'audio labels port entries by port')
assertEqual(audio.outputEntryLabel(entries[2]), 'HDMI / DisplayPort', 'audio labels whole sinks by node')
assertEqual(audio.outputEntryGlyph(entries[1]), '󰋋', 'audio uses headphone glyph for headphone ports')
assertEqual(audio.outputEntryGlyph(entries[0]), '󰓃', 'audio uses speaker glyph for line out ports')
assert(audio.isHeadphonesPort({ type: 'Unknown', description: 'Front Headphones' }), 'audio detects headphone ports by description')

assert(audio.outputEntryIsActive(entries[1], analog, ports), 'audio marks the active port of the default sink')
assert(!audio.outputEntryIsActive(entries[0], analog, ports), 'audio does not mark inactive ports')
assert(!audio.outputEntryIsActive(entries[2], analog, ports), 'audio does not mark other sinks')
assert(audio.outputEntryIsActive(entries[2], hdmi, ports), 'audio marks a whole default sink')

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
JS
