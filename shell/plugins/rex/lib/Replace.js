.pragma library

// Replacement templates and splitting, with each language's own rules,
// applied to the matches the real engine found.
//
// A template is read once into parts:
//   { kind: "text", value }       literal text
//   { kind: "group", ref }        a group by number or name (0: the match)
//   { kind: "before" } / { kind: "after" }   text before / after the match
//   { kind: "input" }             the whole input (.NET $_)
//   { kind: "last" }              the highest-numbered group that took part (.NET $+)
//   { kind: "case", mode }        "upper", "lower", "end", "upperOne", "lowerOne"
// and then expanded for every match.

// Which template syntax each flavor uses lives in Flavors.js (`replace`).
var SYNTAXES = {
  js: "JavaScript: $1, $<name>, $&, $` and $', $$ for a dollar",
  pcre2: "PCRE2 / PHP: $1, ${1}, ${name}, \\1, $$ for a dollar; \\U \\L \\E \\u \\l change case",
  perl: "Perl: $1, ${1}, $+{name}, $&, $` and $', \\U \\L \\E \\u \\l change case",
  python: "Python: \\1, \\g<1>, \\g<name>, \\g<0>; \\n and \\t are escapes",
  ruby: "Ruby: \\1, \\k<name>, \\0 or \\&, \\` and \\'",
  dotnet: ".NET: $1, ${name}, $&, $` and $', $+ last group, $_ whole input, $$ for a dollar",
  java: "Java: $1, ${name}, \\$ for a dollar, \\\\ for a backslash",
  go: "Go: $1, ${1}, $name, ${name}, $$ for a dollar; $1x means the group named 1x",
  rust: "Rust: $1, ${1}, $name, ${name}, $$ for a dollar; $1x means the group named 1x",
  sed: "sed: \\1 to \\9, & for the match, \\& for &; \\U \\L \\E \\u \\l change case",
  awk: "awk (gsub): & for the match, \\& for a literal &",
  vim: "Vim: \\1 to \\9, & or \\0, \\u \\U \\l \\L \\e \\E change case, \\r for a line break",
  lua: "Lua: %1 to %9, %0 for the match, %% for a percent sign",
  resid: "Resid: $1, ${1}, ${name}, $$ for a dollar",
}

function isDigit(c) { return c >= "0" && c <= "9" }

// Splits a template into parts. Returns { parts, errors } where errors carry
// the offset they apply to.
function parse(template, syntax, groupCount, names) {
  var parts = []
  var errors = []
  var text = ""
  function flush() { if (text !== "") { parts.push({ kind: "text", value: text }); text = "" } }
  function push(part) { flush(); parts.push(part) }
  function hasGroup(n) { return n <= groupCount }
  var i = 0
  var t = String(template || "")
  var n = t.length
  var m

  while (i < n) {
    var c = t.charAt(i)
    var rest = t.substr(i)

    // ---- $-style references ----
    if (c === "$" && (syntax === "js" || syntax === "pcre2" || syntax === "perl" || syntax === "dotnet" || syntax === "java" || syntax === "go" || syntax === "rust" || syntax === "resid")) {
      var next = t.charAt(i + 1)
      if (next === "$" && syntax !== "java" && syntax !== "perl") { text += "$"; i += 2; continue }
      if (syntax === "go" || syntax === "rust") {
        // Go and Rust take the longest name after $, so $1x is group "1x".
        if ((m = /^\$\{([^}]*)\}/.exec(rest)) || (m = /^\$([A-Za-z0-9_]+)/.exec(rest))) {
          push({ kind: "group", ref: /^\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1] })
          i += m[0].length
          continue
        }
        text += "$"
        i++
        continue
      }
      if (syntax === "resid") {
        if ((m = /^\$\{([^}]*)\}/.exec(rest)) || (m = /^\$(\d+)/.exec(rest))) {
          push({ kind: "group", ref: /^\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1] })
          i += m[0].length
          continue
        }
        text += "$"
        i++
        continue
      }
      if (next === "&" && syntax !== "pcre2" && syntax !== "java") { push({ kind: "group", ref: 0 }); i += 2; continue }
      if (next === "`" && (syntax === "js" || syntax === "perl" || syntax === "dotnet")) { push({ kind: "before" }); i += 2; continue }
      if (next === "'" && (syntax === "js" || syntax === "perl" || syntax === "dotnet")) { push({ kind: "after" }); i += 2; continue }
      if (syntax === "dotnet" && next === "_") { push({ kind: "input" }); i += 2; continue }
      if (syntax === "dotnet" && next === "+") { push({ kind: "last" }); i += 2; continue }
      if (syntax === "js" && (m = /^\$<([^>]*)>/.exec(rest))) {
        if (Object.keys(names).length === 0) { text += m[0]; i += m[0].length; continue }
        push({ kind: "group", ref: m[1] })
        i += m[0].length
        continue
      }
      if (syntax === "perl" && (m = /^\$\+\{([^}]*)\}/.exec(rest))) {
        push({ kind: "group", ref: m[1] })
        i += m[0].length
        continue
      }
      if ((m = /^\$\{([^}]*)\}/.exec(rest)) && syntax !== "js") {
        var ref = /^\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1]
        if (typeof ref === "string" && names[ref] === undefined && syntax !== "perl") errors.push({ message: "No group is named '" + ref + "'", start: i, end: i + m[0].length })
        push({ kind: "group", ref: ref })
        i += m[0].length
        continue
      }
      if ((m = /^\$(\d+)/.exec(rest))) {
        var digits = m[1]
        if (syntax === "js") {
          // Two digits when that group exists, else one.
          if (digits.length >= 2 && hasGroup(parseInt(digits.substr(0, 2), 10)) && parseInt(digits.substr(0, 2), 10) > 0) digits = digits.substr(0, 2)
          else digits = digits.substr(0, 1)
          var number = parseInt(digits, 10)
          if (number === 0 || !hasGroup(number)) { text += "$" + digits; i += 1 + digits.length; continue }
          push({ kind: "group", ref: number })
          i += 1 + digits.length
          continue
        }
        if (syntax === "java") {
          // As many digits as still name a group.
          var take = 1
          while (take < digits.length && hasGroup(parseInt(digits.substr(0, take + 1), 10))) take++
          digits = digits.substr(0, take)
          if (!hasGroup(parseInt(digits, 10))) errors.push({ message: "No group " + digits, start: i, end: i + 1 + digits.length })
        } else if (syntax === "dotnet") {
          var longest = digits.length
          while (longest > 1 && !hasGroup(parseInt(digits.substr(0, longest), 10))) longest--
          digits = digits.substr(0, longest)
          if (!hasGroup(parseInt(digits, 10))) { text += "$" + digits; i += 1 + digits.length; continue }
        } else if (syntax === "pcre2") {
          digits = digits.substr(0, 2)
        }
        push({ kind: "group", ref: parseInt(digits, 10) })
        i += 1 + digits.length
        continue
      }
      if (syntax === "java") errors.push({ message: "A $ must be escaped as \\$ in Java", start: i, end: i + 1 })
      text += "$"
      i++
      continue
    }

    // ---- backslash escapes and references ----
    if (c === "\\" && i + 1 < n) {
      var e = t.charAt(i + 1)
      if (syntax === "java") { text += e; i += 2; continue }
      if (syntax === "python") {
        if ((m = /^\\g<([^>]*)>/.exec(rest))) {
          var py = /^\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1]
          if (typeof py === "number" ? py > groupCount : names[py] === undefined) errors.push({ message: "Unknown group " + m[1], start: i, end: i + m[0].length })
          push({ kind: "group", ref: py })
          i += m[0].length
          continue
        }
        if ((m = /^\\(\d{1,2})/.exec(rest)) && m[1].charAt(0) !== "0") {
          var pn = parseInt(m[1], 10)
          if (pn > groupCount && m[1].length === 2) { m[1] = m[1].charAt(0); pn = parseInt(m[1], 10) }
          if (pn > groupCount) errors.push({ message: "Invalid group reference " + pn, start: i, end: i + 1 + m[1].length })
          push({ kind: "group", ref: pn })
          i += 1 + m[1].length
          continue
        }
        var pyEscapes = { n: "\n", t: "\t", r: "\r", f: "\f", v: "\v", a: "\x07", b: "\b", "\\": "\\" }
        if (pyEscapes[e] !== undefined) { text += pyEscapes[e]; i += 2; continue }
        if (/[A-Za-z]/.test(e)) errors.push({ message: "Bad escape \\" + e, start: i, end: i + 2 })
        text += "\\" + e
        i += 2
        continue
      }
      if (syntax === "ruby") {
        if (isDigit(e)) { push({ kind: "group", ref: parseInt(e, 10) }); i += 2; continue }
        if (e === "&") { push({ kind: "group", ref: 0 }); i += 2; continue }
        if (e === "`") { push({ kind: "before" }); i += 2; continue }
        if (e === "'") { push({ kind: "after" }); i += 2; continue }
        if ((m = /^\\k<([^>]*)>/.exec(rest))) { push({ kind: "group", ref: m[1] }); i += m[0].length; continue }
        if (e === "\\") { text += "\\"; i += 2; continue }
        text += "\\" + e
        i += 2
        continue
      }
      if (syntax === "sed" || syntax === "vim" || syntax === "pcre2" || syntax === "perl") {
        if (isDigit(e) && (e !== "0" || syntax === "vim" || syntax === "pcre2")) { push({ kind: "group", ref: parseInt(e, 10) }); i += 2; continue }
        var cases = { U: "upper", L: "lower", E: "end", u: "upperOne", l: "lowerOne", e: "end" }
        if (cases[e] && (e !== "e" || syntax === "vim")) { push({ kind: "case", mode: cases[e] }); i += 2; continue }
        if (e === "n") { text += syntax === "vim" ? "\0" : "\n"; i += 2; continue }
        if (e === "r" && syntax === "vim") { text += "\n"; i += 2; continue }
        if (e === "t") { text += "\t"; i += 2; continue }
        text += e
        i += 2
        continue
      }
      if (syntax === "awk") {
        if (e === "&") { text += "&"; i += 2; continue }
        if (e === "\\") { text += "\\"; i += 2; continue }
      }
    }

    if (c === "&" && (syntax === "sed" || syntax === "awk" || syntax === "vim")) { push({ kind: "group", ref: 0 }); i++; continue }

    if (c === "%" && syntax === "lua") {
      var l = t.charAt(i + 1)
      if (isDigit(l)) {
        var ln = parseInt(l, 10)
        if (ln > Math.max(groupCount, 1) && ln !== 0) errors.push({ message: "Invalid capture index %" + l, start: i, end: i + 2 })
        // With no captures, %1 is the whole match.
        push({ kind: "group", ref: groupCount === 0 && ln === 1 ? 0 : ln })
        i += 2
        continue
      }
      if (l === "%") { text += "%"; i += 2; continue }
      errors.push({ message: "Invalid use of % in a replacement", start: i, end: i + 2 })
      text += l
      i += 2
      continue
    }

    text += c
    i++
  }
  flush()
  return { parts: parts, errors: errors }
}

function groupText(text, matches, base, stride, ref, names) {
  var index = typeof ref === "number" ? ref : names[ref]
  if (index === undefined || index * 2 >= stride) return ""
  var s = matches[base + index * 2], e = matches[base + index * 2 + 1]
  return s < 0 ? "" : text.substring(s, e)
}

// \L and \U hold until \E; \u and \l change only the next character, and
// win over \L or \U, so \u\L$1 capitalizes.
function applyCase(value, state) {
  if (value === "") return value
  if (state.mode === "upper") value = value.toUpperCase()
  else if (state.mode === "lower") value = value.toLowerCase()
  if (state.one === "upperOne") value = value.charAt(0).toUpperCase() + value.substr(1)
  else if (state.one === "lowerOne") value = value.charAt(0).toLowerCase() + value.substr(1)
  state.one = ""
  return value
}

// The template expanded for match i.
function expandOne(parsed, text, matches, i, stride, names) {
  var base = i * stride
  var out = ""
  var state = { mode: "", one: "" }
  for (var p = 0; p < parsed.parts.length; p++) {
    var part = parsed.parts[p]
    var value
    switch (part.kind) {
    case "text": value = part.value; break
    case "group": value = groupText(text, matches, base, stride, part.ref, names); break
    case "before": value = text.substring(0, matches[base]); break
    case "after": value = text.substring(matches[base + 1]); break
    case "input": value = text; break
    case "last":
      value = ""
      for (var g = stride / 2 - 1; g >= 1; g--) {
        if (matches[base + g * 2] >= 0) { value = groupText(text, matches, base, stride, g, names); break }
      }
      break
    case "case":
      if (part.mode === "upperOne" || part.mode === "lowerOne") state.one = part.mode
      else state.mode = part.mode === "end" ? "" : part.mode
      continue
    }
    out += applyCase(value, state)
  }
  return out
}

// Match indices in text order. Engines searching right to left (.NET's
// RightToLeft, the regex module's REVERSE) report matches last first.
function textOrder(matches, count, stride) {
  var order = []
  for (var i = 0; i < count; i++) order.push(i)
  for (var k = 1; k < count; k++) {
    if (matches[k * stride] < matches[(k - 1) * stride]) {
      order.sort(function(a, b) { return matches[a * stride] - matches[b * stride] })
      break
    }
  }
  return order
}

// The text with every match replaced. Returns { text, spans } where spans
// are [start, end] of each replacement in the result, for highlighting.
function substitute(parsed, text, matches, count, stride, names) {
  var out = ""
  var spans = []
  var at = 0
  var order = textOrder(matches, count, stride)
  for (var k = 0; k < count; k++) {
    var i = order[k]
    var s = matches[i * stride], e = matches[i * stride + 1]
    out += text.substring(at, s)
    var replacement = expandOne(parsed, text, matches, i, stride, names)
    spans.push(out.length, out.length + replacement.length)
    out += replacement
    at = e
  }
  out += text.substring(at)
  return { text: out, spans: spans }
}

// The template expanded for every match, one after another.
function list(parsed, text, matches, count, stride, names) {
  var out = []
  for (var i = 0; i < count; i++) out.push(expandOne(parsed, text, matches, i, stride, names))
  return out.join("")
}

// How each language's split treats groups and empty pieces.
var SPLIT = {
  js: { groups: true, skipEmptyMatchAtEdges: true, dropTrailingEmpty: false },
  python: { groups: true, skipEmptyMatchAtEdges: false, dropTrailingEmpty: false },
  perl: { groups: true, skipEmptyMatchAtEdges: true, dropTrailingEmpty: true },
  ruby: { groups: true, skipEmptyMatchAtEdges: true, dropTrailingEmpty: true },
  dotnet: { groups: true, skipEmptyMatchAtEdges: false, dropTrailingEmpty: false },
  java: { groups: false, skipEmptyMatchAtEdges: true, dropTrailingEmpty: true },
  pcre2: { groups: false, skipEmptyMatchAtEdges: false, dropTrailingEmpty: false },
  other: { groups: false, skipEmptyMatchAtEdges: false, dropTrailingEmpty: false },
}

var SPLIT_NOTES = {
  js: "String.prototype.split: captured groups are included between the pieces",
  python: "re.split: captured groups are included between the pieces",
  perl: "split: captured groups are included; trailing empty fields are removed",
  ruby: "String#split: captured groups are included; trailing empty fields are removed",
  dotnet: "Regex.Split: captured groups are included between the pieces",
  java: "String.split: trailing empty strings are removed",
  pcre2: "preg_split: pieces only (PREG_SPLIT_DELIM_CAPTURE would add the groups)",
  other: "The text between the matches",
}

function splitRule(syntax) {
  return SPLIT[syntax] ? syntax : "other"
}

// Pieces of the text between matches: [{ text, group }] where group is 0
// for a piece and the group number for a captured delimiter.
function split(syntax, text, matches, count, stride) {
  var rule = SPLIT[splitRule(syntax)]
  var out = []
  var at = 0
  var order = textOrder(matches, count, stride)
  for (var k = 0; k < count; k++) {
    var i = order[k]
    var s = matches[i * stride], e = matches[i * stride + 1]
    if (rule.skipEmptyMatchAtEdges && s === e && (s === 0 || s === text.length)) continue
    out.push({ text: text.substring(at, s), group: 0 })
    if (rule.groups) {
      for (var g = 1; g < stride / 2; g++) {
        var gs = matches[i * stride + g * 2]
        out.push({ text: gs < 0 ? null : text.substring(gs, matches[i * stride + g * 2 + 1]), group: g })
      }
    }
    at = e
  }
  out.push({ text: text.substring(at), group: 0 })
  if (rule.dropTrailingEmpty) {
    while (out.length > 1 && (out[out.length - 1].text === "" || out[out.length - 1].text === null)) out.pop()
  }
  // Pieces are numbered as the language's array would number them.
  for (var k = 0; k < out.length; k++) out[k].index = k
  return out
}

if (typeof module !== "undefined") module.exports = {
  SYNTAXES: SYNTAXES,
  SPLIT_NOTES: SPLIT_NOTES,
  parse: parse,
  expandOne: expandOne,
  substitute: substitute,
  textOrder: textOrder,
  list: list,
  split: split,
  splitRule: splitRule,
}
