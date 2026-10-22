#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
home="$test_dir/home"
migration="$ROOT/migrations/1792259038.sh"
webp_migration="$ROOT/migrations/1791470456.sh"
mkdir -p "$test_dir/bin"
call_log="$test_dir/shell-calls"
cat >"$test_dir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$test_dir/bin/omarchy-shell"

state="$home/.local/state/omarchy"
staged="$state/current/theme/backgrounds"
current="$state/current/background"
remembered="$state/theme-backgrounds"
user_theme="$home/.config/omarchy/themes/tokyo-night/backgrounds"
user_backgrounds="$home/.config/omarchy/backgrounds/tokyo-night"

# The staged theme as omarchy-theme-set leaves it, from this checkout.
reset_home() {
  rm -rf "$home"
  mkdir -p "$staged" "$remembered"
  printf '%s\n' "${1:-tokyo-night}" >"$state/current/theme.name"
  cp "$ROOT/themes/${1:-tokyo-night}/backgrounds/"* "$staged/"
  : >"$call_log"
}

run() {
  HOME="$home" OMARCHY_PATH="$ROOT" CALL_LOG="$call_log" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$1" >"$test_dir/output"
}

# A 4.0.x Tokyo Night selection after the update restaged the theme. The WebP
# repair runs first, as on a real upgrade, and has nothing to offer these.
reset_home
ln -s "$staged/0-winding-road.jpg" "$current"
printf '%s\n' "$staged/3-sunset-lake.png" >"$remembered/tokyo-night"
run "$webp_migration"
run "$migration"
[[ $(readlink "$current") == "$staged/1-winding-road.webp" ]] || fail "4.0.x's 0-winding-road follows to 1-winding-road"
[[ $(<"$call_log") == "-q background set $staged/1-winding-road.webp" ]] || fail "the running shell is told about the repaired background"
[[ $(<"$remembered/tokyo-night") == "$staged/4-sunset-lake.webp" ]] || fail "a remembered 3-sunset-lake follows to 4-sunset-lake"
pass "renumbered Tokyo Night backgrounds keep their current and remembered selections"

: >"$call_log"
run "$migration"
[[ $(readlink "$current") == "$staged/1-winding-road.webp" && ! -s $call_log ]] || fail "a second run changes nothing"
[[ $(<"$remembered/tokyo-night") == "$staged/4-sunset-lake.webp" ]] || fail "a second run keeps the remembered repair"
pass "the repair is idempotent"

# Names match whole: 6-oma is 7-oma, not 6-oma-cityscape; 5-oma-cityscape is 6-oma-cityscape.
reset_home
ln -s "$staged/6-oma.jpg" "$current"
printf '%s\n' "$staged/5-oma-cityscape.jpg" >"$remembered/tokyo-night"
run "$migration"
[[ $(readlink "$current") == "$staged/7-oma.webp" ]] || fail "6-oma follows to 7-oma, not to 6-oma-cityscape"
[[ $(<"$remembered/tokyo-night") == "$staged/6-oma-cityscape.jpg" ]] || fail "5-oma-cityscape follows to 6-oma-cityscape"
pass "names are matched whole"

# A staged theme without the renumbered file gets it before the link moves.
reset_home
rm "$staged"/*
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ -f $staged/1-winding-road.webp && $(readlink "$current") == "$staged/1-winding-road.webp" ]] || fail "a staged theme without the renumbered file gets it"
pass "the staged theme is completed first"

# A background that still opens is the user's, renumbered or not.
reset_home
touch "$staged/0-winding-road.jpg"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" && ! -s $call_log ]] || fail "a working background is kept"
pass "a background that still opens is kept"

# A symlinked current/theme is someone's own directory: nothing is copied into it.
reset_home
own_theme="$test_dir/own-theme"
rm -rf "$own_theme"
mv "$state/current/theme" "$own_theme"
ln -s "$own_theme" "$state/current/theme"
rm "$own_theme/backgrounds/1-winding-road.webp"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" && ! -e $own_theme/backgrounds/1-winding-road.webp ]] || fail "nothing is copied through a symlinked current theme"
pass "a symlinked current theme is left alone"

# A remembered selection is judged against its own theme, not the active one.
reset_home gruvbox
printf '%s\n' "$staged/1-quattro.jpg" >"$remembered/tokyo-night"
run "$migration"
[[ $(<"$remembered/tokyo-night") == "$staged/2-quattro.webp" ]] || fail "an inactive Tokyo Night selection follows its own theme"
pass "remembered selections are checked against their named theme"

# A user theme of the same name is laid over the bundled one: an unrelated user
# background changes nothing, a user file of the old name keeps it, and a second
# match across both is not guessed between.
reset_home
mkdir -p "$user_theme"
touch "$user_theme/my-own.jpg"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/1-winding-road.webp" ]] || fail "an unrelated user theme background does not block the repair"

reset_home
mkdir -p "$user_theme"
touch "$user_theme/0-winding-road.jpg" "$staged/0-winding-road.jpg"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" ]] || fail "a user theme's own file of that name is kept"

reset_home
mkdir -p "$user_theme"
touch "$user_theme/9-winding-road.png"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" && ! -s $call_log ]] || fail "two matches across user and bundled files are not guessed between"

# A symlink in a user theme may or may not be staged (a cloned theme's are
# not): one standing for the old name or for a match leaves the selection.
reset_home
mkdir -p "$user_theme"
ln -s "$test_dir/elsewhere.jpg" "$user_theme/7-winding-road.jpg"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" ]] || fail "a symlinked match is not taken or guessed past"

reset_home
mkdir -p "$user_theme"
ln -s "$test_dir/elsewhere.jpg" "$user_theme/0-winding-road.jpg"
ln -s "$staged/0-winding-road.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-winding-road.jpg" ]] || fail "a dangling symlink of the old name keeps the selection"

reset_home
mkdir -p "$home/.config/omarchy/themes/tokyo-night/.git" "$test_dir/outside"
rm -rf "$test_dir/outside"/*
touch "$test_dir/outside/8-cliff.jpg"
ln -s "$test_dir/outside" "$user_theme"
ln -s "$staged/0-cliff.jpg" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/0-cliff.jpg" && ! -e $staged/8-cliff.jpg ]] || fail "a symlinked backgrounds folder is not looked through"
pass "a user theme is laid over the bundled one, its symlinks left alone"

# Left alone: a background that is still there, the user's own backgrounds
# (present or not), the WebP repair's case, unnumbered names, odd state values.
reset_home
ln -s "$staged/1-winding-road.webp" "$current"
run "$migration"
[[ $(readlink "$current") == "$staged/1-winding-road.webp" && ! -s $call_log ]] || fail "an existing background is not touched"

reset_home
mkdir -p "$user_backgrounds"
touch "$user_backgrounds/0-winding-road.jpg"
ln -s "$user_backgrounds/0-winding-road.jpg" "$current"
printf '%s\n' "$user_backgrounds/0-winding-road.jpg" >"$remembered/tokyo-night"
printf '%s\n' "$user_backgrounds/1-quattro.jpg" >"$remembered/gruvbox"
run "$migration"
[[ $(readlink "$current") == "$user_backgrounds/0-winding-road.jpg" ]] || fail "the user's own background is not renumbered"
[[ $(<"$remembered/tokyo-night") == "$user_backgrounds/0-winding-road.jpg" ]] || fail "a remembered own background is not renumbered"
[[ $(<"$remembered/gruvbox") == "$user_backgrounds/1-quattro.jpg" ]] || fail "a missing own background is not renumbered"

reset_home
ln -s "$staged/omarchy.png" "$current"
printf '%s\n' "0-winding-road.jpg" >"$remembered/tokyo-night"
: >"$remembered/gruvbox"
run "$migration"
[[ $(readlink "$current") == "$staged/omarchy.png" ]] || fail "an unnumbered name is left to the WebP repair"
[[ $(<"$remembered/tokyo-night") == "0-winding-road.jpg" ]] || fail "a relative remembered value is left alone"
[[ ! -s $remembered/gruvbox ]] || fail "an empty remembered value is left alone"
pass "anything that is not a renumbered theme background is left alone"
