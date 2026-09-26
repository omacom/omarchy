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
const sink = (name, description) => ({ name: name, description: description, nickname: description })
const hdmi = sink('alsa_output.pci-0000_01_00.1.hdmi-stereo', 'Monitor')
const headset = sink('bluez_output.00_11_22_33_44_55.1', 'Headset')
const tuning = sink('omarchy_speaker_tuning', 'Speakers')
const pool = sink('raop_sink.Pool.local.192.168.1.67.7000', 'Pool')
const kitchenAmp = sink('raop_sink.Kitchen.local.192.168.1.56.7000', 'Kitchen')
const kitchenPod = sink('raop_sink.Kitchen-2.local.192.168.1.87.7000', 'Kitchen')
const denLeft = sink('raop_sink.Den.local.192.168.1.20.7000', 'Den')
const denRight = sink('raop_sink.Den-2.local.192.168.1.21.7000', 'Den')

assertDeepEqual(
  audio.groupedSinks([pool, tuning, hdmi, kitchenAmp, headset]).map(n => n.name),
  [hdmi.name, headset.name, kitchenAmp.name, pool.name, tuning.name],
  'audio groups outputs as direct, then AirPlay by name, then other'
)
assertEqual(audio.sinkGroupCount([hdmi, headset]), 1, 'audio counts a single output group')
assert(!audio.hasAirPlaySinks([hdmi, tuning]), 'audio sees no AirPlay sinks without RAOP')
assert(audio.hasAirPlaySinks([hdmi, pool]), 'audio detects AirPlay sinks')
assertEqual(audio.sinkGroupTitle(1), 'AIRPLAY', 'audio titles the AirPlay group')

const models = audio.parseAirPlayModels('Kitchen.local\tWiiM Amp\nKitchen-2.local\tAudioAccessory5,1\nDen.local\tAppleTV14,1\nDen-2.local\tAppleTV14,1\n')
assertEqual(models['Kitchen-2.local'], 'AudioAccessory5,1', 'audio parses AirPlay models')
assertEqual(audio.airPlayHostname(kitchenPod), 'Kitchen-2.local', 'audio reads the AirPlay hostname from the node name')
assertEqual(audio.friendlyAirPlayModel('AppleTV5,3'), 'Apple TV HD', 'audio names Apple TV HD')
assertEqual(audio.friendlyAirPlayModel('WiiM Pro'), 'WiiM Pro', 'audio keeps readable third-party models')

const outputs = [pool, kitchenAmp, kitchenPod, denLeft, denRight]
assertEqual(audio.sinkRowLabel(pool, outputs, models), 'Pool', 'audio leaves unique AirPlay names alone')
assertEqual(audio.sinkRowLabel(kitchenAmp, outputs, models), 'Kitchen · WiiM Amp', 'audio labels a shared name with the device type')
assertEqual(audio.sinkRowLabel(kitchenPod, outputs, models), 'Kitchen · HomePod mini', 'audio labels the other device with its type')
assertEqual(audio.sinkRowLabel(denRight, outputs, models), 'Den · Apple TV 4K (Den-2)', 'audio adds the hostname when types match too')
assertEqual(audio.sinkRowLabel(kitchenPod, outputs, {}), 'Kitchen · Kitchen-2', 'audio falls back to the hostname before models load')
JS
