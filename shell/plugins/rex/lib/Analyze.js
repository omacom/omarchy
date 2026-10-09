.pragma library
.import "Parser.js" as Parser
.import "Flavors.js" as Flavors

// Finds what makes a pattern slow, fragile, or harder to read, and how to
// fix it. analyze() returns findings:
//   { id, severity, title, detail, start, end, rewrite, changesGroups, witness }
// severity: "danger" (catastrophic backtracking), "warning", "tip", "info".
// rewrite is the whole pattern with the fix applied, or "" when the finding
// only explains. Rex runs a rewrite on the real engine before offering it.
// witness, for backtracking risks, is a function of n that builds a text on
// which the pattern slows down as n grows.

var INF = Parser.INFINITE

// ---- character sets, by sampling ---------------------------------------------
//
// Deciding exactly whether two classes overlap means modelling every
// engine's Unicode tables. Testing a broad sample of characters gets the
// cases that matter right: ASCII, Latin letters, digits from other scripts,
// whitespace of every kind, and a few symbols and emoji.

var SAMPLE = (function() {
  var out = []
  for (var c = 9; c <= 13; c++) out.push(c)
  for (var a = 32; a < 127; a++) out.push(a)
  out.push(0xa0, 0xe9, 0xc9, 0xdf, 0x3b1, 0x416, 0x5d0, 0x663, 0x966, 0x2003, 0x2028, 0x3000, 0x4e2d, 0x20ac, 0x1f600)
  return out
})()

function isWordCp(cp, unicode) {
  if (cp === 95) return true
  if ((cp >= 48 && cp <= 57) || (cp >= 65 && cp <= 90) || (cp >= 97 && cp <= 122)) return true
  return unicode && (cp === 0xe9 || cp === 0xc9 || cp === 0xdf || cp === 0x3b1 || cp === 0x416 || cp === 0x5d0 || cp === 0x663 || cp === 0x966 || cp === 0x4e2d)
}

function isDigitCp(cp, unicode) {
  return (cp >= 48 && cp <= 57) || (unicode && (cp === 0x663 || cp === 0x966))
}

function isSpaceCp(cp, unicode) {
  return (cp >= 9 && cp <= 13) || cp === 32 || (unicode && (cp === 0xa0 || cp === 0x2003 || cp === 0x2028 || cp === 0x3000))
}

function lower(cp) {
  if (cp >= 65 && cp <= 90) return cp + 32
  if (cp === 0xc9) return 0xe9
  return cp
}

// Whether a single-character node can match cp. Returns null for nodes that
// are not single characters.
function contains(n, cp, ctx) {
  switch (n.type) {
  case "literal":
    return n.value === cp || (ctx.icase && lower(n.value) === lower(cp))
  case "dot":
    return n.newline || ctx.dotall || cp !== 10
  case "chartype":
    var r
    switch (n.kind) {
    case "digit": r = isDigitCp(cp, ctx.unicode); break
    case "word": r = isWordCp(cp, ctx.unicode); break
    case "space": r = isSpaceCp(cp, ctx.unicode); break
    case "hspace": r = cp === 9 || cp === 32 || cp === 0xa0 || cp === 0x2003 || cp === 0x3000; break
    case "vspace": r = cp >= 10 && cp <= 13 || cp === 0x2028; break
    case "hex": r = (cp >= 48 && cp <= 57) || (cp >= 65 && cp <= 70) || (cp >= 97 && cp <= 102); break
    case "notnewline": r = cp !== 10; break
    case "alpha": r = (cp >= 65 && cp <= 90) || (cp >= 97 && cp <= 122); break
    case "lower": r = cp >= 97 && cp <= 122; break
    case "upper": r = cp >= 65 && cp <= 90; break
    case "alnum": r = isWordCp(cp, false) && cp !== 95; break
    case "punct": r = cp > 32 && cp < 127 && !isWordCp(cp, false) || cp === 95; break
    case "control": r = cp < 32 || cp === 127; break
    case "printable": r = cp >= 32 && cp !== 127; break
    default: r = true
    }
    return n.negated ? !r : r
  case "property":
    var name = String(n.name).replace(/^Is/, "")
    var p = /^L/.test(name) || name === "Letter" || name === "Alphabetic" ? isWordCp(cp, true) && !isDigitCp(cp, true) && cp !== 95
      : /^N/.test(name) || name === "Number" ? isDigitCp(cp, true)
      : /^Z/.test(name) ? isSpaceCp(cp, true) && cp > 13
      : /^P/.test(name) || name === "Punctuation" ? cp > 32 && cp < 127 && !isWordCp(cp, false)
      : true
    return n.negated ? !p : p
  case "posixclass":
    var map = { alpha: "alpha", digit: "digit", alnum: "alnum", space: "space", upper: "upper", lower: "lower", punct: "punct", xdigit: "hex", word: "word", cntrl: "control", print: "printable", graph: "printable", blank: "hspace" }
    var res = contains({ type: "chartype", kind: map[n.name] || "printable", negated: false }, cp, ctx)
    return n.negated ? !res : res
  case "range":
    return (cp >= n.from.value && cp <= n.to.value) || (ctx.icase && lower(cp) >= lower(n.from.value) && lower(cp) <= lower(n.to.value))
  case "class":
    var any = false
    for (var i = 0; i < n.items.length && !any; i++) any = contains(n.items[i], cp, ctx) === true
    return n.negated ? !any : any
  case "setop":
    var l = contains(n.left, cp, ctx), rr = contains(n.right, cp, ctx)
    if (n.op === "&&") return l && rr
    if (n.op === "~~") return l !== rr
    return l && !rr
  case "quote":
    return n.items.length ? contains(n.items[0], cp, ctx) : false
  }
  return null
}

// The characters (from the sample) a node can start with, or null when it
// can start with anything we cannot tell.
function firstSet(n, ctx) {
  var direct = contains(n, 65, ctx)
  if (direct !== null && n.type !== "quote") return SAMPLE.filter(function(cp) { return contains(n, cp, ctx) })
  switch (n.type) {
  case "quote": return n.items.length ? firstSet(n.items[0], ctx) : []
  case "group":
    if (/ook/.test(n.kind)) return []
    return firstSet(n.body, ctx)
  case "quantifier": return firstSet(n.body, ctx)
  case "sequence":
    var out = []
    for (var i = 0; i < n.items.length; i++) {
      out = union(out, firstSet(n.items[i], ctx) || SAMPLE)
      if (Parser.width(n.items[i]).min > 0) break
    }
    return out
  case "alternation":
    var all = []
    for (var a = 0; a < n.alternatives.length; a++) all = union(all, firstSet(n.alternatives[a], ctx) || SAMPLE)
    return all
  case "anchor": case "empty": case "flags": case "comment": return []
  }
  return SAMPLE
}

function union(a, b) {
  var seen = {}
  var out = []
  for (var i = 0; i < a.length; i++) if (!seen[a[i]]) { seen[a[i]] = true; out.push(a[i]) }
  for (var j = 0; j < b.length; j++) if (!seen[b[j]]) { seen[b[j]] = true; out.push(b[j]) }
  return out
}

function intersect(a, b) {
  var inB = {}
  for (var i = 0; i < b.length; i++) inB[b[i]] = true
  return a.filter(function(cp) { return inB[cp] })
}

function charOf(cp) {
  return String.fromCharCode.apply(null, cp > 0xffff ? [0xd800 + ((cp - 0x10000) >> 10), 0xdc00 + ((cp - 0x10000) & 0x3ff)] : [cp])
}

// A character none of the given sets contain, for the end of a witness.
function outsider(sets) {
  var candidates = [33, 64, 35, 126, 10, 0x1f600, 0x2028, 46, 32]
  for (var i = 0; i < candidates.length; i++) {
    var cp = candidates[i]
    var inside = false
    for (var s = 0; s < sets.length && !inside; s++) inside = sets[s].indexOf(cp) >= 0
    if (!inside) return charOf(cp)
  }
  return "!"
}

// A short string the node can match, for building witnesses.
function sampleText(n, ctx) {
  var w = Parser.width(n)
  var set = firstSet(n, ctx)
  if (!set || !set.length) return ""
  var c = charOf(preferred(set))
  return c.length && w.min > 1 ? new Array(Math.min(w.min, 4) + 1).join(c) : c
}

function preferred(set) {
  // Letters read better in a witness than punctuation.
  var order = [97, 120, 49, 48, 32]
  for (var i = 0; i < order.length; i++) if (set.indexOf(order[i]) >= 0) return order[i]
  return set[0]
}

// ---- helpers -------------------------------------------------------------------

function source(pattern, n) {
  return pattern.substring(n.start, n.end)
}

function splice(pattern, start, end, text) {
  return pattern.substring(0, start) + text + pattern.substring(end)
}

function unbounded(q) {
  return q.type === "quantifier" && q.max === INF
}

function repeats(q) {
  return q.type === "quantifier" && (q.max === INF || q.max > 1)
}

// The node inside groups that do nothing but group.
function unwrap(n) {
  while (n.type === "group" && (n.kind === "noncapture" || n.kind === "capture" || n.kind === "named")) n = n.body
  return n
}

function hasCapture(n) {
  var found = false
  Parser.walk(n, function(c) { if (c.type === "group" && c.index) found = true })
  return found
}

function isSingleChar(n) {
  return n.type === "literal" || n.type === "class" || n.type === "chartype" || n.type === "property" || n.type === "dot"
}

var META = "\\^$.|?*+()[]{}"

function escapeChar(c, inClass) {
  var special = inClass ? "\\]^-[" : META
  return special.indexOf(c) >= 0 ? "\\" + c : c
}

// ---- the rules -------------------------------------------------------------------

function analyze(pattern, flavorId, flags) {
  flags = flags || []
  var flavor = Flavors.byId(flavorId)
  var parsed = Parser.parse(pattern, flavorId, flags)
  var findings = []
  if (pattern === "" || parsed.errors.length) return findings
  var f = flavor.features || {}
  var backtracking = flavor.engine === "backtracking"
  var ctx = {
    icase: flags.indexOf("i") >= 0,
    dotall: flags.indexOf("s") >= 0 || (flavor.id === "ruby" && flags.indexOf("m") >= 0),
    unicode: /^(python|python-regex|perl|rust|dotnet)$/.test(flavor.id) || flags.indexOf("u") >= 0 && flavor.id === "pcre2",
  }
  function add(item) {
    item.rewrite = item.rewrite || ""
    item.changesGroups = item.changesGroups === true
    findings.push(item)
  }
  var ast = parsed.ast
  var referenced = {}
  Parser.walk(ast, function(n) {
    if (n.type === "backref" || n.type === "recursion") referenced[n.ref] = true
  })

  // ---- catastrophic and polynomial backtracking ----
  if (backtracking) {
    Parser.walk(ast, function(n) {
      if (n.type !== "quantifier" || !repeats(n) || n.mode === "possessive") return
      var body = unwrap(n.body)
      if (n.body.type === "group" && n.body.kind === "atomic") return
      // A repeated body that contains another repetition that can match the
      // same text in more than one way: (a+)+, (\w+\s?)*, (x*)*
      var inner = null
      Parser.walk(body, function(c) {
        if (inner) return false
        if (c.type === "group" && (c.kind === "atomic" || /ook/.test(c.kind))) return false
        if (c.type === "quantifier" && unbounded(c) && c.mode !== "possessive" && Parser.width(c.body).min > 0) inner = c
      })
      if (inner && Parser.width(body).max !== 0) {
        var innerSet = firstSet(inner.body, ctx) || SAMPLE
        var follow = followSet(ast, n, ctx)
        var unit = charOf(preferred(innerSet))
        var tail = outsider([innerSet, follow])
        var fix = possessiveFix(pattern, n, inner, f)
        add({
          id: "nested-quantifier",
          severity: "danger",
          title: "Catastrophic backtracking: a repetition inside a repetition",
          detail: source(pattern, inner) + " sits inside " + source(pattern, n) + ", so a run of " + JSON.stringify(unit) + " can be split between them in exponentially many ways. When the rest of the pattern fails, a backtracking engine tries every split: " + JSON.stringify(new Array(26).join(unit) + tail) + " can take minutes." + (fix.note ? " " + fix.note : ""),
          start: n.start,
          end: n.end,
          rewrite: fix.rewrite,
          changesGroups: fix.changesGroups,
          witness: { unit: unit, tail: tail },
        })
        return false
      }
      // Alternatives inside a repetition that can match the same text:
      // (a|ab)*, (\w|\d)+
      if (body.type === "alternation") {
        var sets = body.alternatives.map(function(a) { return firstSet(a, ctx) || SAMPLE })
        for (var i = 0; i < sets.length; i++) {
          for (var j = i + 1; j < sets.length; j++) {
            var shared = intersect(sets[i], sets[j])
            if (!shared.length) continue
            var u = charOf(preferred(shared))
            var t = outsider([union(sets[i], sets[j]), followSet(ast, n, ctx)])
            add({
              id: "overlapping-alternation",
              severity: Parser.width(body.alternatives[i]).max === 1 && Parser.width(body.alternatives[j]).max === 1 ? "danger" : "warning",
              title: "Backtracking risk: repeated alternatives that overlap",
              detail: "Alternatives " + (i + 1) + " and " + (j + 1) + " of " + source(pattern, n) + " can both match " + JSON.stringify(u) + ", so each repetition can be matched more than one way. On a long run of " + JSON.stringify(u) + " that ends in " + JSON.stringify(t) + " the engine tries them all. Make the alternatives exclusive, or merge them into one class.",
              start: n.start,
              end: n.end,
              witness: { unit: u, tail: t },
            })
            return false
          }
        }
      }
    })

    // Adjacent unbounded repetitions of overlapping sets: \d+\d+, \w*\s*\w*
    Parser.walk(ast, function(n) {
      if (n.type !== "sequence") return
      for (var i = 0; i < n.items.length; i++) {
        var a = n.items[i]
        if (!unbounded(a) || a.mode === "possessive") continue
        for (var j = i + 1; j < n.items.length; j++) {
          var b = n.items[j]
          if (unbounded(b) && b.mode !== "possessive") {
            var shared = intersect(firstSet(a.body, ctx) || SAMPLE, firstSet(b.body, ctx) || SAMPLE)
            if (shared.length && isSingleChar(unwrap(a.body)) && isSingleChar(unwrap(b.body))) {
              var u = charOf(preferred(shared))
              add({
                id: "adjacent-quantifiers",
                severity: "warning",
                title: "Slow on long input: two repetitions compete for the same characters",
                detail: source(pattern, a) + " and " + source(pattern, b) + " can both match " + JSON.stringify(u) + ", so a run of n of them can be divided n ways, and the engine tries each when what follows fails: quadratic time, or worse with more of them.",
                start: a.start,
                end: b.end,
                witness: { unit: u, tail: outsider([shared]) },
              })
            }
            break
          }
          if (Parser.width(b).min > 0) break
        }
      }
    })

    // Possessive quantifiers where giving back can never help: \d+ followed
    // by something that cannot start with a digit.
    if (f.possessive || f.atomic) {
      Parser.walk(ast, function(n) {
        if (n.type !== "sequence") return
        for (var i = 0; i + 1 < n.items.length; i++) {
          var q = n.items[i]
          if (!(q.type === "quantifier" && q.mode === "greedy" && repeats(q) && isSingleChar(q.body))) continue
          var next = n.items[i + 1]
          if (Parser.width(next).min === 0) continue
          var mine = firstSet(q.body, ctx)
          var theirs = firstSet(next, ctx)
          if (!mine || !theirs || theirs.length === SAMPLE.length || intersect(mine, theirs).length) continue
          var op = pattern.substring(q.opStart, q.end)
          var rewrite = f.possessive
            ? splice(pattern, q.end, q.end, "+")
            : splice(splice(pattern, q.end, q.end, ")"), q.start, q.start, "(?>")
          add({
            id: "possessive",
            severity: "tip",
            title: "Never give back: " + source(pattern, q) + (f.possessive ? " can be possessive" : " can be atomic"),
            detail: "What follows, " + source(pattern, next) + ", can never start with what " + source(pattern, q.body) + " matches, so backtracking into " + op + " can never help. Saying so spares the engine from trying when the match fails." + (flavor.id === "pcre2" ? " PCRE2 does this on its own (auto-possessification), but other engines do not." : ""),
            start: q.start,
            end: q.end,
            rewrite: rewrite,
          })
        }
      })
    }
  }

  // ---- lazy dot before a delimiter ----
  Parser.walk(ast, function(n) {
    if (n.type !== "sequence") return
    for (var i = 0; i + 1 < n.items.length; i++) {
      var q = n.items[i]
      if (!(q.type === "quantifier" && q.mode === "lazy" && q.max === INF && q.body.type === "dot")) continue
      var next = n.items[i + 1]
      if (next.type !== "literal") continue
      var c = String.fromCharCode(next.value)
      var newline = ctx.dotall || q.body.newline ? "" : "\\n"
      var cls = "[^" + escapeChar(c, true) + newline + "]" + pattern.substring(q.opStart, q.end - 1)
      add({
        id: "lazy-dot",
        severity: "tip",
        title: "Say what to skip: " + source(pattern, q) + source(pattern, next) + " → " + cls + source(pattern, next),
        detail: "A lazy " + source(pattern, q) + " tries the rest of the pattern after every character it takes. A class that excludes " + JSON.stringify(c) + " runs straight to it, and reads as what it means.",
        start: q.start,
        end: q.end,
        rewrite: splice(pattern, q.start, q.end, cls),
      })
    }
  })

  // ---- an unanchored leading .* ----
  var first = ast.type === "sequence" ? ast.items[0] : ast
  if (backtracking && first && first.type === "quantifier" && first.body.type === "dot" && first.max === INF && first.mode === "greedy") {
    add({
      id: "leading-dotstar",
      severity: "warning",
      title: "A leading " + source(pattern, first) + " is tried from every position",
      detail: "When there is no match, the engine starts again one character later and runs " + source(pattern, first) + " to the end each time, which is quadratic in the line length. Anchor it with ^" + (ctx.dotall ? "" : " (and the m flag to work per line)") + ", or drop it if you only need where the rest matches.",
      start: first.start,
      end: first.end,
      rewrite: "^" + pattern,
    })
  }

  // ---- simpler ways to write the same thing ----
  Parser.walk(ast, function(n, parent) {
    // {1}, {0,1}, {0,}, {1,}
    if (n.type === "quantifier") {
      var op = pattern.substring(n.opStart, n.end)
      var suffix = op.replace(/^(\{[^}]*\}|[*+?])/, "")
      var simpler = null
      if (/^\{1\}$/.test(op.substr(0, op.length - suffix.length)) && suffix === "") simpler = ""
      else if (n.min === 0 && n.max === 1 && op.charAt(0) === "{") simpler = "?" + suffix
      else if (n.min === 0 && n.max === INF && op.charAt(0) === "{") simpler = "*" + suffix
      else if (n.min === 1 && n.max === INF && op.charAt(0) === "{") simpler = "+" + suffix
      if (simpler !== null && flavor.family === "perl") {
        add({
          id: "quantifier-shorthand",
          severity: "info",
          title: op + (simpler === "" ? " repeats once: leave it out" : " is written " + simpler),
          detail: "The same meaning, shorter.",
          start: n.opStart,
          end: n.end,
          rewrite: splice(pattern, n.opStart, n.end, simpler),
        })
      }
    }
    // A single character in a class: [a] → a
    if (n.type === "class" && !n.negated && n.items.length === 1 && n.items[0].type === "literal" && !(parent && parent.type === "setop")) {
      var ch = String.fromCharCode(n.items[0].value)
      if (n.items[0].value < 128 && n.items[0].value > 32) {
        add({
          id: "single-class",
          severity: "info",
          title: source(pattern, n) + " is just " + escapeChar(ch, false),
          detail: "A class of one character matches that character; " + (META.indexOf(ch) >= 0 ? "escaping it says so directly." : "writing it plainly is clearer."),
          start: n.start,
          end: n.end,
          rewrite: splice(pattern, n.start, n.end, escapeChar(ch, false)),
        })
      }
    }
    // [0-9] → \d, [^\s] → \S, where it means the same here
    if (n.type === "class" && n.items.length === 1 && n.items[0].type === "range" && n.items[0].from.value === 48 && n.items[0].to.value === 57 && flavor.family === "perl" && !ctx.unicode) {
      add({
        id: "digit-class",
        severity: "info",
        title: source(pattern, n) + " can be written " + (n.negated ? "\\D" : "\\d"),
        detail: "In " + flavor.name + " with these flags, \\d means exactly 0–9.",
        start: n.start,
        end: n.end,
        rewrite: splice(pattern, n.start, n.end, n.negated ? "\\D" : "\\d"),
      })
    }
    if (n.type === "class" && n.negated && n.items.length === 1 && n.items[0].type === "chartype" && !n.items[0].negated && /^(digit|word|space)$/.test(n.items[0].kind)) {
      var letter = { digit: "\\D", word: "\\W", space: "\\S" }[n.items[0].kind]
      add({
        id: "negated-shorthand",
        severity: "info",
        title: source(pattern, n) + " is " + letter,
        detail: "The uppercase shorthand already means 'not'.",
        start: n.start,
        end: n.end,
        rewrite: splice(pattern, n.start, n.end, letter),
      })
    }
    // Duplicate characters in a class
    if (n.type === "class") {
      var seen = {}
      for (var k = 0; k < n.items.length; k++) {
        var it = n.items[k]
        if (it.type !== "literal") continue
        if (seen[it.value]) {
          add({
            id: "duplicate-in-class",
            severity: "info",
            title: "The class lists " + escapeChar(String.fromCharCode(it.value), true) + " twice",
            detail: "Listing a character again changes nothing.",
            start: it.start,
            end: it.end,
            rewrite: splice(pattern, it.start, it.end, ""),
          })
          break
        }
        seen[it.value] = true
      }
    }
    // Needless escapes outside classes: \- \: \" \' \, \= \! \< \> \@ \# \% \&
    if (n.type === "literal" && n.escaped && pattern.charAt(n.start) === "\\" && n.end - n.start === 2 && flavor.family === "perl" && !(parent && parent.type === "class") && !(parent && parent.type === "range")) {
      var e = pattern.charAt(n.start + 1)
      if ("-:\"',=!@%&~`;/".indexOf(e) >= 0 && !(e === "-" && flavor.id === "ecmascript") && !(e === "/" && /node|ecmascript/.test(flavor.id))) {
        add({
          id: "needless-escape",
          severity: "info",
          title: "\\" + e + " needs no backslash",
          detail: e + " has no special meaning outside a class.",
          start: n.start,
          end: n.end,
          rewrite: splice(pattern, n.start, n.end, e),
        })
      }
    }
    // Single characters as alternatives: (a|b|c) → [abc]
    if (n.type === "alternation" && n.alternatives.length > 1 && n.alternatives.every(function(a) { return a.type === "literal" || (a.type === "class" && !a.negated) || a.type === "chartype" })) {
      var inner = n.alternatives.map(function(a) {
        if (a.type === "literal") return escapeChar(String.fromCharCode(a.value), true)
        if (a.type === "class") return source(pattern, a).slice(1, -1)
        return source(pattern, a)
      }).join("")
      // A non-capturing group around the alternatives goes too.
      var whole = parent && parent.type === "group" && parent.kind === "noncapture" ? parent : n
      add({
        id: "alternation-to-class",
        severity: "tip",
        title: source(pattern, whole) + " is the class [" + inner + "]",
        detail: "Alternatives of single characters make the engine try each in turn and remember where to come back to; a class tests one character once.",
        start: whole.start,
        end: whole.end,
        rewrite: splice(pattern, whole.start, whole.end, "[" + inner + "]"),
      })
    }
    // A shared literal prefix: (?:foo|fob) → fo(?:o|b)
    if (n.type === "alternation" && n.alternatives.length > 1 && parent && parent.type === "group" && parent.kind === "noncapture") {
      var texts = n.alternatives.map(function(a) { return literalText(a) })
      if (texts.every(function(t) { return t !== null && t.length > 0 })) {
        var prefix = texts[0]
        for (var x = 1; x < texts.length; x++) while (texts[x].indexOf(prefix) !== 0) prefix = prefix.slice(0, -1)
        if (prefix.length >= 2 && texts.every(function(t) { return t.length > prefix.length })) {
          var rest = n.alternatives.map(function(a) { return pattern.substring(a.start, a.end).substr(literalSourceLength(pattern, a, prefix.length)) })
          var rewritten = escapeLiteral(prefix) + "(?:" + rest.join("|") + ")"
          add({
            id: "common-prefix",
            severity: "tip",
            title: "Every alternative starts with " + JSON.stringify(prefix),
            detail: "Matching the shared start once, then branching, saves retrying it for every alternative that fails.",
            start: parent.start,
            end: parent.end,
            rewrite: splice(pattern, parent.start, parent.end, rewritten),
          })
        }
      }
    }
    // An empty alternative: (a|) → a?
    if (n.type === "alternation" && n.alternatives.length === 2 && n.alternatives[1].type === "empty" && parent && parent.type === "group" && parent.kind === "noncapture") {
      add({
        id: "empty-alternative",
        severity: "info",
        title: "An empty alternative is an optional group",
        detail: source(pattern, parent) + " says 'this, or nothing'; ? says it more plainly.",
        start: parent.start,
        end: parent.end,
        rewrite: splice(pattern, parent.start, parent.end, "(?:" + source(pattern, n.alternatives[0]) + ")?"),
      })
    }
    // Repeated groups that capture without being used: the engine saves a
    // capture on every repetition.
    if (n.type === "quantifier" && repeats(n) && n.body.type === "group" && n.body.kind === "capture" && !referenced[n.body.index] && flavor.family === "perl") {
      var g = n.body
      add({
        id: "unused-capture",
        severity: "info",
        title: "Group " + g.index + " captures on every repetition",
        detail: "A repeated capturing group records each repetition, and keeps only the last. If nothing reads group " + g.index + ", (?:...) groups without that work. Group numbers after it shift down by one, so replacements and code that use them need updating.",
        start: g.start,
        end: g.end,
        rewrite: splice(pattern, g.start, g.start + 1, "(?:"),
        changesGroups: true,
      })
    }
    // A group around a single item: (?:a) → a, (?:\d)+ → \d+
    if (n.type === "group" && n.kind === "noncapture" && (isSingleChar(n.body) || n.body.type === "quote")) {
      add({
        id: "needless-group",
        severity: "info",
        title: source(pattern, n) + " groups a single item",
        detail: "The group adds nothing; a quantifier after it would apply to the item alone anyway.",
        start: n.start,
        end: n.end,
        rewrite: splice(pattern, n.start, n.end, source(pattern, n.body)),
      })
    }
  })

  // ---- Unicode ----
  if (flavor.family === "perl") {
    Parser.walk(ast, function(n) {
      if (n.type !== "class" || n.negated) return
      var ranges = n.items.filter(function(i) { return i.type === "range" }).map(function(r) { return pattern.substring(r.start, r.end) })
      if (ranges.indexOf("a-z") >= 0 && ranges.indexOf("A-Z") >= 0 && (f.unicodeProperties)) {
        add({
          id: "ascii-letters",
          severity: "info",
          title: source(pattern, n) + " leaves out é, ß, Ж and every other letter outside English",
          detail: "If the text can hold names or words from other languages, \\p{L} matches any letter" + (flavor.id === "node" || flavor.id === "ecmascript" ? " (with the u flag)" : "") + ".",
          start: n.start,
          end: n.end,
        })
        return false
      }
    })
  }

  // ---- engines that cannot backtrack catastrophically ----
  if (!backtracking && flavor.family === "perl") {
    add({
      id: "linear-engine",
      severity: "info",
      title: flavor.name + " runs in linear time",
      detail: flavor.name + " compiles patterns to automata, so no pattern can backtrack catastrophically here. The price is no backreferences or lookaround.",
      start: 0,
      end: 0,
    })
  }

  var order = { danger: 0, warning: 1, tip: 2, info: 3 }
  findings.sort(function(a, b) { return order[a.severity] - order[b.severity] || a.start - b.start })
  return findings
}

// What can follow node n in the pattern, as first characters, approximately:
// the sequence item after it, or anything when it ends the pattern.
function followSet(ast, n, ctx) {
  var result = null
  Parser.walk(ast, function(c) {
    if (result || c.type !== "sequence") return
    var i = c.items.indexOf(n)
    if (i < 0) return
    var out = []
    for (var j = i + 1; j < c.items.length; j++) {
      out = union(out, firstSet(c.items[j], ctx) || SAMPLE)
      if (Parser.width(c.items[j]).min > 0) { result = out; return false }
    }
    result = out
  })
  return result || []
}

// Making the inner or outer repetition possessive, or the body atomic,
// removes the ambiguity. Collapsing (a+)+ into a+ is the simplest fix.
function possessiveFix(pattern, outer, inner, f) {
  var body = unwrap(outer.body)
  if (body === inner && inner.body.type !== "group" && outer.body.type === "group" && outer.body.kind !== "capture" && outer.body.kind !== "named") {
    return { rewrite: splice(pattern, outer.start, outer.end, source(pattern, inner)), note: source(pattern, outer) + " matches the same as " + source(pattern, inner) + "." }
  }
  if (f.possessive) {
    return { rewrite: splice(pattern, inner.end, inner.end, "+"), note: "Making " + source(pattern, inner) + " possessive (" + source(pattern, inner) + "+) stops it giving characters back." }
  }
  if (f.atomic) {
    return { rewrite: splice(splice(pattern, inner.end, inner.end, ")"), inner.start, inner.start, "(?>"), note: "An atomic group around " + source(pattern, inner) + " stops it giving characters back." }
  }
  return { rewrite: "", note: "This engine has neither possessive quantifiers nor atomic groups; rewrite the pattern so each character can only be matched one way." }
}

// The literal text a node matches, or null when it is not plain text.
function literalText(n) {
  if (n.type === "literal") return String.fromCharCode(n.value)
  if (n.type === "quote") return n.items.map(function(i) { return String.fromCharCode(i.value) }).join("")
  if (n.type === "sequence") {
    var out = ""
    for (var i = 0; i < n.items.length; i++) {
      var t = literalText(n.items[i])
      if (t === null) return null
      out += t
    }
    return out
  }
  return null
}

// How much of a's source spells its first `chars` literal characters.
function literalSourceLength(pattern, a, chars) {
  if (a.type !== "sequence") return chars
  var end = a.start
  for (var i = 0; i < chars && i < a.items.length; i++) end = a.items[i].end
  return end - a.start
}

function escapeLiteral(text) {
  var out = ""
  for (var i = 0; i < text.length; i++) out += escapeChar(text.charAt(i), false)
  return out
}

// Witness texts of growing size for a finding.
function witness(finding, n) {
  if (!finding.witness) return ""
  return new Array(n + 1).join(finding.witness.unit) + finding.witness.tail
}

if (typeof module !== "undefined") module.exports = { analyze: analyze, witness: witness, contains: contains, firstSet: firstSet }
