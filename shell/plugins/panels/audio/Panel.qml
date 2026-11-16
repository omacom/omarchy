import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.audio"
  ipcTarget: "omarchy.audio"

  TextMetrics {
    id: appPctMetrics
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
    text: Commons.I18n.formatNumber(100) + "%"
  }

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []
  // Window-to-workspace projection, rebuilt when a window or its workspace
  // changes. App rows resolve their streams against this, so a player moved to
  // another workspace follows without reopening the panel.
  readonly property var workspaceWindows: Model.workspaceWindows(Hyprland.toplevels ? Hyprland.toplevels.values : [])
  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
  readonly property var activeMediaPlayer: mediaService ? mediaService.activePlayer : null

  // Nodes of a platform's audio processing, which are neither devices nor apps,
  // stay out of every list (AudioNodes.platformHides). Most machines have none.
  readonly property var nodeNames: {
    var names = []
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i] && nodes[i].name) names.push(String(nodes[i].name))
    return names
  }

  function platformHides(node) {
    return !!node && AudioNodes.platformHides(node.name, nodeNames)
  }

  readonly property var candidateSinks: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (!n || !n.isSink || n.isStream || platformHides(n)) continue
      list.push(n)
    }
    return list
  }

  readonly property var candidateSources: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (!n || n.isSink || n.isStream) continue
      if (!isAudioSource(n) && !Model.isUntypedSource(n, sourceAvailability)) continue
      var name = n.name || ""
      if (name === "quickshell" || platformHides(n)) continue
      list.push(n)
    }
    return list
  }

  readonly property var candidateStreams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (!n || !n.isStream || !isPlaybackStream(n)) continue
      // A tuning's output is a playback stream too, but it is the processing
      // itself rather than an application, so it does not belong in the list.
      if (String(n.name || "").indexOf("omarchy_speaker_tuning") === 0) continue
      if (platformHides(n)) continue
      list.push(n)
    }
    return list
  }

  property var sinkAvailability: ({})
  property bool sinkAvailabilityLoaded: false
  property var sourceAvailability: ({})

  // Identify true playback streams without reading node.properties here:
  // PwNode.properties is invalid until the node is bound, and reading it while
  // capture streams are appearing (for example, when Voxtype starts recording)
  // can destabilize Quickshell's Pipewire service. Quickshell versions differ
  // in how `type` is exposed (media.class, enum name, or numeric enum), but
  // playback streams consistently accept audio input from clients and publish
  // `isSink: true`; capture streams publish as stream sources.
  function isPlaybackStream(node) {
    return Model.isPlaybackStream(node)
  }

  function isAudioSource(node) {
    return Model.isAudioSource(node)
  }

  // A default sink/source can lag behind Pipewire.nodes while the graph is
  // torn down; never let a stale QObject into a snapshot.
  function nodePresent(node) {
    if (!node) return false
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i] === node) return true
    return false
  }

  readonly property var audioSinks: {
    var list = []
    for (var i = 0; i < candidateSinks.length; i++)
      if (sinkAvailable(candidateSinks[i])) list.push(candidateSinks[i])
    if (sink && nodePresent(sink) && list.indexOf(sink) < 0) list.unshift(sink)
    return list
  }

  readonly property var audioSources: {
    var list = candidateSources.slice()
    if (source && nodePresent(source) && list.indexOf(source) < 0) list.unshift(source)
    return list
  }

  readonly property var audioStreams: {
    var list = []
    for (var i = 0; i < candidateStreams.length; i++)
      if (candidateStreams[i].audio) list.push(candidateStreams[i])
    return list
  }

  // The mixer's unit is the application, not the stream: a browser with two
  // tabs playing, or a player that opens one stream per track, gets a single
  // row so muting it does not leave a second copy of the same app behind.
  // Each group keeps its stream nodes only for the live list; the Repeaters
  // below receive the primitive snapshot instead.
  readonly property var audioAppGroups: {
    var groups = Model.groupStreamsByApp(audioStreams)
    var list = []
    for (var i = 0; i < groups.length; i++) {
      var group = groups[i]
      list.push({
        key: group.key,
        label: appLabelFor(group),
        streams: group.streams
      })
    }
    return list
  }

  // Feed Repeaters with panel-local snapshots of primitives instead of the live
  // PipeWire model. PipeWire can remove nodes while Quickshell is dispatching
  // the removal signal, and a row still holding the PwNode is a QObject Qt
  // dereferences without a null check, which segfaults the shell. Rows carry id
  // and name only; every delegate resolves its own node through nodeFor(). The
  // snapshot timer lets the mutation settle first, and closed panels keep their
  // repeaters detached entirely.
  property var displayAudioSinks: []
  property var displayAudioSources: []
  property var displayAudioApps: []

  // A DSP sink -- a speaker tuning, or EasyEffects -- can be the selected output
  // without being where loudness lives: changing its volume alters the level going
  // *into* the processing, so the slider would move while the speakers did not,
  // and on a chain with a limiter it would change the tone as well.
  //
  // omarchy-audio-output-sink resolves the *current* default output through any
  // such sink to the physical one, which is the same definition the volume keys
  // and the output switcher use. Resolving the default (rather than "whatever a
  // tuning fronts") is what keeps this correct when headphones or HDMI are
  // selected while a tuning still exists.
  property string volumeSinkName: ""

  // Carry sub-notch touchpad deltas between wheel events.
  property real wheelAccumulator: 0

  readonly property var volumeSink: {
    if (volumeSinkName === "" || !sink) return sink
    if (volumeSinkName === String(sink.name)) return sink
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.isSink && !n.isStream && String(n.name) === volumeSinkName && n.audio)
        return n
    }
    return sink
  }

  // Re-resolve whenever the selected output changes, and when nodes or links
  // come and go: a tuning being applied or removed underneath us, or a DSP sink
  // rerouted to another output, shows up as exactly that.
  onSinkChanged: resolveVolumeSink()
  onNodesChanged: volumeSinkResolveTimer.restart()

  Connections {
    target: Pipewire.linkGroups
    function onValuesChanged() { volumeSinkResolveTimer.restart() }
  }

  property bool volumeSinkStale: false
  // Bumped by every resolve, so a script read still running from before cannot
  // overwrite a newer answer, the hardware fast path's included.
  property int volumeSinkGeneration: 0
  property int volumeSinkRequest: -1

  function resolveVolumeSink() {
    volumeSinkGeneration++
    // A hardware output is its own volume sink, as omarchy-audio-output-sink
    // reports without looking further, so only a DSP sink needs the script.
    if (sink && String(sink.name).indexOf("alsa_output.") === 0) {
      volumeSinkName = String(sink.name)
      return
    }
    if (volumeSinkProc.running) {
      volumeSinkStale = true
      return
    }
    volumeSinkRequest = volumeSinkGeneration
    volumeSinkProc.running = true
  }

  // An idle EasyEffects is resolved through its configured output device, which
  // changes without touching the Pipewire graph.
  FileView {
    path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/easyeffects/db/easyeffectsrc"
    watchChanges: true
    printErrors: false
    onFileChanged: volumeSinkResolveTimer.restart()
  }

  readonly property real outputVolume: volumeSink && volumeSink.audio ? volumeSink.audio.volume : 0
  readonly property bool outputMuted: volumeSink && volumeSink.audio ? volumeSink.audio.muted : false
  // A virtual source is untyped in Quickshell (see Model.isUntypedSource), so
  // its volume and mute go through wpctl (UntypedInput), and the panel shows no
  // level meter for it: Quickshell's peak monitor takes typed nodes only.
  readonly property bool inputViaWpctl: UntypedInput.active
  readonly property bool inputLevelKnown: !inputViaWpctl || UntypedInput.known
  readonly property real inputVolume: inputViaWpctl ? UntypedInput.volume : (source && source.audio ? source.audio.volume : 0)
  readonly property bool inputMuted: inputViaWpctl ? UntypedInput.muted : (source && source.audio ? source.audio.muted : false)
  readonly property var inputPeakNode: inputViaWpctl ? null : source
  readonly property bool inputLevelShown: !!inputPeakNode

  // Single cursor model shared by keyboard and mouse. Sections:
  //   "output" — output slider + sink device list
  //   "input"  — input slider + source device list
  //   "apps"   — one row per application playing audio
  // selectedIndex semantics within a section:
  //   -1            → on the slider row (h/l adjusts volume, m/Enter mute)
  //   0..N-1        → on the Nth device/app row
  // Visuals derive from hasCursor/current via CursorSurface, never
  // from containsMouse — that's what keeps the highlight unique across
  // keyboard + mouse like wifi does.
  property string focusSection: "output"
  property int selectedIndex: -1
  property bool cursorActive: false

  // "header" is a virtual section for the hero output mute toggle; it sits
  // above the output section so the speaker can be muted from the keyboard.
  readonly property bool headerHasCursor: cursorActive && focusSection === "header"
  // Only channels that actually exist get a vote. A box with no default source
  // would otherwise report "input unmuted" forever, leaving the hero switch
  // able to mute but never to unmute.
  readonly property bool hasOutput: !!(volumeSink && volumeSink.audio)
  readonly property bool hasInput: !!(source && source.audio) || (inputViaWpctl && UntypedInput.known)
  readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)
  readonly property string toggleHint: anyAudible ? Commons.I18n.t("audio.mute") : Commons.I18n.t("audio.unmute")

  readonly property color hoverFill: bar
    ? Style.hoverFillFor(bar.foreground, Commons.Color.accent)
    : "transparent"
  readonly property color selectedFill: bar
    ? Style.selectedFillFor(bar.foreground, Commons.Color.accent)
    : "transparent"

  function sectionCount(section) {
    if (section === "output") return displayAudioSinks.length
    if (section === "input") return displayAudioSources.length
    if (section === "apps") return displayAudioApps.length
    return 0
  }

  function sectionVisible(section) {
    if (section === "output") return true
    if (section === "input") return displayAudioSources.length > 0 || !!source
    if (section === "apps") return displayAudioApps.length > 0
    return false
  }

  function sectionHasSlider(section) {
    if (section === "output") return true
    if (section === "input") return !!source
    return false  // app rows carry their own sliders inline; not a section-level slider
  }

  // Order of visible sections, recomputed reactively so dropping a section
  // (e.g. no input devices) doesn't leave the cursor pointing at it.
  readonly property var visibleSections: {
    var list = []
    if (sectionVisible("output")) list.push("output")
    if (sectionVisible("input")) list.push("input")
    if (sectionVisible("apps")) list.push("apps")
    return list
  }

  function moveCursor(delta) {
    var sections = visibleSections
    if (sections.length === 0) return
    if (focusSection === "header") {
      if (delta > 0) { focusSection = sections[0]; selectedIndex = sectionHasSlider(sections[0]) ? -1 : 0 }
      return
    }
    var sIdx = sections.indexOf(focusSection)
    if (sIdx < 0) { focusSection = sections[0]; selectedIndex = sectionHasSlider(focusSection) ? -1 : 0; return }

    var idx = selectedIndex
    var max = sectionCount(focusSection) - 1  // last device index
    var hasSlider = sectionHasSlider(focusSection)
    var floor = hasSlider ? -1 : 0  // -1 = slider row

    if (delta > 0) {
      if (idx < max) { selectedIndex = idx + 1; return }
      // Fall through to next section.
      if (sIdx < sections.length - 1) {
        focusSection = sections[sIdx + 1]
        selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
      }
    } else {
      if (idx > floor) { selectedIndex = idx - 1; return }
      // Escape upward.
      if (sIdx > 0) {
        focusSection = sections[sIdx - 1]
        var prevMax = sectionCount(focusSection) - 1
        selectedIndex = prevMax >= 0 ? prevMax : (sectionHasSlider(focusSection) ? -1 : 0)
      } else {
        focusSection = "header"
      }
    }
  }

  function setHeaderCursor() {
    cursorActive = true
    focusSection = "header"
    selectedIndex = -1
  }

  function setAppCursor(index) {
    cursorActive = true
    focusSection = "apps"
    selectedIndex = index
  }

  function moveSection(delta) {
    var sections = visibleSections
    if (sections.length === 0) return
    var current = sections.indexOf(focusSection)
    if (current < 0) current = delta > 0 ? -1 : 0
    var next = (current + delta + sections.length) % sections.length
    focusSection = sections[next]
    selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
    cursorActive = true
  }

  // Adjust the slider associated with the focused section. Output and
  // input sliders are real volume controls; on stream rows h/l adjusts
  // that stream's volume (so keyboard parity with the inline slider).
  // For device rows (selectedIndex >= 0 in output/input) h/l is a no-op
  // — the cursor is on a discrete row, not on the slider, and silently
  // moving the global slider would surprise the user.
  function adjustVolume(delta) {
    if (focusSection === "output" && selectedIndex === -1) {
      setOutputVolume(outputVolume + delta)
      return
    }
    if (focusSection === "input" && selectedIndex === -1) {
      setInputVolume(inputVolume + delta)
      return
    }
    if (focusSection === "apps" && selectedIndex >= 0 && selectedIndex < displayAudioApps.length) {
      adjustAppVolume(displayAudioApps[selectedIndex], delta)
    }
  }

  // Enter/Space: activate whatever the cursor is on.
  function activateCursor() {
    if (focusSection === "header") { toggleAllMuted(); return }
    if (focusSection === "output") {
      if (selectedIndex === -1) { toggleOutputMute(); return }
      var sink = nodeFor(displayAudioSinks[selectedIndex])
      if (sink) setDefaultSink(sink)
      return
    }
    if (focusSection === "input") {
      if (selectedIndex === -1) { toggleInputMute(); return }
      var src = nodeFor(displayAudioSources[selectedIndex])
      if (src) setDefaultSource(src)
      return
    }
    if (focusSection === "apps" && selectedIndex >= 0) {
      toggleAppMuted(displayAudioApps[selectedIndex])
    }
  }

  onOpenedChanged: {
    if (opened) {
      refreshDisplayAudioModels()
      routeTargetsProc.restart()
      focusSection = "output"
      selectedIndex = -1  // first keyboard cursor reveal starts on the output slider
      cursorActive = false
      Qt.callLater(resetScroll)
    } else {
      clearDisplayAudioModels()
    }
  }

  // Clamp / repair the cursor whenever any list refreshes underneath us.
  onAudioSinksChanged: scheduleDisplayAudioModelRefresh()
  onAudioSourcesChanged: scheduleDisplayAudioModelRefresh()
  onAudioAppGroupsChanged: {
    scheduleDisplayAudioModelRefresh()
    if (opened) routeTargetsProc.restart()
  }

  function rowSnapshot(list) {
    return Model.rowSnapshot(list, nodes)
  }

  // A row that outlives its node resolves to null, or to a node PipeWire recreated
  // under the same id and name; every binding below guards for null, and a row
  // that never held the node cannot dangle.
  function nodeFor(row) {
    if (!row) return null
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i]
      if (n && n.id === row.id && String(n.name || "") === row.name) return n
    }
    return null
  }

  // Resolve every stream a grouped app row stands for. A stream that ended
  // resolves to null and is dropped; the row keeps whatever is still playing.
  function nodesForApp(app) {
    var list = []
    if (!app || !app.rows) return list
    for (var i = 0; i < app.rows.length; i++) {
      var node = nodeFor(app.rows[i])
      if (node) list.push(node)
    }
    return list
  }

  // Every stream in a group moves by the same step, so streams that a player
  // set at different levels keep their balance while the app row follows its
  // loudest stream. Dragging the inline slider sets the whole group flat.
  function adjustAppVolume(app, delta) {
    var list = nodesForApp(app)
    for (var i = 0; i < list.length; i++)
      if (list[i].audio) list[i].audio.volume = Math.max(0, Math.min(1, list[i].audio.volume + delta))
  }

  function setAppVolume(app, volume) {
    var list = nodesForApp(app)
    var level = Math.max(0, Math.min(1, volume))
    for (var i = 0; i < list.length; i++)
      if (list[i].audio) list[i].audio.volume = level
  }

  // Mute means every stream is silent. One unmuted tab still plays, so the
  // toggle mutes the group in that case and unmutes all only once it is quiet.
  function toggleAppMuted(app) {
    var list = nodesForApp(app)
    var mute = !Model.groupMuted(list)
    for (var i = 0; i < list.length; i++)
      if (list[i].audio) list[i].audio.muted = mute
  }

  // ---- Per-application output routing ----
  //
  // Every stream in a group gets the same pin, so a browser's tabs move
  // together and the choice survives the streams the application opens later.
  // Writes are serialized: pw-metadata takes one node at a time, and a burst of
  // clicks must end on the last target rather than race its predecessors.
  property var routeTargets: ({})
  property var pendingRoutes: ({})
  property int routeGeneration: 0
  property bool routeRefreshPending: false

  function cycleAppRoute(app) {
    var list = nodesForApp(app)
    if (list.length === 0) return

    var options = Model.routeOptions(audioSinks)
    if (options.length <= 1) return
    var current = Model.routeTargetOf(list[0], routeTargets)
    var next = Model.nextRouteTarget(options, current)
    var targets = Object.assign({}, routeTargets)
    var pending = Object.assign({}, pendingRoutes)
    for (var i = 0; i < list.length; i++) {
      var id = String(list[i].id)
      targets[id] = next
      pending[id] = Model.queuedRoute(list[i], next)
    }
    routeTargets = targets
    pendingRoutes = pending
    routeGeneration++
    runNextRoute()
  }

  function runNextRoute() {
    if (routeWriteProc.running) return
    var ids = Object.keys(pendingRoutes)
    if (ids.length === 0) {
      routeTargetsProc.restart()
      return
    }
    var id = ids[0]
    var pending = Object.assign({}, pendingRoutes)
    var route = pending[id]
    delete pending[id]
    pendingRoutes = pending
    if (!Model.queuedRouteIsCurrent(nodes, id, route)) {
      runNextRoute()
      return
    }
    routeWriteProc.command = Model.routeCommand(id, route.target)
    routeWriteProc.running = true
  }

  function acceptRouteSnapshot(text, generation) {
    if (generation !== routeGeneration || routeWriteProc.running || Object.keys(pendingRoutes).length > 0) return
    routeTargets = Model.parseRouteTargets(text)
  }

  function routePinnedFor(nodes) {
    for (var i = 0; i < nodes.length; i++)
      if (Model.routeIsPinned(nodes[i], routeTargets)) return true
    return false
  }

  function iconSourceFor(name) {
    var value = String(name || "").trim()
    if (!value) return ""
    if (value.charAt(0) === "/") return Util.fileUrl(value)

    var entry = DesktopEntries.heuristicLookup(value)
    if (entry && entry.icon) {
      var icon = String(entry.icon)
      if (icon.charAt(0) === "/") return Util.fileUrl(icon)
      var themed = Quickshell.iconPath(icon, true)
      if (themed) return themed
    }
    return Quickshell.iconPath(value, true)
  }

  function desktopEntryFor(names) {
    for (var i = 0; i < names.length; i++) {
      var entry = DesktopEntries.heuristicLookup(names[i])
      if (entry) return entry
    }
    return null
  }

  // The desktop entry's own name is what the app launcher shows, so a binary
  // such as "chromium" reads as "Chromium" and an ALSA client's bridge name
  // resolves to its real application.
  //
  // Group labels feed the Repeater model, so they must not depend on MPRIS
  // playback state: pressing play or pause would rebuild every row (and
  // interrupt a slider drag) even though the app did not move. The row resolves
  // the richer MPRIS-aware label itself through appDisplayLabel().
  function appLabelFor(group) {
    var label = ""
    if (group && group.streams && group.streams.length > 0)
      label = Model.friendlyStreamLabel(Model.rawStreamLabel(group.streams[0]))
    for (var i = 0; group && i < group.streams.length; i++) {
      var entry = desktopEntryFor(Model.streamAppIconCandidates(group.streams[i]))
      if (entry && String(entry.name || "").trim()) return String(entry.name).trim()
    }
    return label || String(group && group.key || "")
  }

  function appDisplayLabel(list) {
    if (!list || list.length === 0) return ""
    var label = Model.streamLabel(list[0], mprisPlayers, audioStreams, Commons.I18n.t)
    for (var i = 0; i < list.length; i++) {
      var entry = desktopEntryFor(Model.streamAppIconCandidates(list[i]))
      if (entry && String(entry.name || "").trim()) return String(entry.name).trim()
    }
    return label
  }

  function playerForApp(list) {
    for (var i = 0; i < list.length; i++)
      for (var j = 0; j < mprisPlayers.length; j++)
        if (streamRepresentsPlayer(list[i], mprisPlayers[j])) return mprisPlayers[j]
    return null
  }

  // The track title belonged under the application it played from; the mixer
  // now shows the application name alone so every row keeps one line.

  // Try every stream in the group: the first one may be a generic stream while
  // a later one carries the application icon. A media player with no icon of
  // its own falls back to its MPRIS desktop entry; the row draws a monogram
  // when nothing resolves.
  function appIconSource(list) {
    for (var i = 0; i < list.length; i++) {
      var names = Model.streamAppIconCandidates(list[i])
      for (var j = 0; j < names.length; j++) {
        var source = iconSourceFor(names[j])
        if (source) return source
      }
    }

    var player = playerForApp(list)
    if (player) {
      var playerNames = [player.desktopEntry, player.identity]
      for (var p = 0; p < playerNames.length; p++) {
        var playerSource = iconSourceFor(playerNames[p])
        if (playerSource) return playerSource
      }
    }
    return ""
  }

  function refreshDisplayAudioModels() {
    if (!opened) return
    displayAudioSinks = rowSnapshot(audioSinks)
    displayAudioSources = rowSnapshot(audioSources)
    displayAudioApps = Model.appGroupSnapshot(audioAppGroups)
    clampCursor()
  }

  function scheduleDisplayAudioModelRefresh() {
    if (!opened) return
    audioModelRefreshTimer.restart()
  }

  function clearDisplayAudioModels() {
    audioModelRefreshTimer.stop()
    displayAudioSinks = []
    displayAudioSources = []
    displayAudioApps = []
  }

  // Keep the keyboard-focused row inside the visible viewport of the
  // ScrollView. Each cursor target (slider rows, SinkRow, SourceRow,
  // AppRow) calls this when it gains hasCursor. Without it, j/k can
  // walk the selection off-screen — wifi uses ListView.positionViewAtIndex
  // for this; we don't have that affordance with a multi-section Column.
  function resetScroll() {
    var scrollArea = panel.loadedContent ? panel.loadedContent.scrollArea : null
    if (!scrollArea) return
    var flick = scrollArea.contentItem
    if (flick && flick.contentY !== undefined) flick.contentY = 0
  }

  function ensureCursorVisible(item) {
    var scrollArea = panel.loadedContent ? panel.loadedContent.scrollArea : null
    if (!item || !scrollArea) return
    var flick = scrollArea.contentItem
    if (!flick || flick.contentY === undefined) return
    var margin = 6
    var maxY = Math.max(0, (flick.contentHeight || 0) - flick.height)
    if (maxY <= Style.space(24) || (root.focusSection === "output" && root.selectedIndex === -1)) {
      flick.contentY = 0
      return
    }
    var pt = item.mapToItem(flick.contentItem || flick, 0, 0)
    var top = pt.y
    var bottom = top + (item.height || 0)
    var viewTop = flick.contentY
    var viewBottom = viewTop + flick.height
    if (top < viewTop + margin) flick.contentY = Math.max(0, Math.min(maxY, top - margin))
    else if (bottom > viewBottom - margin)
      flick.contentY = Math.max(0, Math.min(maxY, bottom + margin - flick.height))
  }

  function clampCursor() {
    var sections = visibleSections
    if (!sections || !sections.length) return
    // "header" is virtual and never appears in visibleSections, so it has to
    // be let through: muting republishes the PipeWire snapshot, and clamping
    // would knock the cursor off the hero switch on every toggle.
    if (focusSection === "header") return
    if (sections.indexOf(focusSection) < 0) {
      focusSection = visibleSections[0]
      selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
      return
    }
    var count = sectionCount(focusSection)
    var hasSlider = sectionHasSlider(focusSection)
    var floor = hasSlider ? -1 : 0
    if (selectedIndex > count - 1) selectedIndex = Math.max(floor, count - 1)
    if (selectedIndex < floor) selectedIndex = floor
  }

  function outputIcon(volume) {
    // Match the old Waybar pulseaudio glyph set. The Material Design speaker
    // icons render visually smaller in JetBrainsMono Nerd Font.
    if (!sink || !sink.audio) return ""
    if (isHeadphones(sink)) return "󰋋"
    if (outputMuted) return ""
    var v = volume === undefined ? outputVolume : volume
    if (v >= 0.67) return ""
    if (v >= 0.34) return ""
    if (v > 0) return ""
    return ""
  }

  function inputIcon() {
    if (!hasInput) return "󰍭"
    return inputMuted ? "󰍭" : "󰍬"
  }

  // Playful mood-name for a given output volume; bands are wide enough
  // that small tweaks don't rename the room you're in.
  function outputVolumeName(volume, muted) {
    return Model.outputVolumeName(volume, muted, Commons.I18n.t)
  }

  function setOutputVolume(v) {
    if (!volumeSink || !volumeSink.audio) return outputVolume
    var volume = Math.max(0, Math.min(1, v))
    volumeSink.audio.volume = volume
    return volume
  }

  function showVolumeOsd(volume) {
    if (!bar || !bar.shell) return
    bar.shell.summon("omarchy.osd", JSON.stringify({
      icon: outputIcon(volume),
      value: Math.round(volume * 100)
    }))
  }

  function setInputVolume(v) {
    if (inputViaWpctl) {
      UntypedInput.setVolume(v)
      return
    }
    if (!source || !source.audio) return
    source.audio.volume = Math.max(0, Math.min(1, v))
  }

  function toggleOutputMute() {
    if (volumeSink && volumeSink.audio) volumeSink.audio.muted = !volumeSink.audio.muted
  }

  function toggleInputMute() {
    if (inputViaWpctl) {
      if (UntypedInput.known) UntypedInput.setMuted(!UntypedInput.muted)
    }
    else if (source && source.audio) source.audio.muted = !source.audio.muted
  }

  // The hero switch is the whole panel's on/off, so it carries both channels
  // at once. It reads as on while anything is still audible, which keeps
  // muting a single channel from the row below flipping the master switch.
  function toggleAllMuted() {
    var mute = anyAudible
    if (hasOutput) volumeSink.audio.muted = mute
    if (hasInput && inputViaWpctl) UntypedInput.setMuted(mute)
    else if (hasInput) source.audio.muted = mute
  }

  function setDefaultSink(node) {
    if (!node) return
    Pipewire.preferredDefaultAudioSink = node
    if (node.id !== undefined && node.name) {
      Quickshell.execDetached([
        "omarchy-audio-output-set-default",
        String(node.id),
        String(node.name)
      ])
    }
  }

  function setDefaultSource(node) {
    if (!node) return
    // Quickshell refuses an untyped node; the command below still selects it.
    if (node.audio) Pipewire.preferredDefaultAudioSource = node
    if (node.id !== undefined && node.name) {
      Quickshell.execDetached([
        "omarchy-audio-input-set-default",
        String(node.id),
        String(node.name)
      ])
    }
  }

  function sinkAvailable(node) {
    if (!node || !node.name || !sinkAvailabilityLoaded) return true
    var name = String(node.name)
    return sinkAvailability[name] !== false
  }

  function updateSinkAvailability(raw) {
    sinkAvailability = Model.parseSinkAvailability(raw)
    sinkAvailabilityLoaded = true
  }

  function friendlyDeviceLabel(text) {
    return Model.friendlyDeviceLabel(text)
  }

  function nodeLabel(node) {
    return Model.nodeLabel(node, Commons.I18n.t)
  }

  function nodeProps(node) {
    return Model.nodeProps(node)
  }

  function isHeadphones(node) {
    return Model.isHeadphones(node)
  }

  function sinkGlyph(node) {
    return Model.sinkGlyph(node)
  }

  function sourceGlyph(node) {
    return Model.sourceGlyph(node)
  }

  function friendlyStreamLabel(label) {
    return Model.friendlyStreamLabel(label)
  }

  function streamLabelKey(label) {
    return Model.streamLabelKey(label)
  }

  function streamLabelIsGeneric(label) {
    return Model.streamLabelIsGeneric(label)
  }

  function rawStreamLabel(node) {
    return Model.rawStreamLabel(node)
  }

  function mprisPlayerLabel(player) {
    return Model.mprisPlayerLabel(player)
  }

  function mprisPlayerIsProxy(player) {
    return Model.mprisPlayerIsProxy(player)
  }

  function streamRepresentsMprisPlayer(streamLabel, playerLabel) {
    return Model.streamRepresentsMprisPlayer(streamLabel, playerLabel)
  }

  function mprisLabelsFor(predicate) {
    return Model.mprisLabelsFor(mprisPlayers, predicate)
  }

  function matchingMprisStreamLabel(label) {
    return Model.matchingMprisStreamLabel(label, mprisPlayers)
  }

  function unmatchedMprisStreamLabel(label) {
    // Spotify exposes its PipeWire stream as "audio-src". For generic stream
    // names, use the one MPRIS player not already represented by another audio
    // stream (e.g. Chromium, or ALSA apps like cliamp).
    return Model.unmatchedMprisStreamLabel(label, mprisPlayers, audioStreams)
  }

  // This reads the other streams' node properties, so it takes the live list --
  // app rows carry primitives now, and resolving each one back would only
  // rebuild what audioStreams already is.
  function streamRepresentsPlayer(node, player) {
    return Model.streamRepresentsPlayer(node, player, mprisPlayers, audioStreams)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  PwObjectTracker { objects: root.candidateSinks }
  PwObjectTracker { objects: root.candidateSources }
  PwObjectTracker { objects: root.audioStreams }

  PwNodePeakMonitor {
    id: inputPeakMonitor
    node: root.inputPeakNode
    enabled: root.opened && !!root.inputPeakNode
  }

  Process {
    id: sinkAvailabilityProc
    command: ["omarchy-audio-sink-availability"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateSinkAvailability(text)
    }
  }

  Process {
    id: sourceAvailabilityProc
    command: ["omarchy-audio-sink-availability", "sources"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.sourceAvailability = Model.parseSinkAvailability(text)
    }
  }

  Process {
    id: volumeSinkProc
    command: ["omarchy-audio-output-sink"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (root.volumeSinkRequest === root.volumeSinkGeneration) root.volumeSinkName = String(text).trim()
      }
    }
    onExited: {
      if (!root.volumeSinkStale) return
      root.volumeSinkStale = false
      // Deferred: the process still reports running while it signals exit.
      Qt.callLater(root.resolveVolumeSink)
    }
  }

  // Routing state lives in WirePlumber's default metadata object. The read is
  // tied to the generation of the last click, so a slow snapshot cannot put an
  // old target back on screen after a newer one was chosen.
  Process {
    id: routeWriteProc
    onExited: function(exitCode, exitStatus) {
      if (exitCode !== 0 || exitStatus !== 0)
        console.warn("audio route write failed", exitCode, exitStatus)
      Qt.callLater(root.runNextRoute)
    }
  }

  Process {
    id: routeTargetsProc
    property int generation: 0
    property bool outputFinished: true
    command: ["pw-metadata", "-n", "default"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.acceptRouteSnapshot(text, routeTargetsProc.generation)
        routeTargetsProc.outputFinished = true
        if (root.routeRefreshPending) Qt.callLater(routeTargetsProc.restart)
      }
    }
    onExited: {
      routeTargetsProc.outputFinished = true
      if (root.routeRefreshPending) Qt.callLater(restart)
    }

    function restart() {
      if (!root.opened || routeWriteProc.running || Object.keys(root.pendingRoutes).length > 0) return
      if (running || !outputFinished) {
        root.routeRefreshPending = true
        return
      }
      root.routeRefreshPending = false
      generation = root.routeGeneration
      outputFinished = false
      running = true
    }
  }

  // Another mixer or a session manager handover can change a pin while the
  // panel is open, so the labels follow the metadata instead of only our writes.
  Process {
    id: routeChangesProc
    running: root.opened
    command: ["pw-metadata", "-n", "default", "-m"]
    stdout: SplitParser {
      onRead: data => routeTargetsProc.restart()
    }
  }

  Timer {
    interval: 5000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!sinkAvailabilityProc.running) sinkAvailabilityProc.running = true
      if (!sourceAvailabilityProc.running) sourceAvailabilityProc.running = true
    }
  }

  // Runs whether or not the panel is open: the bar shows and scrolls the output
  // volume too, so an unresolved sink there would read and change the virtual
  // tuning sink instead of the speakers. Streams starting and stopping also
  // change the graph, so a burst of changes resolves once.
  Timer {
    id: volumeSinkResolveTimer
    interval: 500
    onTriggered: root.resolveVolumeSink()
  }

  Component.onCompleted: root.resolveVolumeSink()

  Timer {
    id: audioModelRefreshTimer
    interval: 75
    repeat: false
    onTriggered: root.refreshDisplayAudioModels()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.outputIcon()
    onPressed: function(b) {
      if (b === Qt.RightButton) root.toggleAllMuted()
      else root.toggle()
    }

    onWheelMoved: function(delta) {
      if (!root.hasOutput) return
      var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
      root.wheelAccumulator = wheel.remainder
      if (wheel.steps === 0) return
      var volume = root.setOutputVolume(root.outputVolume + wheel.steps * 0.05)
      root.showVolumeOsd(volume)
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(620))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias scrollArea: scrollArea
      implicitHeight: panelColumn.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.adjustVolume(dx * 0.05)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        // 'o' sends the focused application to the next output device. The
        // cycle starts with "follow default", so pressing it again is the way
        // back to automatic routing.
        if (t === "o" || t === "O") {
          if (!root.cursorActive) return
          if (root.focusSection === "apps" && root.selectedIndex >= 0
              && root.selectedIndex < root.displayAudioApps.length)
            root.cycleAppRoute(root.displayAudioApps[root.selectedIndex])
          return
        }
        // 'm' mutes whatever the cursor is on: focused section's slider
        // for output/input, the focused application for apps.
        if (t === "m" || t === "M") {
          if (!root.cursorActive) return
          if (root.focusSection === "apps" && root.selectedIndex >= 0
              && root.selectedIndex < root.displayAudioApps.length) {
            root.toggleAppMuted(root.displayAudioApps[root.selectedIndex])
          } else if (root.focusSection === "input") {
            root.toggleInputMute()
          } else {
            root.toggleOutputMute()
          }
        }
      }

      ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        Binding {
          target: scrollArea.contentItem
          property: "interactive"
          value: panelColumn.implicitHeight > scrollArea.height
        }

        Column {
          id: panelColumn
          // Keep the always-on bar off the rows when the panel overflows;
          // mirrored, the bar is on the left.
          width: scrollArea.availableWidth - (scrollArea.ScrollBar.vertical.policy === ScrollBar.AlwaysOn ? scrollArea.ScrollBar.vertical.width : 0)
          x: scrollArea.mirrored ? scrollArea.availableWidth - width : 0
          spacing: Style.space(14)

          // ---------- Hero: speaker icon · title/status ----------
          Item {
            id: heroItem
            width: parent.width
            implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)

            // Status only — the switch owns muting, mouse and keyboard alike.
            Text {
              id: heroIcon
              textFormat: Text.PlainText
              text: root.outputIcon()
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.display
              opacity: root.outputMuted ? 0.5 : 1.0
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            // Compact on/off switch on the trailing edge of the hero, and the
            // header's only cursor target. Checked means something is still
            // audible, so muting everything reads as switching audio off.
            ToggleSwitch {
              id: powerSwitch
              checked: root.anyAudible
              hasCursor: root.headerHasCursor
              foreground: root.bar.foreground
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              onHovered: function(on) { if (on) root.setHeaderCursor() }
              onToggled: root.toggleAllMuted()

              PanelToolTip {
                visible: powerSwitch.containsMouse
                text: root.toggleHint
                fontFamily: root.bar.fontFamily
              }
            }

            Column {
              id: heroLabels
              anchors.left: heroIcon.right
              anchors.leftMargin: Style.space(14)
              anchors.right: parent.right
              anchors.rightMargin: powerSwitch.width + Style.space(12)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: Commons.I18n.t("audio.title")
                textFormat: Text.PlainText
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              Text {
                id: heroLabel
                textFormat: Text.PlainText
                text: root.outputVolumeName(
                  outputSlider.dragging ? outputSlider.liveValue : root.outputVolume,
                  root.outputMuted
                ).toUpperCase()
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
                elide: Text.ElideRight
                width: parent.width
              }
            }
          }

          // ---- Output devices ----
          PanelSeparator {
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Item {
              width: parent.width
              implicitHeight: Math.max(outputHeader.implicitHeight, outputPercent.implicitHeight)

              PanelSectionHeader {
                id: outputHeader
                text: Commons.I18n.t("audio.output")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: outputPercent
                textFormat: Text.PlainText
                text: Commons.I18n.formatNumber(Math.round((outputSlider.dragging ? outputSlider.liveValue : root.outputVolume) * 100)) + "%"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.outputMuted ? 0.5 : 1.0
              }
            }

            CursorSurface {
              id: outputSliderRow
              width: parent.width
              height: outputSlider.implicitHeight + Style.spacing.controlGap
              hasCursor: root.cursorActive && root.focusSection === "output" && root.selectedIndex === -1
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(outputSliderRow)
              foreground: root.bar.foreground
              outline: true

              PanelSlider {
                id: outputSlider
                bar: root.bar
                anchors.fill: parent
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                minimum: 0
                maximum: 1
                step: 0.05
                value: root.outputVolume
                opacity: root.outputMuted ? 0.5 : 1.0
                enabled: !!root.sink

                onMoved: function(v) { root.setOutputVolume(v) }
                onRightClicked: root.toggleOutputMute()
              }

              HoverHandler {
                onHoveredChanged: if (hovered) {
                  root.cursorActive = true
                  root.focusSection = "output"
                  root.selectedIndex = -1
                }
              }
            }

            Repeater {
              model: root.displayAudioSinks

              SinkRow {
                required property var modelData
                required property int index
                width: panelColumn.width
                node: root.nodeFor(modelData)
                rowIndex: index
              }
            }
          }

          // ---- Input ----
          PanelSeparator {
            visible: root.displayAudioSources.length > 0 || !!root.source
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(6)
            visible: root.displayAudioSources.length > 0 || !!root.source

            Item {
              width: parent.width
              implicitHeight: Math.max(microphoneHeader.implicitHeight, microphonePercent.implicitHeight)

              PanelSectionHeader {
                id: microphoneHeader
                text: Commons.I18n.t("audio.input")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                id: microphonePercent
                textFormat: Text.PlainText
                text: root.inputLevelKnown ? Commons.I18n.formatNumber(Math.round((inputSlider.dragging ? inputSlider.liveValue : root.inputVolume) * 100)) + "%" : "–"
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.inputMuted ? 0.5 : 1.0
              }
            }

            CursorSurface {
              id: inputSliderRow
              visible: !!root.source
              width: parent.width
              height: inputControls.implicitHeight + Style.spacing.controlGap
              hasCursor: root.cursorActive && root.focusSection === "input" && root.selectedIndex === -1
              onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(inputSliderRow)
              foreground: root.bar.foreground
              outline: true

              Column {
                id: inputControls
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                // Alone, the slider centres in the row the way the output slider does.
                anchors.topMargin: root.inputLevelShown ? 0 : Style.spacing.controlGap / 2
                spacing: Style.space(5)

                PanelSlider {
                  id: inputSlider
                  bar: root.bar
                  width: parent.width
                  minimum: 0
                  maximum: 1
                  step: 0.05
                  value: root.inputVolume
                  opacity: root.inputMuted ? 0.5 : 1.0
                  enabled: !!root.source

                  onMoved: function(v) { root.setInputVolume(v) }
                  onRightClicked: root.toggleInputMute()
                }

                Rectangle {
                  visible: root.inputLevelShown
                  width: parent.width
                  height: Math.max(Style.space(5), Style.spacing.xs)
                  color: Util.alpha(root.bar.foreground, 0.18)
                  opacity: root.inputMuted ? 0.35 : 1.0

                  Rectangle {
                    height: parent.height
                    width: parent.width * Math.max(0, Math.min(1, inputPeakMonitor.peak))
                    color: root.bar.foreground
                    Behavior on width { NumberAnimation { duration: Style.duration(70) } }
                  }
                }
              }

              HoverHandler {
                onHoveredChanged: if (hovered) {
                  root.cursorActive = true
                  root.focusSection = "input"
                  root.selectedIndex = -1
                }
              }
            }

            Repeater {
              model: root.displayAudioSources

              SourceRow {
                required property var modelData
                required property int index
                width: panelColumn.width
                node: root.nodeFor(modelData)
                rowIndex: index
              }
            }
          }

          // ---- Applications playing audio ----
          PanelSeparator {
            visible: root.displayAudioApps.length > 0
            foreground: root.bar.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(10)
            visible: root.displayAudioApps.length > 0

            Item {
              width: parent.width
              implicitHeight: appsHeader.implicitHeight

              PanelSectionHeader {
                id: appsHeader
                text: Commons.I18n.t("audio.apps")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: Commons.I18n.formatNumber(root.displayAudioApps.length)
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Repeater {
              model: root.displayAudioApps

              AppRow {
                required property var modelData
                required property int index
                width: panelColumn.width
                app: modelData
                rowIndex: index
              }
            }
          }
        }
      }
    }
  }

  // ---- Reusable inline components ----

  // Output device row — cursor target inside the "output" section. Mouse
  // hover updates the panel cursor at the root; visuals come entirely
  // from hasCursor/current via CursorSurface, never from containsMouse.
  component SinkRow: CursorSurface {
    id: sinkRow
    required property var node
    required property int rowIndex

    readonly property bool isActive: root.sink && node && root.sink.id === node.id
    hasCursor: root.cursorActive && root.focusSection === "output" && root.selectedIndex === rowIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(sinkRow)
    current: isActive
    foreground: root.bar.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill
    implicitHeight: sinkInner.implicitHeight + Style.spacing.xl

    Row {
      id: sinkInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: root.sinkGlyph(sinkRow.node)
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.title
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        textFormat: Text.PlainText
        text: root.nodeLabel(sinkRow.node)
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: sinkRow.isActive
        elide: Text.ElideRight
        width: parent.width - Style.space(22) - Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onContainsMouseChanged: if (containsMouse) {
        root.cursorActive = true
        root.focusSection = "output"
        root.selectedIndex = sinkRow.rowIndex
      }
      onClicked: root.setDefaultSink(sinkRow.node)
    }
  }

  // Input device row — sibling of SinkRow for the "input" section.
  component SourceRow: CursorSurface {
    id: sourceRow
    required property var node
    required property int rowIndex

    readonly property bool isActive: root.source && node && root.source.id === node.id
    hasCursor: root.cursorActive && root.focusSection === "input" && root.selectedIndex === rowIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(sourceRow)
    current: isActive
    foreground: root.bar.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill
    implicitHeight: sourceInner.implicitHeight + Style.spacing.xl

    Row {
      id: sourceInner
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: root.sourceGlyph(sourceRow.node)
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.title
        width: Style.space(22)
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        textFormat: Text.PlainText
        text: root.nodeLabel(sourceRow.node)
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: sourceRow.isActive
        elide: Text.ElideRight
        width: parent.width - Style.space(22) - Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onContainsMouseChanged: if (containsMouse) {
        root.cursorActive = true
        root.focusSection = "input"
        root.selectedIndex = sourceRow.rowIndex
      }
      onClicked: root.setDefaultSource(sourceRow.node)
    }
  }

  // One application in the mixer — cursor target inside the "apps" section.
  // The app has its own slider inline, so h/l from the keyboard adjusts the
  // whole application (every stream it owns) when the cursor sits on this
  // row. Enter/Space or the speaker glyph mutes the application.
  component AppRow: CursorSurface {
    id: appRow
    required property var app
    required property int rowIndex

    readonly property var appNodes: root.nodesForApp(app)
    readonly property real appVolume: Model.groupVolume(appNodes)
    readonly property bool appMuted: Model.groupMuted(appNodes)
    readonly property string appIcon: root.appIconSource(appNodes)
    readonly property string appName: root.appDisplayLabel(appNodes)
    readonly property var appWorkspaces: Model.groupWorkspaces(appNodes, root.workspaceWindows)
    readonly property string appWorkspaceLabel: Model.workspaceShortLabel(appWorkspaces, Commons.I18n.formatNumber)
    readonly property string appWorkspaceTip: Model.workspaceTooltip(appWorkspaces, Commons.I18n.t, Commons.I18n.formatNumber)
    readonly property var primaryNode: appNodes.length > 0 ? appNodes[0] : null
    readonly property bool routePinned: root.routePinnedFor(appNodes)
    readonly property var linkedSink: appLinks.linkGroups.length > 0 ? appLinks.linkGroups[0].target : null
    readonly property string routeLabel: Model.routeLabel(primaryNode, root.audioSinks, linkedSink, root.routeTargets, Commons.I18n.t)
    readonly property string routeShortLabel: Model.routePinnedLabel(primaryNode, root.audioSinks, root.routeTargets, Commons.I18n.t)
    readonly property string appInitial: {
      var label = String(appName || "").trim()
      return label ? label.charAt(0).toUpperCase() : "?"
    }
    readonly property bool isActive: {
      for (var i = 0; i < appNodes.length; i++)
        if (root.streamRepresentsPlayer(appNodes[i], root.activeMediaPlayer)) return true
      return false
    }

    PwNodeLinkTracker {
      id: appLinks
      node: appRow.primaryNode
    }

    hasCursor: root.cursorActive && root.focusSection === "apps" && root.selectedIndex === rowIndex
    onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(appRow)
    current: isActive
    foreground: root.bar.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill
    implicitHeight: appColumn.implicitHeight + Style.spacing.xl

    Column {
      id: appColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(2)

      Row {
        width: parent.width
        spacing: Style.space(4)

        // Identity only: muting belongs to the speaker glyph at the end of the
        // row, so clicking the artwork cannot silently silence an application.
        Item {
          id: appIconItem
          width: Style.space(24)
          height: Style.space(24)
          anchors.verticalCenter: parent.verticalCenter
          opacity: appRow.appMuted ? 0.5 : 1.0

          Image {
            id: appIconImage
            anchors.fill: parent
            source: appRow.appIcon
            visible: appRow.appIcon !== ""
            fillMode: Image.PreserveAspectFit
            sourceSize.width: Math.round(Style.space(24) * 2)
            sourceSize.height: Math.round(Style.space(24) * 2)
            smooth: true
          }

          Rectangle {
            anchors.fill: parent
            visible: !appIconImage.visible
            radius: Style.spacing.labelGap
            color: Util.alpha(root.bar.foreground, 0.12)

            Text {
              anchors.centerIn: parent
              textFormat: Text.PlainText
              text: appRow.appInitial
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }
        }

        Column {
          id: appLabels
          width: parent.width - appIconItem.width - appPct.width - appMute.width
            - (appRoute.visible ? appRoute.width + Style.space(4) : 0) - Style.space(12)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(1)

          // The name and the workspace it lives on read together; a drop to a
          // second line only happens when the app has a track to name.
          Row {
            width: parent.width
            spacing: Style.space(4)

            Text {
              id: appLabel
              textFormat: Text.PlainText
              text: appRow.appName
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: appRow.isActive
              elide: Text.ElideRight
              width: parent.width - (appWorkspace.visible ? appWorkspace.width + parent.spacing : 0)
            }

            // Where the application lives: a quiet workspace badge beside the
            // name, so two players of the same name stay tellable apart.
            Item {
              id: appWorkspace
              visible: appRow.appWorkspaceLabel !== ""
              width: visible ? appWorkspaceRow.implicitWidth + Style.space(10) : 0
              height: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter

              Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Util.alpha(root.bar.foreground, workspaceHover.hovered ? 0.12 : 0.07)

                Behavior on color {
                  ColorAnimation { duration: Style.duration(120); easing.type: Easing.InOutQuad }
                }
              }

              Row {
                id: appWorkspaceRow
                anchors.centerIn: parent
                spacing: Style.space(3)

                Text {
                  textFormat: Text.PlainText
                  text: "󱂬"
                  color: Util.alpha(root.bar.foreground, 0.5)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: appRow.appWorkspaceLabel
                  color: Util.alpha(root.bar.foreground, 0.7)
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              HoverHandler { id: workspaceHover }

              PanelToolTip {
                visible: workspaceHover.hovered
                text: appRow.appWorkspaceTip
                fontFamily: root.bar.fontFamily
              }
            }
          }
        }

        // The route pill is the mouse's way to move this application between
        // outputs. It stays compact so the row keeps one line; the tooltip
        // spells out the full device name, which the pill may have to elide.
        Item {
          id: appRoute
          visible: root.audioSinks.length > 1 || appRow.routePinned
          width: visible ? Math.min(Style.space(112), routeRow.implicitWidth + Style.space(14)) : 0
          height: Style.space(22)
          anchors.verticalCenter: parent.verticalCenter

          Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: appRow.routePinned
              ? Util.alpha(root.bar.foreground, routeHover.hovered ? 0.2 : 0.14)
              : Util.alpha(root.bar.foreground, routeHover.hovered ? 0.12 : 0.06)
            border.width: appRow.routePinned ? Math.max(1, Style.space(1)) : 0
            border.color: Util.alpha(root.bar.foreground, 0.35)

            Behavior on color { ColorAnimation { duration: Style.duration(120) } }
          }

          Row {
            id: routeRow
            anchors.centerIn: parent
            spacing: Style.space(4)

            Text {
              textFormat: Text.PlainText
              text: appRow.routePinned ? "\udb81\udd31" : "\udb80\udc54"
              color: Qt.darker(root.bar.foreground, appRow.routePinned ? 1.1 : 1.5)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: appRow.routeShortLabel
              color: Qt.darker(root.bar.foreground, appRow.routePinned ? 1.1 : 1.5)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              width: Math.min(implicitWidth, Style.space(72))
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          HoverHandler {
            id: routeHover
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.cycleAppRoute(appRow.app)
          }

          PanelToolTip {
            visible: routeHover.hovered
            text: appRow.routeLabel
            fontFamily: root.bar.fontFamily
          }
        }

        Text {
          id: appPct
          textFormat: Text.PlainText
          text: Commons.I18n.formatNumber(Math.round(appRow.appVolume * 100)) + "%"
          color: Qt.darker(root.bar.foreground, 1.5)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
          width: Math.ceil(appPctMetrics.advanceWidth)
          horizontalAlignment: Text.AlignLeft
          anchors.verticalCenter: parent.verticalCenter
          opacity: appRow.appMuted ? 0.5 : 1.0
        }

        Text {
          id: appMute
          textFormat: Text.PlainText
          text: appRow.appMuted ? "󰝟" : "󰕾"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.title
          width: Style.space(18)
          horizontalAlignment: Text.AlignHCenter
          anchors.verticalCenter: parent.verticalCenter
          opacity: appRow.appMuted ? 0.5 : 1.0

          MouseArea {
            id: appMuteMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleAppMuted(appRow.app)
          }

          PanelToolTip {
            visible: appMuteMouse.containsMouse
            text: appRow.appMuted ? Commons.I18n.t("audio.unmute") : Commons.I18n.t("audio.mute")
            fontFamily: root.bar.fontFamily
          }
        }
      }

      PanelSlider {
        bar: root.bar
        width: parent.width
        minimum: 0
        maximum: 1
        step: 0.05
        value: appRow.appVolume
        opacity: appRow.appMuted ? 0.5 : 1.0

        onMoved: function(v) { root.setAppVolume(appRow.app, v) }
        onRightClicked: root.toggleAppMuted(appRow.app)
      }
    }

    // A handler rather than a row-sized MouseArea: an area declared after the
    // inline slider sits on top of it and eats its press and drag, which is the
    // bug the standalone slider rows already avoid by using HoverHandler.
    HoverHandler {
      onHoveredChanged: if (hovered) root.setAppCursor(appRow.rowIndex)
    }
  }
}
