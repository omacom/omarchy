// What the Local AI widget shows, as data: the backend's snapshot and the widget's ui state in, a view out.
// Panel.qml draws the view and turns its actions ("verb|arg|arg") into backend verbs. No Qt, no side effects.

function k(n) {
  n = n || 0
  return n >= 1e6 ? Math.round(n / 1e5) / 10 + "M" : n >= 1e3 ? Math.round(n / 100) / 10 + "K" : String(n)
}
function gb(n) { return (n >= 10 ? Math.round(n) : Math.round(n * 10) / 10) + " GB" }
function ctx(n) { return n >= 1024 ? Math.round(n / 1024) + "K" : String(n || 0) }
function dur(s) {
  s = Math.max(0, Math.round(s))
  return s < 3600 ? Math.floor(s / 60) + "m" : Math.floor(s / 3600) + ":" + ("0" + Math.floor(s % 3600 / 60)).slice(-2) + "h"
}
// how long ago a unix time was, in the fewest words: now, 12m ago, 10h ago, 3d ago
function ago(t) {
  var s = Date.now() / 1000 - (t || 0)
  return s < 300 ? "now" : s < 3600 ? Math.round(s / 60) + "m ago" : s < 86400 ? Math.floor(s / 3600) + "h ago" : Math.floor(s / 86400) + "d ago"
}
function home(dir) { return (dir || "").replace(/^\/home\/[^\/]+/, "~") }
function find(list, key, v) { return (list || []).filter(function(x) { return x[key] === v })[0] || null }
function working(d) { return d.state === "download" || d.state === "starting" || d.state === "stopping" }

function parse(text) { try { return JSON.parse(text) } catch (e) { return null } }

// APCA-W3 0.1.9 lightness contrast (Lc) of text on a background. Colors are {r, g, b} in 0..1, as Qt gives them.
// Every text and line color in the panel is picked by the Lc it must reach, so any theme stays readable.
function lum(c) { return 0.2126729 * Math.pow(c.r, 2.4) + 0.7151522 * Math.pow(c.g, 2.4) + 0.072175 * Math.pow(c.b, 2.4) }
function apca(text, bg) {
  var t = lum(text), b = lum(bg)
  if (t < 0.022) t += Math.pow(0.022 - t, 1.414)
  if (b < 0.022) b += Math.pow(0.022 - b, 1.414)
  if (Math.abs(b - t) < 0.0005) return 0
  var s = b > t ? (Math.pow(b, 0.56) - Math.pow(t, 0.57)) * 1.14 : (Math.pow(b, 0.65) - Math.pow(t, 0.62)) * 1.14
  return Math.abs(s) < 0.1 ? 0 : (s > 0 ? s - 0.027 : s + 0.027) * 100
}
function mix(a, b, t) { return { r: a.r + (b.r - a.r) * t, g: a.g + (b.g - a.g) * t, b: a.b + (b.b - a.b) * t, a: 1 } }
// a translucent color as it lands on an opaque one
function over(c, bg) { var a = c.a === undefined ? 1 : c.a; return mix(bg, c, a) }
// the color closest to `from` on the way to `to` that reaches |Lc| >= target on bg; `to` when nothing does
function reach(from, to, bg, target) {
  if (Math.abs(apca(from, bg)) >= target) return mix(from, from, 0)
  if (Math.abs(apca(to, bg)) < target) return mix(to, to, 0)
  var lo = 0, hi = 1
  for (var i = 0; i < 24; i++) {
    var m = (lo + hi) / 2
    if (Math.abs(apca(mix(from, to, m), bg)) >= target) hi = m
    else lo = m
  }
  return mix(from, to, hi)
}
// The panel's tones, all measured on the card surface (the lighter of its two backgrounds, so the worst case):
// ink is for what matters now (a model's name, the primary action, a choice made), value for what a label
// names, label for every label, rule for lines and borders that are not text, alert for problems.
// A theme whose foreground is too soft to lead is pushed toward white (or black, on a light theme) until it does.
var LC = { ink: 90, value: 80, label: 60, rule: 15, alert: 60 }
function tones(ink, bg, surface, urgent) {
  var card = over(surface, bg), white = { r: 1, g: 1, b: 1 }, black = { r: 0, g: 0, b: 0 }
  var far = Math.abs(apca(white, card)) > Math.abs(apca(black, card)) ? white : black
  var top = reach(over(ink, bg), far, card, LC.ink)
  return { ink: top, value: reach(card, top, card, LC.value), label: reach(card, top, card, LC.label),
    rule: reach(card, top, card, LC.rule), alert: reach(urgent, top, card, LC.alert), alertRule: reach(urgent, top, card, LC.rule) }
}

// the bar mark: failed, busy, ready or idle
function mark(s) {
  var d = (s && s.deployments) || []
  if (d.some(function(x) { return x.state === "error" })) return "failed"
  if (d.some(working)) return "busy"
  return d.some(function(x) { return x.state === "ready" }) ? "ready" : ""
}

// a recipe's facts as chips (an icon name and a short text): its format, context and download size
function fmt(f) { return (f || "").replace(/ · /g, " ") }
function spec(r) {
  return [{ text: fmt(r.format) }, r.ctx ? { icon: "context", text: ctx(r.ctx) } : null, r.sizeGb ? { icon: "weights", text: gb(r.sizeGb) } : null].filter(Boolean)
}
// a card's memory and temperature as chips
function health(g) {
  var m = gpuRow(g)
  return [{ icon: "memory", text: m.mem }, m.temp ? { icon: "temp", text: m.temp } : null].filter(Boolean)
}

var SUPPORTED = "url|https://local.sybilsolutions.ai"

// One GPU as a row: on the right its quick action (run its model, run again) or what it is doing; opened, a line
// under it with its memory, what there is to know, and buttons for the rest, Config included for every card with
// a model, so a busy one can be set up too. Rank orders the rows: free, groups, running, crashed, held, no model.
function slot(s, ui, g, at) {
  var kd = find(s.kinds || [], "hw", g.hw), d = (s.deployments || []).filter(function(x) { return x.keys.indexOf(g.key) >= 0 })[0]
  var row = { type: "slot", label: g.name, toggle: "pick|gpu:" + g.key, open: ui.open === "gpu:" + g.key }, note = "", chips = [], items = []
  var config = { label: "Config", action: d ? "more|" + d.id : kd ? "kind|" + kd.hw + "|" + g.key : "" }
  if (!kd) {
    row.rank = 4
    row.note = "no validated model yet"
    items = [{ label: "See supported cards ›", action: SUPPORTED }]
  } else if (d && d.state === "error") {
    row.rank = 2
    row.crashed = true
    row.hint = "crashed"
    row.run = { label: "run again ›", action: "again|" + d.id + "|" + d.keys.join(",") }
    row.dismiss = "stop|" + d.id
    note = d.error || "stopped"
    // dismiss is on the row itself
    items = [{ label: "Run again ›", action: row.run.action, primary: true }, { label: "View logs", action: "log" }, config]
  } else if (d) {
    row.rank = 1
    row.note = (d.state === "ready" ? "running " : d.state === "stopping" ? "stopping " : "starting ") + d.name
    items = (d.state === "ready" ? [{ label: "Open " + d.agent + " ›", action: "open|" + d.id, primary: true }] : [])
      .concat([config, { label: "Stop model", action: "stop|" + d.id, danger: true }])
  } else if (kd.taken.indexOf(g.key) >= 0) {
    row.rank = 3
    row.warn = true
    row.note = "in use by another program"
    items = [config]
  } else {
    var r = kd.models[0]
    row.rank = 0
    row.run = { family: r.family, label: "run " + r.name + " ›", action: "run|" + r.id + "|" + g.key }
    chips = spec(r)
    items = [{ label: "Run ›", action: row.run.action, primary: true }, config]
  }
  chips = health(g).concat(chips)
  return { rank: row.rank, at: at, rows: row.open ? [row, { type: "links", chips: chips, note: note, items: items }] : [row] }
}

// A group, its own row: one model across several free cards of a kind, offered when enough of them are free
// (the first recipe for each number of cards). Its Config is the group's page.
function groups(s, ui) {
  var out = []
  ;(s.kinds || []).forEach(function(kd, at) {
    var first = find(s.gpus || [], "key", kd.keys[0]), seen = {}
    ;(kd.groups || []).forEach(function(gr) {
      if (seen[gr.cards] || kd.free.length < gr.cards) return
      seen[gr.cards] = 1
      var id = "group:" + kd.hw + ":" + gr.cards
      var row = { type: "slot", label: gr.cards + " × " + (first ? first.name : kd.hw), toggle: "pick|" + id, open: ui.open === id,
        run: { family: gr.family, label: "run " + gr.name + " ›", action: "run|" + gr.id + "|" + kd.free.slice(0, gr.cards).join(",") } }
      var links = { type: "links", chips: spec(gr), items: [{ label: "Run ›", action: row.run.action, primary: true },
        { label: "Config", action: "group|" + kd.hw + "|" + gr.cards }] }
      out.push({ rank: 0.5, at: at * 100 + gr.cards, group: true, rows: row.open ? [row, links] : [row] })
    })
  })
  return out
}
function slots(s, ui, keep) {
  return (s.gpus || []).map(function(g, at) { return slot(s, ui, g, at) }).concat(groups(s, ui)).filter(function(x) { return keep(x.rank) })
    .sort(function(a, b) { return a.rank - b.rank || a.at - b.at })
}
function flat(list) { return [].concat.apply([], list.map(function(x) { return x.rows })) }

// home: your lifetime (once there is one), running models as cards (ready, then starting or stopping), then the
// available GPUs as rows: free ones, then groups of free cards, then crashed ones to run again or dismiss. A GPU
// already running a model is not listed again; the rest are one "all GPUs" away.
function homeView(s, ui) {
  if (!s.gpus) return { title: "LOCAL AI", rows: ui.problem ? [{ type: "error", label: ui.problem }] : [] }
  if (!(s.kinds || []).length && !(s.deployments || []).length) return soonView(s)
  var rows = ui.problem ? [{ type: "error", label: ui.problem }] : [], life = s.life || {}
  if (life.requests > 0) rows.push(activity(s))
  ;(s.deployments || []).filter(function(d) { return d.state === "ready" })
    .concat((s.deployments || []).filter(function(d) { return working(d) })).forEach(function(d) { rows.push(card(s, d)) })
  var free = slots(s, ui, function(r) { return r < 1 || r === 2 })
  if (free.length) rows = rows.concat([{ type: "sec", label: "AVAILABLE" }], flat(free))
  if (s.gpus.length > free.filter(function(x) { return !x.group }).length)
    rows.push({ type: "field", icon: "gpu", label: "all GPUs", value: String(s.gpus.length), action: "gpus" })
  return { title: "LOCAL AI", version: s.version, rows: rows }
}

// Your lifetime as an activity grid: a column a week, a row a weekday, each day shaded in four steps by its tokens
// against your busiest day (days still to come are blank), the months under their first week, the totals above
var DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
function activity(s) {
  var life = s.life, days = life.days || [], top = Math.max.apply(null, days.concat([1])), months = [], last = -1
  for (var c = 0; c * 7 < days.length; c++) {
    var m = new Date((life.start + c * 7 * 86400) * 1000).getMonth()
    if (m !== last) months.push({ col: c, label: MONTHS[m] })
    last = m
  }
  // the first, partial month keeps its name unless the next one would crowd it
  if (months.length > 1 && months[1].col < 3) months.shift()
  return { type: "life", tokens: k(s.total) + " tokens", requests: k(life.requests) + (life.requests === 1 ? " request" : " requests"),
    since: "since " + life.since, months: months,
    cells: days.map(function(v, i) { return i > life.today ? -1 : v > 0 ? Math.ceil(v / top * 4) : 0 }),
    // what a hovered day says: its date and its tokens
    labels: days.map(function(v, i) {
      var d = new Date(life.start * 1000)
      d.setDate(d.getDate() + i)
      return DAYS[d.getDay()] + " " + MONTHS[d.getMonth()] + " " + d.getDate() + "  " + (v > 0 ? k(v) + " tokens" : "no tokens")
    }) }
}

// A running model's card: its all-time token line, its name and cards, and Open (or Stop while it starts) and More
function card(s, d) {
  var all = (d.session || {}).all || {}
  var cards = (s.gpus || []).filter(function(g) { return d.keys.indexOf(g.key) >= 0 })
  // a card that does not report its memory in use (Intel) shows only how much it has
  var known = cards.every(function(g) { return g.usedMiB != null })
  var used = cards.reduce(function(a, g) { return a + (g.usedMiB || 0) / 1024 }, 0)
  var total = cards.reduce(function(a, g) { return a + (g.vramGb || 0) }, 0)
  var r = { type: "run", name: d.name, family: d.family, line: all.line || [], more: "more|" + d.id,
    gpu: (cards.length > 1 ? cards.length + " × " : "") + (cards[0] ? cards[0].name : "GPU"),
    mem: total && !working(d) ? (known ? Math.round(used) + " / " : "") + total + " GB" : "" }
  if (d.state === "ready") {
    r.chips = [all.decode ? { icon: "speed", text: all.decode + " tok/s" } : null, { icon: "tokens", text: k(all.tokens) }].filter(Boolean)
    r.primary = { label: "Open " + d.agent, action: "open|" + d.id }
  } else {
    r.progress = d.percent > 0 && d.state !== "stopping" ? d.percent : -1
    r.sub = (d.detail || d.state) + (r.progress >= 0 && d.state !== "download" ? " · " + d.percent + "%" : "")
    r.primary = { label: "Stop model", action: "stop|" + d.id, quiet: true }
  }
  return r
}

// every GPU on the machine, as the same rows as home's, so any of them opens to its actions and Config
function gpusView(s, ui) {
  return { back: true, rows: [{ type: "sec", label: "GPUS" }].concat(flat(slots(s, ui, function() { return true }))) }
}

// nothing to run on: one line on what this machine has, and where the list of supported cards lives
function soonView(s) {
  var found = (s.gpus || []).map(function(g) { return g.name }).filter(function(n, i, a) { return a.indexOf(n) === i })
  return { title: "LOCAL AI", version: s.version, rows: [{ type: "soon",
    head: found.length ? "No tested model for " + found.join(", ") + " yet" : "No supported GPU on this machine",
    action: SUPPORTED }] }
}

// A model's page, the same for a running model, a free card and a group: m is the running model (d) or the chosen
// recipe, with its cards, the models to choose from and what Run does. Its name and what it is, its token line and
// figures when it runs, its cards, what Open uses, its weights, where it answers when it runs, and Run or Log and Stop.
function page(s, ui, m) {
  var run = m.d, u = run ? run.session || {} : {}, all = u.all || {}, line = all.line || [], top = line.length ? line[line.length - 1] : 0
  var facts = spec(run ? Object.assign({}, m, { sizeGb: 0 }) : m)
  facts.splice(1, 0, { icon: "gpu", text: m.cards.length + " × " + (m.cards[0] ? m.cards[0].name : "GPU") })
  if ((m.caps || {}).vision) facts.push({ icon: "vision", text: "" })
  var v = { back: true, rows: [], hero: { name: m.name, family: m.family, chips: facts } }
  if (run) {
    Object.assign(v.hero, { line: line, top: k(top) + " tokens", mid: k(Math.round(top / 2)), since: all.since || "", now: all.last ? ago(all.last) : "now" })
    v.rows.push({ type: "grid", cells: [
      { v: all.decode != null ? String(all.decode) : "–", u: "tok/s", k: "decode avg" },
      { v: all.prefill != null ? k(all.prefill) : "–", u: "tok/s", k: "prefill avg" },
      { v: all.ttft != null ? (all.ttft / 1000).toFixed(1) : "–", u: "s", k: "first token" },
      { v: k(u.tokens), u: "", k: "session" },
      { v: k(s.week), u: "", k: "week" },
      { v: dur((Date.now() - Date.parse(run.startedAt)) / 1000), u: "", k: "up" }] })
  }
  // a card's Config: every model validated for it, the chosen one checked
  if ((m.models || []).length > 1) {
    v.rows.push({ type: "sec", label: "MODEL" })
    m.models.forEach(function(x) {
      v.rows.push({ type: "opt", label: x.name, value: [fmt(x.format), x.ctx ? ctx(x.ctx) : ""].filter(Boolean).join("  "),
        on: x.id === m.id, action: "model|" + x.id })
    })
  }
  v.rows.push({ type: "sec", label: "GPUS" })
  m.cards.forEach(function(g) { v.rows.push(g) })
  v.rows.push({ type: "sec", label: "OPENS WITH" })
  pickers(s, v.rows, ui, run ? run.agent : (s.defaults || {}).agent, run ? run.folder : (s.defaults || {}).folder, run ? run.id : "")
  weights(v.rows, m.weights)
  if (run) {
    v.rows.push({ type: "sec", label: "REACH" })
    v.rows.push({ type: "field", icon: "machine", label: "this machine", value: "127.0.0.1:" + run.port })
    if (s.tailnet) v.rows.push(run.shared
      ? { type: "field", icon: "tailnet", label: "tailnet", value: run.shared, secret: true, action: "copy|" + run.shared }
      : { type: "field", icon: "tailnet", label: "tailnet", value: "share", action: "share|" + run.id })
    if (run.error) v.rows.push({ type: "error", label: run.error })
    v.rows.push({ type: "acts", items: [{ label: "View logs", action: "log" }, { label: "Stop model", action: "stop|" + run.id, danger: true }] })
  } else {
    v.rows.push({ type: "acts", items: [{ label: "Run ›", action: m.action, primary: true }] })
  }
  return v
}

function runView(s, id, ui) {
  var d = find(s.deployments, "id", id)
  if (!d) return null
  return page(s, ui, Object.assign({ d: d }, d, { cards: (s.gpus || []).filter(function(g) { return d.keys.indexOf(g.key) >= 0 }).map(gpuRow) }))
}

// a card kind's page, for the card its row was opened from (else the first free one): the models validated for it,
// the recommended one chosen until another is, and Run when that card is free; a card another program holds says why
function kindView(s, hw, ui) {
  var kd = find(s.kinds, "hw", hw), models = kd ? kd.models : [], pick = find(models, "id", ui.model) || models[0]
  if (!pick) return null
  var key = kd.keys.indexOf(ui.key) >= 0 ? ui.key : kd.free[0], free = kd.free.indexOf(key) >= 0, g = key && find(s.gpus, "key", key)
  return page(s, ui, Object.assign({}, pick, { models: models, action: free ? "run|" + pick.id + "|" + key : "",
    cards: g ? [Object.assign(gpuRow(g), { status: kd.taken.indexOf(key) >= 0 ? "in use by another program" : g.busy ? "running a model" : "" })] : [] }))
}

// a group of free cards of a kind: the models validated for that many cards, on the cards it would run on
function groupView(s, hw, n, ui) {
  var kd = find(s.kinds, "hw", hw), models = kd ? (kd.groups || []).filter(function(x) { return x.cards === n }) : []
  var gr = find(models, "id", ui.model) || models[0]
  if (!gr || kd.free.length < n) return null
  var keys = kd.free.slice(0, n)
  return page(s, ui, Object.assign({}, gr, { models: models, action: "run|" + gr.id + "|" + keys.join(","),
    cards: keys.map(function(key) { return gpuRow(find(s.gpus, "key", key)) }) }))
}

function gpuRow(g) {
  var used = g.usedMiB != null ? g.usedMiB / 1024 : null
  return { type: "gpu", name: g.name, bar: used != null, pct: used != null && g.vramGb ? Math.min(100, Math.round(used / g.vramGb * 100)) : 0,
    mem: (used != null ? Math.round(used * 10) / 10 + " / " : "") + g.vramGb + " GB",
    temp: g.tempC != null ? g.tempC + "°" : "" }
}

function weights(rows, list) {
  if (!(list || []).length) return
  rows.push({ type: "sec", label: "WEIGHTS" })
  list.forEach(function(w) {
    rows.push({ type: "field", logo: "hf", label: "hugging face", value: w.repository,
      action: "url|https://huggingface.co/" + w.repository + "/tree/" + w.revision })
  })
}

// the agent and folder rows, and their choices when open; a choice on a running model also becomes the default
function pickers(s, rows, ui, agent, folder, id) {
  rows.push({ type: "field", icon: "agent", label: "agent", value: agent, action: "pick|agent", drop: true, open: ui.open === "agent" })
  if (ui.open === "agent") (s.agents || []).forEach(function(a) {
    rows.push({ type: "opt", label: a, on: a === agent, action: "set|agent|" + a + "|" + id })
  })
  rows.push({ type: "field", icon: "folder", label: "folder", value: home(folder), action: "pick|folder", drop: true, open: ui.open === "folder" })
  if (ui.open === "folder") {
    ;[folder].concat(s.folders || []).filter(function(f, i, a) { return f && a.indexOf(f) === i }).forEach(function(f) {
      rows.push({ type: "opt", label: home(f), on: f === folder, action: "set|folder|" + f + "|" + id })
    })
    rows.push({ type: "path", id: id })
  }
}

function build(s, ui) {
  s = s || {}
  var v = (ui.view === "run" ? runView(s, ui.id, ui) : ui.view === "kind" ? kindView(s, ui.id, ui) : ui.view === "gpus" ? gpusView(s, ui) : ui.view === "group" ? groupView(s, ui.id, Number(ui.key), ui) : null) || homeView(s, ui)
  return Object.assign(v, { mark: mark(s) })
}

if (typeof module !== "undefined") module.exports = { build: build, parse: parse, apca: apca, reach: reach, tones: tones, over: over, LC: LC }
