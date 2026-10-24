#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
modules="$work/root/usr/lib/modules"
stock=7.2.8-9-omarchy
fallback=7.2.11-arch1-1
mkdir -p "$work/bin" "$work/root/usr/lib/omarchy" "$modules/$stock/updates/dkms" "$modules/$fallback/updates/dkms"
export TEST_ROOT="$work/root" PACMAN_LOG="$work/pacman.log" VERIFIER_LOG="$work/verifier.log"

# Pacman's package list comes from KERNELS; each kernel package owns its
# modules.order.
cat > "$work/bin/pacman" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$PACMAN_LOG"
[[ ${BROKEN_DATABASE:-0} != 1 ]] || exit 1
case "$*" in
  *-Qq) printf 'base\n%s\n' ${KERNELS:-linux-omarchy linux} ;;
  *"-Qlq ${BROKEN_FILE_LIST:-none}") exit 1 ;;
  *"-Qlq ${EMPTY_FILE_LIST:-none}") ;;
  *"-Qlq linux-omarchy") printf '%s/usr/lib/modules/7.2.8-9-omarchy/modules.order\n' "$TEST_ROOT" ;;
  *"-Qlq linux") printf '%s/usr/lib/modules/7.2.11-arch1-1/modules.order\n' "$TEST_ROOT" ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$work/bin/pacman"

# Executable providers with the package verifiers' interface: module paths on
# stdin, the modules root as an argument, a non-zero exit naming each kernel
# that lacks the DKMS module.
for pair in 'verify-snd-hda-macbookpro snd-hda-codec-cs8409' 'verify-facetimehd facetimehd'; do
  read -r name module <<< "$pair"
  cat > "$work/root/usr/lib/omarchy/$name" <<STUB
#!/bin/bash
[[ \$1 == --modules-root && \$2 == "\$TEST_ROOT/usr/lib/modules" ]] || exit 2
status=0
while read -r target; do
  [[ -n \$target ]] || continue
  printf '%s %s\n' $name "\$target" >> "\$VERIFIER_LOG"
  kernel=\${target#usr/lib/modules/}
  kernel=\${kernel%%/*}
  if [[ ! -s \$2/\$kernel/updates/dkms/$module.ko.zst ]]; then
    echo "Missing $module for \$kernel" >&2
    status=1
  fi
done
exit \$status
STUB
  chmod +x "$work/root/usr/lib/omarchy/$name"
done
export PATH="$work/bin:$PATH"

run_check() {
  : > "$PACMAN_LOG"
  : > "$VERIFIER_LOG"
  bash "$ROOT/bin/omarchy-update-verify-kernel-modules" --root "$work/root" > "$work/out" 2>&1
}

install_module() {
  printf 'module\n' > "$modules/$1/updates/dkms/$2.ko.zst"
}

if run_check; then fail "missing drivers pass hardware verification"; fi
for module in snd-hda-codec-cs8409 facetimehd; do
  for kernel in $stock $fallback; do
    grep -q "Missing $module for $kernel" "$work/out" || fail "verification did not report $module for $kernel" "$(cat "$work/out")"
  done
done
grep -q 'before rebooting' "$work/out" || fail "failure omits reboot guidance"
pass "missing drivers are reported for the stock and fallback kernels"

for module in snd-hda-codec-cs8409 facetimehd; do
  install_module $stock $module
  install_module $fallback $module
done
rm "$modules/$fallback/updates/dkms/facetimehd.ko.zst"
if run_check; then fail "a fallback kernel without its driver passes"; fi
grep -q "Missing facetimehd for $fallback" "$work/out" || fail "the fallback kernel's missing driver is not named"
! grep -q "for $stock" "$work/out" || fail "a complete stock kernel is reported" "$(cat "$work/out")"
pass "one missing driver on one kernel fails the check and is named"

install_module $fallback facetimehd
# A directory preserved from an earlier boot is not a kernel the next boot loads.
mkdir -p "$modules/7.2.5-3-omarchy"
run_check || fail "present modules are rejected" "$(cat "$work/out")"
! grep -q '7.2.5-3-omarchy' "$VERIFIER_LOG" || fail "a preserved module directory is verified"
pass "the installed stock and fallback kernels pass without checking preserved directories"

rm "$modules/$fallback/updates/dkms/facetimehd.ko.zst"
KERNELS=linux-omarchy run_check || fail "a system without the fallback kernel checks it anyway" "$(cat "$work/out")"
! grep -q "$fallback" "$VERIFIER_LOG" || fail "an uninstalled fallback kernel is verified"
pass "only installed kernel packages are checked"

KERNELS=linux-zen run_check || fail "an alternative-kernel system is rejected" "$(cat "$work/out")"
[[ ! -s $VERIFIER_LOG ]] || fail "alternative kernels are verified" "$(cat "$VERIFIER_LOG")"
pass "alternative kernels are left to the user"

if BROKEN_DATABASE=1 run_check; then fail "an unreadable package database bypasses verification"; fi
install_module $fallback facetimehd
run_check || fail "complete kernels are rejected before the file-list cases" "$(cat "$work/out")"
for kernel in linux-omarchy linux; do
  if BROKEN_FILE_LIST=$kernel run_check; then fail "an unreadable file list for $kernel bypasses verification"; fi
  if EMPTY_FILE_LIST=$kernel run_check; then fail "an installed $kernel without modules.order bypasses verification"; fi
  grep -q "Cannot determine the modules of $kernel" "$work/out" || fail "an unresolved $kernel is not named" "$(cat "$work/out")"
done
pass "package database errors cannot bypass verification"

rm "$work/root/usr/lib/omarchy/verify-snd-hda-macbookpro" "$work/root/usr/lib/omarchy/verify-facetimehd"
run_check || fail "a machine without compatibility packages is rejected"
[[ ! -s $PACMAN_LOG ]] || fail "a machine without compatibility packages queries pacman"
pass "machines without compatibility packages skip the check"
