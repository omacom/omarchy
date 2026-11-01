#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" HERDR_APP_HOME="$test_tmp/herdr" PATH="$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_tmp/runtime"
unset XDG_CONFIG_HOME
mkdir -p "$XDG_RUNTIME_DIR"
current="$HOME/.local/state/omarchy/current/theme"
next="$HOME/.local/state/omarchy/current/next-theme"

render_theme() {
  mkdir -p "$next" "$current"
  cp "$ROOT/themes/$1/colors.toml" "$next/colors.toml"
  omarchy-theme-set-templates
  cp "$next/herdr-app.json" "$next/colors.toml" "$current/"
  rm -rf "$next"
}

render_theme nord
omarchy-theme-set-herdr-app
[[ ! -e $HERDR_APP_HOME ]] || fail "theme sync must not create an unused Herdr home"
if omarchy-theme-set-herdr-app --activate >"$test_tmp/missing-home.log" 2>&1; then
  fail "activation must explain an unopened app"
fi
pass "unused Herdr homes are skipped and explicit activation explains what is missing"

mkdir -p "$HERDR_APP_HOME" "$test_tmp/bin"
export HERDR_TEST_CALLS="$test_tmp/calls" HERDR_TEST_VERSION="0.1.11"
cat >"$test_tmp/bin/herdr-app" <<'SH'
#!/bin/bash
if [[ $1 == "--version" ]]; then
  printf 'herdr-app %s\n' "$HERDR_TEST_VERSION"
else
  printf '%s|%s\n' "$HERDR_APP_HOME" "$*" >>"$HERDR_TEST_CALLS"
  [[ ${HERDR_TEST_CLOSED:-0} != "1" ]]
fi
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${HERDR_TEST_MISSING:-0} != "1" ]] && command -v "$1" >/dev/null
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"
printf '{"zoom":1.25,"sounds":{"enabled":false},"theme":"moss","colors":{"border":"#123456"}}\n' >"$HERDR_APP_HOME/settings.json"
cp "$HERDR_APP_HOME/settings.json" "$test_tmp/original.json"
omarchy-theme-set-herdr-app
cmp -s "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json" || fail "publication must preserve settings"
[[ ! -e $HERDR_TEST_CALLS ]] || fail "normal switches must not contact the app"
jq -e '.ansi | length == 16' "$HERDR_APP_HOME/themes/omarchy.json" >/dev/null || fail "published theme needs sixteen terminal colors"
pass "ordinary switches publish a discoverable theme without touching settings or contacting Herdr"

omarchy-theme-set-herdr-app --activate
[[ $(cat "$HERDR_TEST_CALLS") == "$HERDR_APP_HOME|do app.theme --name omarchy" ]] || fail "activation must use the native picker in the resolved home"
cmp -s "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json" || fail "activation must not write global theme or palette overrides"
pass "activation selects through Herdr and preserves every settings byte"

for name in catppuccin-latte nord; do
  render_theme "$name"
  omarchy-theme-set-herdr-app
  cmp -s "$current/herdr-app.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "Herdr must receive the new palette"
  cmp -s "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json" || fail "appearance changes must preserve personal settings"
done
[[ $(wc -l <"$HERDR_TEST_CALLS") == 1 ]] || fail "light/dark switches must not reselect a theme or override the picker"
pass "dark/light/dark updates only the theme file, preserving a different picker choice"

jq '.colors.accent = "#123abc"' "$current/herdr-app.json" >"$test_tmp/accent.json"
mv "$test_tmp/accent.json" "$current/herdr-app.json"
omarchy-theme-set-herdr-app
jq -e '.colors.accent == "#123abc"' "$HERDR_APP_HOME/themes/omarchy.json" >/dev/null || fail "accent-only changes must reach the theme file"
pass "accent-only changes need no settings workaround"

settings_time=$(stat -c %y "$HERDR_APP_HOME/settings.json")
theme_time=$(stat -c %y "$HERDR_APP_HOME/themes/omarchy.json")
omarchy-theme-set-herdr-app
[[ $(stat -c %y "$HERDR_APP_HOME/settings.json") == "$settings_time" && $(stat -c %y "$HERDR_APP_HOME/themes/omarchy.json") == "$theme_time" ]] || fail "unchanged sync must not rewrite watched files"
pass "unchanged palettes do not trigger file reloads"

cp "$HERDR_APP_HOME/themes/omarchy.json" "$test_tmp/good-theme.json"
for filter in '.background = "{{ unresolved }}"' '.ansi = []' '.colors = null' '.unknown = true'; do
  jq "$filter" "$test_tmp/good-theme.json" >"$current/herdr-app.json"
  omarchy-theme-set-herdr-app >"$test_tmp/invalid.log" 2>&1 || fail "invalid colors should skip gracefully"
  grep -q 'Skipping Herdr theme' "$test_tmp/invalid.log" || fail "invalid palette skip should be explained"
  cmp -s "$test_tmp/good-theme.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "invalid palettes must preserve the working theme"
done
if omarchy-theme-set-herdr-app --activate >"$test_tmp/invalid-activation.log" 2>&1; then
  fail "explicit activation must report that invalid colors cannot be selected"
fi
pass "invalid and unresolved palettes skip successfully with the last good theme intact"

render_theme catppuccin-latte
for settings in '{broken' '{"theme":"omarchy","colors":"broken"}' '{"theme":"omarchy","colors":null}'; do
  printf '%s\n' "$settings" >"$HERDR_APP_HOME/settings.json"
  cp "$HERDR_APP_HOME/settings.json" "$test_tmp/personal.json"
  omarchy-theme-set-herdr-app
  cmp -s "$test_tmp/personal.json" "$HERDR_APP_HOME/settings.json" || fail "publication must not parse or rewrite personal settings"
done
pass "even malformed personal settings remain untouched by palette publication"
cp "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json"

HERDR_TEST_CLOSED=1 omarchy-theme-set-herdr-app --activate >"$test_tmp/closed.log" 2>&1 && fail "activation must explain a closed window"
grep -q 'Open Herdr' "$test_tmp/closed.log" || fail "closed window should have a retry instruction"
cmp -s "$current/herdr-app.json" "$HERDR_APP_HOME/themes/omarchy.json" || fail "closed Herdr still needs its published palette"
cmp -s "$test_tmp/original.json" "$HERDR_APP_HOME/settings.json" || fail "closed Herdr must not fall back to settings overrides"
pass "closed-window activation publishes the palette and explains how to retry"

for version in 0.1.10 unknown 0.1.11-rc1; do
  HERDR_TEST_VERSION="$version" omarchy-theme-set-herdr-app --activate >"$test_tmp/version.log" 2>&1 && fail "unsupported versions must not silently use the old workaround"
done
HERDR_TEST_MISSING=1 omarchy-theme-set-herdr-app --activate >"$test_tmp/no-cli.log" 2>&1 && fail "missing Herdr must be explained"
HERDR_TEST_VERSION=0.2.0 omarchy-theme-set-herdr-app --activate
pass "activation requires an available stable Herdr 0.1.11+ and supports later versions"

saved_app_home=$HERDR_APP_HOME
unset HERDR_APP_HOME
export XDG_CONFIG_HOME="$test_tmp/custom config"
mkdir -p "$XDG_CONFIG_HOME/herdr-app"
omarchy-theme-set-herdr-app --activate
[[ $(tail -1 "$HERDR_TEST_CALLS") == "$XDG_CONFIG_HOME/herdr-app|do app.theme --name omarchy" ]] || fail "activation must pass the XDG home to Herdr"
[[ -f $XDG_CONFIG_HOME/herdr-app/themes/omarchy.json ]] || fail "custom XDG home must receive the palette"
unset XDG_CONFIG_HOME
mkdir -p "$HOME/.config/herdr-app"
omarchy-theme-set-herdr-app
[[ -f $HOME/.config/herdr-app/themes/omarchy.json ]] || fail "unset XDG_CONFIG_HOME must use the standard home"
export HERDR_APP_HOME="$saved_app_home" XDG_CONFIG_HOME="$test_tmp/unused config"
omarchy-theme-set-herdr-app
[[ ! -e $XDG_CONFIG_HOME ]] || fail "explicit HERDR_APP_HOME must take precedence over XDG_CONFIG_HOME"
pass "custom XDG homes, standard homes and explicit app homes resolve correctly"

# The real helper must wait for the theme setter, even during the gap in
# which the source directory has been removed and not replaced yet.
python3 - <<'PY'
import fcntl
import json
import os
from pathlib import Path
import subprocess

current = Path.home() / ".local/state/omarchy/current/theme"
app = Path(os.environ["HERDR_APP_HOME"])
with (Path(os.environ["XDG_RUNTIME_DIR"]) / "omarchy-theme-set.lock").open("w") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    palette = json.loads((current / "herdr-app.json").read_text())
    (current / "herdr-app.json").unlink()
    helper = subprocess.Popen(["omarchy-theme-set-herdr-app"])
    try:
        try:
            helper.wait(timeout=0.3)
            raise AssertionError("helper did not wait for the theme setter")
        except subprocess.TimeoutExpired:
            pass
        palette["background"] = "#102030"
        (current / "herdr-app.json").write_text(json.dumps(palette))
        fcntl.flock(lock, fcntl.LOCK_UN)
        helper.wait(timeout=5)
        assert helper.returncode == 0
        assert json.loads((app / "themes/omarchy.json").read_text())["background"] == "#102030"
    finally:
        if helper.poll() is None:
            helper.kill()
            helper.wait()
PY
pass "queued publication waits out source replacement and uses the latest palette"
