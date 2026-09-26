#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const paint = requireFromRoot('shell/plugins/ascii-paint/PaintModel.js')

function glyph(canvas, col, row) {
  return paint.glyphAt(canvas, col, row)
}

const empty = paint.createCanvas(2, 2)
assertEqual(empty.cols, 2, 'createCanvas stores width')
assertEqual(empty.rows, 2, 'createCanvas stores height')
assertEqual(paint.serialize(empty), '\n\n', 'empty canvas serializes as blank lines with no trailing spaces')

const ul = paint.createCanvas(1, 1)
paint.setQuadrant(ul, 0, 0, 0, true)
assertEqual(glyph(ul, 0, 0), '\u2598', 'upper-left quadrant is ▘')

const ur = paint.createCanvas(1, 1)
paint.setQuadrant(ur, 0, 0, 1, true)
assertEqual(glyph(ur, 0, 0), '\u259d', 'upper-right quadrant is ▝')

const ll = paint.createCanvas(1, 1)
paint.setQuadrant(ll, 0, 0, 2, true)
assertEqual(glyph(ll, 0, 0), '\u2596', 'lower-left quadrant is ▖')

const lr = paint.createCanvas(1, 1)
paint.setQuadrant(lr, 0, 0, 3, true)
assertEqual(glyph(lr, 0, 0), '\u2597', 'lower-right quadrant is ▗')

const full = paint.createCanvas(1, 1)
paint.setBlockBits(full, 0, 0, 15)
assertEqual(glyph(full, 0, 0), '\u2588', 'all four quadrants are █')

const halves = paint.createCanvas(1, 1)
paint.setBlockBits(halves, 0, 0, 1 | 2)
assertEqual(glyph(halves, 0, 0), '\u2580', 'top two quadrants are ▀')
paint.setBlockBits(halves, 0, 0, 4 | 8)
assertEqual(glyph(halves, 0, 0), '\u2584', 'bottom two quadrants are ▄')
paint.setBlockBits(halves, 0, 0, 1 | 4)
assertEqual(glyph(halves, 0, 0), '\u258c', 'left two quadrants are ▌')
paint.setBlockBits(halves, 0, 0, 2 | 8)
assertEqual(glyph(halves, 0, 0), '\u2590', 'right two quadrants are ▐')

const allQuads = {
  0: ' ',
  1: '\u2598',
  2: '\u259d',
  3: '\u2580',
  4: '\u2596',
  5: '\u258c',
  6: '\u259e',
  7: '\u259b',
  8: '\u2597',
  9: '\u259a',
  10: '\u2590',
  11: '\u259c',
  12: '\u2584',
  13: '\u2599',
  14: '\u259f',
  15: '\u2588'
}
for (let bits = 0; bits < 16; bits++) {
  const cell = paint.createCanvas(1, 1)
  paint.setBlockBits(cell, 0, 0, bits)
  assertEqual(glyph(cell, 0, 0), allQuads[bits], 'block bits ' + bits + ' map to the matching glyph')
}

assertEqual(paint.quadrantAt(1, 1, 10, 20), 0, 'top-left of a cell is quadrant 0')
assertEqual(paint.quadrantAt(9, 1, 10, 20), 1, 'top-right of a cell is quadrant 1')
assertEqual(paint.quadrantAt(1, 19, 10, 20), 2, 'bottom-left of a cell is quadrant 2')
assertEqual(paint.quadrantAt(9, 19, 10, 20), 3, 'bottom-right of a cell is quadrant 3')

const braille = paint.createCanvas(1, 1)
paint.setBrailleDot(braille, 0, 0, 0, 0, true)
assertEqual(glyph(braille, 0, 0), '\u2801', 'braille dot 1 is the upper-left of the 2x4 grid')
paint.setBrailleDot(braille, 0, 0, 1, 3, true)
assertEqual(glyph(braille, 0, 0), '\u2881', 'braille dots 1 and 8 combine')

assertDeepEqual(paint.brailleDotAt(1, 1, 10, 20), { dx: 0, dy: 0 }, 'top-left of a cell is braille 0,0')
assertDeepEqual(paint.brailleDotAt(9, 19, 10, 20), { dx: 1, dy: 3 }, 'bottom-right of a cell is braille 1,3')

const shade = paint.createCanvas(1, 1)
paint.setShade(shade, 0, 0, 1)
assertEqual(glyph(shade, 0, 0), '\u2591', 'shade 1 is ░')
paint.setShade(shade, 0, 0, 2)
assertEqual(glyph(shade, 0, 0), '\u2592', 'shade 2 is ▒')
paint.setShade(shade, 0, 0, 3)
assertEqual(glyph(shade, 0, 0), '\u2593', 'shade 3 is ▓')
paint.setShade(shade, 0, 0, 4)
assertEqual(glyph(shade, 0, 0), '\u2588', 'shade 4 is █')
paint.setShade(shade, 0, 0, 0)
assertEqual(glyph(shade, 0, 0), ' ', 'shade 0 is empty')

const bar = paint.createCanvas(3, 3)
paint.lineStroke(bar, 0, 0, 2, 0, 'single')
assertEqual(glyph(bar, 0, 0) + glyph(bar, 1, 0) + glyph(bar, 2, 0), '\u2500\u2500\u2500', 'a horizontal stroke is ───')
paint.lineStroke(bar, 2, 0, 2, 2, 'single')
assertEqual(glyph(bar, 2, 0), '\u2510', 'joining a down stroke onto a bar makes ┐')
assertEqual(glyph(bar, 2, 1), '\u2502', 'the vertical run is │')
assertEqual(glyph(bar, 2, 2), '\u2502', 'the vertical end keeps │')

const tee = paint.createCanvas(3, 2)
paint.lineStroke(tee, 0, 0, 2, 0, 'single')
paint.lineStroke(tee, 1, 0, 1, 1, 'single')
assertEqual(glyph(tee, 1, 0), '\u252c', 'a stem dropped from a bar makes ┬')

const dbl = paint.createCanvas(2, 2)
paint.lineStroke(dbl, 0, 0, 1, 0, 'double')
paint.lineStroke(dbl, 1, 0, 1, 1, 'double')
assertEqual(glyph(dbl, 1, 0), '\u2557', 'double-line join is ╗')

const node = paint.createCanvas(1, 1)
paint.lineStroke(node, 0, 0, 0, 0, 'single')
assertEqual(glyph(node, 0, 0), '\u253c', 'a one-cell line click is ┼')

const box = paint.createCanvas(3, 3)
paint.rectangle(box, 0, 0, 2, 2, 'single')
assertEqual(glyph(box, 0, 0), '\u250c', 'rectangle top-left is ┌')
assertEqual(glyph(box, 2, 0), '\u2510', 'rectangle top-right is ┐')
assertEqual(glyph(box, 0, 2), '\u2514', 'rectangle bottom-left is └')
assertEqual(glyph(box, 2, 2), '\u2518', 'rectangle bottom-right is ┘')
assertEqual(glyph(box, 1, 0), '\u2500', 'rectangle top edge is ─')
assertEqual(glyph(box, 0, 1), '\u2502', 'rectangle left edge is │')

const fill = paint.createCanvas(3, 1)
paint.setBlockBits(fill, 0, 0, 15)
paint.setBlockBits(fill, 1, 0, 15)
paint.setBlockBits(fill, 2, 0, 1)
paint.floodFill(fill, 0, 0, { kind: 'shade', level: 2 })
assertEqual(glyph(fill, 0, 0), '\u2592', 'flood fill replaces the connected block')
assertEqual(glyph(fill, 1, 0), '\u2592', 'flood fill walks neighbors of the same cell')
assertEqual(glyph(fill, 2, 0), '\u2598', 'flood fill stops at a different cell')

const history = paint.createHistory()
const edited = paint.createCanvas(1, 1)
assertEqual(paint.canUndo(history), false, 'a new history cannot undo')
assertEqual(paint.canRedo(history), false, 'a new history cannot redo')
paint.checkpoint(history, edited)
assertEqual(paint.canUndo(history), false, 'a single checkpoint cannot undo')
paint.setShade(edited, 0, 0, 4)
paint.checkpoint(history, edited)
assertEqual(paint.canUndo(history), true, 'two checkpoints can undo')
assertEqual(paint.canRedo(history), false, 'a new checkpoint cannot redo')
const undone = paint.undo(history)
assertEqual(glyph(undone, 0, 0), ' ', 'undo restores the previous canvas')
assertEqual(paint.canUndo(history), false, 'undoing the last action cannot undo further')
assertEqual(paint.canRedo(history), true, 'undoing leaves a redo')
const redone = paint.redo(history)
assertEqual(glyph(redone, 0, 0), '\u2588', 'redo restores the undone canvas')
assertEqual(paint.canRedo(history), false, 'redoing the last action cannot redo further')

const twoEdits = paint.createCanvas(1, 1)
const twoHistory = paint.createHistory()
paint.checkpoint(twoHistory, twoEdits)
paint.setShade(twoEdits, 0, 0, 1)
paint.checkpoint(twoHistory, twoEdits)
paint.setShade(twoEdits, 0, 0, 4)
paint.checkpoint(twoHistory, twoEdits)
const undoneOnce = paint.undo(twoHistory)
assertEqual(glyph(undoneOnce, 0, 0), '\u2591', 'undo after two edits restores only the last edit')
const redoneOnce = paint.redo(twoHistory)
assertEqual(glyph(redoneOnce, 0, 0), '\u2588', 'redo restores only the undone edit')

const typed = paint.createCanvas(4, 1)
paint.writeText(typed, 1, 0, 'Hi')
assertEqual(glyph(typed, 1, 0) + glyph(typed, 2, 0) + glyph(typed, 3, 0), 'Hi ', 'writeText stamps literals from a cell')
paint.writeText(typed, 3, 0, 'xyz')
assertEqual(glyph(typed, 3, 0), 'x', 'writeText stops at the canvas edge')

const padded = paint.parse('x  \n')
assertEqual(paint.serialize(padded), 'x\n', 'serialize strips trailing spaces')

const unknown = paint.parse('Ω\n')
assertEqual(glyph(unknown, 0, 0), 'Ω', 'unknown characters survive as literals')
assertEqual(paint.serialize(unknown), 'Ω\n', 'literals round-trip')

function normalizeArt(text) {
  return String(text).replace(/[ ]+$/gm, '').replace(/\n+$/, '') + '\n'
}

const logo = fs.readFileSync(path.join(root, 'logo.txt'), 'utf8')
assertEqual(paint.serialize(paint.parse(logo)), normalizeArt(logo), 'logo.txt round-trips')

const icon = fs.readFileSync(path.join(root, 'icon.txt'), 'utf8')
assertEqual(paint.serialize(paint.parse(icon)), normalizeArt(icon), 'icon.txt round-trips')

const rendered = paint.render(paint.parse('█\n'))
assertEqual(rendered.length > 0, true, 'render returns a display string')

assertEqual(paint.pointerIntent(1, 1, 'block'), 'paint', 'left click paints in block mode')
assertEqual(paint.pointerIntent(1, 1, 'line'), 'paint', 'left click paints in line mode')
assertEqual(paint.pointerIntent(1, 1, 'fill'), 'paint', 'left click paints in fill mode')
assertEqual(paint.pointerIntent(1, 1, 'eraser'), 'erase', 'left click erases only in eraser mode')
assertEqual(paint.pointerIntent(2, 2, 'block'), 'erase', 'right click erases in block mode')
assertEqual(paint.pointerIntent(1, 3, 'block'), 'paint', 'left+right bits still paint')
assertEqual(paint.pointerIntent(0, 0, 'block'), 'ignore', 'a press with no button is ignored')
assertEqual(paint.pointerIntent(undefined, undefined, 'block'), 'ignore', 'an unset button is ignored, not treated as erase')

const stamp = paint.createCanvas(1, 1)
paint.applyStamp(stamp, { tool: 'block', intent: 'paint', col: 0, row: 0, lx: 1, ly: 1, cellW: 10, cellH: 20 })
assertEqual(glyph(stamp, 0, 0), '\u2598', 'a left-click block stamp paints a quadrant')
paint.applyStamp(stamp, { tool: 'block', intent: 'paint', col: 0, row: 0, lx: 9, ly: 1, cellW: 10, cellH: 20 })
assertEqual(glyph(stamp, 0, 0), '\u2580', 'a second block stamp adds, it does not erase')
paint.setBlockBits(stamp, 0, 0, 15)
paint.applyStamp(stamp, { tool: 'block', intent: 'erase', col: 0, row: 0, lx: 5, ly: 1, cellW: 10, cellH: 20 })
assertEqual(glyph(stamp, 0, 0), '\u2584', 'an erase intent removes the top half')
paint.applyStamp(stamp, { tool: 'shade', intent: 'paint', col: 0, row: 0, lx: 1, ly: 1, cellW: 10, cellH: 20, shadeLevel: 2 })
assertEqual(glyph(stamp, 0, 0), '\u2592', 'shade paint writes a gradient, not a blank')

const half = paint.createCanvas(1, 1)
paint.setBlockBits(half, 0, 0, 15)
paint.eraseHalf(half, 0, 0, 5, 1, 10, 20)
assertEqual(glyph(half, 0, 0), '\u2584', 'erasing the top of a full block leaves ▄')
paint.eraseHalf(half, 0, 0, 5, 19, 10, 20)
assertEqual(glyph(half, 0, 0), ' ', 'erasing the remaining bottom half clears the cell')

const side = paint.createCanvas(1, 1)
paint.setBlockBits(side, 0, 0, 15)
paint.eraseHalf(side, 0, 0, 1, 10, 10, 20)
assertEqual(glyph(side, 0, 0), '\u2590', 'erasing the left of a full block leaves ▐')

const baseLine = paint.createCanvas(3, 3)
const preview = paint.withStroke(baseLine, 'line', 0, 0, 2, 0, 'single')
assertEqual(glyph(preview, 0, 0) + glyph(preview, 1, 0) + glyph(preview, 2, 0), '\u2500\u2500\u2500', 'a line preview draws the stroke')
assertEqual(glyph(baseLine, 1, 0), ' ', 'a line preview does not mutate the committed canvas')
const committed = paint.withStroke(baseLine, 'line', 0, 0, 2, 0, 'single')
assertEqual(paint.serialize(committed), paint.serialize(preview), 'committing a line matches the last preview')

const baseBox = paint.createCanvas(3, 3)
const boxPreview = paint.withStroke(baseBox, 'rect', 0, 0, 2, 2, 'single')
assertEqual(glyph(boxPreview, 0, 0), '\u250c', 'a rect preview draws the box')
assertEqual(glyph(baseBox, 0, 0), ' ', 'a rect preview does not mutate the committed canvas')

assertEqual(paint.backupPath('/tmp/art.txt'), '/tmp/art.txt.bak', 'save backs up beside the file as .bak')

const seed = paint.createCanvas(1, 1)
paint.setBlockBits(seed, 0, 0, 15)
const above = paint.pad(seed, 1, 0, 0, 0)
assertEqual(above.rows, 2, 'pad above adds a row')
assertEqual(glyph(above, 0, 0), ' ', 'pad above leaves the new row empty')
assertEqual(glyph(above, 0, 1), '\u2588', 'pad above keeps the original cells below')
const left = paint.pad(seed, 0, 0, 0, 2)
assertEqual(left.cols, 3, 'pad left adds columns')
assertEqual(glyph(left, 2, 0), '\u2588', 'pad left keeps the original cells to the right')
assertEqual(glyph(left, 0, 0), ' ', 'pad left leaves the new columns empty')

const tall = paint.pad(seed, 1, 0, 1, 0)
const croppedTop = paint.crop(tall, 1, 0, 0, 0)
assertEqual(croppedTop.rows, 2, 'crop top removes a row')
assertEqual(glyph(croppedTop, 0, 0), '\u2588', 'crop top keeps the original cells')
const wide = paint.pad(seed, 0, 0, 0, 2)
const croppedLeft = paint.crop(wide, 0, 0, 0, 1)
assertEqual(croppedLeft.cols, 2, 'crop left removes a column')
assertEqual(glyph(croppedLeft, 1, 0), '\u2588', 'crop left keeps the original cells')
const tiny = paint.crop(seed, 1, 1, 1, 1)
assertEqual(tiny.cols, 1, 'crop will not shrink width below 1')
assertEqual(tiny.rows, 1, 'crop will not shrink height below 1')
JS

qml="$ROOT/shell/plugins/ascii-paint/AsciiPaint.qml"
manifest="$ROOT/shell/plugins/ascii-paint/manifest.json"
[[ -f $manifest ]] || fail "ascii-paint ships a plugin manifest"
jq -e '.id == "omarchy.ascii-paint" and (.kinds | index("overlay")) and .entryPoints.overlay == "AsciiPaint.qml"' "$manifest" >/dev/null ||
  fail "ascii-paint manifest is an overlay plugin"
pass "ascii-paint manifest is an overlay plugin"
[[ -f $qml ]] || fail "ascii-paint overlay QML exists"
grep -q 'Undo' "$qml" || fail "paint overlay has an Undo button"
grep -q 'Redo' "$qml" || fail "paint overlay has a Redo button"
grep -q 'canUndo' "$qml" || fail "undo is disabled when the history is empty"
grep -q 'afterChromeClick' "$qml" || fail "toolbar clicks do not leak a canvas stroke"
grep -q 'if (root.ignoreCanvas' "$qml" || fail "canvas presses honor ignoreCanvas"
grep -q 'preventStealing: true' "$qml" || fail "the toolbar keeps the pointer grab"
grep -q 'onPressedChanged: if (pressed) root.afterChromeClick()' "$qml" || fail "toolbar presses arm ignoreCanvas immediately, not only on release"
grep -q 'TapHandler' "$ROOT/shell/Ui/Button.qml" || fail "buttons take presses on their full bounds"
grep -q 'TakeOverForbidden' "$ROOT/shell/Ui/Button.qml" || fail "button taps are not stolen by a drag underneath"
grep -q 'hasUnsavedChanges' "$qml" || fail "close prompt requires unsaved history"
grep -q 'Keep (K)' "$qml" || fail "exit confirmation labels Keep with K"
grep -q 'Discard (D)' "$qml" || fail "exit confirmation labels Discard with D"
grep -q 'cancelKey: Qt.Key_K' "$qml" || fail "K keeps the unsaved paint"
grep -q 'confirmKey: Qt.Key_D' "$qml" || fail "D discards the unsaved paint"
python3 - <<'PY' "$ROOT/shell/Ui/ConfirmDialog.qml" || fail "an open confirm dialog consumes leftover keys"
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
m = re.search(r"function handleKey\(event\) \{([\s\S]*?)\n  \}", text)
if not m:
    raise SystemExit(1)
body = m.group(1)
if "cancelKey" not in body or "confirmKey" not in body:
    raise SystemExit(1)
if not body.rstrip().endswith("return true"):
    raise SystemExit(1)
PY
if grep -q '{ value: "dline"' "$qml"; then fail "double line is a palette, not a tool"; fi
grep -q 'lineStyle' "$qml" || fail "line and rect share a single/double palette"
grep -q 'pointerIntent' "$qml" || fail "canvas presses go through pointerIntent"
grep -q 'applyStamp' "$qml" || fail "stamps go through applyStamp"
grep -q 'strokeIntent' "$qml" || fail "a stroke keeps the intent from press through release"
grep -q 'function open(payloadJson)' "$qml" || fail "ascii-paint overlay implements open()"
grep -q 'function close()' "$qml" || fail "ascii-paint overlay implements close()"
pass "ascii-paint overlay implements open and close"
grep -q 'Qt.Key_1' "$qml" || fail "paint overlay maps number keys to shades"
grep -q 'Block (B)' "$qml" || fail "tool buttons keep their names and shortcuts"
grep -q 'Text (T)' "$qml" || fail "text is a tool with a keyboard shortcut"
grep -q 'Qt.Key_T' "$qml" || fail "T selects the text tool"
grep -q 'commitText' "$qml" || fail "Enter commits an in-progress text run"
grep -q 'Palette' "$qml" || fail "palette is labeled separately from tools"
python3 - <<'PY' "$qml" || fail "strokes checkpoint after the edit, so undo reverts one action"
import pathlib, re, sys

def body(text, name):
    m = re.search(r"function " + re.escape(name) + r"\([^)]*\) \{", text)
    if not m:
        raise SystemExit(1)
    i = m.end() - 1
    depth = 0
    for j in range(i, len(text)):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
    raise SystemExit(1)

text = pathlib.Path(sys.argv[1]).read_text()
begin = body(text, "beginStroke")
end = body(text, "endStroke")
grow = body(text, "growCanvas")
if "checkpoint(" in begin:
    raise SystemExit(1)
if "checkpoint(" not in end:
    raise SystemExit(1)
pad = grow.find("root.canvas =")
chk = grow.find("checkpoint(")
if pad < 0 or chk < 0 or chk < pad:
    raise SystemExit(1)
PY
grep -q 'growCanvas' "$qml" || fail "canvas can grow from each edge"
grep -q 'text: "Zoom"' "$qml" || fail "zoom controls are labeled Zoom"
grep -q 'ScrollBar' "$qml" || fail "canvas flickable has scroll bars"
grep -q 'parent: canvasHost' "$qml" || fail "scroll bars sit outside the canvas"
grep -q 'ScrollBar.AsNeeded' "$qml" || fail "scroll bars hide when the canvas fits"
python3 - <<'PY' "$qml" || fail "picking a palette shade does not switch the current tool"
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
idx = text.find("value: String(root.shadeLevel)")
if idx < 0:
    raise SystemExit(1)
chunk = text[idx:idx + 800]
if "setTool(\"shade\")" in chunk:
    raise SystemExit(1)
PY
pass "paint overlay maps keys and shows tooltips"
grep -q 'backupPath' "$qml" || fail "paint overlay writes a .bak before save"
pass "paint overlay writes a .bak before save"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q '"style.screensaver.paint"' "$menu" || fail "screensaver menu has a Paint entry"
grep -q '"style.about.paint"' "$menu" || fail "about menu has a Paint entry"
pass "branding menus have Paint entries"

select="$ROOT/bin/omarchy-file-select"
grep -q '"--save"' "$select" || fail "file select accepts --save"
grep -q 'SaveFile' "$select" || fail "file select save uses the portal SaveFile method"
pass "file select save uses the portal SaveFile method"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home/.config/omarchy/branding"
cat >"$tmp_dir/bin/omarchy-shell" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >"$tmp_dir/ipc"
STUB
chmod +x "$tmp_dir/bin/omarchy-shell"

export HOME="$tmp_dir/home"
export OMARCHY_PATH="$ROOT"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

omarchy-ascii-paint
grep -q 'shell summon omarchy.ascii-paint {}' "$tmp_dir/ipc" || fail "paint with no path summons a blank canvas" "ipc: $(cat "$tmp_dir/ipc")"
pass "paint with no path summons a blank canvas"

omarchy-ascii-paint "$tmp_dir/home/art.txt"
python3 - "$tmp_dir/ipc" "$tmp_dir/home/art.txt" <<'PY' || fail "paint with a path hands it to the overlay"
import json, sys
ipc = open(sys.argv[1]).read().strip()
prefix, payload = ipc.split(" ", 3)[0:3], ipc.split(" ", 3)[-1]
if "shell summon omarchy.ascii-paint" not in ipc:
    raise SystemExit(1)
data = json.loads(payload)
if data.get("path") != sys.argv[2]:
    raise SystemExit(1)
PY
pass "paint with a path hands it to the overlay"

cp "$ROOT/logo.txt" "$HOME/.config/omarchy/branding/screensaver.txt"
omarchy-branding-screensaver paint
python3 - "$tmp_dir/ipc" "$HOME/.config/omarchy/branding/screensaver.txt" <<'PY' || fail "screensaver paint previews after save"
import json, sys
ipc = open(sys.argv[1]).read()
data = json.loads(ipc.split(" ", 3)[-1])
if data.get("path") != sys.argv[2] or data.get("preview") != "screensaver":
    raise SystemExit(1)
PY
pass "screensaver paint previews after save"

cp "$ROOT/icon.txt" "$HOME/.config/omarchy/branding/about.txt"
omarchy-branding-about paint
python3 - "$tmp_dir/ipc" "$HOME/.config/omarchy/branding/about.txt" <<'PY' || fail "about paint previews after save"
import json, sys
ipc = open(sys.argv[1]).read()
data = json.loads(ipc.split(" ", 3)[-1])
if data.get("path") != sys.argv[2] or data.get("preview") != "about":
    raise SystemExit(1)
PY
pass "about paint previews after save"

require_compositor "ascii-paint pointer fixture"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping ascii-paint pointer fixture"
  exit 0
fi

pointer_tmp=$(mktemp -d)
trap 'rm -rf "$tmp_dir" "$pointer_tmp"' EXIT
cp "$SHELL_TEST_DIR/fixtures/ascii-paint-pointer/shell.qml" "$pointer_tmp/shell.qml"
ln -s "$ROOT/shell/plugins/ascii-paint" "$pointer_tmp/ascii-paint"

pointer_out=$(timeout 8 quickshell -p "$pointer_tmp" --no-color 2>&1) || true

if ! grep -q "RESULT pass" <<<"$pointer_out"; then
  printf '%s\n' "$pointer_out" >&2
  fail "ascii-paint left click paints and right click erases"
fi
pass "ascii-paint left click paints and right click erases"
