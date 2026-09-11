#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/audio/Panel.qml', 'utf8')

function qmlObject(source, type, id) {
  const startPattern = new RegExp(type + ' \\{\\s*id: ' + id + '\\b')
  const match = startPattern.exec(source)
  if (!match) fail(`audio panel contains ${id}`)

  const start = match.index
  const open = source.indexOf('{', start)
  let depth = 0
  for (let i = open; i < source.length; i++) {
    if (source[i] === '{') depth++
    if (source[i] === '}' && --depth === 0) return source.slice(start, i + 1)
  }
  fail(`audio panel closes ${id}`)
}

assert(audio.isPlaybackStream({ isStream: true, isSink: true }), 'audio detects sink-backed playback streams')
assert(audio.isPlaybackStream({ isStream: true, type: 'Stream/Output/Audio' }), 'audio detects typed playback streams')
assert(!audio.isPlaybackStream({ isStream: false, isSink: true }), 'audio rejects non-stream playback nodes')
assert(audio.isAudioSource({ audio: {} }), 'audio detects nodes with audio as sources')
assert(audio.isAudioSource({ type: 'Audio/Source' }), 'audio detects typed source nodes')

assertEqual(audio.outputVolumeName(0, false), 'Silenced', 'audio labels silent output')
assertEqual(audio.outputVolumeName(0.9, false), 'Party mode', 'audio labels loud output')
assertEqual(audio.outputVolumeName(0.5, true), 'Muted', 'audio labels muted output')

assert(/if \(focusSection === "header"\) \{ toggleOutputMute\(\); return \}/.test(panelSource), 'audio hero keyboard activation toggles output')
assert(/onPressed: function\(b\) \{\s*if \(b === Qt\.RightButton\) root\.toggleOutputMute\(\)/.test(panelSource), 'audio bar right-click toggles output')
const heroSwitch = qmlObject(panelSource, 'ToggleSwitch', 'powerSwitch')
const heroCheckedExpression = heroSwitch.match(/checked: (.+)/)[1]
const heroChecked = new Function('root', `return ${heroCheckedExpression}`)
assert(!heroChecked({ hasOutput: true, outputMuted: true, inputMuted: false }), 'audio hero stays off when output is muted and input is audible')
assert(heroChecked({ hasOutput: true, outputMuted: false, inputMuted: true }), 'audio hero turns on when output is audible')
assert(!heroChecked({ hasOutput: false, outputMuted: false, inputMuted: false }), 'audio hero stays off without an output')
assert(/onToggled: root\.toggleOutputMute\(\)/.test(heroSwitch), 'audio hero switch controls output')
assert(/text: root\.outputMuted \? "Unmute output" : "Mute output"/.test(heroSwitch), 'audio hero tooltip describes output mute')
const inputSwitch = qmlObject(panelSource, 'ToggleSwitch', 'inputMuteSwitch')
assert(/text: root\.inputMuted \? "Unmute microphone" : "Mute microphone"/.test(inputSwitch), 'audio microphone tooltip stays shortcut-neutral')
assert(!/toggleAllMuted|anyAudible|toggleHint/.test(panelSource), 'audio panel removes global mute state')

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
JS
