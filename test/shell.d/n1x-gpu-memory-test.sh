#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/efivars"
export CALL_LOG="$tmp_dir/calls" N1X="$tmp_dir/n1x"
export OMARCHY_EFIVARS="$tmp_dir/efivars" OMARCHY_N1X_GPU_MEMORY_CONF="$tmp_dir/omarchy-n1x-gpu-memory.conf"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

cat > "$tmp_dir/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ -e $N1X ]]
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
for command in chattr limine-mkinitcpio; do
  cat > "$tmp_dir/bin/$command" <<'SH'
#!/bin/bash
echo "${0##*/}${*:+ $*}" >> "$CALL_LOG"
SH
done
chmod +x "$tmp_dir/bin/"*

var="$OMARCHY_EFIVARS/EXPOSED_DISP_FRM-4b086294-0740-4f71-a7b5-85a329c7ec5f"
shipped='\x07\x00\x00\x00\x00\xfa\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00'
four_gib='\x07\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01'

apply() { : > "$CALL_LOG"; omarchy-apply-n1x-gpu-memory >/dev/null 2>&1; }
migrate() { : > "$CALL_LOG"; bash -euo pipefail "$ROOT/migrations/1791784278.sh" >/dev/null 2>&1; }
holds() { cmp -s <(printf "$1") "$var"; }

printf "$shipped" > "$var"
apply
holds "$shipped" && [[ ! -s $CALL_LOG ]] || fail "other machines are left alone"
pass "other machines are left alone"

touch "$N1X"
apply
holds "$four_gib" || fail "the reservation is set to 4 GiB" "$(od -An -tx1 "$var")"
[[ $(<"$CALL_LOG") == $'chattr -i '"$var"$'\nchattr +i '"$var" ]] ||
  fail "the variable is made mutable only for the write" "$(<"$CALL_LOG")"
pass "an N1x reservation is set to 4 GiB with its attributes kept"

apply
[[ ! -s $CALL_LOG ]] || fail "a set reservation is not rewritten"
pass "a set reservation is not rewritten"

printf '\x07\x00\x00\x00\x00\xfa\x00\x00\x00\x00\x00\x40\x00' > "$var"
cp "$var" "$tmp_dir/unknown"
! apply || fail "an unknown layout is an error"
cmp -s "$tmp_dir/unknown" "$var" && [[ ! -s $CALL_LOG ]] || fail "an unknown layout is left alone"
pass "an unknown layout is left alone"

rm "$var"
! apply || fail "a firmware without the variable is an error"
pass "a firmware without the variable is an error"

printf "$shipped" > "$var"
cat > "$OMARCHY_N1X_GPU_MEMORY_CONF" <<'CONF'
KERNEL_CMDLINE[default]+=" efi_reclaim_reserved=58G@8G"
CONF
migrate
holds "$four_gib" || fail "the migration sets the reservation"
[[ ! -e $OMARCHY_N1X_GPU_MEMORY_CONF ]] || fail "the kernel reclaim option is removed"
grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "the boot entries are rebuilt"
pass "the migration replaces the kernel reclaim with the firmware setting"

migrate
[[ ! -s $CALL_LOG ]] || fail "the migration does nothing a second time" "$(<"$CALL_LOG")"
pass "the migration is idempotent"
