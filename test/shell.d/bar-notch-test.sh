#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const styleSource = fs.readFileSync(root + '/shell/Commons/Style.qml', 'utf8')

assertEqual(bar.notchHeight('eDP-1', 1512, 982, 2), 32, 'MacBook Pro 14" at scale 2 uses its measured 32px cutout')
assertEqual(bar.notchHeight('eDP-1', 1890, 1227, 1.6), 40, 'MacBook Pro 14" at scale 1.6 uses its measured cutout')
assertEqual(bar.notchHeight('eDP-1', 1728, 1117, 2), 32, 'MacBook Pro 16" at scale 2 uses its measured 32px cutout')

assertEqual(bar.notchHeight('eDP-1', 1280, 832, 2), 32, 'MacBook Air 13.6" at scale 2 falls back to its 32px strip')
assertEqual(bar.notchHeight('eDP-1', 1600, 1040, 1.6), 40, 'MacBook Air 13.6" at scale 1.6 falls back to its 40px strip')

assertEqual(bar.notchHeight('eDP-1', 1280, 800, 2), 0, 'an exactly 16:10 panel (M1 Air) has no notch')
assertEqual(bar.notchHeight('DP-1', 1512, 982, 2), 0, 'external monitors never report a notch')
assertEqual(bar.notchHeight('eDP-1', 982, 1512, 2), 0, 'a rotated panel is not mistaken for a notch')
assertEqual(bar.notchHeight('eDP-1', 1128, 752, 2), 0, 'a 3:2 panel is not mistaken for a notch')
assertEqual(bar.notchHeight('eDP-1', 0, 0, 2), 0, 'degenerate screen sizes report no notch')
assertEqual(bar.notchHeight('', 1512, 982, 2), 0, 'a missing screen name reports no notch')
assertEqual(bar.notchHeight('eDP-1', 1512, 982, 0), 37, 'a missing scale still yields the strip fallback')

assert(
  /notchFloor: root\.appleSiliconHost && root\.position === "top"/.test(barSource),
  'bar floors only top bars on Apple Silicon machines'
)
assert(
  /BarModel\.notchHeight\(screen\.name, screen\.width, screen\.height, screen\.devicePixelRatio\)/.test(barSource),
  'bar derives the floor from its own screen geometry'
)
assert(
  /implicitHeight: root\.vertical \? 0 : Math\.max\(root\.barSize, notchFloor\)/.test(barSource),
  'bar height is floored at the notch, never shrunk to it'
)

assert(
  /Style\.bar\.notchHeight > 0[\s\S]{0,80}\? Style\.bar\.notchHeight/.test(barSource),
  'a calibrated notch-height overrides the derived floor'
)
assert(
  /notchHeight:[\s\S]{0,240}barOverrides\["notch-height"\]/.test(styleSource) &&
    !/barToken\("notch-height"/.test(styleSource),
  'notch-height is read raw, not through the font-scaled bar tokens'
)
JS

[[ -x $ROOT/bin/omarchy-hw-apple-silicon ]] ||
  fail "omarchy-hw-apple-silicon helper is executable"
pass "omarchy-hw-apple-silicon helper is executable"

migration=""
for f in "$ROOT/migrations/"*.sh; do
  if grep -q 'omarchy-hw-apple-silicon' "$f" && grep -q 'centerAnchor' "$f"; then
    migration=$f
    break
  fi
done
[[ -n $migration ]] || fail "Apple Silicon notch layout migration is present"
pass "Apple Silicon notch layout migration is present"

mig_home=$(mktemp -d)
mig_bin=$(mktemp -d)
cleanup_mig() { rm -rf "$mig_home" "$mig_bin"; }
trap cleanup_mig EXIT

mkdir -p "$mig_home/.config/omarchy" "$mig_bin"
cat >"$mig_home/.config/omarchy/shell.json" <<'JSON'
{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":[{"id":"omarchy.clock"}],"right":[{"id":"omarchy.tray"}]}}}
JSON
cat >"$mig_bin/omarchy-hw-apple-silicon" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mig_bin/omarchy-hw-apple-silicon"

HOME="$mig_home" PATH="$mig_bin:$PATH" bash "$migration"

jq -e '.bar.centerAnchor == "" and (.bar.layout.center | length) == 0 and .bar.layout.right[0].id == "omarchy.clock"' \
  "$mig_home/.config/omarchy/shell.json" >/dev/null ||
  fail "notch migration clears center and moves widgets right on Apple Silicon"
pass "notch migration clears center and moves widgets right on Apple Silicon"
