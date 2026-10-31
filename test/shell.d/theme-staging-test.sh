#!/bin/bash

set -euo pipefail

# A theme installed with `omarchy theme install` is a stranger's git repo, so
# omarchy-theme-set drops the files that would run its code -- Lua, terminal
# configs, vscode.json -- and keeps the colour. A theme the user wrote themselves
# is not filtered at all.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
# The activation cases below make files unreadable on purpose.
trap 'chmod -R u+rwX "$test_tmp"; rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
themes="$home/.config/omarchy/themes"
mkdir -p "$state" "$themes"

marker="omarchy-theme-staging-marker"

set_theme() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    XDG_RUNTIME_DIR="$test_tmp" \
    bash "$ROOT/bin/omarchy-theme-set" "$1" 2>"$test_tmp/stderr" || return $?
}

staged() {
  printf '%s' "$state/theme/$1"
}

assert_staged() {
  [[ -f $(staged "$1") ]] || fail "$2"
}

assert_not_staged() {
  [[ ! -e $(staged "$1") ]] || fail "$2"
}

assert_no_marker() {
  ! grep -q "$marker" "$(staged "$1")" || fail "$2"
}

write_colors() {
  cat >"$1" <<TOML
mode = "light"

accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"

background = "#1a1b26"
foreground = "#a9b1d6"

color0 = "#1a1b26"
color1 = "#f7768e"
color2 = "#9ece6a"
color3 = "#e0af68"
color4 = "#7aa2f7"
color5 = "#bb9af7"
color6 = "#7dcfff"
color7 = "#a9b1d6"
TOML
}

# A theme that ships everything it is not allowed to ship.
hostile="$themes/hostile"
mkdir -p "$hostile/backgrounds" "$hostile/.git"
write_colors "$hostile/colors.toml"
touch "$hostile/light.mode"
printf 'os.execute("%s")\n' "$marker" >"$hostile/hyprland.lua"
printf 'vim.cmd("%s")\n' "$marker" >"$hostile/neovim.lua"
printf 'shell %s\n' "$marker" >"$hostile/kitty.conf"
printf '[terminal.shell]\nprogram = "%s"\n' "$marker" >"$hostile/alacritty.toml"
printf 'shell = "%s"\n' "$marker" >"$hostile/foot.ini"
printf 'command = "%s"\n' "$marker" >"$hostile/ghostty.conf"
printf 'hl.env("GUM_INPUT_PROMPT", "%s")\n' "$marker" >"$hostile/gum_env.lua"
printf '[bar]\nbackground = "#%s"\n' "000000" >"$hostile/shell.toml"
printf '{}\n' >"$hostile/vscode.json"
printf 'Yaru-red\n' >"$hostile/icons.theme"
printf 'theme[main_bg]="#000000"\n' >"$hostile/btop.theme"
printf 'png\n' >"$hostile/preview.png"
printf 'png\n' >"$hostile/backgrounds/1-real.png"
printf '%s\n' "$marker" >"$hostile/backgrounds/payload.sh"
printf '# notes\n' >"$hostile/README.md"
ln -s /etc/hostname "$hostile/unlock.png"

set_theme hostile || fail "omarchy-theme-set applies a theme that ships disallowed files"

assert_staged colors.toml "the theme's colors.toml is staged"
grep -q '#7aa2f7' "$(staged colors.toml)" || fail "the staged colors.toml is the theme's palette"
assert_staged light.mode "the light mode marker is staged"
assert_staged preview.png "the theme's preview image is staged"
assert_staged backgrounds/1-real.png "an image in backgrounds/ is staged"

assert_not_staged unlock.png "a symlink is not followed out of the theme"
assert_not_staged vscode.json "vscode.json names an extension to install and is not staged"

assert_staged icons.theme "the theme's icon set name is staged"
grep -q 'Yaru-red' "$(staged icons.theme)" || fail "the staged icons.theme is the theme's"
assert_staged btop.theme "the theme's btop colours are staged"
grep -q 'main_bg' "$(staged btop.theme)" || fail "the staged btop.theme is the theme's"
assert_not_staged .git "the clone's own git directory is never staged"

# These run code, so the theme's versions must lose to Omarchy's generated ones
# rather than merely be absent.
for generated in hyprland.lua neovim.lua gum_env.lua kitty.conf alacritty.toml foot.ini ghostty.conf; do
  assert_staged "$generated" "$generated is generated from Omarchy's template"
  assert_no_marker "$generated" "an installed theme cannot supply $generated"
done

# Colour is kept, including a file Omarchy would otherwise have generated.
assert_staged shell.toml "shell.toml is staged"
grep -q '000000' "$(staged shell.toml)" || fail "an installed theme's shell.toml colours are kept"

grep -q 'hyprland.lua' "$test_tmp/stderr" || fail "omarchy-theme-set names the files it ignored"
! grep -q 'README.md' "$test_tmp/stderr" || fail "omarchy-theme-set does not report a theme's documentation"

pass "an installed theme keeps its colour and loses everything that runs code"

# icons.theme is staged verbatim and handed to gsettings, so a symlinked one
# would stage a copy of whatever it points at.
linked="$themes/linked"
mkdir -p "$linked/.git"
write_colors "$linked/colors.toml"
ln -s /etc/hostname "$linked/icons.theme"

set_theme linked || fail "omarchy-theme-set applies a theme whose icons.theme is a symlink"
assert_not_staged icons.theme "a symlinked icons.theme is not followed"

pass "a symlinked icon set name is refused like any other symlink"

# A theme predating colors.toml still gets a palette, without its alacritty.toml
# reaching the staged theme.
legacy="$themes/legacy"
mkdir -p "$legacy/.git"
cat >"$legacy/alacritty.toml" <<TOML
[terminal.shell]
program = "$marker"

[colors.primary]
background = "#102030"
foreground = "#a0b0c0"

[colors.normal]
black = "#102030"
red = "#ff0000"
green = "#00ff00"
yellow = "#ffff00"
blue = "#0000ff"
magenta = "#ff00ff"
cyan = "#00ffff"
white = "#a0b0c0"
TOML

set_theme legacy || fail "omarchy-theme-set applies a theme that only ships alacritty.toml"
assert_staged colors.toml "a legacy theme's palette is recovered from its alacritty.toml"
grep -q '#102030' "$(staged colors.toml)" || fail "the recovered palette is the theme's"
assert_no_marker alacritty.toml "a legacy theme's alacritty.toml is not staged"

pass "a theme older than colors.toml keeps its palette and loses its terminal config"

# An overlay on a stock theme still repaints it, and still cannot add code.
mkdir -p "$themes/tokyo-night/.git"
write_colors "$themes/tokyo-night/colors.toml"
sed -i 's/#7aa2f7/#abcdef/' "$themes/tokyo-night/colors.toml"
printf 'os.execute("%s")\n' "$marker" >"$themes/tokyo-night/hyprland.lua"

set_theme "Tokyo Night" || fail "omarchy-theme-set applies a stock theme with a user overlay"
grep -q '#abcdef' "$(staged colors.toml)" || fail "a user overlay still replaces the stock palette"
assert_no_marker hyprland.lua "a user overlay cannot add Lua to a stock theme"

pass "an overlay on a stock theme repaints it without adding code"

# A theme the user wrote themselves has no git repo behind it and is theirs.
mine="$themes/mine"
mkdir -p "$mine"
write_colors "$mine/colors.toml"
printf 'os.execute("%s")\n' "$marker" >"$mine/hyprland.lua"
printf '{"name":"Mine","extension":"pub.ext"}\n' >"$mine/vscode.json"

set_theme mine || fail "omarchy-theme-set applies a theme the user wrote"
grep -q "$marker" "$(staged hyprland.lua)" || fail "a theme the user wrote keeps its own hyprland.lua"
assert_staged vscode.json "a theme the user wrote keeps every file it ships"
[[ ! -s $test_tmp/stderr ]] || fail "a theme the user wrote reports nothing ignored" "$(cat "$test_tmp/stderr")"

pass "a theme the user wrote is not held to the installed-theme list"

# A working copy symlinked into the themes folder is the user's own too.
ln -s "$mine" "$themes/mine-link"
set_theme mine-link || fail "omarchy-theme-set applies a symlinked working copy"
grep -q "$marker" "$(staged hyprland.lua)" || fail "a symlinked working copy is the user's own"

pass "a symlinked working copy is the user's own"

# The name is joined into paths that get removed and copied into.
for name in .. . "../../evil"; do
  if set_theme "$name" >/dev/null; then
    fail "omarchy-theme-set rejects the theme name '$name'"
  fi
done

pass "a theme name cannot climb out of the theme directories"

# A denylist is only correct while someone adding a template classifies what it
# generates. Every generated theme file is either denied to an installed theme or
# recorded here as carrying colour, so a new template fails until it is placed.
denied=(alacritty.toml foot.ini ghostty.conf kitty.conf gum_env.lua hyprland.lua neovim.lua vscode.json)
colour_only=(btop.theme chromium.theme claude.json fcitx5-theme.conf helix.toml hermes.yaml hyprland-preview-share-picker.css keyboard.rgb obsidian.css pi.json shell.toml t3code.json vscode-theme.json)

for tpl in "$ROOT"/default/themed/*.tpl; do
  generated=$(basename "$tpl" .tpl)
  classified=""

  for name in "${denied[@]}" "${colour_only[@]}"; do
    if [[ $generated == "$name" ]]; then
      classified=1
      break
    fi
  done

  [[ -n $classified ]] ||
    fail "every generated theme file is classified as code or colour" \
      "$generated has a template but is in neither list in $(basename "$0"); decide whether an installed theme may ship it"
done

pass "every file Omarchy generates is classified as code or colour"

# Activation stages a theme completely before it replaces the active one, so a
# failure anywhere along the way leaves the working theme, its name and its
# files as they were. These cases run against a shipped tree of their own, with
# stubs that fail each step in turn.
scratch="$test_tmp/activation"

test_home="$scratch/home"
state="$test_home/.local/state/omarchy/current"
shipped="$scratch/omarchy"
stub_bin="$scratch/bin"
real_awk=$(type -P awk)
mkdir -p "$stub_bin" "$scratch/runtime" "$scratch/temporary"

cat >"$stub_bin/omarchy-theme-set-templates" <<'STUB'
#!/bin/bash
printf '%s\n' "$PPID" >"$TEST_STATE/activation-pid"
[[ ${TEST_FAILURE:-} != "renderer" ]] || exit 42
if [[ ${TEST_FAILURE:-} == "cancel-render" ]]; then
  kill -TERM "$PPID"
  exit 42
fi
exec "$ROOT/bin/omarchy-theme-set-templates" "$@"
STUB

cat >"$stub_bin/omarchy-theme-color" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "palette" ]] || exit 42
exec "$ROOT/bin/omarchy-theme-color" "$@"
STUB

cat >"$stub_bin/omarchy-theme-colors-from-alacritty" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "legacy-palette" ]] || exit 42
exec "$ROOT/bin/omarchy-theme-colors-from-alacritty" "$@"
STUB

cat >"$stub_bin/cp" <<'STUB'
#!/bin/bash
for arg in "$@"; do
  case ${TEST_FAILURE:-}:$arg in
    builtin-copy:"$OMARCHY_PATH/themes/new/"* | user-copy:"$HOME/.config/omarchy/themes/new/"* | nested-copy:*/nested/keep.txt)
      exit 42
      ;;
  esac
done
exec /usr/bin/cp "$@"
STUB

cat >"$stub_bin/mv" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "cancel-publish" && ${*: -1} == "$TEST_STATE/theme" ]]; then
  kill -TERM "$PPID"
fi
if [[ ${TEST_FAILURE:-} == "rollback" ]]; then
  if [[ ${*: -1} == "$TEST_STATE/theme.name" ]]; then
    exit 42
  elif [[ ${*: -1} == "$TEST_STATE/theme" ]]; then
    [[ ! -e $TEST_STATE/exchanged ]] || exit 42
    touch "$TEST_STATE/exchanged"
  fi
fi
case ${TEST_FAILURE:-}:${*: -1} in
  staging-move:"$TEST_STATE/".theme-swap.* | replacement:"$TEST_STATE/theme" | name:"$TEST_STATE/theme.name" | override-write:"$TEST_STATE/next-theme/shell.toml")
    exit 42
    ;;
esac
exec /usr/bin/mv "$@"
STUB

cat >"$stub_bin/rm" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "swap-cleanup" && ${*: -1} == "$TEST_STATE/".theme-swap.* ]]; then
  exit 42
fi
exec /usr/bin/rm "$@"
STUB

cat >"$stub_bin/awk" <<'STUB'
#!/bin/bash
if [[ ${TEST_FAILURE:-} == "template" && $* == *"value_table="* ]]; then exit 42; fi
if [[ ${TEST_FAILURE:-} == "override-read" && ${*: -1} == "$TEST_STATE/next-theme/shell.bar.toml" ]]; then exit 42; fi
exec "$TEST_AWK" "$@"
STUB

cat >"$stub_bin/grep" <<'STUB'
#!/bin/bash
/usr/bin/grep "$@"
status=$?
if [[ ${TEST_FAILURE:-} == "template-disappears" ]]; then
  rm -f "$OMARCHY_PATH/default/themed/example.conf.tpl"
fi
exit "$status"
STUB

cat >"$stub_bin/flock" <<'STUB'
#!/bin/bash
[[ ${TEST_FAILURE:-} != "lock" ]] || exit 42
exec /usr/bin/flock "$@"
STUB

cat >"$stub_bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_IPC"
case $2 in
  prepareThemeIntroCover)
    printf '%s\n' "$3" >"$TEST_STATE/prepared-cover"
    printf '%s\n' "$4" >"$TEST_STATE/prepared-token"
    ;;
  cancelThemeIntro)
    [[ $3 == "$(cat "$TEST_STATE/prepared-token")" ]] || exit 42
    [[ -f $(cat "$TEST_STATE/prepared-cover") ]] || exit 42
    touch "$TEST_STATE/canceled-before-removal"
    ;;
  themeIntroCoverStatus)
    if [[ ${TEST_FAILURE:-} == "cancel-cover" ]]; then
      kill -TERM "$(cat "$TEST_STATE/activation-pid")"
    fi
    echo ready
    ;;
  themeIntroStatus) echo ready ;;
esac
STUB

cat >"$stub_bin/hyprctl" <<'STUB'
#!/bin/bash
printf '{"bool":true}\n'
STUB
cat >"$stub_bin/owe" <<'STUB'
#!/bin/bash
[[ $1 != render ]] || exit 1
STUB
# Keep successful desktop retries inside the fixture: every retint runs directly
# and would otherwise restyle the terminals and apps of whoever runs the test.
mapfile -t retints < <(sed -n '/^\(visible\|other\)_theme_commands=(/,/^)/s/^ *\(omarchy-[a-z0-9-]*\) *$/\1/p' "$ROOT/bin/omarchy-theme-set")
(( ${#retints[@]} > 0 )) || fail "theme retint commands are found to stub"
for command in "${retints[@]}" omarchy-hook omarchy-theme-set-herdr-machines omarchy-theme-bg-cache omarchy-restart-hyprctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
chmod +x "$stub_bin/"*

reset_fixture() {
  chmod -R u+rwX "$scratch"
  rm -rf "$test_home" "$shipped" "$scratch/expected"
  mkdir -p "$state/theme" "$shipped/themes/new" "$shipped/default/themed" "$scratch/expected"
  printf 'previous working configuration\n' >"$state/theme/working.conf"
  printf 'previous image\n' >"$state/theme/background.png"
  printf 'old-theme\n' >"$state/theme.name"
  ln -s "$state/theme/background.png" "$state/background"
  cp "$ROOT/themes/tokyo-night/colors.toml" "$state/theme/colors.toml"
  printf '[bar]\nbackground = "#123456"\n' >"$state/theme/shell.toml"
  cp -a "$state/." "$scratch/expected/"
  cp "$ROOT/themes/tokyo-night/colors.toml" "$shipped/themes/new/colors.toml"
  printf 'accent={{ accent }}\n' >"$shipped/default/themed/example.conf.tpl"
  printf '[bar]\nbackground = "{{ background }}"\n' >"$shipped/default/themed/shell.toml.tpl"
  : >"$scratch/ipc"
}

run_theme() {
  HOME="$test_home" OMARCHY_PATH="$shipped" PATH="$stub_bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$scratch/runtime" TMPDIR="$scratch/temporary" \
    TEST_AWK="$real_awk" TEST_STATE="$state" TEST_IPC="$scratch/ipc" TEST_FAILURE="${1:-}" \
    OMARCHY_THEME_HEADLESS="${2:-1}" OMARCHY_THEME_SKIP_BACKGROUND="${2:-1}" \
    bash "$ROOT/bin/omarchy-theme-set" new >"$scratch/output" 2>&1
}

assert_previous() {
  diff -r "$scratch/expected/theme" "$state/theme" || fail "previous theme files survive"
  cmp "$scratch/expected/theme.name" "$state/theme.name" || fail "previous theme name survives"
  [[ $(readlink "$state/background") == "$(readlink "$scratch/expected/background")" ]] || fail "previous background link survives"
  [[ ! -e $state/next-theme && ! -L $state/next-theme ]] || fail "failed staging is cleaned up"
  [[ ! -s $scratch/ipc ]] || fail "failed activation does not notify the shell"
  [[ -z $(find "$scratch/temporary" -mindepth 1 -print -quit) ]] || fail "renderer scratch files are cleaned up"
  [[ -z $(find "$state" -name '.theme.name.*' -print -quit) ]] || fail "staged name is cleaned up"
  [[ -z $(find "$state" -name '.theme-swap.*' -print -quit) ]] || fail "swap directory is cleaned up"
}

expect_failure() {
  local failure="$1" description="$2"
  if run_theme "$failure"; then
    fail "$description returns failure" "$(cat "$scratch/output")"
  fi
  assert_previous
  pass "$description preserves the working theme, name, and background"
}

for failure in lock renderer cancel-render builtin-copy palette template template-disappears staging-move replacement name; do
  reset_fixture
  expect_failure "$failure" "$failure failure"
done

reset_fixture
if run_theme rollback; then fail "failed rollback reports failure"; fi
recovery_path=$(find "$state" -mindepth 2 -maxdepth 2 -name working.conf -printf '%h\n')
[[ -d $recovery_path && $recovery_path != "$state/theme" ]] || fail "failed rollback retains the previous working files"
diff -r "$scratch/expected/theme" "$recovery_path" || fail "retained recovery files match the previous theme"
grep -F "$recovery_path" "$scratch/output" >/dev/null || fail "failed rollback reports its recovery location"
cmp "$scratch/expected/theme.name" "$state/theme.name" || fail "failed rollback retains the previous theme name"
if run_theme renderer; then fail "retry reports a renderer failure"; fi
diff -r "$scratch/expected/theme" "$recovery_path" || fail "a failed retry preserves the recovery copy"
pass "a failed retry preserves the working theme retained after rollback failure"
run_theme || fail "a later activation can succeed after rollback failure" "$(cat "$scratch/output")"
diff -r "$scratch/expected/theme" "$recovery_path" || fail "a successful retry preserves the recovery copy"
[[ $(cat "$state/theme.name") == "new" && -f $state/theme/example.conf ]] || fail "successful retry publishes the new theme"
pass "a successful retry preserves the recovery copy for manual recovery"

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes/new"
printf 'user customization\n' >"$test_home/.config/omarchy/themes/new/custom.conf"
expect_failure user-copy "user overlay copy failure"

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes/new/.git" "$test_home/.config/omarchy/themes/new/nested"
printf 'nested customization\n' >"$test_home/.config/omarchy/themes/new/nested/keep.txt"
expect_failure nested-copy "nested installed-theme copy failure"

for failure in override-read override-write; do
  reset_fixture
  printf 'background = "#123456"\n' >"$shipped/themes/new/shell.bar.toml"
  expect_failure "$failure" "$failure failure"
done

for kind in local installed; do
  reset_fixture
  rm -rf "$shipped/themes/new"
  mkdir -p "$test_home/.config/omarchy/themes/new"
  if [[ $kind == "installed" ]]; then mkdir "$test_home/.config/omarchy/themes/new/.git"; fi
  printf '[colors.normal]\nblack = "#000000"\n' >"$test_home/.config/omarchy/themes/new/alacritty.toml"
  expect_failure legacy-palette "$kind legacy palette conversion failure"
done

reset_fixture
run_theme || fail "a built-in theme works without a user overlay" "$(cat "$scratch/output")"
[[ $(cat "$state/theme.name") == "new" ]] || fail "successful activation publishes the name"
grep -Fx 'accent=#7aa2f7' "$state/theme/example.conf" >/dev/null || fail "successful activation publishes rendered templates"
[[ ! -e $state/theme/working.conf && ! -e $state/next-theme ]] || fail "successful activation replaces and cleans the previous theme"
run_theme || fail "an already applied theme can be refreshed" "$(cat "$scratch/output")"
[[ -z $(find "$state" -name '.theme-swap.*' -print -quit) ]] || fail "successful activation removes the swap directory"
pass "successful activation renders, replaces, and can be repeated without a user overlay"

reset_fixture
mkdir -p "$test_home/.config/omarchy/themes"
mv "$shipped/themes/new" "$test_home/.config/omarchy/themes/new"
run_theme || fail "a user-only theme works without a built-in theme" "$(cat "$scratch/output")"
grep -Fx 'accent=#7aa2f7' "$state/theme/example.conf" >/dev/null || fail "user-only theme renders"
pass "a missing built-in theme does not prevent a user-only theme from activating"

reset_fixture
rm -rf "$state/theme" "$state/theme.name" "$state/background"
if run_theme name; then fail "first activation reports failed name publication"; fi
[[ ! -e $state/theme && ! -e $state/theme.name && ! -e $state/next-theme ]] || fail "failed first activation leaves no partial current state"
[[ -z $(find "$state" -name '.theme-swap.*' -print -quit) ]] || fail "failed first activation removes the swap directory"
run_theme || fail "first activation can retry successfully" "$(cat "$scratch/output")"
[[ -f $state/theme/example.conf && $(cat "$state/theme.name") == "new" ]] || fail "first activation publishes both files and name"
pass "first activation rolls back failed name publication and can retry"

reset_fixture
run_theme cancel-publish || fail "publication completes across a cancellation signal" "$(cat "$scratch/output")"
[[ -f $state/theme/example.conf && $(cat "$state/theme.name") == "new" ]] || fail "publication keeps the files and name consistent"
[[ ! -e $state/next-theme ]] || fail "publication cleans up the previous theme"
pass "cancellation cannot interrupt the directory and name commit"

reset_fixture
rm "$shipped/themes/new/colors.toml"
printf '[bar]\nbackground = "#111111"\n' >"$shipped/themes/new/shell.toml"
printf 'background = "#123456"\n' >"$shipped/themes/new/shell.bar.toml"
run_theme || fail "manual configs without a palette still activate" "$(cat "$scratch/output")"
grep -Fx 'background = "#123456"' "$state/theme/shell.toml" >/dev/null || fail "manual shell section override is applied"
pass "manual themes without colors.toml retain shell section overrides"

# Early decoding may prepare snapshots, but failure must never start a transition.
for failure in renderer cancel-render name; do
  reset_fixture
  mkdir -p "$shipped/themes/new/backgrounds" "$test_home/.cache/omarchy/background-transitions"
  printf 'next image\n' >"$shipped/themes/new/backgrounds/next.png"
  printf 'another activation\n' >"$test_home/.cache/omarchy/background-transitions/unrelated.png"
  if run_theme "$failure" 0; then fail "$failure with prepared backgrounds returns failure"; fi
  # The preparation IPC is asynchronous and may finish after activation exits.
  for attempt in {1..100}; do
    grep -q '^background prepare ' "$scratch/ipc" && break
    sleep 0.02
  done
  grep -q '^background prepare ' "$scratch/ipc" || fail "background was prepared before $failure"
  if grep -qE 'themeTransition|applyTheme' "$scratch/ipc"; then fail "failed activation does not apply the theme"; fi
  : >"$scratch/ipc"
  assert_previous
  [[ $(find "$test_home/.cache/omarchy/background-transitions" -type f | wc -l) == 1 ]] || fail "failed activation removes its snapshots"
  grep -Fx 'another activation' "$test_home/.cache/omarchy/background-transitions/unrelated.png" >/dev/null || fail "unrelated snapshots survive"
  pass "$failure cleans prepared snapshots and preserves unrelated snapshots"
done

# Intro preparation owns a token before rendering; cleanup must cancel it while
# its snapshot still exists, including after a failed exchange/name rollback.
for failure in renderer cancel-render cancel-cover staging-move replacement name; do
  reset_fixture
  mkdir -p "$shipped/themes/new/backgrounds/intros" "$test_home/.cache/omarchy/background-transitions"
  printf 'next image\n' >"$shipped/themes/new/backgrounds/next.png"
  printf 'intro\n' >"$shipped/themes/new/backgrounds/intros/next.mp4"
  printf 'another activation\n' >"$test_home/.cache/omarchy/background-transitions/unrelated.png"
  if run_theme "$failure" 0; then fail "$failure with a prepared intro returns failure"; fi
  [[ -s $state/prepared-token && -f $state/canceled-before-removal ]] || fail "$failure cancels its token before deleting its cover"
  [[ ! -e $(cat "$state/prepared-cover") ]] || fail "$failure removes the canceled cover"
  if grep -qE 'finishThemeIntro|themeTransition|applyTheme' "$scratch/ipc"; then fail "$failure never applies a palette"; fi
  [[ $(find "$test_home/.cache/omarchy/background-transitions" -type f | wc -l) == 1 ]] || fail "$failure preserves only unrelated snapshots"
  : >"$scratch/ipc"
  assert_previous
  run_theme "" 0 || fail "intro activation can retry after $failure" "$(cat "$scratch/output")"
  [[ $(cat "$state/theme.name") == new && -f $state/theme/example.conf ]] || fail "retry publishes the rendered theme"
  prepared_token=$(cat "$state/prepared-token")
  [[ $prepared_token == "$(stat -Lc '%d:%i' "$state/theme")" ]] || fail "publication preserves the prepared intro token"
  awk '$2 == "prepareThemeIntro" && NF == 6 { found = 1 } END { exit !found }' "$scratch/ipc" || fail "retry supplies both palette payloads"
  ! grep -q 'cancelThemeIntro' "$scratch/ipc" || fail "successful publication keeps the intro"
  # The shell now owns playback and snapshot cleanup after publication.
  grep -q "^shell playThemeIntro $prepared_token " "$scratch/ipc" || fail "retry hands the published intro to the shell"
  [[ -f $(cat "$state/prepared-cover") ]] || fail "retry retains the cover for the shell's handoff"
  pass "$failure cancels the prepared intro before snapshot removal and permits a successful retry"
done

reset_fixture
printf 'custom\n' >"$shipped/themes/new/example.conf"
printf '[bar]\nbackground = "#123456"\n' >"$shipped/themes/new/shell.toml"
run_theme || fail "all template outputs already supplied is a successful no-op" "$(cat "$scratch/output")"
grep -Fx custom "$state/theme/example.conf" >/dev/null || fail "supplied files remain unchanged"
pass "a theme supplying every template output activates successfully"

reset_fixture
rm "$shipped/default/themed/"*
run_theme || fail "an empty template directory is a successful no-op" "$(cat "$scratch/output")"
pass "a theme with no templates activates successfully"

reset_fixture
rm "$shipped/default/themed/shell.toml.tpl"
printf 'background = "#123456"\n' >"$shipped/themes/new/shell.bar.toml"
run_theme || fail "an override without shell.toml is optional" "$(cat "$scratch/output")"
pass "an override without a shell config is a successful no-op"

reset_fixture
printf 'empty_gradient = ""\n' >>"$shipped/themes/new/colors.toml"
printf '{{ hypr_gradient empty_gradient }}|{{ gradient_start empty_gradient }}|{{ shell_gradient empty_gradient }}\n' >"$shipped/default/themed/empty.conf.tpl"
run_theme || fail "empty optional gradients render successfully" "$(cat "$scratch/output")"
[[ $(cat "$state/theme/empty.conf") == '""||' ]] || fail "empty gradients retain their empty values"
pass "empty optional gradients render successfully"

reset_fixture
printf 'padded_rgb = "rgb(08,16,24)"\n' >>"$shipped/themes/new/colors.toml"
printf '{{ gradient_start padded_rgb }}\n' >"$shipped/default/themed/padded.conf.tpl"
run_theme || fail "decimal colors with leading zeros render successfully" "$(cat "$scratch/output")"
[[ $(cat "$state/theme/padded.conf") == "#081018" ]] || fail "leading zeros are read as decimal"
pass "decimal colors with leading zeros render successfully"

# A failed glob must not turn an unreadable source into an empty theme.
for source in builtin overlay installed nested templates template-file; do
  reset_fixture
  case "$source" in
    builtin) unreadable="$shipped/themes/new" ;;
    overlay)
      unreadable="$test_home/.config/omarchy/themes/new"
      mkdir -p "$unreadable"
      ;;
    installed)
      unreadable="$test_home/.config/omarchy/themes/new"
      mkdir -p "$unreadable/.git"
      ;;
    nested)
      unreadable="$test_home/.config/omarchy/themes/new/nested"
      mkdir -p "$unreadable" "${unreadable%/*}/.git"
      ;;
    templates)
      unreadable="$test_home/.config/omarchy/themed"
      mkdir -p "$unreadable"
      ;;
    template-file) unreadable="$shipped/default/themed/example.conf.tpl" ;;
  esac
  chmod 000 "$unreadable"
  if [[ -r $unreadable ]]; then
    chmod u+rwX "$unreadable"
    skip "$source permission failure requires an unprivileged user"
    continue
  fi
  expect_failure "" "unreadable $source"
  chmod u+rwX "$unreadable"
done

reset_fixture
mkdir "$shipped/themes/new/example.conf"
expect_failure "" "template output is a directory"

reset_fixture
run_theme swap-cleanup || fail "cleanup failure does not undo successful publication" "$(cat "$scratch/output")"
[[ $(cat "$state/theme.name") == "new" && -f $state/theme/example.conf ]] || fail "cleanup failure keeps the new theme active"
retained_swap=$(find "$state" -maxdepth 1 -name '.theme-swap.*' -type d)
[[ -f $retained_swap/working.conf ]] || fail "cleanup failure retains the old theme files"
diff -r "$scratch/expected/theme" "$retained_swap" || fail "failed cleanup leaves the old theme files intact"
grep -Fx "omarchy-theme-set: could not remove theme swap; retained theme files at $retained_swap" "$scratch/output" >/dev/null || fail "cleanup failure reports the retained swap path"
run_theme || fail "later activation succeeds with a retained swap" "$(cat "$scratch/output")"
diff -r "$scratch/expected/theme" "$retained_swap" || fail "later activation leaves retained swap files intact"
pass "swap cleanup failure reports retained files without undoing publication or losing them on retry"
