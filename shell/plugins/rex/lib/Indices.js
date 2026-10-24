.pragma library
.import "Parser.js" as Parser

// Exact group positions for engines that only report group text.
//
// Qt's JavaScript engine has no `d` flag, so exec() says what each group
// matched but not where. Rex rewrites the pattern with extra capturing
// groups around whatever precedes each group; a group's start is then the
// match start plus the lengths of some of those captures, minus others.
// The rewrite matches exactly what the original matches.
//
// rewrite() returns { source, plan } where plan[g - 1] describes original
// group g: { index, terms } with index its number in the rewritten pattern
// and terms [[capture, sign], ...]. locate() turns an exec() result into
// [start, end] pairs.

function hasGroups(n) {
  var found = false
  Parser.walk(n, function(child) {
    if (found) return false
    if (child.type === "group" && child.index) found = true
    if (child.type === "backref") found = true
  })
  return found
}

function capturesInside(n) {
  var found = false
  Parser.walk(n, function(child) {
    if (found) return false
    if (child.type === "group" && child.index) found = true
  })
  return found
}

function Emitter(pattern) {
  this.pattern = pattern
  this.count = 0
  this.plan = []
  this.original = {}
}

Emitter.prototype.text = function(n) {
  return this.pattern.substring(n.start, n.end)
}

// A new capturing group for bookkeeping; returns its number.
Emitter.prototype.aux = function() {
  return ++this.count
}

// Emits n, whose start is base (a list of terms), and returns its source.
Emitter.prototype.emit = function(n, base) {
  if (!hasGroups(n)) return this.text(n)
  switch (n.type) {
  case "backref":
    // Renumbered after emission, once every group's new number is known.
    if (typeof n.ref === "number") return "" + n.ref + ""
    return this.text(n)
  case "sequence": return this.sequence(n.items, base)
  case "alternation":
    var self = this
    return n.alternatives.map(function(a) { return self.emit(a, base) }).join("|")
  case "group": return this.group(n, base)
  case "quantifier": return this.quantifier(n, base)
  }
  return this.text(n)
}

Emitter.prototype.group = function(n, base) {
  if (n.index) {
    var index = ++this.count
    this.original[n.index] = index
    this.plan[n.index - 1] = { index: index, terms: base }
    var open = n.kind === "named" ? "(?<" + n.name + ">" : "("
    return open + this.emit(n.body, base) + ")"
  }
  var prefix = {
    noncapture: "(?:", lookahead: "(?=", negativeLookahead: "(?!",
    lookbehind: "(?<=", negativeLookbehind: "(?<!", atomic: "(?>",
  }[n.kind] || "(?:"
  return prefix + this.emit(n.body, base) + ")"
}

// The last iteration of a repeated body starts where the whole repetition
// ends minus that iteration's length.
Emitter.prototype.quantifier = function(n, base) {
  var quant = this.pattern.substring(n.opStart, n.end)
  if (!capturesInside(n.body)) return this.emit(n.body, base) + quant
  var whole = this.aux()
  var iteration = this.aux()
  var inner = base.concat([[whole, 1], [iteration, -1]])
  return "((?:(" + this.emit(n.body, inner) + "))" + quant + ")"
}

// Items before a group are captured so their lengths can be added up.
// Consecutive items that hold no groups share one capture.
Emitter.prototype.sequence = function(items, base) {
  var out = ""
  var terms = base.slice()
  var pending = []
  var self = this
  function flush() {
    if (!pending.length) return
    var index = self.aux()
    out += "(" + pending.join("") + ")"
    terms = terms.concat([[index, 1]])
    pending = []
  }
  for (var i = 0; i < items.length; i++) {
    var item = items[i]
    var last = i === items.length - 1
    if (!capturesInside(item)) {
      var source = this.emit(item, terms)
      if (last) { flush(); out += source }
      else pending.push(source)
      continue
    }
    flush()
    if (last) {
      out += this.emit(item, terms)
      continue
    }
    // The item's own length is needed for what follows it.
    if (item.type === "group" && item.index) {
      var emitted = this.emit(item, terms)
      terms = terms.concat([[this.original[item.index], 1]])
      out += emitted
    } else {
      var wrap = this.aux()
      out += "(" + this.emit(item, terms) + ")"
      terms = terms.concat([[wrap, 1]])
    }
  }
  flush()
  return out
}

function rewrite(pattern, parsed) {
  if (parsed.groupCount === 0) return { source: pattern, plan: [] }
  var emitter = new Emitter(pattern)
  var body = emitter.emit(parsed.ast, [])
  var source = body.replace(/(\d+)/g, function(all, n) {
    var mapped = emitter.original[parseInt(n, 10)]
    // Wrapped so a following digit or quantifier keeps its meaning. A
    // reference to a group that does not exist is left for the engine.
    return mapped !== undefined ? "(?:\\" + mapped + ")" : "\\" + n
  })
  return { source: source, plan: emitter.plan }
}

// [start, end, start, end, ...] for the match and each original group.
function locate(m, plan, groupCount) {
  var out = [m.index, m.index + m[0].length]
  for (var g = 1; g <= groupCount; g++) {
    var p = plan[g - 1]
    var value = p ? m[p.index] : undefined
    if (value === undefined) { out.push(-1, -1); continue }
    var start = m.index
    for (var t = 0; t < p.terms.length; t++) {
      var piece = m[p.terms[t][0]]
      start += (piece === undefined ? 0 : piece.length) * p.terms[t][1]
    }
    out.push(start, start + value.length)
  }
  return out
}

if (typeof module !== "undefined") module.exports = { rewrite: rewrite, locate: locate }
