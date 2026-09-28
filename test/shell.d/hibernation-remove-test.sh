#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/etc/mkinitcpio.conf.d" "$tmp/etc/limine-entry-tool.d" "$tmp/swap"

# Run the real script against a sandboxed /etc and /swap, with the privileged
# and interactive tools stubbed out.
sed -e "s|/etc/|$tmp/etc/|g" -e "s|\"/swap\"|\"$tmp/swap\"|" "$ROOT/bin/omarchy-hibernation-remove" >"$tmp/remove"
printf '#!/bin/bash\n"$@"\n' >"$tmp/bin/sudo"
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/gum"
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/swapon"
printf '#!/bin/bash\nexit 1\n' >"$tmp/bin/btrfs"
printf '#!/bin/bash\ntouch "%s/regenerated"\n' "$tmp" >"$tmp/bin/limine-mkinitcpio"
chmod +x "$tmp/bin/"*

echo 'HOOKS+=(resume)' >"$tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf"
echo 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=1929151"' >"$tmp/etc/limine-entry-tool.d/resume.conf"
touch "$tmp/swap/swapfile" "$tmp/etc/fstab"

PATH="$tmp/bin:$PATH" bash "$tmp/remove" >/dev/null

[[ ! -e $tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf ]] || fail "hibernation remove drops the resume hook"
# Setup only writes resume.conf when it is missing, so a leftover would pin a
# later setup to the deleted swapfile's offset.
[[ ! -e $tmp/etc/limine-entry-tool.d/resume.conf ]] || fail "hibernation remove drops the resume kernel parameters"
[[ -e $tmp/regenerated ]] || fail "hibernation remove regenerates the boot image after dropping them"
pass "hibernation remove drops the resume hook and kernel parameters"
