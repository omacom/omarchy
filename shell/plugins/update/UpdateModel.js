// Reads the raw terminal stream of `omarchy update`, or of a one-click
// install, and keeps a picture of it the update window can draw: which step is
// running, which packages are done, and whether anything waits on an answer.
// Every handler sets state rather than accumulating it, so replaying a whole
// transcript after reopening the window lands on the same picture as watching
// it live. Activities are codes; the window turns them into text.

var STEPS = ["prepare", "packages", "configure", "apps", "cleanup"]

var HEADINGS = [
  [/^Prune package cache$/, "prepare", "prune"],
  [/^Create system snapshot$/, "prepare", "snapshot"],
  [/^Update Omarchy dev checkout$/, "prepare", "checkout"],
  [/^Update Arch signing keys$/, "prepare", "keyring"],
  [/^Update system packages$/, "packages", "servers"],
  [/^Running migration/, "configure", "migrations"],
  [/^Orphan system packages$/, "cleanup", "orphans"],
  [/^Removing orphan system packages$/, "cleanup", "orphansRemove"],
  [/^Restarting shell$/, "cleanup", "shell"],
  [/^Update mise tools$/, "apps", "mise"],
  [/^Update AUR packages$/, "apps", "aur"]
]

var ACTIVITIES = [
  [/^:: Synchronizing package databases/, "servers"],
  [/^:: Starting full system upgrade/, "resolving"],
  [/^:: Retrieving packages/, "download"],
  [/checking package integrity/, "verify"],
  [/checking for file conflicts/, "conflicts"],
  [/^:: Processing package changes/, "installing"],
  [/^:: Running post-transaction hooks/, "hooks"],
  [/^:: Searching AUR for updates/, "aurSearch"]
]

// What PAM modules say while sudo waits on them: face (facelock, howdy),
// fingerprint (fprintd), security keys (pam_u2f), smart cards.
var AUTH = /^(Identifying face|Attempting (facial|face)|.*\bface\b.*(recogni|detect|match|identif|timed out)|(Place|Swipe|Lift|Put|Scan) your .*finger|.*fingerprint|Failed to match|Please touch the device|.*\btouch (your|the) (security key|key|device|token)|(Please )?insert .*(security key|smart ?card|token|U2F)|Sorry, try again)/i

// omarchy-update-restart under -y: "<why> Run omarchy-system reboot when ready."
var REBOOT = /^(.*?)\s*Run omarchy-system reboot when ready\.$/

function create() {
  return {
    raw: "",          // escape sequence split across reads
    partial: "",      // text after the last newline
    lineCount: 0,
    markers: 0,
    section: "",      // heading the following lines belong to
    hooks: false,

    step: "",
    activity: "",     // code, see the window's activityText()
    activityArg: "",  // the package or hook it is about
    subject: "",      // "Spotify", from an installer's "Installing Spotify..."
    note: "",         // what an installer said after pacman was done
    opened: false,    // the installer launched the app itself
    reboot: "",       // why the update wants a restart
    packages: {},     // name -> "active" | "done"
    seen: [],         // every package pacman touched, in order
    install: { index: 0, total: 0 },
    download: { percent: -1, speed: "" },
    tools: [],        // { name, from, to }
    errors: [],
    auth: "",
    retry: false,
    ask: null,        // { id, kind, question, yes } while something waits on an answer
    exit: null,

    lines: [],        // cleaned transcript for the details view
    tail: ""
  }
}

function strip(text) {
  return text
    .replace(/\x1b\][^\x07\x1b]*(\x07|\x1b\\)/g, "")
    .replace(/\x1b\[[0-?]*[ -\/]*[@-~]/g, "")
    .replace(/\x1b[()][\x20-\x7e]/g, "")
    .replace(/\x1b./g, "")
    .replace(/[\x00-\x08\x0b-\x0c\x0e-\x1f\x7f]/g, "")
}

// The text a terminal would show for a line redrawn with carriage returns.
function shown(line) {
  var parts = line.split("\r")
  for (var i = parts.length - 1; i >= 0; i--) if (parts[i].trim()) return parts[i]
  return ""
}

function setPackage(s, name, state) {
  if (s.packages[name] === "done") return
  if (!(name in s.packages) && s.seen.indexOf(name) < 0) s.seen.push(name)
  s.packages[name] = state
}

function setActivity(s, code, arg) {
  s.activity = code
  s.activityArg = arg || ""
}

function line(s, text, complete) {
  var t = shown(text).replace(/\s+$/, "")
  var trimmed = t.trim()
  var m
  if (!trimmed) return

  // Anything printed after a question means it was answered.
  if (complete) s.ask = null

  for (var h = 0; h < HEADINGS.length; h++) {
    if (HEADINGS[h][0].test(trimmed)) {
      s.step = HEADINGS[h][1]
      setActivity(s, HEADINGS[h][2])
      s.section = trimmed
      s.hooks = false
      s.auth = ""
      return
    }
  }

  if (complete && AUTH.test(trimmed) && !/^\(\s*\d+\/\d+\)/.test(trimmed)) {
    s.auth = trimmed
    s.retry = /^Sorry/.test(trimmed)
    return
  }
  s.auth = ""

  if (complete && (m = trimmed.match(/^Installing (.+?)\.{3}$/))) {
    if (!s.subject) s.subject = m[1]
    return
  }
  if (complete && /^Opening .+\.{3}$/.test(trimmed)) {
    s.opened = true
    return
  }
  if (complete && (m = trimmed.match(REBOOT))) {
    s.reboot = m[1]
    return
  }

  for (var a = 0; a < ACTIVITIES.length; a++) {
    if (ACTIVITIES[a][0].test(trimmed)) {
      s.note = ""
      setActivity(s, ACTIVITIES[a][1])
      s.hooks = /post-transaction/.test(trimmed)
      if (/^:: Processing/.test(trimmed)) s.download.percent = 100
      return
    }
  }

  // A line cut off mid-name only counts once whitespace shows the name ended.
  if ((m = trimmed.match(/^\(\s*(\d+)\/(\d+)\)\s+(upgrading|installing|reinstalling|downgrading|removing)\s+(\S+)(\s|$)/)) && (complete || m[5])) {
    var name = m[4]
    var finished = /100%$/.test(trimmed) || complete
    // Removals (orphans, replaced packages) aren't updates worth a tile.
    if (m[3] !== "removing") setPackage(s, name, finished ? "done" : "active")
    s.install = { index: Number(m[1]), total: Number(m[2]) }
    s.note = ""
    setActivity(s, m[3] === "removing" ? "removePackage" : "installPackage", name)
    s.hooks = false
    return
  }

  if (s.hooks && (m = trimmed.match(/^\(\s*\d+\/\d+\)\s+(.+?)\.*$/))) {
    setActivity(s, "hook", m[1])
    s.note = ""
    return
  }

  if ((m = trimmed.match(/^Total\s*\(\s*\d+\/\d+\).*?([\d.]+\s*[KMG]?i?B\/s).*?(\d+)%$/))) {
    s.download = { percent: Number(m[2]), speed: m[1].replace(/\s+/, " ") }
    return
  }

  if ((m = trimmed.match(/^==> Making package: (\S+)\s/))) {
    setPackage(s, m[1], "active")
    setActivity(s, "buildPackage", m[1])
    return
  }

  if (/^error:/i.test(trimmed) || /^Something went wrong/.test(trimmed)) {
    if (complete) s.errors.push(trimmed)
    return
  }

  if (!complete) return

  if (/^Upgraded \d+ tools?:$/.test(trimmed)) {
    s.section = "tools"
    return
  }
  if (s.section === "tools" && (m = t.match(/^\s+(\S+)\s+(\S+)\s+\u2192\s+(\S+)$/))) {
    s.tools.push({ name: m[1], from: m[2], to: m[3] })
    return
  }

  if (!/^(warning:|::|==>|\s*->|\(|Total |Packages \(|Net Upgrade|resolving|looking for)/.test(trimmed)) s.note = trimmed
}

// OSC 5150 markers: from run.sh (exit), sudo's prompt (password), and the gum
// stand-in that one-click installs see (confirm, input).
function marker(s, body) {
  var parts = body.split(";")
  s.markers++
  if (parts[0] === "exit") {
    s.exit = Number(parts[1])
    s.ask = null
  } else if (parts[0] === "password") {
    s.ask = { id: "m" + s.markers, kind: "password", retry: s.retry, question: "", yes: true }
    s.retry = false
  } else if (parts[0] === "input") {
    s.ask = { id: "m" + s.markers, kind: "input", secret: parts[1] === "yes", question: parts[2] || "", hint: parts.slice(3).join(";"), yes: true }
  } else if (parts[0] === "confirm") {
    s.ask = { id: "m" + s.markers, kind: "confirm", yes: parts[1] !== "no", question: parts.slice(2).join(";") }
  }
}

function text(s, chunk) {
  var parts = (s.partial + chunk).split("\n")
  s.partial = parts.pop()
  for (var i = 0; i < parts.length; i++) {
    line(s, parts[i], true)
    var shownLine = shown(parts[i])
    if (shownLine.trim() || (s.lines.length && s.lines[s.lines.length - 1] !== "")) s.lines.push(shownLine)
    s.lineCount++
  }
  if (s.lines.length > 4000) s.lines.splice(0, s.lines.length - 3000)

  line(s, s.partial, false)
  s.tail = shown(s.partial)

  // pacman asking without --noconfirm. Its question sits unterminated on the
  // last line until someone answers.
  var m = s.tail.match(/^(?::: )?(.*\?)\s*\[(Y\/n|y\/N)\]\s*$/)
  var id = "p" + s.lineCount + ":" + s.tail.length
  if (m) s.ask = { id: id, kind: "pacman", question: m[1], yes: m[2] === "Y/n" }
  // Anything else left waiting after a colon or question mark: a PAM module
  // asking for a PIN or code, or a prompt nobody planned for.
  else if ((m = s.tail.match(/^\s*(\S.{0,150}?[:?])\s*$/)) && !/\d%/.test(m[1]))
    s.ask = { id: id, kind: "input", question: m[1], secret: /pass|pin\b|code|otp|token|secret|key/i.test(m[1]), yes: true }
  else if (s.ask && s.ask.id.charAt(0) === "p") s.ask = null
}

// Keep back an escape sequence that the read cut in half.
function holdPartialEscape(s, data) {
  s.raw = ""
  var esc = data.lastIndexOf("\x1b")
  if (esc < 0 || esc < data.length - 512) return data
  var rest = data.slice(esc)
  if (/^\x1b(\][^\x07\x1b]*(\x07|\x1b\\)|\[[0-?]*[ -\/]*[@-~]|[()][\x20-\x7e]|[^\[\]()])/.test(rest)) return data
  s.raw = rest
  return data.slice(0, esc)
}

// Feed raw bytes from the transcript; returns the same state object.
function feed(s, chunk) {
  var data = holdPartialEscape(s, s.raw + chunk)
  var re = /\x1b\]5150;([^\x07]*)\x07/g
  var last = 0
  var m
  while ((m = re.exec(data))) {
    text(s, strip(data.slice(last, m.index)))
    marker(s, m[1])
    last = re.lastIndex
  }
  text(s, strip(data.slice(last)))
  return s
}

// 0..1 across the whole update, weighted by where the time actually goes.
var WEIGHTS = { prepare: [0, 0.06], packages: [0.06, 0.74], configure: [0.74, 0.8], apps: [0.8, 0.95], cleanup: [0.95, 1] }

// How far pacman is through downloading and installing, 0..1; -1 before it
// has said anything measurable.
function transfer(s) {
  if (s.hooks) return 0.95
  if (s.download.percent < 0 && !s.install.total) return -1
  var dl = Math.max(0, s.download.percent) / 100
  var inst = s.install.total ? s.install.index / s.install.total : 0
  return Math.min(1, dl * 0.45 + inst * 0.5)
}

// How far through the current update step, 0..1; -1 when there's no way to tell.
function stepFraction(s) {
  return s.step === "packages" ? Math.max(0, transfer(s)) : -1
}

function progress(s) {
  if (s.exit === 0) return 1
  var w = WEIGHTS[s.step]
  if (!w) return 0
  return w[0] + (w[1] - w[0]) * Math.max(0, stepFraction(s))
}

// The installed package an install's tile belongs to, matched by name ("Chrome"
// is google-chrome) so it doesn't sit among the dependencies until resolved.
// ponytail: name match only; anything else waits for the explicit-package
// lookup once pacman is done.
function namesSubject(name, subject) {
  var squash = function(t) { return String(t).toLowerCase().replace(/[^a-z0-9]/g, "") }
  return !!subject && squash(name).indexOf(squash(subject)) >= 0
}

if (typeof module !== "undefined") {
  module.exports = {
    STEPS: STEPS,
    create: create,
    feed: feed,
    transfer: transfer,
    stepFraction: stepFraction,
    progress: progress,
    namesSubject: namesSubject
  }
}
