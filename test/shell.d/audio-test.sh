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

assert(/onPressed: function\(b\) \{\s*if \(b === Qt\.RightButton\) root\.toggleOutputMute\(\)/.test(panelSource), 'audio bar right-click toggles output')
const outputSwitch = qmlObject(panelSource, 'ToggleSwitch', 'outputMuteSwitch')
const outputCheckedExpression = outputSwitch.match(/checked: (.+)/)[1]
const outputChecked = new Function('root', `return ${outputCheckedExpression}`)
assert(!outputChecked({ hasOutput: true, outputMuted: true, inputMuted: false }), 'audio output switch stays off when input is audible')
assert(outputChecked({ hasOutput: true, outputMuted: false, inputMuted: true }), 'audio output switch turns on when output is audible')
assert(!outputChecked({ hasOutput: false, outputMuted: false, inputMuted: false }), 'audio output switch stays off without an output')
assert(/onToggled: root\.toggleOutputMute\(\)/.test(outputSwitch), 'audio output switch controls output')
assert(/text: root\.outputMuted \? "Unmute output" : "Mute output"/.test(outputSwitch), 'audio output tooltip describes output mute')
const inputSwitch = qmlObject(panelSource, 'ToggleSwitch', 'inputMuteSwitch')
assert(/text: root\.inputMuted \? "Unmute microphone" : "Mute microphone"/.test(inputSwitch), 'audio microphone tooltip stays shortcut-neutral')
assert(!/toggleAllMuted|anyAudible|toggleHint/.test(panelSource), 'audio panel removes global mute state')

{
  // A mute refreshes the device list; focus must stay on the section switch.
  const state = {
    cursorActive: true, focusSection: 'output', selectedIndex: -2,
    visibleSections: ['output', 'input'],
    displayAudioSinks: [], displayAudioSources: [],
    volumeSink: { audio: { muted: false } }, source: { audio: { muted: false } },
    setDefaultSink: () => {}, setDefaultSource: () => {}
  }
  for (const name of ['sectionCount', 'sectionHasSlider', 'moveCursor', 'clampCursor', 'activateCursor', 'toggleOutputMute', 'toggleInputMute']) {
    const match = panelSource.match(new RegExp('function ' + name + '\\(([^)]*)\\) \\{([\\s\\S]*?)\\n  \\}'))
    state[name] = new Function('state', 'return function(' + match[1] + ') { with (state) {' + match[2] + '\n} }')(state)
  }
  state.clampCursor()
  assertEqual(state.selectedIndex, -2, 'refresh keeps focus on the output mute switch')
  state.activateCursor()
  assert(state.volumeSink.audio.muted && !state.source.audio.muted, 'keyboard output switch mutes only output')
  state.moveCursor(1)
  assertEqual(state.selectedIndex, -1, 'down from the output switch reaches its slider')
  state.moveCursor(1)
  assertEqual(state.focusSection, 'input', 'down from the last output row reaches input')
  assertEqual(state.selectedIndex, -2, 'input starts at its own mute switch')
  state.clampCursor()
  assertEqual(state.selectedIndex, -2, 'refresh keeps focus on the input mute switch')
  state.activateCursor()
  assert(state.source.audio.muted && state.volumeSink.audio.muted, 'keyboard input switch does not unmute output')
  state.moveCursor(-1)
  assertEqual(state.focusSection, 'output', 'up from the input switch reaches output')
  assertEqual(state.selectedIndex, -1, 'up reaches the previous section slider when it has no devices')
  state.moveCursor(-1)
  assertEqual(state.selectedIndex, -2, 'up from the slider reaches the output switch')
}

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
