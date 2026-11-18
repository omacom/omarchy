#!/bin/bash

set -euo pipefail

# omarchy-theme-set-hermes writes a file another program parses and asks that
# program to switch to it while it is still on its default. Both are exercised
# here against a throwaway HOME with the Hermes readiness probe, the hermes
# command and the theme refresh stubbed, so a skin that stopped being
# validated, a write into a Hermes that was never set up, or an activation
# that trampled a chosen skin shows up in what landed on disk and what was run.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
echo "check" >>"$OMARCHY_TEST_HERMES_CALLS"
[[ $1 == "--check" && ${OMARCHY_TEST_HERMES_READY:-0} == "1" ]]
SH

# A theme switch finishes the hand-over only for the desktop app Omarchy
# installed; --activate is asked for by name and does not look.
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-1} == "1" ]]
SH

# The hook runs the hermes the probe vets, ~/.local/bin/hermes, not one on PATH;
# reset_home installs this stub there and a decoy on PATH that must never run.
cat >"$mock_bin/hermes" <<'SH'
#!/bin/bash
echo "PATH hermes ran: $*" >>"$OMARCHY_TEST_HERMES_CALLS"
exit 1
SH

cat >"$mock_bin/hermes-stub" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HERMES_CALLS"
if [[ $1 == "config" && $2 == "get" ]]; then
  [[ ${OMARCHY_TEST_HERMES_GET_FAILS:-0} == 0 ]] || exit 1
  printf '%s\n' "${OMARCHY_TEST_HERMES_SKIN-default}"
fi
if [[ $1 == "config" && $2 == "set" ]]; then
  [[ ${OMARCHY_TEST_HERMES_SET_FAILS:-0} == 0 ]] || exit 1
fi
SH

# A refresh re-stages the current theme, which is where the skin gets rendered.
cat >"$mock_bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
echo "refresh" >>"$OMARCHY_TEST_HERMES_CALLS"
printf 'name: omarchy\ndescription: Omarchy system theme\ncolors:\n  background: "#1a1b26"\n' \
  >"$HOME/.local/state/omarchy/current/theme/hermes.yaml"
SH

# --wait sleeps between its polls and once more after activating; the stub
# records the delays it was asked for and returns at once.
cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash
printf 'sleep %s\n' "$1" >>"$OMARCHY_TEST_HERMES_CALLS"
if [[ $1 == 60 && -n ${OMARCHY_TEST_SWAP_SOURCE:-} ]]; then
  printf '%s\n' "$OMARCHY_TEST_SWAP_SOURCE" >"$HOME/.local/state/omarchy/current/theme/hermes.yaml"
fi
if [[ $1 == 60 && ${OMARCHY_TEST_DROP_SKINS:-0} == 1 ]]; then
  rm -f "$HOME/.hermes/skins/omarchy.yaml" "$HOME"/.hermes/profiles/*/skins/omarchy.yaml
fi
SH

chmod +x "$mock_bin"/*

good_skin='name: omarchy
description: Omarchy system theme
colors:
  background: "#1a1b26"
  ui_text: "#a9b1d6"
  ui_accent: "#7aa2f7"'

test_home="$test_tmp/home"
hermes_home="$test_home/.hermes"
skin="$hermes_home/skins/omarchy.yaml"
hermes_calls="$test_tmp/hermes-calls"

# Each case gets a fresh HOME so no file survives from the one before. The
# Hermes home is created the way provisioning does on every machine; only
# --set-up adds the config that says Hermes itself has run, on its default
# skin unless --on names another.
reset_home() {
  local source="$good_skin"

  rm -rf "$test_home"
  mkdir -p "$test_home/.local/state/omarchy/current/theme" "$test_home/.local/bin" "$hermes_home/skills"
  cp "$mock_bin/hermes-stub" "$test_home/.local/bin/hermes"
  : >"$hermes_calls"

  while (( $# > 0 )); do
    case "$1" in
      --set-up) printf 'display:\n  skin: default\n' >"$hermes_home/config.yaml" ;;
      --on) printf 'display:\n  skin: %s\n' "$2" >"$hermes_home/config.yaml"; shift ;;
      *) source="$1" ;;
    esac
    shift
  done

  printf '%s\n' "$source" >"$test_home/.local/state/omarchy/current/theme/hermes.yaml"
}

run_hook() {
  OMARCHY_TEST_HERMES_READY="${OMARCHY_TEST_HERMES_READY:-0}" \
    OMARCHY_TEST_HERMES_SKIN="${OMARCHY_TEST_HERMES_SKIN-default}" \
    OMARCHY_TEST_HERMES_GET_FAILS="${OMARCHY_TEST_HERMES_GET_FAILS:-0}" \
    OMARCHY_TEST_HERMES_SET_FAILS="${OMARCHY_TEST_HERMES_SET_FAILS:-0}" \
    OMARCHY_TEST_HERMES_CALLS="$hermes_calls" \
    OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-1}" \
    OMARCHY_TEST_SWAP_SOURCE="${OMARCHY_TEST_SWAP_SOURCE:-}" \
    OMARCHY_TEST_DROP_SKINS="${OMARCHY_TEST_DROP_SKINS:-0}" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_home" \
    HERMES_HOME='' \
    "$ROOT/bin/omarchy-theme-set-hermes" "$@"
}

# -- publishing ---------------------------------------------------------------

reset_home
run_hook
[[ ! -e $hermes_home/skins ]] || fail "a Hermes home that only holds the Omarchy skill gets no skin"
[[ ! -s $hermes_calls ]] || fail "nothing is run for a Hermes that never ran" "$(cat "$hermes_calls")"
pass "a theme switch leaves a machine that never ran Hermes alone"

reset_home --set-up
mkdir -p "$hermes_home/profiles/work"
run_hook 2>"$test_tmp/stderr"
diff -q "$test_home/.local/state/omarchy/current/theme/hermes.yaml" "$skin" >/dev/null ||
  fail "the generated skin is published to ~/.hermes/skins/omarchy.yaml"
diff -q "$skin" "$hermes_home/profiles/work/skins/omarchy.yaml" >/dev/null ||
  fail "an existing Hermes profile gets the skin too"
[[ $(ls "$hermes_home/skins") == "omarchy.yaml" ]] || fail "no temporary file is left beside the skin"
[[ $(cat "$hermes_calls") == "check" ]] || fail "a Hermes that is not ready is asked nothing more" "$(cat "$hermes_calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch says nothing about Hermes" "$(cat "$test_tmp/stderr")"
pass "the skin is published to the Hermes home and every profile"

reset_home --set-up 'name: omarchy
description: Omarchy system theme
colors:
  background: "{{ background }}"'
mkdir -p "$hermes_home/skins"
printf 'name: omarchy\ncolors:\n  background: "#000000"\n' >"$skin"
run_hook 2>"$test_tmp/stderr"
grep -q '#000000' "$skin" || fail "an unresolved placeholder keeps the previous skin in place"
grep -q 'not a plain color palette' "$test_tmp/stderr" || fail "an unresolved placeholder is reported"
pass "a skin with unresolved colors is not published"

# mv would otherwise move the temp file inside a directory at the skin's path,
# leaving Hermes a directory to read and the temp file behind.
reset_home --set-up
mkdir -p "$skin"
if run_hook 2>/dev/null; then
  fail "a directory at the skin's path is an error, not a place to put the skin"
fi
[[ -z $(ls -A "$skin") && $(ls "$hermes_home/skins") == "omarchy.yaml" ]] ||
  fail "nothing is left inside or beside a directory at the skin's path" "$(ls -R "$hermes_home/skins")"
pass "a directory at the skin's path is refused cleanly"

for bad in \
  $'name: omarchy\ndescription: Omarchy system theme\ncolors:\n  background: "#1a1b26"\nbanner_logo: "[link=file:///etc/passwd]x[/link]"' \
  $'name: omarchy\ndescription: Omarchy system theme\ncolors:\n  background: "#1a1b26\\"\\n  ui_text: \\"#ffffff"' \
  $'name: nord\ndescription: Nord\ncolors:\n  background: "#2e3440"' \
  $'description: Omarchy system theme\ncolors:\n  background: "#1a1b26"' \
  $'name: omarchy\ndescription: Nord: arctic palette\ncolors:\n  background: "#2e3440"' \
  $'name: omarchy\ncolors:\n  background: "#1a1b26"\n#\rbanner_logo: "[link=file:///etc/passwd]x[/link]"' \
  $'name: omarchy\ncolors:\n  background: "#1a1b26"\n#\xe2\x80\xa8banner_logo: "evil"' \
  $'name: omarchy\ncolors:\n  background: "#1a1b26"\n#\xc2\x85banner_logo: "evil"' \
  $'name: omarchy\n  background: "#1a1b26"\ncolors:' \
  $'name: omarchy\ncolors:\n  background: "#1a1b26"\ncolors:' \
  $'colors:\n  background: "#1a1b26"\nname: omarchy' \
  $'name: omarchy\ncolors:'; do
  reset_home --set-up "$bad"
  run_hook 2>/dev/null
  [[ ! -e $skin ]] || fail "a skin that is not exactly a named palette of hex colors is not published" "$bad"
done
pass "a skin is held to the shape Hermes loads, on the lines Hermes' YAML reader sees"

# A NUL cannot travel through a shell string, so it is written straight to the
# source; grep reads past one where YAML stops.
reset_home --set-up
printf 'name: omarchy\ncolors:\n  background: "#1a1b26"\0\n' >"$test_home/.local/state/omarchy/current/theme/hermes.yaml"
run_hook 2>/dev/null
[[ ! -e $skin ]] || fail "a NUL byte in the skin is rejected"
pass "a skin carrying a NUL byte is not published"

reset_home --set-up $'# rendered by Omarchy\nname: omarchy\n\ndescription: Omarchy system theme\ncolors:\n  background: "#1a1b26"\n'
run_hook 2>/dev/null
[[ -f $skin ]] || fail "comments and blank lines are allowed around the palette"
pass "a well-formed skin with comments and blank lines is published"

# -- a theme switch finishes a missed hand-over ---------------------------------

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 run_hook 2>"$test_tmp/stderr"
[[ $(cat "$hermes_calls") == $'check\nconfig get display.skin\nconfig set display.skin omarchy' ]] ||
  fail "a ready Hermes still on its default is switched by a theme switch" "$(cat "$hermes_calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch activates quietly" "$(cat "$test_tmp/stderr")"
pass "a theme switch activates the skin on a Hermes still on its default"

reset_home --on omarchy
OMARCHY_TEST_HERMES_READY=1 run_hook
[[ -f $skin ]] || fail "the skin is published when it is already active"
[[ ! -s $hermes_calls ]] || fail "a Hermes already on the skin is not started" "$(cat "$hermes_calls")"
pass "a theme switch does not start a Hermes already on the skin"

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_DESKTOP_INSTALLED=0 run_hook
[[ -f $skin ]] || fail "a Hermes installed some other way still gets the skin published"
[[ ! -s $hermes_calls ]] || fail "a theme switch does not touch a Hermes Omarchy did not install as the app" "$(cat "$hermes_calls")"
pass "a theme switch activates only for the desktop app Omarchy installed"

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_DESKTOP_INSTALLED=0 run_hook --activate 2>/dev/null
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
  fail "--activate switches whichever Hermes it is asked about" "$(cat "$hermes_calls")"
pass "--activate does not ask which Hermes it is"

reset_home --on ares
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_SKIN=ares run_hook 2>"$test_tmp/stderr"
[[ -f $skin ]] || fail "a chosen skin still gets the Omarchy skin published beside it"
[[ ! -s $hermes_calls ]] || fail "a theme switch does not start a Hermes whose config names a chosen skin" "$(cat "$hermes_calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a chosen skin is left without comment on a theme switch" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves a skin the user chose in Hermes"

# Hermes reads the config of the profile named in active_profile, so that is
# the config that says whether there is anything left to do.
reset_home --on omarchy
mkdir -p "$hermes_home/profiles/work"
printf 'display:\n  skin: default\n' >"$hermes_home/profiles/work/config.yaml"
echo work >"$hermes_home/active_profile"
OMARCHY_TEST_HERMES_READY=1 run_hook
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
  fail "an active profile still on its default is switched even when the root config names the skin" "$(cat "$hermes_calls")"
pass "a theme switch follows the active Hermes profile"

reset_home --set-up
mkdir -p "$hermes_home/profiles/work"
printf 'display:\n  skin: ares\n' >"$hermes_home/profiles/work/config.yaml"
echo work >"$hermes_home/active_profile"
OMARCHY_TEST_HERMES_READY=1 run_hook
[[ ! -s $hermes_calls ]] || fail "a skin chosen in the active profile is not replaced" "$(cat "$hermes_calls")"
pass "a theme switch leaves a skin chosen in the active Hermes profile"

# Hermes selects a profile once its directory exists; without a config of its
# own it is on the default skin whatever the root config says.
reset_home --on omarchy
mkdir -p "$hermes_home/profiles/work"
echo Work >"$hermes_home/active_profile"
OMARCHY_TEST_HERMES_READY=1 run_hook
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
  fail "an active profile without a config of its own is on the default and gets switched" "$(cat "$hermes_calls")"
pass "a theme switch follows an active profile that has no config yet"

# Only a plainly named skin ends a switch early; anything Hermes might read as
# its default is left for Hermes to answer.
for line in 'skin: "default"' 'skin: default # chosen long ago' 'skin: null' 'skin: false'; do
  reset_home --set-up
  printf 'display:\n  %s\n' "$line" >"$hermes_home/config.yaml"
  OMARCHY_TEST_HERMES_READY=1 run_hook
  grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
    fail "a config line Hermes reads as the default still gets the skin activated" "$line: $(cat "$hermes_calls")"
done
pass "a theme switch asks Hermes about any skin line that is not a plain name"

reset_home --set-up
mkdir -p "$hermes_home/profiles/broken"
: >"$hermes_home/profiles/broken/skins"
OMARCHY_TEST_HERMES_READY=1 run_hook 2>"$test_tmp/stderr" || fail "a profile that cannot take the skin does not fail the hook"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch stays quiet about a profile it could not reach" "$(cat "$test_tmp/stderr")"
[[ -f $skin ]] || fail "the Hermes home still gets the skin beside a broken profile"
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
  fail "activation still happens beside a broken profile" "$(cat "$hermes_calls")"
pass "a profile that cannot take the skin costs nobody else"

# -- activation ---------------------------------------------------------------

reset_home
run_hook --activate 2>"$test_tmp/stderr"
[[ ! -e $hermes_home/skins && ! -e $hermes_home/config.yaml ]] ||
  fail "--activate writes nothing into a Hermes that has never run"
grep -q 'not set up yet' "$test_tmp/stderr" || fail "--activate says why nothing happened"
pass "--activate waits for Hermes to have been set up"

reset_home --set-up
run_hook --activate 2>"$test_tmp/stderr"
[[ -f $skin ]] || fail "--activate publishes the skin when Hermes is not ready"
[[ $(cat "$hermes_calls") == "check" ]] || fail "a Hermes that is not ready is not run" "$(cat "$hermes_calls")"
grep -q 'hermes config set display.skin omarchy' "$test_tmp/stderr" || fail "an unready Hermes gets the command that finishes the job"
pass "--activate publishes but does not run a Hermes that is not ready"

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 run_hook --activate 2>"$test_tmp/stderr"
[[ $(cat "$hermes_calls") == $'check\nconfig get display.skin\nconfig set display.skin omarchy' ]] ||
  fail "a ready Hermes is asked for its skin and then to switch" "$(cat "$hermes_calls")"
grep -q 'on the Omarchy skin' "$test_tmp/stderr" || fail "--activate reports success"
pass "--activate goes through hermes config set when Hermes runs"

reset_home --on omarchy
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_SKIN=omarchy run_hook --activate 2>/dev/null
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
  fail "--activate goes through Hermes even when the config already names the skin" "$(cat "$hermes_calls")"
pass "--activate always asks Hermes to switch"

for chosen in omarchy ""; do
  reset_home --set-up
  OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_SKIN="$chosen" run_hook --activate 2>/dev/null
  grep -Fxq 'config set display.skin omarchy' "$hermes_calls" ||
    fail "the default and the omarchy skin are both replaced" "skin='$chosen': $(cat "$hermes_calls")"
done
pass "--activate replaces Hermes' default skin"

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_SKIN=ares run_hook --activate 2>"$test_tmp/stderr"
[[ -f $skin ]] || fail "a chosen skin still gets the Omarchy skin published beside it"
! grep -q 'config set' "$hermes_calls" || fail "a skin the user chose is not replaced" "$(cat "$hermes_calls")"
grep -q "'ares' skin" "$test_tmp/stderr" || fail "leaving a chosen skin is reported"
pass "--activate leaves a skin the user chose in Hermes"

reset_home --set-up
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_GET_FAILS=1 run_hook --activate 2>"$test_tmp/stderr" || fail "a Hermes that does not answer is not an error"
! grep -q 'config set' "$hermes_calls" || fail "no answer from Hermes is not taken for the default" "$(cat "$hermes_calls")"
grep -q 'did not say' "$test_tmp/stderr" || fail "an unanswered question is reported"
pass "--activate does not switch a Hermes that did not say which skin it is on"

reset_home --set-up
mkdir -p "$hermes_home/hermes-agent"
touch "$hermes_home/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_HERMES_SET_FAILS=1 run_hook --wait 2>"$test_tmp/stderr" || fail "a Hermes that refuses the write is not an error"
grep -q 'refused' "$test_tmp/stderr" || fail "a refused write is reported"
! grep -q 'sleep 60' "$hermes_calls" || fail "nothing is announced for a write that did not happen" "$(cat "$hermes_calls")"
pass "--activate reports a Hermes that refused the skin and moves on"

# -- a skin the current theme has not rendered yet -------------------------------

reset_home --set-up
rm "$test_home/.local/state/omarchy/current/theme/hermes.yaml"
run_hook
[[ ! -e $hermes_home/skins && ! -s $hermes_calls ]] ||
  fail "a theme switch without a rendered skin publishes nothing" "$(cat "$hermes_calls")"
pass "a theme switch has nothing to do without a rendered skin"

reset_home --set-up
rm "$test_home/.local/state/omarchy/current/theme/hermes.yaml"
if run_hook --activate 2>"$test_tmp/stderr"; then
  fail "--activate fails when no theme has been selected"
fi
grep -q 'Select an Omarchy theme' "$test_tmp/stderr" || fail "a missing theme is reported"
pass "--activate fails without a current theme to render the skin from"

reset_home --set-up
rm "$test_home/.local/state/omarchy/current/theme/hermes.yaml"
echo tokyo-night >"$test_home/.local/state/omarchy/current/theme.name"
OMARCHY_TEST_HERMES_READY=1 run_hook --activate 2>/dev/null
[[ $(head -1 "$hermes_calls") == "refresh" ]] || fail "a theme applied before the template existed is re-staged" "$(cat "$hermes_calls")"
[[ -f $skin ]] || fail "the freshly rendered skin is published"
grep -Fxq 'config set display.skin omarchy' "$hermes_calls" || fail "the freshly rendered skin is activated" "$(cat "$hermes_calls")"
pass "--activate renders the skin for a theme that predates it"

# -- waiting for the desktop app's first launch ----------------------------------

reset_home --set-up
mkdir -p "$hermes_home/hermes-agent"
touch "$hermes_home/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_HERMES_READY=1 run_hook --wait 2>/dev/null
[[ $(cat "$hermes_calls") == $'check\nconfig get display.skin\nconfig set display.skin omarchy\nsleep 60' ]] ||
  fail "--wait activates as soon as the runtime marker is there, then republishes after the gateway is up" "$(cat "$hermes_calls")"
[[ -f $skin ]] || fail "--wait publishes the skin"
pass "--wait activates once the desktop app has built its runtime"

reset_home --set-up
mkdir -p "$hermes_home/hermes-agent" "$hermes_home/profiles/work"
touch "$hermes_home/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_SWAP_SOURCE=$'name: omarchy\ncolors:\n  background: "#1a1b26"\nbanner_logo: "evil"' run_hook --wait 2>/dev/null
! grep -q 'banner_logo' "$skin" || fail "the republish after the gateway is up does not publish a theme that changed underneath into something rejected"
pass "--wait checks the skin again before republishing it"

reset_home --set-up
mkdir -p "$hermes_home/hermes-agent" "$hermes_home/profiles/work"
touch "$hermes_home/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_HERMES_READY=1 OMARCHY_TEST_DROP_SKINS=1 run_hook --wait 2>/dev/null
[[ -f $skin && -f $hermes_home/profiles/work/skins/omarchy.yaml ]] ||
  fail "the republish after the gateway is up writes the skin to the Hermes home and every profile again" "$(ls -R "$hermes_home")"
pass "--wait republishes the skin everywhere once the gateway is up"

reset_home
OMARCHY_TEST_HERMES_READY=1 run_hook --wait 2>"$test_tmp/stderr"
[[ $(head -1 "$hermes_calls") == "sleep 10" && ! -e $hermes_home/skins ]] ||
  fail "--wait polls for the runtime instead of running Hermes" "$(head -3 "$hermes_calls")"
[[ $(grep -c 'sleep 10' "$hermes_calls") == 180 ]] || fail "--wait gives up after 30 minutes" "$(grep -c 'sleep 10' "$hermes_calls")"
grep -q 'did not finish setting up' "$test_tmp/stderr" || fail "giving up is reported"
pass "--wait polls until the desktop app has built its runtime and gives up in time"
