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
(( include_line > font_line )) ||
  fail "Foot overlay include comes after the shared font line" "font:$font_line include:$include_line"
grep -qx 'include=~/.config/foot/local.ini' "$foot_home/.config/foot/foot.ini" ||
  fail "Foot include uses ~ so the shared config does not carry this home" "$(grep include= "$foot_home/.config/foot/foot.ini")"
(( $(grep -c 'foot/local\.ini' "$foot_home/.config/foot/foot.ini") == 1 )) ||
  fail "migration adds the Foot include once" "$(cat "$foot_home/.config/foot/foot.ini")"
run_migration "$foot_home" "$foot_home/.config"
(( $(grep -c 'foot/local\.ini' "$foot_home/.config/foot/foot.ini") == 1 )) ||
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
(( $(grep -c '^globinclude local.conf$' "$kitty_home/.config/kitty/kitty.conf") == 1 )) ||
  fail "Kitty overlay include is a relative globinclude" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
run_size "$kitty_home" "$kitty_home/.config" 14 >/dev/null
(( $(grep -c '^globinclude local.conf$' "$kitty_home/.config/kitty/kitty.conf") == 1 )) ||
  fail "Kitty relative globinclude is not duplicated" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
grep -qx 'font_size 14.0' "$kitty_home/.config/kitty/local.conf" ||
  fail "Kitty overlay keeps the new size" "$(cat "$kitty_home/.config/kitty/local.conf")"

printf 'globinclude ~/.config/kitty/local.conf\n' >"$kitty_home/.config/kitty/kitty.conf"
run_size "$kitty_home" "$kitty_home/.config" 14 >/dev/null
grep -qx 'globinclude local.conf' "$kitty_home/.config/kitty/kitty.conf" ||
  fail "an absolute Kitty globinclude is rewritten to local.conf" "$(cat "$kitty_home/.config/kitty/kitty.conf")"
(( $(grep -c 'globinclude' "$kitty_home/.config/kitty/kitty.conf") == 1 )) ||
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

# The upgrade copies the packaged overlays, which ship at size 9, before this
# migration. Those copies are byte-identical to $OMARCHY_PATH/config, which the
# harness points at this repo. They must not hide the size still in the shared
# config. A second run must not then eat a Foot fallback's size.
stock="$tmpdir/stock-home"
mkdir -p "$stock/.config/ghostty" "$stock/.config/kitty" "$stock/.config/foot" "$stock/.config/alacritty"
cp "$ROOT/config/ghostty/local" "$stock/.config/ghostty/local"
cp "$ROOT/config/kitty/local.conf" "$stock/.config/kitty/local.conf"
cp "$ROOT/config/foot/local.ini" "$stock/.config/foot/local.ini"
cp "$ROOT/config/alacritty/local.toml" "$stock/.config/alacritty/local.toml"
cp "$ROOT/config/ghostty/config" "$stock/.config/ghostty/config"
cp "$ROOT/config/kitty/kitty.conf" "$stock/.config/kitty/kitty.conf"
cp "$ROOT/config/foot/foot.ini" "$stock/.config/foot/foot.ini"
cp "$ROOT/config/alacritty/alacritty.toml" "$stock/.config/alacritty/alacritty.toml"
printf 'font-size = 14\n' >>"$stock/.config/ghostty/config"
printf 'font_size 14\n' >>"$stock/.config/kitty/kitty.conf"
sed -i 's/^font=JetBrainsMono Nerd Font$/font=JetBrainsMono Nerd Font:size=14, Noto Color Emoji:size=10/' \
  "$stock/.config/foot/foot.ini"
sed -i '/^\[font\]$/a size = 14' "$stock/.config/alacritty/alacritty.toml"
run_migration "$stock" "$stock/.config"
grep -qx 'font-size = 14' "$stock/.config/ghostty/local" ||
  fail "a stock Ghostty overlay takes the shared size" "$(cat "$stock/.config/ghostty/local")"
grep -qx 'font_size 14.0' "$stock/.config/kitty/local.conf" ||
  fail "a stock Kitty overlay takes the shared size" "$(cat "$stock/.config/kitty/local.conf")"
grep -qx 'font=JetBrainsMono Nerd Font:size=14, Noto Color Emoji:size=10' \
  "$stock/.config/foot/local.ini" ||
  fail "a stock Foot overlay takes the shared size and keeps the fallback" "$(cat "$stock/.config/foot/local.ini")"
grep -qx 'size = 14' "$stock/.config/alacritty/local.toml" ||
  fail "a stock Alacritty overlay takes the shared size" "$(cat "$stock/.config/alacritty/local.toml")"
grep -qx '# Machine-local Ghostty overrides. Not part of the shared desktop config.' \
  "$stock/.config/ghostty/local" ||
  fail "replacing a stock overlay keeps its other lines" "$(cat "$stock/.config/ghostty/local")"
! grep -q '^font-size[[:space:]]*=' "$stock/.config/ghostty/config" ||
  fail "migration still strips the shared Ghostty size after seeding a stock overlay" "$(cat "$stock/.config/ghostty/config")"
! grep -q '^font_size[[:space:]]' "$stock/.config/kitty/kitty.conf" ||
  fail "migration still strips the shared Kitty size after seeding a stock overlay" "$(cat "$stock/.config/kitty/kitty.conf")"
grep -qx 'font=JetBrainsMono Nerd Font, Noto Color Emoji:size=10' "$stock/.config/foot/foot.ini" ||
  fail "migration strips only Foot's primary size" "$(grep '^font=' "$stock/.config/foot/foot.ini")"
! grep -q '^[[:space:]]*size[[:space:]]*=' "$stock/.config/alacritty/alacritty.toml" ||
  fail "migration still strips the shared Alacritty size after seeding a stock overlay" "$(cat "$stock/.config/alacritty/alacritty.toml")"
run_migration "$stock" "$stock/.config"
grep -qx 'font=JetBrainsMono Nerd Font, Noto Color Emoji:size=10' "$stock/.config/foot/foot.ini" ||
  fail "a second migration keeps the Foot fallback size" "$(grep '^font=' "$stock/.config/foot/foot.ini")"
grep -qx 'font=JetBrainsMono Nerd Font:size=14, Noto Color Emoji:size=10' \
  "$stock/.config/foot/local.ini" ||
  fail "a second migration keeps the size already on the Foot overlay" "$(cat "$stock/.config/foot/local.ini")"
pass "a stock overlay does not hide the shared font size"

# An overlay the user has already changed is left alone. The shared size is
# still removed, so the next sync does not put it back.
edited="$tmpdir/edited-home"
mkdir -p "$edited/.config/ghostty" "$edited/.config/kitty" "$edited/.config/foot" "$edited/.config/alacritty"
cp "$ROOT/config/ghostty/local" "$edited/.config/ghostty/local"
cp "$ROOT/config/kitty/local.conf" "$edited/.config/kitty/local.conf"
cp "$ROOT/config/foot/local.ini" "$edited/.config/foot/local.ini"
cp "$ROOT/config/alacritty/local.toml" "$edited/.config/alacritty/local.toml"
sed -i 's/font-size = 9/font-size = 16/' "$edited/.config/ghostty/local"
sed -i 's/font_size 9.0/font_size 16.0/' "$edited/.config/kitty/local.conf"
sed -i 's/:size=9/:size=16/' "$edited/.config/foot/local.ini"
sed -i 's/size = 9/size = 16/' "$edited/.config/alacritty/local.toml"
cp "$ROOT/config/ghostty/config" "$edited/.config/ghostty/config"
cp "$ROOT/config/kitty/kitty.conf" "$edited/.config/kitty/kitty.conf"
cp "$ROOT/config/foot/foot.ini" "$edited/.config/foot/foot.ini"
cp "$ROOT/config/alacritty/alacritty.toml" "$edited/.config/alacritty/alacritty.toml"
printf 'font-size = 14\n' >>"$edited/.config/ghostty/config"
printf 'font_size 14\n' >>"$edited/.config/kitty/kitty.conf"
sed -i 's/^font=JetBrainsMono Nerd Font$/font=JetBrainsMono Nerd Font:size=14, Noto Color Emoji:size=10/' \
  "$edited/.config/foot/foot.ini"
sed -i '/^\[font\]$/a size = 14' "$edited/.config/alacritty/alacritty.toml"
run_migration "$edited" "$edited/.config"
grep -qx 'font-size = 16' "$edited/.config/ghostty/local" ||
  fail "migration leaves a changed Ghostty overlay alone" "$(cat "$edited/.config/ghostty/local")"
grep -qx 'font_size 16.0' "$edited/.config/kitty/local.conf" ||
  fail "migration leaves a changed Kitty overlay alone" "$(cat "$edited/.config/kitty/local.conf")"
grep -qx 'font=JetBrainsMono Nerd Font:size=16' "$edited/.config/foot/local.ini" ||
  fail "migration leaves a changed Foot overlay alone" "$(cat "$edited/.config/foot/local.ini")"
grep -qx 'size = 16' "$edited/.config/alacritty/local.toml" ||
  fail "migration leaves a changed Alacritty overlay alone" "$(cat "$edited/.config/alacritty/local.toml")"
! grep -q '^font-size[[:space:]]*=' "$edited/.config/ghostty/config" ||
  fail "migration strips the shared Ghostty size when the overlay was already changed"
grep -qx 'font=JetBrainsMono Nerd Font, Noto Color Emoji:size=10' "$edited/.config/foot/foot.ini" ||
  fail "migration strips Foot's primary size when the overlay was already changed" "$(grep '^font=' "$edited/.config/foot/foot.ini")"
pass "migration leaves a changed overlay alone"

# Other machine settings do not count as a chosen size. The shared size
# still has to land on that overlay, and the other settings stay.
nosize="$tmpdir/nosize-home"
mkdir -p "$nosize/.config/ghostty"
cat >"$nosize/.config/ghostty/local" <<'EOF'
# keep
window-padding-x = 4
EOF
printf 'font-family = "JetBrainsMono Nerd Font"\nfont-size = 14\n' >"$nosize/.config/ghostty/config"
run_migration "$nosize" "$nosize/.config"
grep -qx 'font-size = 14' "$nosize/.config/ghostty/local" ||
  fail "an overlay with no size takes the shared size" "$(cat "$nosize/.config/ghostty/local")"
grep -qx 'window-padding-x = 4' "$nosize/.config/ghostty/local" ||
  fail "an overlay with no size keeps its other settings" "$(cat "$nosize/.config/ghostty/local")"
! grep -q '^font-size[[:space:]]*=' "$nosize/.config/ghostty/config" ||
  fail "migration strips the shared Ghostty size after copying it onto an overlay that had none"
pass "an overlay with no size takes the shared size"

# The packaged Foot overlay is JetBrainsMono at size 9. Foot loads it after
# the shared font line, so a shared family with no size would disappear.
stockfoot="$tmpdir/stock-foot-family"
mkdir -p "$stockfoot/.config/foot"
cp "$ROOT/config/foot/local.ini" "$stockfoot/.config/foot/local.ini"
printf '[main]\nfont=Iosevka Term\n' >"$stockfoot/.config/foot/foot.ini"
run_migration "$stockfoot" "$stockfoot/.config"
grep -qx 'font=Iosevka Term:size=9' "$stockfoot/.config/foot/local.ini" ||
  fail "a stock Foot overlay takes the shared family" "$(cat "$stockfoot/.config/foot/local.ini")"
grep -qx '# Machine-local Foot overrides. Not part of the shared desktop config.' \
  "$stockfoot/.config/foot/local.ini" ||
  fail "rewriting a stock Foot overlay keeps its other lines" "$(cat "$stockfoot/.config/foot/local.ini")"
grep -qx 'font=Iosevka Term' "$stockfoot/.config/foot/foot.ini" ||
  fail "a shared Foot family with no size stays in the shared file" "$(grep '^font=' "$stockfoot/.config/foot/foot.ini")"
pass "a stock Foot overlay takes the shared family"

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

# After the migration strips the primary size, the shared line is
# "font=Old, Emoji:size=10". Replacing through the first colon would turn
# that into "font=New:size=10" and drop the fallback.
comma_font="$tmpdir/comma-font-home"
mkdir -p "$comma_font/.config/foot"
printf '[main]\nfont=Old, Emoji:size=10\n' >"$comma_font/.config/foot/foot.ini"
printf '#!/bin/bash\necho "Test Font"\n' >"$bin/fc-list"
chmod +x "$bin/fc-list"
HOME="$comma_font" XDG_CONFIG_HOME="$comma_font/.config" PATH="$bin:$ROOT/bin:$PATH" \
  omarchy-font-set "Test Font" >/dev/null
grep -qx 'font=Test Font, Emoji:size=10' "$comma_font/.config/foot/foot.ini" ||
  fail "font set keeps a Foot fallback that comes after a comma" "$(cat "$comma_font/.config/foot/foot.ini")"
pass "font set keeps a Foot fallback that comes after a comma"

# --- A fallback font keeps its own size ---
fallback="$tmpdir/fallback-home"
mkdir -p "$fallback/.config/foot"
printf '[main]\nfont=JetBrainsMono Nerd Font:size=12, Noto Color Emoji:size=10\n' \
  >"$fallback/.config/foot/foot.ini"
read_out=$(run_size "$fallback" "$fallback/.config" --read foot)
[[ $read_out == 12 ]] || fail "foot size is the primary font, not the emoji fallback" "$read_out"
run_size "$fallback" "$fallback/.config" --quiet --only foot 11 >/dev/null
grep -qx 'font=JetBrainsMono Nerd Font:size=11, Noto Color Emoji:size=10' \
  "$fallback/.config/foot/local.ini" ||
  fail "foot size change keeps the fallback list" "$(cat "$fallback/.config/foot/local.ini")"
pass "foot size stays on the primary font"

# A comment on the [font] header is still that table.
font_comment="$tmpdir/font-comment-home"
mkdir -p "$font_comment/.config/alacritty"
cat >"$font_comment/.config/alacritty/local.toml" <<'EOF'
[font] # laptop
offset = { x = 1, y = 1 }
EOF
run_size "$font_comment" "$font_comment/.config" --quiet --only alacritty 14 >/dev/null
(( $(grep -c '^\[font\]' "$font_comment/.config/alacritty/local.toml") == 1 )) ||
  fail "a commented [font] header stays one table" "$(cat "$font_comment/.config/alacritty/local.toml")"
grep -qxF '[font] # laptop' "$font_comment/.config/alacritty/local.toml" ||
  fail "a commented [font] header keeps its comment" "$(cat "$font_comment/.config/alacritty/local.toml")"
python3 - "$font_comment/.config/alacritty/local.toml" <<'PY' ||
import sys, tomllib
font = tomllib.load(open(sys.argv[1], "rb")).get("font", {})
if font.get("size") != 14 or font.get("offset") != {"x": 1, "y": 1}:
    raise SystemExit(repr(font))
PY
  fail "a commented [font] header receives the size" "$(cat "$font_comment/.config/alacritty/local.toml")"
pass "a commented Alacritty [font] header stays one table"

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
(( ${#ghostty_includes[@]} >= 1 )) || fail "Ghostty config includes its overlay" "$(cat "$xdg/ghostty/config")"
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
