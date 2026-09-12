#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$home/.config/ghostty" "$home/.config/kitty" "$home/.config/foot" "$home/.config/alacritty"

cp "$ROOT/config/ghostty/config" "$home/.config/ghostty/config"
cp "$ROOT/config/kitty/kitty.conf" "$home/.config/kitty/kitty.conf"
cp "$ROOT/config/foot/foot.ini" "$home/.config/foot/foot.ini"
cp "$ROOT/config/alacritty/alacritty.toml" "$home/.config/alacritty/alacritty.toml"

# Default stock configs must not pin a size in the shared file.
if grep -q '^font-size' "$home/.config/ghostty/config"; then
  fail "ghostty default config has no font-size"
fi
if grep -qE '^[[:space:]]*font_size[[:space:]]' "$home/.config/kitty/kitty.conf"; then
  fail "kitty default config has no font_size"
fi
if grep -q ':size=' "$home/.config/foot/foot.ini"; then
  fail "foot default config has no :size= on the shared font line"
fi
if grep -q '^size' "$home/.config/alacritty/alacritty.toml"; then
  fail "alacritty default config has no size in the shared file"
fi
pass "stock terminal configs leave size to the local overlay"

mkdir -p "$tmpdir/bin"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
chmod +x "$tmpdir/bin/pgrep"
export HOME="$home" XDG_CONFIG_HOME="$home/.config" PATH="$tmpdir/bin:$ROOT/bin:$PATH"

output=$(omarchy-font-size)
[[ $output == 9 ]] || fail "font size defaults to 9 when no overlay exists" "$output"
pass "font size defaults to 9 when no overlay exists"

omarchy-font-size 11 >/dev/null

[[ $(omarchy-font-size) == 11 ]] || fail "font size reports the value that was set"
grep -qx 'font-size = 11' "$home/.config/ghostty/local" || fail "ghostty local overlay has size 11"
grep -q 'font_size 11.0' "$home/.config/kitty/local.conf" || fail "kitty local overlay has size 11"
grep -q ':size=11' "$home/.config/foot/local.ini" || fail "foot local overlay has size 11"
grep -qx 'size = 11' "$home/.config/alacritty/local.toml" || fail "alacritty local overlay has size 11"
pass "omarchy font size 11 writes every terminal overlay"

grep -Fq 'config-file = ?"~/.config/ghostty/local"' "$home/.config/ghostty/config" ||
  fail "ghostty config includes the local overlay"
grep -Fq 'globinclude ~/.config/kitty/local.conf' "$home/.config/kitty/kitty.conf" ||
  fail "kitty config globincludes the local overlay"
grep -Fq 'foot/local.ini' "$home/.config/foot/foot.ini" ||
  fail "foot config includes the local overlay"
pass "omarchy font size ensures shared configs include the overlays"

# Packaged font-set used to force Foot size=9. Family changes must keep size.
cat >"$home/.config/foot/foot.ini" <<'INI'
[main]
font=OldFont
INI
cat >"$home/.config/foot/local.ini" <<'INI'
font=OldFont:size=11
INI

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/fc-list" <<'SH'
#!/bin/bash
echo "JetBrainsMono Nerd Font"
SH
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/omarchy-restart-shell"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/omarchy-hook"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/omarchy-notification-send"
printf '#!/bin/bash\necho JetBrainsMono Nerd Font\n' >"$tmpdir/bin/omarchy-font-current"
chmod +x "$tmpdir/bin/fc-list" "$tmpdir/bin/omarchy-restart-shell" "$tmpdir/bin/omarchy-hook" \
  "$tmpdir/bin/omarchy-notification-send" "$tmpdir/bin/omarchy-font-current"

PATH="$tmpdir/bin:$ROOT/bin:$PATH" HOME="$home" XDG_CONFIG_HOME="$home/.config" \
  omarchy-font-set "JetBrainsMono Nerd Font" >/dev/null

grep -qx 'font=JetBrainsMono Nerd Font' "$home/.config/foot/foot.ini" ||
  fail "font set writes Foot family without a size" "$(cat "$home/.config/foot/foot.ini")"
grep -q 'font=JetBrainsMono Nerd Font:size=11' "$home/.config/foot/local.ini" ||
  fail "font set keeps Foot overlay size" "$(cat "$home/.config/foot/local.ini")"
pass "omarchy font set does not clobber this machine's Foot size"

# Migration extracts an in-file size onto the overlay and strips the shared file.
rm -f "$home/.config/ghostty/local" "$home/.config/kitty/local.conf" \
  "$home/.config/foot/local.ini" "$home/.config/alacritty/local.toml"
cat >"$home/.config/ghostty/config" <<'CONF'
font-family = "JetBrainsMono Nerd Font"
font-size = 14
CONF
HOME="$home" XDG_CONFIG_HOME="$home/.config" PATH="$tmpdir/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1789224260.sh" >/dev/null
if grep -q '^font-size' "$home/.config/ghostty/config"; then
  fail "migration strips font-size from the shared Ghostty config"
fi
[[ $(HOME="$home" XDG_CONFIG_HOME="$home/.config" omarchy-font-size) == 14 ]] ||
  fail "migration preserves the previous Ghostty size on the overlay"
pass "migration moves in-file font size onto the overlay"
