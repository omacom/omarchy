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
# Post-theme retints run through bash -lc; this fixture only exercises selection and presentation.
for command in omarchy-theme-set-templates omarchy-hook omarchy-theme-set-herdr-machines omarchy-theme-bg-cache; do
  ln -s noop "$commands/$command"
done
cat >"$commands/bash" <<'STUB'
#!/bin/bash
if [[ $1 == "-lc" && $2 == "omarchy-restart-hyprctl" ]]; then
  omarchy-restart-hyprctl
fi
STUB
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
if [[ -n ${TEST_GATE_DIR:-} ]]; then
  if [[ $2 == "themeIntroStatus" && ! -f $TEST_GATE_DIR/fade-ready ]]; then
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
chmod +x "$commands/bash" "$commands/omarchy-restart-hyprctl" "$commands/hyprctl" "$commands/omarchy-shell" "$commands/owe"

set_theme() {
  : >"$log"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$commands:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_LOG="$log" \
    /bin/bash "$ROOT/bin/omarchy-theme-set" "$1" >"$test_tmp/stdout" 2>"$test_tmp/stderr" || fail "theme selection completes" "$(cat "$test_tmp/stderr")"
}
wait_command() {
  for attempt in {1..100}; do
    grep -q "$1" "$log" && return 0
    sleep 0.02
  done
  fail "theme selection reaches $1" "$(cat "$log")"
}

set_theme beta
wait_command '^owe: intro '
grep -Fxq "owe: intro --start first-frame --refresh $state/theme/backgrounds/intros/2-road.mp4" "$log" || fail "a theme switch plays the remembered background's matching prepared intro"
[[ $(readlink "$state/background") == "$state/theme/backgrounds/2-road.webp" ]] || fail "the remembered background is selected"
! grep -qE '^shell: background (prepare|themeTransition)' "$log" || fail "an intro replaces the normal still transition"
[[ $(<"$home/.local/state/omarchy/background-intro.session-id") == already-consumed ]] || fail "a theme switch leaves login consumption unchanged"
pass "switching themes plays the matching intro for the remembered background"

set_theme beta
[[ $(readlink "$state/background") == "$state/theme/backgrounds/1-sky.webp" ]] || fail "reselecting the current theme cycles its background"
grep -q '^shell: background themeTransition ' "$log" || fail "same-theme cycling uses the normal still transition"
! grep -q '^owe: intro ' "$log" || fail "same-theme cycling does not play an intro"
OMARCHY_THEME_SKIP_BACKGROUND=1 set_theme alpha
! grep -q '^owe: intro ' "$log" || fail "theme refresh does not play an intro"
pass "same-theme cycling and refresh keep the normal background behavior"

printf '%s\n' "$state/theme/backgrounds/2-road.webp" >"$home/.local/state/omarchy/theme-backgrounds/beta"
mkdir -p "$home/.local/state/omarchy/toggles"
touch "$home/.local/state/omarchy/toggles/background-intros-off"
set_theme beta
grep -q '^shell: background themeTransition ' "$log" || fail "disabled intros use the normal still transition"
! grep -q '^owe: intro ' "$log" || fail "disabled intros do not play on theme selection"
rm "$home/.local/state/omarchy/toggles/background-intros-off"
printf '%s\n' "$state/theme/backgrounds/2-road.webp" >"$home/.local/state/omarchy/theme-backgrounds/alpha"
TEST_ANIMATIONS=false set_theme alpha
grep -q '^shell: background themeTransition ' "$log" || fail "disabled animations use the normal still transition"
! grep -q '^owe: intro ' "$log" || fail "disabled animations do not play an intro"
OMARCHY_THEME_HEADLESS=1 set_theme beta
! grep -q '^owe: intro ' "$log" || fail "headless theme setup does not play an intro"
pass "theme intros respect the global toggle, disabled animations, and headless setup"

# Alpha's remembered image must have a clip for these presentation checks.
printf '%s\n' "$state/theme/backgrounds/2-road.webp" >"$home/.local/state/omarchy/theme-backgrounds/alpha"
TEST_OWE_FAIL=true set_theme alpha
wait_command '^shell: background setInstant '
wait_command '^hypr-reload$'
! grep -q '^owe: intro ' "$log" || fail "an unavailable renderer falls back to the still"
pass "unavailable OWE falls back to the selected still image"

printf '%s\n' "$state/theme/backgrounds/2-road.webp" >"$home/.local/state/omarchy/theme-backgrounds/beta"
release="$test_tmp/release"
TEST_LIVE_FRAME=true TEST_INTRO_PID="$test_tmp/intro.pid" TEST_RELEASE="$release" set_theme beta
wait_command '^owe: intro '
cover=$(awk '/^shell: shell prepareThemeIntro / { print $4; exit }' "$log")
[[ -f $cover && $(<"$cover") == "live video frame" ]] || fail "an interrupted video supplies the outgoing cover instead of its final still"
kill -0 "$(<"$test_tmp/intro.pid")" || fail "the fake renderer is still playing during the lock check"
timeout 1 flock "$test_tmp/omarchy-theme-set.lock" true || fail "theme playback does not retain the theme selection lock"
touch "$release"
pass "interrupted playback uses its current frame and releases the theme selection lock"

TEST_OWE_NO_PREPARE=true set_theme alpha
wait_command '^owe: intro '
grep -Fxq "owe: intro --start first-frame $state/theme/backgrounds/intros/2-road.mp4" "$log" || fail "older OWE uses the ordinary intro path"
pass "older OWE keeps the ordinary intro startup path"

gates="$test_tmp/gates"
mkdir "$gates"
TEST_GATE_DIR="$gates" TEST_STATE="$state" TEST_OLD_THEME=alpha set_theme beta
wait_command '^owe: intro '
[[ -f $gates/fade-waited && -f $gates/cover-waited && -f $gates/cover-ready ]] || fail "a rapid selection waits for the opening fade and replacement cover"
[[ ! -f $gates/premature-swap ]] || fail "the outgoing fade and cover settle before replacing the active theme"
pass "rapid switches present the outgoing video cover before replacing its still"

wait_command '^hypr-reload$'
release="$test_tmp/reload-release"
TEST_INTRO_PID="$test_tmp/intro.pid" TEST_RELEASE="$release" set_theme alpha
wait_command '^owe: intro '
! grep -q '^hypr-reload$' "$log" || fail "the compositor is not reloaded during intro playback"
touch "$release"
wait_command '^hypr-reload$'
(( $(grep -c '^hypr-reload$' "$log") == 1 )) || fail "the compositor reloads once after playback"
pass "theme intros defer the compositor reload until playback finishes"

release="$test_tmp/superseded-release"
TEST_INTRO_PID="$test_tmp/intro.pid" TEST_RELEASE="$release" set_theme beta
wait_command '^owe: intro '
cover=$(awk '/^shell: shell prepareThemeIntro / { print $4; exit }' "$log")
! grep -q '^hypr-reload$' "$log" || fail "the held intro has not reloaded the compositor"
OMARCHY_THEME_SKIP_BACKGROUND=1 set_theme alpha
grep -q '^hypr-reload$' "$log" || fail "a theme refresh reloads the compositor immediately"
touch "$release"
for attempt in {1..100}; do
  [[ -f $cover ]] || break
  sleep 0.02
done
[[ ! -f $cover ]] || fail "the superseded intro finishes cleanup"
(( $(grep -c '^hypr-reload$' "$log") == 1 )) || fail "the superseded intro cannot reload during a newer theme"
pass "superseded intros do not reload the compositor"
