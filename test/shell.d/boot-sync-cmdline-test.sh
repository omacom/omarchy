#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-boot-sync's boot images take /etc/kernel/cmdline, Omarchy's defaults
# and every /etc/cmdline.d drop-in. A machine with no drop-ins (no
# hibernation, no hardware quirks) still gets its command line.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

assemble() {
  bash -c '
    set -euo pipefail
    source <(sed -n "/^assemble_cmdline() {/,/^}/p" "$1")
    assemble_cmdline "$2"
  ' _ "$ROOT/bin/omarchy-boot-sync" "$tmp/root"
}

mkdir -p "$tmp/root/etc/kernel"
echo "root=/dev/mapper/root rw" >"$tmp/root/etc/kernel/cmdline"
export OMARCHY_BOOT_CMDLINE_DEFAULTS=$tmp/defaults
echo "quiet splash" >"$OMARCHY_BOOT_CMDLINE_DEFAULTS"

# The exit status counts: the image build stops on a failed assembly.
out=$(assemble) && [[ $out == "root=/dev/mapper/root rw quiet splash" ]] ||
  fail "a machine without drop-ins gets its command line" "$(assemble 2>&1; echo "exit $?")"
pass "a machine without drop-ins gets its command line"

mkdir -p "$tmp/root/etc/cmdline.d"
printf '# only a comment\n' >"$tmp/root/etc/cmdline.d/zz-empty.conf"
printf 'resume=/dev/mapper/root\n' >"$tmp/root/etc/cmdline.d/resume.conf"
out=$(assemble) && [[ $out == "root=/dev/mapper/root rw quiet splash resume=/dev/mapper/root" ]] ||
  fail "drop-ins follow in name order, comments dropped" "$(assemble 2>&1; echo "exit $?")"
pass "drop-ins follow in name order, and one of only comments is no failure"
