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
  try {
    var id = node.id
    if (id === undefined || id === null) return null
    return { id: id, name: String(node.name || "") }
  } catch (e) {
    // PipeWire can destroy a node while a snapshot is still being taken.
    return null
  }
}

function rowSnapshot(list, liveNodes) {
  var values = list && list.length ? list : []
  // QML gives arrays as V4Sequence, so use length, not Array.isArray.
  var checkLive = liveNodes && typeof liveNodes.length === "number"
  var rows = []
  for (var i = 0; i < values.length; i++) {
    var node = values[i]
    if (checkLive) {
      var live = false
      for (var j = 0; j < liveNodes.length; j++)
        if (liveNodes[j] === node) { live = true; break }
      if (!live) continue
    }
    var row = nodeRow(node)
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

  // ALSA clients reach PipeWire through its ALSA bridge, which prefixes the
  // application's own name with the transport ("PipeWire ALSA [cliamp]",
  // "ALSA plug-in [mpv]").
  var alsa = label.match(/^(?:PipeWire\s+)?ALSA(?:\s+plug-?in)?\s*\[(.+)\]$/i)
  if (alsa) label = alsa[1].trim()

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

// The application a stream belongs to, as the mixer groups it. The application
// name is what the user recognises, the binary is the fallback for clients that
// publish no name, and the node id keeps unknown streams from merging into one
// anonymous row.
function streamAppKey(node) {
  if (!node) return ""

  var p = nodeProps(node)
  var label = p["application.name"]
    || p["application.process.binary"]
    || p["application.icon_name"]
    || p["application.icon-name"]
    || p["node.name"]
    || node.name
  label = friendlyStreamLabel(label).toLowerCase()
  if (label) return label

  return node.id === undefined || node.id === null ? "" : "node:" + node.id
}

// Icon names to try for an application, best first. PipeWire clients name
// their icon directly, and the desktop-entry id or the binary usually resolves
// through the icon theme when they do not. Names are lowercased because icon
// themes store them that way; spaces become dashes for the same reason.
function pushIconCandidate(names, value) {
  var text = String(value || "").trim()
  if (!text) return
  text = text.replace(/\.desktop$/i, "")
  // Category icons are what a client names when it has no icon of its own;
  // they would make every such app look alike, so the binary or display name
  // below gets the chance to find the real one.
  if (/^applications?-/.test(text) || /-x-generic$/.test(text)) return

  var variants = [text, text.toLowerCase(), text.toLowerCase().replace(/\s+/g, "-")]
  for (var i = 0; i < variants.length; i++) {
    if (variants[i] && names.indexOf(variants[i]) < 0) names.push(variants[i])
  }
}

// The track or file a stream is playing, for the second line of an app row.
// mpv appends its own name to the media title ("tone.wav - mpv"); generic
// placeholders such as "audio-src" say nothing and stay hidden.
function streamMediaLabel(node, appLabel) {
  if (!node) return ""

  var p = nodeProps(node)
  var media = String(p["media.name"] || "").trim()
  if (!media) return ""

  // Strip against the display label and the names the client publishes, since
  // the desktop entry's name ("mpv Media Player") may differ from the binary
  // suffix a player appends ("tone.wav - mpv").
  var names = [appLabel, p["application.name"], p["application.process.binary"]]
  for (var i = 0; i < names.length; i++) {
    var label = friendlyStreamLabel(names[i] || "")
    if (!label) continue
    if (media.toLowerCase() === label.toLowerCase()) return ""

    var suffix = " - " + label
    if (media.toLowerCase().endsWith(suffix.toLowerCase()))
      media = media.slice(0, media.length - suffix.length).trim()
  }
  if (!media) return ""

  var key = media.toLowerCase()
  if (["audio-src", "audio stream", "playback stream", "output", "alsa playback", "stream"].indexOf(key) !== -1)
    return ""
  if (/^audio\s*stream\b/i.test(media)) return ""
  return media
}

// ALSA clients publish a pipe-prefixed node name ("alsa_playback.cliamp")
// rather than a binary, so the trailing component is the application name.
function pushNodeNameIconCandidate(names, value) {
  var text = String(value || "").trim()
  if (!text) return

  pushIconCandidate(names, text)
  var dot = text.lastIndexOf(".")
  if (dot > 0 && dot < text.length - 1) pushIconCandidate(names, text.slice(dot + 1))
}

function streamAppIconCandidates(node) {
  var names = []
  if (!node) return names

  var p = nodeProps(node)
  pushIconCandidate(names, p["application.icon_name"])
  pushIconCandidate(names, p["application.icon-name"])
  pushIconCandidate(names, p["application.desktop"])
  pushIconCandidate(names, p["application.process.binary"])
  pushIconCandidate(names, p["application.name"])
  // "PipeWire ALSA [cliamp]" and its node name both carry the real application
  // name after the transport prefix.
  pushIconCandidate(names, friendlyStreamLabel(p["application.name"]))
  pushNodeNameIconCandidate(names, p["node.name"])
  pushNodeNameIconCandidate(names, node.name)
  return names
}

// ------------------------------------------------------------ workspaces
//
// A stream knows nothing about the workspace its window is on. Hyprland does:
// every window carries the pid of its client, and the stream usually publishes
// that pid too. ALSA clients (a terminal player, for instance) publish no pid,
// so their application name is matched against the window class, app id and
// title instead. Titles are matched on whole words only, so "mpv" does not
// claim a browser tab that merely mentions it.

// Project Hyprland toplevels to the primitives the workspace lookup needs.
function workspaceWindows(toplevels) {
  // QML hands us a V4Sequence, not a JS Array; it has length and indices but
  // Array.isArray is false, so accept any array-like.
  var values = toplevels && toplevels.length ? toplevels : []
  var windows = []

  for (var i = 0; i < values.length; i++) {
    var toplevel = values[i]
    if (!toplevel) continue

    var ipc = toplevel.lastIpcObject || {}
    var wayland = toplevel.wayland || {}
    var workspace = toplevel.workspace || ipc.workspace || null
    if (!workspace) continue

    var id = Number(workspace.id)
    if (!isFinite(id)) id = -1

    windows.push({
      pid: Number(ipc.pid || 0),
      appId: String(wayland.appId || "").toLowerCase(),
      wmClass: String(ipc.class || ipc.initialClass || "").toLowerCase(),
      title: String(ipc.title || "").toLowerCase(),
      workspaceId: id,
      workspaceName: String(workspace.name || "")
    })
  }

  return windows
}

// Names a stream can be recognised by, lowercased and free of the ALSA bridge
// prefix. The trailing component of the node name catches ALSA clients that
// publish nothing else.
function streamWorkspaceKeys(node) {
  var p = nodeProps(node)
  var keys = []

  function add(value) {
    var text = String(value || "").trim()
    if (!text) return
    text = friendlyStreamLabel(text).toLowerCase().replace(/\.desktop$/i, "")
    if (!text) return
    if (keys.indexOf(text) < 0) keys.push(text)
    var dashed = text.replace(/\s+/g, "-")
    if (dashed !== text && keys.indexOf(dashed) < 0) keys.push(dashed)
  }

  add(p["application.process.binary"])
  add(p["application.name"])
  add(p["application.desktop"])
  add(p["application.icon_name"])
  add(p["application.icon-name"])

  var nodeName = String(p["node.name"] || node.name || "")
  var dot = nodeName.lastIndexOf(".")
  if (dot >= 0 && dot < nodeName.length - 1) add(nodeName.slice(dot + 1))

  return keys
}

function textHasWord(text, word) {
  var at = text.indexOf(word)
  while (at >= 0) {
    var before = at === 0 ? "" : text.charAt(at - 1)
    var after = text.charAt(at + word.length)
    if (!/[a-z0-9]/.test(before) && !/[a-z0-9]/.test(after)) return true
    at = text.indexOf(word, at + 1)
  }
  return false
}

// The workspaces an application's windows are on, ascending, with special
// workspaces last. A browser with windows on two workspaces reports both.
function nodeWorkspaces(node, windows) {
  var list = windows && windows.length ? windows : []
  if (!node || list.length === 0) return []

  var p = nodeProps(node)
  var pid = Number(p["application.process.id"] || p["application.process.pid"] || 0)
  var matches = []

  for (var i = 0; pid > 0 && i < list.length; i++)
    if (list[i].pid === pid) matches.push(list[i])

  // A browser plays through a renderer process, and some clients publish a pid
  // that is not their window's, so a pid that finds nothing falls back to the
  // names the client publishes.
  if (matches.length === 0) {
    var keys = streamWorkspaceKeys(node)
    for (var j = 0; j < list.length; j++) {
      var window = list[j]
      var hit = false

      for (var k = 0; k < keys.length && !hit; k++) {
        if (window.appId && keys[k] === window.appId) hit = true
        else if (window.wmClass && keys[k] === window.wmClass) hit = true
      }

      for (var w = 0; w < keys.length && !hit; w++)
        if (keys[w].length >= 4 && textHasWord(window.title, keys[w])) hit = true

      if (hit) matches.push(window)
    }
  }

  var workspaces = []
  var seen = {}

  for (var m = 0; m < matches.length; m++) {
    var match = matches[m]
    var key = match.workspaceId >= 0
      ? "id:" + match.workspaceId
      : "name:" + match.workspaceName
    if (seen[key]) continue
    seen[key] = true
    workspaces.push({ id: match.workspaceId, name: match.workspaceName })
  }

  workspaces.sort(compareWorkspaces)

  return workspaces
}

function compareWorkspaces(a, b) {
  var aSpecial = a.id < 0
  var bSpecial = b.id < 0
  if (aSpecial !== bSpecial) return aSpecial ? 1 : -1
  if (aSpecial) return String(a.name).localeCompare(String(b.name))
  return a.id - b.id
}

// Every stream of an application can name a different window (a browser's
// tabs, a player's helper processes), so a grouped row merges their
// workspaces instead of trusting the first stream alone.
function groupWorkspaces(nodes, windows) {
  var list = nodes && nodes.length ? nodes : []
  var workspaces = []
  var seen = {}

  for (var i = 0; i < list.length; i++) {
    var found = nodeWorkspaces(list[i], windows)
    for (var j = 0; j < found.length; j++) {
      var key = found[j].id >= 0 ? "id:" + found[j].id : "name:" + found[j].name
      if (seen[key]) continue
      seen[key] = true
      workspaces.push(found[j])
    }
  }

  workspaces.sort(compareWorkspaces)
  return workspaces
}

function workspaceText(workspace, formatNumber) {
  if (!workspace) return ""
  if (workspace.id >= 0)
    return typeof formatNumber === "function" ? formatNumber(workspace.id) : String(workspace.id)
  var name = String(workspace.name || "").replace(/^special:/i, "")
  return name || String(workspace.id)
}

// The compact form the row badge carries: "3", or "1 · 3" across workspaces.
function workspaceShortLabel(workspaces, formatNumber) {
  var list = workspaces && workspaces.length ? workspaces : []
  var parts = []

  for (var i = 0; i < list.length; i++) {
    var text = workspaceText(list[i], formatNumber)
    if (text && parts.indexOf(text) < 0) parts.push(text)
  }

  return parts.join(" · ")
}

// The tooltip spells the badge out: "Workspace 3" or "Workspaces 1, 3".
// tr is the same translate(key, english) used by the route labels.
function workspaceTooltip(workspaces, tr, formatNumber) {
  var list = workspaces && workspaces.length ? workspaces : []
  var parts = []

  for (var i = 0; i < list.length; i++) {
    var text = workspaceText(list[i], formatNumber)
    if (text && parts.indexOf(text) < 0) parts.push(text)
  }
  if (parts.length === 0) return ""

  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var joined = parts.join(", ")
  var label = parts.length === 1
    ? t("audio.workspace.one", "Workspace %1")
    : t("audio.workspace.many", "Workspaces %1")
  return String(label).replace("%1", joined)
}

// One row per application, in the order its first stream appeared. A browser
// with two tabs playing is one mixer row, so muting or lowering it does not
// leave a second copy of the same application behind.
function groupStreamsByApp(streams) {
  var values = Array.isArray(streams) ? streams : []
  var groups = []
  var index = {}

  for (var i = 0; i < values.length; i++) {
    var node = values[i]
    if (!node) continue

    var key = streamAppKey(node) || "node:" + i
    if (!Object.prototype.hasOwnProperty.call(index, key)) {
      index[key] = groups.length
      groups.push({ key: key, streams: [] })
    }
    groups[index[key]].streams.push(node)
  }

  return groups
}

// A group's slider and readout follow its loudest stream, so a browser tab at
// 80% and another at 20% reads 80%, not an average of two unrelated levels.
function groupVolume(nodes) {
  var values = Array.isArray(nodes) ? nodes : []
  var volume = 0
  for (var i = 0; i < values.length; i++) {
    var node = values[i]
    // The mixer stops at 100%; a stream another tool boosted past it still
    // reads as full rather than making the slider disagree with its track.
    if (node && node.audio) volume = Math.max(volume, Math.min(1, Number(node.audio.volume) || 0))
  }
  return volume
}

// A group counts as muted only when every stream is muted: one unmuted tab
// still makes noise, so the row has to offer muting rather than unmuting.
function groupMuted(nodes) {
  var values = Array.isArray(nodes) ? nodes : []
  var sawAudio = false
  for (var i = 0; i < values.length; i++) {
    var node = values[i]
    if (!node || !node.audio) continue
    sawAudio = true
    if (!node.audio.muted) return false
  }
  return sawAudio
}

// Project groups to the primitives a Repeater can hold, keeping each stream's
// id and name so its delegate can resolve the live nodes again. The label is
// already translated by the caller.
function appGroupSnapshot(groups) {
  var values = Array.isArray(groups) ? groups : []
  var rows = []
  for (var i = 0; i < values.length; i++) {
    var group = values[i]
    if (!group) continue
    rows.push({
      key: String(group.key || ""),
      label: String(group.label || ""),
      rows: rowSnapshot(group.streams)
    })
  }
  return rows
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

// ---- Per application output routing ----
//
// The mixer moves a whole application by writing a WirePlumber `target.object`
// pin for each of its streams. WirePlumber remembers the pin, so the streams the
// application opens later start on the same output; clearing it with -1 hands
// them back to the default output.
var DEFAULT_ROUTE = "__default__"

// pw-metadata keeps target.object in the default metadata object rather than in
// the node's own properties, so the current routing has to be read from there.
// Lines look like:
//   update: id:120 key:'target.object' value:'alsa_output.analog-stereo' ...
function parseRouteTargets(raw) {
  var targets = {}
  var pattern = /id:(\d+)\s+key:'target\.object'\s+value:'([^']*)'/g
  var match
  while ((match = pattern.exec(String(raw || ""))) !== null) {
    targets[match[1]] = match[2]
  }
  return targets
}

function routeTargetOf(node, targets) {
  if (!node) return DEFAULT_ROUTE
  var target = targets ? targets[String(node.id)] : undefined
  if (target === undefined || target === null || target === "" || String(target) === "-1") return DEFAULT_ROUTE
  return String(target)
}

// After "--", so the -1 that clears a route is not read as an option.
function routeCommand(nodeId, sinkSerial) {
  var value = !sinkSerial || sinkSerial === DEFAULT_ROUTE ? "-1" : String(sinkSerial)
  return ["pw-metadata", "-n", "default", "--", String(nodeId), "target.object", value]
}

// PipeWire hands a gone node's id to the next node but never reuses an
// object.serial, so a queued route keeps the serial of the stream it was chosen
// for and runs only while that stream still holds the id.
function queuedRoute(node, target) {
  var serial = nodeProps(node)["object.serial"]
  return { target: target, serial: serial === undefined || serial === null ? "" : String(serial) }
}

function queuedRouteIsCurrent(nodes, id, route) {
  if (!route || route.serial === "") return false
  var list = nodes || []
  for (var i = 0; i < list.length; i++) {
    var node = list[i]
    if (node && String(node.id) === String(id)) return String(nodeProps(node)["object.serial"]) === route.serial
  }
  return false
}

// The sinks the panel offers. Follow-default comes first so a click always has
// a way back without remembering which output was chosen before.
function routeOptions(sinks) {
  var options = [DEFAULT_ROUTE]
  var list = sinks || []
  for (var i = 0; i < list.length; i++) {
    var serial = nodeProps(list[i])["object.serial"]
    if (serial === undefined || serial === null) continue
    var value = String(serial)
    if (options.indexOf(value) < 0) options.push(value)
  }
  return options
}

function nextRouteTarget(options, current) {
  var list = options || []
  for (var i = 0; i < list.length; i++) {
    if (list[i] === current) return list[(i + 1) % list.length]
  }
  return list.length > 0 ? list[0] : DEFAULT_ROUTE
}

function sinkNamed(sinks, name) {
  var list = sinks || []
  for (var i = 0; i < list.length; i++) {
    if (list[i] && (String(list[i].name) === String(name)
      || String(nodeProps(list[i])["object.serial"]) === String(name))) return list[i]
  }
  return null
}

// Prefer where the stream is linked, and fall back to the pinned preference,
// because a link group is not always resolved for a stream that just started.
// tr as in outputVolumeName.
function routeLabel(node, sinks, linkedSink, targets, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (linkedSink) return nodeLabel(linkedSink, tr)
  var target = routeTargetOf(node, targets)
  if (target === DEFAULT_ROUTE) return t("audio.route.followDefault", "Follow default output")
  var sink = sinkNamed(sinks, target)
  return sink ? nodeLabel(sink, tr) : String(target)
}

function routeIsPinned(node, targets) {
  return routeTargetOf(node, targets) !== DEFAULT_ROUTE
}

// The compact policy label the row pill shows: "Default" while the application
// follows the current output, otherwise the device it is pinned to. The full
// routeLabel is the tooltip, so a half-applied move still says where the stream
// really is.
function routePinnedLabel(node, sinks, targets, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var target = routeTargetOf(node, targets)
  if (target === DEFAULT_ROUTE) return t("audio.route.default", "Default")
  var sink = sinkNamed(sinks, target)
  return sink ? nodeLabel(sink, tr) : String(target)
}

if (typeof module !== "undefined") {
  module.exports = {
    DEFAULT_ROUTE: DEFAULT_ROUTE,
    parseRouteTargets: parseRouteTargets,
    routeTargetOf: routeTargetOf,
    routeCommand: routeCommand,
    queuedRoute: queuedRoute,
    queuedRouteIsCurrent: queuedRouteIsCurrent,
    routeOptions: routeOptions,
    nextRouteTarget: nextRouteTarget,
    sinkNamed: sinkNamed,
    routeLabel: routeLabel,
    routePinnedLabel: routePinnedLabel,
    routeIsPinned: routeIsPinned,
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
    streamAppKey: streamAppKey,
    streamAppIconCandidates: streamAppIconCandidates,
    streamMediaLabel: streamMediaLabel,
    workspaceWindows: workspaceWindows,
    streamWorkspaceKeys: streamWorkspaceKeys,
    textHasWord: textHasWord,
    nodeWorkspaces: nodeWorkspaces,
    groupWorkspaces: groupWorkspaces,
    workspaceShortLabel: workspaceShortLabel,
    workspaceTooltip: workspaceTooltip,
    groupStreamsByApp: groupStreamsByApp,
    groupVolume: groupVolume,
    groupMuted: groupMuted,
    appGroupSnapshot: appGroupSnapshot,
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
