#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
test_home="$test_tmp/home"
staged="$test_home/.local/state/omarchy/current/theme/backgrounds"
state="$test_home/.local/state/omarchy/theme-backgrounds"
mkdir -p "$staged" "$state" "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
STUB
chmod +x "$test_tmp/bin/omarchy-shell"
printf 'tokyo-night\n' >"${staged%/theme/backgrounds}/theme.name"
ln -s "$staged/omarchy.webp" "${staged%/theme/backgrounds}/background"
printf '%s\n' "$staged/omarchy.webp" >"$state/tokyo-night"
printf '%s\n' "$staged/omarchy.webp" >"$state/catppuccin"
run() { HOME="$test_home" OMARCHY_PATH="$ROOT" CALLS="$test_tmp/calls" PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1792560121.sh"; }
run
[[ $(readlink "${staged%/theme/backgrounds}/background") == "$staged/omarchy.svg" && -f $staged/omarchy.svg ]] || fail "the active removed bundled wallpaper receives its SVG and current link"
[[ $(cat "$state/tokyo-night") == "$staged/omarchy.svg" && $(cat "$state/catppuccin") == "$staged/omarchy.svg" ]] || fail "active and inactive remembered selections use the new bundled filename"
[[ $(cat "$test_tmp/calls") == "-q background set $staged/omarchy.svg" ]] || fail "the running shell receives the repaired path"
run
(( $(wc -l <"$test_tmp/calls") == 1 )) || fail "repair is idempotent"
pass "removed bundled wallpapers keep their active and remembered selections idempotently"
cmp "$staged/backgrounds.toml" "$ROOT/themes/tokyo-night/backgrounds/backgrounds.toml" || fail "old staged themes receive responsive metadata along with the SVG"
rendered=$(HOME="$test_home" PATH="$ROOT/bin:/usr/bin:$PATH" bash "$ROOT/bin/omarchy-theme-bg-resolve" --screen 200x100 --canonical "$staged/omarchy.svg" | jq -r .path)
[[ $(magick identify -format '%wx%h' "$rendered") == "200x100" ]] || fail "the upgraded active SVG uses the screen viewport before any theme refresh"
printf '[defaults]\nfill = "tile"\n' >"$staged/backgrounds.toml"
ln -sfn "$staged/omarchy.webp" "${staged%/theme/backgrounds}/background"
run
[[ $(cat "$staged/backgrounds.toml") == $'[defaults]\nfill = "tile"' ]] || fail "existing staged user metadata remains untouched"
pass "upgraded wallpapers receive responsive metadata while existing user settings remain untouched"

# A user override with the old name must survive a later refresh.
user="$test_home/.config/omarchy/themes/tokyo-night/backgrounds"
mkdir -p "$user"
printf 'custom\n' >"$user/omarchy.webp"
ln -sfn "$staged/omarchy.webp" "${staged%/theme/backgrounds}/background"
printf '%s\n' "$staged/omarchy.webp" >"$state/tokyo-night"
run
[[ $(readlink "${staged%/theme/backgrounds}/background") == "$staged/omarchy.webp" && $(cat "$state/tokyo-night") == "$staged/omarchy.webp" ]] || fail "user-theme original filenames remain selected"
rm "$user/omarchy.webp"
printf 'user edited staged content\n' >"$staged/omarchy.webp"
run
[[ $(readlink "${staged%/theme/backgrounds}/background") == "$staged/omarchy.webp" ]] || fail "an edited existing staged file is preserved"
printf '%s\n' "$test_tmp/external/omarchy.webp" >"$state/tokyo-night"
run
[[ $(cat "$state/tokyo-night") == "$test_tmp/external/omarchy.webp" ]] || fail "external paths are preserved"
pass "user overrides, edited staged files and unrelated external paths remain untouched"
# Repair the old bundled file while it still exists, before refresh removes it.
# The historical bundled file is pinned so shallow source checkouts work.
cp "$SHELL_TEST_DIR/fixtures/responsive-background/legacy-omarchy.webp" "$staged/omarchy.webp"
run
[[ $(readlink "${staged%/theme/backgrounds}/background") == "$staged/omarchy.svg" ]] || fail "a still-existing original bundled file is repaired before refresh"
HOME="$test_home" XDG_RUNTIME_DIR="$test_tmp" OMARCHY_PATH="$ROOT" OMARCHY_THEME_HEADLESS=1 PATH="$ROOT/bin:/usr/bin:$PATH" bash "$ROOT/bin/omarchy-theme-refresh" >/dev/null
[[ -f $(readlink "${staged%/theme/backgrounds}/background") ]] || fail "theme refresh keeps the repaired current link readable"
pass "repair happens before refresh can strand a still-existing bundled WebP"
