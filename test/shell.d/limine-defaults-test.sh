#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packaged_defaults="$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"

grep -Fq 'KERNEL_CMDLINE[default]+=" initramfs_async=0"' "$packaged_defaults" ||
  fail "the packaged Limine defaults still unpack the initramfs synchronously"
pass "packaged Limine defaults keep Plymouth alive at the LUKS prompt"

grep -Fxq 'BOOT_ORDER="linux-t2, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"' "$packaged_defaults" ||
  fail "packaged Limine defaults protect T2 Macs and prefer the exact Omarchy kernel elsewhere"
pass "packaged Limine defaults protect T2 Macs and prefer the exact Omarchy kernel elsewhere"

# usbcore is built into the kernel, so only the command line can turn off USB
# autosuspend (#906); a modprobe.d option never reaches it.
grep -Fq 'KERNEL_CMDLINE[default]+=" usbcore.autosuspend=-1"' "$packaged_defaults" ||
  fail "the packaged Limine defaults turn off USB autosuspend"
pass "packaged Limine defaults turn off USB autosuspend"
