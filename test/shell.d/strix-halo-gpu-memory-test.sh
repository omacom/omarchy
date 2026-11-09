#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/limine-entry-tool.d"
export CALL_LOG="$tmp_dir/calls" STRIX_HALO="$tmp_dir/strix-halo"
export OMARCHY_STRIX_HALO_GPU_MEMORY_CONF="$tmp_dir/limine-entry-tool.d/omarchy-strix-halo-gpu-memory.conf"
export OMARCHY_LIMINE_DEFAULT="$tmp_dir/limine" OMARCHY_MEMINFO="$tmp_dir/meminfo"
export OMARCHY_STRIX_HALO_GPU_MEMORY_BUILT="$tmp_dir/built"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
dropin=$OMARCHY_STRIX_HALO_GPU_MEMORY_CONF

cat > "$tmp_dir/bin/omarchy-hw-amd-strix-halo" <<'SH'
#!/bin/bash
[[ -e $STRIX_HALO ]]
SH
cat > "$tmp_dir/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo limine-mkinitcpio >> "$CALL_LOG"
SH
chmod +x "$tmp_dir/bin/"*

apply() { : > "$CALL_LOG"; omarchy-apply-strix-halo-gpu-memory "$@" >/dev/null; }
ram_kib() { echo "MemTotal:       $1 kB" > "$OMARCHY_MEMINFO"; }
touch "$OMARCHY_LIMINE_DEFAULT"

# 188 GiB, as a 192 GB machine shows with a 512 MiB carve-out: 180 GiB in 4 KiB pages.
ram_kib 197132288
apply --rebuild
[[ ! -e $dropin && ! -s $CALL_LOG ]] || fail "other machines are left alone"
pass "other machines are left alone"

touch "$STRIX_HALO"
apply
grep -qx 'KERNEL_CMDLINE\[default\]+=" ttm.pages_limit=47185920"' "$dropin" || fail "the limit is all but 8 GiB of RAM" "$(<"$dropin")"
[[ ! -s $CALL_LOG ]] || fail "setup leaves the boot images to the installer"
pass "the GPU may borrow all but 8 GiB of RAM"

apply --rebuild
apply --rebuild
[[ ! -s $CALL_LOG ]] || fail "a built limit is not rebuilt again"
ram_kib 131072000
apply --rebuild
grep -q 'ttm.pages_limit=30670848"' "$dropin" && [[ $(<"$CALL_LOG") == "limine-mkinitcpio" ]] ||
  fail "a changed limit is rebuilt" "$(<"$dropin") / $(<"$CALL_LOG")"
pass "the boot images are rebuilt only when the limit changes"

rm "$dropin"
echo 'KERNEL_CMDLINE[default]+="quiet ttm.pages_limit=1000"' > "$OMARCHY_LIMINE_DEFAULT"
apply --rebuild
[[ ! -e $dropin && ! -s $CALL_LOG ]] || fail "a limit set by hand wins"
pass "a limit set by hand wins"
