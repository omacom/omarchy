var SNAPSHOT_VERSION = 1
var RESTORE_PLAN_VERSION = 1
var TIDE_RUN_VERSION = 1
var DEFAULT_HISTORY_LIMIT = 192
var MAX_HISTORY_LIMIT = 2048
var DEFAULT_WAVE_LIMIT = 12
var MAX_WAVE_LIMIT = 32

function hasOwn(value, key) {
  return value !== null && value !== undefined && Object.prototype.hasOwnProperty.call(value, key)
}

function safeString(value) {
  try {
    if (value === undefined || value === null) return ""
    return String(value)
  } catch (error) {
    return ""
  }
}

function boundedText(value, limit) {
  var text = safeString(value).replace(/[\u0000-\u001f\u007f]+/g, " ").replace(/\s+/g, " ").trim()
  return text.slice(0, limit)
}

function finiteNumber(value, fallback) {
  try {
    var number = Number(value)
    return isFinite(number) ? number : fallback
  } catch (error) {
    return fallback
  }
}

function boundedInteger(value, fallback, minimum, maximum) {
  var number = Math.round(finiteNumber(value, fallback))
  return Math.max(minimum, Math.min(maximum, number))
}

function booleanValue(value) {
  if (value === true) return true
  if (typeof value === "number") return isFinite(value) && value !== 0
  var text = safeString(value).toLowerCase()
  return text === "true" || (/^-?[0-9]+(?:\.[0-9]+)?$/.test(text) && Number(text) !== 0)
}

function normalizedAddress(value) {
  var address = boundedText(value, 128).toLowerCase()
  if (/^[0-9a-f]+$/.test(address)) address = "0x" + address
  return /^0x[0-9a-f]+$/.test(address) ? address : ""
}

function normalizedSessionId(value) {
  return boundedText(value, 192)
}

function normalizedObserverId(value) {
  return boundedText(value, 192)
}

function normalizedLifecycleId(value) {
  return boundedText(value, 192)
}

function normalizedAppId(raw) {
  var source = raw || {}
  return boundedText(source.appId || source.class || source.initialClass || source.app || "unknown", 160) || "unknown"
}

function objectNumber(value, key, fallback) {
  if (value && typeof value === "object" && !Array.isArray(value)) return finiteNumber(value[key], fallback)
  return fallback
}

function arrayNumber(value, index, fallback) {
  return Array.isArray(value) ? finiteNumber(value[index], fallback) : fallback
}

function workspaceValue(raw) {
  var workspace = raw.workspace
  if (workspace && typeof workspace === "object") workspace = workspace.id
  if (workspace === undefined || workspace === null || workspace === "") workspace = raw.workspaceId
  return boundedInteger(workspace, 0, -100000, 100000)
}

function workspaceNameValue(raw) {
  var name = raw.workspaceName
  if (!name && raw.workspace && typeof raw.workspace === "object") name = raw.workspace.name
  return boundedText(name, 128)
}

function canonicalWorkspaceTarget(value, rawName) {
  var numeric = finiteNumber(value, 0)
  var id = numeric < 0 ? Math.ceil(numeric) : Math.floor(numeric)
  if (id > 0) return String(id)

  var untrustedName = safeString(rawName)
  if (/[\u0000-\u001f\u007f,]/.test(untrustedName)) return ""
  var name = untrustedName.replace(/\s+/g, " ").trim().slice(0, 128)
  if (!name) return ""
  if (name.indexOf("special:") === 0 || name.indexOf("name:") === 0) return name
  return "name:" + name
}

function monitorValue(raw) {
  var monitor = raw.monitor
  if (monitor && typeof monitor === "object") monitor = monitor.id
  if (monitor === undefined || monitor === null || monitor === "") monitor = raw.monitorId
  return boundedInteger(monitor, -1, -1, 100000)
}

function monitorNameValue(raw) {
  var name = raw.monitorName
  if (!name && raw.monitor && typeof raw.monitor === "object") name = raw.monitor.name
  return boundedText(name, 128)
}

function normalizeWindow(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return null

  var address = normalizedAddress(raw.address || raw.windowAddress || raw.id)
  if (!address) return null

  var geometry = raw.geometry && typeof raw.geometry === "object" ? raw.geometry : {}
  var x = finiteNumber(raw.x, objectNumber(geometry, "x", arrayNumber(raw.at || raw.position, 0, 0)))
  var y = finiteNumber(raw.y, objectNumber(geometry, "y", arrayNumber(raw.at || raw.position, 1, 0)))
  var width = finiteNumber(raw.width, finiteNumber(raw.w, objectNumber(geometry, "width", arrayNumber(raw.size, 0, 0))))
  var height = finiteNumber(raw.height, finiteNumber(raw.h, objectNumber(geometry, "height", arrayNumber(raw.size, 1, 0))))

  return {
    address: address,
    lifecycleId: normalizedLifecycleId(raw.lifecycleId),
    appId: normalizedAppId(raw),
    workspace: workspaceValue(raw),
    workspaceName: workspaceNameValue(raw),
    monitor: monitorValue(raw),
    monitorName: monitorNameValue(raw),
    x: boundedInteger(x, 0, -1000000, 1000000),
    y: boundedInteger(y, 0, -1000000, 1000000),
    width: boundedInteger(width, 0, 0, 1000000),
    height: boundedInteger(height, 0, 0, 1000000),
    floating: booleanValue(raw.floating),
    fullscreen: booleanValue(raw.fullscreen || raw.fullscreenClient),
    pinned: booleanValue(raw.pinned)
  }
}

function canonicalWindow(window) {
  return JSON.stringify([
    window.address,
    window.lifecycleId,
    window.appId,
    window.workspace,
    window.workspaceName,
    window.monitor,
    window.monitorName,
    window.x,
    window.y,
    window.width,
    window.height,
    window.floating,
    window.fullscreen,
    window.pinned
  ])
}

function normalizedReason(value) {
  var reason = boundedText(value, 48).toLowerCase()
  var known = {
    startup: true,
    event: true,
    sample: true,
    manual: true,
    scene: true,
    rollback: true,
    restore: true
  }
  return hasOwn(known, reason) ? reason : "capture"
}

function snapshotWindows(raw) {
  var values = Array.isArray(raw.windows) ? raw.windows : (Array.isArray(raw.clients) ? raw.clients : [])
  var candidates = []

  for (var i = 0; i < values.length; i++) {
    var window = normalizeWindow(values[i])
    if (window) candidates.push(window)
  }

  candidates.sort(function(a, b) {
    var addressOrder = a.address.localeCompare(b.address)
    if (addressOrder !== 0) return addressOrder
    return canonicalWindow(a).localeCompare(canonicalWindow(b))
  })

  var windows = []
  for (var j = 0; j < candidates.length; j++) {
    if (j > 0 && candidates[j].address === candidates[j - 1].address) continue
    windows.push(candidates[j])
  }
  return windows
}

function normalizeSnapshot(raw) {
  var source = raw && typeof raw === "object" && !Array.isArray(raw) ? raw : {}
  return {
    version: SNAPSHOT_VERSION,
    capturedAt: Math.max(0, Math.floor(finiteNumber(source.capturedAt, finiteNumber(source.timestamp, finiteNumber(source.at, 0))))),
    reason: normalizedReason(source.reason),
    sessionId: normalizedSessionId(source.sessionId || source.session),
    observerId: normalizedObserverId(source.observerId),
    focusedAddress: normalizedAddress(source.focusedAddress || source.activeAddress || source.focused),
    windows: snapshotWindows(source)
  }
}

function isSnapshotInput(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return false
  if (!Array.isArray(raw.windows) && !Array.isArray(raw.clients)) return false
  return finiteNumber(raw.capturedAt, finiteNumber(raw.timestamp, finiteNumber(raw.at, 0))) > 0
}

function hashText(value) {
  var text = safeString(value)
  var hash = 2166136261
  for (var i = 0; i < text.length; i++) {
    hash ^= text.charCodeAt(i)
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24)
    hash >>>= 0
  }
  return ("00000000" + hash.toString(16)).slice(-8)
}

function snapshotHash(raw) {
  var snapshot = normalizeSnapshot(raw)
  var windows = []
  for (var i = 0; i < snapshot.windows.length; i++) windows.push(canonicalWindow(snapshot.windows[i]))
  return hashText(JSON.stringify([
    snapshot.version,
    snapshot.sessionId,
    snapshot.observerId,
    snapshot.focusedAddress,
    windows
  ]))
}

function snapshotWithHash(raw) {
  var snapshot = normalizeSnapshot(raw)
  snapshot.hash = snapshotHash(snapshot)
  return snapshot
}

function normalizedHistoryOptions(value) {
  var source = value && typeof value === "object" && !Array.isArray(value) ? value : {}
  var requestedLimit = typeof value === "number" ? value : source.limit
  var limit = boundedInteger(requestedLimit, DEFAULT_HISTORY_LIMIT, 0, MAX_HISTORY_LIMIT)
  var cutoff = Math.max(0, Math.floor(finiteNumber(source.cutoff, finiteNumber(source.cutoffAt, 0))))
  return { limit: limit, cutoff: cutoff }
}

function normalizeJournal(raw, options) {
  var settings = normalizedHistoryOptions(options)
  if (!Array.isArray(raw) || settings.limit === 0) return []

  var ordered = []
  for (var i = 0; i < raw.length; i++) {
    if (!isSnapshotInput(raw[i])) continue
    var snapshot = snapshotWithHash(raw[i])
    if (snapshot.capturedAt < settings.cutoff) continue
    ordered.push({ snapshot: snapshot, order: i })
  }

  ordered.sort(function(a, b) {
    if (a.snapshot.capturedAt !== b.snapshot.capturedAt) return a.snapshot.capturedAt - b.snapshot.capturedAt
    return a.order - b.order
  })

  var journal = []
  for (var j = 0; j < ordered.length; j++) {
    var entry = ordered[j].snapshot
    if (journal.length > 0 && journal[journal.length - 1].hash === entry.hash) continue
    journal.push(entry)
  }

  if (journal.length > settings.limit) journal = journal.slice(journal.length - settings.limit)
  return journal
}

// Append is deterministic: it never reads the clock. cutoff/cutoffAt is an
// absolute millisecond timestamp supplied by the service, and limit bounds the
// retained changed checkpoints. Consecutive duplicate states are coalesced.
function appendSnapshot(history, rawSnapshot, options) {
  var settings = normalizedHistoryOptions(options)
  if (settings.limit === 0) return []

  var journal = normalizeJournal(history, { limit: MAX_HISTORY_LIMIT, cutoff: settings.cutoff })
  if (!isSnapshotInput(rawSnapshot)) {
    return journal.length > settings.limit ? journal.slice(journal.length - settings.limit) : journal
  }

  var candidate = snapshotWithHash(rawSnapshot)
  if (candidate.capturedAt < settings.cutoff) {
    return journal.length > settings.limit ? journal.slice(journal.length - settings.limit) : journal
  }

  var previous = journal.length > 0 ? journal[journal.length - 1] : null
  if (previous && (candidate.capturedAt < previous.capturedAt || candidate.hash === previous.hash)) {
    return journal.length > settings.limit ? journal.slice(journal.length - settings.limit) : journal
  }

  journal.push(candidate)
  if (journal.length > settings.limit) journal = journal.slice(journal.length - settings.limit)
  return journal
}

function copyWindow(window) {
  return {
    address: window.address,
    lifecycleId: window.lifecycleId,
    appId: window.appId,
    workspace: window.workspace,
    workspaceName: window.workspaceName,
    monitor: window.monitor,
    monitorName: window.monitorName,
    x: window.x,
    y: window.y,
    width: window.width,
    height: window.height,
    floating: window.floating,
    fullscreen: window.fullscreen,
    pinned: window.pinned
  }
}

function placementFor(window) {
  return {
    workspace: window.workspace,
    workspaceName: window.workspaceName,
    monitor: window.monitor,
    monitorName: window.monitorName,
    x: window.x,
    y: window.y,
    width: window.width,
    height: window.height
  }
}

function changedPlacementFields(before, after) {
  var fields = []
  var keys = ["workspace", "workspaceName", "monitor", "monitorName", "x", "y", "width", "height"]
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i]
    if (before[key] !== after[key]) fields.push(key)
  }
  return fields
}

function changedStateFields(before, after) {
  var fields = []
  var keys = ["appId", "floating", "fullscreen", "pinned"]
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i]
    if (before[key] !== after[key]) fields.push(key)
  }
  return fields
}

function windowsByAddress(windows) {
  var map = Object.create(null)
  for (var i = 0; i < windows.length; i++) map[windows[i].address] = windows[i]
  return map
}

function sameCompositorSession(before, after) {
  return before.sessionId.length > 0 && before.sessionId === after.sessionId
}

function safeSameSession(before, after) {
  return sameCompositorSession(before, after) && before.observerId.length > 0 && before.observerId === after.observerId
}

function exactAppIds(a, b) {
  var first = boundedText(a, 160)
  var second = boundedText(b, 160)
  return appKey(first) !== "unknown" && first === second
}

function exactWindowIdentity(before, after) {
  return before.address === after.address && before.lifecycleId.length > 0 && before.lifecycleId === after.lifecycleId && exactAppIds(before.appId, after.appId)
}

function diffSnapshots(rawBefore, rawAfter) {
  var before = normalizeSnapshot(rawBefore)
  var after = normalizeSnapshot(rawAfter)
  var canMatchAddresses = safeSameSession(before, after)
  var beforeMap = windowsByAddress(before.windows)
  var afterMap = windowsByAddress(after.windows)
  var added = []
  var removed = []
  var moved = []
  var stateChanged = []
  var unchanged = []
  var i

  for (i = 0; i < before.windows.length; i++) {
    var oldWindow = before.windows[i]
    var newWindow = canMatchAddresses ? afterMap[oldWindow.address] : null
    if (newWindow && !exactWindowIdentity(oldWindow, newWindow)) newWindow = null
    if (!newWindow) {
      removed.push(copyWindow(oldWindow))
      continue
    }

    var placementFields = changedPlacementFields(oldWindow, newWindow)
    var stateFields = changedStateFields(oldWindow, newWindow)
    if (placementFields.length > 0) {
      moved.push({
        address: oldWindow.address,
        lifecycleId: newWindow.lifecycleId,
        appId: newWindow.appId,
        from: placementFor(oldWindow),
        to: placementFor(newWindow),
        fields: placementFields
      })
    }
    if (stateFields.length > 0) {
      stateChanged.push({
        address: oldWindow.address,
        lifecycleId: newWindow.lifecycleId,
        appId: newWindow.appId,
        before: copyWindow(oldWindow),
        after: copyWindow(newWindow),
        fields: stateFields
      })
    }
    if (placementFields.length === 0 && stateFields.length === 0) unchanged.push(copyWindow(newWindow))
  }

  for (i = 0; i < after.windows.length; i++) {
    var candidate = after.windows[i]
    var oldCandidate = canMatchAddresses ? beforeMap[candidate.address] : null
    if (!oldCandidate || !exactWindowIdentity(oldCandidate, candidate)) added.push(copyWindow(candidate))
  }

  return {
    fromHash: snapshotHash(before),
    toHash: snapshotHash(after),
    sameCompositorSession: sameCompositorSession(before, after),
    sameSession: canMatchAddresses,
    added: added,
    removed: removed,
    moved: moved,
    stateChanged: stateChanged,
    unchanged: unchanged,
    focusChanged: before.focusedAddress !== after.focusedAddress,
    focusedAddress: after.focusedAddress,
    summary: {
      added: added.length,
      removed: removed.length,
      moved: moved.length,
      stateChanged: stateChanged.length,
      unchanged: unchanged.length
    }
  }
}

function appKey(value) {
  return boundedText(value, 160).toLowerCase()
}

function launchableSet(values) {
  var set = Object.create(null)
  var i
  if (Array.isArray(values)) {
    for (i = 0; i < values.length; i++) {
      var arrayKey = appKey(values[i])
      if (arrayKey) set[arrayKey] = true
    }
  } else if (values && typeof values === "object") {
    var keys = Object.keys(values)
    for (i = 0; i < keys.length; i++) {
      var objectKey = appKey(keys[i])
      if (objectKey && booleanValue(values[keys[i]])) set[objectKey] = true
    }
  }
  return set
}

function layoutDistance(target, current) {
  var distance = Math.abs(target.x - current.x) + Math.abs(target.y - current.y)
  distance += Math.abs(target.width - current.width) + Math.abs(target.height - current.height)
  if (target.workspace !== current.workspace) distance += 10000000
  if (target.monitor !== current.monitor) distance += 1000000
  return distance
}

function matchWindows(rawTarget, rawCurrent, launchableAppIds) {
  var target = normalizeSnapshot(rawTarget)
  var current = normalizeSnapshot(rawCurrent)
  var availableLaunchers = launchableSet(launchableAppIds)
  var sameSession = safeSameSession(target, current)
  var used = Object.create(null)
  var matches = []
  var i

  for (i = 0; i < target.windows.length; i++) {
    var targetWindow = target.windows[i]
    var exactIndex = -1
    if (sameSession) {
      for (var currentIndex = 0; currentIndex < current.windows.length; currentIndex++) {
        var exactWindow = current.windows[currentIndex]
        if (used[currentIndex]) continue
        if (exactWindowIdentity(targetWindow, exactWindow)) {
          exactIndex = currentIndex
          break
        }
      }
    }

    if (exactIndex >= 0) {
      used[exactIndex] = true
      matches.push({
        target: copyWindow(targetWindow),
        current: copyWindow(current.windows[exactIndex]),
        fidelity: "exact",
        safeExact: true,
        reason: "same compositor session, observer epoch, lifecycle token, address, and application"
      })
    } else {
      matches.push(null)
    }
  }

  for (i = 0; i < target.windows.length; i++) {
    if (matches[i]) continue
    var wanted = target.windows[i]
    var wantedApp = appKey(wanted.appId)
    var bestIndex = -1
    var bestDistance = Infinity

    if (wantedApp !== "unknown") {
      for (var candidateIndex = 0; candidateIndex < current.windows.length; candidateIndex++) {
        var live = current.windows[candidateIndex]
        if (used[candidateIndex] || appKey(live.appId) !== wantedApp) continue
        var distance = layoutDistance(wanted, live)
        if (distance < bestDistance) {
          bestDistance = distance
          bestIndex = candidateIndex
        }
      }
    }

    if (bestIndex >= 0) {
      used[bestIndex] = true
      matches[i] = {
        target: copyWindow(wanted),
        current: copyWindow(current.windows[bestIndex]),
        fidelity: "layout-only",
        safeExact: false,
        reason: "same application, but window contents and identity cannot be proven"
      }
    } else if (wantedApp !== "unknown" && availableLaunchers[wantedApp]) {
      matches[i] = {
        target: copyWindow(wanted),
        current: null,
        fidelity: "launch-only",
        safeExact: false,
        reason: "application is known, but its prior window contents are unavailable"
      }
    } else {
      matches[i] = {
        target: copyWindow(wanted),
        current: null,
        fidelity: "lost",
        safeExact: false,
        reason: "no live window or verified launcher can recover this vessel"
      }
    }
  }

  return matches
}

// For a single-window inspector. Pass sessionContext with targetSessionId,
// currentSessionId, targetObserverId, and currentObserverId. Missing session,
// observer, or lifecycle tokens can never claim exact fidelity.
function classifyFidelity(rawTargetWindow, rawCurrentWindows, launchableAppIds, sessionContext) {
  var targetWindow = normalizeWindow(rawTargetWindow)
  if (!targetWindow) return { fidelity: "lost", safeExact: false, current: null, reason: "invalid target window" }

  var context = sessionContext && typeof sessionContext === "object" ? sessionContext : {}
  var currentSnapshot = rawCurrentWindows && !Array.isArray(rawCurrentWindows) ? rawCurrentWindows : {
    capturedAt: 1,
    sessionId: context.currentSessionId,
    observerId: context.currentObserverId,
    windows: Array.isArray(rawCurrentWindows) ? rawCurrentWindows : []
  }
  var targetSnapshot = {
    capturedAt: 1,
    sessionId: context.targetSessionId,
    observerId: context.targetObserverId,
    windows: [targetWindow]
  }
  var matches = matchWindows(targetSnapshot, currentSnapshot, launchableAppIds)
  return matches.length > 0 ? matches[0] : { fidelity: "lost", safeExact: false, current: null, reason: "invalid target window" }
}

function placementEqual(a, b) {
  return changedPlacementFields(a, b).length === 0
}

function appendUnique(values, value) {
  if (values.indexOf(value) === -1) values.push(value)
}

function restoreFieldPartition(current, target) {
  var executable = []
  var layoutOnly = []
  var currentWorkspace = canonicalWorkspaceTarget(current.workspace, current.workspaceName)
  var targetWorkspace = canonicalWorkspaceTarget(target.workspace, target.workspaceName)

  if (currentWorkspace !== targetWorkspace) {
    if (targetWorkspace) {
      appendUnique(executable, "workspace")
      if (current.workspaceName !== target.workspaceName) appendUnique(executable, "workspaceName")
    } else {
      appendUnique(layoutOnly, "workspace")
      if (current.workspaceName !== target.workspaceName) appendUnique(layoutOnly, "workspaceName")
    }
  }

  if (current.monitor !== target.monitor) appendUnique(layoutOnly, "monitor")
  if (current.monitorName !== target.monitorName) appendUnique(layoutOnly, "monitorName")

  var geometryFields = ["x", "y", "width", "height"]
  for (var i = 0; i < geometryFields.length; i++) {
    var field = geometryFields[i]
    if (current[field] === target[field]) continue
    if (current.floating && target.floating) appendUnique(executable, field)
    else appendUnique(layoutOnly, field)
  }

  var stateFields = changedStateFields(current, target)
  for (var s = 0; s < stateFields.length; s++) appendUnique(layoutOnly, stateFields[s])
  return { executable: executable, layoutOnly: layoutOnly }
}

// Restore plans are inert, whitelisted data. moves contains only windows whose
// identity is proven by compositor session, observer epoch, lifecycle token,
// address, and application. layout-only rows are suggestions requiring manual
// selection; launch-only/lost rows are never converted into commands. Extra
// live windows are listed and always ignored.
function buildRestorePlan(rawTarget, rawCurrent, launchableAppIds) {
  var target = normalizeSnapshot(rawTarget)
  var current = normalizeSnapshot(rawCurrent)
  var matches = matchWindows(target, current, launchableAppIds)
  var matchedCurrent = Object.create(null)
  var moves = []
  var unchanged = []
  var suggestions = []
  var unresolved = []
  var counts = { exact: 0, layoutOnly: 0, launchOnly: 0, lost: 0 }

  for (var i = 0; i < matches.length; i++) {
    var match = matches[i]
    if (match.current) matchedCurrent[match.current.address] = true

    if (match.fidelity === "exact") {
      counts.exact++
      var fields = restoreFieldPartition(match.current, match.target)
      if (fields.executable.length === 0 && fields.layoutOnly.length === 0) {
        unchanged.push({ address: match.current.address, lifecycleId: match.current.lifecycleId, appId: match.current.appId, fidelity: "exact" })
      } else {
        if (fields.executable.length > 0) {
          moves.push({
            kind: "move-live-window",
            address: match.current.address,
            lifecycleId: match.current.lifecycleId,
            appId: match.current.appId,
            fidelity: "exact",
            from: placementFor(match.current),
            to: placementFor(match.target),
            fields: fields.executable,
            requiresConfirmation: true
          })
        }
        if (fields.layoutOnly.length > 0) {
          suggestions.push({
            kind: "layout-only-window",
            targetAddress: match.target.address,
            targetLifecycleId: match.target.lifecycleId,
            candidateAddress: match.current.address,
            candidateLifecycleId: match.current.lifecycleId,
            appId: match.target.appId,
            fidelity: "exact",
            fields: fields.layoutOnly,
            to: placementFor(match.target),
            executable: false,
            reason: "the compositor owns this tiling, monitor, or window-state detail"
          })
        }
      }
    } else if (match.fidelity === "layout-only") {
      counts.layoutOnly++
      suggestions.push({
        kind: "select-live-window",
        targetAddress: match.target.address,
        targetLifecycleId: match.target.lifecycleId,
        candidateAddress: match.current.address,
        candidateLifecycleId: match.current.lifecycleId,
        appId: match.target.appId,
        fidelity: "layout-only",
        to: placementFor(match.target),
        executable: false,
        reason: match.reason
      })
    } else {
      if (match.fidelity === "launch-only") counts.launchOnly++
      else counts.lost++
      unresolved.push({
        targetAddress: match.target.address,
        targetLifecycleId: match.target.lifecycleId,
        appId: match.target.appId,
        fidelity: match.fidelity,
        executable: false,
        reason: match.reason
      })
    }
  }

  var extras = []
  for (var j = 0; j < current.windows.length; j++) {
    if (!matchedCurrent[current.windows[j].address]) extras.push(copyWindow(current.windows[j]))
  }

  return {
    version: RESTORE_PLAN_VERSION,
    targetHash: snapshotHash(target),
    currentHash: snapshotHash(current),
    sessionId: current.sessionId,
    observerId: current.observerId,
    sameCompositorSession: sameCompositorSession(target, current),
    sameSession: safeSameSession(target, current),
    moves: moves,
    unchanged: unchanged,
    suggestions: suggestions,
    unresolved: unresolved,
    ignoredExtraWindows: extras,
    requiresConfirmation: moves.length > 0 || suggestions.length > 0,
    policy: {
      closeExtraWindows: false,
      launchApplications: false,
      executeCommands: false,
      exactMatchesOnly: true
    },
    summary: {
      exact: counts.exact,
      layoutOnly: counts.layoutOnly,
      launchOnly: counts.launchOnly,
      lost: counts.lost,
      moves: moves.length,
      unchanged: unchanged.length,
      suggestions: suggestions.length,
      unresolved: unresolved.length,
      ignoredExtras: extras.length
    }
  }
}

function invalidTideRun(error) {
  return {
    kind: "spacebeach-tide-run",
    version: TIDE_RUN_VERSION,
    valid: false,
    error: boundedText(error, 240) || "invalid recorded journal",
    sourceKind: "recorded-journal",
    synthetic: false,
    seed: "",
    source: null,
    waves: [],
    vessels: [],
    turn: 0,
    score: 0,
    charge: 0,
    pendingIntervention: null,
    revealedThrough: -1,
    history: [],
    status: "invalid",
    outcome: "",
    lastError: ""
  }
}

function vesselIdentity(address, lifecycleId) {
  var canonicalAddress = normalizedAddress(address)
  var canonicalLifecycle = normalizedLifecycleId(lifecycleId)
  if (!canonicalAddress || !canonicalLifecycle) return ""
  return canonicalAddress + "|" + canonicalLifecycle.length + "|" + canonicalLifecycle
}

function eventFromRemoved(window, index) {
  var vesselId = vesselIdentity(window.address, window.lifecycleId)
  return {
    id: "undertow-" + index + "-" + hashText(vesselId),
    kind: "undertow",
    vesselId: vesselId,
    address: window.address,
    lifecycleId: window.lifecycleId,
    appId: window.appId,
    strength: 3
  }
}

function eventFromMoved(change, index) {
  var changedWorkspace = change.from.workspace !== change.to.workspace || change.from.monitor !== change.to.monitor
  var vesselId = vesselIdentity(change.address, change.lifecycleId)
  return {
    id: "crosscurrent-" + index + "-" + hashText(vesselId),
    kind: "crosscurrent",
    vesselId: vesselId,
    address: change.address,
    lifecycleId: change.lifecycleId,
    appId: change.appId,
    strength: changedWorkspace ? 2 : 1,
    to: change.to,
    fields: change.fields.slice()
  }
}

function eventFromState(change, index) {
  var vesselId = vesselIdentity(change.address, change.lifecycleId)
  return {
    id: "squall-" + index + "-" + hashText(vesselId),
    kind: "squall",
    vesselId: vesselId,
    address: change.address,
    lifecycleId: change.lifecycleId,
    appId: change.appId,
    strength: 1,
    fields: change.fields.slice()
  }
}

function eventFromAdded(window, index) {
  var vesselId = vesselIdentity(window.address, window.lifecycleId)
  return {
    id: "arrival-" + index + "-" + hashText(vesselId),
    kind: "arrival",
    vesselId: vesselId,
    address: window.address,
    lifecycleId: window.lifecycleId,
    appId: window.appId,
    strength: 0,
    window: copyWindow(window)
  }
}

function eventsForTransition(before, after) {
  var diff = diffSnapshots(before, after)
  var events = []
  var i
  for (i = 0; i < diff.removed.length; i++) events.push(eventFromRemoved(diff.removed[i], i))
  for (i = 0; i < diff.moved.length; i++) events.push(eventFromMoved(diff.moved[i], i))
  for (i = 0; i < diff.stateChanged.length; i++) events.push(eventFromState(diff.stateChanged[i], i))
  for (i = 0; i < diff.added.length; i++) events.push(eventFromAdded(diff.added[i], i))
  if (diff.focusChanged && diff.focusedAddress) {
    var focusedWindow = null
    for (i = 0; i < after.windows.length; i++) {
      if (after.windows[i].address === diff.focusedAddress) {
        focusedWindow = after.windows[i]
        break
      }
    }
    if (focusedWindow) {
      var focusedVesselId = vesselIdentity(focusedWindow.address, focusedWindow.lifecycleId)
      events.push({
        id: "beacon-" + hashText(focusedVesselId),
        kind: "beacon",
        vesselId: focusedVesselId,
        address: focusedWindow.address,
        lifecycleId: focusedWindow.lifecycleId,
        appId: focusedWindow.appId,
        strength: 0
      })
    }
  }
  if (before.sessionId !== after.sessionId) {
    events.push({
      id: "session-tide-" + hashText(before.sessionId + ":" + after.sessionId),
      kind: "session-tide",
      address: "",
      appId: "",
      strength: 0
    })
  }
  return events
}

function vesselFromWindow(window, origin) {
  return {
    id: vesselIdentity(window.address, window.lifecycleId),
    address: window.address,
    lifecycleId: window.lifecycleId,
    appId: window.appId,
    workspace: window.workspace,
    monitor: window.monitor,
    integrity: 3,
    maxIntegrity: 3,
    alive: true,
    origin: origin === true
  }
}

function normalizedWaveLimit(options) {
  var source = options && typeof options === "object" ? options : {}
  return boundedInteger(source.waveLimit, DEFAULT_WAVE_LIMIT, 1, MAX_WAVE_LIMIT)
}

function deriveTideRun(rawJournal, options) {
  if (!Array.isArray(rawJournal)) return invalidTideRun("Tide Run needs recorded checkpoints; no tutorial state is fabricated")

  var journal = normalizeJournal(rawJournal, { limit: MAX_HISTORY_LIMIT })
  if (journal.length < 2) return invalidTideRun("Tide Run needs at least two changed, timestamped checkpoints")

  var waveLimit = normalizedWaveLimit(options)
  var sourceJournal = []
  var waves = []

  // A run belongs to exactly one uninterrupted observation segment. Search
  // newest-first so an older segment can still be played when the journal's
  // newest checkpoint is an isolated post-gap baseline.
  var segmentEnd = journal.length
  while (segmentEnd > 1 && waves.length === 0) {
    var segmentStart = segmentEnd - 1
    while (segmentStart > 0 && safeSameSession(journal[segmentStart - 1], journal[segmentStart])) segmentStart--

    var candidate = journal.slice(segmentStart, segmentEnd)
    if (candidate.length > waveLimit + 1) candidate = candidate.slice(candidate.length - waveLimit - 1)

    var candidateWaves = []
    for (var i = 1; i < candidate.length; i++) {
      var before = candidate[i - 1]
      var after = candidate[i]
      var events = eventsForTransition(before, after)
      if (events.length === 0) continue
      candidateWaves.push({
        id: "wave-" + (candidateWaves.length + 1) + "-" + after.hash,
        index: candidateWaves.length,
        capturedAt: after.capturedAt,
        reason: after.reason,
        fromHash: before.hash,
        toHash: after.hash,
        aggregate: true,
        events: events
      })
    }

    if (candidateWaves.length > 0) {
      sourceJournal = candidate
      waves = candidateWaves
    }
    segmentEnd = segmentStart
  }

  if (waves.length === 0) return invalidTideRun("Recorded checkpoints contain no playable transitions")

  var first = sourceJournal[0]
  var last = sourceJournal[sourceJournal.length - 1]
  var vessels = []
  for (var j = 0; j < first.windows.length; j++) vessels.push(vesselFromWindow(first.windows[j], true))
  var hashes = []
  for (var k = 0; k < sourceJournal.length; k++) hashes.push(sourceJournal[k].hash)

  return {
    kind: "spacebeach-tide-run",
    version: TIDE_RUN_VERSION,
    valid: true,
    error: "",
    sourceKind: "recorded-journal",
    synthetic: false,
    seed: hashText(hashes.join(":")),
    source: {
      firstCapturedAt: first.capturedAt,
      lastCapturedAt: last.capturedAt,
      firstHash: first.hash,
      lastHash: last.hash,
      checkpointCount: sourceJournal.length,
      transitionCount: waves.length
    },
    waves: waves,
    vessels: vessels,
    originVesselCount: vessels.length,
    turn: 0,
    score: 0,
    charge: Math.min(8, Math.max(2, Math.ceil(waves.length / 3) + 1)),
    pendingIntervention: null,
    revealedThrough: 0,
    history: [],
    status: "ready",
    outcome: "",
    lastError: ""
  }
}

function jsonCopy(value) {
  try {
    return JSON.parse(JSON.stringify(value))
  } catch (error) {
    return null
  }
}

function validRun(value) {
  try {
    if (!value || typeof value !== "object" || value.kind !== "spacebeach-tide-run" || value.version !== TIDE_RUN_VERSION || value.valid !== true) return false
    if (!Array.isArray(value.waves) || !Array.isArray(value.vessels) || !Array.isArray(value.history)) return false
    if (!isFinite(value.turn) || Math.floor(value.turn) !== value.turn || value.turn < 0 || value.turn > value.waves.length) return false
    if (!isFinite(value.charge) || value.charge < 0 || !isFinite(value.score)) return false

    var eventKinds = { undertow: true, crosscurrent: true, squall: true, arrival: true, beacon: true, "session-tide": true }
    for (var w = 0; w < value.waves.length; w++) {
      var wave = value.waves[w]
      if (!wave || typeof wave !== "object" || !Array.isArray(wave.events)) return false
      for (var e = 0; e < wave.events.length; e++) {
        var event = wave.events[e]
        if (!event || typeof event !== "object" || !eventKinds[event.kind]) return false
        if (event.kind !== "session-tide") {
          if (!normalizedAddress(event.address) || !normalizedLifecycleId(event.lifecycleId)) return false
          if (safeString(event.vesselId) !== vesselIdentity(event.address, event.lifecycleId)) return false
        }
        if (event.kind === "arrival") {
          var arrivalWindow = normalizeWindow(event.window)
          if (!arrivalWindow || event.vesselId !== vesselIdentity(arrivalWindow.address, arrivalWindow.lifecycleId)) return false
        }
        if (event.kind === "crosscurrent" && (!event.to || typeof event.to !== "object")) return false
        if (!isFinite(event.strength) || event.strength < 0) return false
      }
    }

    for (var v = 0; v < value.vessels.length; v++) {
      var vessel = value.vessels[v]
      if (!vessel || typeof vessel !== "object" || !normalizedAddress(vessel.address)) return false
      if (!normalizedLifecycleId(vessel.lifecycleId) || safeString(vessel.id) !== vesselIdentity(vessel.address, vessel.lifecycleId)) return false
      if (!isFinite(vessel.integrity) || !isFinite(vessel.maxIntegrity) || vessel.maxIntegrity <= 0) return false
    }
    return true
  } catch (error) {
    return false
  }
}

function interventionCost(kind) {
  if (kind === "anchor") return 1
  if (kind === "drift" || kind === "repair") return 2
  if (kind === "scan") return 1
  if (kind === "none") return 0
  return -1
}

function findVessel(vessels, vesselId) {
  for (var i = 0; i < vessels.length; i++) {
    if (vessels[i].id === vesselId) return vessels[i]
  }
  return null
}

function applyIntervention(rawRun, rawKind, rawAddress) {
  if (!validRun(rawRun)) return invalidTideRun("Cannot intervene in a corrupt Tide Run")
  var run = jsonCopy(rawRun)
  if (!run) return invalidTideRun("Cannot copy Tide Run state")
  if (run.status === "complete") {
    run.lastError = "This Tide Run is already complete"
    return run
  }

  var kind = boundedText(rawKind, 32).toLowerCase()
  var cost = interventionCost(kind)
  if (cost < 0) {
    run.lastError = "Unknown intervention"
    return run
  }
  if (cost > run.charge) {
    run.lastError = "Not enough lighthouse charge"
    return run
  }
  if (kind === "none") {
    if (run.pendingIntervention && run.pendingIntervention.kind === "scan")
      run.revealedThrough = Math.max(-1, Math.min(run.waves.length - 1, run.turn))
    run.pendingIntervention = null
    run.lastError = ""
    return run
  }

  if (run.pendingIntervention) {
    run.lastError = "An intervention is already committed; cancel it or meet the wave"
    return run
  }

  var vesselId = boundedText(rawAddress, 384)
  if (kind !== "scan") {
    var vessel = findVessel(run.vessels, vesselId)
    if (!vessel || !vessel.alive) {
      run.lastError = "Choose a live vessel"
      return run
    }
    if (kind === "repair" && vessel.integrity >= vessel.maxIntegrity) {
      run.lastError = "That vessel is already at full integrity"
      return run
    }
  }

  run.pendingIntervention = {
    kind: kind,
    targetVesselId: kind === "scan" ? "" : vesselId,
    cost: cost
  }
  if (kind === "scan") run.revealedThrough = Math.max(run.revealedThrough, Math.min(run.waves.length - 1, run.turn + 1))
  run.lastError = ""
  return run
}

function resolutionFor(event) {
  return {
    eventId: event.id,
    kind: event.kind,
    vesselId: safeString(event.vesselId),
    address: event.address,
    lifecycleId: safeString(event.lifecycleId),
    ignored: false,
    prevented: 0,
    damage: 0,
    destroyed: false
  }
}

function resolveArrival(run, event, resolution) {
  var vessel = findVessel(run.vessels, event.vesselId)
  if (!vessel) {
    vessel = vesselFromWindow(event.window, false)
    run.vessels.push(vessel)
  } else {
    vessel.appId = event.window.appId
    vessel.workspace = event.window.workspace
    vessel.monitor = event.window.monitor
    vessel.integrity = vessel.maxIntegrity
    vessel.alive = true
    vessel.origin = false
  }
  run.score += 6
  return resolution
}

function resolveDamage(run, event, intervention, resolution) {
  var vessel = findVessel(run.vessels, event.vesselId)
  if (!vessel || !vessel.alive) {
    resolution.ignored = true
    return resolution
  }

  var damage = event.strength
  if (intervention && intervention.targetVesselId === vessel.id) {
    if (intervention.kind === "drift") {
      resolution.prevented = damage
      damage = 0
    } else if (intervention.kind === "anchor") {
      resolution.prevented = Math.min(2, damage)
      damage -= resolution.prevented
    }
  }

  if (event.kind === "crosscurrent" && damage > 0) {
    vessel.workspace = event.to.workspace
    vessel.monitor = event.to.monitor
  }

  vessel.integrity = Math.max(0, vessel.integrity - damage)
  vessel.alive = vessel.integrity > 0
  resolution.damage = damage
  resolution.destroyed = !vessel.alive
  run.score += resolution.prevented * 8
  if (damage > 0 && vessel.alive) run.score += 4
  if (!vessel.alive) run.score -= 20
  return resolution
}

function aliveCounts(run) {
  var alive = 0
  var originAlive = 0
  for (var i = 0; i < run.vessels.length; i++) {
    if (!run.vessels[i].alive) continue
    alive++
    if (run.vessels[i].origin) originAlive++
  }
  return { alive: alive, originAlive: originAlive }
}

function advanceTideRun(rawRun) {
  if (!validRun(rawRun)) return invalidTideRun("Cannot advance a corrupt Tide Run")
  var run = jsonCopy(rawRun)
  if (!run) return invalidTideRun("Cannot copy Tide Run state")
  if (run.status === "complete" || run.turn >= run.waves.length) {
    run.lastError = "This Tide Run is already complete"
    return run
  }

  var wave = run.waves[run.turn]
  var intervention = run.pendingIntervention
  if (intervention) run.charge = Math.max(0, run.charge - intervention.cost)

  if (intervention && intervention.kind === "repair") {
    var repaired = findVessel(run.vessels, intervention.targetVesselId)
    if (repaired && repaired.alive) repaired.integrity = Math.min(repaired.maxIntegrity, repaired.integrity + 1)
  }

  var resolutions = []
  var destroyedThisWave = 0
  run.score += 10

  for (var i = 0; i < wave.events.length; i++) {
    var event = wave.events[i]
    var resolution = resolutionFor(event)
    if (event.kind === "arrival") {
      resolution = resolveArrival(run, event, resolution)
    } else if (event.kind === "beacon") {
      var focused = findVessel(run.vessels, event.vesselId)
      if (focused && focused.alive) run.score += 3
      else resolution.ignored = true
    } else if (event.kind === "session-tide") {
      resolution.ignored = true
    } else {
      resolution = resolveDamage(run, event, intervention, resolution)
      if (resolution.destroyed) destroyedThisWave++
    }
    resolutions.push(resolution)
  }

  if (!intervention) run.score += 3
  if (intervention && intervention.kind === "scan" && destroyedThisWave === 0) run.score += 8 + wave.events.length

  var counts = aliveCounts(run)
  run.history.push({
    turn: run.turn,
    waveId: wave.id,
    intervention: intervention,
    resolutions: resolutions,
    score: run.score,
    alive: counts.alive
  })
  run.turn++
  run.pendingIntervention = null
  run.lastError = ""

  if (run.turn >= run.waves.length) {
    run.status = "complete"
    run.score += counts.alive * 12
    if (run.originVesselCount > 0 && counts.originAlive >= Math.ceil(run.originVesselCount / 2)) run.outcome = "held-the-line"
    else if (counts.alive > 0) run.outcome = "new-constellation"
    else run.outcome = "washed-out"
  } else {
    run.status = "running"
  }
  return run
}

if (typeof module !== "undefined") {
  module.exports = {
    SNAPSHOT_VERSION: SNAPSHOT_VERSION,
    RESTORE_PLAN_VERSION: RESTORE_PLAN_VERSION,
    TIDE_RUN_VERSION: TIDE_RUN_VERSION,
    DEFAULT_HISTORY_LIMIT: DEFAULT_HISTORY_LIMIT,
    MAX_HISTORY_LIMIT: MAX_HISTORY_LIMIT,
    canonicalWorkspaceTarget: canonicalWorkspaceTarget,
    normalizeWindow: normalizeWindow,
    normalizeSnapshot: normalizeSnapshot,
    snapshotHash: snapshotHash,
    normalizeJournal: normalizeJournal,
    appendSnapshot: appendSnapshot,
    diffSnapshots: diffSnapshots,
    matchWindows: matchWindows,
    classifyFidelity: classifyFidelity,
    buildRestorePlan: buildRestorePlan,
    deriveTideRun: deriveTideRun,
    applyIntervention: applyIntervention,
    advanceTideRun: advanceTideRun
  }
}
