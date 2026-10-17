#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
installed_dir="$test_tmp/installed"
install_log="$test_tmp/install-log"
terminal_log="$test_tmp/terminal-log"
notification_log="$test_tmp/notification-log"
mkdir -p "$mock_bin" "$test_home" "$installed_dir"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ -e $OMARCHY_TEST_INSTALLED_DIR/$1 ]]
SH

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ! -e $OMARCHY_TEST_INSTALLED_DIR/$1 ]]
SH

cat >"$mock_bin/omarchy-install-service-1password" <<'SH'
#!/bin/bash
printf 'install:1password\n' >>"$OMARCHY_TEST_INSTALL_LOG"
[[ ${OMARCHY_TEST_INSTALL_FAIL:-} != "1password" ]] || exit 1
touch "$OMARCHY_TEST_INSTALLED_DIR/1password"
SH

cat >"$mock_bin/omarchy-install-service-bitwarden" <<'SH'
#!/bin/bash
printf 'install:bitwarden\n' >>"$OMARCHY_TEST_INSTALL_LOG"
[[ ${OMARCHY_TEST_INSTALL_FAIL:-} != "bitwarden" ]] || exit 1
touch "$OMARCHY_TEST_INSTALLED_DIR/bitwarden-desktop"
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_TERMINAL_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFICATION_LOG"
SH

chmod +x "$mock_bin"/*

default_file="$test_home/.config/omarchy/defaults/password-manager"

export HOME="$test_home"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_INSTALLED_DIR="$installed_dir"
export OMARCHY_TEST_INSTALL_LOG="$install_log"
export OMARCHY_TEST_TERMINAL_LOG="$terminal_log"
export OMARCHY_TEST_NOTIFICATION_LOG="$notification_log"

query() {
  omarchy-default-password-manager
}

# Querying with nothing chosen answers the way the hotkey always has.
touch "$installed_dir/1password" "$installed_dir/bitwarden-desktop"
[[ $(query) == "1password" ]] ||
  fail "unset default prefers 1Password when both managers are installed"
rm -f "$installed_dir/1password"
[[ $(query) == "bitwarden" ]] ||
  fail "unset default is Bitwarden when it is the only manager installed"
rm -f "$installed_dir/bitwarden-desktop"
[[ $(query) == "1password" ]] ||
  fail "unset default is 1Password, whose launcher starts its installer, when neither is installed"
pass "querying a default that was never chosen follows the hotkey's order"

# A stale or foreign value in the defaults file is not a manager Omarchy knows.
mkdir -p "$(dirname "$default_file")"
printf 'keepassxc\n' >"$default_file"
touch "$installed_dir/bitwarden-desktop"
[[ $(query) == "bitwarden" ]] ||
  fail "unrecognized default falls back to the installed manager"
rm -f "$installed_dir/bitwarden-desktop"
printf '1password\n' >"$default_file"
[[ $(query) == "1password" ]] ||
  fail "recognized default is honored even when that manager is missing"
pass "querying honors a recognized default and falls back on an unrecognized one"

# Choosing a missing manager offers to install it in a visible terminal first.
rm -f "$default_file"
omarchy-default-password-manager bitwarden
mapfile -d '' -t terminal_args <"$terminal_log"
[[ ${terminal_args[*]} == "omarchy-default-password-manager --install bitwarden" ]] ||
  fail "missing manager opens its installer in a terminal"
[[ ! -e $default_file ]] ||
  fail "the terminal offer leaves the default untouched until installation"
pass "choosing a missing manager opens its installer in a terminal"

# The install path runs that manager's service installer, then selects it.
omarchy-default-password-manager --install bitwarden
[[ $(<"$install_log") == "install:bitwarden" ]] ||
  fail "installing Bitwarden runs its service installer"
[[ $(query) == "bitwarden" ]] ||
  fail "Bitwarden becomes the default after installation"
mapfile -d '' -t notification_args <"$notification_log"
[[ ${notification_args[*]} == "-g 󰟵 Bitwarden is now the default password manager" ]] ||
  fail "a notification announces the new default"
pass "installing a missing manager selects it as the default"

# A manager that is already installed is selected immediately.
touch "$installed_dir/1password"
: >"$install_log"
: >"$notification_log"
omarchy-default-password-manager 1password
[[ ! -s $install_log ]] ||
  fail "installed manager skips its installer"
[[ $(query) == "1password" ]] ||
  fail "installed manager becomes the default"
mapfile -d '' -t notification_args <"$notification_log"
[[ ${notification_args[*]} == "-g 󰢁 1Password is now the default password manager" ]] ||
  fail "a notification announces the new default"
pass "choosing an installed manager selects it immediately"

# A failed installation leaves the previous default in place.
rm -f "$installed_dir/bitwarden-desktop"
if OMARCHY_TEST_INSTALL_FAIL=bitwarden omarchy-default-password-manager --install bitwarden 2>/dev/null; then
  fail "failed installation returns an error"
fi
[[ $(query) == "1password" ]] ||
  fail "failed installation preserves the current default"
pass "failed installation preserves the current default"

# When the choice cannot be saved, nothing claims otherwise: the command
# fails before a notification goes out.
readonly_home="$test_tmp/readonly-home"
mkdir -p "$readonly_home"
touch "$readonly_home/.config"
: >"$notification_log"
if HOME="$readonly_home" omarchy-default-password-manager 1password 2>/dev/null; then
  fail "an unsavable default returns an error"
fi
[[ ! -s $notification_log ]] ||
  fail "an unsavable default sends no success notification"
pass "an unsavable default fails instead of reporting success"

# Anything that is not a known manager is a usage error.
if omarchy-default-password-manager keepassxc >"$test_tmp/usage-error" 2>&1; then
  fail "unknown manager is a usage error"
fi
grep -Fq "Usage: omarchy-default-password-manager <1password|bitwarden>" "$test_tmp/usage-error" ||
  fail "usage error names the managers that can be chosen"
pass "unknown manager is a usage error"
