import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "SpaceBeachModel.js" as SpaceBeachModel

Item {
  id: root

  // Injected by omarchy-shell's first-party service loader.
  property var shell: null
  property var manifest: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")

  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || home + "/.local/state"
  readonly property string stateDir: stateHome + "/omarchy/spacebeach"
  readonly property string statePath: stateDir + "/state-v1.json"
  readonly property string sessionId: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""
  readonly property int journalLimit: 360
  readonly property int sceneLimit: 24
  readonly property int dayRetentionMs: 24 * 60 * 60 * 1000

  // "off" observes the current desktop only. "session" journals in memory.
  // "day" is the only mode that grants durable storage permission; after
  // that opt-in, "off" may retain the already-consented bounded journal.
  property string recordingMode: "off"
  property bool consentDecided: false
  property bool durableConsentGranted: false
  readonly property bool consentRequired: stateLoaded && !consentDecided
  property bool overlayOpen: false

  // Address values are pointer-like and may be recycled by Hyprland. The
  // observer epoch proves uninterrupted observation, while each registry
  // token identifies one address/app lifecycle inside that epoch. The
  // registry contains scalar records only; it never retains a toplevel.
  property string observerId: ""
  property int observerSerial: 0
  property int lifecycleSerial: 0
  property var lifecycleRegistry: ({})
  property bool observationActive: false

  // These values are immutable trees of JavaScript scalars. No Hyprland
  // QObject, raw event object, or Wayland toplevel is retained here.
  property var currentSnapshot: ({
    version: 1,
    capturedAt: 0,
    timestamp: 0,
    reason: "startup",
    sessionId: "",
    observerId: "",
    focusedAddress: "",
    monitors: [],
    workspaces: [],
    windows: []
  })
  property var journal: []
  property var scenes: []
  property var restorePreview: null
  property var rollbackCheckpoint: null

  property bool stateLoaded: false
  property bool stateDirReady: false
  property bool persistPending: false
  property bool stateWriteInFlight: false
  property bool stateWriteQueued: false
  property bool stateRemovalPending: false
  property bool historyEraseInFlight: false
  property int dataRevision: 0
  property int snapshotSerial: 0
  property string pendingCaptureReason: "startup"
  property string lastJournalHash: ""
  property string lastRestoreStatus: ""
  property string lastError: ""

  signal snapshotCaptured(var snapshot)
  signal historyChanged()
  signal historyEraseFinished(bool success)
  signal restoreAttempted(int attempted, int dispatches, int skipped)

  function plainClone(value, fallback) {
    try {
      return JSON.parse(JSON.stringify(value))
    } catch (e) {
      return fallback
    }
  }

  function finiteNumber(value, fallback) {
    var number = Number(value)
    return isFinite(number) ? number : fallback
  }

  function integer(value, fallback) {
    var number = finiteNumber(value, fallback)
    return number < 0 ? Math.ceil(number) : Math.floor(number)
  }

  function bool(value) {
    return value === true || value === 1
  }

  function safeString(value) {
    return value === undefined || value === null ? "" : String(value)
  }

  function cleanLabel(value) {
    return safeString(value).replace(/[\u0000-\u001f\u007f]/g, " ").replace(/\s+/g, " ").trim().slice(0, 64)
  }

  function cleanPresentationTitle(value) {
    // Titles are compositor-controlled presentation data. Bound them before
    // they reach snapshot comparisons or Text, and remove control/bidi marks
    // that could create churn or visually impersonate adjacent UI labels.
    return safeString(value)
      .replace(/[\u0000-\u001f\u007f-\u009f\u200b-\u200f\u202a-\u202e\u2060\u2066-\u2069\ufeff]/g, " ")
      .replace(/\s+/g, " ").trim().slice(0, 256)
  }

  function arrayValue(value, index, fallback) {
    try {
      if (value && value.length > index) return value[index]
    } catch (e) { }
    return fallback
  }

  function nextId(prefix, timestamp) {
    snapshotSerial += 1
    return prefix + "-" + Number(timestamp || Date.now()).toString(36) + "-" + snapshotSerial.toString(36)
  }

  function mintObserverId() {
    observerSerial += 1
    var entropy = Math.floor(Math.random() * 0x100000000).toString(36)
    return "observer-" + Date.now().toString(36) + "-" + observerSerial.toString(36) + "-" + entropy
  }

  function rotateObserverIdentity() {
    observerId = mintObserverId()
    lifecycleRegistry = ({})
    dataRevision += 1
  }

  function ensureObserverIdentity() {
    if (!observerId) rotateObserverIdentity()
  }

  function mintLifecycleId() {
    lifecycleSerial += 1
    return observerId + "/window-" + lifecycleSerial.toString(36)
  }

  function syncObservationIdentity() {
    var active = observingDesktop()
    if (active && !observationActive) {
      // Nothing can prove that an address was continuously owned while the
      // service was dormant, so resuming always begins a new observer epoch.
      rotateObserverIdentity()
      observationActive = true
    } else if (!active && observationActive) {
      observationActive = false
      lifecycleRegistry = ({})
      eventDebounce.stop()
      refreshSettle.stop()
    }
  }

  function invalidateLifecycle(address) {
    var canonical = normalizeAddress(address)
    if (!canonical) return false
    var current = lifecycleRegistry || ({})
    if (current[canonical]) {
      var next = ({})
      for (var key in current) {
        if (key !== canonical) next[key] = current[key]
      }
      lifecycleRegistry = next
    }
    dataRevision += 1
    return true
  }

  function identityIsCurrent(address, appId, expectedSessionId, expectedObserverId, expectedLifecycleId) {
    var canonical = normalizeAddress(address)
    var expectedAppId = safeString(appId)
    var wantedSession = safeString(expectedSessionId)
    var wantedObserver = safeString(expectedObserverId)
    var wantedLifecycle = safeString(expectedLifecycleId)
    if (!observationActive || !canonical || !expectedAppId || expectedAppId.toLowerCase() === "unknown"
        || !wantedSession || wantedSession !== sessionId
        || !wantedObserver || wantedObserver !== observerId || !wantedLifecycle)
      return false
    var identity = (lifecycleRegistry || ({}))[canonical]
    return !!identity && safeString(identity.appId) === expectedAppId
      && safeString(identity.lifecycleId) === wantedLifecycle
  }

  function attachObservedLifecycle(window, previous, next) {
    if (!window || !window.address) return window
    var address = window.address
    var appId = safeString(window.appId)
    var existing = next[address] || previous[address]
    var lifecycleId = ""
    if (existing && safeString(existing.appId) === appId)
      lifecycleId = safeString(existing.lifecycleId)
    if (!lifecycleId) lifecycleId = mintLifecycleId()
    window.lifecycleId = lifecycleId
    next[address] = { appId: appId, lifecycleId: lifecycleId }
    return window
  }

  function scalarMonitor(monitor) {
    if (!monitor) return null
    try {
      return {
        id: integer(monitor.id, -1),
        name: safeString(monitor.name),
        x: integer(monitor.x, 0),
        y: integer(monitor.y, 0),
        width: Math.max(0, integer(monitor.width, 0)),
        height: Math.max(0, integer(monitor.height, 0)),
        scale: Math.max(0.1, finiteNumber(monitor.scale, 1)),
        focused: bool(monitor.focused)
      }
    } catch (e) {
      return null
    }
  }

  function scalarWorkspace(workspace) {
    if (!workspace) return null
    try {
      var monitorName = ""
      try { monitorName = workspace.monitor ? safeString(workspace.monitor.name) : "" } catch (e) { }
      return {
        id: integer(workspace.id, 0),
        name: safeString(workspace.name),
        monitor: monitorName,
        active: bool(workspace.active),
        focused: bool(workspace.focused),
        urgent: bool(workspace.urgent),
        hasFullscreen: bool(workspace.hasFullscreen)
      }
    } catch (e) {
      return null
    }
  }

  function scalarWindow(toplevel) {
    if (!toplevel) return null

    try {
      // lastIpcObject is copied field-by-field immediately. It is never put in
      // a model, captured by a callback, or returned from this function.
      var ipc = toplevel.lastIpcObject || ({})
      var ipcWorkspace = ipc.workspace || ({})
      var workspaceId = integer(ipcWorkspace.id, 0)
      var workspaceName = safeString(ipcWorkspace.name)
      var monitorId = integer(ipc.monitor, -1)
      var monitorName = ""

      try {
        if (toplevel.workspace) {
          workspaceId = integer(toplevel.workspace.id, workspaceId)
          workspaceName = safeString(toplevel.workspace.name) || workspaceName
        }
      } catch (e) { }

      try {
        if (toplevel.monitor) {
          monitorId = integer(toplevel.monitor.id, monitorId)
          monitorName = safeString(toplevel.monitor.name)
        }
      } catch (e) { }

      var appId = safeString(ipc.class || ipc.initialClass)
      try {
        if (!appId && toplevel.wayland) appId = safeString(toplevel.wayland.appId)
      } catch (e) { }

      var title = ""
      try { title = cleanPresentationTitle(toplevel.title) } catch (e) { }
      var active = false
      try {
        active = bool(toplevel.activated) || (toplevel.wayland && toplevel.wayland === Hyprland.activeToplevel)
      } catch (e) { }

      return {
        address: normalizeAddress(toplevel.address || ipc.address),
        appId: appId,
        lifecycleId: "",
        // Titles exist only on the live currentSnapshot and are removed by
        // historySnapshot() before any journal, scene, diff, or disk write.
        title: title,
        workspace: workspaceId,
        workspaceName: workspaceName,
        monitor: monitorId,
        monitorName: monitorName,
        x: integer(arrayValue(ipc.at, 0, 0), 0),
        y: integer(arrayValue(ipc.at, 1, 0), 0),
        width: Math.max(0, integer(arrayValue(ipc.size, 0, 0), 0)),
        height: Math.max(0, integer(arrayValue(ipc.size, 1, 0), 0)),
        floating: bool(ipc.floating),
        fullscreen: bool(ipc.fullscreen),
        pinned: bool(ipc.pinned),
        hidden: bool(ipc.hidden),
        urgent: bool(toplevel.urgent),
        active: active
      }
    } catch (e) {
      console.warn("spacebeach: failed to project a toplevel:", e)
      return null
    }
  }

  function projectedSnapshot(reason) {
    ensureObserverIdentity()
    var now = Date.now()
    var monitors = []
    var workspaces = []
    var windows = []
    var previousLifecycles = lifecycleRegistry || ({})
    var nextLifecycles = ({})

    // Keep each QObject local to a single synchronous iteration and retain
    // only the scalar projection produced above.
    var monitorValues = Hyprland.monitors.values || []
    for (var m = 0; m < monitorValues.length; m++) {
      var monitor = scalarMonitor(monitorValues[m])
      if (monitor) monitors.push(monitor)
    }

    var workspaceValues = Hyprland.workspaces.values || []
    for (var w = 0; w < workspaceValues.length; w++) {
      var workspace = scalarWorkspace(workspaceValues[w])
      if (workspace) workspaces.push(workspace)
    }

    var toplevelValues = Hyprland.toplevels.values || []
    for (var t = 0; t < toplevelValues.length; t++) {
      var window = scalarWindow(toplevelValues[t])
      if (window && window.address)
        windows.push(attachObservedLifecycle(window, previousLifecycles, nextLifecycles))
    }
    // Entries absent from this projection are deliberately dropped. If an
    // address reappears later it receives a fresh lifecycle token.
    lifecycleRegistry = nextLifecycles

    var focusedAddress = ""
    for (var f = 0; f < windows.length; f++) {
      if (windows[f].active) {
        focusedAddress = windows[f].address
        break
      }
    }

    var raw = {
      capturedAt: now,
      timestamp: now,
      reason: modelReason(reason),
      sessionId: sessionId,
      observerId: observerId,
      focusedAddress: focusedAddress,
      monitors: monitors,
      workspaces: workspaces,
      windows: windows
    }

    try {
      var normalized = SpaceBeachModel.normalizeSnapshot(raw)
      // The model deliberately drops presentation-only fields. Add current
      // titles back from the just-created scalar rows; historySnapshot strips
      // them again before any history, scene, diff, game, or persistence path.
      var liveByAddress = ({})
      for (var i = 0; i < windows.length; i++) liveByAddress[windows[i].address] = windows[i]
      normalized.observerId = observerId
      for (var j = 0; j < normalized.windows.length; j++) {
        var live = liveByAddress[normalized.windows[j].address] || ({})
        normalized.windows[j].lifecycleId = safeString(live.lifecycleId)
        normalized.windows[j].title = cleanPresentationTitle(live.title)
        normalized.windows[j].active = bool(live.active)
        normalized.windows[j].urgent = bool(live.urgent)
        normalized.windows[j].hidden = bool(live.hidden)
      }
      normalized.monitors = monitors
      normalized.workspaces = workspaces
      return normalized
    } catch (e) {
      console.warn("spacebeach: snapshot normalization failed, using projected data:", e)
      return raw
    }
  }

  function historyWindow(window) {
    var source = window || ({})
    return {
      address: safeString(source.address).toLowerCase(),
      appId: safeString(source.appId),
      lifecycleId: safeString(source.lifecycleId),
      workspace: integer(source.workspace !== undefined ? source.workspace : source.workspaceId, 0),
      workspaceName: safeString(source.workspaceName),
      monitor: integer(source.monitor !== undefined ? source.monitor : source.monitorId, -1),
      monitorName: safeString(source.monitorName),
      x: integer(source.x, 0),
      y: integer(source.y, 0),
      width: Math.max(0, integer(source.width, 0)),
      height: Math.max(0, integer(source.height, 0)),
      floating: bool(source.floating),
      fullscreen: bool(source.fullscreen),
      pinned: bool(source.pinned)
    }
  }

  function historySnapshot(snapshot) {
    var source = snapshot || ({})
    var windows = []
    var inputWindows = Array.isArray(source.windows) ? source.windows : []
    for (var i = 0; i < inputWindows.length; i++) windows.push(historyWindow(inputWindows[i]))
    var raw = {
      capturedAt: Math.max(0, integer(source.capturedAt !== undefined ? source.capturedAt : source.timestamp, 0)),
      reason: modelReason(source.reason),
      sessionId: safeString(source.sessionId || source.session),
      observerId: safeString(source.observerId),
      focusedAddress: safeString(source.focusedAddress || source.activeAddress),
      windows: windows
    }
    try { return SpaceBeachModel.normalizeSnapshot(raw) } catch (e) { return raw }
  }

  function snapshotHash(snapshot) {
    try {
      return safeString(SpaceBeachModel.snapshotHash(historySnapshot(snapshot)))
    } catch (e) {
      var compact = historySnapshot(snapshot)
      delete compact.id
      delete compact.capturedAt
      delete compact.timestamp
      delete compact.reason
      return JSON.stringify(compact)
    }
  }

  function trimJournal(input) {
    var values = Array.isArray(input) ? input : []
    var cutoff = Date.now() - dayRetentionMs
    try {
      return SpaceBeachModel.normalizeJournal(values, { limit: journalLimit, cutoff: cutoff })
    } catch (e) {
      var out = []
      for (var i = 0; i < values.length; i++) {
        var snapshot = historySnapshot(values[i])
        if (snapshot.capturedAt > 0 && snapshot.capturedAt < cutoff) continue
        out.push(snapshot)
      }
      if (out.length > journalLimit) out = out.slice(out.length - journalLimit)
      return out
    }
  }

  function appendToJournal(snapshot) {
    var safeSnapshot = historySnapshot(snapshot)
    var next = null
    try {
      next = SpaceBeachModel.appendSnapshot(journal, safeSnapshot, {
        limit: journalLimit,
        cutoff: Date.now() - dayRetentionMs
      })
    } catch (e) {
      next = journal.concat([safeSnapshot])
    }

    // Accept either the documented array return or an object wrapper so the
    // service remains readable while model tests evolve.
    if (next && Array.isArray(next.journal)) next = next.journal
    if (!Array.isArray(next)) next = journal.concat([safeSnapshot])
    journal = trimJournal(next)
    lastJournalHash = journal.length > 0 ? snapshotHash(journal[journal.length - 1]) : ""
    dataRevision += 1
    historyChanged()
    schedulePersist()
  }

  function presentationKey(snapshot) {
    var value = plainClone(snapshot, ({}))
    delete value.capturedAt
    delete value.timestamp
    delete value.reason
    delete value.id
    delete value.hash
    return JSON.stringify(value)
  }

  function explicitCaptureReason(reason) {
    var value = safeString(reason).toLowerCase()
    return value === "startup" || value === "manual" || value === "overlay-open"
      || value === "recording-start" || value === "ipc" || value === "restore"
      || value === "rollback"
  }

  function captureProjected(reason) {
    var snapshot = projectedSnapshot(reason)
    var publish = explicitCaptureReason(reason) || presentationKey(snapshot) !== presentationKey(currentSnapshot)
    if (publish) {
      currentSnapshot = snapshot
      dataRevision += 1
      snapshotCaptured(snapshot)
    }

    if (recordingMode === "off") return snapshot

    var hash = snapshotHash(snapshot)
    if (hash !== lastJournalHash) appendToJournal(snapshot)
    return snapshot
  }

  function capturePriority(reason) {
    if (reason === "window-open" || reason === "window-close") return 5
    if (reason === "window-move" || reason === "window-state") return 4
    if (reason === "workspace" || reason === "monitor") return 3
    if (reason === "focus") return 2
    if (reason === "window-title") return 1
    return 1
  }

  function modelReason(reason) {
    var value = safeString(reason).toLowerCase()
    if (value === "startup") return "startup"
    if (value === "event" || value === "sample" || value === "capture") return value
    if (value === "restore" || value === "rollback") return value
    if (value === "checkpoint") return "sample"
    if (value === "manual" || value === "overlay-open" || value === "recording-start" || value === "ipc") return "manual"
    if (value === "scene") return "scene"
    return "event"
  }

  function queueCapture(reason) {
    if (!observingDesktop()) return
    var nextReason = safeString(reason) || "checkpoint"
    if (!eventDebounce.running || capturePriority(nextReason) >= capturePriority(pendingCaptureReason))
      pendingCaptureReason = nextReason
    eventDebounce.restart()
  }

  function refreshAndCapture(reason) {
    pendingCaptureReason = safeString(reason) || pendingCaptureReason || "checkpoint"
    try { Hyprland.refreshMonitors() } catch (e) { }
    try { Hyprland.refreshWorkspaces() } catch (e) { }
    try { Hyprland.refreshToplevels() } catch (e) { }
    refreshSettle.restart()
  }

  function captureNow(reason) {
    refreshAndCapture(safeString(reason) || "manual")
    return currentSnapshot
  }

  function semanticReason(eventName) {
    var name = safeString(eventName).toLowerCase()
    if (name === "openwindow") return "window-open"
    if (name === "closewindow") return "window-close"
    if (name === "movewindow" || name === "movewindowv2") return "window-move"
    if (name === "changefloatingmode" || name === "fullscreen" || name === "urgent" || name.indexOf("group") !== -1) return "window-state"
    if (name.indexOf("windowtitle") !== -1) return "window-title"
    if (name.indexOf("workspace") !== -1) return "workspace"
    if (name.indexOf("monitor") !== -1) return "monitor"
    if (name === "focusedmon") return "monitor"
    if (name === "activewindow" || name === "activewindowv2") return "focus"
    return ""
  }

  function closeEventAddress(value) {
    var data = safeString(value).trim()
    var separator = data.indexOf(",")
    if (separator !== -1) data = data.slice(0, separator).trim()
    return normalizeAddress(data)
  }

  function handleRawEvent(event) {
    if (!observingDesktop()) return
    // Copy only scalar fields synchronously. Hyprland reuses/destroys event
    // wrappers; neither the wrapper nor its data enters a deferred callback.
    var name = ""
    var data = ""
    try { name = safeString(event && event.name) } catch (e) { }
    try { data = safeString(event && event.data) } catch (e) { }
    if (name.toLowerCase() === "closewindow") {
      var closedAddress = closeEventAddress(data)
      if (closedAddress) {
        invalidateLifecycle(closedAddress)
      } else {
        // Without the closed address, continuity for every address is
        // unproven. Rotate the whole epoch before any deferred capture.
        rotateObserverIdentity()
      }
    }
    var reason = semanticReason(name)
    if (reason) queueCapture(reason)
  }

  function setOverlayOpen(value) {
    overlayOpen = !!value
    syncObservationIdentity()
    if (overlayOpen) {
      captureNow("overlay-open")
    } else if (recordingMode === "off") {
      eventDebounce.stop()
      refreshSettle.stop()
    }
  }

  function observingDesktop() {
    return overlayOpen || recordingMode !== "off"
  }

  function validMode(value) {
    var mode = safeString(value).toLowerCase()
    return mode === "off" || mode === "session" || mode === "day" ? mode : ""
  }

  function setRecordingMode(value) {
    // FileView hydration is asynchronous. Never let an IPC call or a newly
    // opened overlay race an explicit choice against the existing disk state.
    if (!stateLoaded) return false
    var mode = validMode(value)
    if (!mode) return false

    recordingMode = mode
    consentDecided = true
    lastError = ""
    syncObservationIdentity()

    if (mode === "day") {
      durableConsentGranted = true
      ensurePersistentState()
    } else if (mode === "session") {
      // Session-only always removes the path, including a malformed or older
      // state file that could not be accepted during startup.
      durableConsentGranted = false
      persistTimer.stop()
      persistPending = false
      removePersistentState()
    } else if (mode === "off" && durableConsentGranted) {
      // Pause is distinct from erase: a prior durable opt-in may retain its
      // bounded journal, but no new checkpoints are recorded while paused.
      schedulePersist()
    } else if (mode === "off") {
      // First-run Off writes nothing and also clears an unreadable state file.
      persistTimer.stop()
      persistPending = false
      removePersistentState()
    }

    if (mode !== "off") {
      // Force a fresh baseline even when the desktop has not changed since
      // the consent screen was shown.
      lastJournalHash = ""
      captureNow("recording-start")
    }
    return true
  }

  function saveScene(name, snapshot) {
    if (!stateLoaded) return null
    var source = snapshot && snapshot.snapshot ? snapshot.snapshot : (snapshot || currentSnapshot)
    var safeSnapshot = historySnapshot(source)
    var now = Date.now()
    var label = cleanLabel(name)
    if (!label) label = "Lighthouse " + (scenes.length + 1)

    var scene = {
      id: nextId("beacon", now),
      name: label,
      createdAt: new Date(now).toISOString(),
      timestamp: now,
      snapshot: safeSnapshot
    }

    var next = [scene]
    for (var i = 0; i < scenes.length && next.length < sceneLimit; i++) {
      if (scenes[i] && scenes[i].id !== scene.id) next.push(scenes[i])
    }
    scenes = next
    dataRevision += 1
    historyChanged()
    schedulePersist()
    return plainClone(scene, null)
  }

  function deleteScene(sceneId) {
    if (!stateLoaded) return false
    var id = safeString(sceneId)
    var next = []
    for (var i = 0; i < scenes.length; i++) {
      if (!scenes[i] || safeString(scenes[i].id) !== id) next.push(scenes[i])
    }
    if (next.length === scenes.length) return false
    scenes = next
    dataRevision += 1
    historyChanged()
    schedulePersist()
    return true
  }

  function eraseHistory() {
    if (!stateLoaded) return false
    journal = []
    scenes = []
    restorePreview = null
    rollbackCheckpoint = null
    lastJournalHash = ""
    lastRestoreStatus = "History cleared from memory; local erase pending"
    dataRevision += 1
    historyChanged()
    // Delete, do not merely overwrite: if an older atomic save is in flight,
    // serialized removal runs immediately after it finishes. Durable consent
    // may recreate an empty mode-only file once deletion is confirmed.
    historyEraseInFlight = true
    removePersistentState()
    return true
  }

  function pruneExpiredHistory() {
    var next = trimJournal(journal)
    if (JSON.stringify(next) === JSON.stringify(journal)) return false
    journal = next
    lastJournalHash = journal.length > 0 ? snapshotHash(journal[journal.length - 1]) : ""
    dataRevision += 1
    historyChanged()
    schedulePersist()
    return true
  }

  function diffFor(snapshot) {
    var source = snapshot && snapshot.snapshot ? snapshot.snapshot : snapshot
    try {
      return plainClone(SpaceBeachModel.diffSnapshots(historySnapshot(source), historySnapshot(currentSnapshot)), ({ added: [], removed: [], changed: [] }))
    } catch (e) {
      return { added: [], removed: [], changed: [], error: safeString(e) }
    }
  }

  function localRestorePlan(targetSnapshot) {
    var target = historySnapshot(targetSnapshot)
    var live = historySnapshot(currentSnapshot)
    var sameSession = target.sessionId && target.sessionId === live.sessionId
      && target.observerId && target.observerId === live.observerId
    var byAddress = ({})
    for (var i = 0; i < live.windows.length; i++) byAddress[live.windows[i].address] = live.windows[i]

    var moves = []
    var unresolved = []
    for (var t = 0; t < target.windows.length; t++) {
      var wanted = target.windows[t]
      var found = sameSession ? byAddress[wanted.address] : null
      var knownApp = wanted.appId && wanted.appId.toLowerCase() !== "unknown"
      if (!found || !knownApp || !wanted.lifecycleId || found.appId !== wanted.appId || found.lifecycleId !== wanted.lifecycleId) {
        unresolved.push({ targetAddress: wanted.address, appId: wanted.appId, reason: "unproven-identity", fidelity: "lost", executable: false })
        continue
      }
      var fields = []
      if (currentWorkspace(found) !== actionWorkspace({ to: wanted })) fields.push("workspace")
      if (bool(found.floating) && bool(wanted.floating)) {
        var geometryKeys = ["x", "y", "width", "height"]
        for (var keyIndex = 0; keyIndex < geometryKeys.length; keyIndex++) {
          var key = geometryKeys[keyIndex]
          if (found[key] !== wanted[key]) fields.push(key)
        }
      }
      if (fields.length === 0) continue
      moves.push({
        kind: "move-live-window",
        address: found.address,
        appId: found.appId,
        lifecycleId: found.lifecycleId,
        from: found,
        to: wanted,
        fields: fields,
        fidelity: "exact",
        requiresConfirmation: true
      })
    }
    return {
      version: 1,
      sessionId: live.sessionId,
      observerId: live.observerId,
      targetHash: snapshotHash(target),
      currentHash: snapshotHash(live),
      sameSession: sameSession,
      moves: moves,
      unchanged: [],
      suggestions: [],
      unresolved: unresolved,
      ignoredExtraWindows: [],
      requiresConfirmation: moves.length > 0,
      policy: {
        closeExtraWindows: false,
        launchApplications: false,
        executeCommands: false,
        exactMatchesOnly: true
      }
    }
  }

  function restoreSnapshot(snapshot) {
    var source = snapshot && snapshot.snapshot ? snapshot.snapshot : snapshot
    var target = historySnapshot(source)
    var plan = null
    try {
      plan = SpaceBeachModel.buildRestorePlan(target, historySnapshot(currentSnapshot))
    } catch (e) {
      plan = localRestorePlan(target)
    }
    if (!plan || (!Array.isArray(plan.actions) && !Array.isArray(plan.moves))) plan = localRestorePlan(target)
    restorePreview = plainClone(plan, localRestorePlan(target))
    lastRestoreStatus = "Restore preview ready"
    dataRevision += 1
    return restorePreview
  }

  function previewRestore(snapshot) {
    return restoreSnapshot(snapshot)
  }

  function normalizeAddress(value) {
    var address = safeString(value).trim().toLowerCase()
    if (/^[0-9a-f]+$/.test(address)) address = "0x" + address
    return /^0x[0-9a-f]+$/.test(address) ? address : ""
  }

  function liveToplevelForAddress(value) {
    var address = normalizeAddress(value)
    if (!address) return null
    var values = Hyprland.toplevels.values || []
    for (var i = 0; i < values.length; i++) {
      var candidate = values[i]
      try {
        if (normalizeAddress(candidate.address) === address) return candidate
      } catch (e) { }
    }
    return null
  }

  function snapshotWindowForAddress(snapshot, value) {
    var address = normalizeAddress(value)
    var windows = snapshot && Array.isArray(snapshot.windows) ? snapshot.windows : []
    for (var i = 0; i < windows.length; i++) {
      if (normalizeAddress(windows[i] && windows[i].address) === address) return windows[i]
    }
    return null
  }

  function focusWindow(value, expectedAppId, expectedSessionId, expectedObserverId, expectedLifecycleId) {
    var address = normalizeAddress(value)
    var appId = safeString(expectedAppId)
    var wantedSession = safeString(expectedSessionId)
    var wantedObserver = safeString(expectedObserverId)
    var wantedLifecycle = safeString(expectedLifecycleId)
    if (!address || !appId || appId.toLowerCase() === "unknown"
        || !wantedSession || wantedSession !== sessionId
        || !wantedObserver || wantedObserver !== observerId || !wantedLifecycle)
      return false

    // Re-project synchronously at the action boundary. This drops disappeared
    // registry entries and rotates tokens for address/app changes before focus.
    var liveSnapshot = captureProjected("focus-preflight")
    if (safeString(liveSnapshot.sessionId) !== wantedSession
        || safeString(liveSnapshot.observerId) !== wantedObserver)
      return false
    var projected = snapshotWindowForAddress(liveSnapshot, address)
    if (!projected || safeString(projected.appId) !== appId
        || safeString(projected.lifecycleId) !== wantedLifecycle
        || !identityIsCurrent(address, appId, wantedSession, wantedObserver, wantedLifecycle))
      return false

    var toplevel = liveToplevelForAddress(address)
    if (!toplevel) return false
    var record = scalarWindow(toplevel)
    if (!record || record.address !== address || record.appId !== appId
        || !identityIsCurrent(address, appId, wantedSession, wantedObserver, wantedLifecycle))
      return false

    try {
      if (toplevel.wayland) {
        toplevel.wayland.activate()
        return true
      }
    } catch (e) { }
    try {
      if (toplevel.handle) {
        toplevel.handle.activate()
        return true
      }
    } catch (e) { }
    lastError = "Could not focus the selected live window"
    return false
  }

  function targetWindowFor(action) {
    if (!action) return ({})
    return action.target || action.to || action.window || ({})
  }

  function actionWorkspace(action) {
    var target = targetWindowFor(action)
    var value = action && action.workspace !== undefined ? action.workspace
      : (action && action.workspaceId !== undefined ? action.workspaceId
        : (target.workspace !== undefined ? target.workspace : target.workspaceId))
    var name = safeString(action && action.workspaceName || target.workspaceName)
    return SpaceBeachModel.canonicalWorkspaceTarget(value, name)
  }

  function currentWorkspace(window) {
    if (!window) return ""
    var name = safeString(window.workspaceName)
    return SpaceBeachModel.canonicalWorkspaceTarget(
      window.workspace !== undefined ? window.workspace : window.workspaceId,
      name
    )
  }

  function luaQuoted(value) {
    return safeString(value).replace(/\\/g, "\\\\").replace(/\"/g, "\\\"")
  }

  function dispatchWorkspaceMove(address, workspace) {
    try {
      if (Hyprland.usingLua) {
        Hyprland.dispatch("hl.dsp.window.move({ workspace = \"" + luaQuoted(workspace) + "\", window = \"address:" + address + "\", follow = false })")
      } else {
        Hyprland.dispatch("movetoworkspacesilent " + workspace + ",address:" + address)
      }
      return 1
    } catch (e) {
      return 0
    }
  }

  function dispatchFloatingGeometry(address, target, current, fields) {
    if (!target || !current || !bool(current.floating)) return 0
    var changed = Array.isArray(fields) ? fields : []
    var moveChanged = changed.indexOf("x") !== -1 || changed.indexOf("y") !== -1
    var sizeChanged = changed.indexOf("width") !== -1 || changed.indexOf("height") !== -1
    if (!moveChanged && !sizeChanged) return 0
    var x = integer(target.x, 0)
    var y = integer(target.y, 0)
    var dispatches = 0
    if (moveChanged) {
      try {
        if (Hyprland.usingLua) {
          Hyprland.dispatch("hl.dsp.window.move({ window = \"address:" + address + "\", x = " + x + ", y = " + y + " })")
        } else {
          Hyprland.dispatch("movewindowpixel exact " + x + " " + y + ",address:" + address)
        }
        dispatches += 1
      } catch (e) { }
    }
    if (sizeChanged) {
      var width = Math.max(1, integer(target.width, current.width))
      var height = Math.max(1, integer(target.height, current.height))
      try {
        if (Hyprland.usingLua) {
          Hyprland.dispatch("hl.dsp.window.resize({ window = \"address:" + address + "\", x = " + width + ", y = " + height + ", relative = false })")
        } else {
          Hyprland.dispatch("resizewindowpixel exact " + width + " " + height + ",address:" + address)
        }
        dispatches += 1
      } catch (e) { }
    }
    return dispatches
  }

  function applyRestorePlan(plan, makeRollback) {
    var source = plan || restorePreview
    if (!source) return { considered: 0, attempted: 0, dispatches: 0, skipped: 0, error: "no-preview" }
    var actions = Array.isArray(source.moves) ? source.moves : (Array.isArray(source.actions) ? source.actions : [])
    if (actions.length === 0) {
      restorePreview = null
      lastRestoreStatus = "No exact live windows need moving"
      return { considered: 0, attempted: 0, dispatches: 0, skipped: 0, error: "no-exact-moves" }
    }

    // Re-project immediately before mutation. The preview may have been open
    // while windows closed or addresses were recycled.
    var liveSnapshot = captureProjected("restore-preflight")
    var planSession = safeString(source.sessionId)
    var planObserver = safeString(source.observerId)
    if (!observationActive || !planSession || planSession !== sessionId || !planObserver || planObserver !== observerId
        || safeString(liveSnapshot.sessionId) !== planSession
        || safeString(liveSnapshot.observerId) !== planObserver) {
      lastRestoreStatus = "Window identity continuity is no longer proven"
      return { considered: actions.length, attempted: 0, dispatches: 0, skipped: actions.length, error: "unproven-identity" }
    }
    if (!source.currentHash || safeString(source.currentHash) !== snapshotHash(liveSnapshot)) {
      lastRestoreStatus = "Desktop changed; review a fresh restore preview"
      return { considered: actions.length, attempted: 0, dispatches: 0, skipped: actions.length, error: "desktop-changed" }
    }
    if (source.sameSession !== true) {
      lastRestoreStatus = "Only exact windows from this compositor session can be restored"
      return { considered: actions.length, attempted: 0, dispatches: 0, skipped: actions.length, error: "different-session" }
    }
    if (!source.policy || source.policy.exactMatchesOnly !== true || source.policy.closeExtraWindows === true || source.policy.launchApplications === true || source.policy.executeCommands === true) {
      lastRestoreStatus = "Rejected an unsafe restore plan"
      return { considered: actions.length, attempted: 0, dispatches: 0, skipped: actions.length, error: "unsafe-policy" }
    }

    var attempted = 0
    var dispatches = 0
    var skipped = 0
    for (var i = 0; i < actions.length; i++) {
      var action = actions[i] || ({})
      if (safeString(action.kind) !== "move-live-window" || safeString(action.fidelity) !== "exact") {
        skipped += 1
        continue
      }
      var address = normalizeAddress(action.address)
      var workspace = actionWorkspace(action)
      var expectedAppId = safeString(action.appId)
      var expectedLifecycleId = safeString(action.lifecycleId)
      if (!address || !expectedAppId || expectedAppId.toLowerCase() === "unknown" || !expectedLifecycleId) {
        skipped += 1
        continue
      }

      var projected = snapshotWindowForAddress(liveSnapshot, address)
      if (!projected || safeString(projected.appId) !== expectedAppId
          || safeString(projected.lifecycleId) !== expectedLifecycleId
          || !identityIsCurrent(address, expectedAppId, planSession, planObserver, expectedLifecycleId)) {
        skipped += 1
        continue
      }
      var live = liveToplevelForAddress(address)
      if (!live) {
        skipped += 1
        continue
      }
      var record = scalarWindow(live)
      if (!record || record.address !== address || record.appId !== expectedAppId
          || !identityIsCurrent(address, expectedAppId, planSession, planObserver, expectedLifecycleId)) {
        skipped += 1
        continue
      }

      var fields = Array.isArray(action.fields) ? action.fields : []
      var actionDispatches = 0
      var workspaceChanged = fields.indexOf("workspace") !== -1 || fields.indexOf("workspaceName") !== -1
      if (workspaceChanged && workspace && currentWorkspace(record) !== workspace)
        actionDispatches += dispatchWorkspaceMove(address, workspace)
      actionDispatches += dispatchFloatingGeometry(address, targetWindowFor(action), record, fields)
      if (actionDispatches === 0) {
        skipped += 1
        continue
      }
      attempted += 1
      dispatches += actionDispatches
    }

    restorePreview = null
    if (attempted > 0) rollbackCheckpoint = historySnapshot(liveSnapshot)
    lastRestoreStatus = "Attempted placement for " + attempted + " live window" + (attempted === 1 ? "" : "s") + " with " + dispatches + " compositor request" + (dispatches === 1 ? "" : "s") + (skipped ? "; skipped " + skipped : "")
    dataRevision += 1
    restoreAttempted(attempted, dispatches, skipped)
    if (attempted > 0) postRestoreCapture.restart()
    return { considered: actions.length, attempted: attempted, dispatches: dispatches, skipped: skipped }
  }

  function confirmRestore(plan) {
    return applyRestorePlan(plan || restorePreview, true)
  }

  function rollbackLastRestore() {
    if (!rollbackCheckpoint) return { considered: 0, attempted: 0, dispatches: 0, skipped: 0, error: "no-rollback" }
    var target = rollbackCheckpoint
    var liveSnapshot = captureProjected("rollback")
    var plan = null
    try {
      plan = SpaceBeachModel.buildRestorePlan(target, historySnapshot(liveSnapshot))
    } catch (e) {
      plan = localRestorePlan(target)
    }
    if (!plan || (!Array.isArray(plan.actions) && !Array.isArray(plan.moves))) plan = localRestorePlan(target)
    return applyRestorePlan(plan, true)
  }

  function persistentScene(scene) {
    var source = scene || ({})
    return {
      id: safeString(source.id),
      name: cleanLabel(source.name),
      createdAt: safeString(source.createdAt),
      timestamp: Math.max(0, integer(source.timestamp, 0)),
      snapshot: historySnapshot(source.snapshot)
    }
  }

  function persistentPayload() {
    var safeJournal = []
    for (var i = 0; i < journal.length; i++) safeJournal.push(historySnapshot(journal[i]))
    var safeScenes = []
    for (var s = 0; s < scenes.length; s++) safeScenes.push(persistentScene(scenes[s]))
    return {
      version: 1,
      recordingMode: recordingMode === "off" ? "off" : "day",
      retainedHours: 24,
      savedAt: new Date().toISOString(),
      journal: safeJournal,
      scenes: safeScenes
    }
  }

  function ensurePersistentState() {
    if (!durableConsentGranted) return
    if (stateRemovalPending || removeStateFile.running) {
      persistPending = true
      stateWriteQueued = true
      return
    }
    if (stateDirReady) {
      schedulePersist()
      return
    }
    persistPending = true
    if (!ensureStateDir.running) ensureStateDir.running = true
  }

  function schedulePersist() {
    if (!durableConsentGranted || recordingMode === "session") return
    if (stateRemovalPending || removeStateFile.running) {
      persistPending = true
      stateWriteQueued = true
      return
    }
    if (!stateDirReady) {
      ensurePersistentState()
      return
    }
    if (stateWriteInFlight) {
      stateWriteQueued = true
      return
    }
    persistTimer.restart()
  }

  function flushPersistentState() {
    if (!durableConsentGranted || recordingMode === "session" || !stateDirReady) return
    if (stateRemovalPending || removeStateFile.running) {
      persistPending = true
      stateWriteQueued = true
      return
    }
    if (stateWriteInFlight) {
      stateWriteQueued = true
      return
    }
    var payload = persistentPayload()
    stateWriteInFlight = true
    persistPending = true
    try {
      stateFile.setText(JSON.stringify(payload, null, 2) + "\n")
    } catch (e) {
      console.warn("spacebeach: state save could not start:", e)
      durabilityFailed("Could not save SpaceBeach's private state", true)
    }
  }

  function durabilityFailed(message, removeDisk) {
    persistTimer.stop()
    stateWriteInFlight = false
    stateWriteQueued = false
    persistPending = false
    stateDirReady = false
    durableConsentGranted = false
    recordingMode = "session"
    consentDecided = true
    syncObservationIdentity()
    lastError = message + "; continuing session-only"
    dataRevision += 1
    if (removeDisk) removePersistentState()
  }

  function removePersistentState() {
    persistTimer.stop()
    stateRemovalPending = true
    tryRemovePersistentState()
  }

  function tryRemovePersistentState() {
    if (!stateRemovalPending || stateWriteInFlight || removeStateFile.running) return
    stateRemovalPending = false
    removeStateFile.running = true
  }

  function loadPersistentState(raw) {
    if (stateLoaded) return
    var text = safeString(raw).trim()
    if (!text) {
      stateLoaded = true
      return
    }

    try {
      var parsed = JSON.parse(text)
      if (!parsed || parsed.version !== 1 || (parsed.recordingMode !== "day" && parsed.recordingMode !== "off")) throw new Error("unsupported state")

      journal = trimJournal(Array.isArray(parsed.journal) ? parsed.journal : [])
      var loadedScenes = []
      var sourceScenes = Array.isArray(parsed.scenes) ? parsed.scenes : []
      for (var i = 0; i < sourceScenes.length && loadedScenes.length < sceneLimit; i++)
        loadedScenes.push(persistentScene(sourceScenes[i]))
      scenes = loadedScenes
      recordingMode = parsed.recordingMode
      consentDecided = true
      durableConsentGranted = true
      stateDirReady = true
      if (journal.length > 0) lastJournalHash = snapshotHash(journal[journal.length - 1])
      dataRevision += 1
    } catch (e) {
      lastError = "SpaceBeach ignored an unreadable state file"
      console.warn("spacebeach: state parse failed:", e)
    }
    stateLoaded = true
    syncObservationIdentity()
    if (recordingMode !== "off") captureNow("recording-start")
    if (durableConsentGranted) Qt.callLater(root.schedulePersist)
  }

  function statusJson() {
    return JSON.stringify({
      version: 1,
      recordingMode: recordingMode,
      durableConsentGranted: durableConsentGranted,
      durabilityPending: persistPending || stateWriteInFlight || stateRemovalPending
        || historyEraseInFlight || ensureStateDir.running || removeStateFile.running,
      historyEraseInFlight: historyEraseInFlight,
      stateLoaded: stateLoaded,
      consentRequired: consentRequired,
      overlayOpen: overlayOpen,
      currentWindows: currentSnapshot && Array.isArray(currentSnapshot.windows) ? currentSnapshot.windows.length : 0,
      checkpoints: journal.length,
      scenes: scenes.length,
      restorePreview: restorePreview !== null,
      rollbackAvailable: rollbackCheckpoint !== null,
      lastRestoreStatus: lastRestoreStatus,
      lastError: lastError
    })
  }

  Timer {
    id: eventDebounce
    interval: 160
    repeat: false
    onTriggered: root.refreshAndCapture(root.pendingCaptureReason)
  }

  Timer {
    id: refreshSettle
    interval: 80
    repeat: false
    onTriggered: {
      var reason = root.pendingCaptureReason
      root.pendingCaptureReason = "checkpoint"
      root.captureProjected(reason)
    }
  }

  // Geometry changes do not emit reliable Hyprland events. Poll slowly while
  // recording, and only speed up while the visual time machine is visible.
  Timer {
    id: geometryPoll
    interval: root.overlayOpen ? 2500 : 15000
    running: root.stateLoaded && (root.overlayOpen || root.recordingMode !== "off")
    repeat: true
    onTriggered: root.refreshAndCapture("checkpoint")
  }

  Timer {
    id: postRestoreCapture
    interval: 350
    repeat: false
    onTriggered: root.captureNow("restore")
  }

  Timer {
    id: persistTimer
    interval: 250
    repeat: false
    onTriggered: root.flushPersistentState()
  }

  // Retention is wall-clock based, not capture based. A paused durable or
  // session tide therefore still forgets checkpoints after 24 hours.
  Timer {
    interval: 5 * 60 * 1000
    running: root.stateLoaded && root.journal.length > 0
    repeat: true
    onTriggered: root.pruneExpiredHistory()
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) { root.handleRawEvent(event) }
  }

  Connections {
    target: Hyprland.toplevels
    function onValuesChanged() { if (root.observingDesktop()) root.queueCapture("window-set") }
  }

  Connections {
    target: Hyprland.workspaces
    function onValuesChanged() { if (root.observingDesktop()) root.queueCapture("workspace") }
  }

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() { if (root.observingDesktop()) root.queueCapture("monitor") }
  }

  Process {
    id: ensureStateDir
    // Pre-create the target at 0600 so FileView/QSaveFile preserves private
    // permissions across atomic replacements. This process only runs after
    // the user explicitly selects the durable "day" mode.
    command: ["bash", "-c", "install -d -m 0700 \"$1\" && touch \"$2\" && chmod 0600 \"$2\"", "--", root.stateDir, root.statePath]
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.durabilityFailed("Could not create SpaceBeach's private state", true)
        return
      }
      if (!root.durableConsentGranted || root.recordingMode === "session") {
        root.stateDirReady = false
        root.removePersistentState()
        return
      }
      root.stateDirReady = true
      root.flushPersistentState()
    }
  }

  Process {
    id: removeStateFile
    command: ["rm", "-f", root.statePath]
    onExited: function(exitCode) {
      var removed = exitCode === 0
      if (exitCode !== 0) {
        var prefix = root.lastError ? root.lastError + ". " : ""
        root.lastError = prefix + "Could not remove SpaceBeach's state file"
      } else {
        root.stateDirReady = false
      }
      if (root.stateRemovalPending) {
        root.tryRemovePersistentState()
        return
      }
      if (root.historyEraseInFlight) {
        root.historyEraseInFlight = false
        root.lastRestoreStatus = removed ? "History erased locally" : "Local history erase failed"
        root.dataRevision += 1
        root.historyEraseFinished(removed)
      }
      if (removed && root.durableConsentGranted && root.recordingMode !== "session") {
        root.stateWriteQueued = false
        root.persistPending = true
        root.ensurePersistentState()
      }
    }
  }

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadPersistentState(text())
    onLoadFailed: root.loadPersistentState("")
    onSaved: {
      root.stateWriteInFlight = false
      root.persistPending = false
      if (root.stateRemovalPending) {
        root.stateWriteQueued = false
        root.tryRemovePersistentState()
      } else if (!root.durableConsentGranted || root.recordingMode === "session") {
        root.stateWriteQueued = false
        root.removePersistentState()
      } else if (root.stateWriteQueued) {
        root.stateWriteQueued = false
        root.schedulePersist()
      }
    }
    onSaveFailed: function(error) {
      console.warn("spacebeach: state save failed:", error)
      root.durabilityFailed("Could not save SpaceBeach's private state", true)
    }
  }

  Component.onCompleted: {
    // Reading a previously consented-to file is safe. No directory or file is
    // created on first run; only setRecordingMode("day") does that. FileView
    // loads automatically when its path resolves, including the absent-file
    // failure path handled above.
    root.captureNow("startup")
  }

  IpcHandler {
    target: "spacebeach"

    function status(): string {
      return root.statusJson()
    }

    function capture(): string {
      root.captureNow("ipc")
      return root.statusJson()
    }

    function record(mode: string): string {
      if (!root.stateLoaded) return "state loading"
      return root.setRecordingMode(mode) ? root.recordingMode : "invalid mode"
    }

    function save(name: string): string {
      if (!root.stateLoaded) return "state loading"
      var scene = root.saveScene(name, root.currentSnapshot)
      return JSON.stringify({ id: scene ? scene.id : "", name: scene ? scene.name : "" })
    }

    function erase(): string {
      if (!root.stateLoaded) return "state loading"
      root.eraseHistory()
      return root.historyEraseInFlight ? "erase pending" : "erased"
    }
  }
}
