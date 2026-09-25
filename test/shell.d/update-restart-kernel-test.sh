#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

mkdir -p "$scratch/bin" "$scratch/home/.local/state/omarchy" "$scratch/modules"
log="$scratch/calls"

cat >"$scratch/bin/uname" <<'STUB'
#!/bin/bash
[[ ${1:-} == "-r" ]] || exit 2
printf '%s\n' "$RUNNING_KERNEL"
STUB

cat >"$scratch/bin/pacman" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-Qo" && ${2:-} == "$OMARCHY_MODULES_ROOT/$OWNED_KERNEL/" ]]; then
  exit 0
fi
exit 1
STUB

cat >"$scratch/bin/gum" <<'STUB'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$TEST_LOG"
exit 1
STUB

cat >"$scratch/bin/pgrep" <<'STUB'
#!/bin/bash
exit 1
STUB

cat >"$scratch/bin/omarchy-restart-shell" <<'STUB'
#!/bin/bash
printf 'restart-shell\n' >>"$TEST_LOG"
STUB

cat >"$scratch/bin/omarchy-system-reboot" <<'STUB'
#!/bin/bash
printf 'reboot\n' >>"$TEST_LOG"
STUB

chmod +x "$scratch/bin/"*

run_case() {
  local running="$1"
  local owned="$2"
  : >"$log"
  RUNNING_KERNEL="$running" OWNED_KERNEL="$owned" TEST_LOG="$log"     OMARCHY_MODULES_ROOT="$scratch/modules" HOME="$scratch/home"     PATH="$scratch/bin:$PATH"     "$ROOT/bin/omarchy-update-restart" >/dev/null
}

mkdir -p "$scratch/modules/7.2.2-2-aarch64-ARCH"
run_case "7.2.2-2-aarch64-ARCH" "7.2.2-2-aarch64-ARCH"
if grep -q 'Linux kernel has been updated' "$log"; then
  fail "owned running aarch64 kernel does not request reboot" "$(cat "$log")"
fi
pass "owned running aarch64 kernel is recognized without vmlinuz"

mkdir -p "$scratch/modules/7.2.3-1-aarch64-ARCH"
run_case "7.2.2-2-aarch64-ARCH" "7.2.3-1-aarch64-ARCH"
grep -q 'Linux kernel has been updated. Reboot?' "$log" ||
  fail "different installed kernel requests reboot" "$(cat "$log")"
pass "different installed kernel still requests reboot"

run_case "7.2.2-2-aarch64-ARCH" "not-the-running-kernel"
grep -q 'Linux kernel has been updated. Reboot?' "$log" ||
  fail "unowned modules directory cannot suppress reboot" "$(cat "$log")"
pass "only package-owned module directories count as installed kernels"
