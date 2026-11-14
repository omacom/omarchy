// What a notification offers: verification codes and links. Every detector guesses at someone else's prose, so a false positive
// (offering "412" from "412 passed") is worse than a miss.
.pragma library
.import "Security.js" as Security

// A code is only a code if the sender says so: by shape alone it is also an
// order number, a port, a build number or a year.
var CODE_WORDS = /\b(code|otp|one[\s-]?time|verification|verify|passcode|pin|2fa|two[\s-]factor|security key|confirm(?:ation)?)\b/i

// "482913", "482 913", "84 2139", "482-913", "G-482913".
var CODE_SHAPE = /(?:^|[^\w-])((?:[A-Za-z]-)?\d{2,4}[\s-]\d{2,5}|(?:[A-Za-z]-)?\d{4,8})(?![\w-])/g

// Uppercase alphanumeric with at least one digit and one letter: "A9F3K2".
var CODE_ALNUM = /(?:^|[^\w-])([A-Z0-9]{5,8})(?![\w-])/g

// The code must sit near its keyword, or "Claude Code" would offer the next
// build number in the body.
var NEAR_BEFORE = 24
var NEAR_AFTER = 72

// "Claude Code", "VS Code": a capitalised word before a capitalised "Code" is
// a product name. "use code SAVE20" and "Your Verification Code" are not.
function isProductName(t, at, word) {
  if (String(word).toLowerCase() !== "code") return false
  if (word[0] !== word[0].toUpperCase()) return false
  var before = t.slice(Math.max(0, at - 20), at).match(/([A-Za-z][\w.]*)\s+$/)
  if (!before || !/^([A-Z][a-z]+|[A-Z]{2,})$/.test(before[1])) return false
  return !CODE_WORDS.test(before[1])
}

function windows(t) {
  var out = [], m
  var re = new RegExp(CODE_WORDS.source, "gi")
  while ((m = re.exec(t)) !== null) {
    if (!isProductName(t, m.index, m[0]))
      out.push([Math.max(0, m.index - NEAR_BEFORE), m.index + m[0].length + NEAR_AFTER])
    if (re.lastIndex === m.index) re.lastIndex++
  }
  return out.slice(0, Security.MAX_CODES)
}

function harvest(t, re, seen, out, keep) {
  var m
  re.lastIndex = 0
  while ((m = re.exec(t)) !== null) {
    var value = keep(m[1])
    if (!value || seen[value]) continue
    seen[value] = true
    out.push(value)
  }
}

function codes(text) {
  var t = Security.bounded(text, Security.MAX_BODY)
  var spans = windows(t)
  if (!spans.length) return []

  var out = [], seen = {}
  for (var i = 0; i < spans.length; i++) {
    harvest(t.slice(spans[i][0], spans[i][1]), CODE_SHAPE, seen, out, function (raw) {
      var value = raw.replace(/^[A-Za-z]-/, "").replace(/[\s-]/g, "")
      if (value.length < 4 || value.length > 8) return ""
      if (/^(19|20)\d\d$/.test(value)) return ""      // a year
      return value
    })
  }
  if (out.length) return out.slice(0, Security.MAX_CODES)

  for (var j = 0; j < spans.length; j++) {
    harvest(t.slice(spans[j][0], spans[j][1]), CODE_ALNUM, seen, out, function (raw) {
      // Needs both a digit and a letter, or it is a word in caps.
      return (/\d/.test(raw) && /[A-Z]/.test(raw)) ? raw : ""
    })
  }
  return out.slice(0, Security.MAX_CODES)
}

function links(text) {
  var out = [], seen = {}, m
  var re = /(https?:\/\/[^\s<>"']+)/g
  while ((m = re.exec(Security.bounded(text, Security.MAX_BODY))) !== null) {
    // Trailing punctuation belongs to the sentence, not the URL.
    var url = Security.safeHttpUrl(m[1].replace(/[.,;:!?)\]}'"]+$/, ""))
    if (!url || seen[url]) continue
    seen[url] = true
    out.push(url)
  }
  return out.slice(0, Security.MAX_CODES)
}

// Everything a card might offer. The body must already have the browser's
// origin anchor lifted off, or every Chrome card offers to open its own site.
function scan(summary, body) {
  var text = String(summary || "") + "\n" + String(body || "")
  var code = codes(text)
  var link = links(text)
  return {
    code: code.length ? code[0] : "",
    codes: code.join(" "),
    link: link.length ? link[0] : ""
  }
}
