#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls" OMARCHY_N1X_GPU_MEMORY_CONF="$tmp_dir/omarchy-n1x-gpu-memory.conf"
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat > "$tmp_dir/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo limine-mkinitcpio >> "$CALL_LOG"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1790984700.sh"
run() { : > "$CALL_LOG"; bash -euo pipefail "$migration" >/dev/null; }

# A ProArt P14 or XPS 16 drop-in from before the change, as both scripts wrote it.
cat > "$OMARCHY_N1X_GPU_MEMORY_CONF" <<'CONF'
# ASUS ProArt P14: use the idle part of the firmware's Windows GPU memory as RAM;
# see install/hardware/asus/fix-asus-proart-p14-gpu-memory.sh.
KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G,3968M@67712M"
CONF
run
grep -Fxq 'KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G"' "$OMARCHY_N1X_GPU_MEMORY_CONF" ||
  fail "the second range is dropped" "$(cat "$OMARCHY_N1X_GPU_MEMORY_CONF")"
grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "the boot entries are rebuilt"
pass "an install that reclaims both ranges keeps only the first"

run
[[ ! -s $CALL_LOG ]] || fail "the migration does nothing once narrowed"
pass "the migration is idempotent"

rm "$OMARCHY_N1X_GPU_MEMORY_CONF"
run
[[ ! -e $OMARCHY_N1X_GPU_MEMORY_CONF && ! -s $CALL_LOG ]] || fail "machines without the drop-in are left alone"
pass "machines without the drop-in are left alone"
