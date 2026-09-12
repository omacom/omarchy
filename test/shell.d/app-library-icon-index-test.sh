#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node
require_command gsettings

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Fixture icon tree with adversarial layout: small rasters exist alongside
# crisp sources so readdir luck alone would serve blurry files.
data="$tmp/data"
fake="$data/icons/FakeTheme"
mid="$data/icons/MidTheme"
other="$data/icons/OtherTheme"
hicolor="$data/icons/hicolor"
mkdir -p \
  "$fake/16x16/apps" "$fake/48x48/apps" "$fake/scalable/apps" \
  "$mid/48x48/apps" \
  "$other/48x48/apps" \
  "$hicolor/scalable/apps" "$hicolor/48x48/apps"

printf '[Icon Theme]\nName=FakeTheme\nInherits=MidTheme\n' >"$fake/index.theme"
printf '[Icon Theme]\nName=MidTheme\nInherits=hicolor\n' >"$mid/index.theme"
printf '[Icon Theme]\nName=OtherTheme\n' >"$other/index.theme"
printf '[Icon Theme]\nName=hicolor\n' >"$hicolor/index.theme"

# zzvec: every tier has it; scalable svg in the active theme must win.
touch "$fake/16x16/apps/zzvec.png"
touch "$fake/48x48/apps/zzvec.png"
touch "$fake/scalable/apps/zzvec.svg"
touch "$hicolor/scalable/apps/zzvec.svg"
# zzras: rasters only; largest must win.
touch "$fake/16x16/apps/zzras.png"
touch "$fake/48x48/apps/zzras.png"
# zztheme: tiny themed file only; theme priority keeps it over nothing.
touch "$fake/16x16/apps/zztheme.png"
# zzmid: only in the inherited theme.
touch "$mid/48x48/apps/zzmid.png"
# zzother: only in a theme outside the chain; last-resort sweep finds it.
touch "$other/48x48/apps/zzother.png"
# zzgadget: hicolor-only name.
touch "$hicolor/scalable/apps/zzgadget.svg"

stub_bin="$tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/gsettings" <<'EOF'
#!/bin/bash
printf '%s' "${FAKE_ICON_THEME-'FakeTheme'}"
EOF
chmod +x "$stub_bin/gsettings"

scan_command() {
  node -e '
const fs = require("fs");
const qml = fs.readFileSync(process.env.ROOT + "/shell/services/AppLibrary.qml", "utf8");
const m = qml.match(/function iconIndexScanCommand\(\) \{([\s\S]*?)\n  \}/);
if (!m) { console.error("iconIndexScanCommand not found"); process.exit(1); }
const fn = new Function(m[1] + "; return iconIndexScanCommand();");
console.log(fn());
'
}

run_scan() {
  env -i HOME="$tmp/home" XDG_DATA_DIRS="$tmp/data" \
    "FAKE_ICON_THEME=$1" PATH="$stub_bin:/usr/bin:/bin" \
    bash -c "$2" 2>"$tmp/stderr"
}

cmd=$(scan_command)
[[ -n $cmd ]] || fail "icon index scan command extracts from AppLibrary.qml"

out=$(run_scan "'FakeTheme'" "$cmd")
[[ -s $tmp/stderr ]] && fail "icon index scan runs silently" "$(cat "$tmp/stderr")"

winner() {
  grep -m1 "/$1\.\(svg\|png\)$" <<<"$out" || fail "icon index finds fixture icon $1"
}

[[ $(winner zzvec) == "$fake/scalable/apps/zzvec.svg" ]] ||
  fail "icon index prefers the active theme's scalable svg" "$(winner zzvec)"
[[ $(winner zzras) == "$fake/48x48/apps/zzras.png" ]] ||
  fail "icon index prefers the largest raster" "$(winner zzras)"
[[ $(winner zztheme) == "$fake/16x16/apps/zztheme.png" ]] ||
  fail "icon index keeps small themed files over no fallback" "$(winner zztheme)"
[[ $(winner zzmid) == "$mid/48x48/apps/zzmid.png" ]] ||
  fail "icon index follows the Inherits chain" "$(winner zzmid)"
[[ $(winner zzother) == "$other/48x48/apps/zzother.png" ]] ||
  fail "icon index sweeps non-chain themes as a last resort" "$(winner zzother)"
[[ $(winner zzgadget) == "$hicolor/scalable/apps/zzgadget.svg" ]] ||
  fail "icon index falls back to hicolor" "$(winner zzgadget)"
pass "icon index orders theme, size, and fallback coverage deterministically"

out=$(run_scan "" "$cmd")
[[ -s $tmp/stderr ]] && fail "icon index scan runs silently without a theme" "$(cat "$tmp/stderr")"
[[ $(winner zzvec) == "$hicolor/scalable/apps/zzvec.svg" ]] ||
  fail "icon index falls back to hicolor without a theme" "$(winner zzvec)"
pass "icon index falls back to hicolor without a theme"
