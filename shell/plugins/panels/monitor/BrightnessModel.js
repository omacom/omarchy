function initial() {
  return {
    epoch: { monitor: "" },
    percent: 0,
    confirmed: 0,
    available: false,
    revision: 0,
    active: null,
    latest: null
  }
}

function copy(state, changes) {
  return Object.assign({}, state, changes)
}

function readGeneration(state) {
  return state.active || state.latest ? -1 : state.revision
}

function acceptRead(state, monitor, raw, generation) {
  var changedMonitor = monitor !== state.epoch.monitor
  if (!changedMonitor && (state.active || state.latest || generation !== state.revision)) return state

  var available = raw !== "unavailable" && raw !== ""
  var parsed = parseInt(raw, 10)
  var percent = available && isFinite(parsed) ? Math.max(0, Math.min(100, parsed)) : 0
  return copy(state, {
    // A new identity also invalidates completions after switching away and back.
    epoch: changedMonitor ? { monitor: monitor } : state.epoch,
    percent: percent,
    confirmed: available ? percent : changedMonitor ? 0 : state.confirmed,
    available: available,
    revision: state.revision + 1,
    latest: null
  })
}

function request(state, value, osd) {
  var number = Number(value)
  var target = isFinite(number) ? Math.max(1, Math.min(100, Math.round(number))) : 1
  return copy(state, {
    percent: target,
    revision: state.revision + 1,
    latest: {
      epoch: state.epoch,
      target: target,
      osd: !!osd || !!(state.latest && state.latest.osd)
        || !!(state.active && state.active.epoch === state.epoch && state.active.osd)
    }
  })
}

function start(state) {
  if (state.active || !state.latest) return state
  return copy(state, { active: state.latest, latest: null })
}

function finish(state, request, success) {
  if (!request || state.active !== request) return { state: state, verified: null }

  var current = request.epoch === state.epoch
  var latest = state.latest
  if (latest && latest.epoch === request.epoch && latest.target === request.target) latest = null
  var confirmed = current && success ? request.target : state.confirmed
  return {
    state: copy(state, {
      active: null,
      latest: latest,
      confirmed: confirmed,
      percent: current && !latest && !success ? confirmed : state.percent,
      revision: state.revision + 1
    }),
    verified: current && success && !latest && (request.osd || (state.latest && state.latest.osd))
      ? request.target : null
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    initial: initial,
    readGeneration: readGeneration,
    acceptRead: acceptRead,
    request: request,
    start: start,
    finish: finish
  }
}
