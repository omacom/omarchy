.pragma library
.import "Flavors.js" as Flavors

// One parser for every flavor, producing one AST. Offsets are UTF-16 indices
// into the pattern, as QML strings count them, so a node's [start, end) can
// highlight its source directly.
//
// Nodes all carry { type, start, end }. The types:
//   alternation { alternatives }       sequence { items }
//   literal { value, escaped }         dot { newline }        (newline: also matches \n)
//   class { negated, items }           range { from, to }     (inside a class)
//   setop { op, left, right }          ("&&", "--", "~~", "net")
//   chartype { kind, negated }         property { name, negated }
//   posixclass { name, negated }       equivalence { value }  collating { value }
//   anchor { kind }                    group { kind, name, index, flags, body }
//   flags { on, off }                  quantifier { min, max, mode, body }
//   backref { ref, relative }          recursion { ref, relative }
//   conditional { condition, yes, no } verb { name, arg }
//   comment { text }                   quote { items }        callout { arg }
//   balanced { open, close }           frontier { set }       empty {}
//
// max is -1 for an unbounded quantifier; mode is "greedy", "lazy" or
// "possessive". Group kinds: capture, named, noncapture, atomic, lookahead,
// negativeLookahead, lookbehind, negativeLookbehind, branchReset, flags,
// absent, balancing, position (Lua's empty capture), conditionalAnd (Vim \&).
//
// parse() never throws. It returns every syntax error it found with the span
// it applies to, and the AST of whatever it could make sense of.

var INFINITE = -1

function node(type, start, end, extra) {
  var n = { type: type, start: start, end: end }
  for (var key in extra) n[key] = extra[key]
  return n
}

function isDigit(c) { return c >= "0" && c <= "9" }
function isOctal(c) { return c >= "0" && c <= "7" }
function isHex(c) { return /^[0-9a-fA-F]$/.test(c) }
function isWordChar(c) { return /^[A-Za-z0-9_]$/.test(c) }
function isAlpha(c) { return /^[A-Za-z]$/.test(c) }

// ---- shared state -------------------------------------------------------------

function State(pattern, flavor, flags) {
  this.src = pattern
  this.pos = 0
  this.flavor = flavor
  this.f = flavor.features || {}
  this.errors = []
  this.warnings = []
  this.groups = []
  this.groupCount = 0
  this.names = {}
  this.backrefs = []
  this.recursions = []
  // Flags that change how the rest of the pattern is read
  this.mode = {
    x: flags.indexOf("x") >= 0,
    xx: false,
    n: flags.indexOf("n") >= 0,
    U: flags.indexOf("U") >= 0,
    i: flags.indexOf("i") >= 0,
    u: flags.indexOf("u") >= 0 || flags.indexOf("v") >= 0,
    v: flags.indexOf("v") >= 0,
    V1: flags.indexOf("V1") >= 0,
  }
  this.totalGroups = 0
  // JavaScript reads several things differently outside unicode mode
  this.js = flavor.id === "ecmascript" || flavor.id === "node"
  // Set operations and nested classes: JavaScript only under v, the regex
  // module only under V1
  this.setOps = this.js ? this.mode.v : (flavor.id === "python-regex" ? this.mode.V1 : true)
}

State.prototype.peek = function(offset) {
  return this.src.charAt(this.pos + (offset || 0))
}

State.prototype.startsWith = function(text) {
  return this.src.substr(this.pos, text.length) === text
}

State.prototype.eof = function() {
  return this.pos >= this.src.length
}

// The code point at pos, advancing past it; surrogate pairs count once.
State.prototype.nextCodePoint = function() {
  var cp = this.src.codePointAt(this.pos)
  this.pos += cp > 0xffff ? 2 : 1
  return cp
}

State.prototype.error = function(message, start, end) {
  this.errors.push({ message: message, start: start, end: end === undefined ? Math.min(start + 1, this.src.length) : end })
}

State.prototype.warn = function(message, start, end) {
  this.warnings.push({ message: message, start: start, end: end === undefined ? Math.min(start + 1, this.src.length) : end })
}

State.prototype.unsupported = function(what, start, end) {
  // "Lookbehind" reads "lookbehind" mid-sentence; "POSIX classes" stays.
  if (/^[A-Z][a-z]/.test(what)) what = what.charAt(0).toLowerCase() + what.substr(1)
  this.error(this.flavor.name + " does not support " + what, start, end)
}

State.prototype.addGroup = function(name, start, kind) {
  var index = ++this.groupCount
  var group = { index: index, name: name || "", start: start, end: start, kind: kind }
  this.groups.push(group)
  if (name) {
    if (this.names[name] !== undefined && !this.f.duplicateNames && !this.mode.J && !this.inBranchReset)
      this.error("The group name '" + name + "' is already used", start)
    if (this.names[name] === undefined) this.names[name] = index
  }
  return group
}

// Counting capturing groups before parsing tells a backreference such as
// \10 apart from an octal escape, the way PCRE2 and Perl do.
function countGroups(src) {
  var count = 0
  var inClass = false
  for (var i = 0; i < src.length; i++) {
    var c = src.charAt(i)
    if (c === "\\") { i++; continue }
    if (inClass) { if (c === "]") inClass = false; continue }
    if (c === "[") { inClass = true; if (src.charAt(i + 1) === "]") i++; continue }
    if (c !== "(") continue
    if (src.charAt(i + 1) !== "?") { if (src.charAt(i + 1) !== "*") count++; continue }
    var rest = src.substr(i + 2, 2)
    if (/^P</.test(rest) || (/^<[A-Za-z_]/.test(rest)) || /^'[A-Za-z_]/.test(rest)) count++
  }
  return count
}

// ---- Perl family ----------------------------------------------------------------

function parsePerl(st) {
  st.totalGroups = countGroups(st.src)
  var ast = parseAlternation(st, 0)
  while (!st.eof()) {
    // Only a stray ) stops the top level early.
    st.error("Unmatched closing parenthesis", st.pos)
    st.pos++
    var more = parseAlternation(st, 0)
    ast = node("sequence", ast.start, more.end, { items: [ast, more] })
  }
  return ast
}

function skipExtended(st, inClass) {
  if (!(inClass ? st.mode.xx : st.mode.x)) return
  for (;;) {
    var c = st.peek()
    if (c === " " || c === "\t" || c === "\n" || c === "\r" || c === "\f" || c === "\v") { st.pos++; continue }
    if (c === "#" && !inClass) {
      while (!st.eof() && st.peek() !== "\n") st.pos++
      continue
    }
    return
  }
}

function parseAlternation(st, depth) {
  var start = st.pos
  var alternatives = [parseSequence(st, depth)]
  while (st.peek() === "|") {
    if (st.f.alternation === false) st.unsupported("Alternation", st.pos)
    st.pos++
    alternatives.push(parseSequence(st, depth))
  }
  if (alternatives.length === 1) return alternatives[0]
  return node("alternation", start, st.pos, { alternatives: alternatives })
}

function parseSequence(st, depth) {
  var start = st.pos
  var items = []
  for (;;) {
    skipExtended(st, false)
    if (st.eof()) break
    var c = st.peek()
    if (c === "|") break
    if (c === ")") {
      if (depth > 0) break
      // A stray ) at the top level; parsePerl reports it.
      break
    }
    var atom = parseAtom(st, depth)
    if (!atom) continue
    if (atom.type === "flags") {
      // (?i) changes how everything after it in this group reads.
      applyFlags(st, atom)
      items.push(atom)
      continue
    }
    if (atom.type === "quote" && atom.items.length > 1) {
      // A quantifier after \Q...\E repeats only the last quoted character.
      var last = atom.items[atom.items.length - 1]
      items.push(node("quote", atom.start, last.start, { items: atom.items.slice(0, -1) }))
      var tail = node("literal", last.start, atom.end, { value: last.value })
      items.push(parseQuantifiers(st, tail))
      continue
    }
    items.push(parseQuantifiers(st, atom))
  }
  if (items.length === 1) return items[0]
  if (items.length === 0) return node("empty", start, start, {})
  return node("sequence", start, st.pos, { items: items })
}

function applyFlags(st, flagsNode) {
  var on = flagsNode.on, off = flagsNode.off
  if (flagsNode.caret) { st.mode.x = false; st.mode.n = false; st.mode.i = false }
  for (var i = 0; i < on.length; i++) {
    var f = on.charAt(i)
    if (f === "x") { if (on.charAt(i + 1) === "x") { st.mode.xx = true; i++ } st.mode.x = true }
    else if (f === "n") st.mode.n = true
    else if (f === "U") st.mode.U = true
    else if (f === "i") st.mode.i = true
    else if (f === "J") st.mode.J = true
  }
  for (var j = 0; j < off.length; j++) {
    var g = off.charAt(j)
    if (g === "x") { st.mode.x = false; st.mode.xx = false }
    else if (g === "n") st.mode.n = false
    else if (g === "U") st.mode.U = false
    else if (g === "i") st.mode.i = false
  }
}

function saveMode(st) {
  var copy = {}
  for (var key in st.mode) copy[key] = st.mode[key]
  return copy
}

// A quantifier at pos, or null. Does not consume anything when there is none.
function readQuantifier(st) {
  var c = st.peek()
  var start = st.pos
  if (c === "*") { st.pos++; return { min: 0, max: INFINITE, start: start } }
  if (c === "+") { st.pos++; return { min: 1, max: INFINITE, start: start } }
  if (c === "?") { st.pos++; return { min: 0, max: 1, start: start } }
  if (c !== "{") return null
  var m = /^\{(\d*)(,?)(\d*)\}/.exec(st.src.substr(st.pos))
  if (!m || (m[1] === "" && m[3] === "") || (m[1] === "" && m[2] === "")) return null
  if (m[1] === "" && !st.f.openMinRepeat) return null
  var min = m[1] === "" ? 0 : parseInt(m[1], 10)
  var max = m[2] === "" ? min : (m[3] === "" ? INFINITE : parseInt(m[3], 10))
  st.pos += m[0].length
  if (max !== INFINITE && max < min) st.error("The quantifier's maximum is less than its minimum", start, st.pos)
  var limit = st.f.maxRepeat
  if (limit && (min > limit || max > limit)) st.error("Repeat counts above " + limit + " are not allowed in " + st.flavor.name, start, st.pos)
  return { min: min, max: max, start: start }
}

function parseQuantifiers(st, atom) {
  var result = atom
  for (;;) {
    skipExtended(st, false)
    var q = readQuantifier(st)
    if (!q) break
    var mode = st.mode.U ? "lazy" : "greedy"
    if (st.peek() === "?") {
      if (st.f.lazy === false) st.unsupported("Lazy quantifiers", st.pos)
      st.pos++
      mode = st.mode.U ? "greedy" : "lazy"
    } else if (st.peek() === "+") {
      if (!st.f.possessive) st.unsupported("Possessive quantifiers", st.pos)
      st.pos++
      mode = "possessive"
    }
    if (result.type === "quantifier" && result.body === atom) {
      st.error("A quantifier cannot follow another quantifier", q.start, st.pos)
    }
    if (isAssertion(atom) && !st.f.quantifiedAssertions) st.error("An assertion cannot be repeated in " + st.flavor.name, q.start, st.pos)
    if (atom.type === "empty" || atom.type === "flags" || atom.type === "comment")
      st.error("The quantifier has nothing to repeat", q.start, st.pos)
    result = node("quantifier", atom.start, st.pos, { min: q.min, max: q.max, mode: mode, body: result, opStart: q.start })
  }
  return result
}

function isAssertion(n) {
  if (n.type === "anchor") return true
  return n.type === "group" && /ook(ahead|behind)$/.test(n.kind)
}

function parseAtom(st, depth) {
  var start = st.pos
  var c = st.peek()

  if (c === "(") return parseGroup(st, depth)
  if (c === "[") return parseClass(st)
  if (c === ".") { st.pos++; return node("dot", start, st.pos, {}) }
  if (c === "^") { st.pos++; return node("anchor", start, st.pos, { kind: "lineStart" }) }
  if (c === "$") { st.pos++; return node("anchor", start, st.pos, { kind: "lineEnd" }) }
  if (c === "\\") return parseEscape(st)
  if (c === "*" || c === "+" || c === "?") {
    st.pos++
    st.error("The quantifier has nothing to repeat", start, st.pos)
    return null
  }
  if (c === "{") {
    var q = readQuantifier(st)
    if (q) {
      st.error("The quantifier has nothing to repeat", start, st.pos)
      return null
    }
    if (st.f.strayBrace === "error" || (st.mode.u && st.js)) st.error("A literal { must be escaped in " + st.flavor.name, start)
    st.pos++
    return node("literal", start, st.pos, { value: 123 })
  }
  if (c === "}" || c === "]") {
    if (st.mode.u && st.js) st.error("A literal " + c + " must be escaped in unicode mode", start)
    st.pos++
    return node("literal", start, st.pos, { value: c.charCodeAt(0) })
  }
  var cp = st.nextCodePoint()
  return node("literal", start, st.pos, { value: cp })
}

function readName(st, terminator) {
  var start = st.pos
  while (!st.eof() && st.peek() !== terminator && st.peek() !== ")") st.pos++
  var name = st.src.substring(start, st.pos)
  if (st.peek() !== terminator) {
    st.error("The group name is missing its closing " + terminator, start - 1, st.pos)
    return name
  }
  st.pos++
  if (!/^[A-Za-z_\u00c0-\uffff][A-Za-z0-9_\u00c0-\uffff]*$/.test(name))
    st.error(name === "" ? "The group name is empty" : "'" + name + "' is not a valid group name", start, start + Math.max(1, name.length))
  return name
}

function closeGroup(st, start) {
  if (st.peek() === ")") { st.pos++; return true }
  st.error("Missing closing parenthesis", start, st.pos)
  return false
}

function groupBody(st, depth, start, kind, extra) {
  var saved = saveMode(st)
  var body = parseAlternation(st, depth + 1)
  st.mode = saved
  closeGroup(st, start)
  var n = node("group", start, st.pos, { kind: kind, body: body })
  for (var key in extra) n[key] = extra[key]
  return n
}

function capture(st, depth, start, name, kind) {
  var group = st.addGroup(name, start, kind)
  var n = groupBody(st, depth, start, kind, { name: name || "", index: group.index })
  group.end = st.pos
  return n
}

var VERB_ASSERTIONS = {
  pla: "lookahead", positive_lookahead: "lookahead",
  nla: "negativeLookahead", negative_lookahead: "negativeLookahead",
  plb: "lookbehind", positive_lookbehind: "lookbehind",
  nlb: "negativeLookbehind", negative_lookbehind: "negativeLookbehind",
  atomic: "atomic",
}

function parseGroup(st, depth) {
  var start = st.pos
  st.pos++

  if (st.peek() === "*") {
    var m = /^\*([A-Za-z_]+)(?::([^)]*))?\)/.exec(st.src.substr(st.pos))
    var alpha = /^\*([a-z_]+):/.exec(st.src.substr(st.pos))
    if (alpha && VERB_ASSERTIONS[alpha[1]]) {
      st.pos += alpha[0].length
      return lookaround(st, depth, start, VERB_ASSERTIONS[alpha[1]])
    }
    if (m) {
      if (!st.f.verbs) st.unsupported("Backtracking control verbs", start, start + m[0].length + 1)
      st.pos += m[0].length
      return node("verb", start, st.pos, { name: m[1], arg: m[2] === undefined ? "" : m[2] })
    }
  }

  if (st.peek() !== "?") {
    if (st.mode.n) return groupBody(st, depth, start, "noncapture", {})
    return capture(st, depth, start, "", "capture")
  }

  st.pos++
  var c = st.peek()

  if (c === "#") {
    if (!st.f.comments) st.unsupported("Comment groups", start)
    var textStart = st.pos + 1
    while (!st.eof() && st.peek() !== ")") st.pos++
    var text = st.src.substring(textStart, st.pos)
    closeGroup(st, start)
    return node("comment", start, st.pos, { text: text })
  }
  if (c === ":") { st.pos++; return groupBody(st, depth, start, "noncapture", {}) }
  if (c === ">") {
    st.pos++
    if (!st.f.atomic) st.unsupported("Atomic groups", start, st.pos)
    return groupBody(st, depth, start, "atomic", {})
  }
  if (c === "|") {
    st.pos++
    if (!st.f.branchReset) st.unsupported("Branch reset groups", start, st.pos)
    return branchReset(st, depth, start)
  }
  if (c === "=") { st.pos++; return lookaround(st, depth, start, "lookahead") }
  if (c === "!") { st.pos++; return lookaround(st, depth, start, "negativeLookahead") }
  if (c === "~") {
    st.pos++
    if (!st.f.absent) st.unsupported("The absent operator", start, st.pos)
    return groupBody(st, depth, start, "absent", {})
  }
  if (c === "<" && (st.peek(1) === "=" || st.peek(1) === "!")) {
    st.pos += 2
    return lookaround(st, depth, start, st.peek(-1) === "=" ? "lookbehind" : "negativeLookbehind")
  }
  if (c === "<" || (c === "'" && st.f.namedGroups.indexOf("quote") >= 0) || (c === "'" && st.f.balancing)) {
    var close = c === "<" ? ">" : "'"
    st.pos++
    var nameStart = st.pos
    if (st.f.balancing) {
      var bal = new RegExp("^([A-Za-z_][A-Za-z0-9_]*)?-([A-Za-z_][A-Za-z0-9_]*|\\d+)" + close).exec(st.src.substr(st.pos))
      if (bal) {
        st.pos += bal[0].length
        var pushed = bal[1] || ""
        var group = pushed ? st.addGroup(pushed, start, "balancing") : null
        var b = groupBody(st, depth, start, "balancing", { name: pushed, pop: bal[2], index: group ? group.index : 0 })
        if (group) group.end = st.pos
        return b
      }
    }
    var syntax = c === "<" ? "angle" : "quote"
    if (st.f.namedGroups.indexOf(syntax) < 0) st.unsupported("Named groups written (?" + c + "name" + close + ")", start, nameStart)
    var name = readName(st, close)
    return capture(st, depth, start, name, "named")
  }
  if (c === "P") {
    var next = st.peek(1)
    if (next === "<") {
      st.pos += 2
      if (st.f.namedGroups.indexOf("python") < 0) st.unsupported("Named groups written (?P<name>)", start, st.pos)
      return capture(st, depth, start, readName(st, ">"), "named")
    }
    if (next === "=") {
      st.pos += 2
      if (st.f.namedBackrefs.indexOf("python") < 0) st.unsupported("Backreferences written (?P=name)", start, st.pos)
      var refName = readName(st, ")")
      var ref = node("backref", start, st.pos, { ref: refName, relative: false })
      st.backrefs.push(ref)
      return ref
    }
    if (next === ">") {
      st.pos += 2
      if (!st.f.recursion) st.unsupported("Recursion", start, st.pos)
      var recName = readName(st, ")")
      var rec = node("recursion", start, st.pos, { ref: recName, relative: false })
      st.recursions.push(rec)
      return rec
    }
  }
  if (c === "R" || isDigit(c) || ((c === "+" || c === "-") && isDigit(st.peek(1))) || c === "&") {
    var r = /^(R|[+-]?\d+|&[A-Za-z_][A-Za-z0-9_]*)\)/.exec(st.src.substr(st.pos))
    if (r) {
      st.pos += r[0].length
      if (!st.f.recursion) st.unsupported("Recursion", start, st.pos)
      var token = r[1]
      var recursion
      if (token === "R") recursion = node("recursion", start, st.pos, { ref: 0, relative: false })
      else if (token.charAt(0) === "&") recursion = node("recursion", start, st.pos, { ref: token.substr(1), relative: false })
      else recursion = node("recursion", start, st.pos, { ref: parseInt(token, 10), relative: token.charAt(0) === "+" || token.charAt(0) === "-" })
      st.recursions.push(recursion)
      return recursion
    }
  }
  if (c === "(") return parseConditional(st, depth, start)
  if (c === "C") {
    var co = /^C(\d*|`[^`]*`|'[^']*'|"[^"]*"|\{[^}]*\})\)/.exec(st.src.substr(st.pos))
    if (co) {
      st.pos += co[0].length
      if (!st.f.callouts) st.unsupported("Callouts", start, st.pos)
      return node("callout", start, st.pos, { arg: co[1] })
    }
  }

  // Inline flags: (?i) (?i-s) (?^i) (?i:...)
  var flagMatch = /^(\^?)([A-Za-z0-9]*)(?:-([A-Za-z0-9]*))?([:)])/.exec(st.src.substr(st.pos))
  if (flagMatch) {
    var flagsStart = st.pos
    st.pos += flagMatch[0].length
    var on = flagMatch[2], off = flagMatch[3] || ""
    var allowed = st.f.inlineFlags || ""
    if (allowed === "") st.unsupported("Inline flags", start, st.pos)
    else {
      var letters = on + off
      for (var i = 0; i < letters.length; i++) {
        if (allowed.indexOf(letters.charAt(i)) < 0) {
          var at = flagsStart + flagMatch[1].length + (i < on.length ? i : i + 1)
          st.error("'" + letters.charAt(i) + "' is not an inline flag in " + st.flavor.name, at)
        }
      }
      if (off !== "" || flagMatch[3] !== undefined) { if (!st.f.negatedFlags) st.unsupported("Turning flags off", start, st.pos) }
      if (flagMatch[1] && !st.f.caretFlags) st.unsupported("(?^...) flag resets", start, st.pos)
    }
    var info = { on: on, off: off, caret: flagMatch[1] === "^" }
    if (flagMatch[4] === ")") {
      if (st.flavor.id === "python" && start > 0) st.error("Python only accepts global flags like (?" + on + ") at the start of the pattern", start, st.pos)
      return node("flags", start, st.pos, info)
    }
    if (!st.f.scopedFlags) st.unsupported("Scoped flag groups", start, st.pos)
    var saved = saveMode(st)
    applyFlags(st, info)
    var body = parseAlternation(st, depth + 1)
    st.mode = saved
    closeGroup(st, start)
    return node("group", start, st.pos, { kind: "flags", flags: info, body: body })
  }

  st.error("Unknown group syntax (?" + c, start, Math.min(st.pos + 1, st.src.length))
  return groupBody(st, depth, start, "noncapture", {})
}

function lookaround(st, depth, start, kind) {
  var behind = kind.indexOf("behind") >= 0
  if (behind ? st.f.lookbehind === "none" : !st.f.lookahead) st.unsupported(behind ? "Lookbehind" : "Lookahead", start, st.pos)
  var n = groupBody(st, depth, start, kind, {})
  if (behind && st.f.lookbehind !== "none") checkLookbehind(st, n)
  return n
}

function checkLookbehind(st, n) {
  var rule = st.f.lookbehind
  if (rule === "any") return
  var alternatives = n.body.type === "alternation" ? n.body.alternatives : [n.body]
  var widths = alternatives.map(width)
  var where = st.flavor.name
  if (rule === "fixed") {
    for (var i = 0; i < widths.length; i++) {
      if (widths[i].min !== widths[i].max || widths[i].min !== widths[0].min) {
        st.error(where + " needs a lookbehind whose every alternative has the same fixed length", n.start, n.end)
        return
      }
    }
  } else if (rule === "alternatives") {
    for (var j = 0; j < widths.length; j++) {
      if (widths[j].min !== widths[j].max) {
        st.error(where + " needs each lookbehind alternative to have a fixed length", n.start, n.end)
        return
      }
    }
  } else if (rule === "bounded") {
    for (var k = 0; k < widths.length; k++) {
      if (widths[k].max === INFINITE) {
        st.error(where + " needs a lookbehind with a bounded length", n.start, n.end)
        return
      }
      if (widths[k].max > 255) st.error(where + " limits a lookbehind to 255 characters", n.start, n.end)
    }
  }
}

function branchReset(st, depth, start) {
  var saved = saveMode(st)
  var base = st.groupCount
  var highest = base
  var alternatives = []
  var wasIn = st.inBranchReset
  st.inBranchReset = true
  for (;;) {
    st.groupCount = base
    alternatives.push(parseSequence(st, depth + 1))
    highest = Math.max(highest, st.groupCount)
    if (st.peek() !== "|") break
    st.pos++
  }
  st.inBranchReset = wasIn
  st.groupCount = highest
  st.mode = saved
  closeGroup(st, start)
  var body = alternatives.length === 1 ? alternatives[0] : node("alternation", start + 3, st.pos - 1, { alternatives: alternatives })
  return node("group", start, st.pos, { kind: "branchReset", body: body })
}

function parseConditional(st, depth, start) {
  if (!st.f.conditionals) st.unsupported("Conditionals", start, st.pos + 1)
  var condStart = st.pos
  var rest = st.src.substr(st.pos)
  var condition
  var m
  if ((m = /^\((\d+)\)/.exec(rest)) || (m = /^\(([+-]\d+)\)/.exec(rest))) {
    st.pos += m[0].length
    condition = { kind: "group", ref: parseInt(m[1], 10), relative: /^[+-]/.test(m[1]) }
  } else if ((m = /^\(<([A-Za-z_]\w*)>\)/.exec(rest)) || (m = /^\('([A-Za-z_]\w*)'\)/.exec(rest))) {
    st.pos += m[0].length
    condition = { kind: "group", ref: m[1] }
  } else if ((m = /^\((R\d*|R&[A-Za-z_]\w*)\)/.exec(rest))) {
    st.pos += m[0].length
    condition = { kind: "recursion", ref: m[1].substr(1).replace(/^&/, "") }
  } else if ((m = /^\(DEFINE\)/.exec(rest))) {
    st.pos += m[0].length
    condition = { kind: "define" }
  } else if (/^\(\?(?:=|!|<=|<!)/.test(rest)) {
    var assertStart = st.pos
    st.pos += 2
    var kind = "lookahead"
    if (st.peek() === "=") { st.pos++ }
    else if (st.peek() === "!") { st.pos++; kind = "negativeLookahead" }
    else { st.pos += 2; kind = st.peek(-1) === "=" ? "lookbehind" : "negativeLookbehind" }
    condition = { kind: "assert", assertion: groupBody(st, depth + 1, assertStart, kind, {}) }
  } else if ((m = /^\(([A-Za-z_]\w*)\)/.exec(rest))) {
    st.pos += m[0].length
    condition = { kind: "group", ref: m[1] }
  } else {
    // .NET: any expression as the condition
    var exprStart = st.pos
    st.pos++
    var expr = parseAlternation(st, depth + 1)
    closeGroup(st, exprStart)
    condition = { kind: "assert", assertion: node("group", exprStart, st.pos, { kind: "lookahead", body: expr }) }
  }
  condition.start = condStart
  condition.end = st.pos

  var saved = saveMode(st)
  var yes = parseSequence(st, depth + 1)
  var no = null
  if (st.peek() === "|") {
    st.pos++
    no = parseSequence(st, depth + 1)
    if (st.peek() === "|") st.error("A conditional group has at most two alternatives", st.pos)
    while (st.peek() === "|") { st.pos++; parseSequence(st, depth + 1) }
  }
  st.mode = saved
  closeGroup(st, start)
  return node("conditional", start, st.pos, { condition: condition, yes: yes, no: no })
}

// ---- escapes ------------------------------------------------------------------

var CHARTYPES = {
  digit: "d", word: "w", space: "s", hspace: "h", vspace: "v", hex: "h",
}

function escapeMeaning(st, letter) {
  var meaning = st.f.escapes[letter.toLowerCase()]
  if (meaning === undefined) meaning = st.f.escapes[letter]
  return meaning
}

function parseEscape(st) {
  var start = st.pos
  st.pos++
  if (st.eof()) {
    st.error("The pattern ends with a lone backslash", start)
    return node("literal", start, st.pos, { value: 92, escaped: true })
  }
  var c = st.peek()

  // Anchors
  if ("AzZGbB".indexOf(c) >= 0 && st.f.anchors.indexOf(c) >= 0) {
    st.pos++
    var kinds = { A: "start", z: "end", Z: "endOrNewline", G: "searchStart", b: "wordBoundary", B: "notWordBoundary" }
    var kind = kinds[c]
    if (c === "Z" && st.flavor.id.indexOf("python") === 0) kind = "end"
    return node("anchor", start, st.pos, { kind: kind })
  }

  if (isDigit(c)) return parseDigitEscape(st, start)

  if (!isAlpha(c)) {
    var cp = st.nextCodePoint()
    return node("literal", start, st.pos, { value: cp, escaped: true })
  }

  var meaning = st.f.escapes[c]
  var lower = c.toLowerCase()
  // Uppercase class escapes negate their lowercase class
  if (meaning === undefined && c !== lower) {
    var base = st.f.escapes[lower]
    if (base && (CHARTYPES[base] !== undefined) ) {
      st.pos++
      return node("chartype", start, st.pos, { kind: base, negated: true })
    }
    if (base === "property" && c === "P") meaning = "property"
  }
  if (meaning === undefined) {
    st.pos++
    if (st.f.unknownEscape === "error" || (st.js && st.mode.u)) st.error("\\" + c + " is not a valid escape in " + st.flavor.name, start, st.pos)
    return node("literal", start, st.pos, { value: c.charCodeAt(0), escaped: true })
  }

  st.pos++
  if (CHARTYPES[meaning] !== undefined || meaning === "newline" || meaning === "notnewline" || meaning === "grapheme")
    return node("chartype", start, st.pos, { kind: meaning, negated: false })
  if (meaning.indexOf("char:") === 0)
    return node("literal", start, st.pos, { value: parseInt(meaning.substr(5), 10), escaped: true })
  return parseSpecialEscape(st, start, c, meaning, false)
}

// Escapes that read more than their letter. Shared with classes.
function parseSpecialEscape(st, start, c, meaning, inClass) {
  var rest = st.src.substr(st.pos)
  var m
  switch (meaning) {
  case "hexEscape":
    if (!st.js && (m = /^\{([0-9a-fA-F]+)\}/.exec(rest)) && st.flavor.id !== "python" && st.flavor.id !== "dotnet") {
      st.pos += m[0].length
      return codeLiteral(st, start, parseInt(m[1], 16))
    }
    if ((m = /^[0-9a-fA-F]{2}/.exec(rest))) {
      st.pos += 2
      return codeLiteral(st, start, parseInt(m[0], 16))
    }
    if ((m = /^[0-9a-fA-F]/.exec(rest)) && (st.flavor.id === "pcre2" || st.flavor.id === "perl" || st.flavor.id === "ruby")) {
      st.pos += 1
      return codeLiteral(st, start, parseInt(m[0], 16))
    }
    if (st.js && !st.mode.u) return node("literal", start, st.pos, { value: 120, escaped: true })
    st.error("\\x needs hexadecimal digits", start, st.pos)
    return codeLiteral(st, start, 0)
  case "unicodeEscape":
    if (c === "U") {
      if ((m = /^[0-9a-fA-F]{8}/.exec(rest))) { st.pos += 8; return codeLiteral(st, start, parseInt(m[0], 16)) }
      st.error("\\U needs eight hexadecimal digits", start, st.pos)
      return codeLiteral(st, start, 0)
    }
    if ((m = /^\{([0-9a-fA-F]+)\}/.exec(rest)) && (st.mode.u || st.flavor.id === "rust" || st.flavor.id === "resid")) {
      st.pos += m[0].length
      return codeLiteral(st, start, parseInt(m[1], 16))
    }
    if ((m = /^[0-9a-fA-F]{4}/.exec(rest))) {
      st.pos += 4
      var value = parseInt(m[0], 16)
      // A surrogate pair written as two \u escapes is one code point.
      var low = /^\\u([dD][c-fC-F][0-9a-fA-F]{2})/.exec(st.src.substr(st.pos))
      if (value >= 0xd800 && value <= 0xdbff && low && st.mode.u) {
        st.pos += 6
        value = 0x10000 + ((value - 0xd800) << 10) + (parseInt(low[1], 16) - 0xdc00)
      }
      return codeLiteral(st, start, value)
    }
    if (st.js && !st.mode.u) return node("literal", start, st.pos, { value: 117, escaped: true })
    st.error("\\u needs four hexadecimal digits", start, st.pos)
    return codeLiteral(st, start, 0)
  case "control":
    if (/^[A-Za-z]/.test(rest)) {
      st.pos++
      return codeLiteral(st, start, rest.charCodeAt(0) % 32)
    }
    if (st.js) return node("literal", start, st.pos, { value: 92, escaped: true })
    if (rest.length > 0) { st.pos++; return codeLiteral(st, start, rest.charCodeAt(0) ^ 64) }
    st.error("\\c needs a letter", start, st.pos)
    return codeLiteral(st, start, 0)
  case "octalBrace":
    if ((m = /^\{([0-7]+)\}/.exec(rest))) { st.pos += m[0].length; return codeLiteral(st, start, parseInt(m[1], 8)) }
    st.error("\\o needs octal digits in braces", start, st.pos)
    return codeLiteral(st, start, 0)
  case "namedChar":
    if ((m = /^\{([^}]*)\}/.exec(rest))) {
      st.pos += m[0].length
      var u = /^U\+([0-9a-fA-F]+)$/.exec(m[1])
      return node("literal", start, st.pos, { value: u ? parseInt(u[1], 16) : -1, name: m[1], escaped: true })
    }
    if (st.flavor.id === "perl" && !inClass) return node("chartype", start, st.pos, { kind: "notnewline", negated: false })
    st.error("\\N needs a character name in braces", start, st.pos)
    return node("literal", start, st.pos, { value: -1, escaped: true })
  case "property":
    return parseProperty(st, start, c === "P")
  }
  if (inClass) {
    st.error("\\" + c + " cannot be used inside a character class", start, st.pos)
    return node("literal", start, st.pos, { value: c.charCodeAt(0), escaped: true })
  }
  switch (meaning) {
  case "gref": return parseGReference(st, start)
  case "kref": return parseKReference(st, start)
  case "reset": return node("anchor", start, st.pos, { kind: "resetStart" })
  case "quote": return parseQuote(st, start)
  }
  return node("literal", start, st.pos, { value: c.charCodeAt(0), escaped: true })
}

function codeLiteral(st, start, value) {
  if (value > 0x10ffff) st.error("The code point is beyond Unicode's range", start, st.pos)
  return node("literal", start, st.pos, { value: value, escaped: true })
}

function parseProperty(st, start, negated) {
  if (!st.f.unicodeProperties || (st.js && !st.mode.u)) {
    if (st.js && st.f.unicodeProperties) {
      st.error("\\p{...} needs the u flag in " + st.flavor.name, start, st.pos)
    } else {
      st.unsupported("Unicode properties", start, st.pos)
    }
  }
  var m = /^\{(\^?)([^}]*)\}/.exec(st.src.substr(st.pos))
  if (m) {
    st.pos += m[0].length
    return node("property", start, st.pos, { name: m[2], negated: negated !== (m[1] === "^") })
  }
  if (st.f.shortProperties && /^[A-Za-z]/.test(st.peek())) {
    var name = st.peek()
    st.pos++
    return node("property", start, st.pos, { name: name, negated: negated })
  }
  st.error("\\p needs a property name such as \\p{L}", start, st.pos)
  return node("property", start, st.pos, { name: "", negated: negated })
}

function parseDigitEscape(st, start) {
  var m = /^\d+/.exec(st.src.substr(st.pos))
  var digits = m[0]
  var number = parseInt(digits, 10)
  if (digits.charAt(0) === "0") {
    var oct = /^0[0-7]{0,2}/.exec(st.src.substr(st.pos))[0]
    st.pos += oct.length
    if (!st.f.octal && oct.length > 1) st.unsupported("Octal escapes", start, st.pos)
    return node("literal", start, st.pos, { value: parseInt(oct, 8), escaped: true })
  }
  if (!st.f.backrefs) {
    st.pos += digits.length
    st.unsupported("Backreferences", start, st.pos)
    return node("backref", start, st.pos, { ref: number, relative: false })
  }
  // \1-\9 are always backreferences; longer numbers only while that many
  // groups exist, otherwise as many leading digits as name a group, then
  // octal or literal digits (PCRE2 and Perl).
  if (digits.length > 1 && number > st.totalGroups) {
    if (st.f.octal && /^[0-7]{2,3}$/.test(digits.substr(0, 3)) && /^[0-7]+$/.test(digits.substr(0, 3))) {
      var o = /^[0-7]{1,3}/.exec(digits)[0]
      st.pos += o.length
      return node("literal", start, st.pos, { value: parseInt(o, 8), escaped: true })
    }
  }
  st.pos += digits.length
  var ref = node("backref", start, st.pos, { ref: number, relative: false })
  st.backrefs.push(ref)
  return ref
}

function parseGReference(st, start) {
  var rest = st.src.substr(st.pos)
  var m
  if ((m = /^\{(-?\d+)\}/.exec(rest)) || (m = /^(-?\d+)/.exec(rest))) {
    st.pos += m[0].length
    if (!st.f.gBackrefs) st.unsupported("\\g backreferences", start, st.pos)
    var number = parseInt(m[1], 10)
    if (m[1].charAt(0) === "-" && !st.f.relativeBackrefs) st.unsupported("Relative backreferences", start, st.pos)
    var ref = node("backref", start, st.pos, { ref: number, relative: number < 0 })
    st.backrefs.push(ref)
    return ref
  }
  if ((m = /^\{([A-Za-z_]\w*)\}/.exec(rest))) {
    st.pos += m[0].length
    if (st.f.namedBackrefs.indexOf("g-brace") < 0) st.unsupported("\\g{name} backreferences", start, st.pos)
    var named = node("backref", start, st.pos, { ref: m[1], relative: false })
    st.backrefs.push(named)
    return named
  }
  if ((m = /^<([+-]?\d+|[A-Za-z_]\w*)>/.exec(rest)) || (m = /^'([+-]?\d+|[A-Za-z_]\w*)'/.exec(rest))) {
    st.pos += m[0].length
    if (!st.f.gSubroutines && st.f.namedBackrefs.indexOf("g-angle") >= 0) {
      var pyref = node("backref", start, st.pos, { ref: /^[+-]?\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1], relative: false })
      st.backrefs.push(pyref)
      return pyref
    }
    if (!st.f.gSubroutines) st.unsupported("\\g<...> subroutine calls", start, st.pos)
    var numeric = /^[+-]?\d+$/.test(m[1])
    var call = node("recursion", start, st.pos, { ref: numeric ? parseInt(m[1], 10) : m[1], relative: numeric && /^[+-]/.test(m[1]) })
    st.recursions.push(call)
    return call
  }
  st.error("\\g needs a group number or name", start, st.pos)
  return node("literal", start, st.pos, { value: 103, escaped: true })
}

function parseKReference(st, start) {
  var rest = st.src.substr(st.pos)
  var forms = [["k-angle", /^<([^>]*)>/], ["k-quote", /^'([^']*)'/], ["k-brace", /^\{([^}]*)\}/]]
  for (var i = 0; i < forms.length; i++) {
    var m = forms[i][1].exec(rest)
    if (!m) continue
    st.pos += m[0].length
    if (st.f.namedBackrefs.indexOf(forms[i][0]) < 0) st.unsupported("Backreferences written like " + st.src.substring(start, st.pos), start, st.pos)
    var ref = node("backref", start, st.pos, { ref: /^-?\d+$/.test(m[1]) ? parseInt(m[1], 10) : m[1], relative: /^-/.test(m[1]) })
    st.backrefs.push(ref)
    return ref
  }
  if (st.js && !st.mode.u && Object.keys(st.names).length === 0 && st.src.indexOf("(?<") < 0)
    return node("literal", start, st.pos, { value: 107, escaped: true })
  st.error("\\k needs a group name, as in \\k<name>", start, st.pos)
  return node("literal", start, st.pos, { value: 107, escaped: true })
}

function parseQuote(st, start) {
  var end = st.src.indexOf("\\E", st.pos)
  var textEnd = end < 0 ? st.src.length : end
  var items = []
  while (st.pos < textEnd) {
    var s = st.pos
    var cp = st.nextCodePoint()
    items.push(node("literal", s, st.pos, { value: cp }))
  }
  if (end >= 0) st.pos = end + 2
  return node("quote", start, st.pos, { items: items })
}

// ---- classes ------------------------------------------------------------------

var POSIX_NAMES = ["alnum", "alpha", "ascii", "blank", "cntrl", "digit", "graph", "lower", "print", "punct", "space", "upper", "word", "xdigit"]

function parseClass(st) {
  var start = st.pos
  st.pos++
  var negated = false
  if (st.peek() === "^") { negated = true; st.pos++ }
  var items = []
  var setMode = st.f.nestedClasses && st.setOps
  if (st.peek() === "]") {
    if (st.f.emptyClass) {
      st.pos++
      return node("class", start, st.pos, { negated: negated, items: [] })
    }
    items.push(node("literal", st.pos, st.pos + 1, { value: 93 }))
    st.pos++
  }
  var closed = false
  while (!st.eof()) {
    skipExtended(st, true)
    var c = st.peek()
    if (c === "]") { st.pos++; closed = true; break }

    // Set operations
    if (st.f.classIntersection && st.setOps && st.startsWith("&&")) {
      var opStart = st.pos
      st.pos += 2
      var left = node("class", start, opStart, { negated: false, items: items })
      var right = parseClassOperand(st)
      items = [node("setop", left.start, st.pos, { op: "&&", left: left, right: right, opStart: opStart })]
      continue
    }
    if (st.f.classSubtraction === "--" && st.setOps && st.startsWith("--")) {
      var subStart = st.pos
      st.pos += 2
      var subLeft = node("class", start, subStart, { negated: false, items: items })
      var subRight = parseClassOperand(st)
      items = [node("setop", subLeft.start, st.pos, { op: "--", left: subLeft, right: subRight, opStart: subStart })]
      continue
    }
    if (st.flavor.id === "rust" && st.startsWith("~~")) {
      var symStart = st.pos
      st.pos += 2
      var symLeft = node("class", start, symStart, { negated: false, items: items })
      var symRight = parseClassOperand(st)
      items = [node("setop", symLeft.start, st.pos, { op: "~~", left: symLeft, right: symRight, opStart: symStart })]
      continue
    }
    if (st.f.classSubtraction === "net" && st.startsWith("-[")) {
      var netStart = st.pos
      st.pos++
      var netRight = parseClass(st)
      var netLeft = node("class", start, netStart, { negated: false, items: items })
      items = [node("setop", start, st.pos, { op: "net", left: netLeft, right: netRight, opStart: netStart })]
      if (st.peek() !== "]") st.error("A .NET class subtraction must be the last part of its class", netStart, st.pos)
      continue
    }

    var item = parseClassAtom(st, setMode)
    if (!item) continue
    // Ranges
    if (st.peek() === "-" && st.peek(1) !== "]" && st.peek(1) !== "" && !(st.f.classSubtraction === "--" && st.setOps && st.peek(1) === "-")) {
      var dash = st.pos
      st.pos++
      if (st.f.classSubtraction === "net" && st.peek() === "[") {
        st.pos = dash
        items.push(item)
        continue
      }
      var to = parseClassAtom(st, setMode)
      if (item.type === "literal" && to && to.type === "literal") {
        if (to.value < item.value && item.value >= 0 && to.value >= 0)
          st.error("The range is out of order", item.start, to.end)
        items.push(node("range", item.start, to.end, { from: item, to: to }))
        continue
      }
      if (st.flavor.id === "python" || st.flavor.id === "java" || st.flavor.id === "go" || st.flavor.id === "rust" || st.mode.u)
        st.error("A range needs a single character on each side", item.start, to ? to.end : st.pos)
      items.push(item)
      items.push(node("literal", dash, dash + 1, { value: 45 }))
      if (to) items.push(to)
      continue
    }
    items.push(item)
  }
  if (!closed) st.error("The character class is missing its closing ]", start, st.pos)
  return node("class", start, st.pos, { negated: negated, items: items })
}

function parseClassOperand(st) {
  if (st.peek() === "[") return parseClass(st)
  var start = st.pos
  var atom = parseClassAtom(st, true)
  return atom || node("empty", start, start, {})
}

function parseClassAtom(st, setMode) {
  var start = st.pos
  var c = st.peek()
  if (c === "[") {
    var posix = /^\[:(\^?)([a-z]+):\]/.exec(st.src.substr(st.pos))
    if (posix) {
      st.pos += posix[0].length
      if (!st.f.posixClasses) st.unsupported("POSIX classes like [:" + posix[2] + ":]", start, st.pos)
      else if (POSIX_NAMES.indexOf(posix[2]) < 0) st.error("[:" + posix[2] + ":] is not a POSIX class", start, st.pos)
      return node("posixclass", start, st.pos, { name: posix[2], negated: posix[1] === "^" })
    }
    if (setMode) return parseClass(st)
    st.pos++
    return node("literal", start, st.pos, { value: 91 })
  }
  if (c === "\\") {
    st.pos++
    if (st.eof()) {
      st.error("The pattern ends with a lone backslash", start)
      return null
    }
    var e = st.peek()
    if (e === "b") { st.pos++; return node("literal", start, st.pos, { value: 8, escaped: true }) }
    if (isDigit(e)) {
      var oct = /^[0-7]{1,3}/.exec(st.src.substr(st.pos))
      if (oct && st.f.octal) { st.pos += oct[0].length; return node("literal", start, st.pos, { value: parseInt(oct[0], 8), escaped: true }) }
      st.pos++
      if (e !== "0") st.error("A backreference cannot be used inside a character class", start, st.pos)
      return node("literal", start, st.pos, { value: e === "0" ? 0 : e.charCodeAt(0), escaped: true })
    }
    if (e === "Q" && st.f.quoting) {
      st.pos++
      var q = parseQuote(st, start)
      return q.items.length === 1 ? q.items[0] : q
    }
    if (!isAlpha(e)) {
      var cp = st.nextCodePoint()
      return node("literal", start, st.pos, { value: cp, escaped: true })
    }
    var meaning = st.f.escapes[e]
    var lower = e.toLowerCase()
    if (meaning === undefined && e !== lower) {
      var base = st.f.escapes[lower]
      if (base && CHARTYPES[base] !== undefined) { st.pos++; return node("chartype", start, st.pos, { kind: base, negated: true }) }
      if (base === "property" && e === "P") meaning = "property"
    }
    if (meaning === undefined) {
      st.pos++
      if (st.f.unknownEscape === "error" || (st.js && st.mode.u)) st.error("\\" + e + " is not a valid escape in " + st.flavor.name, start, st.pos)
      return node("literal", start, st.pos, { value: e.charCodeAt(0), escaped: true })
    }
    st.pos++
    if (CHARTYPES[meaning] !== undefined) return node("chartype", start, st.pos, { kind: meaning, negated: false })
    if (meaning === "newline" || meaning === "notnewline" || meaning === "grapheme") {
      st.error("\\" + e + " cannot be used inside a character class", start, st.pos)
      return node("literal", start, st.pos, { value: e.charCodeAt(0), escaped: true })
    }
    if (meaning.indexOf("char:") === 0) return node("literal", start, st.pos, { value: parseInt(meaning.substr(5), 10), escaped: true })
    return parseSpecialEscape(st, start, e, meaning, true)
  }
  var value = st.nextCodePoint()
  return node("literal", start, st.pos, { value: value })
}

// ---- POSIX ERE / BRE ------------------------------------------------------------

function parsePosix(st, basic) {
  st.basic = basic
  return posixAlternation(st, 0)
}

function posixAlternation(st, depth) {
  var start = st.pos
  var alternatives = [posixSequence(st, depth)]
  while (st.basic ? st.startsWith("\\|") : st.peek() === "|") {
    st.pos += st.basic ? 2 : 1
    alternatives.push(posixSequence(st, depth))
  }
  if (alternatives.length === 1) return alternatives[0]
  return node("alternation", start, st.pos, { alternatives: alternatives })
}

function posixSequence(st, depth) {
  var start = st.pos
  var items = []
  for (;;) {
    if (st.eof()) break
    if (st.basic ? st.startsWith("\\|") : st.peek() === "|") break
    if (st.basic ? st.startsWith("\\)") : st.peek() === ")") {
      if (depth > 0) break
      var p = st.pos
      st.pos += st.basic ? 2 : 1
      // An unmatched ) is an ordinary character in ERE (glibc); an unmatched
      // \) is an error in BRE.
      if (st.basic) st.error("Unmatched \\)", p, st.pos)
      else items.push(node("literal", p, st.pos, { value: 41 }))
      continue
    }
    var atom = posixAtom(st, depth, items.length === 0)
    if (!atom) continue
    items.push(posixQuantifiers(st, atom))
  }
  if (items.length === 1) return items[0]
  if (items.length === 0) return node("empty", start, start, {})
  return node("sequence", start, st.pos, { items: items })
}

function posixQuantifier(st) {
  var start = st.pos
  var c = st.peek()
  if (c === "*") { st.pos++; return { min: 0, max: INFINITE } }
  if (st.basic) {
    if (st.startsWith("\\+")) { st.pos += 2; return { min: 1, max: INFINITE } }
    if (st.startsWith("\\?")) { st.pos += 2; return { min: 0, max: 1 } }
    if (st.startsWith("\\{")) {
      var m = /^\\\{(\d*)(,?)(\d*)\\\}/.exec(st.src.substr(st.pos))
      if (!m) { st.error("The interval is not closed with \\}", start, start + 2); st.pos += 2; return null }
      st.pos += m[0].length
      return interval(st, start, m)
    }
    return null
  }
  if (c === "+") { st.pos++; return { min: 1, max: INFINITE } }
  if (c === "?") { st.pos++; return { min: 0, max: 1 } }
  if (c === "{") {
    var e = /^\{(\d*)(,?)(\d*)\}/.exec(st.src.substr(st.pos))
    if (!e || (e[1] === "" && e[3] === "" && e[2] === "")) return null
    st.pos += e[0].length
    return interval(st, start, e)
  }
  return null
}

function interval(st, start, m) {
  var min = m[1] === "" ? 0 : parseInt(m[1], 10)
  var max = m[2] === "" ? min : (m[3] === "" ? INFINITE : parseInt(m[3], 10))
  if (max !== INFINITE && max < min) st.error("The interval's maximum is less than its minimum", start, st.pos)
  if (min > 32767 || max > 32767) st.error("Interval counts above 32767 are not allowed", start, st.pos)
  return { min: min, max: max }
}

function posixQuantifiers(st, atom) {
  var result = atom
  for (;;) {
    var opStart = st.pos
    var q = posixQuantifier(st)
    if (!q) break
    result = node("quantifier", atom.start, st.pos, { min: q.min, max: q.max, mode: "greedy", body: result, opStart: opStart })
  }
  return result
}

function posixAtom(st, depth, first) {
  var start = st.pos
  var c = st.peek()
  var basic = st.basic

  if (basic ? st.startsWith("\\(") : c === "(") {
    st.pos += basic ? 2 : 1
    var group = st.addGroup("", start, "capture")
    var body = posixAlternation(st, depth + 1)
    if (basic ? st.startsWith("\\)") : st.peek() === ")") st.pos += basic ? 2 : 1
    else st.error("Missing closing parenthesis", start, st.pos)
    group.end = st.pos
    return node("group", start, st.pos, { kind: "capture", index: group.index, name: "", body: body })
  }
  if (c === "[") return posixClass(st)
  if (c === ".") { st.pos++; return node("dot", start, st.pos, { newline: true }) }
  if (c === "^") {
    st.pos++
    // In BRE, ^ is an anchor only at the start of an expression
    if (basic && !first && !(st.src.substring(start - 2, start) === "\\(" || st.src.substring(start - 2, start) === "\\|"))
      return node("literal", start, st.pos, { value: 94 })
    return node("anchor", start, st.pos, { kind: "lineStart" })
  }
  if (c === "$") {
    st.pos++
    var atEnd = st.eof() || st.startsWith("\\)") || st.startsWith("\\|")
    if (basic && !atEnd) return node("literal", start, st.pos, { value: 36 })
    return node("anchor", start, st.pos, { kind: "lineEnd" })
  }
  if (c === "*") {
    st.pos++
    if (first) return node("literal", start, st.pos, { value: 42 })
    st.error("The quantifier has nothing to repeat", start, st.pos)
    return null
  }
  if (!basic && (c === "+" || c === "?" || c === "{")) {
    if (c === "{" && !/^\{\d*,?\d*\}/.test(st.src.substr(st.pos))) {
      st.pos++
      return node("literal", start, st.pos, { value: 123 })
    }
    st.pos++
    if (first) return node("literal", start, st.pos, { value: c.charCodeAt(0) })
    st.error("The quantifier has nothing to repeat", start, st.pos)
    return null
  }
  if (c === "\\") {
    st.pos++
    if (st.eof()) {
      st.error("The pattern ends with a lone backslash", start)
      return node("literal", start, st.pos, { value: 92 })
    }
    var e = st.peek()
    st.pos++
    var gawk = st.flavor.id === "gawk"
    if (isDigit(e) && e !== "0") {
      if (gawk) {
        st.unsupported("Backreferences", start, st.pos)
        return node("literal", start, st.pos, { value: e.charCodeAt(0), escaped: true })
      }
      var ref = node("backref", start, st.pos, { ref: parseInt(e, 10), relative: false })
      st.backrefs.push(ref)
      return ref
    }
    if (e === "w" || e === "W") return node("chartype", start, st.pos, { kind: "word", negated: e === "W" })
    if (e === "s" || e === "S") return node("chartype", start, st.pos, { kind: "space", negated: e === "S" })
    if (e === (gawk ? "y" : "b")) return node("anchor", start, st.pos, { kind: "wordBoundary" })
    if (e === "B") return node("anchor", start, st.pos, { kind: "notWordBoundary" })
    if (e === "<") return node("anchor", start, st.pos, { kind: "wordStart" })
    if (e === ">") return node("anchor", start, st.pos, { kind: "wordEnd" })
    if (e === "`") return node("anchor", start, st.pos, { kind: "start" })
    if (e === "'") return node("anchor", start, st.pos, { kind: "end" })
    if ((st.flavor.id === "sed" || st.flavor.id === "sed-e" || gawk) && "ntrfva".indexOf(e) >= 0)
      return node("literal", start, st.pos, { value: { n: 10, t: 9, r: 13, f: 12, v: 11, a: 7 }[e], escaped: true })
    if (basic && "{}".indexOf(e) >= 0) {
      st.error("\\" + e + " here does not start an interval", start, st.pos)
      return node("literal", start, st.pos, { value: e.charCodeAt(0), escaped: true })
    }
    st.pos--
    var cp = st.nextCodePoint()
    return node("literal", start, st.pos, { value: cp, escaped: true })
  }
  var value = st.nextCodePoint()
  return node("literal", start, st.pos, { value: value })
}

function posixClass(st) {
  var start = st.pos
  st.pos++
  var negated = false
  if (st.peek() === "^") { negated = true; st.pos++ }
  var items = []
  var first = true
  var closed = false
  while (!st.eof()) {
    var c = st.peek()
    if (c === "]" && !first) { st.pos++; closed = true; break }
    first = false
    var item = posixClassAtom(st)
    if (st.peek() === "-" && st.peek(1) !== "]" && st.peek(1) !== "" && item.type === "literal") {
      var dash = st.pos
      st.pos++
      var to = posixClassAtom(st)
      if (to.type === "literal") {
        if (to.value < item.value) st.error("The range is out of order", item.start, to.end)
        items.push(node("range", item.start, to.end, { from: item, to: to }))
        continue
      }
      st.error("A range needs a single character on each side", item.start, to.end)
      items.push(item, node("literal", dash, dash + 1, { value: 45 }), to)
      continue
    }
    items.push(item)
  }
  if (!closed) st.error("The bracket expression is missing its closing ]", start, st.pos)
  return node("class", start, st.pos, { negated: negated, items: items })
}

function posixClassAtom(st) {
  var start = st.pos
  var rest = st.src.substr(st.pos)
  var m
  if ((m = /^\[:([a-z]+):\]/.exec(rest))) {
    st.pos += m[0].length
    if (POSIX_NAMES.indexOf(m[1]) < 0 || m[1] === "word" || m[1] === "ascii") st.error("[:" + m[1] + ":] is not a POSIX class", start, st.pos)
    return node("posixclass", start, st.pos, { name: m[1], negated: false })
  }
  if ((m = /^\[=(.+?)=\]/.exec(rest))) {
    st.pos += m[0].length
    return node("equivalence", start, st.pos, { value: m[1] })
  }
  if ((m = /^\[\.(.+?)\.\]/.exec(rest))) {
    st.pos += m[0].length
    return node("collating", start, st.pos, { value: m[1] })
  }
  // Backslash is an ordinary character inside a POSIX bracket expression,
  // except in gawk, where it escapes.
  if (st.flavor.id === "gawk" && st.peek() === "\\" && st.pos + 1 < st.src.length) {
    st.pos++
    var e = st.nextCodePoint()
    var map = { 110: 10, 116: 9, 114: 13, 102: 12, 118: 11, 97: 7 }
    return node("literal", start, st.pos, { value: map[e] !== undefined ? map[e] : e, escaped: true })
  }
  var value = st.nextCodePoint()
  return node("literal", start, st.pos, { value: value })
}

// ---- Vim --------------------------------------------------------------------------

// Vim reads a pattern under one of four magic levels. Each token is read as
// (backslashed, character) and normalized to what it means under 'magic',
// so the grammar below only has to know one level.
var VERY_MAGIC_SPECIAL = "()|+?={@%<>*.[~^$&"

function vimToken(st) {
  var start = st.pos
  if (st.eof()) return null
  var c = st.peek()
  var escaped = false
  if (c === "\\") {
    if (st.pos + 1 >= st.src.length) {
      st.pos++
      return { start: start, end: st.pos, op: "lit", ch: "\\" }
    }
    escaped = true
    st.pos++
    c = st.peek()
  }
  st.pos += c.length
  var level = st.vimLevel
  var special
  if ("cCvmMV".indexOf(c) >= 0 && escaped) return { start: start, end: st.pos, op: "mode", ch: c }
  if (level === "v") {
    special = /^[a-zA-Z0-9_]$/.test(c) ? escaped : (escaped ? false : VERY_MAGIC_SPECIAL.indexOf(c) >= 0 || c === "{")
  } else if (level === "m") {
    special = "^$.*[~".indexOf(c) >= 0 ? !escaped : escaped
  } else if (level === "M") {
    special = "^$".indexOf(c) >= 0 ? !escaped : escaped
  } else {
    special = escaped
  }
  if (!special) return { start: start, end: st.pos, op: "lit", ch: c, escaped: escaped }
  return { start: start, end: st.pos, op: "sp", ch: c }
}

function parseVim(st) {
  st.vimLevel = "m"
  var ast = vimAlternation(st, 0)
  while (!st.eof()) {
    st.error("Unmatched \\)", st.pos)
    st.pos += 2
    var more = vimAlternation(st, 0)
    ast = node("sequence", ast.start, more.end, { items: [ast, more] })
  }
  return ast
}

function vimPeek(st) {
  var saved = st.pos
  var level = st.vimLevel
  var t = vimToken(st)
  st.pos = saved
  st.vimLevel = level
  return t
}

function vimAlternation(st, depth) {
  var start = st.pos
  var alternatives = [vimConcat(st, depth)]
  for (;;) {
    var t = vimPeek(st)
    if (!t || t.op !== "sp" || t.ch !== "|") break
    vimToken(st)
    alternatives.push(vimConcat(st, depth))
  }
  if (alternatives.length === 1) return alternatives[0]
  return node("alternation", start, st.pos, { alternatives: alternatives })
}

// \& joins branches that must all match at the same position; the last one
// is the one that is used.
function vimConcat(st, depth) {
  var start = st.pos
  var parts = [vimSequence(st, depth)]
  for (;;) {
    var t = vimPeek(st)
    if (!t || t.op !== "sp" || t.ch !== "&") break
    vimToken(st)
    parts.push(vimSequence(st, depth))
  }
  if (parts.length === 1) return parts[0]
  var items = []
  for (var i = 0; i < parts.length - 1; i++)
    items.push(node("group", parts[i].start, parts[i].end, { kind: "lookahead", body: parts[i] }))
  items.push(parts[parts.length - 1])
  return node("sequence", start, st.pos, { items: items })
}

function vimSequence(st, depth) {
  var start = st.pos
  var items = []
  for (;;) {
    var t = vimPeek(st)
    if (!t) break
    if (t.op === "sp" && (t.ch === "|" || t.ch === "&" || t.ch === ")")) {
      if (t.ch === ")" && depth === 0) {
        vimToken(st)
        st.error("Unmatched \\)", t.start, t.end)
        continue
      }
      break
    }
    var atom = vimAtom(st, depth, items.length === 0)
    if (!atom) continue
    items.push(vimMulti(st, atom))
  }
  if (items.length === 1) return items[0]
  if (items.length === 0) return node("empty", start, start, {})
  return node("sequence", start, st.pos, { items: items })
}

function vimMulti(st, atom) {
  var result = atom
  for (;;) {
    var t = vimPeek(st)
    if (!t || t.op !== "sp") break
    var opStart = t.start
    if (t.ch === "*") { vimToken(st); result = node("quantifier", atom.start, st.pos, { min: 0, max: INFINITE, mode: "greedy", body: result, opStart: opStart }); continue }
    if (t.ch === "+") { vimToken(st); result = node("quantifier", atom.start, st.pos, { min: 1, max: INFINITE, mode: "greedy", body: result, opStart: opStart }); continue }
    if (t.ch === "=" || t.ch === "?") { vimToken(st); result = node("quantifier", atom.start, st.pos, { min: 0, max: 1, mode: "greedy", body: result, opStart: opStart }); continue }
    if (t.ch === "{") {
      vimToken(st)
      var m = /^(-?)(\d*)(,?)(\d*)\\?\}/.exec(st.src.substr(st.pos))
      if (!m) { st.error("The \\{ is not closed", opStart, st.pos); break }
      st.pos += m[0].length
      var min = m[2] === "" ? 0 : parseInt(m[2], 10)
      var max = m[3] === "" ? (m[2] === "" ? INFINITE : min) : (m[4] === "" ? INFINITE : parseInt(m[4], 10))
      if (max !== INFINITE && max < min) { var swap = min; min = max; max = swap }
      result = node("quantifier", atom.start, st.pos, { min: min, max: max, mode: m[1] === "-" ? "lazy" : "greedy", body: result, opStart: opStart })
      continue
    }
    if (t.ch === "@") {
      vimToken(st)
      var a = /^(\d*)(<=|<!|=|!|>)/.exec(st.src.substr(st.pos))
      if (!a) { st.error("\\@ must be followed by =, !, <=, <! or >", opStart, st.pos); break }
      st.pos += a[0].length
      var kinds = { "=": "lookahead", "!": "negativeLookahead", "<=": "lookbehind", "<!": "negativeLookbehind", ">": "atomic" }
      result = node("group", atom.start, st.pos, { kind: kinds[a[2]], body: result, postfix: true, opStart: opStart })
      continue
    }
    break
  }
  return result
}

var VIM_CLASSES = {
  s: ["space", false], S: ["space", true], d: ["digit", false], D: ["digit", true],
  w: ["word", false], W: ["word", true], x: ["hex", false], X: ["hex", true],
  a: ["alpha", false], A: ["alpha", true], l: ["lower", false], L: ["lower", true],
  u: ["upper", false], U: ["upper", true], o: ["octal", false], O: ["octal", true],
  h: ["head", false], H: ["head", true], i: ["ident", false], I: ["ident", true],
  k: ["keyword", false], K: ["keyword", true], f: ["filename", false], F: ["filename", true],
  p: ["printable", false], P: ["printable", true],
}

function vimAtom(st, depth, first) {
  var t = vimToken(st)
  var start = t.start
  if (t.op === "mode") {
    if ("vmMV".indexOf(t.ch) >= 0) st.vimLevel = t.ch
    return node("flags", start, st.pos, { on: t.ch === "c" ? "i" : "", off: t.ch === "C" ? "i" : "", vim: t.ch })
  }
  if (t.op === "lit") {
    if (t.escaped) {
      var named = { e: 27, t: 9, r: 13, b: 8, n: 10 }
      if (named[t.ch] !== undefined) return node("literal", start, st.pos, { value: named[t.ch], escaped: true })
      if (VIM_CLASSES[t.ch]) return node("chartype", start, st.pos, { kind: VIM_CLASSES[t.ch][0], negated: VIM_CLASSES[t.ch][1] })
      if (isDigit(t.ch) && t.ch !== "0") {
        var ref = node("backref", start, st.pos, { ref: parseInt(t.ch, 10), relative: false })
        st.backrefs.push(ref)
        return ref
      }
      if (t.ch === "z") return vimZ(st, start)
      if (t.ch === "_") return vimUnderscore(st, start)
    }
    return node("literal", start, st.pos, { value: t.ch.codePointAt(0), escaped: t.escaped })
  }
  switch (t.ch) {
  case "(":
    var group = st.addGroup("", start, "capture")
    var body = vimAlternation(st, depth + 1)
    vimClose(st, start)
    group.end = st.pos
    return node("group", start, st.pos, { kind: "capture", index: group.index, name: "", body: body })
  case "%": return vimPercent(st, start, depth)
  case "^": return node("anchor", start, st.pos, { kind: "lineStart" })
  case "$": return node("anchor", start, st.pos, { kind: "lineEnd" })
  case ".": return node("dot", start, st.pos, {})
  case "[": st.pos = start + (st.src.charAt(start) === "\\" ? 1 : 0); return vimCollection(st, start, false)
  case "<": return node("anchor", start, st.pos, { kind: "wordStart" })
  case ">": return node("anchor", start, st.pos, { kind: "wordEnd" })
  case "~":
    st.warn("~ stands for the last substitute string, which Rex treats as empty", start, st.pos)
    return node("empty", start, st.pos, {})
  case "*": case "+": case "=": case "?": case "{": case "@":
    if (first && t.ch === "*") return node("literal", start, st.pos, { value: 42 })
    st.error("The quantifier has nothing to repeat", start, st.pos)
    return null
  }
  if (isDigit(t.ch) && t.ch !== "0") {
    var backref = node("backref", start, st.pos, { ref: parseInt(t.ch, 10), relative: false })
    st.backrefs.push(backref)
    return backref
  }
  if (VIM_CLASSES[t.ch]) return node("chartype", start, st.pos, { kind: VIM_CLASSES[t.ch][0], negated: VIM_CLASSES[t.ch][1] })
  if (t.ch === "z") return vimZ(st, start)
  if (t.ch === "_") return vimUnderscore(st, start)
  var map = { e: 27, t: 9, r: 13, b: 8, n: 10 }
  if (map[t.ch] !== undefined) return node("literal", start, st.pos, { value: map[t.ch], escaped: true })
  return node("literal", start, st.pos, { value: t.ch.codePointAt(0), escaped: true })
}

function vimClose(st, start) {
  var t = vimPeek(st)
  if (t && t.op === "sp" && t.ch === ")") { vimToken(st); return }
  st.error("Missing \\)", start, st.pos)
}

function vimZ(st, start) {
  var c = st.peek()
  st.pos++
  if (c === "s") return node("anchor", start, st.pos, { kind: "matchStart" })
  if (c === "e") return node("anchor", start, st.pos, { kind: "matchEnd" })
  st.unsupported("\\z" + c, start, st.pos)
  return node("empty", start, st.pos, {})
}

function vimUnderscore(st, start) {
  var c = st.peek()
  st.pos++
  if (c === ".") return node("dot", start, st.pos, { newline: true })
  if (c === "^") return node("anchor", start, st.pos, { kind: "lineStart" })
  if (c === "$") return node("anchor", start, st.pos, { kind: "lineEnd" })
  if (c === "[") { st.pos--; return vimCollection(st, start, true) }
  if (VIM_CLASSES[c]) return node("class", start, st.pos, { negated: false, items: [node("chartype", start, st.pos, { kind: VIM_CLASSES[c][0], negated: VIM_CLASSES[c][1] }), node("literal", start, st.pos, { value: 10 })] })
  st.error("\\_" + c + " is not a valid item", start, st.pos)
  return node("empty", start, st.pos, {})
}

function vimPercent(st, start, depth) {
  var rest = st.src.substr(st.pos)
  var m
  if (rest.charAt(0) === "(" || rest.substr(0, 2) === "\\(") {
    st.pos += rest.charAt(0) === "(" && st.vimLevel === "v" ? 1 : (rest.charAt(0) === "(" ? 1 : 2)
    var body = vimAlternation(st, depth + 1)
    vimClose(st, start)
    return node("group", start, st.pos, { kind: "noncapture", body: body })
  }
  if (rest.charAt(0) === "^") { st.pos++; return node("anchor", start, st.pos, { kind: "start" }) }
  if (rest.charAt(0) === "$") { st.pos++; return node("anchor", start, st.pos, { kind: "end" }) }
  if ((m = /^d(\d+)/.exec(rest))) { st.pos += m[0].length; return node("literal", start, st.pos, { value: parseInt(m[1], 10), escaped: true }) }
  if ((m = /^x([0-9a-fA-F]{1,2})/.exec(rest)) || (m = /^u([0-9a-fA-F]{1,4})/.exec(rest)) || (m = /^U([0-9a-fA-F]{1,8})/.exec(rest))) {
    st.pos += m[0].length
    return node("literal", start, st.pos, { value: parseInt(m[1], 16), escaped: true })
  }
  if ((m = /^o([0-7]{1,4})/.exec(rest))) { st.pos += m[0].length; return node("literal", start, st.pos, { value: parseInt(m[1], 8), escaped: true }) }
  if ((m = /^([<>]?)(\d+|')([lcv])/.exec(rest))) {
    st.pos += m[0].length
    return node("anchor", start, st.pos, { kind: "position", detail: m[0] })
  }
  if (rest.charAt(0) === "[") {
    var end = rest.indexOf("]")
    st.pos += end < 0 ? rest.length : end + 1
    st.warn("\\%[...] optional sequences are explained as a group of optional atoms", start, st.pos)
    return node("empty", start, st.pos, {})
  }
  if ((m = /^#=(\d)/.exec(rest))) { st.pos += m[0].length; return node("flags", start, st.pos, { on: "", off: "", engine: m[1] }) }
  if (/^[V#C]/.test(rest)) { st.pos++; return node("anchor", start, st.pos, { kind: "position", detail: rest.charAt(0) }) }
  st.error("\\%" + rest.charAt(0) + " is not a valid item", start, st.pos + 1)
  st.pos++
  return node("empty", start, st.pos, {})
}

function vimCollection(st, start, withNewline) {
  st.pos++
  var negated = false
  if (st.peek() === "^") { negated = true; st.pos++ }
  var items = []
  if (withNewline) items.push(node("literal", start, start, { value: 10 }))
  if (st.peek() === "]") { items.push(node("literal", st.pos, st.pos + 1, { value: 93 })); st.pos++ }
  var closed = false
  while (!st.eof()) {
    var c = st.peek()
    if (c === "]") { st.pos++; closed = true; break }
    var itemStart = st.pos
    var item
    var posix = /^\[:([a-z]+):\]/.exec(st.src.substr(st.pos))
    if (posix) {
      st.pos += posix[0].length
      item = node("posixclass", itemStart, st.pos, { name: posix[1], negated: false })
    } else if (c === "\\" && st.pos + 1 < st.src.length) {
      st.pos++
      var e = st.peek()
      st.pos++
      var map = { e: 27, t: 9, r: 13, b: 8, n: 10, "\\": 92, "]": 93, "^": 94, "-": 45 }
      if (map[e] !== undefined) item = node("literal", itemStart, st.pos, { value: map[e], escaped: true })
      else {
        var m = /^(d\d+|x[0-9a-fA-F]{1,2}|u[0-9a-fA-F]{1,4}|o[0-7]{1,4})/.exec(e + st.src.substr(st.pos))
        if (m) {
          st.pos += m[0].length - 1
          var radix = { d: 10, x: 16, u: 16, o: 8 }[m[0].charAt(0)]
          item = node("literal", itemStart, st.pos, { value: parseInt(m[0].substr(1), radix), escaped: true })
        } else {
          item = node("literal", itemStart, st.pos - 1, { value: 92 })
          st.pos--
        }
      }
    } else {
      item = node("literal", itemStart, st.pos + 1, { value: st.nextCodePoint() })
      item.end = st.pos
    }
    if (st.peek() === "-" && st.peek(1) !== "]" && item.type === "literal" && st.pos + 1 < st.src.length) {
      st.pos++
      var toStart = st.pos
      var to = node("literal", toStart, toStart, { value: st.nextCodePoint() })
      to.end = st.pos
      items.push(node("range", item.start, st.pos, { from: item, to: to }))
      continue
    }
    items.push(item)
  }
  if (!closed) {
    // An unclosed [ is a literal [ in Vim.
    st.pos = start + (withNewline ? 3 : 1)
    return node("literal", start, st.pos, { value: 91 })
  }
  return node("class", start, st.pos, { negated: negated, items: items })
}

// ---- Lua ------------------------------------------------------------------------------

var LUA_CLASSES = { a: "alpha", c: "control", d: "digit", g: "printable", l: "lower", p: "punct", s: "space", u: "upper", w: "alnum", x: "hex" }

function parseLua(st) {
  var start = 0
  var items = []
  var depth = 0
  var stack = []
  var current = items
  if (st.peek() === "^") {
    st.pos++
    current.push(node("anchor", 0, 1, { kind: "start" }))
  }
  while (!st.eof()) {
    var c = st.peek()
    var s = st.pos
    if (c === "(") {
      st.pos++
      if (st.peek() === ")") {
        st.pos++
        var position = st.addGroup("", s, "position")
        position.end = st.pos
        current.push(node("group", s, st.pos, { kind: "position", index: position.index, name: "", body: node("empty", s + 1, s + 1, {}) }))
        continue
      }
      var group = st.addGroup("", s, "capture")
      stack.push({ items: current, start: s, group: group })
      current = []
      depth++
      continue
    }
    if (c === ")") {
      st.pos++
      if (depth === 0) {
        st.error("Unmatched )", s)
        continue
      }
      var frame = stack.pop()
      depth--
      frame.group.end = st.pos
      var body = current.length === 1 ? current[0] : (current.length ? node("sequence", current[0].start, current[current.length - 1].end, { items: current }) : node("empty", s, s, {}))
      current = frame.items
      current.push(node("group", frame.start, st.pos, { kind: "capture", index: frame.group.index, name: "", body: body }))
      luaStrayQuantifier(st)
      continue
    }
    if (c === "$" && st.pos === st.src.length - 1) {
      st.pos++
      current.push(node("anchor", s, st.pos, { kind: "end" }))
      continue
    }
    var item = luaSingle(st)
    if (!item) continue
    if (item.type === "balanced" || item.type === "frontier" || item.type === "backref") {
      current.push(item)
      continue
    }
    var q = st.peek()
    if (q === "*" || q === "+" || q === "-" || q === "?") {
      st.pos++
      var spec = { "*": [0, INFINITE, "greedy"], "+": [1, INFINITE, "greedy"], "-": [0, INFINITE, "lazy"], "?": [0, 1, "greedy"] }[q]
      current.push(node("quantifier", item.start, st.pos, { min: spec[0], max: spec[1], mode: spec[2], body: item, opStart: st.pos - 1 }))
      continue
    }
    current.push(item)
  }
  while (stack.length) {
    var open = stack.pop()
    st.error("Unfinished capture", open.start)
    current = open.items
  }
  if (items.length === 1) return items[0]
  if (items.length === 0) return node("empty", 0, 0, {})
  return node("sequence", start, st.pos, { items: items })
}

function luaStrayQuantifier(st) {
  var q = st.peek()
  if (q === "*" || q === "+" || q === "?")
    st.warn("Lua cannot repeat a capture; this " + q + " matches itself", st.pos)
}

// After a %: a class such as %a, or any other character taken literally.
function luaClassEscape(st, start) {
  var c = st.peek()
  var lower = c.toLowerCase()
  if (LUA_CLASSES[lower]) {
    st.pos++
    return node("chartype", start, st.pos, { kind: LUA_CLASSES[lower], negated: c !== lower })
  }
  var value = st.nextCodePoint()
  if (/[A-Za-z0-9]/.test(c)) st.error("%" + c + " is not a Lua character class", start, st.pos)
  return node("literal", start, st.pos, { value: value, escaped: true })
}

function luaSingle(st) {
  var start = st.pos
  var c = st.peek()
  if (c === ".") { st.pos++; return node("dot", start, st.pos, { newline: true }) }
  if (c === "%") {
    st.pos++
    if (st.eof()) { st.error("The pattern ends with %", start); return null }
    var e = st.peek()
    if (e === "b") {
      st.pos++
      if (st.src.length - st.pos < 2) { st.error("%b needs two characters", start, st.src.length); st.pos = st.src.length; return null }
      var open = st.src.charAt(st.pos), close = st.src.charAt(st.pos + 1)
      st.pos += 2
      return node("balanced", start, st.pos, { open: open, close: close })
    }
    if (e === "f") {
      st.pos++
      if (st.peek() !== "[") { st.error("%f needs a set in [ ]", start, st.pos); return null }
      var set = luaSet(st)
      return node("frontier", start, st.pos, { set: set })
    }
    if (isDigit(e)) {
      st.pos++
      if (e === "0") st.error("%0 is not a valid capture", start, st.pos)
      var ref = node("backref", start, st.pos, { ref: parseInt(e, 10), relative: false })
      st.backrefs.push(ref)
      return ref
    }
    return luaClassEscape(st, start)
  }
  if (c === "[") return luaSet(st)
  var value = st.nextCodePoint()
  return node("literal", start, st.pos, { value: value })
}

function luaSet(st) {
  var start = st.pos
  st.pos++
  var negated = false
  if (st.peek() === "^") { negated = true; st.pos++ }
  var items = []
  var first = true
  var closed = false
  while (!st.eof()) {
    var c = st.peek()
    if (c === "]" && !first) { st.pos++; closed = true; break }
    first = false
    var s = st.pos
    if (c === "%") {
      st.pos++
      if (st.eof()) break
      items.push(luaClassEscape(st, s))
      continue
    }
    var from = node("literal", s, s, { value: st.nextCodePoint() })
    from.end = st.pos
    if (st.peek() === "-" && st.peek(1) !== "]" && st.pos + 1 < st.src.length) {
      st.pos++
      var t = st.pos
      var to = node("literal", t, t, { value: st.nextCodePoint() })
      to.end = st.pos
      items.push(node("range", s, st.pos, { from: from, to: to }))
      continue
    }
    items.push(from)
  }
  if (!closed) st.error("The set is missing its closing ]", start, st.pos)
  return node("class", start, st.pos, { negated: negated, items: items })
}

// ---- after parsing ---------------------------------------------------------------

function checkReferences(st) {
  var count = st.groupCount
  for (var i = 0; i < st.backrefs.length; i++) {
    var ref = st.backrefs[i]
    if (typeof ref.ref === "string") {
      if (st.names[ref.ref] === undefined) st.error("No group is named '" + ref.ref + "'", ref.start, ref.end)
      continue
    }
    var target = ref.relative ? null : ref.ref
    if (target !== null && (target > count || target < 1)) {
      if (st.js && !st.mode.u) continue
      st.error("The pattern has no group " + target, ref.start, ref.end)
    }
  }
  for (var j = 0; j < st.recursions.length; j++) {
    var rec = st.recursions[j]
    if (typeof rec.ref === "string" && st.names[rec.ref] === undefined) st.error("No group is named '" + rec.ref + "'", rec.start, rec.end)
    else if (typeof rec.ref === "number" && !rec.relative && rec.ref > count) st.error("The pattern has no group " + rec.ref, rec.start, rec.end)
  }
}

// .NET numbers unnamed groups first and named groups after them.
function renumberDotnet(st, ast) {
  var groups = st.groups.slice().sort(function(a, b) { return a.start - b.start })
  var next = 1
  var byOld = {}
  for (var i = 0; i < groups.length; i++) if (!groups[i].name) { byOld[groups[i].index] = next; groups[i].index = next++ }
  var nameIndex = {}
  for (var j = 0; j < groups.length; j++) {
    if (!groups[j].name) continue
    if (nameIndex[groups[j].name] === undefined) nameIndex[groups[j].name] = next++
    byOld[groups[j].index] = nameIndex[groups[j].name]
    groups[j].index = nameIndex[groups[j].name]
  }
  walk(ast, function(n) { if (n.type === "group" && n.index && byOld[n.index]) n.index = byOld[n.index] })
  st.names = nameIndex
  st.groupCount = next - 1
}

// ---- API ----------------------------------------------------------------------------

function parse(pattern, flavorId, flags) {
  var flavor = Flavors.byId(flavorId)
  var st = new State(String(pattern || ""), flavor, flags || [])
  var ast
  if (flavor.family === "perl") ast = parsePerl(st)
  else if (flavor.family === "ere") ast = parsePosix(st, false)
  else if (flavor.family === "bre") ast = parsePosix(st, true)
  else if (flavor.family === "vim") ast = parseVim(st)
  else ast = parseLua(st)
  checkReferences(st)
  if (flavor.id === "dotnet") renumberDotnet(st, ast)
  st.groups.sort(function(a, b) { return a.index - b.index || a.start - b.start })
  st.errors.sort(function(a, b) { return a.start - b.start })
  return {
    ast: ast,
    errors: st.errors,
    warnings: st.warnings,
    groups: st.groups,
    groupCount: st.groupCount,
    names: st.names,
    flavor: flavor.id,
  }
}

// Calls fn on every node, depth first, parents before children.
function walk(n, fn, parent) {
  if (!n) return
  if (fn(n, parent) === false) return
  var kids = children(n)
  for (var i = 0; i < kids.length; i++) walk(kids[i], fn, n)
}

function children(n) {
  switch (n.type) {
  case "alternation": return n.alternatives
  case "sequence": return n.items
  case "quote": return n.items
  case "class": return n.items
  case "range": return [n.from, n.to]
  case "setop": return [n.left, n.right]
  case "group": return [n.body]
  case "quantifier": return [n.body]
  case "frontier": return [n.set]
  case "conditional":
    var kids = []
    if (n.condition.assertion) kids.push(n.condition.assertion)
    kids.push(n.yes)
    if (n.no) kids.push(n.no)
    return kids
  }
  return []
}

// The shortest and longest text a node can match, in characters (max -1 when
// unbounded). Backreferences and recursion count as unbounded.
function width(n) {
  switch (n.type) {
  case "literal": return { min: 1, max: 1 }
  case "dot": case "class": case "chartype": case "property": case "posixclass": case "equivalence": case "collating":
    return n.type === "chartype" && (n.kind === "newline" || n.kind === "grapheme") ? { min: 1, max: n.kind === "newline" ? 2 : INFINITE } : { min: 1, max: 1 }
  case "quote": return { min: n.items.length, max: n.items.length }
  case "anchor": case "flags": case "comment": case "verb": case "callout": case "empty": case "frontier":
    return { min: 0, max: 0 }
  case "sequence":
    var min = 0, max = 0
    for (var i = 0; i < n.items.length; i++) {
      var w = width(n.items[i])
      min += w.min
      max = (max === INFINITE || w.max === INFINITE) ? INFINITE : max + w.max
    }
    return { min: min, max: max }
  case "alternation":
    var lo = Infinity, hi = 0
    for (var j = 0; j < n.alternatives.length; j++) {
      var a = width(n.alternatives[j])
      lo = Math.min(lo, a.min)
      hi = (hi === INFINITE || a.max === INFINITE) ? INFINITE : Math.max(hi, a.max)
    }
    return { min: lo === Infinity ? 0 : lo, max: hi }
  case "group":
    if (/ook(ahead|behind)$/.test(n.kind)) return { min: 0, max: 0 }
    return width(n.body)
  case "quantifier":
    var b = width(n.body)
    return {
      min: b.min * n.min,
      max: (n.max === INFINITE || b.max === INFINITE) ? (b.max === 0 ? 0 : INFINITE) : b.max * n.max,
    }
  case "conditional":
    var y = width(n.yes), no = n.no ? width(n.no) : { min: 0, max: 0 }
    return { min: Math.min(y.min, no.min), max: (y.max === INFINITE || no.max === INFINITE) ? INFINITE : Math.max(y.max, no.max) }
  case "balanced": return { min: 2, max: INFINITE }
  }
  return { min: 0, max: INFINITE }
}

// The innermost node whose span holds offset, and its ancestors.
function nodePath(ast, offset) {
  var path = []
  walk(ast, function(n) {
    if (offset < n.start || offset >= n.end) return false
    path.push(n)
  })
  return path
}

if (typeof module !== "undefined") module.exports = {
  INFINITE: INFINITE,
  parse: parse,
  walk: walk,
  children: children,
  width: width,
  nodePath: nodePath,
}
