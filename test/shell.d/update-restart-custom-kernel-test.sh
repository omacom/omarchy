#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

export TEST_MODULES="$scratch/modules"
export TEST_LOG="$scratch/calls"
mkdir -p "$scratch/bin" "$scratch/home" "$TEST_MODULES"
sed "s|/usr/lib/modules|$TEST_MODULES|g" "$ROOT/bin/omarchy-update-restart" >"$scratch/bin/omarchy-update-restart"

cat >"$scratch/bin/uname" <<'STUB'
#!/bin/bash
printf '%s\n' "$RUNNING_KERNEL"
STUB

# Only the package-owned release resolves, as pacman -Qo does for its files.
cat >"$scratch/bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Qo" && ( $2 == "$TEST_MODULES/$OWNED_KERNEL" || $2 == "$TEST_MODULES/$OWNED_KERNEL/"* ) ]]
STUB

cat >"$scratch/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$TEST_LOG"
exit 1
STUB

cat >"$scratch/bin/pgrep" <<'STUB'
#!/bin/bash
exit 1
STUB

chmod +x "$scratch/bin/"*

kernel_prompted() {
  : >"$TEST_LOG"
  RUNNING_KERNEL="$1" OWNED_KERNEL="$2" HOME="$scratch/home" PATH="$scratch/bin:$PATH" \
    "$scratch/bin/omarchy-update-restart" --reboot-only >/dev/null
  grep -q '^prompt:confirm Linux kernel has been updated' "$TEST_LOG"
}

mkdir -p "$TEST_MODULES/7.2.1-arch1-1" "$TEST_MODULES/7.2.2-arch1-1"
touch "$TEST_MODULES/7.2.1-arch1-1/vmlinuz" "$TEST_MODULES/7.2.2-arch1-1/vmlinuz"
echo linux >"$TEST_MODULES/7.2.1-arch1-1/pkgbase"
echo linux >"$TEST_MODULES/7.2.2-arch1-1/pkgbase"
if kernel_prompted 7.2.1-arch1-1 7.2.1-arch1-1; then
  fail "running package kernel does not request a reboot" "$(cat "$TEST_LOG")"
fi
pass "running package kernel does not request a reboot"

kernel_prompted 7.2.1-arch1-1 7.2.2-arch1-1 ||
  fail "package kernel restored by kernel-modules-hook requests a reboot" "$(cat "$TEST_LOG")"
pass "package kernel restored by kernel-modules-hook requests a reboot"

kernel_prompted 7.2.0-arch1-1 7.2.2-arch1-1 ||
  fail "package kernel whose modules were removed requests a reboot" "$(cat "$TEST_LOG")"
pass "package kernel whose modules were removed requests a reboot"

mkdir -p "$TEST_MODULES/7.2.1-custom"
if kernel_prompted 7.2.1-custom 7.2.2-arch1-1; then
  fail "kernel installed outside pacman does not request a reboot" "$(cat "$TEST_LOG")"
fi
pass "kernel installed outside pacman does not request a reboot"

mkdir -p "$TEST_MODULES/7.2.1-manual"
echo linux-manual >"$TEST_MODULES/7.2.1-manual/pkgbase"
if kernel_prompted 7.2.1-manual 7.2.2-arch1-1; then
  fail "kernel installed outside pacman with a pkgbase marker does not request a reboot" "$(cat "$TEST_LOG")"
fi
pass "kernel installed outside pacman with a pkgbase marker does not request a reboot"
