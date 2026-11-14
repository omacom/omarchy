function isPlaybackStream(node) {
  if (!node || !node.isStream) return false
  if (node.isSink === true) return true

  var mediaClass = String(node.type || "")
  return mediaClass.indexOf("Stream/Output/Audio") !== -1
    || mediaClass.indexOf("AudioOutStream") !== -1
    || mediaClass.indexOf("Output") !== -1
}

function isAudioSource(node) {
  if (!node) return false
  if (node.audio) return true

  var mediaClass = String(node.type || "")
  return mediaClass.indexOf("Audio/Source") !== -1
    || mediaClass.indexOf("AudioSource") !== -1
    || mediaClass.indexOf("Source") !== -1
}

// Project a node list to the primitive rows a Repeater model can hold. A row
// holding the PwNode itself is a QObject that Qt dereferences without a null
// check while it builds the delegate, and PipeWire deletes nodes outright, so a
// graph teardown segfaults the shell. Primitives cannot dangle, which is what
// closes that race -- not the check below, since the node usually dies after the
// snapshot is taken. That is also why filtering the list here never worked.
//
// The name rides along because PipeWire reuses object ids: without it a row
// could resolve to whatever inherited its id. PwNode.name is CONSTANT, so it
// identifies the node it was taken from for as long as that node lives.
function nodeRow(node) {
  if (!node) return null
  var id = node.id
  if (id === undefined || id === null) return null
  return { id: id, name: String(node.name || "") }
}

function rowSnapshot(list) {
  var values = list && list.length ? list : []
  var rows = []
  for (var i = 0; i < values.length; i++) {
    var row = nodeRow(values[i])
    if (row) rows.push(row)
  }
  return rows
}

// tr is an optional translate(key, english) from the QML side (I18n.t);
// without it the English text stands, which is what the Node tests assert.
function outputVolumeName(volume, muted, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (muted) return t("audio.level.muted", "Muted")
  var p = Math.round(volume * 100)
  if (p === 0) return t("audio.level.silenced", "Silenced")
  if (p >= 100) return t("audio.level.concertHall", "Concert hall")
  if (p >= 85) return t("audio.level.partyMode", "Party mode")
  if (p >= 70) return t("audio.level.crankedUp", "Cranked up")
  if (p >= 50) return t("audio.level.steadyGroove", "Steady groove")
  if (p >= 30) return t("audio.level.easyListening", "Easy listening")
  if (p >= 15) return t("audio.level.murmur", "Murmur")
  return t("audio.level.whisper", "Whisper")
}

function parseSinkAvailability(raw) {
  var next = {}
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line) continue
    var parts = line.split("\t")
    if (parts.length >= 2) next[parts[0]] = parts[1] !== "0"
  }
  return next
}

function friendlyDeviceLabel(text) {
  var label = String(text || "").trim()
  label = label.replace(/^sof-soundwire\s+/i, "")
  label = label.replace(/^built-?in audio\s+/i, "")
  label = label.replace(/\s+Output$/i, "")
  label = label.replace(/\s+Input$/i, "")
  label = label.replace(/\bMicrophones\b/g, "Microphone")
  return label
}

function nodeProps(node) {
  return node && node.ready && node.properties ? node.properties : {}
}

// tr as in outputVolumeName; only the fallback for a nameless device is UI copy.
function nodeLabel(node, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (!node) return t("audio.unknownDevice", "Unknown")
  var p = nodeProps(node)
  var nickname = friendlyDeviceLabel(node.nickname || node.nick || p["node.nick"] || p["device.profile.description"] || "")
  if (nickname) return nickname
  return friendlyDeviceLabel(node.description || p["node.description"] || node.name || t("audio.unknownDevice", "Unknown"))
}

function isHeadphones(node) {
  if (!node) return false
  var p = nodeProps(node)
  var blob = String([
    node.name, node.description, node.nickname,
    p["device.icon-name"] || "",
    p["device.product.name"] || "",
    p["node.description"] || "",
    p["node.nick"] || ""
  ].join(" ")).toLowerCase()
  return blob.indexOf("headphone") !== -1
    || blob.indexOf("headset") !== -1
    || blob.indexOf("earbud") !== -1
    || blob.indexOf("earphone") !== -1
    || blob.indexOf("airpod") !== -1
}

function sinkGlyph(node) {
  if (!node) return "󰓃"
  if (isHeadphones(node)) return "󰋋"
  var p = nodeProps(node)
  var blob = String([
    node.name, node.description, node.nickname,
    p["device.icon-name"] || "",
    p["device.product.name"] || ""
  ].join(" ")).toLowerCase()
  if (blob.indexOf("bluetooth") !== -1) return "󰂯"
  if (blob.indexOf("hdmi") !== -1 || blob.indexOf("display") !== -1) return "󰍹"
  return "󰓃"
}

function sourceGlyph(node) {
  if (!node) return "󰍬"
  var p = nodeProps(node)
  var blob = String([
    node.name, node.description, node.nickname,
    p["device.icon-name"] || ""
  ].join(" ")).toLowerCase()
  if (blob.indexOf("headset") !== -1) return "󰋋"
  if (blob.indexOf("bluetooth") !== -1) return "󰂯"
  if (blob.indexOf("webcam") !== -1 || blob.indexOf("camera") !== -1) return "󰄀"
  return "󰍬"
}

function friendlyStreamLabel(label) {
  label = String(label || "").trim()
  if (!label) return ""

  var known = {
    "spotify": "Spotify"
  }
  var normalized = label.toLowerCase()
  return known[normalized] || label
}

function streamLabelKey(label) {
  return String(label || "").trim().toLowerCase()
}

function streamLabelIsGeneric(label) {
  return streamLabelKey(label) === "audio-src"
}

function rawStreamLabel(node) {
  if (!node) return ""
  var p = nodeProps(node)
  return p["application.name"]
    || node.description
    || p["media.name"]
    || p["node.name"]
    || node.name
}

function mprisPlayerLabel(player) {
  if (!player) return ""
  return friendlyStreamLabel(player.identity || player.desktopEntry || "")
}

function mprisPlayerIsProxy(player) {
  var dbusName = String(player && player.dbusName || "").toLowerCase()
  var desktopEntry = String(player && player.desktopEntry || "").toLowerCase()
  return dbusName.indexOf("playerctld") !== -1 || desktopEntry === "playerctld"
}

function streamRepresentsMprisPlayer(streamLabel, playerLabel) {
  var streamKey = streamLabelKey(friendlyStreamLabel(streamLabel))
  var playerKey = streamLabelKey(playerLabel)
  if (!streamKey || !playerKey) return false
  return streamKey === playerKey
    || streamKey.indexOf(playerKey) !== -1
    || playerKey.indexOf(streamKey) !== -1
}

function mprisLabelsFor(players, predicate) {
  var values = Array.isArray(players) ? players : []
  var playingCandidates = []
  var candidates = []
  var playingProxyCandidates = []
  var proxyCandidates = []

  for (var i = 0; i < values.length; i++) {
    var player = values[i]
    if (!player) continue
    if (!player.isPlaying && !player.canPlay) continue

    var playerLabel = mprisPlayerLabel(player)
    if (!playerLabel || !predicate(playerLabel)) continue

    if (mprisPlayerIsProxy(player)) {
      if (player.isPlaying) playingProxyCandidates.push(playerLabel)
      proxyCandidates.push(playerLabel)
    } else {
      if (player.isPlaying) playingCandidates.push(playerLabel)
      candidates.push(playerLabel)
    }
  }

  if (playingCandidates.length === 1) return playingCandidates[0]
  if (playingCandidates.length === 0 && playingProxyCandidates.length === 1) return playingProxyCandidates[0]
  if (candidates.length === 1) return candidates[0]
  if (candidates.length === 0 && proxyCandidates.length === 1) return proxyCandidates[0]
  return ""
}

function matchingMprisStreamLabel(label, players) {
  if (streamLabelIsGeneric(label)) return ""
  return mprisLabelsFor(players, function(playerLabel) {
    return streamRepresentsMprisPlayer(label, playerLabel)
  })
}

function unmatchedMprisStreamLabel(label, players, streams) {
  if (!streamLabelIsGeneric(label)) return ""

  return mprisLabelsFor(players, function(playerLabel) {
    var values = Array.isArray(streams) ? streams : []
    for (var i = 0; i < values.length; i++) {
      var stream = values[i]
      var streamLabel = rawStreamLabel(stream)
      if (!streamLabelIsGeneric(streamLabel) && streamRepresentsMprisPlayer(streamLabel, playerLabel))
        return false
    }
    return true
  })
}

// Matching passes no tr, so a nameless stream compares as English everywhere.
function streamLabel(node, players, streams, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (!node) return t("audio.stream", "Stream")
  var label = rawStreamLabel(node)
  return friendlyStreamLabel(matchingMprisStreamLabel(label, players)
    || unmatchedMprisStreamLabel(label, players, streams)
    || label) || t("audio.stream", "Stream")
}

function streamRepresentsPlayer(node, player, players, streams) {
  if (!node || !player) return false
  var playerLabel = mprisPlayerLabel(player)
  if (!playerLabel) return false

  var label = rawStreamLabel(node)
  if (!streamLabelIsGeneric(label)) return streamRepresentsMprisPlayer(label, playerLabel)
  return streamRepresentsMprisPlayer(streamLabel(node, players, streams), playerLabel)
}

// Quickshell types only exact media classes, so a virtual source (an
// Audio/Source/Virtual, such as EasyEffects' or a platform's microphone
// mapping) is a node with no PwNode.audio. PulseAudio lists it as a source, so
// the source availability listing names it; a non-stream node it names is one.
function isUntypedSource(node, sourceAvailability) {
  if (!node || node.audio || node.isStream || node.isSink) return false
  var name = String(node.name || "")
  return name !== "" && !!sourceAvailability && Object.prototype.hasOwnProperty.call(sourceAvailability, name)
}

var MEDIA_ACTION_NAMES = ["previous", "playPause", "next"]

function mediaMetadataPresent(title, artist) {
  return !!(title || artist)
}

var MEDIA_COMMIT_DELAY = 90
var MEDIA_CLEAR_DELAY = 2000

function mediaHandoffDelays() {
  return { commit: MEDIA_COMMIT_DELAY, clear: MEDIA_CLEAR_DELAY }
}

function emptyMediaCache() {
  return {
    playerKey: "",
    title: "",
    artist: "",
    playing: false,
    canGoPrevious: false,
    canPlayPause: false,
    canGoNext: false
  }
}

function mediaCacheHasMetadata(cache) {
  return !!cache && mediaMetadataPresent(cache.title, cache.artist)
}

// What the active player shows right now, or null when there is none.
function mediaLiveState(player, playerKey) {
  if (!player) return null
  return {
    playerKey: String(playerKey || ""),
    title: String(player.trackTitle || ""),
    artist: String(player.trackArtist || ""),
    playing: !!player.isPlaying,
    canGoPrevious: !!player.canGoPrevious,
    canPlayPause: !!(player.canTogglePlaying || player.canPlay || player.canPause),
    canGoNext: !!player.canGoNext
  }
}

function mediaHandoffResult(cache, commitTimer, clearTimer) {
  return { cache: cache, commitTimer: commitTimer || "", clearTimer: clearTimer || "" }
}

function clearedMediaHandoff() {
  return mediaHandoffResult(emptyMediaCache(), "stop", "stop")
}

function syncMediaHandoff(cache, live) {
  if (live && mediaMetadataPresent(live.title, live.artist)) {
    // MPRIS fields often arrive in separate signals. Commit them together
    // after a short settling window so title and artist change as one unit.
    return mediaHandoffResult(cache, "restart", "stop")
  }
  // Chromium may briefly unregister and replace its MPRIS player while
  // skipping. Keep the last complete presentation unless the gap persists.
  if (mediaCacheHasMetadata(cache)) return mediaHandoffResult(cache, "stop", "restart")
  return clearedMediaHandoff()
}

function refreshMediaHandoff(cache, live) {
  if (!live || !mediaMetadataPresent(live.title, live.artist)) {
    // Retain the last complete presentation and action target during a
    // transient MPRIS handoff instead of mixing the replacement player's state.
    return mediaHandoffResult(cache)
  }
  return mediaHandoffResult({
    playerKey: live.playerKey,
    title: cache.title,
    artist: cache.artist,
    playing: live.playing,
    canGoPrevious: live.canGoPrevious,
    canPlayPause: live.canPlayPause,
    canGoNext: live.canGoNext
  })
}

function commitMediaHandoff(cache, live) {
  if (!live || !mediaMetadataPresent(live.title, live.artist)) return syncMediaHandoff(cache, live)
  var titled = refreshMediaHandoff(cache, live).cache
  titled.title = live.title
  titled.artist = live.artist
  return mediaHandoffResult(titled)
}

// One step of the panel's media handoff. Events: "sync" (the active player or
// its metadata changed), "refresh" (its playback state changed), "commit" (the
// settling window ended) and "clearExpired" (a gap outlasted the handoff
// window). Returns the next cache and what to do with each timer: "restart",
// "stop", or "" to leave it.
function mediaHandoffStep(cache, live, event) {
  var current = cache || emptyMediaCache()
  if (event === "sync") return syncMediaHandoff(current, live)
  if (event === "refresh") return refreshMediaHandoff(current, live)
  if (event === "commit") return commitMediaHandoff(current, live)
  if (event === "clearExpired") {
    if (live && mediaMetadataPresent(live.title, live.artist)) return commitMediaHandoff(current, live)
    return clearedMediaHandoff()
  }
  return mediaHandoffResult(current)
}

// What the media section shows. Text comes from the cache once it holds a
// track, so a handoff cannot flash the replacement player's partial metadata;
// playback state and controls follow the live player whenever it has a track.
function mediaPresentation(cache, live, playerKeys) {
  var current = cache || emptyMediaCache()
  var useLive = !!live && mediaMetadataPresent(live.title, live.artist)
  var cached = mediaCacheHasMetadata(current)
  var state = useLive ? live : current
  var targetAvailable = mediaTargetAvailable(useLive, current.playerKey, playerKeys)
  return {
    visible: useLive || cached,
    live: useLive,
    title: cached ? current.title : (live ? live.title : ""),
    artist: cached ? current.artist : (live ? live.artist : ""),
    playing: state.playing,
    canGoPrevious: state.canGoPrevious && targetAvailable,
    canPlayPause: state.canPlayPause && targetAvailable,
    canGoNext: state.canGoNext && targetAvailable,
    targetAvailable: targetAvailable,
    targetKey: useLive ? live.playerKey : current.playerKey
  }
}

// Live controls act on the player they show. Cached controls belong to a
// player that may have closed, and the media service falls back to another
// player for a key it cannot find, so they only act while theirs is open.
function mediaTargetAvailable(useLivePresentation, cachedKey, playerKeys) {
  if (useLivePresentation) return true
  return !!cachedKey && (playerKeys || []).indexOf(cachedKey) >= 0
}

function mediaActionEnabled(player, action) {
  if (!player) return false
  if (action === "previous") return !!player.canGoPrevious
  if (action === "next") return !!player.canGoNext
  if (action === "playPause") return !!(player.canTogglePlaying || player.canPlay || player.canPause)
  return false
}

function mediaActionNames() {
  return MEDIA_ACTION_NAMES.slice()
}

function mediaActions(player) {
  return mediaActionNames().map(function(action) {
    return { action: action, enabled: mediaActionEnabled(player, action) }
  })
}

function firstEnabledMediaControl(player) {
  var controls = mediaActions(player)
  if (controls[1].enabled) return 1
  for (var i = 0; i < controls.length; i++) if (controls[i].enabled) return i
  return 0
}

function nextEnabledMediaControl(player, index, delta) {
  var controls = mediaActions(player)
  var i = index
  for (var step = 0; step < controls.length; step++) {
    i += delta
    if (i < 0 || i >= controls.length) return Math.max(0, Math.min(controls.length - 1, index))
    if (controls[i].enabled) return i
  }
  return index
}

if (typeof module !== "undefined") {
  module.exports = {
    isPlaybackStream: isPlaybackStream,
    isAudioSource: isAudioSource,
    nodeRow: nodeRow,
    rowSnapshot: rowSnapshot,
    outputVolumeName: outputVolumeName,
    parseSinkAvailability: parseSinkAvailability,
    friendlyDeviceLabel: friendlyDeviceLabel,
    nodeProps: nodeProps,
    nodeLabel: nodeLabel,
    isHeadphones: isHeadphones,
    sinkGlyph: sinkGlyph,
    sourceGlyph: sourceGlyph,
    friendlyStreamLabel: friendlyStreamLabel,
    streamLabelKey: streamLabelKey,
    streamLabelIsGeneric: streamLabelIsGeneric,
    rawStreamLabel: rawStreamLabel,
    mprisPlayerLabel: mprisPlayerLabel,
    mprisPlayerIsProxy: mprisPlayerIsProxy,
    streamRepresentsMprisPlayer: streamRepresentsMprisPlayer,
    mprisLabelsFor: mprisLabelsFor,
    matchingMprisStreamLabel: matchingMprisStreamLabel,
    unmatchedMprisStreamLabel: unmatchedMprisStreamLabel,
    streamLabel: streamLabel,
    streamRepresentsPlayer: streamRepresentsPlayer,
    isUntypedSource: isUntypedSource,
    mediaMetadataPresent: mediaMetadataPresent,
    mediaHandoffDelays: mediaHandoffDelays,
    emptyMediaCache: emptyMediaCache,
    mediaLiveState: mediaLiveState,
    mediaHandoffStep: mediaHandoffStep,
    mediaPresentation: mediaPresentation,
    mediaActionEnabled: mediaActionEnabled,
    mediaTargetAvailable: mediaTargetAvailable,
    mediaActionNames: mediaActionNames,
    mediaActions: mediaActions,
    firstEnabledMediaControl: firstEnabledMediaControl,
    nextEnabledMediaControl: nextEnabledMediaControl
  }
}
