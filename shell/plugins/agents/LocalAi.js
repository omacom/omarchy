.pragma library
// The card's content, as data. build(c) turns a snapshot plus the panel's navigation state into
// the header, the path, the rows and the footer; LocalAi.qml only draws what comes back and
// turns row actions into controller verbs. Nothing here touches Qt.
//
// c: { snap, view:"home"|"card"|"model", hw, count, pick, slotSel, agentPick, agentOpen, copied,
//      pending, lastVerb, elapsed, localError }
// row: { type:"row"|"sec"|"stat"|"bar"|"status", label, value, action, kind:""|"primary"|"danger"|"dd",
//        selected, disabled, urgent, cells:[{text,mark}], chips:[{text,off}], tabs:[{text,on,action}], stat:[{k,v,u}] }

function gb(n) { return n >= 100 ? Math.round(n) + " GB" : (Math.round(n * 10) / 10) + " GB" }
function kb(n) { return Math.round(n / 1024) + "K" }
function kmg(n) { return n >= 1e6 ? (Math.round(n / 1e5) / 10) + "M" : n >= 1e3 ? (Math.round(n / 100) / 10) + "K" : String(n) }
function mmss(s) { return Math.floor(s / 60) + ":" + (s % 60 < 10 ? "0" : "") + (s % 60) }
function row(label, value, action, o) { o = o || {}; o.type = o.type || "row"; o.label = label; o.value = value || ""; o.action = action || ""; o.kind = o.kind || ""; return o }
function sec(t) { return { type: "sec", label: t, value: "", action: "", kind: "" } }
function capabilities(caps) {
  caps = caps || {}
  return row("can", "", "", { chips: ["chat", "vision", "video", "tools", "reasoning"].map(function(x) {
    return { text: x + (caps[x] == null ? " ?" : ""), off: caps[x] !== true }
  }) })
}

// the eyebrow word for what the controller is doing, and which load step that is
var STEP = { weights: 0, image: 1, engine: 2, check: 3 }
function opWord(snap) {
  var st = snap.state, d = snap.operation.detail || ""
  if (st === "download") return /weights|download|GB|copy/i.test(d) ? "downloading" : /pull/i.test(d) ? "pulling" : "starting"   // the controller's "download" op also covers the checks before a start
  if (st === "unload") return "stopping"
  if (st === "share") return "sharing"
  if (/pulling/.test(d)) return "pulling"
  if (/loading|starting/.test(d) || d === "") return "starting"
  return "checking"
}
function opStep(word) { return { downloading: 0, pulling: 1, starting: 2, checking: 3 }[word] }

function models(snap) { return (snap.models || []).filter(function(m) { return m.state !== "stopped" }) }
function holder(snap, key) { var ms = models(snap); for (var i = 0; i < ms.length; i++) if (ms[i].keys.indexOf(key) >= 0) return ms[i]; return null }
function modelById(snap, id) { var ms = models(snap); for (var i = 0; i < ms.length; i++) if (ms[i].recipeId === id) return ms[i]; return null }
function recipeById(snap, id) { var rs = snap.recipes || []; for (var i = 0; i < rs.length; i++) if (rs[i].id === id) return rs[i]; return null }
function cardByHw(snap, hw) { var cs = snap.cards || []; for (var i = 0; i < cs.length; i++) if (cs[i].hardwareId === hw) return cs[i]; return null }
function cardOfKeys(snap, keys) { var cs = snap.cards || []; for (var i = 0; i < cs.length; i++) if (keys.length && cs[i].keys.indexOf(keys[0]) >= 0) return cs[i]; return null }
function gpu(snap, key) { var gs = snap.gpus || []; for (var i = 0; i < gs.length; i++) if (gs[i].key === key) return gs[i]; return null }
function freeKeys(snap, c) { return c.keys.filter(function(k) { return !holder(snap, k) }) }
function freest(snap, keys) { return keys.slice().sort(function(a, b) { var ga = gpu(snap, a) || {}, gb = gpu(snap, b) || {}; return ((gb.vramGb || 0) - (gb.usedGb || 0)) - ((ga.vramGb || 0) - (ga.usedGb || 0)) })[0] || "" }   // the display card carries the desktop: start elsewhere when there is an elsewhere
// Match the controller's chosen-GPU-first allocation so the UI names the actual replacements.
function loadPlan(snap, recipe, group) {
  var chosen = freest(snap, freeKeys(snap, group)) || group.keys[0], keys = []
  var claims = recipe.claims; if (!claims || !Object.keys(claims).length) { claims = {}; claims[group.hardwareId] = recipe.cards || 1 }
  Object.keys(claims).forEach(function(hw) {
    var pool = (snap.gpus || []).filter(function(g) { return g.hardwareId === hw }).map(function(g) { return g.key })
    if (!pool.length) pool = (cardByHw(snap, hw) || {keys:[]}).keys.slice()
    pool.sort(function(a,b) { return (a === chosen ? 0 : 1) - (b === chosen ? 0 : 1) })
    keys = keys.concat(pool.slice(0, claims[hw]))
  })
  return { gpu: chosen, keys: keys, replaces: models(snap).filter(function(m) { return m.recipeId === recipe.id || m.keys.some(function(k) { return keys.indexOf(k) >= 0 }) }) }
}
function fits(snap, c, n) { return (snap.recipes || []).filter(function(r) { return r.hardwareId === c.hardwareId && r.cards === n }) }
function where(snap, m) { var c = cardOfKeys(snap, m.keys); return (m.cards > 1 ? m.cards + "× " : "") + (c ? c.name : "card") }
function workKeys(snap) { // the cards a running op touches: the model it stops, or the claim of the recipe it starts
  var id = snap.operation.recipeId || "", m = modelById(snap, id)
  if (m) return m.keys
  return snap.selected && snap.selected.recipeId === id ? (snap.selected.keys || []) : []
}
function shortError(c) {
  var e = c.localError || c.snap.error || c.snap.reason || ""
  if (c.localError) return "no answer"
  if (c.snap.reason && !c.snap.error) return /^no supported GPU/.test(e) ? "no card" : /^no validated recipe/.test(e) ? "no recipe" : /^port /.test(e) ? "port busy" : /driver/.test(e) ? "driver" : "refused"
  if (/out of memory|OOM|VRAM/i.test(e)) return "out of VRAM"
  if (/below the .* floor/.test(e)) return "too slow"
  if (/stopped unexpectedly|crash/.test(e)) return "stopped"
  if (/acceptance failed/.test(e)) return "acceptance failed"
  if (/did not answer|not answering/.test(e)) return "no answer"
  if (/refused|dismissed/.test(e)) return "refused"
  if (/docker/i.test(e)) return "docker"
  if (/space/.test(e)) return "disk full"
  return "error"
}

// the update row: what the background check found, and the one verb that applies it. Nothing is
// adopted on its own, so this row is the only way an update happens from the card.
function ago(ts) {
  var s = Math.max(0, Math.round(Date.now() / 1000 - ts))
  return s < 90 ? "just now" : s < 5400 ? Math.round(s / 60) + "m ago" : s < 172800 ? Math.round(s / 3600) + "h ago" : Math.round(s / 86400) + "d ago"
}
function updateRows(snap) {
  var u = snap.update || {}, p = u.plugin || {}, r = u.recipes || {};
  if (u.enabled === false) return []
  var bits = []
  if (p.latest) bits.push("v" + p.latest)
  if (r.new > 0) bits.push(r.relevant > 0 ? r.relevant + " for your card" : r.new + (r.new === 1 ? " recipe" : " recipes"))
  else if (r.staged) bits.push("registry")   // a newer file that changes recipes without adding any
  if (bits.length) return [row("update", bits.join(" + ") + " ›", "update", { kind: "primary" })]
  var checked = ((snap.registryFile || {}).checkedAt || 0)
  return [row("updates", "current" + (checked ? " · checked " + ago(checked) : "") + " ›", "update-check")]
}

// one cell per physical card of a group: what holds it, or its temperature
function cells(c, group, work) {
  var snap = c.snap, keys = work ? workKeys(snap) : [], word = work ? opWord(snap) : ""
  return group.keys.map(function(k) {
    var m = holder(snap, k), g = gpu(snap, k)
    if (work && keys.indexOf(k) >= 0 && word === "stopping") return { text: "freeing", mark: "freeing" }
    if (work && keys.indexOf(k) >= 0 && word !== "sharing") return { text: "claimed", mark: "claimed" }
    if (m && m.state === "error") return { text: "crashed", mark: "crashed" }
    if (m) return { text: "#" + k.split(":")[1] + " ready", mark: "used" }
    return { text: "free" + (g && g.tempC !== null && g.tempC !== undefined ? " · " + g.tempC + "°" : ""), mark: "free" }
  })
}
// A missing sensor is unknown, not zero. Clamp only the drawing; retain the reading.
function meter(label, value, max, unit) {
  var known = typeof value === "number" && isFinite(value) && value >= 0
  return { label: label, value: known ? (Math.round(value * 10) / 10) + unit : "N/A",
    fraction: known && max > 0 ? Math.max(0, Math.min(1, value / max)) : null }
}
function devices(snap, keys) {
  return keys.map(function(k) {
    var g = gpu(snap, k) || {}, m = holder(snap, k), memory = meter("VRAM", g.usedGb, g.vramGb, "")
    if (memory.fraction !== null) memory.value += "/" + g.vramGb + " GB"
    return { label: "GPU " + k.split(":")[1], status: m ? m.state : "available", meters: [
      meter("Temp", g.tempC, 100, "°C"), meter("Usage", g.utilPct, 100, "%"), memory] }
  })
}
function groupModels(snap, group) {
  return models(snap).filter(function(m) { return m.keys.some(function(k) { return group.keys.indexOf(k) >= 0 }) })
}
function gpuUsage(snap, group) {
  var total = 0, today = 0, since = "", estimated = false
  var date = new Date(), day = date.getFullYear() + "-" + ("0" + (date.getMonth()+1)).slice(-2) + "-" + ("0" + date.getDate()).slice(-2)
  ;(snap.gpuUsage || []).forEach(function(h) {
    if (!(h.hardwareId && h.hardwareId === group.hardwareId) && !(h.keys || []).some(function(k) { return group.keys.indexOf(k) >= 0 })) return
    if (h.since && (!since || h.since < since)) since = h.since
    estimated = estimated || !!h.estimated
    Object.keys(h.days || {}).forEach(function(d) {
      var n = h.days[d]
      if (typeof n === "number" && isFinite(n) && n >= 0) { total += n; if (d === day) today += n }
    })
    // Keep the previous sampler's values visible until log replay succeeds.
    ;(h.bins || []).forEach(function(n) { if (typeof n === "number" && isFinite(n) && n >= 0) total += n })
  })
  return { total: total, today: today, since: since, estimated: estimated }
}
function cardRows(c, work) {
  var snap = c.snap, out = [sec(work ? "gpus" : "deployments")], cs = snap.cards || []
  cs.forEach(function(g) {
    var ms = groupModels(snap, g), free = freeKeys(snap, g).length
    var failed = ms.some(function(m) { return m.state === "error" })
    var busy = work && g.keys.some(function(k) { return workKeys(snap).indexOf(k) >= 0 })
    var status = busy ? opWord(snap) : failed ? "error" : ms.length ? (free ? free + " available" : "running") : "available"
    var detail = (failed ? "Needs attention" : ms.length ? "Running" : "Available") + " · "
      + (ms.length === 1 ? ms[0].name : ms.length ? ms.length + " models" : "no model loaded")
      + (ms.length && free ? " · " + free + " free" : "")
    out.push(row(g.count + "× " + g.name, work ? status : "Models ›", work ? "" : "gpu:" + g.hardwareId,
      { status: status, detail: work ? "" : detail, urgent: failed, compact: !work,
        cells: work ? cells(c, g, work) : undefined, devices: work ? devices(snap, g.keys) : undefined }))
  })
  if (!cs.length) out.push(row("GPU", "none detected", "", { urgent: true }))
  return out
}
function usageRows(snap) {
  var rows = (snap.cards || []).map(function(g) {
    return row(g.count + "× " + g.name, "", "", { type: "usage", history: gpuUsage(snap, g) })
  }).sort(function(a, b) { return b.history.total - a.history.total })
  if (!rows.some(function(r) { return r.history.since })) return []
  var peak = Math.max(1, rows[0].history.total)
  rows.forEach(function(r) { r.share = r.history.total / peak })
  return [sec("tokens by gpu")].concat(rows)
}

function launchModel(c) {
  var ready = models(c.snap).filter(function(m) { return m.state === "ready" })
  return ready.filter(function(m) { return m.recipeId === c.launchPick })[0]
    || ready.filter(function(m) { return m.recipeId === (c.snap.running || {}).recipeId })[0] || ready[0]
}
function launchRows(c, m) {
  if (!m) return [row("open agent", "load a model first", "", { disabled: true })]
  var snap = c.snap, agents = m.launchable || [], a = agents.indexOf(c.agentPick) >= 0 ? c.agentPick
    : agents.indexOf((snap.agents || {}).default) >= 0 ? snap.agents.default : agents[0] || ""
  if (!a) return [row("agent", "none can use this model", "", { disabled: true })]
  var rows = [row("agent", a, "agent-toggle", { expanded: !!c.agentOpen })]
  if (c.agentOpen) agents.forEach(function(x) { rows.push(row(x, x === (snap.agents || {}).default ? "default" : "", "agent:" + x, { kind: "dd", selected: x === a })) })
  rows.push(row("open " + a, "terminal ›", "open-agent:" + a + ":" + m.recipeId, { kind: "primary", compact: true }))
  return rows
}

function isWorking(c) {
  return ["download", "starting", "unload", "share"].indexOf(c.snap.state) >= 0 || (c.pending && ["run", "load", "unload", "share"].indexOf(c.lastVerb) >= 0)
}
function changesDeployment(action) { return ["run", "run-again", "stop", "share", "update", "update-check"].indexOf((action || "").split(":")[0]) >= 0 }
function build(c) {
  var out = buildView(c)
  if (isWorking(c) && c.browseWhileWorking) {
    out.rows.unshift(row("Deployment in progress", "View progress ›", "work", { compact: true }))
    out.rows.concat(out.foot).forEach(function(r) { if (changesDeployment(r.action)) r.disabled = true })
  }
  return out
}

function buildView(c) {
  var snap = c.snap, ms = models(snap), op = snap.operation || {}, o = { steps: -1, path: [{ n: "local ai", v: "home", action: "home" }], rows: [], foot: [] }
  var working = isWorking(c)
  var error = !working && c.view === "home" && (c.localError !== "" || snap.state === "error" || (snap.reason || "") !== "")
  var crashed = ms.filter(function(m) { return m.state === "error" })
  // ---- work: progress is the default; navigation may inspect other views safely.
  if (working && !c.browseWhileWorking) {
    var w = snap.state === "download" || snap.state === "starting" || snap.state === "unload" || snap.state === "share" ? opWord(snap) : (c.lastVerb === "unload" ? "stopping" : c.lastVerb === "share" ? "sharing" : snap.selected && !snap.selected.onDisk ? "downloading" : "starting")
    var who = recipeById(snap, op.recipeId) || modelById(snap, op.recipeId) || (snap.selected ? { name: snap.selected.name } : { name: "Local AI" })
    var r = recipeById(snap, op.recipeId) || { sizeGb: 0 }
    o.tone = "work"; o.eyebrow = w; o.title = who.name
    o.sub = w === "downloading" && op.percent > 0 && r.sizeGb ? "weights · " + gb(op.percent / 100 * r.sizeGb) + " of " + gb(r.sizeGb) : (op.detail || { downloading: "weights", pulling: "engine image", starting: "engine warming", checking: "acceptance", stopping: "containers coming down", sharing: "gateway restarting on the tailnet" }[w])
    if (w !== "stopping" && w !== "sharing") { o.steps = opStep(w); var hw = r.hardwareId ? cardByHw(snap, r.hardwareId) : null; if (hw) o.path.push({ n: hw.name.toLowerCase(), v: "card", action: "card:" + hw.hardwareId }) }
    else { var wm = modelById(snap, op.recipeId); o.path.push({ n: (wm ? wm.name : who.name).toLowerCase(), v: "model", action: wm ? "model:" + wm.recipeId : "home" }) }
    o.path.push({ n: w, v: "work", action: "work" })
    var late = op.expectedSeconds > 0 && c.elapsed > op.expectedSeconds * 1.5
    var pct = op.percent > 0 ? op.percent : (op.expectedSeconds > 0 && c.elapsed > 0 ? Math.min(95, Math.round(c.elapsed * 100 / op.expectedSeconds)) : 0)
    o.rows.push(row(w, late ? mmss(c.elapsed) + " · longer than usual" : pct > 0 ? pct + "%" + (c.elapsed > 0 ? " · " + mmss(c.elapsed) : "") : c.elapsed > 0 ? mmss(c.elapsed) : "…", "", { type: "status" }))
    o.rows.push({ type: "bar", percent: pct, label: "", value: "", action: "", kind: "" })
    if (w !== "downloading" && w !== "sharing") o.rows = o.rows.concat(cardRows(c, true).filter(function(x) { return x.type === "sec" || (x.cells && x.cells.some(function(k) { return k.mark === "claimed" || k.mark === "freeing" })) }))
    if (w === "downloading" && !c.pending) o.foot.push(row("stop", "keeps weights", "stop-download", { kind: "danger" }))
    return o
  }
  // ---- error: the last verb failed
  if (error) {
    o.tone = "error"; o.eyebrow = "error"; o.title = shortError(c); o.sub = snap.selected ? snap.selected.name : ""
    var why = c.localError ? "the plugin did not answer" : snap.error || snap.reason || ""
    o.rows.push(row(c.localError ? "plugin" : snap.error ? "engine" : "recipe", why, "", { urgent: true, type: "text" }))
    o.rows.push(row("run again", snap.selected ? snap.selected.name : "", c.localError ? "refresh" : "run-again", { kind: "primary", disabled: !snap.selected && !c.localError }))
    o.rows.push(row("log", "open ›", "log"))
    o.rows = o.rows.concat(cardRows(c, false))
    return o
  }
  var total = (snap.cards || []).reduce(function(a, g) { return a + g.count }, 0)
  var view = c.view === "model" && !modelById(snap, c.slotSel) ? "home" : c.view === "card" && !cardByHw(snap, c.hw) ? "home" : c.view   // a place that is gone falls back to home
  // ---- model: one running model, its numbers first
  if (view === "model") {
    var m = modelById(snap, c.slotSel)
    {
      var cg = cardOfKeys(snap, m.keys)
      o.tone = m.state === "error" ? "error" : "ready"; o.eyebrow = m.state === "error" ? "crashed" : m.state === "ready" ? "ready" : m.state; o.title = m.name
      o.sub = where(snap, m) + " · :" + m.port + (m.shareUrl ? " · shared" : "")
      if (cg) o.path.push({ n: cg.name.toLowerCase(), v: "card", action: "card:" + cg.hardwareId })
      o.path.push({ n: m.name.toLowerCase(), v: "model", action: "model:" + m.recipeId })
      if (m.state !== "ready") {
        o.rows.push(row("engine", m.note || "stopped unexpectedly", "", { urgent: true, type: "text" }))
        o.rows.push(row("run again", m.name, "run-again", { kind: "primary" })); o.rows.push(row("log", "open ›", "log"))
        o.foot.push(row("stop", m.name, "stop:" + m.recipeId, { kind: "danger" })); return o
      }
      o.rows = o.rows.concat(launchRows(c, m))
      o.rows.push({ type: "stat", stat: [{ k: "decode · today avg", v: m.decodeTps > 0 ? String(m.decodeTps) : "n/a", u: m.decodeTps > 0 ? "tok/s" : "" }, { k: "prefill · today avg", v: m.prefillTps > 0 ? String(m.prefillTps) : "n/a", u: m.prefillTps > 0 ? "tok/s" : "" }], label: "", value: "", action: "", kind: "" })
      o.rows.push({ type: "stat", stat: [{ k: "tokens today", v: m.tokensToday == null ? "n/a" : (m.usageEstimated ? "≈" : "") + kmg(m.tokensToday), u: "" }, { k: "kv cache", v: m.kvTokens > 0 ? kb(m.kvTokens) : "n/a", u: m.ctxTokens > 0 ? kb(m.ctxTokens) + " ctx" : "" }], label: "", value: "", action: "", kind: "" })
      o.rows.push(row(where(snap, m), ":" + m.port, "", { devices: devices(snap, m.keys) }))
      o.rows.push(capabilities(m.caps))
      if (m.usageSince) o.rows.push(row("usage tracked since", new Date(m.usageSince).toLocaleTimeString(), ""))
      var sh = snap.share || {}
      if (!sh.available) o.rows.push(row("share", "no tailscale", "", { disabled: true }))
      else if (!m.shareUrl) o.rows.push(row("share", "off · tailnet ›", "share"))
      else o.rows.push(row("share", "on", "share", { chips: [{ text: m.shareUrl.replace(/^https?:\/\//, ""), off: false }, { text: c.copied ? "copied" : "copy", off: false, action: "copy:" + m.recipeId }] }))
      o.foot.push(row("stop", m.name, "stop:" + m.recipeId, { kind: "danger" }))
      return o
    }
  }
  // ---- card: one card type, how many, which recipe
  if (view === "card") {
    var g = cardByHw(snap, c.hw)
    {
      var free = freeKeys(snap, g), n = Math.max(1, Math.min(c.count || 1, g.keys.length))
      o.tone = "idle"; o.eyebrow = "models"; o.title = g.name; o.sub = free.length + " of " + g.keys.length + " free · " + g.vramGb + " GB each"
      o.path.push({ n: g.name.toLowerCase(), v: "card", action: "card:" + g.hardwareId }); if (n > 1) o.path.push({ n: n + " cards", v: "card", action: "count:" + n })
      var running = groupModels(snap, g)
      if (running.length) {
        o.rows.push(sec("running models"))
        running.forEach(function(m) { o.rows.push(row(m.name, "Open ›", "model:" + m.recipeId, { detail: (m.state === "ready" ? "Ready" : m.state) + " · " + where(snap, m), compact: true })) })
      }
      o.rows.push(row(g.count + "× " + g.name, free.length + " available", "", { cells: cells(c, g, false) }))
      if (g.keys.length > 1) { var tabs = []; for (var k = 1; k <= g.keys.length; k++) tabs.push({ text: k + "×", on: k === n, action: "count:" + k }); o.rows.push(row("GPUs to use", "", "", { tabs: tabs })) }
      var list = fits(snap, g, n).filter(function(r) { return !modelById(snap, r.id) })
      o.rows.push(sec("load a model · " + n + (n > 1 ? " GPUs" : " GPU") + " · " + list.length))
      if (!list.length) o.rows.push(row("models", "no unloaded models for " + n + " GPU" + (n > 1 ? "s" : "")))
      var dup = {}; list.forEach(function(r) { dup[r.name] = (dup[r.name] || 0) + 1 })   // two recipes of one model: say which
      list.forEach(function(r) {
        var selected = c.pick === r.id
        o.rows.push(row(dup[r.name] > 1 && r.precision ? r.name + " · " + r.precision : r.name,
          r.onDisk ? gb(r.sizeGb) + " · on disk" : r.partialBytes > 0 ? gb(r.partialBytes / 1073741824) + " of " + gb(r.sizeGb) + " · resume" : gb(r.sizeGb) + " · download",
          "pick:" + r.id, { selected: selected, expanded: selected }))
        if (!selected) return
        o.rows.push(row("context", r.ctxTokens > 0 ? kb(r.ctxTokens) + " per request" : "unknown", "", { child: true, compact: true }))
        o.rows.push(capabilities(r.caps))
        var plan = loadPlan(snap, r, g)
        if (plan.replaces.length) o.rows.push(row("Will replace", plan.replaces.map(function(m) { return m.name + " · " + where(snap, m) }).join(", "), "", { type: "text", child: true }))
        o.rows.push(row(plan.replaces.length ? (r.onDisk ? "Swap model" : "Download & swap") : r.onDisk ? "Load model" : r.partialBytes > 0 ? "Resume download & load" : "Download & load", r.sizeGb > 0 ? gb(r.sizeGb) : "", "run:" + r.id + ":" + n, { kind: "primary", child: true, compact: true }))
      })
      return o
    }
  }
  // ---- home: what you have and what runs on it
  if (!ms.length) { o.tone = (snap.cards || []).length ? "idle" : "error"; o.eyebrow = (snap.cards || []).length ? "idle" : "no card"; o.title = "Local AI"; o.sub = (snap.cards || []).length ? total + " cards free · nothing running" : "no supported GPU" }
  else { var used = ms.reduce(function(a, m) { return a + m.cards }, 0)
    o.tone = crashed.length ? "error" : "ready"; o.eyebrow = crashed.length ? "crashed" : "ready"; o.title = ms.length === 1 ? ms[0].name : ms.length + " models"
    o.sub = "on " + used + " of " + total + " cards" + (ms.some(function(m) { return m.shareUrl }) ? " · shared" : "") }
  var launch = launchModel(c)
  o.rows.push(row("launch agent", launch ? where(snap, launch) + " · " + launch.name : "load a model first", "launcher-toggle", { expanded: !!c.launcherOpen }))
  if (c.launcherOpen && launch) {
    o.rows.push(row("model", where(snap, launch) + " · " + launch.name, "launch-model-toggle", { expanded: !!c.launchModelOpen }))
    if (c.launchModelOpen) ms.filter(function(m) { return m.state === "ready" }).forEach(function(m) {
      o.rows.push(row(where(snap, m), m.name, "launch-model:" + m.recipeId, { kind: "dd", selected: m.recipeId === launch.recipeId }))
    })
  }
  o.rows = o.rows.concat(c.launcherOpen ? launchRows(c, launch) : launchRows(c, launch).slice(-1))
  o.rows = o.rows.concat(cardRows(c, false), usageRows(snap))
  o.foot = updateRows(snap)
  return o
}

// The native view uses the installed controller; it never imports third-party QML.
function backendCommand(manifest) {
  if (!manifest || !manifest.__sourceDir) return ""
  var v = String(manifest.version || "").match(/^(\d+)\.(\d+)\.(\d+)$/)
  if (!v || Number(v[1]) !== 5 || Number(v[2]) < 3 || (Number(v[2]) === 3 && Number(v[3]) < 6)) return ""
  return manifest.__sourceDir.replace(/\/$/, "") + "/bin/omarchy-local-ai"
}
