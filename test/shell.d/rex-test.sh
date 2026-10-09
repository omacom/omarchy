#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

REX="$ROOT/shell/plugins/rex"

# ---- plugin and launcher ----------------------------------------------------

[[ $(jq -r '.id + " " + .entryPoints.panel' "$REX/manifest.json") == "omarchy.rex Rex.qml" ]] ||
  fail "the Rex manifest declares its id and panel entry point"
[[ -f $REX/Rex.qml ]] || fail "the Rex panel entry point exists"
pass "the Rex manifest declares its id and panel entry point"

grep -qx 'Exec=omarchy-launch-rex' "$ROOT/applications/Rex.desktop" &&
  grep -qx 'Icon=rex' "$ROOT/applications/Rex.desktop" &&
  [[ -f $ROOT/applications/icons/Rex.png ]] ||
  fail "Rex is listed under Apps with its own icon"
pass "Rex is listed under Apps with its own icon"

stubs="$tmpdir/bin"
mkdir -p "$stubs"
cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
SH
cat >"$stubs/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  printf '%s\n' "${CLIENTS:-[]}"
else
  printf 'hyprctl %s\n' "$*" >>"$CALLS"
fi
SH
cat >"$stubs/update-desktop-database" <<'SH'
#!/bin/bash
SH
chmod +x "$stubs"/*

launch() {
  : >"$tmpdir/calls"
  PATH="$stubs:$PATH" CALLS="$tmpdir/calls" "$ROOT/bin/omarchy-launch-rex" "$@"
}

launch
[[ $(<"$tmpdir/calls") == "shell summon omarchy.rex {}" ]] ||
  fail "launching Rex summons the plugin" "$(<"$tmpdir/calls")"
pass "launching Rex summons the plugin"

launch 'a "quoted" \d+'
[[ $(<"$tmpdir/calls") == 'shell summon omarchy.rex {"pattern":"a \"quoted\" \\d+"}' ]] ||
  fail "a pattern argument reaches Rex as JSON" "$(<"$tmpdir/calls")"
pass "a pattern argument reaches Rex as JSON"

CLIENTS='[{"class":"org.quickshell","title":"Rex","address":"0xabc"}]' launch
grep -q 'address:0xabc' "$tmpdir/calls" && ! grep -q summon "$tmpdir/calls" ||
  fail "launching Rex again focuses the open window" "$(<"$tmpdir/calls")"
pass "launching Rex again focuses the open window"

# ---- migration --------------------------------------------------------------

migration_home="$tmpdir/home"
mkdir -p "$migration_home"
for _ in 1 2; do
  HOME="$migration_home" OMARCHY_PATH="$ROOT" PATH="$stubs:$PATH" bash -euo pipefail "$ROOT/migrations/1791578053.sh" >/dev/null
done
cmp -s "$migration_home/.local/share/applications/Rex.desktop" "$ROOT/applications/Rex.desktop" ||
  fail "the migration adds Rex to Apps on existing installs"
pass "the migration adds Rex to Apps on existing installs"

# ---- parser -----------------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const P = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Parser.js'))
const Flavors = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Flavors.js'))

// A compact rendering of the AST, so expectations read like the pattern.
function show(n) {
  switch (n.type) {
  case 'literal': return JSON.stringify(String.fromCodePoint(n.value))
  case 'sequence': return '(' + n.items.map(show).join(' ') + ')'
  case 'alternation': return '(alt ' + n.alternatives.map(show).join(' | ') + ')'
  case 'group': return '(' + n.kind + (n.index ? '#' + n.index : '') + (n.name ? ':' + n.name : '') + ' ' + show(n.body) + ')'
  case 'quantifier': return '{' + n.min + ',' + (n.max < 0 ? 'inf' : n.max) + ' ' + n.mode + ' ' + show(n.body) + '}'
  case 'class': return '[' + (n.negated ? '^' : '') + n.items.map(show).join(' ') + ']'
  case 'range': return show(n.from) + '-' + show(n.to)
  case 'setop': return '(' + show(n.left) + ' ' + n.op + ' ' + show(n.right) + ')'
  case 'chartype': return (n.negated ? '!' : '') + n.kind
  case 'anchor': return '@' + n.kind
  case 'backref': return '\\' + n.ref
  case 'recursion': return '(?' + n.ref + ')'
  case 'property': return (n.negated ? '!' : '') + 'p:' + n.name
  case 'posixclass': return ':' + n.name + ':'
  case 'quote': return 'Q' + n.items.map(show).join('')
  default: return n.type
  }
}

function parses(pattern, flavor, expected, flags) {
  const r = P.parse(pattern, flavor, flags || [])
  const errors = r.errors.map(e => e.message).join('; ')
  if (errors) fail(`${flavor} parses ${pattern}`, errors)
  assertEqual(show(r.ast), expected, `${flavor} parses ${pattern}`)
}

function rejects(pattern, flavor, message, span) {
  const r = P.parse(pattern, flavor, [])
  const e = r.errors.find(e => e.message.includes(message))
  assert(e, `${flavor} rejects ${pattern}: ${message}`, r.errors.map(e => e.message).join('; ') || 'no errors')
  if (span) assertDeepEqual([e.start, e.end], span, `${flavor} points at the right part of ${pattern}`)
}

for (const flavor of Flavors.FLAVORS) {
  const r = P.parse('', flavor.id, [])
  assert(r.ast.type === 'empty' && r.errors.length === 0, `${flavor.id} parses the empty pattern`)
}

parses('(\\d{3})-(?<x>\\w+)\\k<x>', 'pcre2', '((capture#1 {3,3 greedy digit}) "-" (named#2:x {1,inf greedy word}) \\x)')
parses('[a-z\\d_-]+?', 'pcre2', '{1,inf lazy ["a"-"z" digit "_" "-"]}')
parses('(?|(a)|(b))\\1', 'pcre2', '((branchReset (alt (capture#1 "a") | (capture#1 "b"))) \\1)')
parses('\\Qa.b\\E+', 'pcre2', '(Q"a""." {1,inf greedy "b"})')
parses('(?x) a b # comment\n c', 'pcre2', '(flags "a" "b" "c")')
parses('(a)(?1)(?R)', 'pcre2', '((capture#1 "a") (?1) (?0))')
parses('[[:^alpha:]]', 'pcre2', '[:alpha:]')
parses('(?i:a)', 'node', '(flags "a")')
parses('[\\p{L}--[a-z]]', 'node', '[([p:L] -- ["a"-"z"])]', ['v'])
parses('[a-z&&[^aeiou]]', 'java', '[(["a"-"z"] && [^"a" "e" "i" "o" "u"])]')
parses('(?P<n>x)(?P=n)', 'python', '((named#1:n "x") \\n)')
parses('(?<=ab|cd)e', 'python', '((lookbehind (alt ("a" "b") | ("c" "d"))) "e")')
parses('(?<a>x)(y)', 'dotnet', '((named#2:a "x") (capture#1 "y"))')
parses('[a-z-[aeiou]]', 'dotnet', '[(["a"-"z"] net ["a" "e" "i" "o" "u"])]')
parses('\\u{1F600}', 'node', '"😀"', ['u'])
parses('\\h+', 'ruby', '{1,inf greedy hex}')
parses('\\(a\\)\\1*', 'posix-bre', '((capture#1 "a") {0,inf greedy \\1})')
parses('a+(b|c)?', 'posix-bre', '("a" "+" "(" "b" "|" "c" ")" "?")')
parses('a\\{2,3\\}', 'posix-bre', '{2,3 greedy "a"}')
parses('(a|b)+$', 'posix-ere', '({1,inf greedy (capture#1 (alt "a" | "b"))} @lineEnd)')
parses('\\v(a|b)+\\1', 'vim', '(flags {1,inf greedy (capture#1 (alt "a" | "b"))} \\1)')
parses('\\(foo\\)\\@<=bar\\{-1,}', 'vim', '((lookbehind (capture#1 ("f" "o" "o"))) "b" "a" {1,inf lazy "r"})')
parses('%d+%s-(%a+)', 'lua', '({1,inf greedy digit} {0,inf lazy space} (capture#1 {1,inf greedy alpha}))')
parses('^%b()$', 'lua', '(@start balanced @end)')

rejects('(?<=a+)b', 'pcre2', 'bounded length', [0, 7])
rejects('(?<=ab|c)d', 'python', 'same fixed length')
rejects('(?<=a)b', 'go', 'does not support lookbehind')
rejects('(a)\\1', 'rust', 'does not support backreferences')
rejects('a++', 'node', 'does not support possessive quantifiers', [2, 3])
rejects('a(?i)b', 'python', 'only accepts global flags')
rejects('(a)\\2', 'pcre2', 'no group 2', [3, 5])
rejects('\\k<nope>', 'pcre2', "No group is named 'nope'")
rejects('a{3,1}', 'pcre2', 'maximum is less than its minimum')
rejects('a{1001}', 'go', 'above 1000')
rejects('*a', 'pcre2', 'nothing to repeat', [0, 1])
rejects('(a', 'pcre2', 'Missing closing parenthesis')
rejects('a)', 'pcre2', 'Unmatched closing parenthesis', [1, 2])
rejects('[abc', 'pcre2', 'missing its closing ]')
rejects('[z-a]', 'python', 'out of order')
rejects('\\q', 'python', 'not a valid escape')
rejects('(?<a>x)(?<a>y)', 'pcre2', 'already used')
rejects('\\p{L}', 'python', 'not a valid escape')
parses('\\p{L}', 'ecmascript', '("p" "{" "L" "}")')

rejects('%q', 'lua', 'not a Lua character class')

assertDeepEqual(P.width(P.parse('ab?c{2,3}', 'pcre2', []).ast), { min: 3, max: 5 }, 'width counts quantified spans')
assertDeepEqual(P.width(P.parse('a|bcd*', 'pcre2', []).ast), { min: 1, max: -1 }, 'width of an unbounded alternative is unbounded')
JS

# ---- group positions for engines without them -------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const P = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Parser.js'))
const I = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Indices.js'))

// V8's d flag knows where every group matched; the rewrite has to agree
// with it on every match, and match exactly what the original matches.
function agrees(pattern, text) {
  const parsed = P.parse(pattern, 'ecmascript', [])
  if (parsed.errors.length) return `parse error: ${parsed.errors[0].message}`
  const { source, plan } = I.rewrite(pattern, parsed)
  const rewritten = new RegExp(source, 'g'), reference = new RegExp(pattern, 'gd')
  let r
  while ((r = reference.exec(text)) !== null) {
    const m = rewritten.exec(text)
    if (!m) return `the rewrite ${source} misses a match`
    const got = JSON.stringify(I.locate(m, plan, parsed.groupCount))
    const want = JSON.stringify(r.indices.flatMap(x => x || [-1, -1]))
    if (got !== want) return `${source} on ${JSON.stringify(text)}: ${got}, expected ${want}`
    if (r[0] === '') { reference.lastIndex++; rewritten.lastIndex++ }
  }
  return rewritten.exec(text) === null ? '' : `the rewrite ${source} finds an extra match`
}

const fixed = [
  ['(a)(a)', 'aa'], ['x(a|ab)(c|bcd)(d*)', 'xabcd'], ['(?:(a)|b)+', 'aab'], ['(a(b)?)+', 'ababa'],
  ['(\\d+)-(?<y>\\d+)\\1', '12-34 5-6-5'], ['(a*)*b', 'aaab'], ['(?=(a+))a*b\\1', 'baaabac'],
  ['(z)((a+)?(b+)?(c))*', 'zaacbbbcac'], ['(.)\\1{2}', 'xaaay'], ['()', 'a'], ['(?<a>.)(?<b>.)\\k<a>', 'xyx'],
]
for (const [pattern, text] of fixed) {
  const problem = agrees(pattern, text)
  if (problem) fail(`group positions for ${pattern} agree with V8`, problem)
}
pass('group positions agree with V8 on hand-picked patterns')

// Random patterns from a small grammar, with a fixed seed.
let seed = 12345
const random = n => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed % n }
function gen(depth) {
  const pick = random(depth > 2 ? 4 : 9)
  if (pick < 4) return ['a', 'b', '[ab]', '.'][random(4)]
  if (pick === 4) return '(' + gen(depth + 1) + ')'
  if (pick === 5) return '(?:' + gen(depth + 1) + '|' + gen(depth + 1) + ')'
  if (pick === 6) return gen(depth + 1) + ['*', '+', '?', '{1,2}', '*?'][random(5)]
  if (pick === 7) return '(' + gen(depth + 1) + gen(depth + 1) + ')'
  return gen(depth + 1) + gen(depth + 1)
}
for (let i = 0; i < 400; i++) {
  let pattern = gen(0)
  if (/^[*+?{]/.test(pattern)) continue
  const text = Array.from({ length: 12 }, () => 'abba'[random(4)]).join('')
  const problem = agrees(pattern, text)
  if (problem && !problem.startsWith('parse error')) fail('group positions agree with V8 on random patterns', `${pattern}: ${problem}`)
}
pass('group positions agree with V8 on random patterns')
JS

# ---- engine workers ---------------------------------------------------------

# Each case runs on the real engine: [worker, flavor, pattern, flags, text,
# expected matches, group count]. Offsets are UTF-16 code units, so the
# accented and astral characters check every worker's conversion. The tools
# and Vim only report group text, so they are told how many groups there are.
worker_cases='[
  ["python", "python", "(\\w)(?P<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["python", "pcre2", "(\\w)(?<n>é|😀)?", ["u"], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["python", "pcre2", "x*", ["u"], "aé", [0,0,1,1,2,2]],
  ["python", "pcre2", "(?<=é)\\w", ["u"], "aéb", [2,3]],
  ["python", "posix-ere", "([a-z])(é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["python", "posix-bre", "\\(a\\)\\1", [], "xaay", [1,3,1,2]],
  ["perl", "perl", "(\\w)(?<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["perl", "perl", "(a)|(b)", [], "ba", [0,1,-1,-1,0,1,1,2,1,2,-1,-1]],
  ["ruby", "ruby", "(\\w)(é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["ruby", "ruby", "(\\w)(?<n>é|😀)?", [], "aé b😀 c", [0,2,1,2,3,6,4,6,7,8,-1,-1]],
  ["lua", "lua", "(%a)%1", [], "xaay", [1,3,1,2]],
  ["lua", "lua", "%b()", [], "x(a(b)c)y()", [1,8,9,11]],
  ["lua", "lua", "()é", [], "aéé", [1,2,1,1,2,3,2,2]],
  ["python", "grep-e", "[a-z]+é?", [], "aé b😀 cé\nxyz", [0,2,3,4,7,9,10,13]],
  ["python", "grep", "a\\|é", ["i"], "Aé", [0,1,1,2]],
  ["python", "sed-e", "([a-z])(é)", [], "aé b😀 cé", [0,2,0,1,1,2,7,9,7,8,8,9], 2],
  ["python", "sed", "x*", [], "ab", [0,0,1,1,2,2]],
  ["python", "gawk", "([a-z])(é)?", [], "aé b😀\nc", [0,2,0,1,1,2,3,4,3,4,-1,-1,7,8,7,8,-1,-1], 2],
  ["vim", "vim", "\\v(\\w)(é)", [], "aé b😀 cé", [0,2,0,1,1,2,7,9,7,8,8,9], 2],
  ["vim", "vim", "a\\nb", [], "xa\nbc", [1,4]],
  ["vim", "vim", "foo\\zsbar", [], "foobar", [3,6]],
  ["node", "node", "(\\w)(?<n>é|😀)?", ["u"], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["node", "node", "(?<=a)b(c)?", [], "ab", [1,2,-1,-1]],
  ["go", "go", "(\\w)(?P<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["rust", "rust", "(\\w)(?P<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["java", "java", "(\\w)(?<n>é|😀)?", ["U"], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["dotnet", "dotnet", "(\\w)(?<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["dotnet", "dotnet", "(?<a>x)(y)", [], "xy", [0,2,1,2,0,1]],
  ["cpp", "cpp", "(\\w)(é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["resid", "resid", "(\\w)(?P<n>é|😀)?", [], "aé b😀 c", [0,2,0,1,1,2,3,6,3,4,4,6,7,8,7,8,-1,-1]],
  ["resid", "resid", "\\\\|\\n", [], "a\\b\nc", [1,2,3,4]]
]'

# Compiled workers build into a throwaway cache rather than the developer's.
export XDG_CACHE_HOME="$tmpdir/cache"
declare -A worker_command=([python]=python3 [perl]=perl [ruby]=ruby [lua]=lua5.1 [vim]=nvim [node]=node [go]=go [rust]=cargo [java]=javac [dotnet]=dotnet [cpp]=g++ [resid]=residc)
for worker in python perl ruby lua vim node go rust java dotnet cpp resid; do
  if [[ $worker == "dotnet" ]] && command -v dotnet >/dev/null && [[ -z $(dotnet --list-sdks 2>/dev/null) ]]; then
    skip "the dotnet worker reports matches in UTF-16 offsets (no .NET SDK to build it)"
    continue
  fi
  if ! command -v "${worker_command[$worker]}" >/dev/null; then
    skip "the $worker worker reports matches in UTF-16 offsets (${worker_command[$worker]} is not installed)"
    continue
  fi
  requests=$(jq -c --arg worker "$worker" 'to_entries[] | select(.value[0] == $worker) | {op: "match", id: .key, flavor: .value[1], pattern: .value[2], flags: .value[3], text: .value[4], textId: .key, groups: (.value[6] // 0)}' <<<"$worker_cases")
  replies=$(OMARCHY_PATH="$ROOT" timeout 300 "$ROOT/bin/omarchy-rex-worker" "$worker" <<<"$requests" | grep -v '^{"building"')
  if [[ $replies == *buildError* && $worker == "rust" && $replies == *"--fetch rust"* ]]; then
    skip "the rust worker reports matches in UTF-16 offsets (the regex crate is not in Cargo's cache)"
    continue
  fi
  while IFS= read -r reply; do
    id=$(jq -r .id <<<"$reply")
    expected=$(jq -c ".[$id][5]" <<<"$worker_cases")
    actual=$(jq -c .matches <<<"$reply")
    [[ $actual == "$expected" ]] ||
      fail "the $worker worker reports matches in UTF-16 offsets" "$(jq -c ".[$id][1:5]" <<<"$worker_cases"): expected $expected, got $reply"
  done <<<"$replies"
  [[ $(grep -c . <<<"$replies") == $(grep -c . <<<"$requests") ]] || fail "the $worker worker answers every request" "$replies"
  pass "the $worker worker reports matches in UTF-16 offsets"
done

# A pattern that would create a file if Perl ran the code inside it.
marker="$tmpdir/perl-ran-code"
request=$(jq -cn --arg marker "$marker" '{op: "match", id: 1, flavor: "perl", pattern: ("(?{ open(my $f, \">\", \"" + $marker + "\") })x"), flags: [], text: "x", textId: 1}')
reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" perl <<<"$request")
[[ $(jq -r .ok <<<"$reply") == "false" && ! -e $marker ]] || fail "the Perl worker refuses code in patterns" "$reply"
pass "the Perl worker refuses code in patterns"

reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python <<<'{"op":"match","id":1,"flavor":"pcre2","pattern":"(","flags":[],"text":"x","textId":1}')
[[ $(jq -r '.ok, .error' <<<"$reply" | tr '\n' ' ') == "false missing closing parenthesis " ]] || fail "a worker reports the engine's own error" "$reply"
pass "a worker reports the engine's own error"

reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python <<<'{"op":"match","id":1,"flavor":"python","pattern":"a","flags":[],"textId":9}')
[[ $(jq -r .error <<<"$reply") == "missing-text" ]] || fail "a worker asks again for a text it does not hold" "$reply"
pass "a worker asks again for a text it does not hold"

# ---- replacement templates and split ----------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const R = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Replace.js'))

// Matches as an engine reports them, from V8 with the d flag.
function engine(pattern, text) {
  const re = new RegExp(pattern, 'gd')
  const out = []
  let m, count = 0, stride = 2
  while ((m = re.exec(text)) !== null) {
    stride = m.length * 2
    for (const pair of m.indices) out.push(...(pair || [-1, -1]))
    count++
    if (m[0] === '') re.lastIndex++
  }
  const names = {}
  let index = 0
  pattern.replace(/\\.|\((\?<(\w+)>|(?!\?))/g, (all, open, name) => { if (open !== undefined) { index++; if (name) names[name] = index } })
  return { matches: out, count, stride: count ? stride : 2, names }
}

function substitutes(syntax, pattern, template, text, expected) {
  const e = engine(pattern, text)
  const parsed = R.parse(template, syntax, e.stride / 2 - 1, e.names)
  if (parsed.errors.length) fail(`${syntax} expands ${template}`, parsed.errors.map(x => x.message).join('; '))
  assertEqual(R.substitute(parsed, text, e.matches, e.count, e.stride, e.names).text, expected, `${syntax} expands ${template} like the language does`)
}

// Each expectation is what the language itself produces.
const text = 'John Smith, Jane Doe'
const pattern = '(?<first>\\w+) (\\w+)'
substitutes('js', pattern, '$2 $1 [$&] $<first> $$ $3', text, text.replace(new RegExp(pattern, 'g'), '$2 $1 [$&] $<first> $$ $3'))
substitutes('js', '(a)', "$`|$'", 'xay', 'xx|yy')
substitutes('python', '(?<first>\\w+) (\\w+)', '\\2 \\g<1> \\g<first>\\n', text, 'Smith John John\n, Doe Jane Jane\n')
substitutes('ruby', '(?<first>\\w+) (\\w+)', '\\2 \\k<first> \\0', text, 'Smith John John Smith, Doe Jane Jane Doe')
substitutes('dotnet', '(?<first>\\w+) (\\w+)', '$2 ${first} $+ $$', text, 'Smith John Smith $, Doe Jane Doe $')
substitutes('java', '(?<first>\\w+) (\\w+)', '$2 ${first} \\$', text, 'Smith John $, Doe Jane $')
substitutes('go', '(?<first>\\w+) (\\w+)', '$2 ${first} $1x $$', text, 'Smith John  $, Doe Jane  $')
substitutes('pcre2', '(?<first>\\w+) (\\w+)', '\\U$2\\E ${first} \\1', text, 'SMITH John John, DOE Jane Jane')
substitutes('perl', '(?<first>\\w+) (\\w+)', '\\u\\L$2\\E $+{first} $&', text, 'Smith John John Smith, Doe Jane Jane Doe')
substitutes('sed', '(\\w+) (\\w+)', '\\2 & \\&', text, 'Smith John Smith &, Doe Jane Doe &')
substitutes('awk', '(\\w+) (\\w+)', '[&] \\&', text, '[John Smith] &, [Jane Doe] &')
substitutes('vim', '(\\w+) (\\w+)', '\\u\\2 \\U\\1\\E \\0', 'john smith', 'Smith JOHN john smith')
substitutes('lua', '(\\w+) (\\w+)', '%2 %1 %% %0', text, 'Smith John % John Smith, Doe Jane % Jane Doe')
substitutes('lua', '\\w+', '<%1>', 'ab cd', '<ab> <cd>')
substitutes('resid', '(?<first>\\w+) (\\w+)', '$2 ${first} $$', text, 'Smith John $, Doe Jane $')

const java = R.parse('$9', 'java', 1, {})
assert(java.errors.length === 1, 'Java rejects a reference to a missing group')
const python = R.parse('\\q', 'python', 0, {})
assert(python.errors.length === 1, 'Python rejects an unknown escape in a replacement')

function splits(syntax, pattern, text, expected) {
  const e = engine(pattern, text)
  const pieces = R.split(syntax, text, e.matches, e.count, e.stride).map(p => p.text)
  assertDeepEqual(pieces, expected, `${syntax} splits ${JSON.stringify(text)} on /${pattern}/ like the language does`)
}

splits('js', 'x*', 'abc', 'abc'.split(/x*/))
splits('js', '(,)', 'a,b,', 'a,b,'.split(/(,)/))
splits('python', 'x*', 'abc', ['', 'a', 'b', 'c', ''])
splits('python', '(,)', 'a,b,', ['a', ',', 'b', ',', ''])
splits('java', ',', 'a,b,,', ['a', 'b'])
splits('perl', '(,)', 'a,b,,', ['a', ',', 'b', ',', '', ','])
splits('ruby', ',', 'a,b,,', ['a', 'b'])
splits('java', ',', ',a', ['', 'a'])
splits('java', 'x*', 'abc', ['a', 'b', 'c'])
splits('pcre2', ',', 'a,b,,', ['a', 'b', '', ''])
JS

# A file opened in Rex is read by the worker itself.
printf 'aé b😀\nc' >"$tmpdir/opened.txt"
declare -A path_flavor=([python]=pcre2 [perl]=perl [ruby]=ruby [lua]=lua [vim]=vim [node]=node [go]=go [rust]=rust [java]=java [dotnet]=dotnet [cpp]=cpp [resid]=resid)
declare -A path_pattern=([lua]='%a' [vim]='\a')
for worker in python perl ruby lua vim node go rust java dotnet cpp resid; do
  command -v "${worker_command[$worker]}" >/dev/null || continue
  [[ $worker == "dotnet" && -z $(dotnet --list-sdks 2>/dev/null) ]] && continue
  pattern=${path_pattern[$worker]:-[a-z]}
  request=$(jq -cn --arg flavor "${path_flavor[$worker]}" --arg path "$tmpdir/opened.txt" --arg pattern "$pattern" '{op: "match", id: 1, flavor: $flavor, pattern: $pattern, flags: [], textPath: $path, textId: 7}')
  reply=$(OMARCHY_PATH="$ROOT" timeout 300 "$ROOT/bin/omarchy-rex-worker" "$worker" <<<"$request" | grep -v '^{"building"')
  [[ $(jq -c .matches <<<"$reply") == "[0,1,3,4,7,8]" ]] || fail "the $worker worker reads an opened file itself" "$reply"
done
pass "workers read an opened file themselves"

# ---- large texts --------------------------------------------------------------

run_node_test <<'JS'
const fs = require('fs')
// rows.js is a WorkerScript; stand in for the WorkerScript object it uses.
let reply
const WorkerScript = { sendMessage: r => { reply = r } }
new Function('WorkerScript', fs.readFileSync(path.join(root, 'shell/plugins/rex/workers/rows.js'), 'utf8'))(WorkerScript)

WorkerScript.onMessage({ id: 1, text: 'ab\ncd\n\nef' })
assertDeepEqual([reply.starts, reply.lines], [[0, 3, 6, 7], [1, 2, 3, 4]], 'rows start at every line')

const long = 'x'.repeat(4500) + '\ny'
WorkerScript.onMessage({ id: 2, text: long })
assertDeepEqual([reply.starts, reply.lines], [[0, 2000, 4000, 4501], [1, 0, 0, 2]], 'a long line is cut into rows that continue it')

const astral = 'x'.repeat(1999) + '😀' + 'z'
WorkerScript.onMessage({ id: 3, text: astral })
assertDeepEqual(reply.starts, [0, 1999], 'a row never ends inside a surrogate pair')
JS

# ---- explanations -------------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const P = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Parser.js'))
const E = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Explain.js'))
const Flavors = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Flavors.js'))

function titles(pattern, flavor, flags = []) {
  return E.explain(P.parse(pattern, flavor, flags), flags).map(r => '  '.repeat(r.depth) + r.title)
}

assertDeepEqual(titles('^(?<y>\\d{4})+?$', 'pcre2'), [
  'Start of the text',
  'One or more times',
  '  Named capturing group 1',
  '    Exactly 4 times',
  '      A digit',
  'End of the text',
], 'a pattern is explained as a tree in reading order')

const multiline = E.explain(P.parse('^a$', 'pcre2', ['m']), ['m'])
assertEqual(multiline[0].title, 'Start of a line', 'the m flag changes what ^ means')
const ruby = E.explain(P.parse('^', 'ruby', []), [])
assertEqual(ruby[0].title, 'Start of a line', "Ruby's ^ always means a line")
const digit = (flavor, flags) => E.explain(P.parse('\\d', flavor, flags), flags)[0].detail
assert(digit('python', []).includes('Unicode-aware'), "Python 3's \\d is Unicode-aware")
assert(digit('node', []).includes('ASCII only'), "JavaScript's \\d is ASCII only")
assert(digit('pcre2', []).includes('ASCII only') && digit('pcre2', ['u']).includes('Unicode-aware'), "PCRE2's \\d follows UCP")

// Every flavor's tokens stay inside the pattern and never overlap, so the
// pattern editor's tints never stack.
const samples = ['(a|b)*c[^d-f]\\w+(?=x)\\1', '%d+(%a-)%b()', '\\(ab\\)\\{2\\}', '\\v(a|b)+\\@=', '(?P<n>x)(?P=n)']
for (const flavor of Flavors.FLAVORS) {
  for (const pattern of samples) {
    const tokens = E.tokens(P.parse(pattern, flavor.id, []))
    let at = 0
    for (const t of tokens) {
      if (t.start < at || t.end > pattern.length || t.end <= t.start)
        fail(`${flavor.id} tokens for ${pattern} stay apart`, JSON.stringify(tokens))
      at = t.end
    }
  }
}
pass('pattern tokens never overlap in any flavor')
JS

# ---- comparing flavors --------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const C = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Compare.js'))
const result = (matches, stride) => ({ ok: true, matches, stride, count: matches.length / stride })

assertEqual(C.compare(result([0, 2, 0, 1], 4), result([0, 2, 0, 1], 4)).verdict, 'same', 'identical matches compare the same')
assertEqual(C.compare(result([0, 2, 0, 1], 4), result([0, 2, 1, 2], 4)).verdict, 'groups', 'differing groups are told apart from differing matches')
const different = C.compare(result([0, 2, 5, 7], 2), result([0, 2, 5, 8], 2))
assertDeepEqual([different.verdict, different.firstDifference], ['different', 1], 'the first differing match is found')
assertEqual(C.compare(result([0, 2], 2), result([0, 2, 5, 7], 2)).detail, '2 matches instead of 1', 'extra matches are counted')
assertEqual(C.compare(result([], 2), { ok: false, error: 'bad' }).verdict, 'error', 'a flavor that rejects the pattern is an error')
JS

# ---- the PCRE2 debugger -------------------------------------------------------

reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python <<<'{"op":"debug","id":1,"flavor":"pcre2","pattern":"a+b","flags":["u"],"text":"xaab","textId":1}')
[[ $(jq -c '[.match, (.steps | length), .steps[0][0:5], .steps[1][4]]' <<<"$reply") == '[[1,4],4,[0,0,0,2,1],3]' ]] ||
  fail "the debugger reports PCRE2's steps, attempts, and backtracks" "$reply"
pass "the debugger reports PCRE2's steps, attempts, and backtracks"

reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python <<<'{"op":"debug","id":1,"flavor":"pcre2","pattern":"(a+)+b","flags":[],"text":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","textId":1}')
[[ $(jq -r '.stopped' <<<"$reply") == "true" && $(jq '.steps | length' <<<"$reply") == 200000 ]] ||
  fail "the debugger stops a runaway pattern after a fixed number of steps" "$(jq -c '{stopped, limit, n: (.steps | length)}' <<<"$reply")"
pass "the debugger stops a runaway pattern after a fixed number of steps"

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const D = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Debug.js'))
const steps = [[0, 0, 0, 2, 1], [1, 1, 0, 2, 3], [1, 3, 2, 1, 0], [1, 4, 3, 0, 0]]
assertEqual(D.describe(steps[1], 'a+b', 'xaab'), 'Try a+ at 1, facing "a" (new attempt from 1, after backtracking)', 'a step says what the engine tries and why')
assertEqual(D.describe(steps[3], 'a+b', 'xaab'), 'End of the pattern: a match', 'reaching the end of the pattern is a match')
assertDeepEqual(D.hotspots(steps).map(h => [h.start, h.count, h.backtracks]), [[0, 2, 1], [2, 1, 0]], 'the busiest items come first')
assertDeepEqual(D.attempts(steps), [0, 1], 'each new attempt is found')
assertEqual(D.summary({ match: [1, 4] }, steps), 'A match at 1–4 after 4 steps', 'the summary says where the match is')
JS

# ---- the optimizer --------------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const A = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Analyze.js'))
const find = (pattern, flavor, id, flags = []) => A.analyze(pattern, flavor, flags).find(f => f.id === id)

const nested = find('(a+)+b', 'pcre2', 'nested-quantifier')
assert(nested && nested.severity === 'danger', 'nested repetition is catastrophic')
assertEqual(nested.rewrite, '(a++)+b', 'PCRE2 gets a possessive fix')
assertEqual(A.witness(nested, 4), 'aaaa!', 'the witness repeats what both repetitions match, then fails')
assertEqual(find('(?:a+)+b', 'python', 'nested-quantifier').rewrite, 'a+b', 'a redundant outer repetition collapses')
assertEqual(find('(\\w+\\s?)*$', 'node', 'nested-quantifier').rewrite, '', 'JavaScript has no possessive fix to offer')
assert(!find('(a+)+b', 'go', 'nested-quantifier'), 'linear-time engines have no backtracking risk')
assert(find('(a|ab)*c', 'java', 'overlapping-alternation'), 'overlapping repeated alternatives are a risk')
assert(!find('(a|b)*c', 'java', 'overlapping-alternation'), 'exclusive alternatives are not')
assert(find('\\d+\\d+x', 'perl', 'adjacent-quantifiers'), 'competing repetitions are flagged')
assertEqual(find('\\d+[a-z]', 'java', 'possessive').rewrite, '\\d++[a-z]', 'a repetition that can never give back usefully becomes possessive')
assertEqual(find('\\d+[a-z]', 'dotnet', 'possessive').rewrite, '(?>\\d+)[a-z]', '.NET gets an atomic group instead')
assert(!find('\\w+[a-z]', 'java', 'possessive'), 'not when what follows overlaps')
assertEqual(find('".*?"', 'python', 'lazy-dot').rewrite, '"[^"\\n]*"', 'a lazy dot before a delimiter becomes a negated class')
assertEqual(find('(?:a|b|c)', 'pcre2', 'alternation-to-class').rewrite, '[abc]', 'single-character alternatives become a class')
assertEqual(find('(?:foo|fob)', 'pcre2', 'common-prefix').rewrite, 'fo(?:o|b)', 'a shared prefix is factored out')
assertEqual(find('a{0,1}', 'pcre2', 'quantifier-shorthand').rewrite, 'a?', '{0,1} is ?')
assertEqual(find('[^\\s]', 'pcre2', 'negated-shorthand').rewrite, '\\S', '[^\\s] is \\S')
assert(!find('[0-9]', 'python', 'digit-class'), "[0-9] is not \\d in Python, where \\d is Unicode")
assertEqual(find('[0-9]', 'node', 'digit-class').rewrite, '\\d', '[0-9] is \\d in JavaScript')
assertEqual(A.analyze('(', 'pcre2', []).length, 0, 'a pattern with errors is not reviewed')
JS

# ---- benchmarks -------------------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const B = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Bench.js'))
assertEqual(B.median([5, 1, 3]), 3, 'the median of an odd count is the middle time')
assertEqual(B.median([4, 1, 3, 2]), 2.5, 'the median of an even count averages the middle two')
const ranked = B.rank([
  { flavor: 'slow', median: 10, error: '' },
  { flavor: 'broken', median: null, error: 'bad' },
  { flavor: 'fast', median: 2, error: '' },
])
assertDeepEqual(ranked.map(r => [r.flavor, r.share]), [['fast', 0.2], ['slow', 1], ['broken', 0]], 'the fastest come first, failures last')
JS

# Toolchains installed under the home directory are found without the
# interactive shell's PATH, which the desktop session never sees.
fake_home="$tmpdir/resid-home"
mkdir -p "$fake_home/.resid/bin"
printf '#!/bin/bash\n' >"$fake_home/.resid/bin/residc"
chmod +x "$fake_home/.resid/bin/residc"
flavors=$(env -i HOME="$fake_home" PATH="$ROOT/bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" --flavors)
grep -qx resid <<<"$flavors" || fail "Resid is found in its own install directory" "$flavors"
pass "Resid is found in its own install directory"

# ---- unit tests for patterns --------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const T = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Tests.js'))
const reply = (matches, stride) => ({ ok: true, matches, stride })
const t = (text, expect, group, value) => T.normalize({ text, expect, group, value })

assert(T.evaluate(t('xab', 'match'), reply([1, 3], 2)).pass, 'a match anywhere passes "matches"')
assert(!T.evaluate(t('xab', 'nomatch'), reply([1, 3], 2)).pass, 'a match fails "does not match"')
assert(T.evaluate(t('xab', 'nomatch'), reply([], 2)).pass, 'no match passes "does not match"')
assert(!T.evaluate(t('xab', 'full'), reply([1, 3], 2)).pass, 'a partial match fails "matches all of it"')
assert(T.evaluate(t('ab', 'full'), reply([0, 2], 2)).pass, 'a whole match passes "matches all of it"')
assert(T.evaluate(t('ab', 'group', 'n', 'b'), reply([0, 2, 1, 2], 4), { n: 1 }).pass, 'a named group capturing the value passes')
assertEqual(T.evaluate(t('ab', 'group', '2', 'b'), reply([0, 2, 1, 2], 4), {}).detail, 'there is no group 2', 'a missing group is reported')
assertEqual(T.evaluate(t('ab', 'group', '1', 'a'), reply([0, 2, 1, 2], 4), {}).detail, 'group 1 is "b", not "a"', 'a wrong capture says what it got')
assertEqual(T.normalize({ expect: 'bogus' }).expect, 'match', 'an unknown expectation falls back to "matches"')
JS

# ---- generated code -------------------------------------------------------------------

# The generated code has to carry a pattern full of quotes, slashes,
# backslashes, and sigils intact; run it in each language that is installed.
snippet() {
  ROOT="$ROOT" node -e '
const { loadQmlJs } = require(process.env.ROOT + "/test/shell.d/fixtures/qml-js-loader.js")
const C = loadQmlJs(process.env.ROOT + "/shell/plugins/rex/lib/Codegen.js")
process.stdout.write(C.snippets(process.argv[1], process.argv[2], [], "X").find(s => s.title === "Test").code)' "$1" "$2"
}
code_pattern='a/b"'"'"'c\\d\$x@y#\{z\}\t'
export REX_TEXT=$'a/b"\'c\\d$x@y#{z}\t'
declare -A ran=()
ran[node]=$(node -e "const text = process.env.REX_TEXT; $(snippet node "$code_pattern"); console.log(found)")
ran[python]=$(python3 -c "import os
text = os.environ['REX_TEXT']
$(snippet python "$code_pattern")
print(str(found).lower())")
command -v perl >/dev/null && ran[perl]=$(perl -e 'my $text = $ENV{REX_TEXT};'"$(snippet perl "$code_pattern")"' print($found ? "true" : "false")')
command -v ruby >/dev/null && ran[ruby]=$(ruby -e 'text = ENV["REX_TEXT"]'$'\n'"$(snippet ruby "$code_pattern")"$'\n''puts found')
for language in "${!ran[@]}"; do
  [[ ${ran[$language]} == "true" ]] || fail "generated $language code matches the pattern it was given" "${ran[$language]}"
done
pass "generated code carries the pattern intact in ${!ran[*]}"

# ---- the reference agrees with the engines ------------------------------------------

# Rex's parser decides which reference entries a flavor has; each engine
# must accept exactly those. A few constructs compile in some engines while
# meaning something else (Perl's \u uppercases the next character, Python
# reads [[:upper:]] as an ordinary set); Rex rightly calls those unsupported.
declare -A means_else=(
  [python]='[[:alpha:]]'
  [perl]='\uhhhh'
  [ruby]='\g{-1}'
  [node]='\p{L} \P{L}|\p{Greek}|[[:alpha:]]'
  [rust]='*+ ++ ?+'
  [java]='[[:alpha:]]'
  [dotnet]='[[:alpha:]]'
  [cpp]='*+ ++ ?+'
)
for flavor in pcre2 python perl ruby node go rust java dotnet cpp resid; do
  worker=${flavor}
  [[ $flavor == "pcre2" ]] && worker=python
  command -v "${worker_command[$worker]}" >/dev/null || continue
  [[ $worker == "dotnet" && -z $(dotnet --list-sdks 2>/dev/null) ]] && continue
  requests=$(ROOT="$ROOT" node -e '
const { loadQmlJs } = require(process.env.ROOT + "/test/shell.d/fixtures/qml-js-loader.js")
const R = loadQmlJs(process.env.ROOT + "/shell/plugins/rex/lib/Reference.js")
R.forFlavor(process.argv[1]).forEach((e, i) => console.log(JSON.stringify({ op: "match", id: i, flavor: process.argv[1], pattern: e.pattern, flags: [], text: "x", textId: i, rex: e.supported, syntax: e.syntax })))' "$flavor")
  replies=$(OMARCHY_PATH="$ROOT" timeout 300 "$ROOT/bin/omarchy-rex-worker" "$worker" <<<"$requests" | grep -v '^{"building"')
  [[ $replies == *buildError* ]] && continue
  disagreements=$(python3 - "$flavor" "${means_else[$flavor]:-}" 3<<<"$requests" 4<<<"$replies" <<'PY'
import json, os, sys
requests = [json.loads(l) for l in os.fdopen(3) if l.strip()]
replies = {r["id"]: r for r in (json.loads(l) for l in os.fdopen(4) if l.strip())}
allowed = set(filter(None, sys.argv[2].split("|")))
for q in requests:
    r = replies.get(q["id"])
    if r is None:
        print(q["syntax"] + ": no reply")
    elif r["ok"] != q["rex"] and q["syntax"] not in allowed:
        print(q["syntax"] + ": Rex says " + ("yes" if q["rex"] else "no") + ", the engine " + ("accepts it" if r["ok"] else "says " + r.get("error", "")[:80]))
PY
)
  [[ -z $disagreements ]] || fail "the $flavor reference agrees with the engine" "$disagreements"
done
pass "every reference entry's support agrees with the real engines"

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const R = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Reference.js'))
assert(R.forFlavor('lua').every(e => e.category === 'Lua'), 'Lua gets only Lua patterns')
assert(R.search(R.forFlavor('pcre2'), 'lookbehind').some(e => e.syntax === '(?<=…)'), 'searching finds entries by meaning')
JS

# ---- saved patterns, history, and the session --------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const S = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Store.js'))

const session = S.readSession(S.writeSession({ pattern: 'a+', flavor: 'python', flags: ['i', 'J'], text: 'aaa', tool: 'split', tests: [{ text: 'a', expect: 'match' }] }))
assertDeepEqual([session.pattern, session.flavor, session.flags, session.tool, session.tests.length], ['a+', 'python', ['i'], 'split', 1], 'a session survives a round trip, keeping only flags the flavor has')
assertEqual(S.readSession('not json'), null, 'an unreadable session is ignored')
assertEqual(S.readSession('{"session": {"flavor": "klingon", "tool": "dance"}}').flavor, 'pcre2', 'an unknown flavor falls back to the default')
assertEqual(S.readSession(S.writeSession({ text: 'x'.repeat(100000) })).text.length, S.MAX_TEXT, 'a large typed text is cut to fit')

let library = S.save([], { pattern: 'a', flavor: 'pcre2' }, 'First', 1000)
library = S.save(library, { pattern: 'b', flavor: 'pcre2' }, 'Second', 2000)
library = S.save(library, { pattern: 'c', flavor: 'pcre2' }, 'First', 3000)
assertDeepEqual(library.map(e => [e.name, e.pattern, e.created, e.updated]), [['Second', 'b', 2000, 2000], ['First', 'c', 1000, 3000]], 'saving under a name in use replaces that pattern')
assertDeepEqual(S.readLibrary(S.writeLibrary(library)).map(e => e.name), ['Second', 'First'], 'the library survives a round trip')
assertDeepEqual(S.search(library, 'sec').map(e => e.name), ['Second'], 'the library searches names')
assertEqual(S.remove(library, library[0].id).length, 1, 'a saved pattern can be deleted')

let history = S.remember([], { pattern: 'a', flavor: 'pcre2' }, 1)
history = S.remember(history, { pattern: 'b', flavor: 'pcre2' }, 2)
history = S.remember(history, { pattern: 'a', flavor: 'pcre2' }, 3)
assertDeepEqual(history.map(h => h.pattern), ['a', 'b'], 'history keeps the newest use of a pattern first')
JS

# ---- lessons ------------------------------------------------------------------------------

# Every exercise's solution has to pass its own tests on the engine the
# exercise runs on.
requests=$(ROOT="$ROOT" node -e '
const { loadQmlJs } = require(process.env.ROOT + "/test/shell.d/fixtures/qml-js-loader.js")
const L = loadQmlJs(process.env.ROOT + "/shell/plugins/rex/lib/Lessons.js")
let id = 0
for (const lesson of L.LESSONS) lesson.exercises.forEach((e, i) => e.tests.forEach(t => {
  const flavor = e.flavor || "pcre2"
  console.log(JSON.stringify({ op: "match", id: id++, flavor, pattern: e.solution, flags: (e.flags || []).concat(flavor === "pcre2" ? ["u"] : []), text: t.text, textId: id, all: false, limit: 1, where: lesson.id + " exercise " + (i + 1), test: t }))
}))')
replies=$(grep '"flavor":"pcre2"' <<<"$requests" | OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python)
if command -v go >/dev/null; then
  replies+=$'\n'$(grep '"flavor":"go"' <<<"$requests" | OMARCHY_PATH="$ROOT" timeout 300 "$ROOT/bin/omarchy-rex-worker" go | grep -v '^{"building"')
else
  requests=$(grep -v '"flavor":"go"' <<<"$requests")
fi
failures=$(REQUESTS="$requests" REPLIES="$replies" run_node_test <<'JS' 2>&1 || true
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const T = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Tests.js'))
const replies = {}
for (const line of process.env.REPLIES.split('\n').filter(Boolean)) { const r = JSON.parse(line); replies[r.id] = r }
for (const line of process.env.REQUESTS.split('\n').filter(Boolean)) {
  const q = JSON.parse(line)
  const r = replies[q.id]
  const verdict = r ? T.evaluate(q.test, r, r.names) : { pass: false, detail: 'no reply' }
  if (!verdict.pass) console.log(`${q.where}: ${q.pattern} on ${JSON.stringify(q.test.text)}: ${verdict.detail}`)
}
JS
)
[[ -z $failures ]] || fail "every lesson's solution passes its own tests" "$failures"
pass "every lesson's solution passes its own tests"

reply=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-rex-worker" python <<<'{"op":"match","id":1,"flavor":"pcre2","pattern":"(a+)+$","flags":["u"],"text":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!","textId":1,"all":false,"limit":1}')
[[ $(jq -r .kind <<<"$reply") == "limit" ]] || fail "the catastrophic backtracking lesson's pattern really runs away" "$reply"
pass "the catastrophic backtracking lesson's pattern really runs away"

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const L = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Lessons.js'))
assertEqual(L.LESSONS.length, 30, 'the course has thirty lessons')
assertEqual(new Set(L.LESSONS.map(l => l.id)).size, L.LESSONS.length, 'lesson ids are unique')
let progress = L.readProgress('{"done": {"literals": [0], "nonsense": [1]}}')
assertDeepEqual(Object.keys(progress.done), ['literals'], 'progress for lessons that no longer exist is dropped')
progress = L.markDone(progress, 'literals', 1)
assert(L.complete(progress, L.byId('literals')), 'a lesson is complete when every exercise is done')
assertDeepEqual(L.readProgress(L.writeProgress(progress)), progress, 'progress survives a round trip')
JS

# ---- review fixes -----------------------------------------------------------------

run_node_test <<'JS'
const { loadQmlJs } = require(path.join(root, 'test/shell.d/fixtures/qml-js-loader.js'))
const C = loadQmlJs(path.join(root, 'shell/plugins/rex/lib/Codegen.js'))
assert(C.snippets('grep-e', '-foo', [], '').every(s => s.code.includes("-e '-foo'")), 'generated grep keeps a leading - in the pattern from reading as an option')
JS

if command -v perl >/dev/null; then
  replace_code=$(ROOT="$ROOT" node -e '
const { loadQmlJs } = require(process.env.ROOT + "/test/shell.d/fixtures/qml-js-loader.js")
const C = loadQmlJs(process.env.ROOT + "/shell/plugins/rex/lib/Codegen.js")
process.stdout.write(C.snippets("perl", "(a)\x27\\$x", [], "\\U$1/X").find(s => s.title === "Replace").code)')
  replaced=$(perl -e 'my $text = q{za'"'"'$xz};'"$replace_code"' print $result')
  [[ $replaced == 'zA/Xz' ]] || fail "generated Perl replacements interpolate groups and case escapes" "$replaced"
  pass "generated Perl replacements interpolate groups and case escapes"
fi
