#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Config parsing only. Do not talk to the live compositor.
unset WAYLAND_DISPLAY

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

bin="$tmpdir/bin"
mkdir -p "$bin"
printf '#!/bin/bash\nexit 1\n' >"$bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$bin/pkill"
printf '#!/bin/bash\necho "JetBrainsMono Nerd Font"\n' >"$bin/omarchy-font-current"
printf '#!/bin/bash\nexit 0\n' >"$bin/omarchy-notification-send"
chmod +x "$bin"/*

run_size() {
  HOME="$1" XDG_CONFIG_HOME="$2" PATH="$bin:$ROOT/bin:$PATH" omarchy-font-size "$@"
}

run_migration() {
  HOME="$1" XDG_CONFIG_HOME="$2" PATH="$bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1789224260.sh" >/dev/null
}

# --- Foot include lands in [main], not under the last section ---
foot_home="$tmpdir/foot-home"
mkdir -p "$foot_home/.config/foot" "$foot_home/.local/state/omarchy/current/theme"
: >"$foot_home/.local/state/omarchy/current/theme/foot.ini"
cat >"$foot_home/.config/foot/foot.ini" <<'INI'
[main]
include=~/.local/state/omarchy/current/theme/foot.ini
term=xterm-256color
font=JetBrainsMono Nerd Font:size=9
pad=14x14

[scrollback]
lines=10000

[text-bindings]
\x1b[13;2u=Shift+Return
INI

run_migration "$foot_home" "$foot_home/.config"
foot_section=$(awk '/^\[/ { s = $0 } /^include=.*foot\/local\.ini/ { print s; exit }' "$foot_home/.config/foot/foot.ini")
[[ $foot_section == "[main]" ]] || fail "migration adds the Foot overlay include to [main]" "include landed in section: $foot_section"
font_line=$(grep -n '^font=' "$foot_home/.config/foot/foot.ini" | head -1 | cut -d: -f1)
include_line=$(grep -n 'foot/local\.ini' "$foot_home/.config/foot/foot.ini" | head -1 | cut -d: -f1)
[[ $include_line -gt $font_line ]] ||
  fail "Foot overlay include comes after the shared font line" "font:$font_line include:$include_line"
grep -qx 'include=~/.config/foot/local.ini' "$foot_home/.config/foot/foot.ini" ||
  fail "Foot include uses ~ so the shared config does not carry this home" "$(grep include= "$foot_home/.config/foot/foot.ini")"
[[ $(grep -c 'foot/local\.ini' "$foot_home/.config/foot/foot.ini") -eq 1 ]] ||
  fail "migration adds the Foot include once" "$(cat "$foot_home/.config/foot/foot.ini")"
run_migration "$foot_home" "$foot_home/.config"
[[ $(grep -c 'foot/local\.ini' "$foot_home/.config/foot/foot.ini") -eq 1 ]] ||
  fail "migration does not duplicate the Foot include" "$(cat "$foot_home/.config/foot/foot.ini")"
if command -v foot >/dev/null; then
  HOME="$foot_home" XDG_CONFIG_HOME="$foot_home/.config" foot -C >/dev/null 2>"$tmpdir/foot-check.err" ||
    fail "migrated Foot config passes foot --check-config" "$(cat "$tmpdir/foot-check.err")"
fi
pass "migrated Foot config includes the overlay from [main]"

# No [main] at all: write the header, then the include.
nomain="$tmpdir/foot-nomain"
mkdir -p "$nomain/.config/foot"
printf 'font=Iosevka Term:size=10\n' >"$nomain/.config/foot/foot.ini"
run_migration "$nomain" "$nomain/.config"
nomain_section=$(awk '/^\[/ { s = $0 } /^include=.*foot\/local\.ini/ { print s; exit }' "$nomain/.config/foot/foot.ini")
[[ $nomain_section == "[main]" ]] || fail "migration writes [main] when Foot has none" "section: $nomain_section"
pass "migration writes a [main] header when Foot has none"

# --- Kitty globinclude is relative, including the duplicate check ---
kitty_home="$tmpdir/kitty-home"
mkdir -p "$kitty_home/.config/kitty"
printf 'font_size 13\n# mentions local.conf in a comment\n' >"$kitty_home/.config/kitty/kitty.conf"
run_size "$kitty_home" "$kitty_home/.config" 13 >/dev/null
[[ $(grep -c '^globinclude local.conf$' "$kitty_home/.config/kitty/kitty.conf") -eq 1 ]] ||
  fail "Kitty overlay include is a relative globinclude" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
run_size "$kitty_home" "$kitty_home/.config" 14 >/dev/null
[[ $(grep -c '^globinclude local.conf$' "$kitty_home/.config/kitty/kitty.conf") -eq 1 ]] ||
  fail "Kitty relative globinclude is not duplicated" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
grep -qx 'font_size 14.0' "$kitty_home/.config/kitty/local.conf" ||
  fail "Kitty overlay keeps the new size" "$(cat "$kitty_home/.config/kitty/local.conf")"

printf 'globinclude ~/.config/kitty/local.conf\n' >"$kitty_home/.config/kitty/kitty.conf"
run_size "$kitty_home" "$kitty_home/.config" 14 >/dev/null
grep -qx 'globinclude local.conf' "$kitty_home/.config/kitty/kitty.conf" ||
  fail "an absolute Kitty globinclude is rewritten to local.conf" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
[[ $(grep -c 'globinclude' "$kitty_home/.config/kitty/kitty.conf") -eq 1 ]] ||
  fail "rewriting Kitty globinclude does not leave the absolute line" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
pass "Kitty globinclude is relative"

if "$ROOT/bin/omarchy-cmd-present" kitty; then
  output=$(HOME="$kitty_home" kitty +runpy '
import sys
from kitty.config import load_config
errors = []
opts = load_config(sys.argv[1], sys.argv[2], accumulate_bad_lines=errors)
print(opts.font_size)
for e in errors:
    print("bad line:", e.line, "->", type(e.exception).__name__ + ":", e.exception)
' "$ROOT/etc/xdg/kitty/kitty.conf" "$kitty_home/.config/kitty/kitty.conf" 2>/dev/null || true)
  [[ $output == "14.0" ]] || fail "Kitty applies the size from kitty/local.conf" "$output"
  pass "Kitty applies the size from kitty/local.conf"
else
  pass "Kitty not installed; skipping native overlay check"
fi

# --- Each terminal keeps its own size; Foot keeps the shared family ---
per="$tmpdir/per-home"
mkdir -p "$per/.config/ghostty" "$per/.config/kitty" "$per/.config/foot" "$per/.config/alacritty"
printf 'font-family = "JetBrainsMono Nerd Font"\nfont-size = 9\n' >"$per/.config/ghostty/config"
printf 'font_size 16\n' >"$per/.config/kitty/kitty.conf"
printf '[main]\nfont=Iosevka Term:size=11\n' >"$per/.config/foot/foot.ini"
cat >"$per/.config/alacritty/alacritty.toml" <<'TOML'
general.import = [ "~/.local/state/omarchy/current/theme/alacritty.toml" ]

[font]
size = 12
TOML
run_migration "$per" "$per/.config"
grep -qx 'font-size = 9' "$per/.config/ghostty/local" ||
  fail "migration keeps Ghostty's own size" "$(cat "$per/.config/ghostty/local")"
grep -qx 'font_size 16.0' "$per/.config/kitty/local.conf" ||
  fail "migration keeps Kitty's own size" "$(cat "$per/.config/kitty/local.conf")"
grep -qx 'font=Iosevka Term:size=11' "$per/.config/foot/local.ini" ||
  fail "migration keeps Foot's own family and size" "$(cat "$per/.config/foot/local.ini")"
grep -qx 'size = 12' "$per/.config/alacritty/local.toml" ||
  fail "migration keeps Alacritty's own size" "$(cat "$per/.config/alacritty/local.toml")"
! grep -q 'JetBrainsMono' "$per/.config/foot/local.ini" ||
  fail "migration does not substitute omarchy-font-current for Foot" "$(cat "$per/.config/foot/local.ini")"
pass "migration keeps each terminal's own size"

# --- Trailing whitespace, inline comment, and a non-number ---
ws="$tmpdir/ws-home"
mkdir -p "$ws/.config/ghostty"
printf 'font-family = "JetBrainsMono Nerd Font"\nfont-size = 11 \n' >"$ws/.config/ghostty/config"
if ! run_migration "$ws" "$ws/.config"; then
  fail "migration tolerates trailing whitespace after the size"
fi
grep -qx 'font-size = 11' "$ws/.config/ghostty/local" ||
  fail "migration keeps size 11" "$(cat "$ws/.config/ghostty/local" 2>/dev/null || true)"
pass "migration tolerates trailing whitespace after the size"

comment="$tmpdir/comment-home"
mkdir -p "$comment/.config/alacritty"
cat >"$comment/.config/alacritty/alacritty.toml" <<'TOML'
general.import = [ "~/.local/state/omarchy/current/theme/alacritty.toml" ]

[font]
size = 12 # laptop
TOML
if ! run_migration "$comment" "$comment/.config"; then
  fail "migration tolerates a TOML inline comment after the size"
fi
grep -qx 'size = 12' "$comment/.config/alacritty/local.toml" ||
  fail "migration keeps the size before the comment" "$(cat "$comment/.config/alacritty/local.toml" 2>/dev/null || true)"
pass "migration tolerates a TOML inline comment after the size"

bad="$tmpdir/bad-home"
mkdir -p "$bad/.config/ghostty"
printf 'font-size = nope\n' >"$bad/.config/ghostty/config"
if ! run_migration "$bad" "$bad/.config"; then
  fail "migration continues when the size is not a number"
fi
grep -qx 'font-size = 9' "$bad/.config/ghostty/local" ||
  fail "a non-numeric size falls back to 9" "$(cat "$bad/.config/ghostty/local" 2>/dev/null || true)"
pass "migration uses 9 when the size is not a number"

# 0 and 500 stay valid. This command does not grow a range check.
range="$tmpdir/range-home"
mkdir -p "$range/.config"
run_size "$range" "$range/.config" 0 >/dev/null
grep -qx 'font-size = 0' "$range/.config/ghostty/local" ||
  fail "omarchy font size still accepts 0" "$(cat "$range/.config/ghostty/local")"
run_size "$range" "$range/.config" 500 >/dev/null
grep -qx 'font-size = 500' "$range/.config/ghostty/local" ||
  fail "omarchy font size still accepts 500" "$(cat "$range/.config/ghostty/local")"
pass "omarchy font size still accepts 0 and 500"

# --- Symlinked shared configs are edited in place ---
link="$tmpdir/link-home"
mkdir -p "$link/.config/ghostty" "$link/.config/kitty" "$link/.config/foot" "$link/.config/alacritty" "$link/dotfiles"
printf 'font-family = "JetBrainsMono Nerd Font"\nfont-size = 11\n' >"$link/dotfiles/ghostty-config"
printf 'font_size 11\n' >"$link/dotfiles/kitty.conf"
printf '[main]\nfont=Iosevka Term:size=11\n' >"$link/dotfiles/foot.ini"
cat >"$link/dotfiles/alacritty.toml" <<'TOML'
general.import = [ "~/.local/state/omarchy/current/theme/alacritty.toml" ]

[font]
size = 12
TOML
ln -s ../../dotfiles/ghostty-config "$link/.config/ghostty/config"
ln -s ../../dotfiles/kitty.conf "$link/.config/kitty/kitty.conf"
ln -s ../../dotfiles/foot.ini "$link/.config/foot/foot.ini"
ln -s ../../dotfiles/alacritty.toml "$link/.config/alacritty/alacritty.toml"
run_migration "$link" "$link/.config"
for linked in \
  "$link/.config/ghostty/config" \
  "$link/.config/kitty/kitty.conf" \
  "$link/.config/foot/foot.ini" \
  "$link/.config/alacritty/alacritty.toml"
do
  [[ -L $linked ]] || fail "migration keeps the dotfile symlink" "$linked is no longer a symlink"
done
! grep -q '^font-size[[:space:]]*=' "$link/dotfiles/ghostty-config" ||
  fail "migration edits the Ghostty symlink target" "$(cat "$link/dotfiles/ghostty-config")"
! grep -q '^font_size[[:space:]]' "$link/dotfiles/kitty.conf" ||
  fail "migration edits the Kitty symlink target" "$(cat "$link/dotfiles/kitty.conf")"
! grep -q ':size=' "$link/dotfiles/foot.ini" ||
  fail "migration edits the Foot symlink target" "$(cat "$link/dotfiles/foot.ini")"
! grep -q '^size[[:space:]]*=' "$link/dotfiles/alacritty.toml" ||
  fail "migration edits the Alacritty symlink target" "$(cat "$link/dotfiles/alacritty.toml")"
pass "migration keeps dotfile symlinks and edits them in place"

# --- Overlay writers replace only the size line ---
keep="$tmpdir/keep-home"
mkdir -p "$keep/.config/ghostty" "$keep/.config/kitty" "$keep/.config/foot" "$keep/.config/alacritty"
printf 'font-family = "Iosevka Term"\n' >"$keep/.config/ghostty/config"
printf '[main]\nfont=Iosevka Term\n' >"$keep/.config/foot/foot.ini"
cat >"$keep/.config/ghostty/local" <<'EOF'
# Machine-local Ghostty overrides. Not part of the shared desktop config.
font-size = 9
window-padding-x = 4
EOF
cat >"$keep/.config/kitty/local.conf" <<'EOF'
# keep
font_size 9.0
background #111111
EOF
cat >"$keep/.config/foot/local.ini" <<'EOF'
# keep
font=Iosevka Term:size=10
pad=2
EOF
cat >"$keep/.config/alacritty/local.toml" <<'EOF'
[font]
size = 9
offset = { x = 1, y = 1 }
EOF
run_size "$keep" "$keep/.config" 12 >/dev/null
grep -qx 'window-padding-x = 4' "$keep/.config/ghostty/local" ||
  fail "font size change keeps other Ghostty settings" "$(cat "$keep/.config/ghostty/local")"
grep -qx 'font-size = 12' "$keep/.config/ghostty/local" ||
  fail "font size change updates the Ghostty size line" "$(cat "$keep/.config/ghostty/local")"
grep -qx 'background #111111' "$keep/.config/kitty/local.conf" ||
  fail "font size change keeps other Kitty settings" "$(cat "$keep/.config/kitty/local.conf")"
grep -qx 'pad=2' "$keep/.config/foot/local.ini" ||
  fail "font size change keeps other Foot settings" "$(cat "$keep/.config/foot/local.ini")"
grep -qx 'font=Iosevka Term:size=12' "$keep/.config/foot/local.ini" ||
  fail "font size change keeps Foot's shared family" "$(cat "$keep/.config/foot/local.ini")"
grep -qx 'offset = { x = 1, y = 1 }' "$keep/.config/alacritty/local.toml" ||
  fail "font size change keeps other Alacritty settings" "$(cat "$keep/.config/alacritty/local.toml")"
pass "font size change keeps other machine-local settings"

printf '#!/bin/bash\necho "Iosevka Term"\n' >"$bin/fc-list"
chmod +x "$bin/fc-list"
printf '#!/bin/bash\nexit 0\n' >"$bin/omarchy-restart-shell"
printf '#!/bin/bash\nexit 0\n' >"$bin/omarchy-hook"
chmod +x "$bin/omarchy-restart-shell" "$bin/omarchy-hook"
HOME="$keep" XDG_CONFIG_HOME="$keep/.config" PATH="$bin:$ROOT/bin:$PATH" \
  omarchy-font-set "Iosevka Term" >/dev/null
grep -qx 'pad=2' "$keep/.config/foot/local.ini" ||
  fail "font set keeps other Foot overlay lines" "$(cat "$keep/.config/foot/local.ini")"
grep -qx 'font=Iosevka Term:size=12' "$keep/.config/foot/local.ini" ||
  fail "font set updates the Foot family without dropping the size" "$(cat "$keep/.config/foot/local.ini")"
pass "font set replaces only Foot's font line"

# --- Alacritty import: trailing comma, [general] table, and no import ---
comma="$tmpdir/comma-home"
mkdir -p "$comma/.config/alacritty"
cat >"$comma/.config/alacritty/alacritty.toml" <<'TOML'
general.import = [
  "~/.local/state/omarchy/current/theme/alacritty.toml",
]

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
TOML
run_size "$comma" "$comma/.config" 12 >/dev/null
python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$comma/.config/alacritty/alacritty.toml" ||
  fail "alacritty.toml is still valid TOML after adding the overlay import" "$(sed -n 1,6p "$comma/.config/alacritty/alacritty.toml")"
! grep -q ',,' "$comma/.config/alacritty/alacritty.toml" ||
  fail "overlay import does not produce a double comma" "$(sed -n 1,6p "$comma/.config/alacritty/alacritty.toml")"
pass "alacritty.toml is still valid TOML after adding the overlay import"

general="$tmpdir/general-home"
mkdir -p "$general/.config/alacritty"
cat >"$general/.config/alacritty/alacritty.toml" <<'TOML'
[general]
import = [ "~/.local/state/omarchy/current/theme/alacritty.toml" ]

[font]
size = 12
TOML
run_migration "$general" "$general/.config"
python3 - "$general/.config/alacritty/alacritty.toml" "$general/.config/alacritty/local.toml" <<'PY' ||
import sys, tomllib
shared = tomllib.load(open(sys.argv[1], "rb"))
local = tomllib.load(open(sys.argv[2], "rb"))
imports = shared.get("general", {}).get("import", [])
overlay = sys.argv[2]
if not (local.get("font", {}).get("size") == 12 and (overlay in imports or "~/.config/alacritty/local.toml" in imports)):
    raise SystemExit(1)
if shared.get("font", {}).get("size") is not None:
    raise SystemExit(1)
PY
  fail "Alacritty [general] import loads the overlay size" "$(cat "$general/.config/alacritty/alacritty.toml"; echo '---'; cat "$general/.config/alacritty/local.toml")"
pass "Alacritty [general] table imports the overlay"

none="$tmpdir/none-home"
mkdir -p "$none/.config/alacritty"
cat >"$none/.config/alacritty/alacritty.toml" <<'TOML'
[font]
size = 12
TOML
run_migration "$none" "$none/.config"
grep -qx 'size = 12' "$none/.config/alacritty/alacritty.toml" ||
  fail "migration keeps the shared Alacritty size when it cannot add an import" "$(cat "$none/.config/alacritty/alacritty.toml")"
pass "migration keeps the shared Alacritty size when it cannot add an import"

# --- One config base: XDG_CONFIG_HOME, not a hardcoded ~/.config ---
xdg_home="$tmpdir/xdg-home"
xdg="$tmpdir/xdg"
mkdir -p "$xdg_home" "$xdg/ghostty" "$xdg/kitty" "$xdg/foot" "$xdg/alacritty" \
  "$xdg_home/.config/alacritty" "$xdg_home/.config/ghostty"
cp "$ROOT/config/ghostty/config" "$xdg/ghostty/config"
cp "$ROOT/config/kitty/kitty.conf" "$xdg/kitty/kitty.conf"
cp "$ROOT/config/foot/foot.ini" "$xdg/foot/foot.ini"
cp "$ROOT/config/alacritty/alacritty.toml" "$xdg/alacritty/alacritty.toml"
# A different size on the HOME tree must not win.
printf 'font-size = 9\n' >"$xdg_home/.config/ghostty/config"
printf 'size = 9\n' >"$xdg_home/.config/alacritty/alacritty.toml"
run_size "$xdg_home" "$xdg" 15 >/dev/null

mapfile -t ghostty_includes < <(sed -n 's/^config-file = ?"\(.*ghostty\/local\)"$/\1/p' "$xdg/ghostty/config")
[[ ${#ghostty_includes[@]} -ge 1 ]] || fail "Ghostty config includes its overlay" "$(cat "$xdg/ghostty/config")"
for include in "${ghostty_includes[@]}"; do
  target=${include/#\~/$xdg_home}
  [[ $target == "$xdg/ghostty/local" && -f $target ]] ||
    fail "Ghostty's overlay include points at the overlay omarchy font size wrote" \
      "include: $include (resolved: $target)"
done
grep -qx 'font-size = 15' "$xdg/ghostty/local" ||
  fail "Ghostty overlay under XDG_CONFIG_HOME has the size that was set" "$(cat "$xdg/ghostty/local")"
[[ ! -e $xdg_home/.config/ghostty/local ]] ||
  fail "omarchy font size does not write the Ghostty overlay under ~/.config when XDG_CONFIG_HOME is set"

grep -qx 'globinclude local.conf' "$xdg/kitty/kitty.conf" ||
  fail "Kitty globinclude stays relative under XDG_CONFIG_HOME" "$(grep globinclude "$xdg/kitty/kitty.conf" || true)"
[[ -f $xdg/kitty/local.conf ]] || fail "Kitty overlay is written under XDG_CONFIG_HOME"

foot_include=$(sed -n 's/^include=//p' "$xdg/foot/foot.ini" | grep 'foot/local.ini' | head -1)
foot_target=${foot_include/#\~/$xdg_home}
[[ $foot_target == "$xdg/foot/local.ini" && -f $foot_target ]] ||
  fail "Foot include points at the overlay that was written" "include: $foot_include"
foot_section=$(awk '/^\[/ { s = $0 } /^include=.*foot\/local\.ini/ { print s; exit }' "$xdg/foot/foot.ini")
[[ $foot_section == "[main]" ]] || fail "Foot include stays in [main] under XDG_CONFIG_HOME" "section: $foot_section"

python3 - "$xdg/alacritty/alacritty.toml" "$xdg/alacritty/local.toml" <<'PY' ||
import sys, tomllib
doc = tomllib.load(open(sys.argv[1], "rb"))
imports = doc.get("general", {}).get("import", [])
overlay = sys.argv[2]
if overlay not in imports and "~/.config/alacritty/local.toml" not in imports:
    raise SystemExit("imports: " + repr(imports))
if "~/.config/alacritty/local.toml" in imports and overlay not in imports:
    # ~/.config does not resolve to XDG_CONFIG_HOME here.
    raise SystemExit("import still points at ~/.config: " + repr(imports))
PY
  fail "Alacritty import points at the overlay under XDG_CONFIG_HOME" "$(sed -n 1,6p "$xdg/alacritty/alacritty.toml")"
[[ -f $xdg/alacritty/local.toml ]] || fail "Alacritty overlay is written under XDG_CONFIG_HOME"
pass "includes point at the overlays written under XDG_CONFIG_HOME"

# Migration reads the same tree it writes.
printf 'font-size = 15\n' >"$xdg/ghostty/config"
printf 'size = 13\n' >>"$xdg/alacritty/alacritty.toml"
rm -f "$xdg/ghostty/local" "$xdg/alacritty/local.toml" "$xdg/kitty/local.conf" "$xdg/foot/local.ini"
run_migration "$xdg_home" "$xdg"
grep -qx 'font-size = 15' "$xdg/ghostty/local" ||
  fail "migration reads Ghostty's size from XDG_CONFIG_HOME" "$(cat "$xdg/ghostty/local" 2>/dev/null || true)"
grep -qx 'size = 13' "$xdg/alacritty/local.toml" ||
  fail "migration reads Alacritty's size from XDG_CONFIG_HOME" "$(cat "$xdg/alacritty/local.toml" 2>/dev/null || true)"
[[ ! -e $xdg_home/.config/ghostty/local ]] ||
  fail "migration does not write overlays under ~/.config when XDG_CONFIG_HOME is set"
pass "migration uses XDG_CONFIG_HOME for shared configs and overlays"
