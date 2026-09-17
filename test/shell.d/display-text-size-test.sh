#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
gsettings_log="$test_tmp/gsettings.log"

mkdir -p "$stub_bin" "$home_dir/.config/alacritty" "$home_dir/.config/ghostty" \
  "$home_dir/.config/kitty" "$home_dir/.config/foot"

# Record GTK mutations without touching the real dconf, and answer font-name
# queries with a stable interface font so the factor math stays deterministic.
cat >"$stub_bin/gsettings" <<'SH'
#!/bin/bash

case "$1" in
  set)
    printf 'set %s %s %s\n' "$2" "$3" "$4" >>"$GSETTINGS_LOG"
    exit 0
    ;;
  reset)
    printf 'reset %s %s\n' "$2" "$3" >>"$GSETTINGS_LOG"
    exit 0
    ;;
  get)
    if [[ $2 == "font-name" ]]; then
      printf "'Noto Sans 11'\n"
    else
      printf "1.0\n"
    fi
    exit 0
    ;;
esac
exit 1
SH
chmod +x "$stub_bin/gsettings"

# Seed terminal configs the way a user with a previous/global size would have
# them; each seds the existing value in place rather than appending.
cat >"$home_dir/.config/alacritty/alacritty.toml" <<'EOF'
[font]
size = 11
EOF

cat >"$home_dir/.config/ghostty/config" <<'EOF'
font-size = 11
EOF

cat >"$home_dir/.config/kitty/kitty.conf" <<'EOF'
font_size 9.0
EOF

cat >"$home_dir/.config/foot/foot.ini" <<'EOF'
font=JetBrainsMono Nerd Font:size=11
EOF

run_display_text_size() {
  HOME="$home_dir" \
    PATH="$stub_bin:$PATH" \
    GSETTINGS_LOG="$gsettings_log" \
    GDK_SCALE="${GDK_SCALE:-}" \
    "$ROOT/bin/omarchy-display-text-size" "$@"
}

# The GDK_SCALE variable must not factor into terminal points: on a Wayland
# desktop terminals, the shell, and native GTK apps all nest at the
# compositor's logical scale (1 here), so honoring GDK_SCALE=2 would roughly
# double terminals against the rest of a scale-1 desktop.
GDK_SCALE=2 run_display_text_size 11
grep -F 'size = 8.25' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "GDK_SCALE 2 does not double the alacritty pt" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
grep -Fx 'font-size = 8.25' "$home_dir/.config/ghostty/config" >/dev/null \
  || fail "GDK_SCALE 2 does not double the ghostty pt" \
    "$(cat "$home_dir/.config/ghostty/config")"
grep -Fx 'font_size 8.25' "$home_dir/.config/kitty/kitty.conf" >/dev/null \
  || fail "GDK_SCALE 2 kitty pt stays fractional and unsuffixed" \
    "$(cat "$home_dir/.config/kitty/kitty.conf")"
grep -F ':size=8.25' "$home_dir/.config/foot/foot.ini" >/dev/null \
  || fail "GDK_SCALE 2 does not double the foot pt" \
    "$(cat "$home_dir/.config/foot/foot.ini")"
grep -Fx 'base-size = 11' "$home_dir/.config/omarchy/shell.toml" >/dev/null \
  || fail "the shell base-size is still written" \
    "$(cat "$home_dir/.config/omarchy/shell.toml")"
grep -Eq '^set org.gnome.desktop.interface text-scaling-factor [0-9.]+$' "$gsettings_log" \
  || fail "the GTK text-scaling-factor is still driven" \
    "$(cat "$gsettings_log")"
pass "GDK_SCALE does not distort terminal points at the logical scale"

# The old integer rounding collapsed 10px and 11px both to 8pt. Fractional
# sizes are exact, so the mapping is smooth and each px step is distinct.
GDK_SCALE=1 run_display_text_size 10
grep -F 'size = 7.5' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "10px maps to 7.5pt" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
GDK_SCALE=1 run_display_text_size 11
grep -F 'size = 8.25' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "11px maps to 8.25pt, not a rounded 8" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
pass "no integer rounding collapse"

# The classic anchor still holds without GDK_SCALE: 12px -> 9pt.
unset GDK_SCALE
run_display_text_size 12
grep -F 'size = 9' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "the 12px -> 9pt anchor holds" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
pass "12px maps to the 9pt terminal default"

# Reset returns everything to the defaults and drops the shell override.
run_display_text_size 11 >/dev/null
run_display_text_size reset
grep -F 'size = 9' "$home_dir/.config/alacritty/alacritty.toml" >/dev/null \
  || fail "reset writes the 9pt terminal default" \
    "$(cat "$home_dir/.config/alacritty/alacritty.toml")"
[[ -f $home_dir/.config/omarchy/shell.toml ]] \
  && grep -qE '^base-size = ' "$home_dir/.config/omarchy/shell.toml" \
  && fail "reset drops the shell base-size override" \
    "$(cat "$home_dir/.config/omarchy/shell.toml")"
grep -Eq '^reset org.gnome.desktop.interface text-scaling-factor$' "$gsettings_log" \
  || fail "reset clears the GTK text-scaling-factor" \
    "$(cat "$gsettings_log")"
pass "reset returns shells, GTK, and terminals to defaults"

# Sizes outside the 9–20px range are rejected before anything is written.
GDK_SCALE=1 run_display_text_size 8 >/dev/null 2>&1 && fail "8px is rejected"
pass "sizes outside 9-20px are rejected"