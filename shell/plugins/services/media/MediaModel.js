function isProxyPlayer(player) {
  var dbusName = String(player && player.dbusName || "").toLowerCase()
  var desktopEntry = String(player && player.desktopEntry || "").toLowerCase()
  return dbusName.indexOf("playerctld") !== -1 || desktopEntry === "playerctld"
}

function hasMetadata(player) {
  return !!(player && (player.trackTitle || player.trackArtist || player.identity || player.desktopEntry))
}

function hasTrackMetadata(player) {
  return !!(player && (player.trackTitle || player.trackArtist || player.trackAlbum || player.trackArtUrl))
}

function playerCanControl(player) {
  return !!(player && (player.canTogglePlaying || player.canPlay || player.canPause || player.canGoNext || player.canGoPrevious))
}

function canHandleAction(player, action) {
  if (!player) return false
  if (action === "next") return !!player.canGoNext
  if (action === "previous") return !!player.canGoPrevious
  if (action === "play") return !!(player.canPlay || player.canTogglePlaying)
  if (action === "pause") return !!(player.canPause || player.canTogglePlaying)
  if (action === "playPause") return !!(player.canTogglePlaying || player.canPlay || player.canPause)
  return false
}

function canCycleSource(player) {
  return !!(player && hasMetadata(player) && (player.isPlaying || player.canPlay))
}

function nodeProps(node) {
  return node && node.ready && node.properties ? node.properties : {}
}

function isPlaybackStream(node) {
  if (!node || !node.isStream) return false
  if (node.isSink === true) return true

  var mediaClass = String(node.type || "")
  return mediaClass.indexOf("Stream/Output/Audio") !== -1
    || mediaClass.indexOf("AudioOutStream") !== -1
    || mediaClass.indexOf("Output") !== -1
}

function streamLabelKey(label) {
  var key = String(label || "").toLowerCase()
  key = key.replace(/^pipewire alsa \[/, "")
  key = key.replace(/\]$/, "")
  key = key.replace(/^alsa playback \[/, "")
  key = key.replace(/[^a-z0-9]+/g, "")
  return key
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

function playerAppLabel(player) {
  if (!player) return ""
  var dbus = String(player.dbusName || "")
  dbus = dbus.replace(/^org\.mpris\.MediaPlayer2\./, "")
  dbus = dbus.replace(/\.instance[0-9]+$/, "")
  return player.desktopEntry || player.identity || dbus
}

function playerHasPlaybackStream(player, playbackStreams) {
  var playerKey = streamLabelKey(playerAppLabel(player))
  if (!playerKey) return false

  var streams = Array.isArray(playbackStreams) ? playbackStreams : []
  for (var i = 0; i < streams.length; i++) {
    var streamKey = streamLabelKey(rawStreamLabel(streams[i]))
    if (!streamKey) continue
    if (streamKey === playerKey
        || streamKey.indexOf(playerKey) !== -1
        || playerKey.indexOf(streamKey) !== -1)
      return true
  }

  return false
}

function playerKey(player) {
  if (!player) return ""
  return String(player.dbusName || player.desktopEntry || player.identity || "")
}

function trackSignature(player) {
  if (!player) return ""
  return [
    player.trackTitle || "",
    player.trackArtist || "",
    player.trackAlbum || "",
    player.trackArtUrl || ""
  ].join("\u001f")
}

function trackChanged(previousSignature, player) {
  return trackSignature(player) !== String(previousSignature || "")
}

function labelFor(player) {
  if (!player) return ""
  return player.trackTitle || player.identity || player.desktopEntry || ""
}

function osdMessage(player, fallback) {
  if (!player) return fallback
  var label = labelFor(player)
  if (label && player.trackArtist) return label + " - " + player.trackArtist
  return label || fallback
}

// What a volume key does to the output, by omarchy-audio-output-volume's rules:
// raise and lower step 5 and clamp to 0..100 (so a boosted sink drops to 100
// on raise), unmuting as they go; mute-toggle flips mute and keeps the volume.
function volumeKeyStep(action, percent, muted) {
  if (action === "raise") return { percent: Math.min(percent + 5, 100), muted: false }
  if (action === "lower") return { percent: Math.max(percent - 5, 0), muted: false }
  if (action === "mute-toggle") return { percent: percent, muted: !muted }
  return null
}

function volumeOsdIcon(percent, muted) {
  return muted || percent === 0 ? "volume-muted" : "volume-high"
}

// A stream carrying a call or meeting, by PipeWire's canonical VOIP roles.
function isCommunicationStream(node) {
  if (!node || !node.properties) return false
  var role = String(node.properties["media.role"] || "")
  return /phone|communication|voip/i.test(role)
}

// The sink the volume keys should control. A communication stream wins wherever
// it plays -- even on the default sink, so a call on the speakers is not drowned
// out by music routed elsewhere. Otherwise a playback stream linked to a
// non-default sink wins. With neither, null, meaning the default sink.
//
// linkGroups are PipeWire's link groups reduced to { source, target, active }:
// source is the stream, target the sink it feeds, and active is true while the
// link is up (PwLinkState.Active). A corked stream keeps an active link, so
// this over-approximates "playing": it may answer a sink whose stream is
// paused, and the caller's script then refines the answer with the corked flag.
function activeVolumeSink(defaultSink, linkGroups) {
  if (!defaultSink) return null
  var defaultName = String(defaultSink.name)
  var comm = null
  var other = null
  var groups = Array.isArray(linkGroups) ? linkGroups : []
  for (var i = 0; i < groups.length; i++) {
    var group = groups[i]
    if (!group || !group.active || !group.source || !group.target) continue
    if (!group.target.isSink || !isPlaybackStream(group.source)) continue
    if (isCommunicationStream(group.source)) {
      if (comm === null) comm = group.target
    } else if (other === null && String(group.target.name) !== defaultName) {
      other = group.target
    }
  }
  return comm || other || null
}

if (typeof module !== "undefined") {
  module.exports = {
    isProxyPlayer: isProxyPlayer,
    hasMetadata: hasMetadata,
    hasTrackMetadata: hasTrackMetadata,
    playerCanControl: playerCanControl,
    canHandleAction: canHandleAction,
    canCycleSource: canCycleSource,
    nodeProps: nodeProps,
    isPlaybackStream: isPlaybackStream,
    streamLabelKey: streamLabelKey,
    rawStreamLabel: rawStreamLabel,
    playerAppLabel: playerAppLabel,
    playerHasPlaybackStream: playerHasPlaybackStream,
    playerKey: playerKey,
    trackSignature: trackSignature,
    trackChanged: trackChanged,
    labelFor: labelFor,
    osdMessage: osdMessage,
    volumeKeyStep: volumeKeyStep,
    volumeOsdIcon: volumeOsdIcon,
    isCommunicationStream: isCommunicationStream,
    activeVolumeSink: activeVolumeSink
  }
}
