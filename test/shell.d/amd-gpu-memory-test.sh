#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/pci" OMARCHY_MEMINFO="$tmp_dir/meminfo"
export OMARCHY_AMD_GPU_MEMORY_CONF="$tmp_dir/limine-entry-tool.d/amd-gpu-memory.conf"
page_kib=$(( $(getconf PAGESIZE) / 1024 ))

gpu() { mkdir -p "$OMARCHY_PCI_DEVICES_PATH/$1"; echo "$2" > "$OMARCHY_PCI_DEVICES_PATH/$1/vendor"; echo "$3" > "$OMARCHY_PCI_DEVICES_PATH/$1/class"; }
ram_gib() { echo "MemTotal:       $(( $1 * 1024 * 1024 )) kB" > "$OMARCHY_MEMINFO"; }
apply() { "$ROOT/bin/omarchy-apply-amd-gpu-memory" >/dev/null; }

ram_gib 64
gpu 0000:00:02.0 0x8086 0x030000
gpu 0000:c3:00.1 0x1002 0x040300
apply
[[ ! -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "a machine without an AMD GPU is left alone"
pass "a machine without an AMD GPU, even with AMD audio, is left alone"

gpu 0000:c3:00.0 0x1002 0x038000
ram_gib 16
apply
[[ ! -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "16 GB keeps the kernel's half, which is as high"
pass "16 GB keeps the kernel's half, which is as high"

ram_gib 64
apply
grep -Fxq "KERNEL_CMDLINE[default]+=\" ttm.pages_limit=$(( 56 * 1024 * 1024 / page_kib ))\"" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "a 64 GB AMD machine lets the GPU map 56 GiB" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "a 64 GB AMD machine lets the GPU map 56 GiB"

# A 64 GB APU whose firmware carves out 32 GB of VRAM boots with 32 GB.
uma="$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/uma"
mkdir -p "$uma"
printf '0: Minimum (512 MB)\n1:  (1 GB)\n5: Medium (16 GB)\n6: High (32 GB)\n' > "$uma/carveout_options"
echo 6 > "$uma/carveout"
echo $(( 32 * 1024 * 1024 * 1024 )) > "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_vram_total"
ram_gib 32
apply
[[ $(< "$uma/carveout") == "0" ]] || fail "a 32 GB carveout shrinks to the smallest option" "$(< "$uma/carveout")"
pass "a 32 GB carveout shrinks to the smallest option"
grep -Fxq "KERNEL_CMDLINE[default]+=\" ttm.pages_limit=$(( (63 * 1024 + 512) * 1024 / page_kib - 8 * 1024 * 1024 / page_kib ))\"" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "the cap is sized for the 63.5 GiB the next boot sees" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "the cap is sized for the 63.5 GiB the next boot sees"

# Run again before the reboot: the carveout reads back as the smallest, but
# this boot's VRAM still says 32 GB, so the cap stays the same.
apply
grep -Fxq "KERNEL_CMDLINE[default]+=\" ttm.pages_limit=$(( (63 * 1024 + 512) * 1024 / page_kib - 8 * 1024 * 1024 / page_kib ))\"" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "a second run before the reboot keeps the cap" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "a second run before the reboot keeps the cap"
