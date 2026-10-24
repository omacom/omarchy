#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls" OMARCHY_N1X_GPU_MEMORY_CONF="$tmp_dir/omarchy-n1x-gpu-memory.conf"
export OMARCHY_N1X_PROC_CMDLINE="$tmp_dir/cmdline" REBUILD_STATUS=0 N1X_STATUS=0
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat > "$tmp_dir/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
exit "$N1X_STATUS"
SH
cat > "$tmp_dir/bin/omarchy-apply-n1x-gpu-memory" <<'SH'
#!/bin/bash
echo omarchy-apply-n1x-gpu-memory >> "$CALL_LOG"
SH
cat > "$tmp_dir/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo limine-mkinitcpio >> "$CALL_LOG"
exit "$REBUILD_STATUS"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1791784278.sh"
run() { : > "$CALL_LOG"; bash -euo pipefail "$migration" >/dev/null; }

reclaiming_cmdline='root=UUID=1234 rw quiet efi_reclaim_reserved=58G@8G'
write_dropin() {
  echo 'KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G"' > "$OMARCHY_N1X_GPU_MEMORY_CONF"
}

write_dropin
echo "$reclaiming_cmdline" > "$OMARCHY_N1X_PROC_CMDLINE"
REBUILD_STATUS=1
if run; then
  fail "a failed rebuild leaves the migration pending"
fi
[[ ! -e $OMARCHY_N1X_GPU_MEMORY_CONF ]] || fail "the drop-in is removed before the rebuild"
pass "a failed rebuild leaves the migration pending"

REBUILD_STATUS=0
run
grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "the retry rebuilds the boot entries" "$(cat "$CALL_LOG")"
pass "a retry after a failed rebuild still rebuilds, though the drop-in is gone"

write_dropin
echo 'root=UUID=1234 rw quiet' > "$OMARCHY_N1X_PROC_CMDLINE"
run
[[ ! -e $OMARCHY_N1X_GPU_MEMORY_CONF ]] || fail "the drop-in is removed"
grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "removing the drop-in rebuilds the boot entries"
pass "a drop-in not yet booted is removed and the entries rebuilt"

run
grep -Fxq omarchy-apply-n1x-gpu-memory "$CALL_LOG" || fail "the firmware setting is applied"
! grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "nothing to rebuild once the option is gone" "$(cat "$CALL_LOG")"
pass "an N1x without the option is not rebuilt"

N1X_STATUS=1
write_dropin
run
[[ ! -s $CALL_LOG && -e $OMARCHY_N1X_GPU_MEMORY_CONF ]] || fail "other machines are left alone" "$(cat "$CALL_LOG")"
pass "other machines are left alone"
