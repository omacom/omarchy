#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-boot-rebuild on systemd-boot builds an initramfs per installed kernel
# and stores it as a boot image. --initramfs PKGBASE=FILE stores a given one
# for that kernel instead (the installer's, from its root image); every other
# kernel still builds, and so does that one when the file is missing.
# omarchy-boot-switch install passes the option through.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/hooks"
cat >"$test_tmp/bin/mkinitcpio" <<'SH'
#!/bin/bash
while (($#)); do
  case $1 in
  -k) kver=$2; shift ;;
  -g) out=$2; shift ;;
  esac
  shift
done
echo "mkinitcpio $kver" >>"$CALLS"
printf 'built for %s\n' "$kver" >"$out"
SH
cat >"$test_tmp/bin/omarchy-boot-sync" <<'SH'
#!/bin/bash
if [[ $1 == "import" ]]; then
  echo "import $2 $3 $(<"$5")" >>"$CALLS"
else
  echo "$1" >>"$CALLS"
fi
SH
cat >"$test_tmp/bin/omarchy-boot-backend" <<'SH'
#!/bin/bash
echo systemd-boot
SH
chmod +x "$test_tmp/bin/"*

for kernel in linux-omarchy:7.2.1 linux-lts:6.12.9; do
  mkdir -p "$test_tmp/modules/${kernel#*:}"
  echo "${kernel%%:*}" >"$test_tmp/modules/${kernel#*:}/pkgbase"
  printf 'k\n' >"$test_tmp/modules/${kernel#*:}/vmlinuz"
done
printf 'from the image\n' >"$test_tmp/prebuilt.img"

rebuild() {
  : >"$test_tmp/calls"
  env PATH="$test_tmp/bin:$PATH" CALLS="$test_tmp/calls" OMARCHY_BOOT_MODULES="$test_tmp/modules" \
    OMARCHY_BOOT_MKINITCPIO="$test_tmp/bin/mkinitcpio" OMARCHY_BOOT_HOOKS_DIR="$test_tmp/hooks" \
    bash "$ROOT/bin/omarchy-boot-rebuild" "$@" >"$test_tmp/out" 2>&1
}

rebuild || fail "a rebuild runs" "$(cat "$test_tmp/out")"
[[ $(sort "$test_tmp/calls") == $(printf '%s\n' "import linux-lts 6.12.9 built for 6.12.9" "import linux-omarchy 7.2.1 built for 7.2.1" \
  "mkinitcpio 6.12.9" "mkinitcpio 7.2.1" sync | sort) ]] || fail "every kernel builds and is imported" "$(cat "$test_tmp/calls")"
pass "without --initramfs every installed kernel builds its initramfs"

rebuild --initramfs "linux-omarchy=$test_tmp/prebuilt.img" || fail "a rebuild with a pre-built initramfs runs" "$(cat "$test_tmp/out")"
grep -qx "import linux-omarchy 7.2.1 from the image" "$test_tmp/calls" || fail "the given initramfs is stored for its kernel" "$(cat "$test_tmp/calls")"
! grep -qx "mkinitcpio 7.2.1" "$test_tmp/calls" || fail "the kernel with a given initramfs doesn't build one" "$(cat "$test_tmp/calls")"
grep -qx "import linux-lts 6.12.9 built for 6.12.9" "$test_tmp/calls" || fail "another kernel still builds" "$(cat "$test_tmp/calls")"
[[ $(tail -1 "$test_tmp/calls") == sync ]] || fail "the images are published" "$(cat "$test_tmp/calls")"
[[ -s $test_tmp/prebuilt.img ]] || fail "the given initramfs is left in place"
pass "--initramfs stores the given initramfs for that kernel only"

rebuild --initramfs "linux-omarchy=$test_tmp/prebuilt.img" linux-omarchy || fail "a rebuild of one kernel runs" "$(cat "$test_tmp/out")"
[[ $(<"$test_tmp/calls") == $(printf '%s\n' "import linux-omarchy 7.2.1 from the image" sync) ]] ||
  fail "a rebuild of one kernel with a given initramfs only imports it" "$(cat "$test_tmp/calls")"
pass "--initramfs works with a kernel list"

rebuild --initramfs "linux-omarchy=$test_tmp/missing.img" || fail "a rebuild with a missing initramfs runs" "$(cat "$test_tmp/out")"
grep -qx "import linux-omarchy 7.2.1 built for 7.2.1" "$test_tmp/calls" || fail "a missing initramfs is built instead" "$(cat "$test_tmp/calls")"
grep -q "missing; building one" "$test_tmp/out" || fail "a missing initramfs is reported" "$(cat "$test_tmp/out")"
pass "a missing pre-built initramfs falls back to mkinitcpio"

rebuild --initramfs "linux-zen=$test_tmp/prebuilt.img" || fail "a rebuild naming a kernel that isn't installed runs" "$(cat "$test_tmp/out")"
[[ $(grep -c '^mkinitcpio' "$test_tmp/calls") == 2 ]] && ! grep -q 'from the image' "$test_tmp/calls" ||
  fail "a kernel that isn't installed gets nothing and the rest build" "$(cat "$test_tmp/calls")"
grep -q "linux-zen isn't installed" "$test_tmp/out" || fail "the unused initramfs is reported" "$(cat "$test_tmp/out")"
pass "a pre-built initramfs for a kernel that isn't installed is ignored"

for bad in "" linux-omarchy "=$test_tmp/prebuilt.img" "linux-omarchy="; do
  if rebuild --initramfs "$bad"; then
    fail "--initramfs '$bad' is refused"
  fi
done
pass "--initramfs needs PKGBASE=FILE"

# omarchy-boot-switch install hands its --initramfs options to the rebuild.
awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-boot-switch" >"$test_tmp/functions"

install_fresh_with() {
  bash -c '
    set -euo pipefail
    source "$1/functions"
    dir=$1
    ESP=$1/esp STORE=$1/store TOP=$1/top LOADER_SOURCE=$1/loader.efi FALLBACK=EFI/BOOT/BOOTX64.EFI
    findmnt() { :; }
    stat() { echo btrfs; }
    mountpoint() { return 1; }
    omarchy-boot-backend() { echo systemd-boot; }
    create_store() { :; }
    adopt_cmdline() { :; }
    install_loader() { :; }
    state_get() { :; }
    state_set() { :; }
    systemctl() { :; }
    systemd-detect-virt() { return 1; }
    omarchy-boot-sync() { :; }
    omarchy-boot-rebuild() { printf "%s\n" "rebuild $*" >"$dir/rebuild"; }
    shift
    install_fresh --no-efi-register --no-fallback "$@"
  ' _ "$test_tmp" "$@"
}

mkdir -p "$test_tmp/esp"
printf 'loader\n' >"$test_tmp/loader.efi"
install_fresh_with || fail "an install without --initramfs runs"
[[ $(<"$test_tmp/rebuild") == "rebuild " ]] || fail "an install without --initramfs rebuilds every kernel" "$(cat "$test_tmp/rebuild")"
install_fresh_with --initramfs "linux-omarchy=/var/lib/omarchy-iso/prebuilt-initramfs.img" --prefer linux-lts ||
  fail "an install with --initramfs runs"
[[ $(<"$test_tmp/rebuild") == "rebuild --initramfs linux-omarchy=/var/lib/omarchy-iso/prebuilt-initramfs.img" ]] ||
  fail "an install passes --initramfs to the rebuild" "$(cat "$test_tmp/rebuild")"
if install_fresh_with --initramfs linux-omarchy 2>/dev/null; then
  fail "an install refuses --initramfs without a file"
fi
pass "omarchy-boot-switch install passes --initramfs to the rebuild"
