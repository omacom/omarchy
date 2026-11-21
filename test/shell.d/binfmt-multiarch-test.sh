#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-apply-binfmt"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

source_dir="$test_tmp/lib-binfmt.d"
dest_dir="$test_tmp/etc-binfmt.d"
proc_dir="$test_tmp/binfmt_misc"
fake_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$source_dir" "$fake_bin"

cat >"$fake_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
exec "$@"
STUB
chmod +x "$fake_bin/systemctl" "$fake_bin/sudo"

write_conf() {
  # Shaped like the qemu-user-static-binfmt package's own registrations:
  # a magic/mask binfmt_misc line ending in the flags field.
  printf ':qemu-%s:M::magic:mask:/usr/bin/qemu-%s-static:%s\n' "$1" "$1" "${3:-FP}" >"$2"
}

registration() {
  printf ':qemu-%s:M::magic:mask:/usr/bin/qemu-%s-static:%s' "$1" "$1" "$2"
}

set_live() {
  mkdir -p "$proc_dir"
  : >"$proc_dir/status"
  printf 'enabled\ninterpreter /usr/bin/qemu-%s-static\nflags: %s\n' "$1" "$2" >"$proc_dir/qemu-$1"
}

apply() {
  TEST_LOG="$calls" \
  PATH="$ROOT/bin:$fake_bin:$PATH" \
  OMARCHY_BINFMT_SOURCE_DIR="$source_dir" \
  OMARCHY_BINFMT_DIR="$dest_dir" \
  OMARCHY_BINFMT_PROC_DIR="$proc_dir" \
    "$@"
}

reset() {
  rm -rf "$source_dir" "$dest_dir" "$proc_dir"
  mkdir -p "$source_dir"
  : >"$calls"
}

# Every qemu static registration gets O and C added to the package's own flags,
# with the rest of the line untouched, and anything else is ignored.
reset
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
write_conf arm "$source_dir/qemu-arm-static.conf"
printf 'unrelated\n' >"$source_dir/other.conf"

apply "$command" --check && fail "--check reports pending registrations"
[[ ! -e $dest_dir ]] || fail "--check changes nothing"
apply "$command"

grep -qFx "$(registration aarch64 FPOC)" "$dest_dir/qemu-aarch64-static.conf" ||
  fail "adds O and C to aarch64 flags without dropping FP"
grep -qFx "$(registration arm FPOC)" "$dest_dir/qemu-arm-static.conf" ||
  fail "adds O and C to arm flags without dropping FP"
grep -q '^# Managed by omarchy-apply-binfmt ' "$dest_dir/qemu-aarch64-static.conf" ||
  fail "marks overrides as managed"
[[ ! -e $dest_dir/other.conf ]] || fail "copies files that aren't qemu static registrations"
pass "adds O and C to every qemu static registration without dropping existing flags"

# Re-running neither rewrites nor piles up duplicate letters.
before=$(cat "$dest_dir"/*.conf)
apply "$command"
[[ $(cat "$dest_dir"/*.conf) == "$before" ]] || fail "is idempotent"
apply "$command" --check || fail "--check passes once applied"
pass "is idempotent and --check passes once applied"

# A registration that already carries O and C keeps its flags as they are.
reset
write_conf riscv64 "$source_dir/qemu-riscv64-static.conf" FPOCX
apply "$command"
grep -qFx "$(registration riscv64 FPOCX)" "$dest_dir/qemu-riscv64-static.conf" ||
  fail "leaves flags that already include O and C alone"
pass "leaves flags that already include O and C alone"

# A package update that changes a registration, adds an architecture or drops
# one is followed, which a one-time copy would hide behind a stale override.
reset
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
write_conf sparc "$source_dir/qemu-sparc-static.conf"
apply "$command"
sed -i 's/magic/magic2/' "$source_dir/qemu-aarch64-static.conf"
write_conf loongarch64 "$source_dir/qemu-loongarch64-static.conf"
rm "$source_dir/qemu-sparc-static.conf"
apply "$command"
grep -qFx ':qemu-aarch64:M::magic2:mask:/usr/bin/qemu-aarch64-static:FPOC' "$dest_dir/qemu-aarch64-static.conf" ||
  fail "follows a changed registration"
grep -qFx "$(registration loongarch64 FPOC)" "$dest_dir/qemu-loongarch64-static.conf" ||
  fail "covers an added architecture"
[[ ! -e $dest_dir/qemu-sparc-static.conf ]] || fail "removes the override of a dropped architecture"
pass "follows changed, added and dropped registrations"

# Administrator-authored overrides are never rewritten or removed.
reset
mkdir -p "$dest_dir"
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
printf ':qemu-aarch64:M::magic:mask:/opt/qemu/qemu-aarch64:F\n' >"$dest_dir/qemu-aarch64-static.conf"
printf ':qemu-m68k:M::magic:mask:/opt/qemu/qemu-m68k:F\n' >"$dest_dir/qemu-m68k-static.conf"
apply "$command" 2>/dev/null
grep -qFx ':qemu-aarch64:M::magic:mask:/opt/qemu/qemu-aarch64:F' "$dest_dir/qemu-aarch64-static.conf" ||
  fail "leaves an unmanaged override alone"
[[ -e $dest_dir/qemu-m68k-static.conf ]] || fail "leaves an unmanaged override without a registration alone"
pass "leaves administrator-authored overrides alone"

# An empty source directory, as before qemu-user-static-binfmt is installed.
reset
apply "$command" || fail "tolerates a source directory with no qemu registrations"
pass "tolerates a source directory with no qemu registrations"

# systemd-binfmt is restarted when overrides change, and when they are already
# on disk but the running registrations still carry the old flags.
reset
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
set_live aarch64 PF
apply "$command"
grep -qFx 'systemctl restart systemd-binfmt.service' "$calls" || fail "restarts systemd-binfmt after writing overrides"

: >"$calls"
apply "$command"
grep -qFx 'systemctl restart systemd-binfmt.service' "$calls" ||
  fail "restarts systemd-binfmt while running registrations lack O and C"

: >"$calls"
set_live aarch64 POCF
apply "$command"
[[ ! -s $calls ]] || fail "leaves systemd-binfmt alone once running registrations match"
pass "restarts systemd-binfmt only while running registrations differ"

# Without binfmt_misc mounted, as in the ISO's target chroot, overrides are
# still written and load at boot.
reset
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
apply "$command"
[[ -e $dest_dir/qemu-aarch64-static.conf ]] || fail "writes overrides without binfmt_misc mounted"
[[ ! -s $calls ]] || fail "skips the restart without binfmt_misc mounted"
pass "writes overrides without restarting when binfmt_misc is not mounted"

# The migration escalates only when something is pending, so a second user on
# an already fixed machine is not prompted.
migration=$(grep -rl 'omarchy-apply-binfmt' "$ROOT/migrations" | head -n 1 || true)
[[ -n $migration ]] || fail "binfmt migration exists"

reset
write_conf aarch64 "$source_dir/qemu-aarch64-static.conf"
apply bash -euo pipefail "$migration" >/dev/null
grep -qFx "$(registration aarch64 FPOC)" "$dest_dir/qemu-aarch64-static.conf" ||
  fail "binfmt migration applies pending overrides"
grep -q '^sudo omarchy-apply-binfmt$' "$calls" || fail "binfmt migration escalates to apply"

: >"$calls"
apply bash -euo pipefail "$migration" >/dev/null
[[ ! -s $calls ]] || fail "binfmt migration does not escalate once applied"
pass "binfmt migration escalates only when overrides are pending"
