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

for skill in omarchy diagnose-crash; do
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

# A home adopted from another drive keeps what its owner set up: provisioning
# adds what is missing and replaces nothing. The installer marks it with
# OMARCHY_ADOPTED_HOME=1.
adopted=$test_tmp/adopted
mkdir -p "$adopted/.claude/skills" "$adopted/.config" "$adopted/.local/state/omarchy" "$test_tmp/adopted-bin"
ln -s /somewhere/else "$adopted/.claude/skills/omarchy"
printf 'XDG_DESKTOP_DIR="$HOME/Skrivbord"\n' >"$adopted/.config/user-dirs.dirs"
printf 'markers kept\n' >"$adopted/.local/state/omarchy/adopted-home"
cat >"$test_tmp/adopted-bin/xdg-settings" <<'SH'
#!/bin/bash
printf 'xdg-settings %s\n' "$*" >>"$TEST_COMMAND_LOG"
[[ $1 == get ]] && echo firefox.desktop
exit 0
SH
cat >"$test_tmp/adopted-bin/xdg-mime" <<'SH'
#!/bin/bash
printf 'xdg-mime %s\n' "$*" >>"$TEST_COMMAND_LOG"
[[ $1 == query ]] && echo thunderbird.desktop
exit 0
SH
chmod +x "$test_tmp/adopted-bin"/*
: >"$TEST_COMMAND_LOG"
HOME="$adopted" PATH="$test_tmp/adopted-bin:$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_ADOPTED_HOME=1 \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" --force --first-install >/dev/null ||
  fail "omarchy-provision-user finishes on an adopted home"
[[ $(readlink "$adopted/.claude/skills/omarchy") == /somewhere/else ]] || fail "an adopted home keeps its own skill link"
[[ -L $adopted/.claude/skills/diagnose-crash ]] || fail "an adopted home still gets the skills it lacks"
! grep -q -- '--set DESKTOP ' "$TEST_COMMAND_LOG" || fail "an adopted home keeps its own Desktop folder"
! grep -q '^xdg-settings set' "$TEST_COMMAND_LOG" || fail "an adopted home keeps its default browser" "$(cat "$TEST_COMMAND_LOG")"
! grep -q '^xdg-mime default' "$TEST_COMMAND_LOG" || fail "an adopted home keeps its mail handler"
[[ ! -d $adopted/.local/state/omarchy/migrations ]] || fail "a previous Omarchy home keeps its own migration history"
pass "provisioning an adopted home adds what is missing and replaces nothing"

printf 'my compose\n' >"$adopted/.XCompose"
HOME="$adopted" OMARCHY_ADOPTED_HOME=1 bash -c 'source "$1"' bash "$ROOT/install/user/xcompose.sh"
[[ $(cat "$adopted/.XCompose") == "my compose" ]] || fail "an adopted home keeps its .XCompose"
HOME="$test_tmp/home" bash -c 'source "$1"' bash "$ROOT/install/user/xcompose.sh"
grep -q 'default/xcompose' "$test_tmp/home/.XCompose" || fail "a new home gets Omarchy's .XCompose"
pass "an adopted home keeps its .XCompose"

# An adopted home's own Pi and Qt theme settings: theme setup does not touch
# them. A home without them gets Omarchy's.
theme_log=$test_tmp/theme.log
mkdir -p "$test_tmp/theme-bin" "$adopted/.local/state/omarchy/current" "$adopted/.pi/agent"
printf 'Tokyo Night\n' >"$adopted/.local/state/omarchy/current/theme.name"
printf '{"theme":"mine"}\n' >"$adopted/.pi/agent/settings.json"
printf 'kept .config/qtengine/config.json\nmarkers kept\n' >"$adopted/.local/state/omarchy/adopted-home"
for command in omarchy-theme-set omarchy-theme-set-pi omarchy-theme-set-fcitx5 omarchy-theme-set-qt; do
  printf '#!/bin/bash\necho "%s $*" >>"%s"\n' "$command" "$theme_log" >"$test_tmp/theme-bin/$command"
done
chmod +x "$test_tmp/theme-bin"/*
: >"$theme_log"
HOME="$adopted" PATH="$test_tmp/theme-bin:$PATH" OMARCHY_ADOPTED_HOME=1 bash -c 'source "$1"' bash "$ROOT/install/user/theme.sh"
! grep -q '^omarchy-theme-set-pi' "$theme_log" || fail "an adopted home keeps its own Pi theme" "$(cat "$theme_log")"
! grep -q '^omarchy-theme-set-qt' "$theme_log" || fail "an adopted home keeps its own Qt settings" "$(cat "$theme_log")"
rm -rf "$adopted/.pi"
printf 'markers kept\n' >"$adopted/.local/state/omarchy/adopted-home"
: >"$theme_log"
HOME="$adopted" PATH="$test_tmp/theme-bin:$PATH" OMARCHY_ADOPTED_HOME=1 bash -c 'source "$1"' bash "$ROOT/install/user/theme.sh"
grep -q '^omarchy-theme-set-pi' "$theme_log" && grep -q '^omarchy-theme-set-qt' "$theme_log" ||
  fail "an adopted home without its own settings gets Omarchy's" "$(cat "$theme_log")"
pass "an adopted home keeps its own Pi and Qt theme settings"

# An adopted home that already has keyrings keeps them as its default: an
# unencrypted Omarchy keyring made the default would take new secrets out of
# the user's password-protected one.
mkdir -p "$adopted/.local/share/keyrings"
: >"$adopted/.local/share/keyrings/login.keyring"
HOME="$adopted" OMARCHY_ADOPTED_HOME=1 bash -c 'source "$1"' bash "$ROOT/install/user/default-keyring.sh"
[[ ! -e $adopted/.local/share/keyrings/Default_keyring.keyring && ! -e $adopted/.local/share/keyrings/default ]] ||
  fail "an adopted home with keyrings gets no Omarchy keyring" "$(ls -A "$adopted/.local/share/keyrings")"
fresh=$test_tmp/fresh-keyring
mkdir -p "$fresh"
HOME="$fresh" bash -c 'source "$1"' bash "$ROOT/install/user/default-keyring.sh"
[[ -f $fresh/.local/share/keyrings/Default_keyring.keyring && $(cat "$fresh/.local/share/keyrings/default") == Default_keyring ]] ||
  fail "a new home gets Omarchy's default keyring"
pass "an adopted home keeps its own keyrings"
