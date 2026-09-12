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

const browser = { dbusName: 'org.mpris.MediaPlayer2.brave.instance1', identity: 'Brave', trackTitle: 'A video' }
const spotify = { dbusName: 'org.mpris.MediaPlayer2.spotify', identity: 'Spotify', trackTitle: 'A song' }
const proxy = { dbusName: 'org.mpris.MediaPlayer2.playerctld', identity: 'playerctld', trackTitle: 'Proxied' }

assertEqual(
  media.mostRecentlyActivePlayer([browser, spotify], { [media.playerKey(browser)]: 100, [media.playerKey(spotify)]: 50 }),
  browser,
  'media prefers the player most recently observed playing'
)
assertEqual(
  media.mostRecentlyActivePlayer([browser, spotify], { [media.playerKey(spotify)]: 50 }),
  spotify,
  'media picks the only player with recorded recency'
)
assertEqual(
  media.mostRecentlyActivePlayer([browser, spotify], {}),
  null,
  'media has no recency opinion when nothing was ever observed playing'
)
assertEqual(
  media.mostRecentlyActivePlayer([proxy], { [media.playerKey(proxy)]: 100 }),
  null,
  'media excludes proxy players from recency selection'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(spotify, 100, browser, { [media.playerKey(browser)]: 50 }),
  [spotify, browser],
  'media keeps a preference that is newer than the other player\'s last playback'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(spotify, 100, browser, { [media.playerKey(browser)]: 200 }),
  [browser, spotify],
  'media demotes a stale preference behind a player that played more recently'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(spotify, 100, spotify, { [media.playerKey(spotify)]: 200 }),
  [spotify],
  'media collapses preference and recency when they name the same player'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(null, 0, browser, { [media.playerKey(browser)]: 50 }),
  [browser],
  'media falls back to recency alone when nothing is preferred'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(spotify, 100, null, {}),
  [spotify],
  'media falls back to the preference alone when nothing was observed playing'
)
assertDeepEqual(
  media.recencyOrderedFallbacks(spotify, 100, browser, {}),
  [spotify, browser],
  'media keeps the preference first when the other player has no recorded recency'
)
JS
