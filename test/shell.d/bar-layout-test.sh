#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

LAYOUT_JS=$ROOT/shell/plugins/bar/BarLayout.js
BAR_QML=$ROOT/shell/plugins/bar/Bar.qml
MENU=$ROOT/default/omarchy/omarchy-menu.jsonc

# --- BarLayout.js ---------------------------------------------------------

BAR_LAYOUT_JS=$LAYOUT_JS node <<'NODE'
const assert = require("node:assert/strict")
const fs = require("node:fs")
const vm = require("node:vm")

// BarLayout.js is a QML library (.pragma library); run it as plain JS.
const source = fs.readFileSync(process.env.BAR_LAYOUT_JS, "utf8").replace(/^\.pragma .*$/m, "")
const sandbox = {}
vm.runInNewContext(`${source}\nthis.api = { MODES, normalizeMode, parseOptions, metrics }`, sandbox)
const { MODES, normalizeMode, parseOptions, metrics } = sandbox.api

const plain = (value) => JSON.parse(JSON.stringify(value))
const same = (actual, expected, message) => assert.deepEqual(plain(actual), plain(expected), message)

// Modes
same(MODES, ["classic", "notch", "floating", "island", "split"], "modes")
for (const mode of MODES) assert.equal(normalizeMode(mode), mode, `${mode} is its own mode`)
assert.equal(normalizeMode("  ISLAND \n"), "island", "trimmed and case-folded")
assert.equal(normalizeMode("panel"), "island", "panel alias")
assert.equal(normalizeMode("islands"), "split", "islands alias")
assert.equal(normalizeMode("split-islands"), "split", "split-islands alias")
assert.equal(normalizeMode("flat"), "classic", "flat alias")
assert.equal(normalizeMode("default"), "classic", "default alias")
for (const bad of ["", "nope", null, undefined, 3, "__proto__", "hasOwnProperty", "constructor"])
  assert.equal(normalizeMode(bad), "classic", `unknown mode ${String(bad)} is classic`)

// Options parsing
same(parseOptions(""), {}, "blank options")
same(parseOptions("  \n"), {}, "whitespace options")
same(parseOptions("{nope"), {}, "invalid json")
same(parseOptions("[1,2]"), {}, "array is not options")
same(parseOptions("42"), {}, "scalar is not options")
same(parseOptions("null"), {}, "null is not options")
same(parseOptions(null), {}, "null text")
same(parseOptions('{"common":{"opacity":0.5}}'), { common: { opacity: 0.5 } }, "object options")

// Defaults per mode
const classic = metrics("classic", {})
same(classic, {
  mode: "classic", radius: 0, margin: 0, padding: -1, spacing: 0, border: false, shadow: false,
  opacity: 1, background: "", halo: 0, extra: 0
}, "classic defaults")
const notch = metrics("notch", {})
assert.equal(notch.radius, 14, "notch radius")
assert.equal(notch.padding, 12, "notch padding")
assert.equal(notch.spacing, 2, "notch packs modules like an island")
assert.equal(notch.extra, 0, "notch adds no thickness")
assert.equal(metrics("rounded", {}).mode, "classic", "the retired rounded mode is classic")
const floating = metrics("floating", {})
assert.equal(floating.margin, 8, "floating margin")
assert.equal(floating.border, true, "floating border")
assert.equal(floating.extra, 8, "floating thickness")
const island = metrics("island", {})
assert.equal(island.radius, 999, "island is a pill")
assert.equal(island.spacing, 2, "island packs modules with spacing")
assert.equal(island.padding, 8, "island padding")
assert.equal(metrics("split", {}).spacing, 0, "split has no extra spacing")
assert.equal(metrics("bogus", {}).mode, "classic", "unknown mode is classic")
assert.equal(metrics("panel", {}).mode, "island", "alias resolves in metrics")
assert.equal(metrics("island").mode, "island", "options may be omitted")
assert.equal(metrics("island", "nope").margin, 6, "non-object options ignored")

// Classic is the stock bar whatever the options say
same(metrics("classic", {
  common: { radius: 20, margin: 10, opacity: 0.2, background: "#112233", border: true, shadow: true },
  classic: { padding: 20, spacing: 9 }
}), classic, "classic ignores every option")

// A notch stays attached to its edge: no gap, outline or halo, whatever the options say
const hung = metrics("notch", { common: { margin: 12, border: true, shadow: true }, notch: { radius: 20, padding: 6, spacing: 4, opacity: 0.5 } })
assert.equal(hung.margin, 0, "notch margin is forced to 0")
assert.equal(hung.border, false, "notch border is forced off")
assert.equal(hung.shadow, false, "notch shadow is forced off")
assert.equal(hung.halo, 0, "notch has no halo")
assert.equal(hung.extra, 0, "notch adds no thickness")
assert.equal(hung.radius, 20, "notch radius is tunable")
assert.equal(hung.padding, 6, "notch padding is tunable")
assert.equal(hung.spacing, 4, "notch spacing is tunable")
assert.equal(hung.opacity, 0.5, "notch opacity is tunable")

// Precedence: default < common < mode
const opts = { common: { margin: 10, opacity: 0.8 }, floating: { margin: 4 } }
assert.equal(metrics("floating", opts).margin, 4, "mode beats common")
assert.equal(metrics("island", opts).margin, 10, "common beats default")
assert.equal(metrics("floating", opts).opacity, 0.8, "common applies to every mode")
assert.equal(metrics("island", { common: { margin: null }, island: { margin: undefined } }).margin, 6, "null falls through to default")
assert.equal(metrics("island", { common: { margin: 12 }, island: { margin: null } }).margin, 12, "null in a mode falls through to common")
assert.equal(metrics("island", { common: "oops", island: [] }).margin, 6, "non-object sections ignored")

// Clamping and rounding
assert.equal(metrics("floating", { floating: { margin: 500 } }).margin, 64, "margin max")
assert.equal(metrics("floating", { floating: { margin: -5 } }).margin, 0, "margin min")
assert.equal(metrics("island", { island: { padding: 500 } }).padding, 48, "padding max")
assert.equal(metrics("island", { island: { padding: -50 } }).padding, -1, "padding min is the theme default")
assert.equal(metrics("island", { island: { spacing: 99 } }).spacing, 32, "spacing max")
assert.equal(metrics("island", { island: { opacity: 5 } }).opacity, 1, "opacity max")
assert.equal(metrics("island", { island: { opacity: -1 } }).opacity, 0, "opacity min")
assert.equal(metrics("floating", { floating: { margin: 8.4 } }).margin, 8, "margin rounds down")
assert.equal(metrics("floating", { floating: { margin: 8.6 } }).margin, 9, "margin rounds up")
assert.equal(metrics("floating", { floating: { margin: 8.6 } }).extra, 9, "extra matches the rounded margin")
assert.equal(metrics("island", { island: { opacity: 0.55 } }).opacity, 0.55, "opacity is not rounded")
assert.equal(metrics("floating", { floating: { margin: "10px" } }).margin, 10, "px string")
assert.equal(metrics("floating", { floating: { margin: "abc" } }).margin, 8, "garbage keeps the default")
assert.equal(metrics("floating", { floating: { margin: Infinity } }).margin, 8, "infinity keeps the default")
assert.equal(metrics("floating", { floating: { margin: true } }).margin, 8, "boolean is not a number")

// Radius
assert.equal(metrics("notch", { notch: { radius: "pill" } }).radius, 999, "pill")
assert.equal(metrics("notch", { notch: { radius: " Pill " } }).radius, 999, "pill is trimmed and case-folded")
assert.equal(metrics("notch", { notch: { radius: "20px" } }).radius, 20, "px radius")
assert.equal(metrics("notch", { notch: { radius: 0 } }).radius, 0, "square corners")
assert.equal(metrics("notch", { notch: { radius: -4 } }).radius, 0, "negative radius")
assert.equal(metrics("notch", { notch: { radius: 5000 } }).radius, 999, "huge radius is a pill")
assert.equal(metrics("notch", { notch: { radius: "round" } }).radius, 14, "unknown radius keeps the default")

// Booleans
for (const on of [true, 1, "true", "on", "yes"]) assert.equal(metrics("island", { island: { border: on } }).border, true, `border ${on}`)
for (const off of [false, 0, "false", "off", "no"]) assert.equal(metrics("island", { island: { border: off } }).border, false, `border ${off}`)
assert.equal(metrics("island", { island: { border: "maybe" } }).border, true, "unknown boolean keeps the default")

// Background
assert.equal(metrics("island", { common: { background: "#1e1e2e" } }).background, "#1e1e2e", "rrggbb")
assert.equal(metrics("island", { common: { background: " #1E1E2Ecc " } }).background, "#1E1E2Ecc", "rrggbbaa, trimmed")
for (const bad of ["theme", "", "#123", "#12345g", "red", 5, true])
  assert.equal(metrics("island", { common: { background: bad } }).background, "", `background ${String(bad)} keeps the theme`)

// Shadow: halo, and enough margin to hold it
const shadowed = metrics("floating", { floating: { shadow: true, margin: 0 } })
assert.equal(shadowed.halo, 3, "halo")
assert.equal(shadowed.margin, 3, "margin grows to hold the halo")
assert.equal(shadowed.extra, 6, "extra is margin + halo")
const roomy = metrics("floating", { floating: { shadow: true } })
assert.equal(roomy.margin, 8, "margin already holds the halo")
assert.equal(roomy.extra, 11, "extra with a roomy margin")
assert.equal(metrics("floating", {}).halo, 0, "no halo without a shadow")

// Pure: options are not mutated
const frozen = Object.freeze({ common: Object.freeze({ margin: 3 }), island: Object.freeze({ radius: "pill" }) })
metrics("island", frozen)

console.log("ok")
NODE
pass "BarLayout.js computes metrics"

# --- omarchy-bar-layout ---------------------------------------------------

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/stubs"

cat >"$tmp/stubs/omarchy-shell" <<'STUB'
#!/bin/bash
echo "omarchy-shell $*" >>"$TEST_CALLS"
STUB
cat >"$tmp/stubs/omarchy-menu" <<'STUB'
#!/bin/bash
echo "omarchy-menu $*" >>"$TEST_CALLS"
STUB
chmod +x "$tmp/stubs/omarchy-shell" "$tmp/stubs/omarchy-menu"

export TEST_CALLS=$tmp/calls
export OMARCHY_BAR_LAYOUT_DIR=$tmp/layout
export PATH="$tmp/stubs:$ROOT/bin:$PATH"

reset_state() {
  rm -rf "$OMARCHY_BAR_LAYOUT_DIR"
  : >"$TEST_CALLS"
}

# Runs the command, leaving stdout in $out, stderr in $err and the status in $status.
run() {
  status=0
  out=$(omarchy-bar-layout "$@" 2>"$tmp/err") || status=$?
  err=$(<"$tmp/err")
}

expect_ok() {
  local label=$1
  shift
  run "$@"
  [[ $status == 0 ]] || fail "$label" "exit $status: $err"
}

expect_fail() {
  local label=$1
  local pattern=$2
  shift 2
  run "$@"
  [[ $status != 0 ]] || fail "$label" "expected a failure, got: $out"
  [[ $err == *"$pattern"* ]] || fail "$label" "stderr was: $err"
}

reset_state
expect_ok "get without state" get
[[ $out == classic ]] || fail "a missing mode file is classic" "$out"
pass "layout defaults to classic"

expect_ok "apply island" island
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == island ]] || fail "applying writes the mode file"
expect_ok "get after apply" get
[[ $out == island ]] || fail "get reports the applied mode" "$out"
rg -qx 'omarchy-shell -q omarchy.bar reloadLayout' "$TEST_CALLS" || fail "applying nudges the bar" "$(<"$TEST_CALLS")"
pass "layout applies and nudges the bar"

for alias_pair in panel:island islands:split split-islands:split flat:classic default:classic PANEL:island; do
  alias=${alias_pair%%:*}
  expected=${alias_pair##*:}
  expect_ok "alias $alias" "$alias"
  [[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == "$expected" ]] || fail "$alias is written as $expected" "$(<"$OMARCHY_BAR_LAYOUT_DIR/mode")"
done
pass "layout aliases are canonicalized"

# A hand-written alias in the mode file reads back as the bar reads it
printf 'Panel\n' >"$OMARCHY_BAR_LAYOUT_DIR/mode"
expect_ok "get with alias" get
[[ $out == island ]] || fail "get resolves aliases in the file like the bar does" "$out"
printf 'garbage\n' >"$OMARCHY_BAR_LAYOUT_DIR/mode"
expect_ok "get with garbage" get
[[ $out == classic ]] || fail "garbage in the mode file is classic" "$out"
pass "layout reads the mode file like the bar"

reset_state
expect_fail "unknown layout" "unknown layout 'bogus'" bogus
[[ ! -e $OMARCHY_BAR_LAYOUT_DIR/mode ]] || fail "an unknown layout writes nothing"
[[ ! -s $TEST_CALLS ]] || fail "an unknown layout does not nudge the bar"
pass "layout rejects unknown modes"

reset_state
expect_ok "cycle 1" cycle
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == notch ]] || fail "cycle goes classic to notch"
expect_ok "cycle prev" cycle prev
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == classic ]] || fail "cycle prev goes back"
expect_ok "cycle prev wraps" cycle prev
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == split ]] || fail "cycle prev wraps to split"
expect_ok "cycle wraps" cycle
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/mode") == classic ]] || fail "cycle wraps to classic"
expect_fail "cycle argument" "cycle takes" cycle sideways
pass "layout cycles both ways and wraps"

reset_state
expect_ok "list" island
expect_ok "list" list
[[ $out == *'* island'* && $out == *'  classic'* ]] || fail "list marks the current layout" "$out"
[[ $(rg -c '^[* ] ' <<<"$out") == 5 ]] || fail "list shows every layout" "$out"
pass "layout lists modes"

reset_state
expect_ok "radius default" radius pill
[[ $(jq -c . "$OMARCHY_BAR_LAYOUT_DIR/layout.json") == '{"notch":{"radius":"pill"}}' ]] || fail "radius defaults to notch" "$(<"$OMARCHY_BAR_LAYOUT_DIR/layout.json")"
expect_ok "radius island" radius 012 island
[[ $(jq -c .island.radius "$OMARCHY_BAR_LAYOUT_DIR/layout.json") == 12 ]] || fail "radius normalizes leading zeros"
expect_ok "radius px" radius 20px floating
[[ $(jq -c .floating.radius "$OMARCHY_BAR_LAYOUT_DIR/layout.json") == 20 ]] || fail "radius accepts px"
expect_ok "radius preset" radius sm
[[ $(jq -c .notch.radius "$OMARCHY_BAR_LAYOUT_DIR/layout.json") == 8 ]] || fail "radius presets"
[[ $(jq -c .notch.radius "$OMARCHY_BAR_LAYOUT_DIR/layout.json") != '"pill"' ]] || fail "a later radius replaces the earlier one"
expect_fail "radius classic" "classic has no corners" radius 8 classic
expect_fail "radius classic alias" "classic has no corners" radius 8 flat
expect_fail "radius garbage" "radius must be" radius round
expect_fail "radius negative" "radius must be" radius -3
expect_fail "radius missing" "usage: radius" radius
pass "layout radius presets and validation"

reset_state
expect_ok "set margin" set floating margin 10
expect_ok "set opacity" set common opacity 0.90
expect_ok "set bool" set island border off
expect_ok "set bool" set island shadow YES
expect_ok "set padding" set island padding -1
expect_ok "set background" set common background '#1E1E2E'
expect_ok "set spacing" set split spacing 3px
expect_ok "set alias mode" set panel spacing 4
jq -e '
  .floating.margin == 10 and
  .common.opacity == 0.9 and
  .island.border == false and
  .island.shadow == true and
  .island.padding == -1 and
  .island.spacing == 4 and
  .common.background == "#1e1e2e" and
  .split.spacing == 3
' "$OMARCHY_BAR_LAYOUT_DIR/layout.json" >/dev/null || fail "set stores typed values" "$(<"$OMARCHY_BAR_LAYOUT_DIR/layout.json")"
expect_ok "set theme" set common background theme
[[ $(jq -r .common.background "$OMARCHY_BAR_LAYOUT_DIR/layout.json") == theme ]] || fail "background accepts theme"
pass "layout set stores typed values"

reset_state
expect_ok "seed" set floating margin 10
before=$(<"$OMARCHY_BAR_LAYOUT_DIR/layout.json")
expect_fail "unknown key" "unknown key 'color'" set floating color red
expect_fail "unknown mode" "unknown layout" set bogus margin 4
expect_fail "bad number" "margin takes a number" set floating margin abc
expect_fail "bad float margin" "margin takes a number" set floating margin 1.5
expect_fail "bad opacity" "opacity takes" set common opacity half
expect_fail "bad bool" "border takes" set island border maybe
expect_fail "bad background" "background must be" set common background banana
expect_fail "short background" "background must be" set common background '#123'
expect_fail "missing value" "usage: set" set floating margin
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/layout.json") == "$before" ]] || fail "a rejected set leaves layout.json alone"
pass "layout set rejects bad input without writing"

reset_state
mkdir -p "$OMARCHY_BAR_LAYOUT_DIR"
printf 'not json' >"$OMARCHY_BAR_LAYOUT_DIR/layout.json"
expect_fail "invalid layout.json" "is not a JSON object" set floating margin 4
[[ $(<"$OMARCHY_BAR_LAYOUT_DIR/layout.json") == 'not json' ]] || fail "an invalid layout.json is never overwritten"
printf '[1]' >"$OMARCHY_BAR_LAYOUT_DIR/layout.json"
expect_fail "array layout.json" "is not a JSON object" radius 8
pass "layout refuses to clobber an invalid layout.json"

reset_state
expect_ok "reload" reload
rg -qx 'omarchy-shell -q omarchy.bar reloadLayout' "$TEST_CALLS" || fail "reload nudges the bar"
reset_state
expect_ok "menu" menu
rg -qx 'omarchy-menu summon appearance.top-bar.layout' "$TEST_CALLS" || fail "menu opens the layout picker" "$(<"$TEST_CALLS")"
expect_ok "help" --help
[[ $out == *'Usage: omarchy bar layout'* ]] || fail "help prints usage" "$out"
pass "layout reload, menu and help"

# --- wiring: script, JS, Bar.qml and menu agree ---------------------------

expect_ok "list for wiring" list
script_modes=$(sed -E 's/^[* ] //' <<<"$out" | paste -sd' ')
js_modes=$(node -e '
  const fs = require("node:fs")
  const vm = require("node:vm")
  const sandbox = {}
  vm.runInNewContext(fs.readFileSync(process.argv[1], "utf8").replace(/^\.pragma .*$/m, "") + "\nthis.m = MODES", sandbox)
  console.log(sandbox.m.join(" "))
' "$LAYOUT_JS")
[[ $script_modes == "$js_modes" ]] || fail "the command and BarLayout.js list the same layouts" "$script_modes / $js_modes"

for mode in $js_modes; do
  rg -q "\"appearance.top-bar.layout.$mode\".*omarchy-bar-layout $mode\"" "$MENU" || fail "the menu has a row for $mode"
done
pass "menu, command and BarLayout.js agree on layouts"

# The command and the bar must resolve every alias the same way.
alias_pairs=$(node -e '
  const fs = require("node:fs")
  const vm = require("node:vm")
  const sandbox = {}
  vm.runInNewContext(fs.readFileSync(process.argv[1], "utf8").replace(/^\.pragma .*$/m, "") + "\nthis.n = normalizeMode; this.a = Object.keys(ALIASES)", sandbox)
  for (const word of sandbox.a) console.log(`${word} ${sandbox.n(word)}`)
' "$LAYOUT_JS")
[[ -n $alias_pairs ]] || fail "BarLayout.js has aliases to compare"
while read -r word expected; do
  reset_state
  mkdir -p "$OMARCHY_BAR_LAYOUT_DIR"
  printf '%s\n' "$word" >"$OMARCHY_BAR_LAYOUT_DIR/mode"
  expect_ok "alias parity $word" get
  [[ $out == "$expected" ]] || fail "'$word' means $expected to the bar but $out to the command"
done <<<"$alias_pairs"
pass "command and BarLayout.js resolve aliases the same way"

rg -q 'target: "omarchy.bar"' "$BAR_QML" || fail "Bar.qml keeps the omarchy.bar IPC target"
rg -q 'function reloadLayout\(\): void' "$BAR_QML" || fail "Bar.qml handles the reloadLayout IPC call"
rg -q 'import "BarLayout.js" as BarLayout' "$BAR_QML" || fail "Bar.qml imports BarLayout.js"
rg -q 'bar-layout' "$BAR_QML" || fail "Bar.qml reads the bar-layout state directory"
rg -q 'omarchy-shell -q omarchy.bar reloadLayout' "$ROOT/bin/omarchy-bar-layout" || fail "the command nudges the IPC call Bar.qml handles"
rg -q 'String\(root\.thicknessFor\(null\)\)' "$BAR_QML" || fail "the transparent text color samples the band the layout pill covers"
rg -Uq 'radius: pill\.radius \+ index \+ 1\n\s+color: "transparent"' "$BAR_QML" || fail "shadow rings are outlines, so a translucent pill is not darkened"
# Switching split to island at runtime must not leave a stale width on the run:
# the run is placed with x/y, never with anchors that are swapped between modes.
run_blocks=$(awk '/id: centerRun/ { grab = 1 } grab { print } grab && /^          }$/ { grab = 0 }' "$BAR_QML")
[[ -n $run_blocks ]] || fail "Bar.qml has the center run blocks"
if rg -q 'anchors\.(left|right|horizontalCenter|verticalCenter|top): .*(\?|undefined)' <<<"$run_blocks"; then
  fail "the center run is positioned with x/y, not mode-swapped anchors" "$run_blocks"
fi
rg -q 'x: hbar\.isPacked' "$BAR_QML" || fail "the horizontal run is placed with x"
rg -q 'y: vbar\.isPacked' "$BAR_QML" || fail "the vertical run is placed with y"
# A notch hangs from its screen edge: the pill squares the corners on that edge,
# and a camera-notch screen falls back to the classic bar.
rg -q 'flush: (hbar|vbar)\.mode === "notch" \? root\.position : ""' "$BAR_QML" || fail "the notch pill is flush with the bar's screen edge"
rg -q 'topLeftRadius: flush === "top" \|\| flush === "left" \? 0 : radius' "$BAR_QML" || fail "the pill squares the corners on its flush edge"
rg -q 'mode !== "notch" && mode !== "island" && mode !== "split"' "$BAR_QML" || fail "the notch, island and split yield to a camera notch"
rg -q 'return notched \? "classic" : mode' "$BAR_QML" || fail "a camera-notch screen keeps the classic bar"
if rg -q '"rounded"' "$BAR_QML"; then fail "Bar.qml no longer knows the retired rounded mode"; fi
pass "Bar.qml, command and IPC agree"
