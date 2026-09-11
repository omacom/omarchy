import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Commons
import "SpaceBeachModel.js" as SpaceBeachModel

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null
  property var service: null

  property bool opened: false
  property string mode: "chronicle"
  property bool followingLive: true
  property int snapshotIndex: -1
  property int selectedWindowIndex: 0
  property int selectedGameIndex: 0
  property bool revealPreview: false
  property var revealedIdentity: null
  property bool reduceMotion: false
  property string confirmation: ""
  property var pendingPlan: null
  property var tideRun: null
  property string statusMessage: ""
  property var targetScreen: null

  property real cpuPercent: 0
  property real memoryPercent: 0
  property real loadAverage: 0
  property real previousCpuIdle: -1
  property real previousCpuTotal: -1

  readonly property var currentSnapshot: root.service && root.service.currentSnapshot
    ? root.service.currentSnapshot : ({ at: Date.now(), reason: "live", windows: [], workspaces: [] })
  readonly property var journal: root.service && Array.isArray(root.service.journal)
    ? root.service.journal : []
  readonly property var scenes: root.service && Array.isArray(root.service.scenes)
    ? root.service.scenes : []
  readonly property string recordingMode: root.service && root.service.recordingMode !== undefined
    ? String(root.service.recordingMode) : "off"
  readonly property bool stateReady: root.service && root.service.stateLoaded === true
  readonly property bool consentRequired: root.service && root.service.consentRequired === true
  readonly property string serviceError: root.service && root.service.lastError
    ? String(root.service.lastError) : ""
  readonly property bool durabilityPending: root.service && (root.service.persistPending === true
    || root.service.stateWriteInFlight === true || root.service.stateRemovalPending === true
    || root.service.historyEraseInFlight === true)
  readonly property var timelineEntries: root.buildTimeline()
  readonly property var timelineTicks: root.buildTimelineTicks()
  readonly property var displayedSnapshot: root.snapshotForIndex(root.snapshotIndex)
  readonly property var flatWindows: root.windowsFor(root.displayedSnapshot)
  readonly property var workspaceGroups: root.groupWorkspaces(root.displayedSnapshot)
  readonly property var selectedWindow: root.flatWindows.length > 0
    ? root.flatWindows[Math.max(0, Math.min(root.selectedWindowIndex, root.flatWindows.length - 1))] : null
  readonly property var diffData: root.calculateDiff(root.displayedSnapshot, root.currentSnapshot)
  readonly property bool viewingLive: root.snapshotIndex === root.timelineEntries.length - 1

  function snapshotPayload(entry) {
    if (!entry) return ({ at: Date.now(), reason: "empty", windows: [], workspaces: [] })
    return entry.snapshot || entry
  }

  function buildTimeline() {
    var entries = []
    for (var i = 0; i < root.journal.length; i++) {
      var source = root.journal[i] || {}
      entries.push({
        index: i,
        live: false,
        reason: String(source.reason || (source.snapshot && source.snapshot.reason) || "checkpoint"),
        snapshot: root.snapshotPayload(source)
      })
    }
    entries.push({
      index: entries.length,
      live: true,
      reason: "live shore",
      snapshot: root.currentSnapshot
    })
    return entries
  }

  function buildTimelineTicks() {
    var count = root.timelineEntries.length
    var maximum = 48
    var ticks = []
    if (count <= maximum) {
      for (var i = 0; i < count; i++) ticks.push({ sourceIndex: i })
      return ticks
    }
    for (var t = 0; t < maximum; t++)
      ticks.push({ sourceIndex: Math.round(t * (count - 1) / (maximum - 1)) })
    return ticks
  }

  function selectedTimelineTick() {
    if (root.timelineTicks.length <= 1 || root.timelineEntries.length <= 1) return 0
    return Math.round(root.snapshotIndex * (root.timelineTicks.length - 1) / (root.timelineEntries.length - 1))
  }

  function snapshotForIndex(index) {
    if (root.timelineEntries.length === 0) return root.currentSnapshot
    var safe = Math.max(0, Math.min(Number(index), root.timelineEntries.length - 1))
    if (!isFinite(safe)) safe = root.timelineEntries.length - 1
    return root.snapshotPayload(root.timelineEntries[safe])
  }

  function workspaceIdFor(windowData) {
    if (!windowData) return "?"
    if (windowData.workspaceId !== undefined) return String(windowData.workspaceId)
    if (windowData.workspace && windowData.workspace.id !== undefined) return String(windowData.workspace.id)
    if (windowData.workspace !== undefined) return String(windowData.workspace)
    if (windowData.workspaceName !== undefined) return String(windowData.workspaceName)
    return "?"
  }

  function canonicalAddress(value) {
    return String(value || "").toLowerCase().replace(/^0x/, "")
  }

  function windowIsLive(windowData, snapshot) {
    if (snapshot !== root.currentSnapshot) {
      var targetSession = String(snapshot && snapshot.sessionId || "")
      var currentSession = String(root.currentSnapshot && root.currentSnapshot.sessionId || "")
      var targetObserver = String(snapshot && snapshot.observerId || "")
      var currentObserver = String(root.currentSnapshot && root.currentSnapshot.observerId || "")
      if (!targetSession || targetSession !== currentSession || !targetObserver || targetObserver !== currentObserver) return false
    }
    var address = root.canonicalAddress(windowData && windowData.address)
    var appId = String(windowData && windowData.appId || "")
    var lifecycleId = String(windowData && windowData.lifecycleId || "")
    if (!address || !appId || !lifecycleId) return false
    var windows = root.currentSnapshot && Array.isArray(root.currentSnapshot.windows)
      ? root.currentSnapshot.windows : []
    for (var i = 0; i < windows.length; i++) {
      if (root.canonicalAddress(windows[i].address) === address
          && String(windows[i].appId || "") === appId
          && String(windows[i].lifecycleId || "") === lifecycleId) return true
    }
    return false
  }

  function fidelityFor(windowData, snapshot) {
    if (snapshot === root.currentSnapshot) return "LIVE"
    try {
      var result = SpaceBeachModel.classifyFidelity(
        windowData,
        root.currentSnapshot.windows || [],
        [],
        {
          targetSessionId: String(snapshot && snapshot.sessionId || ""),
          currentSessionId: String(root.currentSnapshot && root.currentSnapshot.sessionId || ""),
          targetObserverId: String(snapshot && snapshot.observerId || ""),
          currentObserverId: String(root.currentSnapshot && root.currentSnapshot.observerId || "")
        }
      )
      return String(result && result.fidelity || "lost").replace(/-/g, " ").toUpperCase()
    } catch (error) {
      return "LOST"
    }
  }

  function windowsFor(snapshot) {
    var source = root.snapshotPayload(snapshot)
    var windows = source && Array.isArray(source.windows) ? source.windows : []
    var out = []
    for (var i = 0; i < windows.length; i++) {
      var copy = {}
      var row = windows[i] || {}
      for (var key in row) copy[key] = row[key]
      copy._flatIndex = i
      copy._liveNow = root.windowIsLive(copy, source)
      copy._fidelity = root.fidelityFor(copy, source)
      out.push(copy)
    }
    return out
  }

  function groupWorkspaces(snapshot) {
    var source = root.snapshotPayload(snapshot)
    var groups = {}
    var order = []
    var workspaces = source && Array.isArray(source.workspaces) ? source.workspaces : []
    var focused = String(source.focusedWorkspaceId !== undefined
      ? source.focusedWorkspaceId : (source.focusedWorkspace || ""))

    for (var i = 0; i < workspaces.length; i++) {
      var ws = workspaces[i] || {}
      var id = String(ws.id !== undefined ? ws.id : (ws.name !== undefined ? ws.name : "?"))
      if (!groups[id]) {
        groups[id] = { id: id, name: String(ws.name !== undefined ? ws.name : id), windows: [], focused: ws.focused === true || id === focused }
        order.push(id)
      }
    }

    var windows = root.windowsFor(source)
    for (var w = 0; w < windows.length; w++) {
      var workspaceId = root.workspaceIdFor(windows[w])
      if (!groups[workspaceId]) {
        var workspaceName = String(windows[w].workspaceName || workspaceId)
        groups[workspaceId] = { id: workspaceId, name: workspaceName, windows: [], focused: workspaceId === focused }
        order.push(workspaceId)
      }
      groups[workspaceId].windows.push(windows[w])
    }

    order.sort(function(a, b) {
      var an = Number(a)
      var bn = Number(b)
      if (isFinite(an) && isFinite(bn)) return an - bn
      return String(a).localeCompare(String(b))
    })

    var result = []
    for (var o = 0; o < order.length; o++) result.push(groups[order[o]])
    return result
  }

  function snapshotWindowCount(snapshot) {
    var source = root.snapshotPayload(snapshot)
    return source && Array.isArray(source.windows) ? source.windows.length : 0
  }

  function snapshotWorkspaceCount(snapshot) {
    var source = root.snapshotPayload(snapshot)
    if (source && Array.isArray(source.workspaces) && source.workspaces.length > 0)
      return source.workspaces.length
    var windows = source && Array.isArray(source.windows) ? source.windows : []
    var seen = ({})
    var count = 0
    for (var i = 0; i < windows.length; i++) {
      var key = root.workspaceIdFor(windows[i])
      if (seen[key]) continue
      seen[key] = true
      count += 1
    }
    return count
  }

  function calculateDiff(thenSnapshot, nowSnapshot) {
    try {
      if (root.service && typeof root.service.diffFor === "function")
        return root.service.diffFor(thenSnapshot)
      if (SpaceBeachModel && typeof SpaceBeachModel.diffSnapshots === "function")
        return SpaceBeachModel.diffSnapshots(thenSnapshot, nowSnapshot)
    } catch (error) {
      console.warn("SpaceBeach diff failed:", error)
    }
    return ({ added: [], removed: [], moved: [], unchanged: [] })
  }

  function diffCount(primary, alternate) {
    var value = root.diffData ? root.diffData[primary] : null
    if (!Array.isArray(value) && alternate) value = root.diffData ? root.diffData[alternate] : null
    return Array.isArray(value) ? value.length : Number(value || 0)
  }

  function timestampFor(snapshot) {
    var source = root.snapshotPayload(snapshot)
    var raw = Number(source.capturedAt || source.at || source.timestamp || source.time || Date.now())
    return isFinite(raw) ? raw : Date.now()
  }

  function timeLabel(snapshot) {
    var date = new Date(root.timestampFor(snapshot))
    return String(date.getHours()).padStart(2, "0") + ":" + String(date.getMinutes()).padStart(2, "0") + ":" + String(date.getSeconds()).padStart(2, "0")
  }

  function dateLabel(snapshot) {
    var date = new Date(root.timestampFor(snapshot))
    return date.toLocaleDateString(Qt.locale(), "ddd d MMM")
  }

  function reasonLabel(entry) {
    if (!entry) return "checkpoint"
    return String(entry.live ? "LIVE SHORE" : (entry.reason || "CHECKPOINT")).replace(/[-_]/g, " ").toUpperCase()
  }

  function setSnapshotIndex(index) {
    root.clearLivePreview()
    var last = root.timelineEntries.length - 1
    root.snapshotIndex = Math.max(0, Math.min(index, last))
    root.followingLive = root.snapshotIndex === last
    root.selectedWindowIndex = 0
  }

  function stepSnapshot(delta) {
    root.setSnapshotIndex(root.snapshotIndex + delta)
  }

  function selectWindow(index) {
    root.clearLivePreview()
    if (root.flatWindows.length === 0) {
      root.selectedWindowIndex = 0
      return
    }
    var count = root.flatWindows.length
    root.selectedWindowIndex = (Number(index) + count) % count
  }

  function showStatus(message) {
    root.statusMessage = String(message || "")
    statusTimer.restart()
  }

  function focusSelectedWindow() {
    if (!root.canFocusSelectedWindow()) {
      root.showStatus("Only an exact vessel in this compositor session can be focused")
      return
    }
    var address = String(root.selectedWindow.address || root.selectedWindow.id || "")
    var appId = String(root.selectedWindow.appId || "")
    var sourceSession = String(root.displayedSnapshot && root.displayedSnapshot.sessionId || "")
    var sourceObserver = String(root.displayedSnapshot && root.displayedSnapshot.observerId || "")
    var lifecycleId = String(root.selectedWindow.lifecycleId || "")
    if (root.service && typeof root.service.focusWindow === "function") {
      if (root.service.focusWindow(address, appId, sourceSession, sourceObserver, lifecycleId)) {
        root.close()
      } else {
        root.showStatus("That exact vessel has already left the shore")
      }
      return
    }
    root.showStatus("Safe focus is unavailable without the SpaceBeach service")
  }

  function canFocusSelectedWindow() {
    if (!root.selectedWindow || root.selectedWindow._liveNow !== true) return false
    var fidelity = String(root.selectedWindow._fidelity || "").toUpperCase()
    if (fidelity !== "EXACT" && fidelity !== "LIVE") return false
    var address = String(root.selectedWindow.address || root.selectedWindow.id || "")
    var appId = String(root.selectedWindow.appId || "")
    var sourceSession = String(root.displayedSnapshot && root.displayedSnapshot.sessionId || "")
    var liveSession = String(root.currentSnapshot && root.currentSnapshot.sessionId || "")
    var sourceObserver = String(root.displayedSnapshot && root.displayedSnapshot.observerId || "")
    var liveObserver = String(root.currentSnapshot && root.currentSnapshot.observerId || "")
    var lifecycleId = String(root.selectedWindow.lifecycleId || "")
    return address.length > 0 && appId.length > 0 && lifecycleId.length > 0
      && sourceSession.length > 0 && sourceSession === liveSession
      && sourceObserver.length > 0 && sourceObserver === liveObserver
  }

  function canRevealLivePreview() {
    if (!root.stateReady || root.consentRequired || root.confirmation.length > 0
        || !root.opened || root.mode !== "chronicle" || !root.viewingLive
        || root.selectedWindow === null || root.selectedWindow._liveNow !== true) return false
    if (root.service && typeof root.service.identityIsCurrent === "function") {
      var revision = root.service.dataRevision
      return revision >= 0 && root.service.identityIsCurrent(
        root.selectedWindow.address,
        root.selectedWindow.appId,
        root.currentSnapshot.sessionId,
        root.currentSnapshot.observerId,
        root.selectedWindow.lifecycleId
      )
    }
    return false
  }

  function selectedPreviewIdentity() {
    if (!root.selectedWindow) return null
    return {
      address: root.canonicalAddress(root.selectedWindow.address),
      appId: String(root.selectedWindow.appId || ""),
      sessionId: String(root.currentSnapshot && root.currentSnapshot.sessionId || ""),
      observerId: String(root.currentSnapshot && root.currentSnapshot.observerId || ""),
      lifecycleId: String(root.selectedWindow.lifecycleId || "")
    }
  }

  function revealedIdentityMatchesSelected() {
    var revealed = root.revealedIdentity
    var selected = root.selectedPreviewIdentity()
    return revealed !== null && selected !== null
      && String(revealed.address || "") === selected.address
      && String(revealed.appId || "") === selected.appId
      && String(revealed.sessionId || "") === selected.sessionId
      && String(revealed.observerId || "") === selected.observerId
      && String(revealed.lifecycleId || "") === selected.lifecycleId
  }

  function livePreviewActive() {
    return root.revealPreview && root.revealedIdentityMatchesSelected() && root.canRevealLivePreview()
  }

  function clearLivePreview() {
    root.revealPreview = false
    root.revealedIdentity = null
  }

  function toggleLivePreview() {
    if (root.livePreviewActive()) {
      root.clearLivePreview()
      return
    }
    if (!root.canRevealLivePreview()) return
    root.revealedIdentity = root.selectedPreviewIdentity()
    root.revealPreview = root.revealedIdentity !== null
  }

  function setRecording(modeName) {
    if (!root.service || typeof root.service.setRecordingMode !== "function"
        || !root.service.setRecordingMode(modeName)) {
      root.showStatus("SpaceBeach is still reading its local tide")
      return
    }
    root.showStatus(modeName === "day" ? "Preparing an ongoing rolling journal on this machine" : (modeName === "session" ? "This voyage stays in memory only" : "The tide is paused"))
  }

  function saveLighthouse() {
    if (!root.service || typeof root.service.saveScene !== "function") return
    var now = new Date()
    var name = "Lighthouse " + String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0")
    root.service.saveScene(name, root.currentSnapshot)
    root.showStatus(name + " lit")
  }

  function deleteLighthouse(sceneId) {
    if (root.service && typeof root.service.deleteScene === "function"
        && root.service.deleteScene(sceneId)) {
      root.showStatus("Lighthouse extinguished")
      Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
      return true
    }
    return false
  }

  function requestRestore(snapshot, force) {
    root.clearLivePreview()
    if ((!force && root.viewingLive) || !snapshot) {
      root.showStatus("You are already standing at the live shore")
      return
    }
    var plan = null
    try {
      if (root.service && typeof root.service.previewRestore === "function")
        plan = root.service.previewRestore(snapshot)
      else if (SpaceBeachModel && typeof SpaceBeachModel.buildRestorePlan === "function")
        plan = SpaceBeachModel.buildRestorePlan(snapshot, root.currentSnapshot)
    } catch (error) {
      console.warn("SpaceBeach restore preview failed:", error)
    }
    root.pendingPlan = plan || ({ moves: [], missing: root.windowsFor(snapshot), exact: [] })
    root.confirmation = "restore"
  }

  function planCount(name) {
    var value = root.pendingPlan ? root.pendingPlan[name] : null
    if (!Array.isArray(value) && root.pendingPlan && root.pendingPlan.summary)
      value = root.pendingPlan.summary[name]
    if (!Array.isArray(value) && (value === undefined || value === null) && name === "missing")
      value = root.pendingPlan ? root.pendingPlan.unresolved : null
    return Array.isArray(value) ? value.length : Number(value || 0)
  }

  function confirmRestore() {
    var result = null
    if (root.service && typeof root.service.confirmRestore === "function")
      result = root.service.confirmRestore(root.pendingPlan)
    else if (root.service && typeof root.service.applyRestorePlan === "function")
      result = root.service.applyRestorePlan(root.pendingPlan, true)
    root.confirmation = ""
    root.pendingPlan = null
    var attempted = result && result.attempted !== undefined ? Number(result.attempted) : 0
    var dispatches = result && result.dispatches !== undefined ? Number(result.dispatches) : attempted
    var error = result && result.error ? String(result.error) : ""
    if (error === "desktop-changed") root.showStatus("Desktop changed after preview; review a fresh restore plan")
    else if (error) root.showStatus("Restore stopped: " + error.replace(/-/g, " "))
    else root.showStatus(attempted === 0
      ? "No compositor placement request was sent"
      : "Attempted placement for " + attempted + " vessel" + (attempted === 1 ? "" : "s") + " with " + dispatches + " compositor request" + (dispatches === 1 ? "" : "s") + "; rollback is available")
  }

  function eraseTide() {
    var started = root.service && typeof root.service.eraseHistory === "function"
      ? root.service.eraseHistory() : false
    root.confirmation = ""
    root.followingLive = true
    root.snapshotIndex = 0
    if (!started) root.showStatus("The tide could not be erased")
    else if (root.service && root.service.historyEraseInFlight)
      root.showStatus("Tide cleared from memory; removing its local file")
    else root.showStatus("The session tide was erased")
  }

  function rollbackRestore() {
    if (!root.service || typeof root.service.rollbackLastRestore !== "function") return
    var result = root.service.rollbackLastRestore()
    var attempted = result && result.attempted !== undefined ? Number(result.attempted) : 0
    var dispatches = result && result.dispatches !== undefined ? Number(result.dispatches) : attempted
    var error = result && result.error ? String(result.error) : ""
    root.showStatus(error
      ? "Rollback stopped: " + error.replace(/-/g, " ")
      : "Rollback attempted " + attempted + " vessel" + (attempted === 1 ? "" : "s") + " with " + dispatches + " compositor request" + (dispatches === 1 ? "" : "s"))
  }

  function deriveGame() {
    try {
      root.tideRun = SpaceBeachModel.deriveTideRun(root.journal)
    } catch (error) {
      console.warn("SpaceBeach Tide Run failed:", error)
      root.tideRun = { ready: false, reason: "The run could not be charted." }
    }
    root.selectedGameIndex = 0
  }

  function gameFleet() {
    if (!root.tideRun) return []
    if (Array.isArray(root.tideRun.fleet)) return root.tideRun.fleet
    if (Array.isArray(root.tideRun.vessels)) return root.tideRun.vessels
    return []
  }

  function gameWaves() {
    return root.tideRun && Array.isArray(root.tideRun.waves) ? root.tideRun.waves : []
  }

  function gameReady() {
    return root.tideRun && root.tideRun.valid !== false && root.tideRun.status !== "invalid" && root.gameWaves().length > 0
  }

  function gameComplete() {
    return root.tideRun && root.tideRun.status === "complete"
  }

  function gameTurn() {
    if (!root.tideRun) return 0
    return Number(root.tideRun.turn !== undefined ? root.tideRun.turn : (root.tideRun.waveIndex || 0))
  }

  function gameScore() {
    if (!root.tideRun) return 0
    return Number(root.tideRun.score !== undefined ? root.tideRun.score : (root.tideRun.coherence || 0))
  }

  function selectedGameVessel() {
    var fleet = root.gameFleet()
    return fleet.length > 0 ? fleet[Math.max(0, Math.min(root.selectedGameIndex, fleet.length - 1))] : null
  }

  function selectedGameVesselIsLive() {
    var vessel = root.selectedGameVessel()
    return vessel !== null && vessel.alive === true
  }

  function selectedGameVesselNeedsRepair() {
    var vessel = root.selectedGameVessel()
    return root.selectedGameVesselIsLive()
      && Number(vessel.integrity) < Number(vessel.maxIntegrity)
  }

  function pendingInterventionKind() {
    return root.tideRun && root.tideRun.pendingIntervention
      ? String(root.tideRun.pendingIntervention.kind || "") : ""
  }

  function waveIsRevealed(index) {
    if (!root.tideRun) return false
    return index < root.gameTurn() || index <= Number(root.tideRun.revealedThrough || 0)
  }

  function waveEventLabel(wave, index) {
    if (!root.waveIsRevealed(index)) return "UNCHARTED"
    var events = wave && Array.isArray(wave.events) ? wave.events : []
    if (events.length === 0) return "CALM"
    var first = String(events[0].kind || "shift").replace(/-/g, " ").toUpperCase()
    return events.length === 1 ? first : first + " +" + (events.length - 1)
  }

  function waveEventDetails(wave, index) {
    if (!root.waveIsRevealed(index)) return "FUTURE WATER UNCHARTED — COMMIT SCAN TO REVEAL IT"
    var events = wave && Array.isArray(wave.events) ? wave.events : []
    if (events.length === 0) return "NO RECORDED EVENT IN THIS WAVE"
    var counts = ({})
    var order = []
    for (var i = 0; i < events.length; i++) {
      var kind = String(events[i].kind || "shift").replace(/-/g, " ").toUpperCase()
      if (counts[kind] === undefined) {
        counts[kind] = 0
        order.push(kind)
      }
      counts[kind] += 1
    }
    var parts = []
    for (var k = 0; k < order.length; k++) parts.push(order[k] + " ×" + counts[order[k]])
    return parts.join("  /  ")
  }

  function intelligenceWaveIndex() {
    var waves = root.gameWaves()
    if (waves.length === 0) return -1
    var revealed = root.tideRun ? Number(root.tideRun.revealedThrough || 0) : 0
    return Math.max(0, Math.min(waves.length - 1, Math.max(root.gameTurn(), revealed)))
  }

  function gameHistory() {
    return root.tideRun && Array.isArray(root.tideRun.history)
      ? root.tideRun.history.slice(-4).reverse() : []
  }

  function gameOutcomeLabel() {
    var outcome = root.tideRun ? String(root.tideRun.outcome || "") : ""
    return outcome ? outcome.replace(/-/g, " ").toUpperCase() : "VOYAGE COMPLETE"
  }

  function applyIntervention(kind) {
    if (!root.gameReady()) return
    var vessel = root.selectedGameVessel()
    var id = vessel ? String(vessel.id || vessel.address || vessel.key || "") : ""
    var requestedKind = root.pendingInterventionKind() === kind ? "none" : kind
    try {
      root.tideRun = SpaceBeachModel.applyIntervention(root.tideRun, requestedKind, id)
    } catch (error) {
      console.warn("SpaceBeach intervention failed:", error)
    }
  }

  function advanceWave() {
    if (!root.gameReady()) return
    try {
      root.tideRun = SpaceBeachModel.advanceTideRun(root.tideRun)
      if (root.gameFleet().length > 0)
        root.selectedGameIndex = Math.max(0, Math.min(root.selectedGameIndex, root.gameFleet().length - 1))
    } catch (error) {
      console.warn("SpaceBeach wave advance failed:", error)
    }
  }

  function switchMode(nextMode) {
    if (nextMode !== "chronicle") root.clearLivePreview()
    root.mode = nextMode
    if (nextMode === "tide" && !root.tideRun) root.deriveGame()
  }

  function parseTelemetry(raw) {
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].split("\t")
      if (parts[0] === "cpu" && parts.length >= 3) {
        var idle = Number(parts[1])
        var total = Number(parts[2])
        if (root.previousCpuTotal >= 0 && total > root.previousCpuTotal) {
          var idleDelta = idle - root.previousCpuIdle
          var totalDelta = total - root.previousCpuTotal
          root.cpuPercent = Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100))
        }
        root.previousCpuIdle = idle
        root.previousCpuTotal = total
      } else if (parts[0] === "memory") {
        root.memoryPercent = Math.max(0, Math.min(100, Number(parts[1]) || 0))
      } else if (parts[0] === "load") {
        root.loadAverage = Math.max(0, Number(parts[1]) || 0)
      }
    }
  }

  function refreshTelemetry() {
    if (!telemetryProc.running) telemetryProc.running = true
  }

  function focusedScreen() {
    var wanted = ""
    try { wanted = String(Hyprland.focusedMonitor && Hyprland.focusedMonitor.name || "") } catch (error) { }
    var screens = Quickshell.screens || []
    for (var i = 0; i < screens.length; i++) {
      if (screens[i] && String(screens[i].name || "") === wanted) return screens[i]
    }
    return screens.length > 0 ? screens[0] : null
  }

  function open(payloadJson) {
    var payload = {}
    if (payloadJson) {
      try { payload = JSON.parse(payloadJson) || {} } catch (error) { payload = {} }
    }
    root.targetScreen = root.focusedScreen()
    root.opened = root.targetScreen !== null
    if (!root.opened) return
    root.clearLivePreview()
    root.switchMode(payload.mode === "tide" ? "tide" : "chronicle")
    if (root.service && typeof root.service.setOverlayOpen === "function") root.service.setOverlayOpen(true)
    if (root.service && typeof root.service.captureNow === "function") root.service.captureNow("opened-spacebeach")
    root.followingLive = true
    root.snapshotIndex = root.timelineEntries.length - 1
    root.selectedWindowIndex = 0
    root.refreshTelemetry()
    Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
    root.clearLivePreview()
    root.confirmation = ""
    keyCatcher.focus = false
    if (root.service && typeof root.service.setOverlayOpen === "function") root.service.setOverlayOpen(false)
  }

  onJournalChanged: {
    if (root.followingLive) root.snapshotIndex = root.timelineEntries.length - 1
  }

  onFlatWindowsChanged: {
    root.clearLivePreview()
    if (root.flatWindows.length === 0) root.selectedWindowIndex = 0
    else if (root.selectedWindowIndex >= root.flatWindows.length) root.selectedWindowIndex = root.flatWindows.length - 1
  }

  onConfirmationChanged: {
    if (root.confirmation.length > 0) root.clearLivePreview()
    else Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }
  onStateReadyChanged: {
    if (!root.stateReady) root.clearLivePreview()
    else Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }
  onConsentRequiredChanged: {
    if (!root.consentRequired) Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  Connections {
    target: root.service
    ignoreUnknownSignals: true
    function onHistoryEraseFinished(success) {
      root.showStatus(success ? "The local tide was erased" : "Local erase failed; check the warning above")
    }
  }

  Timer {
    id: statusTimer
    interval: 3600
    onTriggered: root.statusMessage = ""
  }

  Timer {
    interval: 2000
    repeat: true
    running: root.opened
    triggeredOnStart: true
    onTriggered: root.refreshTelemetry()
  }

  Process {
    id: telemetryProc
    command: ["omarchy-system-stats", "--bar-widget"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseTelemetry(text)
    }
  }

  PanelWindow {
    id: panel
    screen: root.targetScreen
    visible: root.opened && root.targetScreen !== null
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-spacebeach"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    BeachWorld {
      anchors.fill: parent
      voidColor: Color.background
      inkColor: Color.foreground
      accentColor: Color.accent
      mutedColor: Color.muted
      tide: root.memoryPercent / 100
      wind: root.cpuPercent / 100
      running: root.opened
      reduceMotion: root.reduceMotion
    }

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.17)
    }

    FocusScope {
      id: keyCatcher
      anchors.fill: parent
      focus: true

      Keys.priority: Keys.AfterItem
      Keys.onPressed: function(event) {
        if (!root.stateReady) {
          if (event.key === Qt.Key_Escape) root.close()
          else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = false
            return
          }
          event.accepted = true
          return
        }
        if (root.consentRequired) {
          if (event.key === Qt.Key_Escape) root.close()
          else if (event.key === Qt.Key_0) root.setRecording("off")
          else if (event.key === Qt.Key_1) root.setRecording("session")
          else if (event.key === Qt.Key_2) root.setRecording("day")
          else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = false
            return
          }
          event.accepted = true
          return
        }
        if (root.confirmation) {
          if (event.key === Qt.Key_Escape) {
            root.confirmation = ""
            root.pendingPlan = null
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.confirmation === "restore" && root.planCount("moves") > 0) root.confirmRestore()
            else if (root.confirmation === "erase") root.eraseTide()
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = false
            return
          }
          event.accepted = true
          return
        }

        if (event.key === Qt.Key_Escape) {
          root.close()
          event.accepted = true
        } else if (event.key === Qt.Key_G) {
          root.switchMode(root.mode === "chronicle" ? "tide" : "chronicle")
          event.accepted = true
        } else if (event.key === Qt.Key_Left && root.mode === "chronicle") {
          root.stepSnapshot(-1)
          event.accepted = true
        } else if (event.key === Qt.Key_Right && root.mode === "chronicle") {
          root.stepSnapshot(1)
          event.accepted = true
        } else if (event.key === Qt.Key_Up) {
          if (root.mode === "chronicle") root.selectWindow(root.selectedWindowIndex - 1)
          else if (root.gameFleet().length > 0) root.selectedGameIndex = Math.max(0, root.selectedGameIndex - 1)
          event.accepted = true
        } else if (event.key === Qt.Key_Down) {
          if (root.mode === "chronicle") root.selectWindow(root.selectedWindowIndex + 1)
          else if (root.gameFleet().length > 0) root.selectedGameIndex = Math.min(root.gameFleet().length - 1, root.selectedGameIndex + 1)
          event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          if (root.mode === "chronicle") root.focusSelectedWindow()
          else root.advanceWave()
          event.accepted = true
        } else if (event.key === Qt.Key_1 && root.mode === "tide") {
          root.applyIntervention("anchor")
          event.accepted = true
        } else if (event.key === Qt.Key_2 && root.mode === "tide") {
          root.applyIntervention("drift")
          event.accepted = true
        } else if (event.key === Qt.Key_3 && root.mode === "tide") {
          root.applyIntervention("scan")
          event.accepted = true
        } else if (event.key === Qt.Key_4 && root.mode === "tide") {
          root.applyIntervention("repair")
          event.accepted = true
        } else if (event.key === Qt.Key_C) {
          root.saveLighthouse()
          event.accepted = true
        } else if (event.key === Qt.Key_R && root.mode === "chronicle") {
          root.requestRestore(root.displayedSnapshot)
          event.accepted = true
        } else if (event.key === Qt.Key_V && root.canRevealLivePreview()) {
          root.toggleLivePreview()
          event.accepted = true
        } else if (event.key === Qt.Key_M) {
          root.reduceMotion = !root.reduceMotion
          event.accepted = true
        }
      }

      Component.onCompleted: forceActiveFocus()

      ColumnLayout {
        id: mainContent
        anchors.fill: parent
        anchors.margins: Math.max(18, Style.space(22))
        spacing: 13
        enabled: root.stateReady && !root.consentRequired && root.confirmation.length === 0

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          spacing: 14

          ColumnLayout {
            spacing: -2

            Text {
              text: "SPACEBEACH"
              textFormat: Text.PlainText
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.display
              font.weight: Font.DemiBold
              font.letterSpacing: 4
            }

            Text {
              text: root.serviceError ? "WARNING / " + root.serviceError.toUpperCase() : "OMARCHY VISUAL TIME MACHINE  /  THE TIDE REMEMBERS"
              textFormat: Text.PlainText
              color: root.serviceError ? Color.urgent : Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1.35
            }
          }

          Item { Layout.fillWidth: true }

          Rectangle {
            Layout.preferredWidth: localLabel.implicitWidth + 22
            Layout.preferredHeight: 27
            radius: 14
            color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.62)
            border.width: 1
            border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.42)

            Text {
              id: localLabel
              anchors.centerIn: parent
              text: root.recordingMode === "day"
                ? (root.durabilityPending ? "◌ LOCAL / SYNCING" : "● LOCAL / UP TO 24H · 360")
                : (root.recordingMode === "session" ? "● LOCAL / SESSION" : "○ TIDE PAUSED")
              textFormat: Text.PlainText
              color: root.recordingMode === "off" ? Color.muted : Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 1
            }
          }

          BeachButton {
            label: "CHRONICLE"
            shortcut: "G"
            selected: root.mode === "chronicle"
            onClicked: root.switchMode("chronicle")
          }

          BeachButton {
            label: "TIDE RUN"
            shortcut: "G"
            selected: root.mode === "tide"
            onClicked: root.switchMode("tide")
          }

          BeachButton {
            label: "CLOSE"
            shortcut: "ESC"
            onClicked: root.close()
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 13

          Rectangle {
            Layout.preferredWidth: 252
            Layout.fillHeight: true
            radius: 11
            color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.72)
            border.width: 1
            border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.14)

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 14
              spacing: 10

              RowLayout {
                Layout.fillWidth: true

                Text {
                  Layout.fillWidth: true
                  text: "TIDE LOG"
                  textFormat: Text.PlainText
                  color: Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: Font.DemiBold
                  font.letterSpacing: 1.6
                }

                Text {
                  text: String(root.timelineEntries.length).padStart(3, "0")
                  textFormat: Text.PlainText
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                }
              }

              ListView {
                id: tideLog
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: root.timelineEntries
                currentIndex: root.snapshotIndex
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                  id: checkpointRow
                  required property var modelData
                  required property int index
                  width: tideLog.width
                  height: 52
                  activeFocusOnTab: true
                  Accessible.role: Accessible.Button
                  Accessible.name: root.timeLabel(modelData.snapshot) + " " + root.reasonLabel(modelData)
                  Accessible.description: root.snapshotWindowCount(modelData.snapshot) + " vessels, " + root.snapshotWorkspaceCount(modelData.snapshot) + " islands"
                  Accessible.focusable: true
                  Accessible.focused: activeFocus
                  Accessible.selected: root.snapshotIndex === index
                  Accessible.onPressAction: root.setSnapshotIndex(index)
                  radius: 7
                  color: activeFocus || root.snapshotIndex === index
                    ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12)
                    : (rowMouse.containsMouse ? Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.05) : "transparent")
                  border.width: activeFocus ? 2 : (root.snapshotIndex === index ? 1 : 0)
                  border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.46)

                  Keys.onReturnPressed: root.setSnapshotIndex(index)
                  Keys.onEnterPressed: root.setSnapshotIndex(index)
                  Keys.onSpacePressed: root.setSnapshotIndex(index)

                  Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    color: modelData.live ? Color.accent : Color.muted
                  }

                  Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                      width: parent.width
                      text: root.timeLabel(modelData.snapshot) + "  " + root.reasonLabel(modelData)
                      textFormat: Text.PlainText
                      elide: Text.ElideRight
                      color: modelData.live ? Color.accent : Color.foreground
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.weight: modelData.live ? Font.DemiBold : Font.Normal
                    }

                    Text {
                      width: parent.width
                      text: root.snapshotWindowCount(modelData.snapshot) + " vessels  /  " + root.snapshotWorkspaceCount(modelData.snapshot) + " islands"
                      textFormat: Text.PlainText
                      color: Color.muted
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                    }
                  }

                  MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      checkpointRow.forceActiveFocus()
                      root.setSnapshotIndex(index)
                    }
                  }
                }
              }

              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.12)
              }

              Text {
                text: "RECORDER"
                textFormat: Text.PlainText
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.letterSpacing: 1.4
              }

              RowLayout {
                Layout.fillWidth: true
                spacing: 5

                BeachButton {
                  Layout.fillWidth: true
                  label: "PAUSE"
                  compact: true
                  selected: root.recordingMode === "off"
                  onClicked: root.setRecording("off")
                }
                BeachButton {
                  Layout.fillWidth: true
                  label: "SESSION"
                  compact: true
                  selected: root.recordingMode === "session"
                  onClicked: root.setRecording("session")
                }
                BeachButton {
                  Layout.fillWidth: true
                  label: "UP TO 24H"
                  compact: true
                  selected: root.recordingMode === "day"
                  onClicked: root.setRecording("day")
                }
              }

              RowLayout {
                Layout.fillWidth: true
                spacing: 6

                BeachButton {
                  Layout.fillWidth: true
                  label: "LIGHTHOUSE"
                  shortcut: "C"
                  compact: true
                  onClicked: root.saveLighthouse()
                }

                BeachButton {
                  label: "ERASE"
                  compact: true
                  destructive: true
                  onClicked: root.confirmation = "erase"
                }
              }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 11
            color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.28)
            border.width: 1
            border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.11)
            clip: true

            StackLayout {
              anchors.fill: parent
              currentIndex: root.mode === "chronicle" ? 0 : 1

              Item {
                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 16
                  spacing: 10

                  RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38

                    ColumnLayout {
                      spacing: 0
                      Text {
                        text: root.viewingLive ? "LIVE SHORE" : root.dateLabel(root.displayedSnapshot) + " / " + root.timeLabel(root.displayedSnapshot)
                        textFormat: Text.PlainText
                        color: root.viewingLive ? Color.accent : Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                      }
                      Text {
                        text: root.viewingLive ? "Everything below exists now." : "A semantic checkpoint. Titles and pixels were not written to disk."
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }

                    Item { Layout.fillWidth: true }

                    BeachButton {
                      label: "PREVIOUS"
                      shortcut: "←"
                      compact: true
                      enabled: root.snapshotIndex > 0
                      onClicked: root.stepSnapshot(-1)
                    }
                    BeachButton {
                      label: "NEXT"
                      shortcut: "→"
                      compact: true
                      enabled: !root.viewingLive
                      onClicked: root.stepSnapshot(1)
                    }
                  }

                  Flickable {
                    id: islandFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentHeight: islandGrid.implicitHeight

                    GridLayout {
                      id: islandGrid
                      width: islandFlick.width
                      columns: width > 860 ? 3 : (width > 530 ? 2 : 1)
                      columnSpacing: 18
                      rowSpacing: 14

                      Repeater {
                        model: root.workspaceGroups

                        delegate: WorkspaceIsland {
                          required property var modelData
                          Layout.fillWidth: true
                          Layout.preferredHeight: Math.max(150, 185 - Math.min(35, root.workspaceGroups.length * 3))
                          workspaceData: modelData
                          selectedWindowIndex: root.selectedWindowIndex
                          reduceMotion: root.reduceMotion
                          onWindowChosen: function(flatIndex) { root.selectWindow(flatIndex) }
                        }
                      }

                      Text {
                        visible: root.workspaceGroups.length === 0
                        Layout.columnSpan: islandGrid.columns
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: "THE BEACH IS QUIET\nOpen a window or move between workspaces.\nSpaceBeach will never invent a footprint."
                        textFormat: Text.PlainText
                        horizontalAlignment: Text.AlignHCenter
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        lineHeight: 1.45
                      }
                    }
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 8
                    color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.58)
                    border.width: 1
                    border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.12)

                    RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 14
                      anchors.rightMargin: 14
                      spacing: 10

                      Text {
                        text: "PAST"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.letterSpacing: 1
                      }

                      Repeater {
                        model: root.timelineTicks
                        delegate: Rectangle {
                          required property var modelData
                          required property int index
                          Layout.fillWidth: true
                          Layout.maximumWidth: 44
                          Layout.preferredHeight: root.selectedTimelineTick() === index ? 15 : 5
                          radius: 3
                          color: root.selectedTimelineTick() === index ? Color.accent
                            : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.2)
                          MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setSnapshotIndex(Number(modelData.sourceIndex))
                          }
                        }
                      }

                      Text {
                        text: "NOW"
                        textFormat: Text.PlainText
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.letterSpacing: 1
                      }
                    }
                  }
                }
              }

              Item {
                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 20
                  spacing: 14

                  RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                      spacing: 1
                      Text {
                        text: "TIDE RUN / " + (root.gameReady() ? "VOYAGE " + (root.gameTurn() + 1) : "AWAITING FOOTPRINTS")
                        textFormat: Text.PlainText
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.4
                      }
                      Text {
                        text: "A deterministic tactics run cut from your real desktop transitions."
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                      visible: root.gameReady()
                      text: (root.gameComplete() ? "LANDFALL  " : "COHERENCE  ") + root.gameScore()
                      textFormat: Text.PlainText
                      color: Color.foreground
                      font.family: Style.font.family
                      font.pixelSize: Style.font.body
                      font.weight: Font.DemiBold
                      font.letterSpacing: 1
                    }

                    BeachButton {
                      label: "RECHART"
                      compact: true
                      onClicked: root.deriveGame()
                    }
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 108
                    radius: 9
                    color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.62)
                    border.width: 1
                    border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.22)

                    RowLayout {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      anchors.margins: 12
                      height: 46
                      spacing: 8

                      Text {
                        text: "WAVES"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.letterSpacing: 1.2
                      }

                      Repeater {
                        model: root.gameWaves()
                        delegate: Rectangle {
                          required property var modelData
                          required property int index
                          Layout.fillWidth: true
                          Layout.maximumWidth: 78
                          Layout.preferredHeight: 42
                          radius: 6
                          color: index === root.gameTurn()
                            ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.18)
                            : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, index < root.gameTurn() ? 0.03 : 0.07)
                          border.width: index === root.gameTurn() ? 1 : 0
                          border.color: Color.accent

                          Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Text {
                              anchors.horizontalCenter: parent.horizontalCenter
                              text: String(index + 1).padStart(2, "0")
                              textFormat: Text.PlainText
                              color: index === root.gameTurn() ? Color.accent : Color.foreground
                              font.family: Style.font.family
                              font.pixelSize: Style.font.caption
                            }
                            Text {
                              anchors.horizontalCenter: parent.horizontalCenter
                              width: Math.max(30, parent.parent.width - 8)
                              text: root.waveEventLabel(modelData, index)
                              textFormat: Text.PlainText
                              horizontalAlignment: Text.AlignHCenter
                              elide: Text.ElideRight
                              color: Color.muted
                              font.family: Style.font.family
                              font.pixelSize: Math.max(8, Style.font.caption - 2)
                            }
                          }
                        }
                      }
                    }

                    Text {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.bottom: parent.bottom
                      anchors.margins: 12
                      text: {
                        var intelIndex = root.intelligenceWaveIndex()
                        var waves = root.gameWaves()
                        return intelIndex >= 0
                          ? "CHART " + String(intelIndex + 1).padStart(2, "0") + "  /  " + root.waveEventDetails(waves[intelIndex], intelIndex)
                          : "NO RECORDED WATER"
                      }
                      textFormat: Text.PlainText
                      elide: Text.ElideRight
                      color: Color.muted
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.letterSpacing: 0.7
                    }
                  }

                  Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                      visible: root.gameReady()
                      anchors.fill: parent
                      spacing: 10

                      Text {
                        text: "FLEET / choose one vessel, commit one intervention, then meet the next real wave"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }

                      Text {
                        visible: root.gameComplete()
                        Layout.fillWidth: true
                        text: root.gameOutcomeLabel()
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                      }

                      GridView {
                        id: fleetGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        cellWidth: width / (width > 650 ? 3 : 2)
                        cellHeight: 122
                        model: root.gameFleet()
                        currentIndex: root.selectedGameIndex
                        onCurrentIndexChanged: {
                          if (currentIndex >= 0 && count > 0) positionViewAtIndex(currentIndex, GridView.Contain)
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: fleetGrid.cellWidth
                            height: fleetGrid.cellHeight

                            WindowCard {
                              anchors.fill: parent
                              anchors.margins: 5
                              windowData: modelData.window || modelData
                              selected: index === root.selectedGameIndex
                              fidelity: modelData.alive === true
                                ? "AFLOAT · HULL " + modelData.integrity + "/" + modelData.maxIntegrity
                                : "LOST"
                              onChosen: root.selectedGameIndex = index
                            }
                          }
                      }

                      Text {
                        visible: root.gameFleet().length === 0
                        Layout.fillWidth: true
                        text: "NO VESSEL AFLOAT YET — MEET THE RECORDED ARRIVAL WAVE"
                        textFormat: Text.PlainText
                        horizontalAlignment: Text.AlignHCenter
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                      }
                    }

                    Column {
                      visible: !root.gameReady()
                      anchors.centerIn: parent
                      width: Math.min(parent.width - 50, 560)
                      spacing: 13

                      Text {
                        width: parent.width
                        text: "NO SYNTHETIC STORM"
                        textFormat: Text.PlainText
                        horizontalAlignment: Text.AlignHCenter
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.display
                        font.weight: Font.Light
                        font.letterSpacing: 2.4
                      }

                      Text {
                        width: parent.width
                        text: root.tideRun && (root.tideRun.error || root.tideRun.lastError)
                          ? String(root.tideRun.error || root.tideRun.lastError)
                          : "Tide Run needs several real desktop checkpoints. Open, move, focus, or close windows, then return. SpaceBeach refuses to pad the game with fake activity."
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        lineHeight: 1.45
                      }
                    }
                  }

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    BeachButton {
                      Layout.fillWidth: true
                      label: root.pendingInterventionKind() === "anchor" ? "CANCEL ANCHOR" : "ANCHOR"
                      shortcut: "1"
                      selected: root.pendingInterventionKind() === "anchor"
                      enabled: root.gameReady() && !root.gameComplete()
                        && (root.pendingInterventionKind() === "anchor"
                          || (root.pendingInterventionKind() === "" && root.selectedGameVesselIsLive()))
                      onClicked: root.applyIntervention("anchor")
                    }
                    BeachButton {
                      Layout.fillWidth: true
                      label: root.pendingInterventionKind() === "drift" ? "CANCEL DRIFT" : "DRIFT"
                      shortcut: "2"
                      selected: root.pendingInterventionKind() === "drift"
                      enabled: root.gameReady() && !root.gameComplete()
                        && (root.pendingInterventionKind() === "drift"
                          || (root.pendingInterventionKind() === "" && root.selectedGameVesselIsLive()))
                      onClicked: root.applyIntervention("drift")
                    }
                    BeachButton {
                      Layout.fillWidth: true
                      label: root.pendingInterventionKind() === "scan" ? "CANCEL SCAN" : "SCAN"
                      shortcut: "3"
                      selected: root.pendingInterventionKind() === "scan"
                      enabled: root.gameReady() && !root.gameComplete()
                        && (root.pendingInterventionKind() === "" || root.pendingInterventionKind() === "scan")
                      onClicked: root.applyIntervention("scan")
                    }
                    BeachButton {
                      Layout.fillWidth: true
                      label: root.pendingInterventionKind() === "repair" ? "CANCEL REPAIR" : "REPAIR"
                      shortcut: "4"
                      selected: root.pendingInterventionKind() === "repair"
                      enabled: root.gameReady() && !root.gameComplete()
                        && (root.pendingInterventionKind() === "repair"
                          || (root.pendingInterventionKind() === "" && root.selectedGameVesselNeedsRepair()))
                      onClicked: root.applyIntervention("repair")
                    }
                    BeachButton {
                      Layout.fillWidth: true
                      label: root.gameComplete() ? "VOYAGE COMPLETE" : "MEET WAVE"
                      shortcut: "ENTER"
                      selected: true
                      enabled: root.gameReady() && !root.gameComplete()
                      onClicked: root.advanceWave()
                    }
                  }
                }
              }
            }
          }

          Rectangle {
            Layout.preferredWidth: 282
            Layout.fillHeight: true
            radius: 11
            color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.72)
            border.width: 1
            border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.14)

            Flickable {
              anchors.fill: parent
              anchors.margins: 14
              clip: true
              contentHeight: inspector.implicitHeight

              ColumnLayout {
                id: inspector
                width: parent.width
                spacing: 11

                RowLayout {
                  Layout.fillWidth: true
                  Text {
                    Layout.fillWidth: true
                    text: root.mode === "chronicle" ? "CARTOGRAPHER" : "RUN LOG"
                    textFormat: Text.PlainText
                    color: Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.5
                  }
                  Text {
                    text: root.mode === "chronicle" && root.selectedWindow ? String(root.selectedWindowIndex + 1).padStart(2, "0") + "/" + String(root.flatWindows.length).padStart(2, "0") : "◌"
                    textFormat: Text.PlainText
                    color: Color.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                  }
                }

                Item {
                  Layout.fillWidth: true
                  Layout.preferredHeight: 168
                  visible: root.mode === "chronicle" && root.selectedWindow !== null
                  clip: true

                  WindowCard {
                    anchors.fill: parent
                    windowData: root.selectedWindow || ({})
                    selected: true
                    interactive: false
                  }

                  LiveWindowPreview {
                    anchors.fill: parent
                    address: String(root.selectedWindow && root.selectedWindow.address || "")
                    appId: String(root.selectedWindow && root.selectedWindow.appId || "")
                    active: root.livePreviewActive()
                  }

                  Rectangle {
                    anchors.fill: parent
                    visible: root.livePreviewActive()
                    color: "transparent"
                    radius: 10
                    border.width: 2
                    border.color: Color.accent
                  }
                }

                Text {
                  Layout.fillWidth: true
                  visible: root.mode === "chronicle" && root.selectedWindow === null
                  text: "No vessel is present at this checkpoint."
                  textFormat: Text.PlainText
                  wrapMode: Text.WordWrap
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                }

                ColumnLayout {
                  visible: root.mode === "tide"
                  Layout.fillWidth: true
                  spacing: 9

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 84
                    radius: 8
                    color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.07)
                    border.width: 1
                    border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2)

                    ColumnLayout {
                      anchors.fill: parent
                      anchors.margins: 10
                      spacing: 4

                      Text {
                        Layout.fillWidth: true
                        text: root.gameReady() && root.selectedGameVessel()
                          ? String(root.selectedGameVessel().appId || "unknown vessel")
                          : "No playable vessel"
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                        font.weight: Font.DemiBold
                      }

                      Text {
                        Layout.fillWidth: true
                        text: root.gameReady() && root.selectedGameVessel()
                          ? "ISLAND " + root.selectedGameVessel().workspace + "  /  HULL " + root.selectedGameVessel().integrity + "/" + root.selectedGameVessel().maxIntegrity
                          : "Record two or more changed checkpoints"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }

                      Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 3
                        color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.1)
                        Rectangle {
                          width: parent.width * (root.gameReady() && root.selectedGameVessel()
                            ? Math.max(0, Number(root.selectedGameVessel().integrity)) / Math.max(1, Number(root.selectedGameVessel().maxIntegrity)) : 0)
                          height: parent.height
                          color: root.gameReady() && root.selectedGameVessel() && root.selectedGameVessel().alive ? Color.accent : Color.urgent
                        }
                      }
                    }
                  }

                  RowLayout {
                    Layout.fillWidth: true

                    Text {
                      Layout.fillWidth: true
                      text: "LIGHTHOUSE CHARGE"
                      textFormat: Text.PlainText
                      color: Color.muted
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.letterSpacing: 1
                    }
                    Text {
                      text: root.tideRun ? String(root.tideRun.charge || 0) : "0"
                      textFormat: Text.PlainText
                      color: Color.accent
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      font.weight: Font.DemiBold
                    }
                  }

                  Text {
                    Layout.fillWidth: true
                    text: root.tideRun && root.tideRun.pendingIntervention
                      ? "COMMITTED / " + String(root.tideRun.pendingIntervention.kind || "none").toUpperCase()
                      : (root.gameComplete() ? root.gameOutcomeLabel() : "NO INTERVENTION COMMITTED")
                    textFormat: Text.PlainText
                    color: root.tideRun && root.tideRun.pendingIntervention ? Color.accent : Color.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 0.8
                  }

                  Text {
                    Layout.fillWidth: true
                    visible: root.tideRun && root.tideRun.source
                    text: root.tideRun && root.tideRun.source
                      ? root.tideRun.source.checkpointCount + " real checkpoints / " + root.tideRun.source.transitionCount + " recorded transitions / seed " + String(root.tideRun.seed || "").toUpperCase()
                      : ""
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Color.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.11)
                  }

                  Text {
                    text: "RECENT WAVES"
                    textFormat: Text.PlainText
                    color: Color.muted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 1
                  }

                  Repeater {
                    model: root.gameHistory()
                    delegate: RowLayout {
                      required property var modelData
                      Layout.fillWidth: true
                      spacing: 7

                      Text {
                        text: String(Number(modelData.turn || 0) + 1).padStart(2, "0")
                        textFormat: Text.PlainText
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                      Text {
                        Layout.fillWidth: true
                        text: modelData.intervention
                          ? String(modelData.intervention.kind || "none").toUpperCase()
                          : "NO INTERVENTION"
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                      Text {
                        text: modelData.alive + " afloat  /  " + modelData.score
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }
                  }

                  Text {
                    Layout.fillWidth: true
                    visible: root.tideRun && root.tideRun.lastError
                    text: String(root.tideRun && root.tideRun.lastError || "")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Color.urgent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                  }
                }

                GridLayout {
                  visible: root.mode === "chronicle"
                  Layout.fillWidth: true
                  columns: 2
                  columnSpacing: 8
                  rowSpacing: 8

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 53
                    radius: 7
                    color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.08)
                    Column {
                      anchors.centerIn: parent
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: String(root.diffCount("added", "opened"))
                        textFormat: Text.PlainText
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                      }
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ARRIVED"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 53
                    radius: 7
                    color: Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, 0.07)
                    Column {
                      anchors.centerIn: parent
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: String(root.diffCount("removed", "closed"))
                        textFormat: Text.PlainText
                        color: Color.urgent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                      }
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "DEPARTED"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 53
                    radius: 7
                    color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.045)
                    Column {
                      anchors.centerIn: parent
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: String(root.diffCount("moved", "changed"))
                        textFormat: Text.PlainText
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                      }
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "DRIFTED"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }
                  }

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 53
                    radius: 7
                    color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.045)
                    Column {
                      anchors.centerIn: parent
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: String(root.diffCount("unchanged", "exact"))
                        textFormat: Text.PlainText
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                      }
                      Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ANCHORED"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                    }
                  }
                }

                RowLayout {
                  visible: root.mode === "chronicle"
                  Layout.fillWidth: true
                  spacing: 6

                  BeachButton {
                    Layout.fillWidth: true
                    label: "FOCUS"
                    shortcut: "ENTER"
                    compact: true
                    enabled: root.canFocusSelectedWindow()
                    onClicked: root.focusSelectedWindow()
                  }

                  BeachButton {
                    Layout.fillWidth: true
                    label: root.livePreviewActive() ? "HIDE PIXELS" : "LIVE PIXELS"
                    shortcut: "V"
                    compact: true
                    enabled: root.canRevealLivePreview()
                    selected: root.livePreviewActive()
                    onClicked: root.toggleLivePreview()
                  }
                }

                BeachButton {
                  visible: root.mode === "chronicle"
                  Layout.fillWidth: true
                  label: "PREVIEW SCENE RESTORE"
                  shortcut: "R"
                  enabled: !root.viewingLive
                  onClicked: root.requestRestore(root.displayedSnapshot)
                }

                BeachButton {
                  visible: root.mode === "chronicle" && root.service && root.service.rollbackCheckpoint
                  Layout.fillWidth: true
                  label: "ROLL BACK LAST RESTORE"
                  onClicked: root.rollbackRestore()
                }

                Rectangle {
                  Layout.fillWidth: true
                  Layout.preferredHeight: 1
                  color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.12)
                }

                Text {
                  text: "WORLD PHYSICS / REAL HOST"
                  textFormat: Text.PlainText
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.letterSpacing: 1.25
                }

                TelemetryGauge {
                  Layout.fillWidth: true
                  label: "WIND / CPU"
                  valueLabel: Math.round(root.cpuPercent) + "%"
                  value: root.cpuPercent / 100
                  gaugeColor: Color.accent
                }

                TelemetryGauge {
                  Layout.fillWidth: true
                  label: "TIDE / MEMORY"
                  valueLabel: Math.round(root.memoryPercent) + "%"
                  value: root.memoryPercent / 100
                  gaugeColor: Color.foreground
                }

                TelemetryGauge {
                  Layout.fillWidth: true
                  label: "SWELL / LOAD"
                  valueLabel: root.loadAverage.toFixed(2)
                  value: Math.min(1, root.loadAverage / 8)
                  gaugeColor: Color.muted
                }

                Rectangle {
                  Layout.fillWidth: true
                  Layout.preferredHeight: 1
                  color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.12)
                }

                Text {
                  text: "LIGHTHOUSES  " + root.scenes.length + (root.scenes.length > 4 ? "  /  SCROLL" : "")
                  textFormat: Text.PlainText
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.letterSpacing: 1.25
                }

                ListView {
                  id: lighthouseList
                  visible: root.scenes.length > 0
                  Layout.fillWidth: true
                  Layout.preferredHeight: Math.min(4, root.scenes.length) * 42
                  clip: true
                  spacing: 4
                  boundsBehavior: Flickable.StopAtBounds
                  model: root.scenes
                  delegate: Rectangle {
                    id: lighthouseRow
                    required property var modelData
                    width: lighthouseList.width
                    height: 38
                    activeFocusOnTab: true
                    Accessible.role: Accessible.Button
                    Accessible.name: "Restore " + String(modelData.name || "Lighthouse")
                    Accessible.description: "Press Enter to preview this lighthouse. Press Delete to extinguish it."
                    Accessible.focusable: true
                    Accessible.focused: activeFocus
                    Accessible.onPressAction: root.requestRestore(modelData.snapshot || modelData, true)
                    radius: 6
                    color: activeFocus
                      ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12)
                      : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.045)
                    border.width: activeFocus ? 2 : 1
                    border.color: activeFocus ? Color.accent : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.1)

                    Keys.onPressed: function(event) {
                      if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        root.requestRestore(modelData.snapshot || modelData, true)
                        event.accepted = true
                      } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                        root.deleteLighthouse(modelData.id)
                        event.accepted = true
                      }
                    }

                    RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 9
                      anchors.rightMargin: 9
                      Text {
                        text: "◉"
                        textFormat: Text.PlainText
                        color: Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.font.bodySmall
                      }
                      Text {
                        Layout.fillWidth: true
                        text: String(modelData.name || "Lighthouse")
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                      Text {
                        text: root.timeLabel(modelData.snapshot || modelData)
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                      }
                      Text {
                        text: "×"
                        textFormat: Text.PlainText
                        color: Color.muted
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body

                        MouseArea {
                          anchors.fill: parent
                          anchors.margins: -7
                          cursorShape: Qt.PointingHandCursor
                          onClicked: {
                            lighthouseRow.forceActiveFocus()
                            root.deleteLighthouse(modelData.id)
                          }
                        }
                      }
                    }

                    MouseArea {
                      anchors.fill: parent
                      anchors.rightMargin: 30
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        lighthouseRow.forceActiveFocus()
                        root.requestRestore(modelData.snapshot || modelData, true)
                      }
                    }
                  }
                }

                Text {
                  Layout.fillWidth: true
                  visible: root.scenes.length === 0
                  text: "Press C to pin the live shore as a named recovery point."
                  textFormat: Text.PlainText
                  wrapMode: Text.WordWrap
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                }
              }
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 28
          spacing: 14

          Text {
            text: "← → TIME   ↑ ↓ VESSEL   1–4 TIDE ACTION   ENTER FOCUS/WAVE   C LIGHTHOUSE   R RESTORE   V LIVE PIXELS   M MOTION   G MODE   TAB CONTROLS   ESC CLOSE"
            textFormat: Text.PlainText
            color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.62)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.letterSpacing: 0.45
          }

          Item { Layout.fillWidth: true }

          BeachButton {
            compact: true
            label: root.reduceMotion ? "MOTION OFF" : "MOTION ON"
            shortcut: "M"
            selected: !root.reduceMotion
            onClicked: root.reduceMotion = !root.reduceMotion
          }
        }
      }

      Rectangle {
        visible: root.statusMessage.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 56
        width: Math.min(parent.width - 80, statusText.implicitWidth + 36)
        height: 40
        radius: 20
        color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.94)
        border.width: 1
        border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.52)
        z: 80

        Text {
          id: statusText
          anchors.centerIn: parent
          text: root.statusMessage
          textFormat: Text.PlainText
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }

      Rectangle {
        visible: !root.stateReady
        anchors.fill: parent
        color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.94)
        z: 120

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
          preventStealing: true
          onClicked: function(mouse) { mouse.accepted = true }
        }

        Rectangle {
          width: Math.min(parent.width - 60, 520)
          height: 238
          anchors.centerIn: parent
          radius: 13
          color: Color.background
          border.width: 1
          border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.62)

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 14

            Text {
              text: "READING THE TIDE"
              textFormat: Text.PlainText
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
              font.weight: Font.DemiBold
              font.letterSpacing: 1.8
            }

            Text {
              Layout.fillWidth: true
              text: "SpaceBeach is loading its private local journal before accepting a voyage choice or changing history."
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              lineHeight: 1.4
            }

            Item { Layout.fillHeight: true }

            BeachButton {
              Layout.alignment: Qt.AlignRight
              label: "LEAVE SHORE"
              shortcut: "ESC"
              onClicked: root.close()
            }
          }
        }
      }

      Rectangle {
        visible: root.stateReady && root.consentRequired
        anchors.fill: parent
        color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.91)
        z: 100

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
          preventStealing: true
          onClicked: function(mouse) { mouse.accepted = true }
        }

        Rectangle {
          width: Math.min(parent.width - 60, 680)
          height: Math.min(parent.height - 60, 520)
          anchors.centerIn: parent
          radius: 13
          color: Color.background
          border.width: 1
          border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.62)

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 34
            spacing: 15

            Text {
              text: "BEFORE THE FIRST TIDE"
              textFormat: Text.PlainText
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.letterSpacing: 2
            }

            Text {
              Layout.fillWidth: true
              text: "Your desktop leaves footprints.\nYou decide whether they remain."
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.display
              font.weight: Font.Light
              lineHeight: 1.22
            }

            Text {
              Layout.fillWidth: true
              text: "SpaceBeach records window identity, workspace, geometry, and event type. It does not record pixels, keystrokes, document contents, command lines, or network traffic. Durable checkpoints omit window titles. Nothing leaves this machine."
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              lineHeight: 1.45
            }

            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 1
              color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.14)
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 8

              Text {
                text: "CHOOSE A VOYAGE"
                textFormat: Text.PlainText
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
              }

              Text {
                Layout.fillWidth: true
                text: "Session keeps checkpoints and lighthouses only in memory and forgets them when Omarchy Shell exits. Durable mode continuously records across restarts until you pause it, storing up to 24 hours or the latest 360 changed checkpoints, whichever is smaller, under ~/.local/state/omarchy/spacebeach. In durable mode, up to 24 explicit lighthouses remain until you erase them."
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                lineHeight: 1.35
              }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
              Layout.fillWidth: true
              spacing: 9

              BeachButton {
                Layout.fillWidth: true
                label: "NOT NOW"
                shortcut: "0"
                onClicked: {
                  root.setRecording("off")
                  if (root.service && typeof root.service.resolveConsent === "function") root.service.resolveConsent("off")
                }
              }
              BeachButton {
                Layout.fillWidth: true
                label: "SESSION ONLY"
                shortcut: "1"
                selected: true
                onClicked: root.setRecording("session")
              }
              BeachButton {
                Layout.fillWidth: true
                label: "KEEP UP TO 24H"
                shortcut: "2"
                onClicked: root.setRecording("day")
              }
            }
          }
        }
      }

      Rectangle {
        visible: root.confirmation.length > 0
        anchors.fill: parent
        color: Qt.rgba(Color.background.r, Color.background.g, Color.background.b, 0.82)
        z: 110

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
          preventStealing: true
          onClicked: function(mouse) { mouse.accepted = true }
        }

        Rectangle {
          width: Math.min(parent.width - 60, 560)
          height: root.confirmation === "restore" ? 360 : 270
          anchors.centerIn: parent
          radius: 12
          color: Color.background
          border.width: 1
          border.color: root.confirmation === "erase" ? Color.urgent : Color.accent

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 13

            Text {
              text: root.confirmation === "restore" ? "WAKE THIS SCENE?" : "ERASE THE TIDE?"
              textFormat: Text.PlainText
              color: root.confirmation === "erase" ? Color.urgent : Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
              font.weight: Font.DemiBold
              font.letterSpacing: 1.5
            }

            Text {
              Layout.fillWidth: true
              text: root.confirmation === "restore"
                ? "SpaceBeach will ask the compositor to place only exact windows that still exist. Dispatch is best-effort, so verify the result. It will not close current windows, launch commands, recover application memory, or promise an exact tiling tree."
                : "This removes recorded checkpoints and saved lighthouses from memory and disk. Your current windows are untouched."
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              lineHeight: 1.4
            }

            GridLayout {
              visible: root.confirmation === "restore"
              Layout.fillWidth: true
              columns: 4
              columnSpacing: 8

              Text {
                Layout.fillWidth: true
                text: root.planCount("moves") + "\nATTEMPTS"
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }
              Text {
                Layout.fillWidth: true
                text: root.planCount("unchanged") + "\nUNCHANGED"
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }
              Text {
                Layout.fillWidth: true
                text: root.planCount("suggestions") + "\nLAYOUT ONLY"
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: Color.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }
              Text {
                Layout.fillWidth: true
                text: root.planCount("missing") + "\nUNAVAILABLE"
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: Color.urgent
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
              Layout.fillWidth: true
              spacing: 8
              BeachButton {
                Layout.fillWidth: true
                label: "CANCEL"
                shortcut: "ESC"
                onClicked: {
                  root.confirmation = ""
                  root.pendingPlan = null
                }
              }
              BeachButton {
                Layout.fillWidth: true
                label: root.confirmation === "restore"
                  ? (root.planCount("moves") > 0 ? "ATTEMPT PLACEMENT" : "NO EXACT SURVIVORS")
                  : "ERASE LOCALLY"
                shortcut: "ENTER"
                selected: root.confirmation === "restore"
                destructive: root.confirmation === "erase"
                enabled: root.confirmation !== "restore" || root.planCount("moves") > 0
                onClicked: {
                  if (root.confirmation === "restore") root.confirmRestore()
                  else root.eraseTide()
                }
              }
            }
          }
        }
      }
    }
  }
}
