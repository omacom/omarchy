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
