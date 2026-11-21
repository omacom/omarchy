.pragma library
.import "Parser.js" as Parser
.import "Flavors.js" as Flavors

// The quick reference: every construct, what it means, and an example to
// try. Whether a flavor has a construct is decided by parsing the example
// with that flavor's grammar, so the reference and the parser never disagree.
//
// An entry: [category, syntax, meaning, example pattern, example text, families]
// families limits an entry to grammars ("perl", "ere", "bre", "vim", "lua");
// omitted means the Perl family.

var ENTRIES = [
  // ---- characters ----
  ["Characters", "abc", "The characters themselves", "cat", "concatenate"],
  ["Characters", "\\.", "A metacharacter, taken literally", "3\\.14", "pi is 3.14, not 3x14"],
  ["Characters", "\\n \\t \\r", "Newline, tab, carriage return", "a\\tb", "a\tb"],
  ["Characters", "\\xhh", "The character with hex code hh", "\\x41", "ABC"],
  ["Characters", "\\x{hhhh}", "The code point hhhh", "\\x{e9}", "café"],
  ["Characters", "\\uhhhh", "The UTF-16 code unit hhhh", "\\u00e9", "café"],
  ["Characters", "\\u{h…}", "A code point, in unicode mode", "\\u{1F600}", "smile 😀"],
  ["Characters", "\\0 \\012", "Octal escapes", "\\101", "ABC"],
  ["Characters", "\\cX", "A control character", "\\cI", "a\tb"],
  ["Characters", "\\N{name}", "A character by its Unicode name", "\\N{GREEK SMALL LETTER ALPHA}", "αβγ"],
  ["Characters", "\\Q…\\E", "Everything between, literally", "\\Qa.b*c\\E", "a.b*c and abbc"],

  // ---- classes ----
  ["Classes", ".", "Any character but a line break (any at all with s)", "c.t", "cat cot c\nt"],
  ["Classes", "[abc]", "One of the listed characters", "gr[ae]y", "grey gray groy"],
  ["Classes", "[^abc]", "Any character not listed", "[^aeiou]+", "rhythm and blues"],
  ["Classes", "[a-z]", "A range of characters", "[0-9A-F]+", "0x1F 0xZZ"],
  ["Classes", "\\d \\D", "A digit, and its opposite", "\\d+", "2026 and ٣"],
  ["Classes", "\\w \\W", "A word character, and its opposite", "\\w+", "naïve café_2"],
  ["Classes", "\\s \\S", "Whitespace, and its opposite", "\\S+", "two  words"],
  ["Classes", "\\h \\v", "Horizontal and vertical whitespace", "\\h+", "a \t b"],
  ["Classes", "\\R", "Any line break, \\r\\n as one", "a\\Rb", "a\r\nb"],
  ["Classes", "\\N", "Any character but a line break, whatever the flags", "a\\Nb", "axb a\nb"],
  ["Classes", "\\X", "One user-perceived character (grapheme)", "\\X", "é 👍🏽"],
  ["Classes", "\\p{L} \\P{L}", "A Unicode property, and its opposite", "\\p{L}+", "Ωmega 42"],
  ["Classes", "\\p{Greek}", "A Unicode script", "\\p{Greek}+", "alpha α beta β"],
  ["Classes", "[[:alpha:]]", "A POSIX class inside brackets", "[[:upper:]]+", "SHOUT quietly", ["perl", "ere", "bre"]],
  ["Classes", "[a-z&&[^aeiou]]", "Intersection of sets", "[a-z&&[^aeiou]]+", "strength"],
  ["Classes", "[\\w--\\d]", "Difference of sets", "[\\w--\\d]+", "abc123def"],
  ["Classes", "[a-z-[aeiou]]", ".NET class subtraction", "[a-z-[aeiou]]+", "strength"],

  // ---- anchors ----
  ["Anchors", "^ $", "Start and end of the text (of each line with m)", "^\\w+$", "one\ntwo"],
  ["Anchors", "\\A \\z", "Start and very end of the text, whatever the flags", "\\Aone", "one\ntwo"],
  ["Anchors", "\\Z", "End of the text, before a final newline", "two\\Z", "one\ntwo\n"],
  ["Anchors", "\\b \\B", "A word boundary, and not one", "\\bcat\\b", "cat concat cats"],
  ["Anchors", "\\G", "Where the previous match ended", "\\G\\d", "123a45"],
  ["Anchors", "\\K", "Keep what came before out of the match", "price: \\K\\d+", "price: 42"],
  ["Anchors", "\\< \\>", "Start and end of a word", "\\<the\\>", "the other theme", ["ere", "bre", "vim"]],

  // ---- groups ----
  ["Groups", "(…)", "A capturing group", "(\\d+)-(\\d+)", "pages 10-20"],
  ["Groups", "(?:…)", "A group that does not capture", "(?:ab)+", "ababab"],
  ["Groups", "(?<name>…)", "A named group", "(?<year>\\d{4})", "in 2026"],
  ["Groups", "(?P<name>…)", "A named group, Python's way", "(?P<year>\\d{4})", "in 2026"],
  ["Groups", "(?'name'…)", "A named group, with quotes", "(?'year'\\d{4})", "in 2026"],
  ["Groups", "(?>…)", "An atomic group: never backtracked into", "(?>a+)b", "aaab"],
  ["Groups", "(?|…|…)", "Branch reset: alternatives share group numbers", "(?|(\\d+)|x(\\w+))", "42 xab"],
  ["Groups", "(?i)", "Flags from here on", "(?i)hello", "HeLLo"],
  ["Groups", "(?i:…)", "Flags inside the group only", "(?i:hello) world", "HELLO world"],
  ["Groups", "(?#…)", "A comment", "\\d+(?# the number)", "42"],
  ["Groups", "(?~…)", "The absent operator: text not containing …", "/\\*(?~\\*/)\\*/", "/* a */ b */"],

  // ---- quantifiers ----
  ["Quantifiers", "* + ?", "Zero or more, one or more, zero or one", "colou?r", "color colour"],
  ["Quantifiers", "{n} {n,} {n,m}", "Exactly n, at least n, between n and m", "\\d{2,3}", "1 12 1234"],
  ["Quantifiers", "{,m}", "At most m", "a{,2}", "aaa"],
  ["Quantifiers", "*? +? ??", "Lazy: as few as possible", "<.+?>", "<b>bold</b>"],
  ["Quantifiers", "*+ ++ ?+", "Possessive: as many as possible, never giving back", "\\d++\\d", "1234"],

  // ---- lookaround ----
  ["Lookaround", "(?=…)", "Lookahead: followed by …, without consuming it", "\\d+(?=%)", "50% of 80"],
  ["Lookaround", "(?!…)", "Negative lookahead: not followed by …", "\\d+(?!%|\\d)", "50% of 80"],
  ["Lookaround", "(?<=…)", "Lookbehind: preceded by …", "(?<=\\$)\\d+", "$30 or 40"],
  ["Lookaround", "(?<!…)", "Negative lookbehind: not preceded by …", "(?<!\\$)\\b\\d+", "$30 or 40"],

  // ---- references ----
  ["References", "\\1", "The text group 1 matched", "(\\w)\\1", "book keeper"],
  ["References", "\\k<name>", "The text a named group matched", "(?<c>\\w)\\k<c>", "book keeper"],
  ["References", "(?P=name)", "The same, Python's way", "(?P<c>\\w)(?P=c)", "book keeper"],
  ["References", "\\g{-1}", "The text the previous group matched", "(\\w)\\g{-1}", "book keeper"],
  ["References", "(?R) (?1)", "Recursion: the whole pattern, or group 1's, again", "\\((?:[^()]|(?R))*\\)", "f((a)(b(c)))"],
  ["References", "\\g<1>", "Group 1's pattern again (Ruby, PCRE2)", "(\\d)\\g<1>", "12 3"],
  ["References", "(?(1)…|…)", "Conditional: if group 1 matched", "(<)?\\w+(?(1)>)", "<tag> word"],
  ["References", "(*SKIP)(*FAIL)", "Backtracking control verbs", "\"[^\"]*\"(*SKIP)(*FAIL)|\\w+", "say \"skip me\" words"],

  // ---- POSIX ----
  ["POSIX", "\\(…\\) \\{n,m\\}", "Groups and intervals in basic syntax", "\\(ab\\)\\{2\\}", "ababab", ["bre"]],
  ["POSIX", "(…) {n,m} + ?", "Groups, intervals, + and ? in extended syntax", "(ab){2}", "ababab", ["ere"]],
  ["POSIX", "[[:class:]]", "Character classes inside brackets", "[[:digit:]]+", "a42", ["ere", "bre"]],
  ["POSIX", "[[=e=]]", "Equivalence class: e and its accented forms", "[[=e=]]", "e é è", ["ere", "bre"]],

  // ---- Vim ----
  ["Vim", "\\v", "Very magic: most punctuation is special", "\\v(\\d+)-(\\d+)", "10-20", ["vim"]],
  ["Vim", "\\{-}", "Lazy repetition", "<.\\{-}>", "<b>bold</b>", ["vim"]],
  ["Vim", "\\zs \\ze", "Start and end the match here", "foo\\zsbar", "foobar", ["vim"]],
  ["Vim", "\\@=  \\@!", "Lookahead, written after the item", "foo\\(bar\\)\\@=", "foobar foobaz", ["vim"]],
  ["Vim", "\\@<=", "Lookbehind, written after the item", "\\(foo\\)\\@<=bar", "foobar bazbar", ["vim"]],
  ["Vim", "\\c \\C", "Ignore case, match case", "\\cvim", "VIM vim", ["vim"]],
  ["Vim", "\\_s", "Whitespace or a line break", "a\\_s\\+b", "a\n b", ["vim"]],

  // ---- Lua ----
  ["Lua", "%a %d %s %w", "Letters, digits, spaces, alphanumerics", "%d+", "abc 123", ["lua"]],
  ["Lua", "- (lazy *)", "Zero or more, as few as possible", "<.->", "<b>bold</b>", ["lua"]],
  ["Lua", "%b()", "A balanced pair", "%b()", "f(a(b)c)d", ["lua"]],
  ["Lua", "%f[%w]", "A frontier: the edge of a set", "%f[%w]%w+", "hello, world", ["lua"]],
  ["Lua", "()", "Capture the position", "()%d", "ab3", ["lua"]],
  ["Lua", "%1", "The text capture 1 matched", "(%a)%1", "book", ["lua"]],
]

// Entries a flavor has, by parsing each example with its grammar.
function forFlavor(flavorId) {
  var flavor = Flavors.byId(flavorId)
  var out = []
  for (var i = 0; i < ENTRIES.length; i++) {
    var e = ENTRIES[i]
    var families = e[5] || ["perl"]
    if (families.indexOf(flavor.family) < 0) continue
    var supported = Parser.parse(e[3], flavor.id, []).errors.length === 0
    out.push({ category: e[0], syntax: e[1], meaning: e[2], pattern: e[3], text: e[4], supported: supported })
  }
  return out
}

function search(entries, query) {
  var q = String(query || "").toLowerCase()
  if (q === "") return entries
  return entries.filter(function(e) {
    return e.syntax.toLowerCase().indexOf(q) >= 0 || e.meaning.toLowerCase().indexOf(q) >= 0 || e.category.toLowerCase().indexOf(q) >= 0
  })
}

if (typeof module !== "undefined") module.exports = { ENTRIES: ENTRIES, forFlavor: forFlavor, search: search }
