#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"

for command in xdg-user-dirs-update xdg-settings xdg-mime; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "${0##*/}" "$*" >>"$TEST_COMMAND_LOG"\n' >"$mock_bin/$command"
done
export TEST_COMMAND_LOG=$test_tmp/commands.log
chmod +x "$mock_bin"/*

# Provisioning prepends $OMARCHY_PATH/bin, which shadows a mock for anything
# Omarchy ships, so the install suite is stubbed out at its path instead. The
# real one rethemes the session it runs in: hyprctl reload against the live
# compositor, gsettings against the live desktop, and a global Node install.
mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes"

for skill in omarchy omarchy-diagnose-crash; do
  link="$test_tmp/home/.gemini/config/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Antigravity"

  link="$test_tmp/home/.hermes/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Hermes"

  link="$test_tmp/home/.hermes/profiles/james/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for a Hermes profile"
done

pass "omarchy-provision-user provisions Antigravity and Hermes skills"

# Linking a checkout (omarchy dev link) moves the links out of the package,
# drops one to a skill the checkout doesn't have, and keeps the user's own.
mkdir -p "$test_tmp/relink/.claude/skills" "$test_tmp/package/default/agents/skills/omarchy" "$test_tmp/package/default/agents/skills/retired"
ln -s "$test_tmp/package/default/agents/skills/omarchy" "$test_tmp/relink/.claude/skills/omarchy"
ln -s "$test_tmp/package/default/agents/skills/retired" "$test_tmp/relink/.claude/skills/retired"
ln -s /opt/elsewhere/skill "$test_tmp/relink/.claude/skills/theirs"
ln -s /opt/elsewhere/game "$test_tmp/relink/.claude/skills/omarchy-make-game"
mkdir -p "$test_tmp/relink/.claude/skills/omarchy-make-app"
HOME="$test_tmp/relink" "$ROOT/bin/omarchy-agent-skills-link" "$ROOT" || fail "omarchy-agent-skills-link links a checkout"
[[ $(readlink "$test_tmp/relink/.claude/skills/omarchy") == "$ROOT/default/agents/skills/omarchy" ]] ||
  fail "a skill linked from the package now links to the checkout" "$(readlink "$test_tmp/relink/.claude/skills/omarchy")"
[[ ! -L $test_tmp/relink/.claude/skills/retired ]] || fail "a link to a skill the checkout doesn't have is removed"
[[ $(readlink "$test_tmp/relink/.claude/skills/theirs") == "/opt/elsewhere/skill" ]] || fail "a link to the user's own skill stays"
[[ $(readlink "$test_tmp/relink/.claude/skills/omarchy-make-game") == "/opt/elsewhere/game" ]] ||
  fail "a link of the user's own named like an Omarchy skill stays" "$(readlink "$test_tmp/relink/.claude/skills/omarchy-make-game")"
[[ -d $test_tmp/relink/.claude/skills/omarchy-make-app && ! -L $test_tmp/relink/.claude/skills/omarchy-make-app && ! -e $test_tmp/relink/.claude/skills/omarchy-make-app/omarchy-make-app ]] ||
  fail "a folder of the user's own named like an Omarchy skill stays, with no link put inside it"
[[ $(readlink "$test_tmp/relink/.agents/skills/omarchy-make-game") == "$ROOT/default/agents/skills/omarchy-make-game" ]] ||
  fail "every skill in the checkout is linked, including ones the package lacks"
pass "omarchy-agent-skills-link moves Omarchy's skill links to the tree in use and keeps the user's"

# Pi's extension package follows the same rules as the skills.
[[ $(readlink "$test_tmp/home/.pi/agent/extensions/omarchy") == "$ROOT/default/agents/pi" ]] ||
  fail "omarchy-provision-user links Omarchy's Pi package"
mkdir -p "$test_tmp/pi-moved/.pi/agent/extensions" "$test_tmp/pi-theirs/.pi/agent/extensions"
ln -s "$test_tmp/package/default/agents/pi" "$test_tmp/pi-moved/.pi/agent/extensions/omarchy"
ln -s /opt/elsewhere/pi-package "$test_tmp/pi-theirs/.pi/agent/extensions/omarchy"
printf '{"theme": "dark", "collapseChangelog": false}\n' >"$test_tmp/pi-theirs/.pi/agent/settings.json"
mkdir -p "$test_tmp/pi-moved/dotfiles"
printf '{"theme": "light"}\n' >"$test_tmp/pi-moved/dotfiles/pi-settings.json"
ln -s "$test_tmp/pi-moved/dotfiles/pi-settings.json" "$test_tmp/pi-moved/.pi/agent/settings.json"
for home in pi-moved pi-theirs; do
  HOME="$test_tmp/$home" "$ROOT/bin/omarchy-agent-pi-defaults" "$ROOT" || fail "omarchy-agent-pi-defaults sets up Pi in $home"
done
[[ $(readlink "$test_tmp/pi-moved/.pi/agent/extensions/omarchy") == "$ROOT/default/agents/pi" ]] ||
  fail "Pi's package linked from the package now links to the checkout" "$(readlink "$test_tmp/pi-moved/.pi/agent/extensions/omarchy")"
[[ $(readlink "$test_tmp/pi-theirs/.pi/agent/extensions/omarchy") == "/opt/elsewhere/pi-package" ]] ||
  fail "a Pi extension of the user's own named omarchy stays"
pass "omarchy-agent-pi-defaults links Omarchy's Pi package to the tree in use and keeps the user's"

[[ -L $test_tmp/pi-moved/.pi/agent/settings.json && $(jq -c '[.theme, .collapseChangelog]' "$test_tmp/pi-moved/dotfiles/pi-settings.json") == '["light",true]' ]] ||
  fail "Pi's changelog is condensed by default, through a settings file linked from dotfiles"
[[ $(jq -c '[.theme, .collapseChangelog]' "$test_tmp/pi-theirs/.pi/agent/settings.json") == '["dark",false]' ]] ||
  fail "a user's own changelog choice and other Pi settings stay" "$(cat "$test_tmp/pi-theirs/.pi/agent/settings.json")"
pass "omarchy-agent-pi-defaults condenses Pi's changelog unless the user chose otherwise"

# The Agent Skills spec caps a description at 1024 characters, and harnesses
# such as pi flag a longer one. Descriptions are folded YAML, so the lines
# join with single spaces.
for skill in "$ROOT"/default/agents/skills/*/SKILL.md; do
  description=$(awk '/^description:/ { f = 1; next } /^---/ { if (f) exit } f' "$skill" | sed 's/^ *//' | paste -sd ' ')
  (( ${#description} > 0 && ${#description} <= 1024 )) ||
    fail "${skill#"$ROOT"/} has a description of 1-1024 characters" "${#description} characters"
done
pass "every Omarchy skill's description fits the Agent Skills limit"

for dir in DOWNLOAD:Downloads PICTURES:Pictures VIDEOS:Videos DOCUMENTS:Documents MUSIC:Music; do
  grep -qxF "xdg-user-dirs-update --set ${dir%%:*} $test_tmp/home/${dir#*:}" "$TEST_COMMAND_LOG" ||
    fail "provisioning names the ${dir%%:*} folder in English" "$(cat "$TEST_COMMAND_LOG")"
done
for dir in Downloads Pictures Videos Documents Music; do
  [[ -d $test_tmp/home/$dir ]] || fail "provisioning creates the $dir folder it names"
done
pass "provisioning names the user folders in English before a first login in another language"

: >"$TEST_COMMAND_LOG"
mkdir -p "$test_tmp/home/.config"
printf 'XDG_DOWNLOAD_DIR="$HOME/下载"\n' >"$test_tmp/home/.config/user-dirs.dirs"
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" --force >/dev/null ||
  fail "omarchy-provision-user finishes again"
! grep -q -- '--set DOWNLOAD ' "$TEST_COMMAND_LOG" || fail "provisioning keeps a folder the user already named"
grep -q -- '--set PICTURES ' "$TEST_COMMAND_LOG" || fail "provisioning still names the folders the user has not"
pass "provisioning keeps a folder the user already named, in any language"
