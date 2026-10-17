#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The refresh upgrade that opens a channel switch runs with --noconfirm alone,
# which does not answer pacman's "Replace omarchy-dev with extra/omarchy?"
# prompt: --noconfirm only answers its own [Y/n] questions, and a replacement
# is one of the questions it leaves on screen. Under the updater's systemd-run
# scope there is no TTY to answer it, so the switch dies on its first
# transaction with "script interrupted by signal" and half-applied state. The
# later install step in omarchy-channel-set already passes --ask 4 for exactly
# that replacement; the refresh needs it too.

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman

refresh() {
  "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" "$1" >"$boundary_tmp/output" 2>&1
}

for channel in stable rc edge; do
  reset_boundary
  refresh "$channel" || fail "the $channel refresh ran" "$(cat "$boundary_tmp/output")"
  grep -Fqx 'step:pacman -Syyuu --noconfirm --ask 4' "$SUDO_TEST_LOG" ||
    fail "the $channel refresh upgrades without a replace prompt" "$(grep '^step:pacman' "$SUDO_TEST_LOG")"
done
pass "the channel refresh's upgrade answers package replacement prompts without a TTY (--ask 4)"
