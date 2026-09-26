#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "ascii paint pointer and keyboard"
require_command quickshell

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/config/paint" "$work/config/bin" "$work/home" "$work/omarchy/bin"
ln -s "$ROOT/shell/Commons" "$work/config/Commons"
ln -s "$ROOT/shell/Ui" "$work/config/Ui"
cp "$ROOT/shell/plugins/ascii-paint/AsciiPaint.qml" "$work/config/paint/AsciiPaint.qml"
cp "$ROOT/shell/plugins/ascii-paint/PaintModel.js" "$work/config/paint/PaintModel.js"
printf 'module qs.paint\nAsciiPaint 1.0 AsciiPaint.qml\n' > "$work/config/paint/qmldir"
cp "$SHELL_TEST_DIR/fixtures/ascii-paint-input/shell.qml" "$work/config/shell.qml"

printf 'ab\ncd\n' > "$work/home/seeded.txt"
printf 'o\n' > "$work/home/opened.txt"
printf ' \n' > "$work/home/blank.txt"

cat > "$work/omarchy/bin/omarchy-file-select" << EOF
#!/bin/bash
if [[ \$* == *--save* ]]; then
  printf '%s\n' "$work/home/saved-as.txt"
else
  printf '%s\n' "$work/home/opened.txt"
fi
EOF
cat > "$work/omarchy/bin/omarchy-launch-screensaver" << EOF
#!/bin/bash
printf '%s\n' "\$*" >> "$work/home/preview.log"
EOF
cat > "$work/omarchy/bin/omarchy-launch-about" << EOF
#!/bin/bash
printf '%s\n' "\$*" >> "$work/home/preview.log"
EOF
chmod +x "$work/omarchy/bin/omarchy-file-select" "$work/omarchy/bin/omarchy-launch-screensaver" "$work/omarchy/bin/omarchy-launch-about"

log=$work/home/quickshell.log
set +e
HOME="$work/home" OMARCHY_PATH="$work/omarchy" PAINT_TEST_DIR="$work/home" \
  timeout 30 quickshell -p "$work/config" --no-color >"$log" 2>&1
status=$?
set -e

if (( status != 0 )) || ! grep -q 'RESULT pass' "$log"; then
  cat "$log" >&2
  fail "ascii paint pointer and keyboard suite" "quickshell status $status"
fi

expected=(
  "RESULT ok blank canvas and disabled history"
  "RESULT ok block clicks, erase, and ignored pointers"
  "RESULT ok block drag"
  "RESULT ok lines and rectangles"
  "RESULT ok shade keys and wheel"
  "RESULT ok flood fill"
  "RESULT ok text entry"
  "RESULT ok undo and redo"
  "RESULT ok zoom"
  "RESULT ok canvas edges"
  "RESULT ok save "
  "RESULT ok discard dialog"
  "RESULT ok open and save as"
  "RESULT pass"
)
for line in "${expected[@]}"; do
  grep -q "$line" "$log" || fail "ascii paint input reported $line" "$(cat "$log")"
done
pass "ascii paint pointer and keyboard suite"

grep -q $'\xe2\x96\x98' "$work/home/blank.txt" || fail "save wrote the quadrant the pointer painted" "$(cat "$work/home/blank.txt")"
pass "save wrote the quadrant the pointer painted"
[[ -f $work/home/blank.txt.bak ]] || fail "save keeps the previous file as .bak"
pass "save keeps the previous file as .bak"
grep -q 'force' "$work/home/preview.log" || fail "save with a screensaver preview launches the screensaver" "$(cat "$work/home/preview.log")"
pass "save with a screensaver preview launches the screensaver"
[[ -f $work/home/saved-as.txt ]] || fail "save as wrote the chooser path"
pass "save as wrote the chooser path"
