#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
themes="$home/.config/omarchy/themes"
commands="$test_tmp/bin"
log="$test_tmp/commands"
mkdir -p "$state" "$commands" "$home/.local/state/omarchy/theme-backgrounds"
for theme in alpha beta; do
  mkdir -p "$themes/$theme/backgrounds/intros"
  cp "$ROOT/themes/tokyo-night/colors.toml" "$themes/$theme/colors.toml"
  printf 'still\n' >"$themes/$theme/backgrounds/1-sky.webp"
  printf 'still\n' >"$themes/$theme/backgrounds/2-road.webp"
  printf 'intro\n' >"$themes/$theme/backgrounds/intros/2-road.mp4"
done
cp -r "$themes/alpha" "$state/theme"
printf 'alpha\n' >"$state/theme.name"
ln -s "$state/theme/backgrounds/1-sky.webp" "$state/background"
printf '%s\n' "$state/theme/backgrounds/2-road.webp" >"$home/.local/state/omarchy/theme-backgrounds/beta"
printf 'already-consumed\n' >"$home/.local/state/omarchy/background-intro.session-id"

cat >"$commands/noop" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$commands/noop"
# This fixture only exercises selection and presentation, so every retint is
# a no-op except the compositor reload, whose timing it checks.
for command in "$ROOT"/bin/omarchy-restart-* "$ROOT"/bin/omarchy-theme-set-* omarchy-hook omarchy-theme-bg-cache; do
  command=${command##*/}
  [[ $command == omarchy-restart-hyprctl ]] || ln -sf noop "$commands/$command"
done
cat >"$commands/omarchy-restart-hyprctl" <<'STUB'
#!/bin/bash
echo "hypr-reload" >>"$TEST_LOG"
STUB
cat >"$commands/hyprctl" <<'STUB'
#!/bin/bash
printf '{"bool":%s}\n' "${TEST_ANIMATIONS:-true}"
STUB
cat >"$commands/omarchy-shell" <<'STUB'
#!/bin/bash
printf 'shell: %s\n' "$*" >>"$TEST_LOG"
# A shell from before the handover knows neither call.
if [[ $2 == "switchBackground" || $2 == "playThemeIntro" || $2 == "selectedBackground" ]]; then
  [[ ${TEST_OLD_SHELL:-false} != true ]] || exit 1
  if [[ $2 == "selectedBackground" ]]; then
    echo "${TEST_SELECTED:-}"
  else
    echo "ok"
  fi
fi
if [[ -n ${TEST_GATE_DIR:-} ]]; then
  if [[ $2 == "themeIntroBusy" && ! -f $TEST_GATE_DIR/fade-ready ]]; then
    if [[ ! -f $TEST_GATE_DIR/fade-waited ]]; then
      touch "$TEST_GATE_DIR/fade-waited"
      echo "pending"
    else
      touch "$TEST_GATE_DIR/fade-ready"
      echo "ready"
    fi
  elif [[ $2 == "themeIntroCoverStatus" && ! -f $TEST_GATE_DIR/cover-ready ]]; then
    if [[ ! -f $TEST_GATE_DIR/fade-ready || $(<"$TEST_STATE/theme.name") != "$TEST_OLD_THEME" ]]; then
      touch "$TEST_GATE_DIR/premature-swap"
    fi
    if [[ ! -f $TEST_GATE_DIR/cover-waited ]]; then
      touch "$TEST_GATE_DIR/cover-waited"
      echo "loading"
    else
      touch "$TEST_GATE_DIR/cover-ready"
      echo "ready"
    fi
  else
    echo "ready"
  fi
fi
STUB
cat >"$commands/owe" <<'STUB'
#!/bin/bash
if [[ $1 == intro && -n ${TEST_RELEASE:-} ]]; then
  printf '%s\n' "$$" >"$TEST_INTRO_PID"
fi
printf 'owe: %s\n' "$*" >>"$TEST_LOG"
if [[ $1 == status && ${TEST_INTRO_PLAYING:-false} == true ]]; then
  echo '{"intro":true}'
fi
[[ ${TEST_OWE_FAIL:-false} != true ]] || exit 1
if [[ $1 == "render" ]]; then
  [[ ${TEST_LIVE_FRAME:-false} == "true" ]] || exit 1
  snapshot=$(jq -r '.path' <<<"$2")
  printf 'live video frame\n' >"$snapshot"
elif [[ $1 == "intro-prepare" && ${TEST_OWE_NO_PREPARE:-false} == "true" ]]; then
  exit 1
fi
if [[ $1 == intro && -n ${TEST_RELEASE:-} ]]; then
  for attempt in {1..100}; do
    [[ ! -f $TEST_RELEASE ]] || exit 0
    sleep 0.05
  done
  exit 1
fi
STUB
chmod +x "$commands/omarchy-restart-hyprctl" "$commands/hyprctl" "$commands/omarchy-shell" "$commands/owe"

set_theme() {
  : >"$log"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$commands:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_LOG="$log" \
    /bin/bash "$ROOT/bin/omarchy-theme-set" "$1" </dev/null >"$test_tmp/stdout" 2>"$test_tmp/stderr" || fail "theme selection completes" "$(cat "$test_tmp/stderr")"
}

# Once a theme switch has put up its cover, the shell sequences the rest:
# BackgroundSwitch plays the intro, reveals the still and reloads Hyprland.
road="$state/theme/backgrounds/2-road.webp"
sky="$state/theme/backgrounds/1-sky.webp"
clip="$state/theme/backgrounds/intros/2-road.mp4"
handed_over() {
  grep -Fxq "shell: shell playThemeIntro $(stat -Lc '%d:%i' "$state/theme") $1" "$log"
}

set_theme beta
handed_over "$road $clip true" || fail "a theme switch hands the remembered background's prepared intro to the shell" "$(cat "$log")"
[[ $(readlink "$state/background") == "$road" ]] || fail "the remembered background is selected"
! grep -qE '^shell: background (prepare|themeTransition)' "$log" || fail "an intro replaces the normal still transition"
! grep -qE '^owe: intro ' "$log" || fail "the shell plays the intro, not the command"
! grep -q '^hypr-reload$' "$log" || fail "the shell reloads Hyprland after the intro, not the command"
[[ $(<"$home/.local/state/omarchy/background-intro.session-id") == already-consumed ]] || fail "a theme switch leaves login consumption unchanged"
pass "switching themes hands the remembered background's intro to the shell"

set_theme beta
[[ $(readlink "$state/background") == "$sky" ]] || fail "reselecting the current theme cycles its background"
grep -q '^shell: background themeTransition ' "$log" || fail "cycling to a background without an intro uses the normal still transition"
! grep -q ' playThemeIntro ' "$log" || fail "cycling to a background without an intro plays none"
set_theme beta
handed_over "$road $clip true" || fail "cycling to a background with an intro plays it" "$(cat "$log")"
OMARCHY_THEME_SKIP_BACKGROUND=1 set_theme alpha
! grep -q ' playThemeIntro ' "$log" || fail "theme refresh does not play an intro"
pass "same-theme cycling plays the next background's intro and refresh keeps the still"

printf '%s\n' "$road" >"$home/.local/state/omarchy/theme-backgrounds/beta"
mkdir -p "$home/.local/state/omarchy/toggles"
touch "$home/.local/state/omarchy/toggles/background-intros-off"
set_theme beta
grep -q '^shell: background themeTransition ' "$log" || fail "disabled intros use the normal still transition"
! grep -q ' playThemeIntro ' "$log" || fail "disabled intros do not play on theme selection"
rm "$home/.local/state/omarchy/toggles/background-intros-off"
printf '%s\n' "$road" >"$home/.local/state/omarchy/theme-backgrounds/alpha"
TEST_ANIMATIONS=false set_theme alpha
grep -q '^shell: background themeTransition ' "$log" || fail "disabled animations use the normal still transition"
! grep -q ' playThemeIntro ' "$log" || fail "disabled animations do not play an intro"
OMARCHY_THEME_HEADLESS=1 set_theme beta
! grep -q ' playThemeIntro ' "$log" || fail "headless theme setup does not play an intro"
pass "theme intros respect the global toggle, disabled animations, and headless setup"

printf '%s\n' "$road" >"$home/.local/state/omarchy/theme-backgrounds/alpha"
TEST_OWE_NO_PREPARE=true set_theme alpha
handed_over "$road $clip false" || fail "a clip older OWE could not prepare starts the ordinary way" "$(cat "$log")"
pass "older OWE keeps the ordinary intro startup path"

printf '%s\n' "$road" >"$home/.local/state/omarchy/theme-backgrounds/beta"
TEST_LIVE_FRAME=true set_theme beta
cover=$(awk '/^shell: shell prepareThemeIntro / { print $4; exit }' "$log")
[[ -f $cover && $(<"$cover") == "live video frame" ]] || fail "an interrupted video supplies the outgoing cover instead of its final still"
pass "interrupted playback uses its current frame as the outgoing cover"

gates="$test_tmp/gates"
mkdir "$gates"
TEST_GATE_DIR="$gates" TEST_STATE="$state" TEST_OLD_THEME=beta set_theme alpha
[[ -f $gates/fade-waited && -f $gates/cover-waited && -f $gates/cover-ready ]] || fail "a rapid selection waits for the running reveal and its own cover"
[[ ! -f $gates/premature-swap ]] || fail "the running reveal and the new cover settle before replacing the active theme"
pass "rapid switches present the outgoing cover before replacing its still"

# A shell an update could not restart only knows to drop the cover, so the
# switch takes the ordinary transition and reloads Hyprland itself.
TEST_OLD_SHELL=true set_theme beta
grep -q '^shell: shell finishThemeIntro ' "$log" || fail "an older shell drops its cover"
grep -q '^shell: background themeTransition ' "$log" || fail "an older shell takes the ordinary transition"
grep -q '^hypr-reload$' "$log" || fail "an older shell's switch reloads Hyprland itself"
pass "an older shell falls back to the ordinary theme transition"

set_background() {
  : >"$log"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$commands:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_LOG="$log" \
    /bin/bash "$ROOT/bin/omarchy-theme-bg-set" "$1" </dev/null >"$test_tmp/stdout" 2>"$test_tmp/stderr" || fail "background selection completes" "$(cat "$test_tmp/stderr")"
}
set_background "$road"
grep -Fxq "shell: shell switchBackground $road $clip" "$log" || fail "a background change is handed to the shell with its intro" "$(cat "$log")"
! grep -q '^shell: -q background set ' "$log" || fail "the shell, not the command, transitions the background"
TEST_OLD_SHELL=true set_background "$sky"
[[ $(readlink "$state/background") == "$sky" ]] || fail "without the shell's switch the command repoints the link"
grep -Fxq "shell: -q background set $sky" "$log" || fail "without the shell's switch the background is set directly"
pass "background changes go to the shell, or straight to the link without it"

# A theme switch repoints the background too, so a background change waits
# for one still holding the theme selection lock.
release="$test_tmp/theme-lock-release"
( flock 9; for attempt in {1..150}; do [[ -f $release ]] && break; sleep 0.02; done ) 9>"$test_tmp/omarchy-theme-set.lock" &
holder=$!
sleep 0.2
set_background "$sky" &
change=$!
sleep 0.3
! grep -q ' switchBackground ' "$log" || fail "a background change waits for a running theme switch"
touch "$release"
wait "$holder" "$change"
grep -Fxq "shell: shell switchBackground $sky " "$log" || fail "the background change goes ahead once the theme switch is done" "$(cat "$log")"
pass "background changes take turns with theme switches"

# Cycling moves on from a selection the shell has not linked yet.
next_background() {
  : >"$log"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$commands:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_LOG="$log" \
    /bin/bash "$ROOT/bin/omarchy-theme-bg-next" </dev/null >"$test_tmp/stdout" 2>"$test_tmp/stderr" || fail "background cycling completes" "$(cat "$test_tmp/stderr")"
}
ln -nsf "$road" "$state/background"
TEST_SELECTED="$sky" next_background
grep -Fxq "shell: shell switchBackground $road $clip" "$log" || fail "cycling moves on from the shell's pending selection" "$(cat "$log")"
TEST_OLD_SHELL=true next_background
[[ $(readlink "$state/background") == "$sky" ]] || fail "without the shell, cycling moves on from the link"
pass "background cycling moves on from a selection that is still being applied"

# A playing intro hides the shell's background, so a theme switch to a still
# without an intro hands the shell its cover to open with the ordinary cut.
if [[ $(<"$state/theme.name") == alpha ]]; then next_theme=beta; else next_theme=alpha; fi
printf '%s\n' "$sky" >"$home/.local/state/omarchy/theme-backgrounds/$next_theme"
TEST_INTRO_PLAYING=true set_theme "$next_theme"
handed_over "$sky  false" || fail "a theme switch during an intro hands its cover over with no clip" "$(cat "$log")"
! grep -q '^shell: background themeTransition ' "$log" || fail "no ordinary transition runs under the playing intro"
! grep -qE '^owe: intro(-prepare)? ' "$log" || fail "the theme's still without an intro plays none"
pass "a theme switch to a still without an intro while one plays keeps its cover"
