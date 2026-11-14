#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# mise applies [bootstrap.settings.omarchy] through default/mise/plugins/omarchy:
# it reads the current values, writes only the ones that differ, and reads them
# again. Each setting goes through the Omarchy command that owns it, so the
# real commands run here against a scratch HOME, with the session's side
# (Hyprland, the shell, notifications) and the theme and font machinery stubbed.

require_command mise

if ! MISE_EXPERIMENTAL=1 mise bootstrap settings status --help >/dev/null 2>&1; then
  skip "this mise has no bootstrap settings plugins (needs 2026.11.8 or later)"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
project="$test_tmp/project"
calls="$test_tmp/calls"
mkdir -p "$mock_bin" "$project" "$test_tmp/home" "$test_tmp/plugins"

# mise only loads a system plugin that group and others cannot write to.
cp -R "$ROOT/default/mise/plugins/omarchy" "$test_tmp/plugins/omarchy"
chmod -R go-w "$test_tmp/plugins"

for stub in omarchy-notification-send omarchy-restart-hyprctl omarchy-restart-terminal omarchy-restart-btop omarchy-shell omarchy-theme-set-foot omarchy-theme-set-glass; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$stub"
done

# No workspace has windows, and Hyprland names no layout of its own.
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
case "$*" in
  *"workspaces -j"* | *"clients -j"*) echo "[]" ;;
esac
SH

cat >"$mock_bin/omarchy-theme-set" <<'SH'
#!/bin/bash
printf 'theme-set %s\n' "$1" >>"$OMARCHY_TEST_CALLS"
mkdir -p "$HOME/.local/state/omarchy/current"
printf '%s\n' "$1" >"$HOME/.local/state/omarchy/current/theme.name"
SH

cat >"$mock_bin/omarchy-font-current" <<'SH'
#!/bin/bash
cat "$HOME/font" 2>/dev/null || echo "JetBrainsMono Nerd Font"
SH

cat >"$mock_bin/omarchy-font-set" <<'SH'
#!/bin/bash
printf 'font-set %s\n' "$1" >>"$OMARCHY_TEST_CALLS"
if [[ $1 == "Missing Font" ]]; then
  echo "Font '$1' not found."
  exit 1
fi
printf '%s\n' "$1" >"$HOME/font"
SH

chmod +x "$mock_bin"/*

settings_env=()
settings() {
  (
    cd "$project"
    env -i HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
      OMARCHY_TEST_CALLS="$calls" MISE_EXPERIMENTAL=1 MISE_YES=1 \
      MISE_SYSTEM_PLUGINS_DIRS="$test_tmp/plugins" MISE_TRUSTED_CONFIG_PATHS="$project" \
      "${settings_env[@]}" mise bootstrap settings "$@"
  )
}

toggles="$test_tmp/home/.local/state/omarchy/toggles"

cat >"$project/mise.toml" <<'TOML'
[bootstrap.settings.omarchy]
theme = "tokyo-night"
font = "CaskaydiaMono Nerd Font"
screensaver = false

[bootstrap.settings.omarchy.appearance]
corners = "rounded"
transparency = "opaque"
animations = false
gaps = false
bar = false

[bootstrap.settings.omarchy.workspaces]
layout = "scrolling"
TOML

# A fresh desktop: no theme recorded, and every other setting at its default.
status=$(settings status 2>&1) || fail "status reads a fresh desktop" "$status"
expected='theme "tokyo-night" (unset) differs
font "CaskaydiaMono Nerd Font" "JetBrainsMono Nerd Font" differs
screensaver false true differs
appearance.corners "rounded" "theme" differs
appearance.transparency "opaque" "transparent" differs
appearance.animations false true differs
appearance.gaps false true differs
appearance.bar false true differs
workspaces.layout "scrolling" "dwindle" differs'
actual=$(sed -E 's/^omarchy +//; s/ +/ /g' <<<"$status")
[[ $actual == "$expected" ]] || fail "status reads a fresh desktop" "$actual"
pass "status reads a fresh desktop"

if settings status --missing >/dev/null 2>&1; then
  fail "status --missing fails while a setting differs"
fi
pass "status --missing fails while a setting differs"

dry_run=$(settings apply --dry-run 2>&1) || fail "a dry run succeeds" "$dry_run"
[[ ! -e $calls && ! -e $toggles ]] || fail "a dry run changes nothing" "$dry_run"
pass "a dry run changes nothing"

applied=$(settings apply 2>&1) || fail "apply writes every setting" "$applied"
[[ -f $toggles/screensaver-off && -f $toggles/bar-off ]] || fail "apply turns the screensaver and the bar off" "$applied"
for flag in corners-rounded window-opaque no-animations window-no-gaps; do
  [[ -f $toggles/hypr/$flag.lua ]] || fail "apply sets the $flag Hyprland toggle" "$applied"
done
grep -qF 'default = "scrolling"' "$test_tmp/home/.local/state/omarchy/workspace-layouts/default.lua" ||
  fail "apply saves the default workspace layout" "$applied"
[[ $(<"$calls") == $'theme-set tokyo-night\nfont-set CaskaydiaMono Nerd Font' ]] ||
  fail "apply sets the theme and the font once each" "$(<"$calls")"
settings status --missing >/dev/null 2>&1 || fail "nothing differs after apply" "$(settings status 2>&1)"
pass "apply writes every setting through its command"

# omarchy-theme-set records the theme under ~/.local/state wherever
# XDG_STATE_HOME points, so that is where the plugin reads it. The commands
# that follow XDG_STATE_HOME find nothing in the new place.
settings_env=(XDG_STATE_HOME="$test_tmp/elsewhere")
moved=$(settings status 2>&1)
settings_env=()
[[ $(grep -E '^omarchy +theme ' <<<"$moved") =~ \"tokyo-night\"\ +\"tokyo-night\"\ +set$ ]] ||
  fail "the theme is read from where Omarchy records it" "$moved"
pass "the theme is read from where Omarchy records it"

# Only the keys that differ are written, and the ones stored as an "off" flag
# come back on.
cat >"$project/mise.toml" <<'TOML'
[bootstrap.settings.omarchy]
theme = "tokyo-night"
font = "CaskaydiaMono Nerd Font"
screensaver = true

[bootstrap.settings.omarchy.appearance]
corners = "theme"
transparency = "glassy"
animations = true
gaps = true
bar = true
TOML
: >"$calls"
applied=$(settings apply 2>&1) || fail "apply writes the settings back" "$applied"
[[ ! -s $calls ]] || fail "an unchanged theme and font are not set again" "$(<"$calls")"
[[ $(find "$toggles" -type f -printf '%P\n') == "hypr/window-glassy.lua" ]] ||
  fail "apply turns the off flags back on" "$(find "$toggles" -type f)"
settings status --missing >/dev/null 2>&1 || fail "nothing differs after applying back" "$(settings status 2>&1)"
pass "apply writes only what differs"

# A value the plugin rejects stops the whole apply, so the accepted change
# beside it is not written either.
rejects() {
  local description="$1" message="$2" output
  cat >"$project/mise.toml"
  if output=$(settings apply 2>&1); then
    fail "$description" "$output"
  fi
  grep -qF -- "$message" <<<"$output" || fail "$description" "$output"
  [[ ! -e $toggles/screensaver-off ]] || fail "$description: nothing else is written" "$output"
  pass "$description"
}

rejects "an unknown setting is named with the ones that exist" "omarchy has no setting named blur; it has appearance.animations," <<'TOML'
[bootstrap.settings.omarchy]
screensaver = false
blur = true
TOML

rejects "a choice outside the list is refused" "appearance.corners must be one of theme, sharp, rounded, not round" <<'TOML'
[bootstrap.settings.omarchy]
screensaver = false
appearance.corners = "round"
TOML

rejects "a value of the wrong type is refused" "appearance.gaps must be a boolean, not string" <<'TOML'
[bootstrap.settings.omarchy]
screensaver = false
appearance.gaps = "yes"
TOML

rejects "a theme's display name is refused" "theme must be a theme's directory name, such as tokyo-night, not Tokyo Night" <<'TOML'
[bootstrap.settings.omarchy]
screensaver = false
theme = "Tokyo Night"
TOML

# The command's own explanation reaches the user.
cat >"$project/mise.toml" <<'TOML'
[bootstrap.settings.omarchy]
font = "Missing Font"
TOML
if output=$(settings apply 2>&1); then
  fail "a failing command fails the apply" "$output"
fi
grep -qF "Font 'Missing Font' not found." <<<"$output" || fail "a failing command's message is shown" "$output"
pass "a failing command's message is shown"

# Every program the hooks run is in requires, which is how mise tells the user
# what is missing instead of failing halfway through an apply.
required=$(sed -n 's/^  "\(omarchy-[a-z-]*\)",$/\1/p' "$ROOT/default/mise/plugins/omarchy/mise.plugin.toml" | sort)
used=$(grep -oE '"omarchy-[a-z-]+' "$ROOT/default/mise/plugins/omarchy/lib/settings.lua" | tr -d '"' | sort -u)
[[ $required == "$used" ]] || fail "requires lists the commands the plugin runs" "$(diff <(echo "$required") <(echo "$used"))"
while read -r program; do
  [[ -x $ROOT/bin/$program ]] || fail "requires names commands that exist" "$program"
done <<<"$required"
pass "requires lists the commands the plugin runs"
