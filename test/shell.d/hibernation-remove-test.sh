#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The real command, with its system paths moved into a scratch directory.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fake=$tmp/root
mkdir -p "$tmp/bin"
sed -e "s#/etc/#$fake/etc/#g" -e "s#SWAP_SUBVOLUME=\"/swap\"#SWAP_SUBVOLUME=\"$fake/swap\"#" \
  "$ROOT/bin/omarchy-hibernation-remove" >"$tmp/remove"

printf '#!/bin/bash\nexec "$@"\n' >"$tmp/bin/sudo"
for command in gum swapon; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$tmp/bin/btrfs"
# Records whether the drop-in was still there for the boot image to read.
printf '#!/bin/bash\n[[ -f %q ]] && echo stale >>%q\necho built >>%q\n' \
  "$fake/etc/limine-entry-tool.d/resume.conf" "$tmp/rebuilds" "$tmp/rebuilds" >"$tmp/bin/limine-mkinitcpio"
chmod +x "$tmp/bin/"*

# A machine with the resume drop-in, and the mkinitcpio hook when asked for.
machine() {
  rm -rf "$fake" "$tmp/rebuilds"
  mkdir -p "$fake/etc/mkinitcpio.conf.d" "$fake/etc/limine-entry-tool.d" "$fake/swap"
  : >"$fake/etc/fstab"
  : >"$fake/swap/swapfile"
  printf '%s\n' 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=123"' \
    >"$fake/etc/limine-entry-tool.d/resume.conf"
  [[ $1 == "hook" ]] && printf 'HOOKS+=(resume)\n' >"$fake/etc/mkinitcpio.conf.d/omarchy_resume.conf"
  return 0
}

# A full remove, and a machine an older remove left with only the drop-in.
for state in hook no-hook; do
  machine "$state"
  PATH="$tmp/bin:$PATH" bash "$tmp/remove" >/dev/null || fail "remove succeeds ($state)"
  [[ $(<"$tmp/rebuilds") == "built" ]] ||
    fail "remove deletes resume.conf before rebuilding the boot image ($state)" "$(cat "$tmp/rebuilds" 2>/dev/null)"
done
pass "remove deletes resume.conf before rebuilding the boot image"
