// Collapse repeated chat, mail, and CI toasts into one line.
// A single notification stays as it arrived.

function notificationText(row) {
  var e = row || {}
  return String(e.app || "") + " " + String(e.summary || "") + " " + String(e.body || "")
}

function classifyNotification(text) {
  var t = String(text || "").toLowerCase()
  if (/\b(failed|failure|build|pipeline|workflow)\b/.test(t) || t.indexOf("github actions") >= 0 || /\bci\b/.test(t)) return "ci"
  if (/\b(mail|email|inbox|gmail|thunderbird)\b/.test(t)) return "mail"
  if (/\b(slack|discord|signal|matrix|telegram)\b/.test(t) || /#[a-z0-9][a-z0-9_-]*/.test(t)) return "chat"
  return "other"
}

function channelNames(text) {
  var found = []
  var re = /#([a-z0-9][a-z0-9_-]*)/g
  var match
  var t = String(text || "").toLowerCase()
  while ((match = re.exec(t))) {
    if (found.indexOf(match[1]) < 0) found.push(match[1])
  }
  return found
}

function digestLine(rows) {
  var groups = { ci: [], mail: [], chat: [] }
  var i
  for (i = 0; i < rows.length; i++) {
    var kind = classifyNotification(notificationText(rows[i]))
    if (groups[kind]) groups[kind].push(rows[i])
  }

  var parts = []
  if (groups.ci.length >= 2) {
    var failed = false
    for (i = 0; i < groups.ci.length; i++) {
      if (/fail/i.test(notificationText(groups.ci[i]))) failed = true
    }
    parts.push(String(groups.ci.length) + (failed ? " failed builds" : " builds"))
  }
  if (groups.mail.length >= 2) parts.push(String(groups.mail.length) + " emails")
  if (groups.chat.length >= 2) {
    var names = []
    for (i = 0; i < groups.chat.length; i++) {
      var channels = channelNames(notificationText(groups.chat[i]))
      var c
      for (c = 0; c < channels.length; c++) {
        if (names.indexOf(channels[c]) < 0) names.push(channels[c])
      }
    }
    var chat = String(groups.chat.length) + " messages"
    if (names.length > 0) chat += " from #" + names.join(", #")
    parts.push(chat)
  }
  return parts.join(", ")
}

function rowTime(row) {
  var e = row || {}
  if (typeof e.ts === "number") return e.ts
  return e.timestamp || 0
}

function copyRow(row) {
  var e = row || {}
  var out = {}
  var k
  for (k in e) {
    if (Object.prototype.hasOwnProperty.call(e, k)) out[k] = e[k]
  }
  return out
}

function fold(rows) {
  var list = Array.isArray(rows) ? rows : []
  var line = digestLine(list)
  if (!line) return list.map(copyRow)

  var folded = { ci: false, mail: false, chat: false }
  var counts = { ci: 0, mail: 0, chat: 0 }
  var i
  for (i = 0; i < list.length; i++) {
    var kind = classifyNotification(notificationText(list[i]))
    if (counts[kind] !== undefined) counts[kind] += 1
  }
  if (counts.ci >= 2) folded.ci = true
  if (counts.mail >= 2) folded.mail = true
  if (counts.chat >= 2) folded.chat = true

  var newest = null
  var kept = []
  for (i = 0; i < list.length; i++) {
    var rowKind = classifyNotification(notificationText(list[i]))
    if (folded[rowKind]) {
      if (!newest || rowTime(list[i]) >= rowTime(newest)) newest = list[i]
      continue
    }
    kept.push(copyRow(list[i]))
  }

  var digest = copyRow(newest || {})
  digest.key = "ml-fold"
  digest.app = "omarchy"
  digest.summary = line
  digest.body = ""
  digest.bodyLine = ""
  digest.glyph = "󰂛"
  kept.unshift(digest)
  return kept
}

if (typeof module !== "undefined") {
  module.exports = {
    classifyNotification: classifyNotification,
    digestLine: digestLine,
    fold: fold
  }
}
