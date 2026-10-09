.pragma library
.import "Flavors.js" as Flavors

// Code that uses the pattern in the flavor's own language: test, find every
// match with its groups, replace, and split. The hard part is getting the
// pattern into a string or regex literal intact, so every language has its
// own quoting below, chosen so the pattern needs the least escaping.

// ---- quoting ------------------------------------------------------------------

function cEscape(s, quote) {
  var out = ""
  for (var i = 0; i < s.length; i++) {
    var c = s.charAt(i)
    var code = s.charCodeAt(i)
    if (c === "\\") out += "\\\\"
    else if (c === quote) out += "\\" + quote
    else if (c === "\n") out += "\\n"
    else if (c === "\r") out += "\\r"
    else if (c === "\t") out += "\\t"
    else if (code < 32) out += "\\x" + (code < 16 ? "0" : "") + code.toString(16)
    else out += c
  }
  return out
}

function doubleQuoted(s) { return "\"" + cEscape(s, "\"") + "\"" }

function shellQuoted(s) { return "'" + s.replace(/'/g, "'\\''") + "'" }

// A regex literal between slashes: a / inside must be escaped, unless it
// already is or sits in a class.
function slashed(pattern) {
  var out = ""
  var inClass = false
  for (var i = 0; i < pattern.length; i++) {
    var c = pattern.charAt(i)
    if (c === "\\") { out += c + pattern.charAt(i + 1); i++; continue }
    if (c === "[") inClass = true
    else if (c === "]") inClass = false
    if (c === "/" && !inClass) out += "\\/"
    else if (c === "\n") out += "\\n"
    else out += c
  }
  return out
}

function pythonString(s) {
  var odd = (s.match(/\\+$/) || [""])[0].length % 2 === 1
  if (!odd && s.indexOf("\n") < 0) {
    if (s.indexOf("\"") < 0) return "r\"" + s + "\""
    if (s.indexOf("'") < 0) return "r'" + s + "'"
  }
  return doubleQuoted(s)
}

function rustRaw(s) {
  var hashes = "#"
  while (s.indexOf("\"" + hashes) >= 0) hashes += "#"
  return "r" + hashes + "\"" + s + "\"" + hashes
}

function cppRaw(s) {
  var delimiter = "re"
  while (s.indexOf(")" + delimiter + "\"") >= 0) delimiter += "x"
  return "R\"" + delimiter + "(" + s + ")" + delimiter + "\""
}

function goString(s) {
  return s.indexOf("`") < 0 ? "`" + s + "`" : doubleQuoted(s)
}

function csharpVerbatim(s) { return "@\"" + s.replace(/"/g, "\"\"") + "\"" }

function luaLong(s) {
  var level = ""
  while (s.indexOf("]" + level + "]") >= 0) level += "="
  // A long string drops a newline right after its opening bracket.
  return "[" + level + "[" + (s.charAt(0) === "\n" ? "\n" : "") + s + "]" + level + "]"
}

function phpSingle(s) { return "'" + s.replace(/\\/g, "\\\\").replace(/'/g, "\\'") + "'" }

// PHP needs delimiters around the pattern; pick one the pattern lacks.
function phpPattern(pattern, modifiers) {
  var choices = ["/", "#", "~", "%", "!", "@", ";"]
  for (var i = 0; i < choices.length; i++) {
    if (pattern.indexOf(choices[i]) < 0) return phpSingle(choices[i] + pattern + choices[i] + modifiers)
  }
  return phpSingle("/" + slashed(pattern) + "/" + modifiers)
}

// Perl interpolates $name and @name inside m//; single quotes as the
// delimiter turn that off. A pattern with a quote of its own comes from a
// quoted heredoc instead, which takes any text as it is.
function perlPattern(pattern) {
  if (pattern.indexOf("'") < 0 && pattern.indexOf("\n") < 0) return { setup: "", match: "m'" + pattern + "'" }
  return { setup: "chomp(my $pattern = <<'PATTERN');\n" + pattern + "\nPATTERN\n", match: "m/$pattern/" }
}

function rubyLiteral(pattern) {
  return "/" + slashed(pattern).replace(/#(?=[{$@])/g, "\\#") + "/"
}

function flagLetters(flags, allowed) {
  return flags.filter(function(f) { return allowed.indexOf(f) >= 0 }).join("")
}

// ---- snippets per flavor --------------------------------------------------------

function snippets(flavorId, pattern, flags, replacement) {
  var f = Flavors.byId(flavorId)
  var rep = replacement || ""
  var has = function(x) { return flags.indexOf(x) >= 0 }
  switch (f.id) {
  case "ecmascript":
  case "node": {
    var jsFlags = flagLetters(flags, "dimsuvy")
    var literal = "/" + slashed(pattern) + "/"
    return [
      { title: "Test", language: "javascript", code: "const re = " + literal + jsFlags + "\nconst found = re.test(text)" },
      { title: "Every match with its groups", language: "javascript", code: "const re = " + literal + "g" + jsFlags + "\nfor (const m of text.matchAll(re)) {\n  console.log(m.index, m[0], m.slice(1), m.groups)\n}" },
      { title: "Replace", language: "javascript", code: "const result = text.replace(" + literal + "g" + jsFlags + ", " + doubleQuoted(rep) + ")" },
      { title: "Split", language: "javascript", code: "const parts = text.split(" + literal + jsFlags + ")" },
    ]
  }
  case "pcre2": {
    var mods = flagLetters(flags, "imsxnUJAD") + (has("u") ? "u" : "")
    var p = phpPattern(pattern, mods)
    return [
      { title: "Test (PHP)", language: "php", code: "$found = preg_match(" + p + ", $text) === 1;" },
      { title: "Every match with its groups (PHP)", language: "php", code: "preg_match_all(" + p + ", $text, $matches, PREG_SET_ORDER | PREG_OFFSET_CAPTURE);\nforeach ($matches as $m) {\n    [$whole, $offset] = $m[0];\n}" },
      { title: "Replace (PHP)", language: "php", code: "$result = preg_replace(" + p + ", " + phpSingle(rep) + ", $text);" },
      { title: "Split (PHP)", language: "php", code: "$parts = preg_split(" + p + ", $text);" },
      { title: "Every match (C, libpcre2)", language: "c", code: "#define PCRE2_CODE_UNIT_WIDTH 8\n#include <pcre2.h>\n\nint error;\nPCRE2_SIZE offset;\npcre2_code *re = pcre2_compile((PCRE2_SPTR)" + doubleQuoted(pattern) + ", PCRE2_ZERO_TERMINATED,\n    " + (pcreOptions(flags) || "0") + ", &error, &offset, NULL);\npcre2_match_data *match = pcre2_match_data_create_from_pattern(re, NULL);\nPCRE2_SIZE start = 0;\nwhile (pcre2_match(re, (PCRE2_SPTR)text, length, start, 0, match, NULL) > 0) {\n    PCRE2_SIZE *ovector = pcre2_get_ovector_pointer(match);\n    /* ovector[0]..ovector[1] is the match; 2n, 2n+1 group n */\n    start = ovector[1] > ovector[0] ? ovector[1] : ovector[1] + 1;\n}\npcre2_match_data_free(match);\npcre2_code_free(re);" },
    ]
  }
  case "perl": {
    var perl = perlPattern(pattern)
    var pm = perl.match
    var pf = flagLetters(flags, "imsxna")
    var setup = perl.setup
    var sub = perl.setup === "" && rep.indexOf("'") < 0 ? "s'" + pattern + "'" + rep + "'g" + pf : "s/" + (perl.setup ? "$pattern" : slashed(pattern)) + "/" + rep.replace(/\//g, "\\/") + "/g" + pf
    return [
      { title: "Test", language: "perl", code: setup + "my $found = $text =~ " + pm + pf + ";" },
      { title: "Every match with its groups", language: "perl", code: setup + "while ($text =~ " + pm + "g" + pf + ") {\n    print \"$-[0]: $&\\n\";   # $1, $2 ... and %+ hold the groups\n}" },
      { title: "Replace", language: "perl", code: setup + "(my $result = $text) =~ " + sub + ";" },
      { title: "Split", language: "perl", code: setup + "my @parts = split " + pm + pf + ", $text;" },
    ]
  }
  case "python":
  case "python-regex": {
    var module = f.id === "python" ? "re" : "regex"
    var names = { i: "IGNORECASE", m: "MULTILINE", s: "DOTALL", x: "VERBOSE", a: "ASCII", V1: "VERSION1", r: "REVERSE", b: "BESTMATCH" }
    var pyFlags = flags.filter(function(x) { return names[x] }).map(function(x) { return module + "." + names[x] }).join(" | ")
    var compile = "pattern = " + module + ".compile(" + pythonString(pattern) + (pyFlags ? ", " + pyFlags : "") + ")"
    return [
      { title: "Test", language: "python", code: "import " + module + "\n\n" + compile + "\nfound = pattern.search(text) is not None" },
      { title: "Every match with its groups", language: "python", code: "import " + module + "\n\n" + compile + "\nfor m in pattern.finditer(text):\n    print(m.start(), m.group(), m.groups(), m.groupdict())" },
      { title: "Replace", language: "python", code: "import " + module + "\n\n" + compile + "\nresult = pattern.sub(" + pythonString(rep) + ", text)" },
      { title: "Split", language: "python", code: "import " + module + "\n\n" + compile + "\nparts = pattern.split(text)" },
    ]
  }
  case "ruby": {
    var rl = rubyLiteral(pattern) + flagLetters(flags, "imx")
    return [
      { title: "Test", language: "ruby", code: "found = text.match?(" + rl + ")" },
      { title: "Every match with its groups", language: "ruby", code: "text.scan(" + rl + ") { m = Regexp.last_match; p m.begin(0), m[0], m.captures, m.named_captures }" },
      { title: "Replace", language: "ruby", code: "result = text.gsub(" + rl + ", " + doubleQuoted(rep).replace(/#(?=[{$@])/g, "\\#") + ")" },
      { title: "Split", language: "ruby", code: "parts = text.split(" + rl + ")" },
    ]
  }
  case "dotnet": {
    var opts = { i: "IgnoreCase", m: "Multiline", s: "Singleline", x: "IgnorePatternWhitespace", n: "ExplicitCapture", r: "RightToLeft", e: "ECMAScript", c: "CultureInvariant", b: "NonBacktracking" }
    var csOpts = flags.filter(function(x) { return opts[x] }).map(function(x) { return "RegexOptions." + opts[x] }).join(" | ")
    var ctor = "var regex = new Regex(" + csharpVerbatim(pattern) + (csOpts ? ", " + csOpts : "") + ");"
    return [
      { title: "Test", language: "csharp", code: "using System.Text.RegularExpressions;\n\n" + ctor + "\nbool found = regex.IsMatch(text);" },
      { title: "Every match with its groups", language: "csharp", code: "using System.Text.RegularExpressions;\n\n" + ctor + "\nforeach (Match m in regex.Matches(text))\n{\n    Console.WriteLine($\"{m.Index}: {m.Value}\");\n    foreach (Group g in m.Groups) Console.WriteLine($\"  {g.Name} = {g.Value}\");\n}" },
      { title: "Replace", language: "csharp", code: "using System.Text.RegularExpressions;\n\n" + ctor + "\nstring result = regex.Replace(text, " + csharpVerbatim(rep) + ");" },
      { title: "Split", language: "csharp", code: "using System.Text.RegularExpressions;\n\n" + ctor + "\nstring[] parts = regex.Split(text);" },
    ]
  }
  case "java": {
    var jopts = { i: "CASE_INSENSITIVE", m: "MULTILINE", s: "DOTALL", x: "COMMENTS", u: "UNICODE_CASE", U: "UNICODE_CHARACTER_CLASS", d: "UNIX_LINES" }
    var jFlags = flags.filter(function(x) { return jopts[x] }).map(function(x) { return "Pattern." + jopts[x] }).join(" | ")
    var jc = "Pattern pattern = Pattern.compile(" + doubleQuoted(pattern) + (jFlags ? ", " + jFlags : "") + ");"
    return [
      { title: "Test", language: "java", code: "import java.util.regex.*;\n\n" + jc + "\nboolean found = pattern.matcher(text).find();" },
      { title: "Every match with its groups", language: "java", code: "import java.util.regex.*;\n\n" + jc + "\nMatcher m = pattern.matcher(text);\nwhile (m.find()) {\n    System.out.println(m.start() + \": \" + m.group());\n    for (int g = 1; g <= m.groupCount(); g++) System.out.println(\"  \" + g + \" = \" + m.group(g));\n}" },
      { title: "Replace", language: "java", code: "import java.util.regex.*;\n\n" + jc + "\nString result = pattern.matcher(text).replaceAll(" + doubleQuoted(rep) + ");" },
      { title: "Split", language: "java", code: "import java.util.regex.*;\n\n" + jc + "\nString[] parts = pattern.split(text);" },
    ]
  }
  case "go": {
    var goFlags = flagLetters(flags, "imsU")
    var src = goFlags ? "(?" + goFlags + ")" + pattern : pattern
    var goc = has("L") ? "re := regexp.MustCompilePOSIX(" + goString(src) + ")" : "re := regexp.MustCompile(" + goString(src) + ")"
    return [
      { title: "Test", language: "go", code: "import \"regexp\"\n\n" + goc + "\nfound := re.MatchString(text)" },
      { title: "Every match with its groups", language: "go", code: "import (\n\t\"fmt\"\n\t\"regexp\"\n)\n\n" + goc + "\nfor _, m := range re.FindAllStringSubmatchIndex(text, -1) {\n\tfmt.Println(m[0], text[m[0]:m[1]], m[2:])\n}" },
      { title: "Replace", language: "go", code: "import \"regexp\"\n\n" + goc + "\nresult := re.ReplaceAllString(text, " + goString(rep) + ")" },
      { title: "Split", language: "go", code: "import \"regexp\"\n\n" + goc + "\nparts := re.Split(text, -1)" },
    ]
  }
  case "rust": {
    var builder = "let re = RegexBuilder::new(" + rustRaw(pattern) + ")"
    var rb = { i: "case_insensitive", m: "multi_line", s: "dot_matches_new_line", x: "ignore_whitespace", U: "swap_greed", R: "crlf" }
    flags.forEach(function(x) { if (rb[x]) builder += "\n    ." + rb[x] + "(true)" })
    builder += "\n    .build()\n    .unwrap();"
    var use = "use regex::RegexBuilder;\n\n"
    return [
      { title: "Test", language: "rust", code: use + builder + "\nlet found = re.is_match(text);" },
      { title: "Every match with its groups", language: "rust", code: use + builder + "\nfor caps in re.captures_iter(text) {\n    let whole = caps.get(0).unwrap();\n    println!(\"{}: {}\", whole.start(), whole.as_str());\n}" },
      { title: "Replace", language: "rust", code: use + builder + "\nlet result = re.replace_all(text, " + rustRaw(rep) + ");" },
      { title: "Split", language: "rust", code: use + builder + "\nlet parts: Vec<&str> = re.split(text).collect();" },
    ]
  }
  case "cpp": {
    var cf = "std::regex::ECMAScript" + (has("i") ? " | std::regex::icase" : "") + (has("m") ? " | std::regex::multiline" : "")
    var cc = "const std::regex re(" + cppRaw(pattern) + ", " + cf + ");"
    return [
      { title: "Test", language: "cpp", code: "#include <regex>\n\n" + cc + "\nbool found = std::regex_search(text, re);" },
      { title: "Every match with its groups", language: "cpp", code: "#include <regex>\n\n" + cc + "\nfor (auto it = std::sregex_iterator(text.begin(), text.end(), re); it != std::sregex_iterator(); ++it) {\n    const std::smatch &m = *it;\n    // m.position(0), m.str(0), m[1], m[2] ...\n}" },
      { title: "Replace", language: "cpp", code: "#include <regex>\n\n" + cc + "\nstd::string result = std::regex_replace(text, re, " + doubleQuoted(rep) + ");" },
    ]
  }
  case "posix-ere":
  case "posix-bre": {
    var cflags = (f.id === "posix-ere" ? "REG_EXTENDED" : "0") + (has("i") ? " | REG_ICASE" : "") + (has("n") ? " | REG_NEWLINE" : "")
    return [
      { title: "Every match (C)", language: "c", code: "#include <regex.h>\n\nregex_t re;\nregmatch_t m[10];\nif (regcomp(&re, " + doubleQuoted(pattern) + ", " + cflags + ") == 0) {\n    const char *at = text;\n    while (regexec(&re, at, 10, m, at == text ? 0 : REG_NOTBOL) == 0) {\n        /* at + m[0].rm_so .. at + m[0].rm_eo; m[n] for group n */\n        at += m[0].rm_eo > m[0].rm_so ? m[0].rm_eo : m[0].rm_eo + 1;\n    }\n    regfree(&re);\n}" },
    ]
  }
  case "grep":
  case "grep-e": {
    var gopts = (f.id === "grep-e" ? " -E" : "") + flags.filter(function(x) { return "iwx".indexOf(x) >= 0 }).map(function(x) { return " -" + x }).join("")
    return [
      // -e keeps a pattern that starts with - from reading as options.
      { title: "Lines that match", language: "shell", code: "grep" + gopts + " -e " + shellQuoted(pattern) + " file.txt" },
      { title: "Every match, with its byte offset", language: "shell", code: "grep" + gopts + " -o -b -e " + shellQuoted(pattern) + " file.txt" },
      { title: "Count matching lines", language: "shell", code: "grep" + gopts + " -c -e " + shellQuoted(pattern) + " file.txt" },
    ]
  }
  case "sed":
  case "sed-e": {
    var sflags = "g" + flags.filter(function(x) { return x === "i" || x === "m" }).map(function(x) { return x.toUpperCase() }).join("")
    var script = "s/" + slashed(pattern) + "/" + rep.replace(/\//g, "\\/") + "/" + sflags
    return [
      { title: "Replace", language: "shell", code: "sed" + (f.id === "sed-e" ? " -E" : "") + " " + shellQuoted(script) + " file.txt" },
      { title: "Print only the lines that match", language: "shell", code: "sed" + (f.id === "sed-e" ? " -E" : "") + " -n " + shellQuoted("/" + slashed(pattern) + "/p") + " file.txt" },
    ]
  }
  case "gawk": {
    var lit = "/" + slashed(pattern) + "/"
    var pre = has("i") ? "BEGIN { IGNORECASE = 1 } " : ""
    return [
      { title: "Every match with its groups", language: "shell", code: "gawk " + shellQuoted(pre + "{ s = $0; while (match(s, " + lit + ", m)) { print m[0]; s = substr(s, RSTART + (RLENGTH ? RLENGTH : 1)) } }") + " file.txt" },
      { title: "Replace", language: "shell", code: "gawk " + shellQuoted(pre + "{ gsub(" + lit + ", " + doubleQuoted(rep) + "); print }") + " file.txt" },
      { title: "Split each line", language: "shell", code: "gawk " + shellQuoted(pre + "{ n = split($0, parts, " + lit + "); for (i = 1; i <= n; i++) print parts[i] }") + " file.txt" },
    ]
  }
  case "vim": {
    var vp = (has("i") ? "\\c" : "") + pattern.replace(/\//g, "\\/")
    return [
      { title: "Search", language: "vim", code: "/" + vp },
      { title: "Replace in the whole file", language: "vim", code: ":%s/" + vp + "/" + rep.replace(/\//g, "\\/") + "/g" },
      { title: "From Lua in Neovim", language: "lua", code: "local re = vim.regex(" + luaLong((has("i") ? "\\c" : "") + pattern) + ")\nlocal from, to = re:match_str(line)" },
    ]
  }
  case "lua": {
    var lp = luaLong(pattern)
    return [
      { title: "Find the first match", language: "lua", code: "local from, to = string.find(text, " + lp + ")" },
      { title: "Every match with its captures", language: "lua", code: "for capture in string.gmatch(text, " + lp + ") do\n  print(capture)\nend" },
      { title: "Replace", language: "lua", code: "local result = string.gsub(text, " + lp + ", " + luaLong(rep) + ")" },
    ]
  }
  case "resid": {
    var rflags = flagLetters(flags, "imsx")
    var rsrc = doubleQuoted(rflags ? "(?" + rflags + ")" + pattern : pattern)
    return [
      { title: "Every match with its groups", language: "resid", code: "import \"regex.resid\";\n\nRegex re = regex(" + rsrc + ");\nfor (RegexMatch m in regex_captures_all(re, text)) {\n    println(f\"{m.start}: {regex_text(m, text)}\");\n}" },
      { title: "Replace", language: "resid", code: "import \"regex.resid\";\n\nStr result = regex_replace_all(regex(" + rsrc + "), text, " + doubleQuoted(rep) + ");" },
      { title: "Split", language: "resid", code: "import \"regex.resid\";\n\nList(Str) parts = regex_split(regex(" + rsrc + "), text);" },
    ]
  }
  }
  return []
}

function pcreOptions(flags) {
  var names = { i: "PCRE2_CASELESS", m: "PCRE2_MULTILINE", s: "PCRE2_DOTALL", x: "PCRE2_EXTENDED", n: "PCRE2_NO_AUTO_CAPTURE", U: "PCRE2_UNGREEDY", J: "PCRE2_DUPNAMES", A: "PCRE2_ANCHORED", D: "PCRE2_DOLLAR_ENDONLY" }
  var out = flags.filter(function(f) { return names[f] }).map(function(f) { return names[f] })
  if (flags.indexOf("u") >= 0) out.push("PCRE2_UTF", "PCRE2_UCP")
  return out.join(" | ")
}

if (typeof module !== "undefined") module.exports = {
  snippets: snippets,
  pythonString: pythonString,
  rustRaw: rustRaw,
  cppRaw: cppRaw,
  goString: goString,
  luaLong: luaLong,
  shellQuoted: shellQuoted,
  slashed: slashed,
  perlPattern: perlPattern,
  phpPattern: phpPattern,
}
