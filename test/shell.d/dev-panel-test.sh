#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const { typeName, findOpenCard, shown, intersect, itemTree, captureSize, settleDelay } = requireFromRoot('shell/services/DevInspect.js')

const named = name => ({ toString: () => name })
assertEqual(typeName(named('QQuickText(0x55d4a1b2c3d0)')), 'Text', 'Qt Quick types lose their QQuick prefix and address')
assertEqual(typeName(named('PanelHero_QMLTYPE_37(0x55d4a1b2c3d0, "hero")')), 'PanelHero', 'QML types lose their generated suffix')
assertEqual(typeName(named('Rectangle_QML_12(0x1)')), 'Rectangle', 'inline QML types lose their generated suffix')

const card = { name: 'card' }
const closedCard = { name: 'closed' }
const panel = { data: [{ cardItem: closedCard, open: false }, { data: [{ cardItem: card, open: true }] }] }
assertEqual(findOpenCard(panel), card, 'the open card is found among nested resources, past a closed one')
assertEqual(findOpenCard({ data: [{ cardItem: closedCard, open: false }] }), null, 'a closed card is not captured')
let deep = { cardItem: card, open: true }
for (let i = 0; i < 7; i++) deep = { data: [deep] }
assertEqual(findOpenCard(deep), null, 'the search gives up past six levels')
assertEqual(findOpenCard(null), null, 'nothing has no card')
const loader = { data: [], item: { data: [{ cardItem: card, open: true }] } }
assertEqual(findOpenCard({ data: [{ name: 'button' }, loader] }), card, 'a card under a Loader is found through its item, even when the item is not among its data')

const box = (extra) => Object.assign({ visible: true, opacity: 1, width: 10, height: 10 }, extra)
assert(shown(box()), 'a visible item with a size is shown')
assert(!shown(box({ visible: false })), 'a hidden item is not shown')
assert(!shown(box({ opacity: 0 })), 'a transparent item is not shown')
assert(!shown(box({ width: 0 })), 'an item without width is not shown')
assert(!shown(null), 'a missing item is not shown')

const at = (x, y) => () => ({ x: x + 0.4, y: y + 0.4 })
const label = box({ toString: () => 'QQuickText(0x1)', text: 'ACTIVE', font: { pixelSize: 11 }, color: '#7aa2f7', width: 40.3, height: 14.6, mapToItem: at(300, 106) })
const hidden = box({ toString: () => 'QQuickText(0x2)', text: 'secret', visible: false })
const spacer = box({ toString: () => 'QQuickItem(0x3)', mapToItem: at(0, 0), color: '#00000000' })
const panelCard = box({ toString: () => 'QQuickRectangle(0x4)', width: 380, height: 632, radius: 8, color: '#1a1b26', children: [label, hidden, spacer] })
assertDeepEqual(itemTree(panelCard, panelCard), {
  type: 'Rectangle', x: 0, y: 0, w: 380, h: 632, color: '#1a1b26', radius: 8,
  children: [
    { type: 'Text', x: 300, y: 106, w: 40, h: 15, text: 'ACTIVE', color: '#7aa2f7', px: 11 },
    { type: 'Item', x: 0, y: 0, w: 10, h: 10 }
  ]
}, 'the item tree keeps geometry, text, font size, color, and radius, and leaves hidden items and transparent colors out')
const pointSized = box({ toString: () => 'QQuickText(0x15)', text: 'Default font', font: { pixelSize: -1 }, mapToItem: at(0, 0) })
assert(!('px' in itemTree(pointSized, pointSized)), 'a font sized in points, which reports -1 pixels, has no px')

assertDeepEqual(intersect({ x: 0, y: 0, w: 10, h: 10 }, null), { x: 0, y: 0, w: 10, h: 10 }, 'no clip leaves a rectangle whole')
assertDeepEqual(intersect({ x: 5, y: 5, w: 10, h: 10 }, { x: 0, y: 0, w: 10, h: 10 }), { x: 5, y: 5, w: 5, h: 5 }, 'a clip cuts a rectangle to the overlap')
assertEqual(intersect({ x: 0, y: 20, w: 10, h: 10 }, { x: 0, y: 0, w: 10, h: 20 }), null, 'a rectangle just past the clip is gone')

// A list scrolled by 30: its viewport, at y 100, shows 40 pixels, so of rows at
// 70, 100, 130, and 140 in card coordinates only the middle two show.
const row = (y, text) => box({ toString: () => 'QQuickText(0x5)', text, width: 100, height: 10, mapToItem: () => ({ x: 0, y }) })
const rows = box({ toString: () => 'QQuickItem(0x6)', width: 100, height: 80, mapToItem: () => ({ x: 0, y: 70 }), children: [row(70, 'above'), row(100, 'first'), row(130, 'last'), row(140, 'below')] })
const list = box({ toString: () => 'QQuickFlickable(0x7)', clip: true, width: 100, height: 40, mapToItem: () => ({ x: 0, y: 100 }), children: [rows] })
const scrolledCard = box({ toString: () => 'QQuickRectangle(0x8)', width: 100, height: 200, children: [list] })
const texts = node => (node.text ? [node.text] : []).concat(...(node.children || []).map(texts))
assertDeepEqual(texts(itemTree(scrolledCard, scrolledCard)), ['first', 'last'], 'the item tree leaves out rows a scrolled, clipping list hides')
// A plain container scrolled out of view still shows a badge that reaches back
// into the viewport; a clipping one out of view hides everything under it.
const badge = box({ toString: () => 'QQuickText(0xc)', text: 'badge', width: 100, height: 20, mapToItem: () => ({ x: 0, y: 120 }) })
const offscreen = box({ toString: () => 'QQuickItem(0xd)', width: 100, height: 10, mapToItem: () => ({ x: 0, y: 60 }), children: [badge] })
const clippedAway = box({ toString: () => 'QQuickItem(0xe)', clip: true, width: 100, height: 10, mapToItem: () => ({ x: 0, y: 60 }), children: [row(120, 'hidden')] })
const viewport = box({ toString: () => 'QQuickFlickable(0xf)', clip: true, width: 100, height: 40, mapToItem: () => ({ x: 0, y: 100 }), children: [offscreen, clippedAway] })
const reachCard = box({ toString: () => 'QQuickRectangle(0x10)', width: 100, height: 200, children: [viewport] })
assertDeepEqual(texts(itemTree(reachCard, reachCard)), ['badge'], 'a visible item under an out-of-view container shows, but not one under an out-of-view clip')

// A link scrolled just out of view whose mouse area reaches back in: the link
// stays as the area's parent, but its own text and color, which don't show, go.
const area = box({ toString: () => 'QQuickMouseArea(0x11)', width: 100, height: 20, mapToItem: () => ({ x: 0, y: 95 }) })
const link = box({ toString: () => 'TextLink_QMLTYPE_3(0x12)', text: 'Sign in', color: '#7aa2f7', font: { pixelSize: 11 }, width: 100, height: 10, mapToItem: () => ({ x: 0, y: 85 }), children: [area] })
const linkView = box({ toString: () => 'QQuickFlickable(0x13)', clip: true, width: 100, height: 40, mapToItem: () => ({ x: 0, y: 100 }), children: [link] })
const linkCard = box({ toString: () => 'QQuickRectangle(0x14)', width: 100, height: 200, children: [linkView] })
assertDeepEqual(itemTree(linkCard, linkCard).children[0].children[0], {
  type: 'TextLink', x: 0, y: 85, w: 100, h: 10,
  children: [{ type: 'MouseArea', x: 0, y: 95, w: 100, h: 20 }]
}, 'an out-of-view item kept for a child that reaches into view drops its own text and color')

assertDeepEqual(captureSize(380, 632, ''), { width: 380, height: 632, scale: 1 }, 'a capture defaults to the screen pixels, leaving the device pixel ratio to Qt')
assertDeepEqual(captureSize(380, 632, '2'), { width: 760, height: 1264, scale: 2 }, 'a capture at scale 2 asks for twice the size')
assertDeepEqual(captureSize(380.5, 631.2, '1.25'), { width: 476, height: 789, scale: 1.25 }, 'a fractional scale rounds the size up')
assertDeepEqual(captureSize(380, 632, '0'), { width: 380, height: 632, scale: 1 }, 'a zero scale falls back to the screen pixels')

assertEqual(settleDelay(0, 5000, 400), 400, 'a card with no known open time gets the whole settle wait')
assertEqual(settleDelay(4900, 5000, 400), 300, 'a card opened 100ms ago waits out the rest')
assertEqual(settleDelay(4000, 5000, 400), 0, 'a card open for a while is captured right away')
assertEqual(settleDelay(5200, 5000, 400), 400, 'a clock that stepped back never waits longer than the settle time')

const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')
assert(/function debugPanelCapture\(id: string, path: string, scale: string\): string/.test(shellSource), 'the shell IPC captures a panel card')
assert(/function debugPanelTree\(id: string\): string/.test(shellSource), 'the shell IPC describes a panel card')
assert(/if \(Quickshell\.env\("QS_DISABLE_FILE_WATCHER"\)\) return "disabled"/.test(shellSource), 'the installed shell, which runs without the file watcher, refuses to reload')
assert(/function devPanelOpen\(id\) \{[^}]*isBarWidgetPanelPlugin\(resolved\) && shell\.summon\(resolved/.test(shellSource), 'only a bar widget panel is summoned for a capture or a tree, not any plugin')
assert(/if \(!devPanelOpen\(id\)\) return false/.test(shellSource), 'a capture summons through the bar widget check')
assert(/devCaptureRequest\.createObject\(shell, \{ pluginId: id, path: path/.test(shellSource), 'each capture request gets its own timer, so overlapping ones keep their arguments')
assert(/DevInspect\.settleDelay\(card \? card\.openedAt : 0, Date\.now\(\), 400\)[\s\S]*interval: wait \}/.test(shellSource), 'a capture waits out what is left of a just-opened card settling')
for (const file of ['KeyboardPanel', 'PopupCard']) {
  const source = fs.readFileSync(`${root}/shell/Ui/${file}.qml`, 'utf8')
  assert(/readonly property Item cardItem: card/.test(source), `${file} exposes its card for the capture`)
  assert(/property double openedAt: 0/.test(source) && /if \(open\)[\s\S]{0,40}card\.openedAt = Date\.now\(\)/.test(source), `${file} records when its card opened`)
  assert(/Component\.onCompleted: if \(root\.open\) openedAt = Date\.now\(\)/.test(source), `${file} records a card created open as opened then`)
}
JS

# The command, against a stand-in omarchy-shell that logs its calls and plays
# the shell's part: writing the PNG, or answering with a tree.
test_bin=$(mktemp -d)
work=$(mktemp -d)
trap 'rm -rf "$test_bin" "$work"' EXIT

cat >"$test_bin/omarchy-shell" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$FAKE_LOG"
case $2 in
  debugPanelCapture)
    if [[ $3 == "missing.panel" ]]; then
      echo unknown
    else
      echo ok
      stat -c %a "$(dirname "$4")" >"$FAKE_LOG.stage"
      # Like the real shell, "slow" writes after answering, and not all at once.
      if [[ ${FAKE_WRITE:-} == "slow" ]]; then
        { sleep 0.1; { printf 'pn'; sleep 0.2; printf 'g'; } >"$4"; } >/dev/null 2>&1 &
      elif [[ -n ${FAKE_WRITE:-} ]]; then
        printf 'png' >"$4"
      fi
    fi
    ;;
  debugPanelTree)
    if [[ $3 == "missing.panel" ]]; then
      echo unknown
    elif [[ $3 == "stuck.panel" ]]; then
      echo opening
    elif [[ $3 == "slow.panel" ]] && (( $(grep -c "debugPanelTree slow.panel" "$FAKE_LOG") <= 3 )); then
      echo opening
    else
      echo '{"type":"Rectangle","x":0,"y":0,"w":380,"h":632,"color":"#1a1b26","children":[{"type":"Text","x":8,"y":106,"w":40,"h":15,"text":"Two\nlines","px":11}]}'
    fi
    ;;
esac
EOF
chmod +x "$test_bin/omarchy-shell"

export FAKE_LOG="$work/calls"
capture() {
  (cd "$work" && PATH="$test_bin:$ROOT/bin:$PATH" omarchy-dev-panel-capture "$@")
}
tree() {
  (cd "$work" && PATH="$test_bin:$ROOT/bin:$PATH" omarchy-dev-panel-tree "$@")
}

for args in "" "--scale" "--scale big omarchy.agents" "--scale -1 omarchy.agents" "--frob omarchy.agents"; do
  # shellcheck disable=SC2086
  if capture $args >/dev/null 2>&1; then
    fail "panel capture rejects: '$args'"
  fi
done
for args in "" "--json" "--frob omarchy.agents"; do
  # shellcheck disable=SC2086
  if tree $args >/dev/null 2>&1; then
    fail "panel tree rejects: '$args'"
  fi
done
pass "panel capture and tree reject a missing id, an unknown option, and a scale that isn't a number"

: >"$FAKE_LOG"
out=$(FAKE_WRITE=1 capture --scale 2 omarchy.agents)
[[ $out == "$work/agents-panel.png" ]] || fail "panel capture names the PNG after the plugin" "$out"
[[ $(cat "$work/agents-panel.png") == "png" ]] || fail "panel capture leaves the PNG the shell wrote"
grep -Eqx "shell debugPanelCapture omarchy.agents $work/\.agents-panel\.[A-Za-z0-9]{6}/capture\.png 2" "$FAKE_LOG" || fail "panel capture has the shell write into a private directory beside the absolute path, passing the scale" "$(cat "$FAKE_LOG")"
[[ $(cat "$FAKE_LOG.stage") == "700" ]] || fail "panel capture stages the PNG in a directory only its user can write" "$(cat "$FAKE_LOG.stage")"
pass "panel capture saves the card where asked and prints its path"

: >"$FAKE_LOG"
FAKE_WRITE=1 capture omarchy.agents sub/../card.png >/dev/null
grep -Eqx "shell debugPanelCapture omarchy.agents $work/\.card\.[A-Za-z0-9]{6}/capture\.png " "$FAKE_LOG" || fail "panel capture resolves a relative path and sends an empty default scale" "$(cat "$FAKE_LOG")"
pass "panel capture resolves a relative output path"

FAKE_WRITE=slow capture omarchy.agents late.png >/dev/null || fail "panel capture waits for a PNG the shell writes after answering"
[[ $(cat "$work/late.png") == "png" ]] || fail "panel capture moves the PNG into place only once the shell has closed it" "$(cat "$work/late.png")"
pass "panel capture waits for the shell to finish writing"

if capture missing.panel 2>"$work/err"; then fail "panel capture fails on a panel the shell doesn't know"; fi
grep -q "No bar panel for missing.panel" "$work/err" || fail "panel capture says the panel is unknown" "$(cat "$work/err")"
if capture omarchy.agents never.png 2>"$work/err"; then fail "panel capture fails when the shell never writes the PNG"; fi
grep -q "The shell never wrote" "$work/err" || fail "panel capture says the shell never wrote the PNG" "$(cat "$work/err")"
pass "panel capture reports an unknown panel and a PNG that never appears"

echo "old" >"$work/keep.png"
capture missing.panel keep.png 2>/dev/null || true
capture omarchy.agents keep.png 2>/dev/null || true
[[ $(cat "$work/keep.png") == "old" ]] || fail "a failed panel capture leaves an existing file alone"
FAKE_WRITE=1 capture omarchy.agents keep.png >/dev/null
[[ $(cat "$work/keep.png") == "png" ]] || fail "a successful panel capture replaces an existing file"
[[ $(stat -c %a "$work/keep.png") == "$(printf '%o' $(( 0666 & ~$(umask) )))" ]] || fail "a captured PNG gets the usual permissions" "$(stat -c %a "$work/keep.png")"
mkdir "$work/shots"
if FAKE_WRITE=1 capture omarchy.agents shots 2>"$work/err"; then fail "panel capture refuses a directory as its output"; fi
grep -q "is a directory" "$work/err" || fail "panel capture says the output is a directory" "$(cat "$work/err")"
[[ -z $(ls -A "$work/shots") ]] || fail "panel capture writes nothing into a directory given as its output"
if FAKE_WRITE=1 capture omarchy.agents card.jpg 2>"$work/err"; then fail "panel capture refuses an output that isn't a .png"; fi
grep -q "must end in .png" "$work/err" || fail "panel capture says the output must be a .png" "$(cat "$work/err")"
leftovers=$(find "$work" -name '.*')
[[ -z $leftovers ]] || fail "panel capture cleans up its temporary files" "$leftovers"
pass "panel capture replaces an existing file only once a new PNG is complete, and only with a file named .png"

lines=$(tree omarchy.agents)
expected=$'Rectangle  0,0 380x632  #1a1b26\n  Text  8,106 40x15  "Two⏎lines"  11px'
[[ $lines == "$expected" ]] || fail "panel tree prints one indented line per item" "$lines"
tree --json omarchy.agents | jq -e '.children[0].text == "Two\nlines"' >/dev/null || fail "panel tree --json prints the tree as JSON"
if tree missing.panel 2>/dev/null; then fail "panel tree fails on a panel that isn't open"; fi
: >"$FAKE_LOG"
tree --json slow.panel | jq -e '.w == 380' >/dev/null || fail "panel tree reads a slow panel once the shell has opened it"
(( $(grep -c "debugPanelTree slow.panel" "$FAKE_LOG") == 4 )) || fail "panel tree keeps asking while the panel opens" "$(cat "$FAKE_LOG")"
if tree --json stuck.panel >"$work/out" 2>"$work/err"; then fail "panel tree fails on a panel that never opens"; fi
[[ ! -s $work/out ]] || fail "panel tree prints nothing for a panel that never opens" "$(cat "$work/out")"
grep -q "never opened" "$work/err" || fail "panel tree says the panel never opened" "$(cat "$work/err")"
! grep -q summon "$FAKE_LOG" || fail "panel tree leaves summoning to the shell, which only opens bar panels" "$(cat "$FAKE_LOG")"
pass "panel tree prints the panel's item tree as text or JSON"
