#!/bin/bash

set -euo pipefail

# The theme picker offers one directory of images per theme: that theme's
# preview first, then every background it ships and every background the user
# added for it. omarchy-menu-images --group-by-dir turns each directory into a
# single carousel item, so up/down walks a theme's backgrounds.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
omarchy="$test_tmp/omarchy"
stub_bin="$test_tmp/bin"
previews="$test_tmp/cache/omarchy/theme-selector/previews"
state="$home/.local/state/omarchy/current"

mkdir -p "$stub_bin" "$state" \
  "$omarchy/themes/nord/backgrounds" \
  "$omarchy/themes/plain/backgrounds" \
  "$home/.config/omarchy/themes/mine/backgrounds" \
  "$home/.config/omarchy/backgrounds/nord"

printf 'preview' >"$omarchy/themes/nord/preview.png"
printf 'image' >"$omarchy/themes/nord/backgrounds/1-city.webp"
printf 'image' >"$omarchy/themes/nord/backgrounds/2-moon.jpg"
printf 'video' >"$omarchy/themes/nord/backgrounds/3-motion.mp4"
printf 'image' >"$home/.config/omarchy/backgrounds/nord/0-mine.png"

# A theme with no preview of its own: the picker falls back to its first
# background, which must not then show up twice.
printf 'image' >"$omarchy/themes/plain/backgrounds/1-only.webp"

printf 'preview' >"$home/.config/omarchy/themes/mine/preview.png"
printf 'image' >"$home/.config/omarchy/themes/mine/backgrounds/1-mine.webp"

# A theme the user wrote is theirs to fill however they like, symlinks included.
ln -s "$omarchy/themes/nord/backgrounds/1-city.webp" "$home/.config/omarchy/themes/mine/backgrounds/2-linked.webp"

# A theme installed from a git repo came from a stranger, and omarchy-theme-set
# drops the symlinks in one rather than stage a file from anywhere on disk.
cloned="$home/.config/omarchy/themes/cloned"
mkdir -p "$cloned/backgrounds" "$cloned/.git"
printf 'preview' >"$cloned/preview.png"
printf 'image' >"$cloned/backgrounds/1-own.webp"
ln -s "$omarchy/themes/nord/backgrounds/2-moon.jpg" "$cloned/backgrounds/2-linked.jpg"

cat >"$stub_bin/omarchy-menu-images" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$MENU_IMAGES_ARGS"
[[ -n ${MENU_IMAGES_SELECTION:-} ]] && printf '%s\n' "$MENU_IMAGES_SELECTION"
EOF
chmod +x "$stub_bin/omarchy-menu-images"

switch() {
  HOME="$home" OMARCHY_PATH="$omarchy" PATH="$stub_bin:$PATH" \
    XDG_CACHE_HOME="$test_tmp/cache" MENU_IMAGES_ARGS="$test_tmp/args" \
    bash "$ROOT/bin/omarchy-theme-switcher"
}

links_for() {
  local theme="$1"
  local link

  for link in "$previews/$theme"/*; do
    [[ -e $link ]] || continue
    printf '%s\n' "${link##*/}"
  done
}

echo nord >"$state/theme.name"
ln -nsf "$omarchy/themes/nord/backgrounds/2-moon.jpg" "$state/background"

switch >/dev/null

[[ $(links_for nord) == "000-preview.png
001-0-mine.png
002-1-city.webp
003-2-moon.jpg
004-3-motion.mp4" ]] || fail "theme picker offers a theme's preview, then its backgrounds" "$(links_for nord)"
pass "theme picker collects a theme's preview and backgrounds"

[[ $(readlink "$previews/nord/001-0-mine.png") == "$home/.config/omarchy/backgrounds/nord/0-mine.png" ]] ||
  fail "theme picker offers the backgrounds a user added for a theme"
pass "theme picker includes user backgrounds"

[[ $(links_for plain) == "000-1-only.webp" ]] ||
  fail "theme picker does not repeat the background it fell back to for a preview" "$(links_for plain)"
pass "theme picker keeps a fallback preview out of the list twice"

[[ $(links_for mine) == "000-preview.png
001-1-mine.webp
002-2-linked.webp" ]] || fail "theme picker offers a user theme, symlinks and all" "$(links_for mine)"
pass "theme picker includes user themes"

[[ $(links_for cloned) == "000-preview.png
001-1-own.webp" ]] ||
  fail "theme picker offers a symlink an installed theme would never get to stage" "$(links_for cloned)"
pass "theme picker holds an installed theme to what it can stage"

grep -qx -- '--group-by-dir' "$test_tmp/args" || fail "theme picker groups the picker's rows by theme"
[[ $(grep -A1 -x -- '--item-label' "$test_tmp/args" | tail -n 1) == "theme" ]] ||
  fail "theme picker names what left and right walk"
[[ $(grep -A1 -x -- '--variant-label' "$test_tmp/args" | tail -n 1) == "background" ]] ||
  fail "theme picker names what up and down walk"
grep -qx -- "$previews/nord" "$test_tmp/args" || fail "theme picker passes one directory per theme"
[[ $(grep -A1 -x -- '--selected' "$test_tmp/args" | tail -n 1) == "$previews/nord/000-preview.png" ]] ||
  fail "theme picker opens on the current theme's preview, not on the background that is up"
pass "theme picker opens on the current theme's preview"

# A background added for a theme is a new image under that theme, and a theme
# directory's own mtime never saw it.
sleep 1
printf 'image' >"$home/.config/omarchy/backgrounds/nord/3-late.png"
switch >/dev/null

[[ $(links_for nord) == "000-preview.png
001-0-mine.png
002-3-late.png
003-1-city.webp
004-2-moon.jpg
005-3-motion.mp4" ]] || fail "theme picker picks up a background added after the last open" "$(links_for nord)"
pass "theme picker rebuilds when a background is added"

selection=$(MENU_IMAGES_SELECTION="$previews/nord/003-1-city.webp" switch)
[[ $selection == "nord"$'\t'"$omarchy/themes/nord/backgrounds/1-city.webp" ]] ||
  fail "theme picker reports the theme and the background the user stopped on" "$selection"
pass "theme picker reports the picked theme and background"

selection=$(MENU_IMAGES_SELECTION="$previews/mine/002-2-linked.webp" switch)
[[ $selection == "mine"$'\t'"$home/.config/omarchy/themes/mine/backgrounds/2-linked.webp" ]] ||
  fail "theme picker preserves a user background alias for staged-name matching" "$selection"
pass "theme picker preserves aliased background names"

selection=$(MENU_IMAGES_SELECTION="$previews/nord/005-3-motion.mp4" switch)
[[ $selection == "nord"$'\t'"$omarchy/themes/nord/backgrounds/3-motion.mp4" ]] ||
  fail "theme picker reports a video background like any other variant" "$selection"
pass "theme picker carries video backgrounds through grouped selection"

# Stopping on a dedicated preview declines to choose a background and preserves
# the theme's normal rotation.
selection=$(MENU_IMAGES_SELECTION="$previews/nord/000-preview.png" switch)
[[ $selection == "nord"$'\t' ]] ||
  fail "theme picker reports no background when the user never left the preview" "$selection"
pass "theme picker reports no background for a theme's preview"

# A theme without a dedicated preview displays its first real background. That
# visible background must be applied explicitly rather than silently rotating.
selection=$(MENU_IMAGES_SELECTION="$previews/plain/000-1-only.webp" switch)
[[ $selection == "plain"$'\t'"$omarchy/themes/plain/backgrounds/1-only.webp" ]] ||
  fail "a theme without a preview applies the background it displays" "$selection"
pass "theme picker applies the displayed fallback background"

[[ -z $(MENU_IMAGES_SELECTION="" switch) ]] || fail "theme picker reports nothing when dismissed"
pass "theme picker reports nothing when dismissed"
