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

function parseOutputProfiles(raw) {
  try {
    var parsed = JSON.parse(String(raw || "[]"))
    if (!Array.isArray(parsed)) return []

    var profiles = []
    for (var i = 0; i < parsed.length; i++) {
      var profile = parsed[i] || {}
      var cardName = String(profile.cardName || "")
      var profileName = String(profile.profileName || "")
      if (!cardName || !profileName) continue
      profiles.push({
        cardName: cardName,
        profileName: profileName,
        label: friendlyDeviceLabel(profile.label || profile.description || profileName),
        description: friendlyDeviceLabel(profile.description || "")
      })
    }
    return profiles
  } catch (error) {
    return []
  }
}

// A sink is named after the output mapping alone, so the duplex profile
// output:hdmi-stereo+input:analog-stereo and output:hdmi-stereo share the
// hdmi-stereo sink. Match on the mapping; activate the full profile name.
function outputProfileMapping(profileName) {
  var parts = String(profileName || "").split("+")
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].indexOf("output:") === 0) return parts[i].slice(7)
  }
  return ""
}

function outputProfileKey(cardName, profileName) {
  var mapping = outputProfileMapping(profileName)
  if (!cardName || !mapping) return ""
  return String(cardName) + "|" + mapping
}

function outputProfileSinkName(cardName, profileName) {
  cardName = String(cardName || "")
  var mapping = outputProfileMapping(profileName)
  if (cardName.indexOf("alsa_card.") !== 0 || !mapping) return ""
  return "alsa_output." + cardName.slice(10) + "." + mapping
}

function sinkProfileKey(node) {
  var p = nodeProps(node)
  var cardName = p["device.name"] || ""
  var profileName = p["device.profile.name"] || ""
  if (!cardName || !profileName) return ""
  if (String(profileName).indexOf("output:") !== 0) profileName = "output:" + profileName
  return outputProfileKey(cardName, profileName)
}

// Sinks that exist in the graph but are kept out of the list, such as the physical
// sink a speaker tuning fronts, still count as active: their profile is already
// in use, so offering it again would only duplicate the tuning's own row.
function outputRows(sinks, profiles, hiddenSinks) {
  var rows = []
  var activeProfiles = {}
  var profilesByKey = {}
  var profilesBySinkName = {}
  var sinkValues = Array.isArray(sinks) ? sinks : []
  var profileValues = Array.isArray(profiles) ? profiles : []
  var hiddenValues = Array.isArray(hiddenSinks) ? hiddenSinks : []

  for (var i = 0; i < profileValues.length; i++) {
    var availableProfile = profileValues[i]
    var availableKey = outputProfileKey(availableProfile.cardName, availableProfile.profileName)
    var sinkName = outputProfileSinkName(availableProfile.cardName, availableProfile.profileName)
    if (availableKey) profilesByKey[availableKey] = availableProfile
    if (sinkName) profilesBySinkName[sinkName] = availableProfile
  }

  for (var j = 0; j < sinkValues.length; j++) {
    var node = sinkValues[j]
    var activeKey = sinkProfileKey(node)
    var profile = profilesBySinkName[String(node && node.name || "")] || profilesByKey[activeKey]
    if (profile) activeKey = outputProfileKey(profile.cardName, profile.profileName)
    if (activeKey) activeProfiles[activeKey] = true
    rows.push({
      kind: "sink",
      node: node,
      label: profile ? profile.label : "",
      description: profile ? profile.description : ""
    })
  }

  for (var h = 0; h < hiddenValues.length; h++) {
    var hiddenNode = hiddenValues[h]
    var hiddenProfile = profilesBySinkName[String(hiddenNode && hiddenNode.name || "")]
    var hiddenKey = hiddenProfile
      ? outputProfileKey(hiddenProfile.cardName, hiddenProfile.profileName)
      : sinkProfileKey(hiddenNode)
    if (hiddenKey) activeProfiles[hiddenKey] = true
  }

  for (var k = 0; k < profileValues.length; k++) {
    var inactiveProfile = profileValues[k]
    var key = outputProfileKey(inactiveProfile.cardName, inactiveProfile.profileName)
    if (!key || activeProfiles[key]) continue
    rows.push({
      kind: "profile",
      cardName: inactiveProfile.cardName,
      profileName: inactiveProfile.profileName,
      label: inactiveProfile.label,
      description: inactiveProfile.description
    })
  }

  // Order by label, then by the sink the row stands for. A profile row and the
  // sink it turns into share that key, so activating an output never moves it,
  // even between outputs with identical labels or when the graph lists sinks in a
  // different order.
  return rows.sort(function(a, b) {
    var left = String(a && a.label || "")
    var right = String(b && b.label || "")
    if (left !== right) return left < right ? -1 : 1
    var leftKey = outputRowKey(a)
    var rightKey = outputRowKey(b)
    return leftKey < rightKey ? -1 : leftKey > rightKey ? 1 : 0
  })
}

// outputRows keeps the live node on sink rows. Project the rows to primitives the
// way rowSnapshot does, keeping the label and kind the delegate needs; the sink
// row's node is found again through nodeFor().
function outputRowSnapshot(rows) {
  var values = rows && rows.length ? rows : []
  var snapshot = []
  for (var i = 0; i < values.length; i++) {
    var row = values[i]
    if (!row) continue
    if (row.kind === "sink") {
      var base = nodeRow(row.node)
      if (!base) continue
      base.kind = "sink"
      base.label = row.label
      base.description = row.description
      snapshot.push(base)
    } else {
      snapshot.push({
        kind: "profile",
        cardName: row.cardName,
        profileName: row.profileName,
        label: row.label,
        description: row.description
      })
    }
  }
  return snapshot
}

function outputRowKey(row) {
  if (!row) return ""
  if (row.kind === "profile")
    return outputProfileSinkName(row.cardName, row.profileName) || String(row.cardName) + "|" + String(row.profileName)
  return String(row.node && row.node.name || "")
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

if (typeof module !== "undefined") {
  module.exports = {
    isPlaybackStream: isPlaybackStream,
    isAudioSource: isAudioSource,
    nodeRow: nodeRow,
    rowSnapshot: rowSnapshot,
    outputVolumeName: outputVolumeName,
    parseSinkAvailability: parseSinkAvailability,
    parseOutputProfiles: parseOutputProfiles,
    outputProfileMapping: outputProfileMapping,
    outputProfileKey: outputProfileKey,
    outputProfileSinkName: outputProfileSinkName,
    sinkProfileKey: sinkProfileKey,
    outputRows: outputRows,
    outputRowSnapshot: outputRowSnapshot,
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
    isUntypedSource: isUntypedSource
  }
}
