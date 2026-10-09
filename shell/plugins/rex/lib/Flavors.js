.pragma library

// Every regex flavor Rex knows: how its syntax is shaped, what it supports,
// which flags it takes, and which worker runs it. The parser, explainer,
// analyzer, code generator, and reference all read this table, so a fact
// about a flavor lives here once.
//
// family      which grammar the parser uses: "perl" (the Perl-derived syntax
//             nearly everything speaks), "ere" / "bre" (POSIX), "vim", "lua"
// engine      "backtracking" or "automaton" (linear time, no backtracking)
// worker      the worker process that runs it (bin/omarchy-rex-worker
//             <worker>); "" for Qt's own engine in a WorkerScript
// requires    commands that must be present for the flavor to be offered
// units       what the engine counts offsets in: "utf16", "cp", or "byte"
// replace     replacement-string syntax, see Replace in Codegen.js
// features    what the grammar accepts; see PERL below for every key
// flags       the compile options Rex exposes, each with the letter used in
//             an inline group where the flavor has one

// ---- features ---------------------------------------------------------------

// The Perl-family baseline: what PCRE2 accepts. Other flavors override.
var PERL = {
  alternation: true,
  lookahead: true,
  // "none", "fixed" (every alternative the same width), "alternatives"
  // (each top-level alternative fixed, widths may differ), "bounded" (a
  // finite maximum), or "any"
  lookbehind: "bounded",
  atomic: true,
  possessive: true,
  lazy: true,
  backrefs: true,
  // How named groups may be written: "angle" (?<n>), "quote" (?'n'),
  // "python" (?P<n>)
  namedGroups: ["angle", "quote", "python"],
  // How a named backreference may be written: "k-angle" \k<n>, "k-quote"
  // \k'n', "k-brace" \k{n}, "g-brace" \g{n}, "python" (?P=n)
  namedBackrefs: ["k-angle", "k-quote", "k-brace", "g-brace", "python"],
  // \g1, \g{1}, \g{-1}
  gBackrefs: true,
  relativeBackrefs: true,
  // (?R) (?1) (?-1) (?+1) (?&n) (?P>n)
  recursion: true,
  // \g<n> \g'n' as subroutine calls (Ruby, PCRE2)
  gSubroutines: true,
  conditionals: true,
  branchReset: true,
  // (?i) to the end of the group, (?i:...) scoped, (?-i) off, (?^) reset
  inlineFlags: "imnsxJU",
  scopedFlags: true,
  negatedFlags: true,
  caretFlags: true,
  comments: true,
  // \Q...\E
  quoting: true,
  // \K
  resetStart: true,
  // Anchors beyond ^ and $
  anchors: "AzZGbB",
  // [:alpha:] inside a class
  posixClasses: true,
  // [a-z&&[^aeiou]] (Java, Ruby, Rust)
  classIntersection: false,
  // "--" (Rust, Python regex V1, JS v), "net" [a-z-[aeiou]], or ""
  classSubtraction: "",
  // [a[bc]] (Java, Ruby, Rust)
  nestedClasses: false,
  // \p{L} and \pL
  unicodeProperties: true,
  shortProperties: true,
  // Escape letters with a meaning; anything else is decided by
  // unknownEscape. Values: a class ("digit", "word", "space", "hspace",
  // "vspace", "hex", "newline" for \R, "notnewline" for \N, "grapheme" for
  // \X), "char:<code>" for a single character, or a token kind handled by
  // the parser ("hexEscape", "unicodeEscape", "control", "octalBrace",
  // "property", "namedChar", "backref", "gref", "kref", "quote", "reset",
  // "anchor").
  escapes: {
    d: "digit", w: "word", s: "space", h: "hspace", v: "vspace",
    R: "newline", N: "notnewline", X: "grapheme",
    n: "char:10", r: "char:13", t: "char:9", f: "char:12", e: "char:27", a: "char:7",
    x: "hexEscape", c: "control", o: "octalBrace", p: "property",
    g: "gref", k: "kref", Q: "quote", K: "reset",
  },
  // "error" when an unknown letter escape is a syntax error, "literal" when
  // it stands for the letter itself
  unknownEscape: "error",
  // \0, \012: octal escapes
  octal: true,
  // {,n} meaning {0,n}
  openMinRepeat: true,
  // "error" when a { that does not start a quantifier is rejected,
  // "literal" when it matches a brace
  strayBrace: "literal",
  // Largest count a {n,m} may use (0: unbounded)
  maxRepeat: 65535,
  // (*VERB) backtracking control and (?C) callouts
  verbs: true,
  callouts: true,
  // (?~absent) (Onigmo)
  absent: false,
  // .NET balancing groups (?<open-close>...)
  balancing: false,
  // An empty class [] that matches nothing (JavaScript); otherwise ] first
  // in a class is a literal
  emptyClass: false,
  // Whether quantifying an assertion (lookaround, \b) is allowed
  quantifiedAssertions: true,
  // Duplicate group names accepted
  duplicateNames: false,
}

function features(overrides) {
  var out = {}
  for (var key in PERL) out[key] = PERL[key]
  for (var name in overrides) out[name] = overrides[name]
  if (overrides.escapes) {
    var escapes = {}
    for (var letter in PERL.escapes) escapes[letter] = PERL.escapes[letter]
    for (var override in overrides.escapes) {
      if (overrides.escapes[override] === null) delete escapes[override]
      else escapes[override] = overrides.escapes[override]
    }
    out.escapes = escapes
  }
  return out
}

// Escapes shared by the engines whose \v is a vertical tab rather than a
// class, and that know nothing of \h, \R, \N, or \X.
var PLAIN_ESCAPES = { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, Q: null, g: null }

// ---- flags ------------------------------------------------------------------

function flag(id, label, description, inline) {
  return { id: id, label: label, description: description, inline: inline === undefined ? id : inline }
}

var CASE = "Letters match regardless of case"
var MULTI = "^ and $ also match at the start and end of every line"
var DOTALL = ". also matches a newline"
var EXTENDED = "Whitespace and # comments in the pattern are ignored"
var UNGREEDY = "Quantifiers are lazy by default and greedy with a trailing ?"

// ---- the table --------------------------------------------------------------

var FLAVORS = [
  {
    id: "ecmascript",
    name: "JavaScript (Qt)",
    short: "JS (Qt)",
    language: "JavaScript",
    description: "Qt's JavaScript engine (QV4 with WebKit's YARR), always available. An older ECMAScript dialect: no lookbehind, no s flag, no \\p{...}.",
    family: "perl",
    engine: "backtracking",
    worker: "",
    requires: [],
    units: "utf16",
    replace: "js",
    features: features({
      lookbehind: "none", atomic: false, possessive: false,
      namedGroups: ["angle"], namedBackrefs: ["k-angle"], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "", scopedFlags: false, negatedFlags: false, caretFlags: false, comments: false,
      anchors: "bB", posixClasses: false, unicodeProperties: false, shortProperties: false,
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, Q: null, g: null, a: null, p: null, u: "unicodeEscape" },
      unknownEscape: "literal", openMinRepeat: false, verbs: false, callouts: false, emptyClass: true,
      maxRepeat: 0,
    }),
    flags: [
      flag("i", "Ignore case", CASE, ""),
      flag("m", "Multiline", MULTI, ""),
      flag("u", "Unicode", "Treat the pattern and text as code points, enabling \\u{...}", ""),
      flag("y", "Sticky", "Match only at the position the previous match ended", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "node",
    name: "JavaScript (V8)",
    short: "JS",
    language: "JavaScript",
    description: "V8 through Node.js: the JavaScript of Chrome, Edge, Node, Deno, and Electron.",
    family: "perl",
    engine: "backtracking",
    worker: "node",
    requires: ["node"],
    units: "utf16",
    replace: "js",
    features: features({
      lookbehind: "any", atomic: false, possessive: false,
      namedGroups: ["angle"], namedBackrefs: ["k-angle"], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "ims", scopedFlags: true, negatedFlags: true, caretFlags: false, comments: false,
      anchors: "bB", posixClasses: false, shortProperties: false, classSubtraction: "--", classIntersection: true, nestedClasses: true,
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, Q: null, g: null, a: null, u: "unicodeEscape" },
      unknownEscape: "literal", openMinRepeat: false, verbs: false, callouts: false, emptyClass: true,
      duplicateNames: true, maxRepeat: 0,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("u", "Unicode", "Code point semantics, \\p{...} and \\u{...}", ""),
      flag("v", "Unicode sets", "Unicode mode with set operations and string properties in classes", ""),
      flag("y", "Sticky", "Match only at the position the previous match ended", ""),
      flag("d", "Indices", "Report the start and end of every group", ""),
    ],
    defaultFlags: ["u"],
  },
  {
    id: "pcre2",
    name: "PCRE2",
    short: "PCRE2",
    language: "PHP, C, R, Nginx, Apache",
    description: "Perl Compatible Regular Expressions 2 through libpcre2, the engine behind PHP's preg_* functions, grep -P, and much else. Runs JIT-compiled.",
    family: "perl",
    engine: "backtracking",
    worker: "python",
    requires: [],
    units: "byte",
    replace: "pcre2",
    features: features({}),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Extended", EXTENDED),
      flag("n", "No auto-capture", "Plain (...) groups do not capture; only named groups do"),
      flag("U", "Ungreedy", UNGREEDY),
      flag("J", "Duplicate names", "Allow several groups with the same name"),
      flag("A", "Anchored", "The match must start where the search starts", ""),
      flag("D", "Dollar end only", "$ matches only at the very end, not before a final newline", ""),
      flag("u", "Unicode", "Unicode properties for \\d, \\w, \\s and POSIX classes (UCP)", ""),
    ],
    defaultFlags: ["u"],
  },
  {
    id: "perl",
    name: "Perl",
    short: "Perl",
    language: "Perl",
    description: "Perl's own regex engine, the original of the Perl family.",
    family: "perl",
    engine: "backtracking",
    worker: "perl",
    requires: ["perl"],
    units: "cp",
    replace: "perl",
    features: features({
      inlineFlags: "imnsxpadlu", verbs: true, callouts: false,
      escapes: { N: "namedChar" },
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Single line", DOTALL),
      flag("x", "Extended", EXTENDED),
      flag("n", "No capture", "Plain (...) groups do not capture"),
      flag("a", "ASCII", "\\d, \\w, \\s and POSIX classes match ASCII only"),
    ],
    defaultFlags: [],
  },
  {
    id: "python",
    name: "Python re",
    short: "Python",
    language: "Python",
    description: "Python's standard re module.",
    family: "perl",
    engine: "backtracking",
    worker: "python",
    requires: ["python3"],
    units: "cp",
    replace: "python",
    features: features({
      lookbehind: "fixed", namedGroups: ["python"], namedBackrefs: ["python"],
      gBackrefs: false, relativeBackrefs: false, recursion: false, gSubroutines: false, branchReset: false,
      inlineFlags: "aiLmsux", caretFlags: false, quoting: false, resetStart: false,
      anchors: "AZbB", posixClasses: false, unicodeProperties: false, shortProperties: false,
      escapes: { h: null, v: "char:11", R: null, N: "namedChar", X: null, o: null, e: null, K: null, Q: null, g: null, c: null, p: null, k: null, u: "unicodeEscape", U: "unicodeEscape" },
      verbs: false, callouts: false, maxRepeat: 4294967295,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Verbose", EXTENDED),
      flag("a", "ASCII", "\\d, \\w, \\s and \\b match ASCII only"),
    ],
    defaultFlags: [],
  },
  {
    id: "python-regex",
    name: "Python regex",
    short: "regex",
    language: "Python",
    description: "The third-party regex module (pip install regex, python-regex): re plus recursion, possessive quantifiers, variable lookbehind, fuzzy matching, and Unicode properties.",
    family: "perl",
    engine: "backtracking",
    worker: "python",
    requires: ["python3", "python3:regex"],
    units: "cp",
    replace: "python",
    features: features({
      lookbehind: "any", namedGroups: ["python", "angle"], namedBackrefs: ["python", "g-angle"],
      gBackrefs: false, relativeBackrefs: false, gSubroutines: false,
      inlineFlags: "abeEfiLmprsuVwx01", caretFlags: false, resetStart: true,
      anchors: "AZGbB", classIntersection: true, classSubtraction: "--", nestedClasses: true,
      escapes: { h: null, v: "char:11", R: null, N: "namedChar", o: null, e: null, Q: null, g: null, c: null, k: null, u: "unicodeEscape", U: "unicodeEscape" },
      verbs: false, callouts: false, maxRepeat: 4294967295,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Verbose", EXTENDED),
      flag("a", "ASCII", "\\d, \\w, \\s and \\b match ASCII only"),
      flag("V1", "Version 1", "Set operations and nested classes; full case folding", "V1"),
      flag("r", "Reverse", "Search backwards from the end of the text"),
      flag("b", "Best match", "Fuzzy matching finds the best match, not the first"),
    ],
    defaultFlags: [],
  },
  {
    id: "ruby",
    name: "Ruby",
    short: "Ruby",
    language: "Ruby",
    description: "Onigmo, Ruby's regex engine.",
    family: "perl",
    engine: "backtracking",
    worker: "ruby",
    requires: ["ruby"],
    units: "cp",
    replace: "ruby",
    features: features({
      lookbehind: "alternatives", namedGroups: ["angle", "quote"], namedBackrefs: ["k-angle", "k-quote"],
      gBackrefs: false, relativeBackrefs: false, recursion: false, gSubroutines: true, branchReset: false,
      inlineFlags: "imx", caretFlags: false, quoting: false,
      anchors: "AzZGbB", classIntersection: true, nestedClasses: true,
      escapes: { h: "hex", v: "char:11", N: null, o: null, Q: null, g: "gref" },
      verbs: false, callouts: false, absent: true, maxRepeat: 100000,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", "In Ruby, m makes . match a newline; ^ and $ always match at line breaks"),
      flag("x", "Extended", EXTENDED),
    ],
    defaultFlags: [],
  },
  {
    id: "dotnet",
    name: ".NET",
    short: ".NET",
    language: "C#, F#, PowerShell",
    description: "System.Text.RegularExpressions, the engine of C#, F#, VB.NET, and PowerShell.",
    family: "perl",
    engine: "backtracking",
    worker: "dotnet",
    requires: ["dotnet"],
    units: "utf16",
    replace: "dotnet",
    features: features({
      lookbehind: "any", possessive: false, namedGroups: ["angle", "quote"], namedBackrefs: ["k-angle", "k-quote"],
      gBackrefs: false, relativeBackrefs: false, recursion: false, gSubroutines: false, branchReset: false,
      inlineFlags: "imnsx", caretFlags: false, quoting: false, resetStart: false,
      anchors: "AzZGbB", posixClasses: false, shortProperties: false, classSubtraction: "net", openMinRepeat: false,
      escapes: PLAIN_ESCAPES, verbs: false, callouts: false, balancing: true, duplicateNames: true,
      maxRepeat: 2147483647,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Single line", DOTALL),
      flag("x", "Ignore whitespace", EXTENDED),
      flag("n", "Explicit capture", "Only named groups capture"),
      flag("r", "Right to left", "Search from the end of the text toward the start", ""),
      flag("e", "ECMAScript", "ECMAScript-compatible behavior", ""),
      flag("c", "Culture invariant", "Case-insensitive matching ignores the current culture", ""),
      flag("b", "Non-backtracking", "Linear-time engine; no lookaround, backreferences, or atomic groups", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "java",
    name: "Java",
    short: "Java",
    language: "Java, Kotlin, Scala",
    description: "java.util.regex, also used by Kotlin, Scala, Groovy, and Clojure on the JVM.",
    family: "perl",
    engine: "backtracking",
    worker: "java",
    requires: ["java"],
    units: "utf16",
    replace: "java",
    features: features({
      namedGroups: ["angle"], namedBackrefs: ["k-angle"], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "idmsuxU", caretFlags: false,
      anchors: "AzZGbB", posixClasses: false, classIntersection: true, nestedClasses: true,
      escapes: { e: "char:27", o: null, g: null, K: null, N: "namedChar" },
      verbs: false, callouts: false, openMinRepeat: false, strayBrace: "error",
      maxRepeat: 2147483647,
    }),
    flags: [
      flag("i", "Case insensitive", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Comments", EXTENDED),
      flag("u", "Unicode case", "Case-insensitive matching uses Unicode case folding"),
      flag("U", "Unicode classes", "\\d, \\w, \\s and POSIX classes follow Unicode"),
      flag("d", "Unix lines", "Only \\n ends a line for ., ^ and $"),
    ],
    defaultFlags: [],
  },
  {
    id: "go",
    name: "Go",
    short: "Go",
    language: "Go",
    description: "Go's regexp package (RE2 syntax): guaranteed linear time, so no backreferences or lookaround.",
    family: "perl",
    engine: "automaton",
    worker: "go",
    requires: ["go"],
    units: "byte",
    replace: "go",
    features: features({
      lookahead: false, lookbehind: "none", atomic: false, possessive: false, backrefs: false,
      namedGroups: ["python", "angle"], namedBackrefs: [], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "imsU", caretFlags: false, comments: false, resetStart: false,
      anchors: "AzbB",
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, g: null, k: null, c: null },
      octal: true, openMinRepeat: false, verbs: false, callouts: false, maxRepeat: 1000,
    }),
    flags: [
      flag("i", "Case insensitive", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("U", "Ungreedy", UNGREEDY),
      flag("L", "Leftmost longest", "POSIX leftmost-longest matching (regexp.CompilePOSIX semantics)", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "rust",
    name: "Rust",
    short: "Rust",
    language: "Rust",
    description: "The regex crate: guaranteed linear time, so no backreferences or lookaround. Ripgrep's default engine.",
    family: "perl",
    engine: "automaton",
    worker: "rust",
    requires: ["cargo"],
    units: "byte",
    replace: "rust",
    features: features({
      lookahead: false, lookbehind: "none", atomic: false, possessive: false, backrefs: false,
      namedGroups: ["python", "angle"], namedBackrefs: [], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "imsxRUu", caretFlags: false, comments: false, quoting: false, resetStart: false,
      anchors: "AzbB", classIntersection: true, classSubtraction: "--", nestedClasses: true,
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, Q: null, g: null, k: null, c: null, u: "unicodeEscape", U: "unicodeEscape" },
      octal: false, openMinRepeat: false, verbs: false, callouts: false, maxRepeat: 0,
    }),
    flags: [
      flag("i", "Case insensitive", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Verbose", EXTENDED),
      flag("U", "Swap greed", UNGREEDY),
      flag("R", "CRLF", "^, $ and . treat \\r\\n as a line break"),
    ],
    defaultFlags: [],
  },
  {
    id: "cpp",
    name: "C++ std::regex",
    short: "C++",
    language: "C++",
    description: "The C++ standard library's std::regex (libstdc++) with its default ECMAScript grammar.",
    family: "perl",
    engine: "backtracking",
    worker: "cpp",
    requires: ["g++"],
    units: "byte",
    replace: "js",
    features: features({
      lookbehind: "none", atomic: false, possessive: false,
      namedGroups: [], namedBackrefs: [], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "", scopedFlags: false, negatedFlags: false, caretFlags: false, comments: false,
      quoting: false, resetStart: false, anchors: "bB", unicodeProperties: false, shortProperties: false,
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, e: null, K: null, Q: null, g: null, a: null, p: null, k: null, u: "unicodeEscape" },
      unknownEscape: "error", openMinRepeat: false, strayBrace: "error", verbs: false, callouts: false,
      maxRepeat: 0,
    }),
    flags: [
      flag("i", "icase", CASE, ""),
      flag("m", "multiline", MULTI, ""),
    ],
    defaultFlags: [],
  },
  {
    id: "posix-ere",
    name: "POSIX ERE",
    short: "ERE",
    language: "C (regcomp), awk, egrep",
    description: "POSIX extended regular expressions through glibc's regcomp with REG_EXTENDED: leftmost-longest matching.",
    family: "ere",
    engine: "backtracking",
    worker: "python",
    requires: [],
    units: "byte",
    replace: "sed",
    flags: [
      flag("i", "REG_ICASE", CASE, ""),
      flag("n", "REG_NEWLINE", ". and [^...] do not match a newline; ^ and $ match at line breaks", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "posix-bre",
    name: "POSIX BRE",
    short: "BRE",
    language: "C (regcomp), sed, grep",
    description: "POSIX basic regular expressions through glibc's regcomp, with GNU's \\+, \\?, and \\| extensions.",
    family: "bre",
    engine: "backtracking",
    worker: "python",
    requires: [],
    units: "byte",
    replace: "sed",
    flags: [
      flag("i", "REG_ICASE", CASE, ""),
      flag("n", "REG_NEWLINE", ". and [^...] do not match a newline; ^ and $ match at line breaks", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "grep",
    name: "grep",
    short: "grep",
    language: "Shell",
    description: "GNU grep with basic regular expressions, run on the test text one line at a time.",
    family: "bre",
    engine: "automaton",
    worker: "python",
    requires: ["grep"],
    units: "byte",
    replace: "",
    flags: [
      flag("i", "-i", CASE, ""),
      flag("w", "-w", "Match only whole words", ""),
      flag("x", "-x", "Match only whole lines", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "grep-e",
    name: "grep -E",
    short: "egrep",
    language: "Shell",
    description: "GNU grep with extended regular expressions, run on the test text one line at a time.",
    family: "ere",
    engine: "automaton",
    worker: "python",
    requires: ["grep"],
    units: "byte",
    replace: "",
    flags: [
      flag("i", "-i", CASE, ""),
      flag("w", "-w", "Match only whole words", ""),
      flag("x", "-x", "Match only whole lines", ""),
    ],
    defaultFlags: [],
  },
  {
    id: "sed",
    name: "sed",
    short: "sed",
    language: "Shell",
    description: "GNU sed with basic regular expressions.",
    family: "bre",
    engine: "backtracking",
    worker: "python",
    requires: ["sed"],
    units: "byte",
    replace: "sed",
    flags: [
      flag("i", "I", CASE, ""),
      flag("m", "M", MULTI, ""),
    ],
    defaultFlags: [],
  },
  {
    id: "sed-e",
    name: "sed -E",
    short: "sed -E",
    language: "Shell",
    description: "GNU sed with extended regular expressions.",
    family: "ere",
    engine: "backtracking",
    worker: "python",
    requires: ["sed"],
    units: "byte",
    replace: "sed",
    flags: [
      flag("i", "I", CASE, ""),
      flag("m", "M", MULTI, ""),
    ],
    defaultFlags: [],
  },
  {
    id: "gawk",
    name: "gawk",
    short: "awk",
    language: "awk",
    description: "GNU awk's dynamic regular expressions (POSIX ERE plus GNU operators), as used by match(), gsub(), and split().",
    family: "ere",
    engine: "automaton",
    worker: "python",
    requires: ["gawk"],
    units: "cp",
    replace: "awk",
    flags: [
      flag("i", "IGNORECASE", CASE, ""),
    ],
    defaultFlags: [],
  },
  {
    id: "vim",
    name: "Vim",
    short: "Vim",
    language: "Vim, Neovim",
    description: "Vim's search patterns, run in a headless Neovim. Starts in 'magic' mode; \\v, \\m, \\M and \\V switch modes inside the pattern.",
    family: "vim",
    engine: "backtracking",
    worker: "vim",
    requires: ["nvim"],
    units: "byte",
    replace: "vim",
    flags: [
      flag("i", "\\c", CASE, ""),
    ],
    defaultFlags: [],
  },
  {
    id: "lua",
    name: "Lua patterns",
    short: "Lua",
    language: "Lua",
    description: "Lua's string patterns: not regular expressions, but their own compact language with % escapes, %b balanced matches, and %f frontiers. No alternation.",
    family: "lua",
    engine: "backtracking",
    worker: "lua",
    requires: ["lua5.1"],
    units: "byte",
    replace: "lua",
    flags: [],
    defaultFlags: [],
  },
  {
    id: "resid",
    name: "Resid",
    short: "Resid",
    language: "Resid",
    description: "Resid's lib/regex.resid: a Thompson NFA run as a lazy DFA or Pike VM, linear time, no backreferences or lookaround.",
    family: "perl",
    engine: "automaton",
    worker: "resid",
    requires: ["residc"],
    units: "cp",
    replace: "",
    features: features({
      lookahead: false, lookbehind: "none", atomic: false, possessive: false, backrefs: false,
      namedGroups: ["python", "angle"], namedBackrefs: [], gBackrefs: false, relativeBackrefs: false,
      recursion: false, gSubroutines: false, conditionals: false, branchReset: false,
      inlineFlags: "imsx", caretFlags: false, negatedFlags: true, comments: false, quoting: false, resetStart: false,
      anchors: "AzbB", unicodeProperties: false, shortProperties: false,
      escapes: { h: null, v: "char:11", R: null, N: null, X: null, o: null, K: null, Q: null, g: null, k: null, c: null, p: null, u: "unicodeEscape" },
      octal: false, verbs: false, callouts: false, maxRepeat: 0,
    }),
    flags: [
      flag("i", "Ignore case", CASE),
      flag("m", "Multiline", MULTI),
      flag("s", "Dot all", DOTALL),
      flag("x", "Extended", EXTENDED),
    ],
    defaultFlags: [],
  },
]

var BY_ID = {}
for (var i = 0; i < FLAVORS.length; i++) BY_ID[FLAVORS[i].id] = FLAVORS[i]

var DEFAULT_FLAVOR = "pcre2"

function byId(id) {
  return BY_ID[id] || BY_ID[DEFAULT_FLAVOR]
}

function exists(id) {
  return !!BY_ID[id]
}

// The flags a flavor accepts, filtered to the ones it knows.
function validFlags(id, flags) {
  var flavor = byId(id)
  var known = {}
  for (var f = 0; f < flavor.flags.length; f++) known[flavor.flags[f].id] = true
  var out = []
  for (var j = 0; j < (flags || []).length; j++) {
    if (known[flags[j]] && out.indexOf(flags[j]) < 0) out.push(flags[j])
  }
  return out
}

if (typeof module !== "undefined") module.exports = {
  FLAVORS: FLAVORS,
  PERL: PERL,
  DEFAULT_FLAVOR: DEFAULT_FLAVOR,
  byId: byId,
  exists: exists,
  validFlags: validFlags,
}
