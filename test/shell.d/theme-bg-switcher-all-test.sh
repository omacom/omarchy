#!/bin/bash

set -euo pipefail

# The all-themes switcher hands the image picker one folder of theme-prefixed
# links, because the picker keeps one image per file name and themes reuse
# names. It must also highlight the current background when that background is
# the copy omarchy-theme-set staged, not one of the originals.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
omarchy="$test_tmp/omarchy"
state="$home/.local/state/omarchy/current"
view="$home/.cache/omarchy/all-backgrounds"
stub_bin="$test_tmp/bin"

mkdir -p "$omarchy/themes/nord/backgrounds" "$omarchy/themes/tokyo/backgrounds" \
  "$home/.config/omarchy/themes/tokyo/backgrounds" "$home/.config/omarchy/backgrounds/nord" \
  "$state/theme/backgrounds" "$stub_bin"

printf 'nord' >"$omarchy/themes/nord/backgrounds/omarchy.png"
printf 'tokyo' >"$omarchy/themes/tokyo/backgrounds/omarchy.png"
printf 'stock' >"$omarchy/themes/tokyo/backgrounds/1.png"
printf 'user' >"$home/.config/omarchy/themes/tokyo/backgrounds/1.png"
printf 'mine' >"$home/.config/omarchy/backgrounds/nord/mine.png"

# Link names must stay unique however themes and files are named: "@" and
# "%" in a user's theme name are escaped, so the first "@" always ends it.
mkdir -p "$home/.config/omarchy/themes/foo@bar/backgrounds" "$home/.config/omarchy/themes/foo/backgrounds"
printf 'foo@bar' >"$home/.config/omarchy/themes/foo@bar/backgrounds/baz.png"
printf 'foo' >"$home/.config/omarchy/themes/foo/backgrounds/bar@baz.png"
mkdir -p "$home/.config/omarchy/themes/foo%40bar/backgrounds"
printf 'foo%%40bar' >"$home/.config/omarchy/themes/foo%40bar/backgrounds/baz.png"
printf 'tab' >"$omarchy/themes/nord/backgrounds/a"$'\t'"tab.png"

# Stand-in picker: record the arguments it was opened with.
cat >"$stub_bin/omarchy-menu-images" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$PICKER_ARGS"
SH
chmod +x "$stub_bin/omarchy-menu-images"

run_switcher() {
  HOME="$home" XDG_CACHE_HOME="$home/.cache" OMARCHY_PATH="$omarchy" \
    PICKER_ARGS="$test_tmp/args" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-bg-switcher-all"
}

selected() {
  sed -n '/^--selected$/{n;p;q}' "$test_tmp/args"
}

# Stage nord the way omarchy-theme-set does: a copy, with the background
# pointing at the copy.
cp "$omarchy/themes/nord/backgrounds/omarchy.png" "$state/theme/backgrounds/omarchy.png"
printf 'nord' >"$state/theme.name"
ln -sfn "$state/theme/backgrounds/omarchy.png" "$state/background"

run_switcher

[[ $(readlink "$view/nord@omarchy.png") == "$omarchy/themes/nord/backgrounds/omarchy.png" ]] &&
  [[ $(readlink "$view/tokyo@omarchy.png") == "$omarchy/themes/tokyo/backgrounds/omarchy.png" ]] ||
  fail "same-named backgrounds from different themes both get a link" "$(ls -l "$view")"
pass "same-named backgrounds from different themes both get a link"

[[ $(readlink "$view/tokyo@1.png") == "$home/.config/omarchy/themes/tokyo/backgrounds/1.png" ]] ||
  fail "a user theme's background wins over the stock theme of the same name" "$(ls -l "$view")"
pass "a user theme's background wins over the stock theme of the same name"

[[ $(readlink "$view/nord@mine.png") == "$home/.config/omarchy/backgrounds/nord/mine.png" ]] ||
  fail "user backgrounds for a theme are included" "$(ls -l "$view")"
pass "user backgrounds for a theme are included"

[[ $(readlink "$view/foo%40bar@baz.png") == "$home/.config/omarchy/themes/foo@bar/backgrounds/baz.png" ]] &&
  [[ $(readlink "$view/foo@bar@baz.png") == "$home/.config/omarchy/themes/foo/backgrounds/bar@baz.png" ]] &&
  [[ $(readlink "$view/foo%2540bar@baz.png") == "$home/.config/omarchy/themes/foo%40bar/backgrounds/baz.png" ]] ||
  fail "theme and file names cannot collide across themes" "$(ls -l "$view")"
pass "theme and file names cannot collide across themes"

grep -qx -- "--filterable" "$test_tmp/args" && [[ $(tail -n 1 "$test_tmp/args") == "$view" ]] ||
  fail "the picker opens filterable on the link folder" "$(cat "$test_tmp/args")"
pass "the picker opens filterable on the link folder"

[[ $(selected) == "$omarchy/themes/nord/backgrounds/omarchy.png" ]] ||
  fail "a staged background is mapped back to its original" "selected: $(selected)"
pass "a staged background is mapped back to its original"

# A staged background maps back to its own theme, even when another theme's
# name and file would have run together into the same link name.
cp "$home/.config/omarchy/themes/foo@bar/backgrounds/baz.png" "$state/theme/backgrounds/baz.png"
printf 'foo@bar' >"$state/theme.name"
ln -sfn "$state/theme/backgrounds/baz.png" "$state/background"
run_switcher
[[ $(selected) == "$home/.config/omarchy/themes/foo@bar/backgrounds/baz.png" ]] ||
  fail "a staged background maps back to its own theme" "selected: $(selected)"
pass "a staged background maps back to its own theme"

# Choosing a background set by omarchy-theme-bg-set keeps pointing at it.
ln -sfn "$omarchy/themes/tokyo/backgrounds/omarchy.png" "$state/background"
run_switcher
[[ $(selected) == "$omarchy/themes/tokyo/backgrounds/omarchy.png" ]] ||
  fail "an original background is selected as is" "selected: $(selected)"
pass "an original background is selected as is"

# A file name with a tab is linked once and left alone on later opens.
tab_link="$view/nord@a"$'\t'"tab.png"
[[ $(readlink "$tab_link") == "$omarchy/themes/nord/backgrounds/a"$'\t'"tab.png" ]] ||
  fail "file names with tabs are linked" "$(ls -l "$view")"
touch -d '2001-01-01' "$view"
run_switcher
[[ $(stat -c %Y "$view") == $(date -d '2001-01-01' +%s) ]] ||
  fail "an unchanged view is not rewritten, even with tabs in file names"
pass "an unchanged view is not rewritten, even with tabs in file names"

# Links are kept in step with the themes.
rm "$omarchy/themes/tokyo/backgrounds/omarchy.png" "$omarchy/themes/nord/backgrounds/a"$'\t'"tab.png"
run_switcher
[[ ! -e $view/tokyo@omarchy.png && ! -L $view/tokyo@omarchy.png && ! -L $tab_link ]] ||
  fail "a removed background loses its link" "$(ls -l "$view")"
pass "a removed background loses its link"

# A background added to a theme shows up, and anything that is not one of the
# switcher's links is left alone.
printf 'new' >"$omarchy/themes/nord/backgrounds/new.png"
printf 'keep' >"$view/not-a-link.txt"
run_switcher
[[ $(readlink "$view/nord@new.png") == "$omarchy/themes/nord/backgrounds/new.png" ]] ||
  fail "a new background gets a link" "$(ls -l "$view")"
pass "a new background gets a link"

[[ -f $view/not-a-link.txt ]] || fail "files that are not links are never removed"
pass "files that are not links are never removed"

# A background replaced at the same path keeps its link, but the folder's
# mtime still moves, so the picker drops its cached preview.
touch -d '2001-01-01' "$view"
printf 'nord, redrawn' >"$omarchy/themes/nord/backgrounds/new.png"
run_switcher
[[ $(stat -c %Y "$view") != $(date -d '2001-01-01' +%s) ]] ||
  fail "a background replaced in place refreshes the view"
pass "a background replaced in place refreshes the view"

# Hidden files are backgrounds too, as in the per-theme switcher.
printf 'hidden' >"$home/.config/omarchy/backgrounds/nord/.hidden.png"
run_switcher
[[ $(readlink "$view/nord@.hidden.png") == "$home/.config/omarchy/backgrounds/nord/.hidden.png" ]] ||
  fail "hidden backgrounds get a link" "$(ls -la "$view")"
pass "hidden backgrounds get a link"
