#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
package_root="$SUDO_TEST_ROOT"
copy_boundary_file bin/omarchy-channel-set
python3 - "$SUDO_TEST_ROOT/bin/omarchy-channel-set" "$package_root" <<'PYTHON'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace("/usr/share/omarchy", sys.argv[2]))
PYTHON

stub_bin="$SUDO_TEST_ROOT/bin"
log_file="$test_tmp/channel.log"
mkdir -p "$stub_bin" "$test_tmp/home"

write_stub() {
  local name="$1"
  local body="$2"

  rm -f "$stub_bin/$name"
  cat >"$stub_bin/$name" <<<"$body"
  chmod +x "$stub_bin/$name"
}

write_stub omarchy-refresh-pacman '#!/bin/bash
printf "refresh" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub sudo '#!/bin/bash
case "${1:-}" in
  -h) echo "usage: sudo [-ABbEHkNnPS] command"; exit 0 ;;
  -k|-K) exit 0 ;;
esac
printf "sudo" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

cp "$stub_bin/sudo" "$SUDO_TEST_ROOT/mock/sudo"

write_stub omarchy-update-pacman '#!/bin/bash
printf "update-pacman" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub omarchy-dev-unlink '#!/bin/bash
printf "unlink" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub omarchy-state '#!/bin/bash
printf "state" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub omarchy-update '#!/bin/bash
printf "update" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\tOMARCHY_PATH=%s" "$OMARCHY_PATH" >>"$OMARCHY_CHANNEL_TEST_LOG"
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub gum '#!/bin/bash
printf "gum" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
exit "${OMARCHY_TEST_GUM_STATUS:-0}"
'

write_stub omarchy-pkg-drop '#!/bin/bash
printf "drop" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
exit "${OMARCHY_TEST_DROP_STATUS:-0}"
'

write_stub git '#!/bin/bash
printf "git" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
if [[ $1 == "clone" ]]; then
  dest="${@: -1}"
  /usr/bin/cp -a "$SUDO_TEST_ROOT" "$dest"
  mkdir -p "$dest/.git" "$dest/shell"
fi
'

write_stub omarchy-dev-link '#!/bin/bash
printf "link" >>"$OMARCHY_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$OMARCHY_CHANNEL_TEST_LOG"; done
printf "\n" >>"$OMARCHY_CHANNEL_TEST_LOG"
'

write_stub omarchy-version-channel '#!/bin/bash
printf "%s\n" "${OMARCHY_TEST_VERSION_CHANNEL:-unknown}"
'

# The previous channel's Omarchy repository, and what is foreign after the switch.
write_stub pacman '#!/bin/bash
case "$1" in
  -Slq) [[ -z ${OMARCHY_TEST_PREVIOUS_REPO:-} ]] || printf "%s\n" $OMARCHY_TEST_PREVIOUS_REPO; exit "${OMARCHY_TEST_PREVIOUS_REPO_STATUS:-0}" ;;
  -Qmq) [[ -z ${OMARCHY_TEST_FOREIGN:-} ]] || printf "%s\n" $OMARCHY_TEST_FOREIGN; exit 0 ;;
  -Q) shift ;;
  *) exit 1 ;;
esac
case "${OMARCHY_TEST_PACKAGES:-}" in
  stable) [[ $* == "omarchy omarchy-settings" ]] ;;
  dev) [[ $* == "omarchy-dev omarchy-settings-dev" ]] ;;
  *) exit 1 ;;
esac
'

run_channel() {
  : >"$log_file"
  OMARCHY_CHANNEL_TEST_LOG="$log_file" \
    OMARCHY_PATH="${OMARCHY_TEST_PATH:-$package_root}" \
    HOME="$test_tmp/home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "${OMARCHY_TEST_PATH:-$package_root}/bin/omarchy-channel-set" "$@"
}

assert_log_line() {
  local expected="$1"
  local description="$2"

  grep -Fx -- "$expected" "$log_file" >/dev/null || fail "$description" "$(cat "$log_file")"
  pass "$description"
}

run_channel stable
assert_log_line $'refresh\tstable' "stable refreshes the stable pacman channel"
assert_log_line $'update-pacman\t-S\t--needed\t--noconfirm\t--ask\t4\tomarchy\tomarchy-settings' "stable installs stable Omarchy packages"
assert_log_line $'unlink\t--no-reboot' "stable restores the package-backed Omarchy path without an early reboot prompt"
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "stable runs the normal update pipeline from the package-backed path"
if grep -q $'^state\tset\treboot-required$' "$log_file"; then
  fail "stable does not require reboot when already package-backed" "$(cat "$log_file")"
fi
pass "stable does not require reboot when already package-backed"

run_channel rc
assert_log_line $'refresh\trc' "rc refreshes the rc pacman channel"
assert_log_line $'update-pacman\t-S\t--needed\t--noconfirm\t--ask\t4\tomarchy\tomarchy-settings' "rc installs rc Omarchy packages"
assert_log_line $'unlink\t--no-reboot' "rc restores the package-backed Omarchy path without an early reboot prompt"
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "rc runs the normal update pipeline from the package-backed path"

active_checkout="$test_tmp/active-checkout"
cp -a "$package_root" "$active_checkout"
OMARCHY_TEST_PATH="$active_checkout" run_channel edge
assert_log_line $'refresh\tedge' "edge refreshes the edge pacman channel"
assert_log_line $'update-pacman\t-S\t--needed\t--noconfirm\t--ask\t4\tomarchy-dev\tomarchy-settings-dev' "edge installs development Omarchy packages"
assert_log_line $'unlink\t--no-reboot' "edge unlinks dev without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "edge marks reboot required when leaving dev"
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "edge runs the normal update pipeline from the package-backed path"
[[ $(grep -E $'^(unlink|state|update)\t' "$log_file") == $'unlink\t--no-reboot\nstate\tset\treboot-required\nupdate\t-y\tOMARCHY_PATH='"$package_root" ]] ||
  fail "edge defers the reboot prompt until the update restart stage" "$(cat "$log_file")"
pass "edge defers the reboot prompt until the update restart stage"

OMARCHY_TEST_PREVIOUS_REPO="omarchy-dev omarchy-settings-dev edge-app edge-lib" \
  OMARCHY_TEST_FOREIGN="edge-app edge-lib my-aur-app" run_channel stable >"$test_tmp/left-behind.out"
assert_log_line $'gum\tconfirm\t--default=false\tRemove 2 left-behind package(s)?' "leaving edge offers to remove what only edge published"
assert_log_line $'drop\tedge-app\tedge-lib' "leaving edge removes only the packages edge left behind"
if grep -q 'my-aur-app' "$log_file" "$test_tmp/left-behind.out"; then
  fail "leaving edge leaves the user's own foreign packages alone" "$(cat "$log_file" "$test_tmp/left-behind.out")"
fi
pass "leaving edge leaves the user's own foreign packages alone"
[[ $(grep -E $'^(drop|update)\t' "$log_file") == $'drop\tedge-app\tedge-lib\nupdate\t-y\tOMARCHY_PATH='"$package_root" ]] ||
  fail "left-behind packages are removed before the update reaches the AUR" "$(cat "$log_file")"
pass "left-behind packages are removed before the update reaches the AUR"

OMARCHY_TEST_GUM_STATUS=1 OMARCHY_TEST_PREVIOUS_REPO="edge-app" OMARCHY_TEST_FOREIGN="edge-app" run_channel stable >/dev/null
if grep -q $'^drop\t' "$log_file"; then fail "declining keeps the left-behind packages" "$(cat "$log_file")"; fi
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "declining the removal still finishes the switch"

OMARCHY_TEST_DROP_STATUS=1 OMARCHY_TEST_PREVIOUS_REPO="edge-app" OMARCHY_TEST_FOREIGN="edge-app" run_channel stable >/dev/null 2>&1 ||
  fail "a failed removal does not abort the switch" "$(cat "$log_file")"
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "a failed removal still finishes the switch"

OMARCHY_TEST_PREVIOUS_REPO="omarchy omarchy-settings" OMARCHY_TEST_FOREIGN="my-aur-app" run_channel stable
if grep -qE $'^(gum|drop)\t' "$log_file"; then fail "staying on stable offers nothing to remove" "$(cat "$log_file")"; fi
pass "staying on stable offers nothing to remove"

# An unreadable previous repository is an empty list, never a match-all.
OMARCHY_TEST_PREVIOUS_REPO_STATUS=1 OMARCHY_TEST_FOREIGN="edge-app my-aur-app" run_channel stable
if grep -qE $'^(gum|drop)\t' "$log_file"; then fail "an unreadable previous repository offers nothing to remove" "$(cat "$log_file")"; fi
assert_log_line $'update\t-y\tOMARCHY_PATH='"$package_root" "an unreadable previous repository still finishes the switch"

checkout="$test_tmp/home/omarchy"
mkdir -p "$checkout"
if run_channel dev >"$test_tmp/occupied.out" 2>"$test_tmp/occupied.err"; then
  fail "dev refuses to use an occupied non-checkout path"
fi

grep -q "already exists and is not a git checkout" "$test_tmp/occupied.err" || fail "dev explains occupied checkout paths" "$(cat "$test_tmp/occupied.err")"
if grep -Fx $'refresh\tedge' "$log_file" >/dev/null; then
  fail "dev validates checkout path before changing packages" "$(cat "$log_file")"
fi
pass "dev refuses occupied non-checkout paths before package changes"

rmdir "$checkout"
run_channel dev
assert_log_line $'gum\tconfirm\t--default=false\tSwitch to dev channel?' "dev asks for confirmation"
assert_log_line $'refresh\tedge' "dev refreshes the edge pacman channel"
assert_log_line $'update-pacman\t-S\t--needed\t--noconfirm\t--ask\t4\tomarchy-dev\tomarchy-settings-dev' "dev installs development Omarchy packages"
assert_log_line $'git\tclone\t--filter=blob:none\thttps://github.com/omacom/omarchy.git\t'"$checkout" "dev clones the source checkout to ~/omarchy"
assert_log_line $'link\t'"$checkout"$'\t--no-reboot' "dev links ~/omarchy without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "dev defers the reboot prompt to the update pipeline"
assert_log_line $'update\t-y\tOMARCHY_PATH='"$checkout" "dev runs the normal update pipeline from the source checkout"
[[ $(grep -E '^(git|link|state|refresh|sudo|update)' "$log_file") == $'git\tclone\t--filter=blob:none\thttps://github.com/omacom/omarchy.git\t'"$checkout"$'\nlink\t'"$checkout"$'\t--no-reboot\nstate\tset\treboot-required\nrefresh\tedge\nupdate-pacman\t-S\t--needed\t--noconfirm\t--ask\t4\tomarchy-dev\tomarchy-settings-dev\nupdate\t-y\tOMARCHY_PATH='"$checkout" ]] ||
  fail "dev activates the checkout before changing or updating packages" "$(cat "$log_file")"
pass "dev activates the checkout before changing or updating packages"

OMARCHY_TEST_PATH="$checkout" run_channel stable
assert_log_line $'unlink\t--no-reboot' "switching from dev to stable unlinks without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "switching from dev to stable marks reboot required"

run_channel dev
if grep -q $'^git\tclone\t' "$log_file"; then
  fail "dev reuses an existing checkout" "$(cat "$log_file")"
fi
assert_log_line $'link\t'"$checkout"$'\t--no-reboot' "switching back to dev links ~/omarchy"
pass "switching back to dev reuses the existing ~/omarchy checkout"

current_channel() {
  OMARCHY_TEST_VERSION_CHANNEL="$1" \
    OMARCHY_TEST_PACKAGES="$2" \
    OMARCHY_PATH="$3" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-channel-current"
}

[[ $(current_channel stable stable /usr/share/omarchy) == "stable" ]] || fail "current channel detects stable"
pass "current channel detects stable"

[[ $(current_channel rc stable /usr/share/omarchy) == "rc" ]] || fail "current channel detects rc"
pass "current channel detects rc"

[[ $(current_channel edge dev /usr/share/omarchy) == "edge" ]] || fail "current channel detects package-backed edge"
pass "current channel detects package-backed edge"

[[ $(current_channel edge dev "$test_tmp/dev-checkout") == "dev" ]] || fail "current channel detects dev from OMARCHY_PATH"
pass "current channel honors a dev link outside ~/omarchy"
