#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const media = requireFromRoot('shell/plugins/services/media/MediaModel.js')

assert(media.isProxyPlayer({ dbusName: 'org.mpris.MediaPlayer2.playerctld' }), 'media detects playerctld proxy by DBus name')
assert(media.isProxyPlayer({ desktopEntry: 'playerctld' }), 'media detects playerctld proxy by desktop entry')
assert(media.hasMetadata({ identity: 'Spotify' }), 'media detects identity metadata')
assert(media.hasTrackMetadata({ trackTitle: 'Track' }), 'media detects track metadata')
assert(media.playerCanControl({ canGoNext: true }), 'media detects controllable players')
assert(media.canHandleAction({ canTogglePlaying: true }, 'playPause'), 'media maps playPause capability')
assert(media.canCycleSource({ identity: 'Spotify', canPlay: true }), 'media detects cycleable sources')

assert(media.isPlaybackStream({ isStream: true, type: 'Stream/Output/Audio' }), 'media detects playback streams')
assertEqual(media.streamLabelKey('PipeWire ALSA [Chromium]'), 'chromium', 'media normalizes stream labels')
assertEqual(
  media.rawStreamLabel({ ready: true, properties: { 'application.name': 'Chromium' }, name: 'fallback' }),
  'Chromium',
  'media extracts raw stream labels'
)
assertEqual(
  media.playerAppLabel({ dbusName: 'org.mpris.MediaPlayer2.spotify.instance42' }),
  'spotify',
  'media derives player app labels from DBus names'
)
assert(media.playerHasPlaybackStream(
  { desktopEntry: 'chromium' },
  [{ ready: true, properties: { 'application.name': 'Chromium' } }]
), 'media matches players to playback streams')

assertEqual(media.playerKey({ dbusName: 'org.mpris.MediaPlayer2.spotify' }), 'org.mpris.MediaPlayer2.spotify', 'media derives stable player keys')
const track = { trackTitle: 'Song', trackArtist: 'Artist', trackAlbum: 'Album', trackArtUrl: 'file:///cover.jpg' }
const trackSignature = media.trackSignature(track)
assert(!media.trackChanged(trackSignature, { ...track }), 'media detects unchanged track metadata')
assert(media.trackChanged(trackSignature, { ...track, trackTitle: 'Next song' }), 'media detects changed track metadata')
assertEqual(media.labelFor({ trackTitle: 'Song', identity: 'Spotify' }), 'Song', 'media labels players by track first')
assertEqual(media.osdMessage({ trackTitle: 'Song', trackArtist: 'Artist' }, 'Fallback'), 'Song - Artist', 'media builds OSD messages')
assertEqual(media.osdMessage(null, 'Fallback'), 'Fallback', 'media falls back OSD messages')

// The in-shell volume keys follow omarchy-audio-output-volume's rules.
assertDeepEqual(media.volumeKeyStep('raise', 43, true), { percent: 48, muted: false }, 'volume raise steps 5 and unmutes')
assertDeepEqual(media.volumeKeyStep('lower', 48, true), { percent: 43, muted: false }, 'volume lower steps 5 and unmutes')
assertDeepEqual(media.volumeKeyStep('raise', 98, false), { percent: 100, muted: false }, 'volume raise clamps at 100')
assertDeepEqual(media.volumeKeyStep('raise', 120, false), { percent: 100, muted: false }, 'volume raise brings a boosted sink back to 100')
assertDeepEqual(media.volumeKeyStep('lower', 120, false), { percent: 115, muted: false }, 'volume lower steps down from a boosted sink')
assertDeepEqual(media.volumeKeyStep('lower', 3, false), { percent: 0, muted: false }, 'volume lower clamps at 0')
assertDeepEqual(media.volumeKeyStep('mute-toggle', 48, false), { percent: 48, muted: true }, 'mute toggle keeps the volume')
assertEqual(media.volumeKeyStep('+1', 48, false), null, 'volume keys leave other steps to the script')
assertEqual(media.volumeOsdIcon(48, false), 'volume-high', 'volume OSD shows the speaker when audible')
assertEqual(media.volumeOsdIcon(48, true), 'volume-muted', 'volume OSD shows muted when muted')
assertEqual(media.volumeOsdIcon(0, false), 'volume-muted', 'volume OSD shows muted at zero')

// Only an ALSA sink is its own physical sink. Any other default sink, a DSP
// chain or EasyEffects above all, needs omarchy-audio-output-sink's live
// resolution on every press, so its keys fall back to the script.
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/services/media/Service.qml'), 'utf8')
assert(
  serviceQml.includes('readonly property var volumeSink: defaultSink && String(defaultSink.name).indexOf("alsa_output.") === 0 ? defaultSink : null') &&
    /function handleVolumeKey\(action\) \{\s*var audio = volumeSink && volumeSink\.audio\s*if \(!audio\) return false/.test(serviceQml) &&
    !serviceQml.includes('volumeSinkName'),
  'volume keys act in the shell only on an ALSA sink and otherwise defer to the script'
)
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
assert(
  /if \(!media \|\| !media\.handleVolumeKey\(entry\.target\)\)\s*Util\.execArgv\(\["omarchy-audio-output-volume", entry\.target\]\)/.test(shellQml),
  'a volume key the shell declines runs omarchy-audio-output-volume'
)
JS
