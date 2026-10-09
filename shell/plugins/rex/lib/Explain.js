.pragma library
.import "Parser.js" as Parser
.import "Flavors.js" as Flavors

// Explains a parsed pattern in plain language, node by node, for the
// selected flavor. explain() returns a flat list of rows for a tree view:
// { depth, title, detail, start, end, kind, group } where [start, end) is the
// span of the pattern the row explains and kind picks its color.
//
// tokens() returns the spans the pattern editor tints, with the same kinds.

var INF = Parser.INFINITE

var CONTROL_NAMES = {
  0: "NUL", 7: "bell", 8: "backspace", 9: "tab", 10: "line feed (newline)", 11: "vertical tab",
  12: "form feed", 13: "carriage return", 27: "escape", 32: "space", 127: "delete", 160: "no-break space",
}

function hex(cp) {
  var h = cp.toString(16).toUpperCase()
  while (h.length < 4) h = "0" + h
  return "U+" + h
}

function charText(cp) {
  if (cp < 0) return "a named character"
  if (CONTROL_NAMES[cp]) return CONTROL_NAMES[cp] + " (" + hex(cp) + ")"
  if (cp < 32) return "control character " + hex(cp)
  var c = String.fromCharCode.apply(null, cp > 0xffff ? [0xd800 + ((cp - 0x10000) >> 10), 0xdc00 + ((cp - 0x10000) & 0x3ff)] : [cp])
  return "\"" + c + "\"" + (cp > 126 ? " (" + hex(cp) + ")" : "")
}

// ---- flavor-dependent meanings ----------------------------------------------

function unicodeClasses(flavor, flags) {
  var id = flavor.id
  var has = function(f) { return flags.indexOf(f) >= 0 }
  if (id === "python" || id === "python-regex") return !has("a")
  if (id === "perl") return !has("a")
  if (id === "pcre2") return has("u")
  if (id === "java") return has("U")
  if (id === "dotnet") return !has("e")
  if (id === "ruby") return false
  if (id === "node" || id === "ecmascript") return false
  if (id === "rust") return true
  return false
}

var CHARTYPE = {
  digit: ["A digit", "0–9", "any Unicode decimal digit, such as ٣ or ३"],
  word: ["A word character", "letter, digit or underscore: [A-Za-z0-9_]", "any Unicode letter, mark, digit or connector punctuation"],
  space: ["Whitespace", "space, tab, line breaks, vertical tab or form feed", "any Unicode whitespace, including no-break and ideographic spaces"],
  hspace: ["Horizontal whitespace", "space, tab and other horizontal spaces", ""],
  vspace: ["Vertical whitespace", "line feed, vertical tab, form feed, carriage return, next line, line and paragraph separators", ""],
  hex: ["A hexadecimal digit", "0–9, a–f or A–F", ""],
  newline: ["A line break", "\\r\\n, \\n, \\r, vertical tab, form feed and Unicode line breaks, as a unit", ""],
  notnewline: ["Any character except a line break", "like . without the s flag, whatever the flags say", ""],
  grapheme: ["One user-perceived character", "an extended grapheme cluster, such as e plus a combining accent, or an emoji with its modifiers", ""],
  alpha: ["A letter", "", ""], lower: ["A lowercase letter", "", ""], upper: ["An uppercase letter", "", ""],
  alnum: ["A letter or digit", "", ""], control: ["A control character", "", ""], punct: ["A punctuation character", "", ""],
  printable: ["A printable character", "", ""], octal: ["An octal digit", "0–7", ""],
  head: ["A head of word character", "a letter or underscore", ""], ident: ["An identifier character", "per 'isident'", ""],
  keyword: ["A keyword character", "per 'iskeyword'", ""], filename: ["A file name character", "per 'isfname'", ""],
}

var POSIX = {
  alnum: "a letter or digit", alpha: "a letter", ascii: "an ASCII character", blank: "a space or tab",
  cntrl: "a control character", digit: "a digit", graph: "a visible character (not space)",
  lower: "a lowercase letter", print: "a printable character (visible or space)",
  punct: "a punctuation character", space: "a whitespace character", upper: "an uppercase letter",
  word: "a word character", xdigit: "a hexadecimal digit",
}

var PROPERTIES = {
  L: "Letter", Lu: "Uppercase letter", Ll: "Lowercase letter", Lt: "Titlecase letter", Lm: "Modifier letter", Lo: "Other letter",
  M: "Mark", Mn: "Nonspacing mark", Mc: "Spacing mark", Me: "Enclosing mark",
  N: "Number", Nd: "Decimal digit", Nl: "Letter number", No: "Other number",
  P: "Punctuation", Pc: "Connector punctuation", Pd: "Dash", Ps: "Open punctuation", Pe: "Close punctuation",
  Pi: "Initial quote", Pf: "Final quote", Po: "Other punctuation",
  S: "Symbol", Sm: "Math symbol", Sc: "Currency symbol", Sk: "Modifier symbol", So: "Other symbol",
  Z: "Separator", Zs: "Space separator", Zl: "Line separator", Zp: "Paragraph separator",
  C: "Other", Cc: "Control", Cf: "Format", Co: "Private use", Cn: "Unassigned", Cs: "Surrogate",
  Letter: "Letter", Number: "Number", Punctuation: "Punctuation", Symbol: "Symbol",
  Emoji: "Emoji", Emoji_Presentation: "Emoji presentation", Extended_Pictographic: "Extended pictographic (emoji and friends)",
  Alphabetic: "Alphabetic", White_Space: "White space", Any: "Any code point", ASCII: "ASCII",
  Latin: "Latin script", Greek: "Greek script", Cyrillic: "Cyrillic script", Han: "Han (Chinese characters)",
  Arabic: "Arabic script", Hebrew: "Hebrew script", Hiragana: "Hiragana", Katakana: "Katakana", Hangul: "Hangul", Devanagari: "Devanagari script", Thai: "Thai script",
}

function propertyName(name) {
  var bare = String(name).replace(/^(Is|In|sc=|Script=|gc=|General_Category=|scx=|Script_Extensions=)/, "")
  return PROPERTIES[bare] || bare
}

var ANCHORS = {
  lineStart: function(f, flags) {
    if (f.family === "lua" || f.family === "bre" || f.family === "ere") return ["Start of the line", "the start of the text, or of a line when matching line by line"]
    if (f.id === "ruby" || f.id === "vim") return ["Start of a line", "Ruby and Vim treat ^ as a line anchor always"]
    return flags.indexOf("m") >= 0
      ? ["Start of a line", "the start of the text or just after a line break (multiline)"]
      : ["Start of the text", "with the m flag, the start of every line"]
  },
  lineEnd: function(f, flags) {
    if (f.id === "ruby" || f.id === "vim") return ["End of a line", "Ruby and Vim treat $ as a line anchor always"]
    if (flags.indexOf("m") >= 0) return ["End of a line", "the end of the text or just before a line break (multiline)"]
    var trailing = /^(pcre2|perl|python|python-regex|java|dotnet|grep|grep-e)$/.test(f.id) && flags.indexOf("D") < 0
    return ["End of the text", trailing ? "or just before a newline that ends the text" : "with the m flag, the end of every line"]
  },
  start: function() { return ["Start of the text", "never the start of a line, whatever the flags"] },
  end: function() { return ["End of the text", "the very end, even when the text ends in a newline"] },
  endOrNewline: function() { return ["End of the text", "or just before a newline that ends the text"] },
  searchStart: function() { return ["Where the search began", "\\G: the end of the previous match, or the starting position"] },
  wordBoundary: function(f) { return ["A word boundary", "between a word character and a non-word character, or the text's edge"] },
  notWordBoundary: function() { return ["Not a word boundary", "between two word characters or two non-word characters"] },
  wordStart: function() { return ["Start of a word", ""] },
  wordEnd: function() { return ["End of a word", ""] },
  resetStart: function() { return ["Reset the match start", "\\K: whatever matched before this is kept out of the match"] },
  matchStart: function() { return ["The match starts here", "\\zs: what matched before this is not part of the match"] },
  matchEnd: function() { return ["The match ends here", "\\ze: what matches after this is not part of the match"] },
  position: function() { return ["A position", "a Vim position item such as a line or column"] },
}

var GROUPS = {
  capture: ["Capturing group", "remembers what it matched as group "],
  named: ["Named capturing group", "remembers what it matched as "],
  noncapture: ["Group", "groups without capturing"],
  atomic: ["Atomic group", "once it has matched, the engine never backtracks into it to try other ways"],
  lookahead: ["Positive lookahead", "asserts that what follows matches, without consuming it"],
  negativeLookahead: ["Negative lookahead", "asserts that what follows does not match"],
  lookbehind: ["Positive lookbehind", "asserts that what precedes matches"],
  negativeLookbehind: ["Negative lookbehind", "asserts that what precedes does not match"],
  branchReset: ["Branch reset group", "each alternative numbers its groups from the same starting number"],
  flags: ["Group with flags", "changes the flags inside it only"],
  absent: ["Absent operator", "matches any text that does not contain what is inside"],
  balancing: ["Balancing group", "pops the last capture of one group, keeping what lies between as another"],
  position: ["Position capture", "captures the position here, as a number"],
}

var VERBS = {
  ACCEPT: "End the match successfully right here",
  FAIL: "Fail at this point and backtrack", F: "Fail at this point and backtrack",
  COMMIT: "If the rest fails, fail the whole match instead of trying later starts",
  PRUNE: "If the rest fails, move on to the next starting position",
  SKIP: "If the rest fails, resume searching after this position",
  THEN: "If the rest fails, try the next alternative of the enclosing group",
  MARK: "Name this position for (*SKIP:name)",
  UTF: "Treat the pattern and text as UTF", UCP: "Use Unicode properties for \\d, \\w, \\s",
  CR: "Only CR is a newline", LF: "Only LF is a newline", CRLF: "Only CRLF is a newline",
  ANYCRLF: "CR, LF, or CRLF is a newline", ANY: "Any Unicode line break is a newline",
  NO_AUTO_POSSESS: "Turn off automatic possessification", NO_START_OPT: "Turn off start-of-match optimizations",
}

var FLAG_NAMES = {
  i: "ignore case", m: "multiline", s: "dot matches newline", x: "extended (free spacing)", n: "no automatic capture",
  U: "ungreedy", J: "duplicate names", u: "Unicode", a: "ASCII classes", d: "Unix lines", L: "locale", R: "CRLF", V: "version",
}

function quantifierText(n) {
  var min = n.min, max = n.max
  var count
  if (min === 0 && max === INF) count = "zero or more times"
  else if (min === 1 && max === INF) count = "one or more times"
  else if (min === 0 && max === 1) count = "optionally (zero or one time)"
  else if (max === INF) count = min + " or more times"
  else if (min === max) count = "exactly " + min + (min === 1 ? " time" : " times")
  else count = "between " + min + " and " + max + " times"
  var how = {
    greedy: "as many as possible, giving back as needed (greedy)",
    lazy: "as few as possible, expanding as needed (lazy)",
    possessive: "as many as possible, never giving back (possessive)",
  }[n.mode]
  return [count.charAt(0).toUpperCase() + count.substr(1), how]
}

// ---- one node ----------------------------------------------------------------

function describe(n, f, flags) {
  switch (n.type) {
  case "literal":
    return { title: (n.escaped ? "Escaped " : "") + charText(n.value), detail: n.name ? "\\N{" + n.name + "}" : "matches itself" + (flags.indexOf("i") >= 0 && /[A-Za-z]/.test(String.fromCharCode(Math.max(0, n.value))) ? ", in either case" : ""), kind: n.escaped ? "escape" : "literal" }
  case "dot":
    var all = n.newline || flags.indexOf("s") >= 0 || (f.id === "ruby" && flags.indexOf("m") >= 0)
    return { title: all ? "Any character" : "Any character except a line break", detail: all ? "including line breaks" : "add the s flag to include line breaks", kind: "class" }
  case "chartype":
    var c = CHARTYPE[n.kind] || [n.kind, "", ""]
    var uni = unicodeClasses(f, flags)
    var detail = uni && c[2] ? c[2] : c[1]
    if ((n.kind === "digit" || n.kind === "word" || n.kind === "space") && c[2]) detail += uni ? " (Unicode-aware here)" : " (ASCII only here)"
    return { title: (n.negated ? "Not " + c[0].charAt(0).toLowerCase() + c[0].substr(1) : c[0]), detail: detail, kind: "class" }
  case "property":
    return { title: (n.negated ? "Not a" : "A") + " character with the Unicode property " + n.name, detail: propertyName(n.name), kind: "class" }
  case "posixclass":
    return { title: "[:" + n.name + ":] — " + (n.negated ? "not " : "") + (POSIX[n.name] || n.name), detail: "a POSIX character class", kind: "class" }
  case "equivalence":
    return { title: "[=" + n.value + "=]", detail: "any character equivalent to " + n.value + " in the locale, such as accented forms", kind: "class" }
  case "collating":
    return { title: "[." + n.value + ".]", detail: "the collating element " + n.value, kind: "class" }
  case "class":
    return { title: n.negated ? "One character not in the set" : (n.items.length === 0 ? "A set that matches nothing" : "One character from the set"), detail: n.negated ? "anything except what is listed below" + (f.family === "perl" ? ", including line breaks" : "") : "", kind: "class" }
  case "range":
    return { title: "A character from " + charText(n.from.value) + " to " + charText(n.to.value), detail: "a range of code points", kind: "class" }
  case "setop":
    return { title: { "&&": "Intersection", "--": "Difference", "~~": "Symmetric difference", net: "Subtraction" }[n.op] + " of two sets", detail: { "&&": "characters in both", "--": "characters in the first but not the second", "~~": "characters in exactly one", net: "characters in the first but not the second" }[n.op], kind: "class" }
  case "anchor":
    var a = ANCHORS[n.kind] ? ANCHORS[n.kind](f, flags) : [n.kind, ""]
    return { title: a[0], detail: a[1] || "matches a position, not a character", kind: "anchor" }
  case "group":
    var g = GROUPS[n.kind] || ["Group", ""]
    var gd = g[1]
    if (n.kind === "capture") gd += n.index
    if (n.kind === "named") gd += "'" + n.name + "' (group " + n.index + ")"
    if (n.kind === "flags" && n.flags) gd = flagText(n.flags) + " inside this group"
    if (n.kind === "balancing") gd = (n.name ? "captures into '" + n.name + "' and " : "") + "pops the last capture of '" + n.pop + "'"
    if (n.postfix) gd += " (Vim writes it after the item)"
    return { title: g[0] + (n.index ? " " + n.index : ""), detail: gd, kind: n.index ? "group" : (/ook/.test(n.kind) ? "assertion" : "meta"), group: n.index || 0 }
  case "quantifier":
    var q = quantifierText(n)
    return { title: q[0], detail: q[1], kind: "quantifier" }
  case "alternation":
    return { title: "Either of " + n.alternatives.length + " alternatives", detail: "tried left to right" + (f.family === "ere" || f.family === "bre" || f.id === "go" && flags.indexOf("L") >= 0 ? "; POSIX picks the longest match overall" : "; the first that lets the rest match wins"), kind: "meta" }
  case "sequence":
    return { title: "In sequence", detail: "", kind: "meta" }
  case "backref":
    var ref = typeof n.ref === "string" ? "'" + n.ref + "'" : (n.relative ? "the group " + (-n.ref) + " back" : "group " + n.ref)
    return { title: "Backreference to " + ref, detail: "matches the same text " + ref + " last matched", kind: "group", group: typeof n.ref === "number" && !n.relative ? n.ref : 0 }
  case "recursion":
    var target = n.ref === 0 ? "the whole pattern" : (typeof n.ref === "string" ? "group '" + n.ref + "'" : (n.relative ? "the group " + Math.abs(n.ref) + (n.ref < 0 ? " back" : " ahead") : "group " + n.ref))
    return { title: "Recurse into " + target, detail: "matches " + target + "'s pattern again here (not the text it matched)", kind: "meta" }
  case "conditional":
    var cond = n.condition
    var ct = cond.kind === "group" ? "if group " + (typeof cond.ref === "string" ? "'" + cond.ref + "'" : cond.ref) + " has matched"
      : cond.kind === "assert" ? "if the assertion holds"
      : cond.kind === "define" ? "never matched: a place to define subroutines"
      : "if inside recursion"
    return { title: "Conditional", detail: ct + ", match the first branch" + (n.no ? ", otherwise the second" : ""), kind: "meta" }
  case "verb":
    return { title: "(*" + n.name + (n.arg ? ":" + n.arg : "") + ")", detail: VERBS[n.name] || "a backtracking control verb", kind: "meta" }
  case "callout":
    return { title: "Callout", detail: "calls out to the host program while matching", kind: "meta" }
  case "comment":
    return { title: "Comment", detail: n.text, kind: "comment" }
  case "flags":
    if (n.vim) return { title: "\\" + n.vim, detail: { c: "ignore case for the whole pattern", C: "match case for the whole pattern", v: "very magic: most punctuation is special", m: "magic (the default)", M: "nomagic: only ^ and $ are special", V: "very nomagic: only \\ is special" }[n.vim] || "", kind: "meta" }
    return { title: "Flags", detail: flagText(n) + " from here on", kind: "meta" }
  case "quote":
    var text = ""
    for (var i = 0; i < n.items.length; i++) text += String.fromCharCode(n.items[i].value)
    return { title: "The literal text \"" + text + "\"", detail: "\\Q...\\E: nothing inside is special", kind: "literal" }
  case "balanced":
    return { title: "A balanced pair " + n.open + "…" + n.close, detail: "%b: from " + n.open + " to the " + n.close + " that balances it, counting nested pairs", kind: "meta" }
  case "frontier":
    return { title: "A frontier", detail: "%f: where the previous character is not in the set and the next one is", kind: "anchor" }
  case "empty":
    return { title: "Nothing", detail: "matches the empty string", kind: "meta" }
  }
  return { title: n.type, detail: "", kind: "meta" }
}

function flagText(info) {
  var parts = []
  function names(letters) {
    var out = []
    for (var i = 0; i < letters.length; i++) out.push(FLAG_NAMES[letters.charAt(i)] || letters.charAt(i))
    return out.join(", ")
  }
  if (info.caret) parts.push("reset to defaults")
  if (info.on) parts.push("turns on " + names(info.on))
  if (info.off) parts.push("turns off " + names(info.off))
  return parts.join("; ") || "no change"
}

// ---- the tree ---------------------------------------------------------------

// Flags after an inline (?i-s) or (?^i): a new list, the old one untouched.
function withFlags(active, info) {
  var out = info.caret ? [] : active.slice()
  for (var i = 0; i < (info.on || "").length; i++) if (out.indexOf(info.on.charAt(i)) < 0) out.push(info.on.charAt(i))
  for (var j = 0; j < (info.off || "").length; j++) {
    var at = out.indexOf(info.off.charAt(j))
    if (at >= 0) out.splice(at, 1)
  }
  return out
}

function explain(parsed, flags) {
  var f = Flavors.byId(parsed.flavor)
  var rows = []

  // active is the flags in force where n sits. A standalone (?i) changes
  // them for the rest of its group; (?i:...) only inside.
  function visit(n, depth, active) {
    if (!n) return
    // Sequences and the empty pattern add nothing a reader needs.
    if (n.type === "sequence") {
      var current = active
      for (var i = 0; i < n.items.length; i++) {
        var item = n.items[i]
        if (item.type === "flags") current = withFlags(current, item.vim ? { on: item.on, off: item.off } : item)
        visit(item, depth, current)
      }
      return
    }
    if (n.type === "empty" && depth > 0) return
    var d = describe(n, f, active)
    rows.push({ depth: depth, title: d.title, detail: d.detail, start: n.start, end: n.end, kind: d.kind, group: d.group || 0, type: n.type })
    if (n.type === "conditional") {
      if (n.condition.assertion) visit(n.condition.assertion, depth + 1, active)
      visit(n.yes, depth + 1, active)
      if (n.no) visit(n.no, depth + 1, active)
      return
    }
    if (n.type === "alternation") {
      for (var a = 0; a < n.alternatives.length; a++) {
        var alt = n.alternatives[a]
        rows.push({ depth: depth + 1, title: "Alternative " + (a + 1), detail: "", start: alt.start, end: alt.end, kind: "meta", group: 0, type: "alternative" })
        visit(alt, depth + 2, active)
      }
      return
    }
    if (n.type === "range" || n.type === "quote") return
    var inner = n.type === "group" && n.kind === "flags" && n.flags ? withFlags(active, n.flags) : active
    var kids = Parser.children(n)
    for (var j = 0; j < kids.length; j++) visit(kids[j], depth + 1, inner)
  }

  visit(parsed.ast, 0, (flags || []).slice())
  return rows
}

// Spans of the pattern to tint: { start, end, kind, group }. Containers
// contribute only their syntax (a group's parentheses, a class's brackets,
// a quantifier's operator), so nested spans never overlap.
function tokens(parsed) {
  var out = []
  Parser.walk(parsed.ast, function(n) {
    switch (n.type) {
    case "group":
      if (n.postfix) {
        out.push({ start: n.opStart, end: n.end, kind: "assertion", group: 0 })
        return
      }
      var kind = n.index ? "group" : (/ook/.test(n.kind) ? "assertion" : "meta")
      var bodyStart = n.body ? n.body.start : n.start + 1
      var bodyEnd = n.body ? n.body.end : n.end - 1
      if (bodyStart > n.start) out.push({ start: n.start, end: bodyStart, kind: kind, group: n.index || 0 })
      if (n.end > bodyEnd) out.push({ start: bodyEnd, end: n.end, kind: kind, group: n.index || 0 })
      return
    case "quantifier":
      out.push({ start: n.opStart, end: n.end, kind: "quantifier", group: 0 })
      return
    case "class":
      out.push({ start: n.start, end: n.end, kind: "class", group: 0 })
      return false
    case "alternation":
      // The | bars sit between the alternatives.
      for (var i = 1; i < n.alternatives.length; i++) {
        var bar = n.alternatives[i].start - 1
        out.push({ start: bar, end: bar + 1, kind: "meta", group: 0 })
      }
      return
    case "literal":
      if (n.escaped) out.push({ start: n.start, end: n.end, kind: "escape", group: 0 })
      return
    case "chartype": case "property": case "dot":
      out.push({ start: n.start, end: n.end, kind: "class", group: 0 })
      return
    case "anchor": case "frontier":
      out.push({ start: n.start, end: n.end, kind: "anchor", group: 0 })
      return
    case "backref":
      out.push({ start: n.start, end: n.end, kind: "group", group: typeof n.ref === "number" && !n.relative ? n.ref : 0 })
      return
    case "recursion": case "verb": case "callout": case "flags": case "balanced":
      out.push({ start: n.start, end: n.end, kind: "meta", group: 0 })
      return
    case "comment":
      out.push({ start: n.start, end: n.end, kind: "comment", group: 0 })
      return
    case "quote":
      out.push({ start: n.start, end: n.end, kind: "literal", group: 0 })
      return false
    case "conditional":
      out.push({ start: n.start, end: n.condition.end, kind: "meta", group: 0 })
      out.push({ start: n.end - 1, end: n.end, kind: "meta", group: 0 })
      return
    }
  })
  out.sort(function(a, b) { return a.start - b.start })
  return out
}

if (typeof module !== "undefined") module.exports = { explain: explain, tokens: tokens, describe: describe, charText: charText }
