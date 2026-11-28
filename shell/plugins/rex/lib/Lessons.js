.pragma library
.import "Tests.js" as Tests

// Rex's course: from a first literal to how engines work inside. Every
// exercise is a set of unit tests the learner's pattern has to pass, run on
// the real engine for the flavor the exercise names; every exercise's
// solution is checked against its own tests by the test suite.
//
// A lesson: { id, level, title, body, example: { pattern, text, flavor },
//             exercises: [{ prompt, flavor, flags, tests, hint, solution }] }
// Tests are written [text, expect, group, value], see Tests.js.

function t(text, expect, group, value) {
  return Tests.normalize({ text: text, expect: expect || "match", group: group, value: value })
}

var LEVELS = ["Basics", "Building patterns", "Advanced", "Inside the engine"]

var LESSONS = [
  // ---- basics ----
  {
    id: "literals", level: 0, title: "Literal text",
    body: "Most characters in a pattern stand for themselves. The pattern cat finds the letters c, a, t in that order, wherever they are: inside concatenate as much as in cat. Matching is case sensitive unless you ask otherwise.",
    example: { pattern: "cat", text: "The cat sat on the concatenated mat. CAT" },
    exercises: [
      { prompt: "Match the word dog.", tests: [t("hot dog", "match"), t("Dog", "nomatch"), t("doge", "match")], hint: "Type the letters as they are.", solution: "dog" },
      { prompt: "Match 2026, and nothing else that is a number.", tests: [t("in 2026", "match"), t("in 2025", "nomatch"), t("20 26", "nomatch")], hint: "Digits are literal characters too.", solution: "2026" },
    ],
  },
  {
    id: "dot", level: 0, title: "Any character: the dot",
    body: "A dot matches any single character except a line break. c.t matches cat, cot and c?t, but not ct (the dot needs a character) or c\\nt (a line break is not 'any character' unless the s flag is on).",
    example: { pattern: "c.t", text: "cat cot c?t ct coat" },
    exercises: [
      { prompt: "Match a, any one character, then c.", tests: [t("abc", "full"), t("a-c", "full"), t("ac", "nomatch"), t("abbc", "nomatch")], hint: "One dot stands for one character.", solution: "^a.c$" },
    ],
  },
  {
    id: "escaping", level: 0, title: "Escaping metacharacters",
    body: "Some characters have special meanings: . ^ $ * + ? ( ) [ ] { } | and \\. To match one literally, put a backslash before it. 3\\.14 matches 3.14 but not 3x14.",
    example: { pattern: "3\\.14", text: "pi is 3.14, not 3x14" },
    exercises: [
      { prompt: "Match the price $9.99 exactly.", tests: [t("only $9.99 today", "match"), t("only $9x99 today", "nomatch"), t("9.99", "nomatch")], hint: "Both $ and . are special.", solution: "\\$9\\.99" },
      { prompt: "Match (yes) with its parentheses.", tests: [t("say (yes)", "match"), t("say yes", "nomatch")], hint: "Escape ( and ).", solution: "\\(yes\\)" },
    ],
  },
  {
    id: "classes", level: 0, title: "Character classes",
    body: "Square brackets match one character from a set. gr[ae]y matches grey and gray. Inside brackets most metacharacters lose their meaning, so [.] is a literal dot.",
    example: { pattern: "gr[ae]y", text: "grey gray groy" },
    exercises: [
      { prompt: "Match both spellings, gray and grey, and nothing else.", tests: [t("gray", "full"), t("grey", "full"), t("groy", "nomatch")], hint: "One class for the vowel that changes.", solution: "^gr[ae]y$" },
      { prompt: "Match a vowel followed by a digit.", tests: [t("a1", "match"), t("e9", "match"), t("b1", "nomatch"), t("aa", "nomatch")], hint: "Two classes in a row.", solution: "[aeiou][0-9]" },
    ],
  },
  {
    id: "ranges", level: 0, title: "Ranges and negation",
    body: "Inside brackets, a-z is a range of characters. [0-9A-F] is a hex digit. A ^ right after the opening bracket negates the class: [^0-9] is any character that is not a digit, including a line break.",
    example: { pattern: "[^aeiou ]+", text: "rhythm and blues" },
    exercises: [
      { prompt: "Match a hexadecimal digit (upper or lower case).", tests: [t("f", "full"), t("C", "full"), t("7", "full"), t("g", "nomatch")], hint: "Three ranges in one class.", solution: "^[0-9a-fA-F]$" },
      { prompt: "Match a character that is not a letter or a space.", tests: [t("!", "full"), t("7", "full"), t("a", "nomatch"), t(" ", "nomatch")], hint: "Start the class with ^.", solution: "^[^a-zA-Z ]$" },
    ],
  },
  {
    id: "shorthands", level: 0, title: "Shorthand classes",
    body: "\\d is a digit, \\w a word character (letters, digits, underscore), \\s whitespace. Their capitals are the opposites: \\D, \\W, \\S. In some flavors they cover all of Unicode, in others only ASCII; the Explain tab says which.",
    example: { pattern: "\\w+\\s\\d+", text: "room 101, floor 3" },
    exercises: [
      { prompt: "Match a digit, whitespace, then a word character.", tests: [t("1 a", "full"), t("9\tZ", "full"), t("1  a", "nomatch")], hint: "\\d, \\s, \\w.", solution: "^\\d\\s\\w$" },
    ],
  },
  {
    id: "repetition", level: 0, title: "Repetition: * + ?",
    body: "A quantifier repeats what comes just before it. * means zero or more, + one or more, ? zero or one. \\d+ is one or more digits; colou?r makes the u optional. To repeat several characters, group them first: (ab)+.",
    example: { pattern: "\\d+", text: "7 42 and 2026" },
    exercises: [
      { prompt: "Match a whole number with one or more digits.", tests: [t("7", "full"), t("2026", "full"), t("", "nomatch"), t("12a", "nomatch")], hint: "\\d and +, anchored at both ends.", solution: "^\\d+$" },
      { prompt: "Match a number with an optional minus sign.", tests: [t("-5", "full"), t("5", "full"), t("--5", "nomatch")], hint: "-? then digits.", solution: "^-?\\d+$" },
    ],
  },
  {
    id: "counts", level: 0, title: "Counted repetition",
    body: "Braces give exact counts: \\d{4} is exactly four digits, \\d{2,4} two to four, \\d{2,} two or more.",
    example: { pattern: "\\d{2,3}", text: "1 12 123 1234" },
    exercises: [
      { prompt: "Match a US ZIP code: five digits, optionally a dash and four more.", tests: [t("90210", "full"), t("90210-1234", "full"), t("9021", "nomatch"), t("90210-12", "nomatch")], hint: "\\d{5}, then an optional group (-\\d{4})?", solution: "^\\d{5}(-\\d{4})?$" },
    ],
  },
  {
    id: "anchors", level: 0, title: "Anchors: ^ and $",
    body: "^ matches at the start of the text and $ at the end. They match positions, not characters. With the m flag they also match at the start and end of every line.",
    example: { pattern: "^\\w+", text: "first line\nsecond line" },
    exercises: [
      { prompt: "Match text that is only digits, nothing else.", tests: [t("12345", "match"), t("123a", "nomatch"), t("a123", "nomatch")], hint: "Anchor both ends.", solution: "^\\d+$" },
      { prompt: "Match a line that starts with #, in a text of several lines.", flags: ["m"], tests: [t("one\n# two", "match"), t("one # two", "nomatch")], hint: "The m flag is on, so ^ matches after each line break.", solution: "^#" },
    ],
  },
  {
    id: "boundaries", level: 0, title: "Word boundaries",
    body: "\\b matches where a word character meets a non-word character, or the edge of the text. \\bcat\\b finds cat as a whole word, but not in concatenate or cats.",
    example: { pattern: "\\bcat\\b", text: "cat concat cats bobcat cat." },
    exercises: [
      { prompt: "Match the whole word is, not inside this or island.", tests: [t("it is here", "match"), t("this island", "nomatch"), t("is", "full")], hint: "\\b on both sides.", solution: "\\bis\\b" },
    ],
  },

  // ---- building patterns ----
  {
    id: "alternation", level: 1, title: "Alternation",
    body: "A | B matches A or B. It has the lowest precedence, so ^cat|dog$ means (^cat) or (dog$). Use a group to limit it: ^(cat|dog)$.",
    example: { pattern: "\\b(cat|dog|bird)s?\\b", text: "cats and dogs, a bird" },
    exercises: [
      { prompt: "Match exactly yes or no.", tests: [t("yes", "full"), t("no", "full"), t("yesno", "nomatch"), t("noyes", "nomatch")], hint: "Group the alternation, then anchor the group.", solution: "^(yes|no)$" },
    ],
  },
  {
    id: "groups", level: 1, title: "Capturing groups",
    body: "Parentheses group and capture: (\\d+)-(\\d+) on 10-20 captures 10 as group 1 and 20 as group 2. Groups are numbered by their opening parenthesis, left to right.",
    example: { pattern: "(\\d+)-(\\d+)", text: "pages 10-20" },
    exercises: [
      { prompt: "Capture the user name of an email address as group 1.", tests: [t("ann@example.com", "group", "1", "ann"), t("bob.lee@x.org", "group", "1", "bob.lee")], hint: "Capture everything before the @: ([^@]+)@", solution: "([^@]+)@" },
      { prompt: "Capture the year, month, and day of 2026-10-09 as groups 1, 2, 3.", tests: [t("2026-10-09", "group", "1", "2026"), t("2026-10-09", "group", "2", "10"), t("2026-10-09", "group", "3", "09")], hint: "Three groups of digits with dashes between.", solution: "(\\d{4})-(\\d{2})-(\\d{2})" },
    ],
  },
  {
    id: "noncapturing", level: 1, title: "Groups that do not capture",
    body: "(?:...) groups without capturing. Use it to repeat or alternate a part without creating a group number, which keeps later groups numbered as you expect.",
    example: { pattern: "(?:ab)+(\\d)", text: "abab7" },
    exercises: [
      { prompt: "Match one or more ha, and capture the ! that follows as group 1.", tests: [t("hahaha!", "group", "1", "!"), t("ha!", "group", "1", "!")], hint: "(?:ha)+ then (!).", solution: "(?:ha)+(!)" },
    ],
  },
  {
    id: "named", level: 1, title: "Named groups",
    body: "(?<name>...) names a group, so code can ask for it by name instead of number. Python writes (?P<name>...); PCRE2 accepts both.",
    example: { pattern: "(?<year>\\d{4})-(?<month>\\d{2})", text: "2026-10" },
    exercises: [
      { prompt: "Name the area code of (555) 123-4567 'area'.", tests: [t("(555) 123-4567", "group", "area", "555")], hint: "\\((?<area>\\d{3})\\)", solution: "\\((?<area>\\d{3})\\)" },
    ],
  },
  {
    id: "backrefs", level: 1, title: "Backreferences",
    body: "\\1 matches the same text group 1 matched. (\\w)\\1 finds a doubled letter; \\b(\\w+) \\1\\b finds a repeated word. Not every engine has them: Go, Rust, and RE2 leave them out to stay fast.",
    example: { pattern: "\\b(\\w+) \\1\\b", text: "this is is a test test" },
    exercises: [
      { prompt: "Match a word repeated twice in a row, like the the.", tests: [t("it was the the end", "match"), t("the then", "nomatch")], hint: "Capture a word, a space, then \\1, with boundaries.", solution: "\\b(\\w+) \\1\\b" },
      { prompt: "Match text in matching quotes, single or double.", tests: [t("'hi'", "full"), t("\"hi\"", "full"), t("'hi\"", "nomatch")], hint: "Capture the opening quote and refer back to it.", solution: "^(['\"]).*\\1$" },
    ],
  },
  {
    id: "lazy", level: 1, title: "Greedy and lazy",
    body: "Quantifiers are greedy: .+ takes as much as it can and gives back only when the rest fails. Add ? to make one lazy: .+? takes as little as it can. On <b>bold</b>, <.+> matches the whole thing; <.+?> just <b>.",
    example: { pattern: "<.+?>", text: "<b>bold</b>" },
    exercises: [
      { prompt: "Match the first HTML tag only: <b> in <b>x</b>.", tests: [t("<b>x</b>", "group", "0", "<b>")], hint: "A lazy quantifier, or [^>]+.", solution: "<.+?>" },
    ],
  },
  {
    id: "flags", level: 1, title: "Flags",
    body: "Flags change how the whole pattern reads. i ignores case, m makes ^ and $ match at every line, s lets . match a line break, x lets you add spaces and comments. Most flavors also take them inline: (?i)hello.",
    example: { pattern: "(?i)hello", text: "Hello HELLO hello" },
    exercises: [
      { prompt: "Match error in any case, using an inline flag.", tests: [t("ERROR", "match"), t("Error", "match"), t("errr", "nomatch")], hint: "Start the pattern with (?i).", solution: "(?i)error" },
      { prompt: "With the s flag on, match from start to end across lines.", flags: ["s"], tests: [t("BEGIN\nmiddle\nEND", "full")], hint: ". now matches line breaks too.", solution: "^BEGIN.*END$" },
    ],
  },
  {
    id: "lookahead", level: 1, title: "Lookahead",
    body: "(?=...) checks what comes next without consuming it; (?!...) checks it does not come. \\d+(?=%) finds the number in 50% but not the % itself.",
    example: { pattern: "\\d+(?=%)", text: "50% of 80" },
    exercises: [
      { prompt: "Match a number followed by px, without matching px.", tests: [t("width: 12px", "group", "0", "12"), t("12em", "nomatch")], hint: "\\d+(?=px)", solution: "\\d+(?=px)" },
      { prompt: "Match the first word that is not followed by a comma.", tests: [t("one, two", "group", "0", "two"), t("solo", "full")], hint: "Careful: \\w+(?!,) just backs off one letter, matching on. Put the lookahead after a whole word: \\b\\w+\\b(?!,)", solution: "\\b\\w+\\b(?!,)" },
    ],
  },
  {
    id: "lookbehind", level: 1, title: "Lookbehind",
    body: "(?<=...) checks what comes before; (?<!...) checks it does not. (?<=\\$)\\d+ finds 30 in $30. Many flavors only allow lookbehind of a fixed or bounded length.",
    example: { pattern: "(?<=\\$)\\d+", text: "$30 or 40" },
    exercises: [
      { prompt: "Match a number that comes right after a $ sign, without the $.", tests: [t("cost $42", "group", "0", "42"), t("cost 42", "nomatch")], hint: "(?<=\\$)", solution: "(?<=\\$)\\d+" },
    ],
  },
  {
    id: "passwords", level: 1, title: "Several conditions at once",
    body: "Lookaheads at the start of a pattern each test the whole text without moving, so several can stack: ^(?=.*\\d)(?=.*[a-z]).{8,}$ needs a digit, a lowercase letter, and eight characters.",
    example: { pattern: "^(?=.*\\d)(?=.*[a-z]).{8,}$", text: "hunter22" },
    exercises: [
      { prompt: "Match a password of 8+ characters with an uppercase letter and a digit.", tests: [t("Secret123", "full"), t("secret123", "nomatch"), t("Secretive", "nomatch"), t("Sh0rt", "nomatch")], hint: "Two lookaheads, then .{8,}", solution: "^(?=.*[A-Z])(?=.*\\d).{8,}$" },
    ],
  },

  // ---- advanced ----
  {
    id: "unicode", level: 2, title: "Unicode",
    body: "[a-zA-Z] misses é, ß and Ж. \\p{L} matches any letter, \\p{Lu} an uppercase one, \\p{Greek} a Greek character. Flavors differ: JavaScript needs the u flag, Python's re has no \\p at all, and \\w is ASCII in some flavors and Unicode in others.",
    example: { pattern: "\\p{L}+", text: "naïve café Ωmega 42" },
    exercises: [
      { prompt: "Match a whole word of letters from any language.", flags: ["u"], tests: [t("Ωmega", "full"), t("naïve", "full"), t("abc1", "nomatch")], hint: "\\p{L}+", solution: "^\\p{L}+$" },
    ],
  },
  {
    id: "atomic", level: 2, title: "Atomic groups and possessive quantifiers",
    body: "(?>...) is atomic: once it matches, the engine never goes back into it to try other ways. \\d++ is the same idea on one quantifier. They make failures fast, and they change what matches: (?>a+)ab can never match, because a+ keeps every a.",
    example: { pattern: "(?>\\d+)\\b", text: "12345 678x" },
    exercises: [
      { prompt: "Match a run of digits possessively, then a letter.", tests: [t("123a", "full"), t("123", "nomatch")], hint: "\\d++ then [a-z].", solution: "^\\d++[a-z]$" },
    ],
  },
  {
    id: "catastrophic", level: 2, title: "Catastrophic backtracking",
    body: "(a+)+$ fails on a long run of a's followed by anything else in exponential time: the engine tries every way of splitting the a's between the two loops before giving up. The fix is to give each character one way to match: a+$, or an atomic group. Open the Optimize tab on such a pattern to see Rex find it, and the Debugger to watch it happen.",
    example: { pattern: "(a+)+$", text: "aaaaaaaaaaaaaaaaaaaaaaaaa!" },
    exercises: [
      { prompt: "(a+)+$ should match text that ends in a run of a's, and fail fast otherwise, but it hits PCRE2's backtracking limit on the last test. Fix it.", tests: [t("baaa", "match"), t("aaa!", "nomatch"), t("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!", "nomatch")], hint: "One loop is enough.", solution: "a+$" },
    ],
  },
  {
    id: "recursion", level: 2, title: "Recursion",
    body: "PCRE2, Perl, and the Python regex module can recurse: (?R) matches the whole pattern again, (?1) group 1's. That handles nested structures regular expressions otherwise cannot, such as balanced parentheses: \\((?:[^()]|(?R))*\\).",
    example: { pattern: "\\((?:[^()]|(?R))*\\)", text: "f((a)(b(c)))" },
    exercises: [
      { prompt: "Match balanced curly braces, nested to any depth.", tests: [t("{a{b}{c{d}}}", "full"), t("{a{b}", "nomatch")], hint: "\\{(?:[^{}]|(?R))*\\}, anchored with care: use a group and (?1).", solution: "^(\\{(?:[^{}]|(?1))*\\})$" },
    ],
  },
  {
    id: "conditionals", level: 2, title: "Conditionals",
    body: "(?(1)yes|no) matches yes if group 1 took part and no otherwise. (<)?\\w+(?(1)>) matches a word optionally wrapped in <>, but only with both brackets or neither.",
    example: { pattern: "^(<)?\\w+(?(1)>)$", text: "<tag>" },
    exercises: [
      { prompt: "Match a number optionally in parentheses, but only if they are balanced.", tests: [t("(42)", "full"), t("42", "full"), t("(42", "nomatch"), t("42)", "nomatch")], hint: "^(\\()?\\d+(?(1)\\))$", solution: "^(\\()?\\d+(?(1)\\))$" },
    ],
  },
  {
    id: "freespacing", level: 2, title: "Readable patterns: free spacing",
    body: "With the x flag, spaces and line breaks in the pattern are ignored and # starts a comment, so a long pattern can be laid out and explained. A literal space then needs \\ or [ ].",
    example: { pattern: "(?x) (\\d{4}) - (\\d{2})  # year and month", text: "2026-10" },
    exercises: [
      { prompt: "Write a free-spacing pattern that matches an ISO date (2026-10-09).", flags: ["x"], tests: [t("2026-10-09", "full"), t("2026-1-09", "nomatch")], hint: "Spaces are free: \\d{4} - \\d{2} - \\d{2}, anchored.", solution: "^ \\d{4} - \\d{2} - \\d{2} $" },
    ],
  },

  // ---- inside the engine ----
  {
    id: "backtracking", level: 3, title: "How a backtracking engine works",
    body: "Perl, PCRE2, Python, Java, .NET, Ruby and JavaScript all backtrack: they try the pattern from each starting position, make a choice at every quantifier and alternation, and when the rest fails they go back to the last choice and try the next. Open the Debugger to watch PCRE2 do it step by step. A class that says what to skip avoids most of the backtracking.",
    example: { pattern: "\".*\"", text: "say \"hi\" and \"bye\"" },
    exercises: [
      { prompt: "Match each double-quoted string separately, without a lazy quantifier.", tests: [t("say \"hi\" and \"bye\"", "group", "0", "\"hi\"")], hint: "Between the quotes, anything but a quote: [^\"]*", solution: "\"[^\"]*\"" },
    ],
  },
  {
    id: "automata", level: 3, title: "Engines that cannot backtrack",
    body: "Go, Rust, RE2 and Resid compile a pattern into an automaton that reads each character once, so no pattern can take exponential time. The price is no backreferences or lookaround. Compare flavors shows which engines accept a pattern.",
    example: { pattern: "\\d{4}-\\d{2}-\\d{2}", text: "on 2026-10-09", flavor: "go" },
    exercises: [
      { prompt: "Without lookaround, match a number that ends in px, capturing just the number.", flavor: "go", tests: [t("width: 12px", "group", "1", "12"), t("12em", "nomatch")], hint: "Capture the number, then match px after it.", solution: "(\\d+)px" },
    ],
  },
  {
    id: "longest", level: 3, title: "Leftmost first, leftmost longest",
    body: "Perl-style engines take the first alternative that leads to a match: a|ab on ab matches just a. POSIX engines (grep, sed, awk) take the longest match starting at the leftmost position: ab. Ordering alternatives longest first makes Perl-style engines agree.",
    example: { pattern: "a|ab", text: "ab" },
    exercises: [
      { prompt: "Reorder a|ab so a Perl-style engine matches all of ab.", tests: [t("ab", "full")], hint: "Put the longer alternative first.", solution: "^(?:ab|a)$" },
    ],
  },
  {
    id: "optimizing", level: 3, title: "Making patterns fast",
    body: "Fast patterns fail fast: anchor them when you can, say exactly what may be skipped ([^,]* rather than .*?), make repetitions that should not give back possessive or atomic, and turn alternations of single characters into classes. The Optimize tab checks each of these, and the Benchmark page times them on every engine.",
    example: { pattern: "^(?:[^,]*,){2}([^,]*)", text: "a,b,third,d" },
    exercises: [
      { prompt: "Capture the third comma-separated field as group 1, without .*", tests: [t("a,b,third,d", "group", "1", "third"), t("x,y,z", "group", "1", "z")], hint: "^(?:[^,]*,){2}([^,]*)", solution: "^(?:[^,]*,){2}([^,]*)" },
    ],
  },
]

function byId(id) {
  for (var i = 0; i < LESSONS.length; i++) if (LESSONS[i].id === id) return LESSONS[i]
  return null
}

function index(id) {
  for (var i = 0; i < LESSONS.length; i++) if (LESSONS[i].id === id) return i
  return -1
}

// Progress: { done: { "lessonId": [exercise indices] } }
function readProgress(text) {
  var doc = null
  try { doc = JSON.parse(text) } catch (e) {}
  var done = doc && doc.done && typeof doc.done === "object" ? doc.done : {}
  var out = {}
  for (var id in done) if (byId(id) && Array.isArray(done[id])) out[id] = done[id].filter(function(n) { return typeof n === "number" })
  return { done: out }
}

function writeProgress(progress) {
  return JSON.stringify({ version: 1, done: progress.done }, null, 2) + "\n"
}

function markDone(progress, lessonId, exercise) {
  var done = {}
  for (var id in progress.done) done[id] = progress.done[id].slice()
  var list = done[lessonId] || []
  if (list.indexOf(exercise) < 0) list.push(exercise)
  done[lessonId] = list
  return { done: done }
}

function complete(progress, lesson) {
  var list = progress.done[lesson.id] || []
  return lesson.exercises.every(function(e, i) { return list.indexOf(i) >= 0 })
}

if (typeof module !== "undefined") module.exports = {
  LEVELS: LEVELS, LESSONS: LESSONS, byId: byId, index: index,
  readProgress: readProgress, writeProgress: writeProgress, markDone: markDone, complete: complete,
}
