#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789639200.sh"
[[ -f $migration ]] || fail "migration that removes the unsigned limine hook exists"
grep -Fq '99-omarchy-limine.hook' "$migration" ||
  fail "migration names the installer leftover hook"
grep -Fq 'sbctl sign' "$migration" ||
  fail "migration re-signs limine_x64.efi when sbctl is available"

pass "migration removes the installer limine hook and re-signs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/etc/pacman.d/hooks" "$test_tmp/boot/EFI/limine" "$test_tmp/bin"
printf 'unsigned\n' >"$test_tmp/boot/EFI/limine/limine_x64.efi"
cat >"$test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook" <<'HOOK'
[Trigger]
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Overwrite signed limine with unsigned BOOTX64.EFI
When = PostTransaction
Exec = /bin/sh -c "/usr/bin/cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/limine_x64.efi"
HOOK

cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat >"$test_tmp/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == sbctl ]]
STUB
cat >"$test_tmp/bin/sbctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/sbctl.log"
exit 0
STUB
chmod +x "$test_tmp/bin"/*

PATH="$test_tmp/bin:$PATH" \
  OMARCHY_LIMINE_PACMAN_HOOK="$test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook" \
  OMARCHY_LIMINE_EFI="$test_tmp/boot/EFI/limine/limine_x64.efi" \
  TEST_TMP="$test_tmp" \
  bash "$migration"

[[ ! -e $test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook ]] ||
  fail "migration deletes the leftover hook"
grep -Fq -- "-s $test_tmp/boot/EFI/limine/limine_x64.efi" "$test_tmp/sbctl.log" ||
  fail "migration asks sbctl to sign limine_x64.efi" "$(cat "$test_tmp/sbctl.log" 2>/dev/null || true)"

pass "migration deletes the hook and signs the EFI binary"

# Idempotent when the hook is already gone
rm -f "$test_tmp/sbctl.log"
PATH="$test_tmp/bin:$PATH" \
  OMARCHY_LIMINE_PACMAN_HOOK="$test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook" \
  OMARCHY_LIMINE_EFI="$test_tmp/boot/EFI/limine/limine_x64.efi" \
  TEST_TMP="$test_tmp" \
  bash "$migration"

grep -Fq -- "-s $test_tmp/boot/EFI/limine/limine_x64.efi" "$test_tmp/sbctl.log" ||
  fail "rerun still re-signs when the efi file remains"
pass "migration is safe to re-run"

# BIOS installs share the hook filename but deploy limine-bios.sys — keep them.
cat >"$test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook" <<'HOOK'
[Trigger]
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Refresh Limine BIOS stage
When = PostTransaction
Exec = /bin/sh -c "limine bios-install /dev/disk && cp /usr/share/limine/limine-bios.sys /boot/limine/"
HOOK
PATH="$test_tmp/bin:$PATH" \
  OMARCHY_LIMINE_PACMAN_HOOK="$test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook" \
  OMARCHY_LIMINE_EFI="$test_tmp/boot/EFI/limine/limine_x64.efi" \
  TEST_TMP="$test_tmp" \
  bash "$migration"
[[ -e $test_tmp/etc/pacman.d/hooks/99-omarchy-limine.hook ]] ||
  fail "migration leaves the BIOS limine hook in place"
pass "migration leaves BIOS limine deploy hooks alone"
