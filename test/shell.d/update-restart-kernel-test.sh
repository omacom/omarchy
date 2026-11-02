#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home" "$tmp_dir/modules"
cat >"$tmp_dir/bin/uname" <<'STUB'
#!/bin/bash
echo "$TEST_RUNNING_KERNEL"
STUB
cat >"$tmp_dir/bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Qo" ]]; then
  grep -Fxq "$2" "$TEST_OWNED_FILES"
elif [[ $1 == "-Q" ]]; then
  shift
  for pkg in "$@"; do
    if [[ -n ${MOCK_NVIDIA_PKG:-} && $pkg == $MOCK_NVIDIA_PKG ]]; then
      echo "$pkg ${MOCK_NVIDIA_VER:-615.78.08-1}"
      exit 0
    fi
  done
  exit 1
fi
STUB
cat >"$tmp_dir/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$TEST_LOG"
exit 1
STUB
cat >"$tmp_dir/bin/pgrep" <<'STUB'
#!/bin/bash
exit 1
STUB
cat >"$tmp_dir/bin/omarchy-restart-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$tmp_dir/bin/omarchy-state" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$tmp_dir/bin"/*

export TEST_OWNED_FILES="$tmp_dir/owned" TEST_LOG="$tmp_dir/log"
export OMARCHY_PATH="$ROOT"
export OMARCHY_NVIDIA_PROC_VERSION="$tmp_dir/no-proc-nvidia"
export OMARCHY_NVIDIA_SYS_VERSION="$tmp_dir/no-sys-nvidia"

# kernel VERSION FILE...: a modules directory holding the given package-owned files
kernel() {
  local version=$1 file
  shift
  rm -rf "$tmp_dir/modules"
  mkdir -p "$tmp_dir/modules/$version"
  : >"$TEST_OWNED_FILES"
  for file in "$@"; do
    touch "$tmp_dir/modules/$version/$file"
    echo "$tmp_dir/modules/$version/$file" >>"$TEST_OWNED_FILES"
  done
}

prompts() {
  local mode="${2:---reboot-only}"
  : >"$TEST_LOG"
  TEST_RUNNING_KERNEL=$1 OMARCHY_KERNEL_MODULES_PATH="$tmp_dir/modules" HOME="$tmp_dir/home" \
    OMARCHY_UPDATE_UNATTENDED=0 PATH="$tmp_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-restart" "$mode" >/dev/null 2>&1
  cat "$TEST_LOG"
}

kernel 7.2.8-1-aarch64-ARCH modules.builtin
[[ -z $(prompts 7.2.8-1-aarch64-ARCH) ]] || fail "a running Arch Linux ARM kernel, which ships no vmlinuz, asks for a reboot"
pass "a running Arch Linux ARM kernel does not ask for a reboot"

kernel 7.2.8-arch1-1 modules.builtin vmlinuz
[[ -z $(prompts 7.2.8-arch1-1) ]] || fail "a running Arch kernel asks for a reboot"
pass "a running Arch kernel does not ask for a reboot"

kernel 7.2.9-1-aarch64-ARCH modules.builtin
grep -Fxq "prompt:confirm --affirmative Yes --negative No Linux kernel has been updated. Reboot?" <<<"$(prompts 7.2.8-1-aarch64-ARCH)" ||
  fail "an updated kernel asks for a reboot"
pass "an updated kernel asks for a reboot"

kernel 7.2.8-1-aarch64-ARCH
touch "$tmp_dir/modules/7.2.8-1-aarch64-ARCH/modules.builtin"
grep -Fxq "prompt:confirm --affirmative Yes --negative No Linux kernel has been updated. Reboot?" <<<"$(prompts 7.2.8-1-aarch64-ARCH)" ||
  fail "a leftover directory no package owns asks for a reboot"
pass "a leftover directory no package owns asks for a reboot"

# NVIDIA driver restart tests
kernel 7.2.8-arch1-1 modules.builtin vmlinuz

cat >"$tmp_dir/nvidia-proc" <<'EOF'
NVRM version: NVIDIA UNIX x86_64 Kernel Module  615.71.09  Wed Jan 28 17:15:20 UTC 2026
GCC version:  gcc version 15.2.1 20260207 (GCC)
EOF
export OMARCHY_NVIDIA_PROC_VERSION="$tmp_dir/nvidia-proc"

export MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1"
grep -Fxq "prompt:confirm --affirmative Yes --negative No NVIDIA driver has been updated. Reboot?" <<<"$(prompts 7.2.8-arch1-1)" ||
  fail "mismatched nvidia-utils offers a reboot"
pass "mismatched nvidia-utils offers a reboot"

export MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.71.09-1"
[[ -z $(prompts 7.2.8-arch1-1) ]] || fail "matching nvidia-utils prompts for reboot"
pass "matching nvidia-utils does not prompt for reboot"

rm -f "$tmp_dir/nvidia-proc"
export OMARCHY_NVIDIA_PROC_VERSION="$tmp_dir/no-proc-nvidia"
export MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1"
[[ -z $(prompts 7.2.8-arch1-1) ]] || fail "systems without a loaded NVIDIA driver prompt for reboot"
pass "systems without a loaded NVIDIA driver do not prompt for reboot"

echo "615.71.09" >"$tmp_dir/nvidia-sys"
export OMARCHY_NVIDIA_SYS_VERSION="$tmp_dir/nvidia-sys"
grep -Fxq "prompt:confirm --affirmative Yes --negative No NVIDIA driver has been updated. Reboot?" <<<"$(prompts 7.2.8-arch1-1)" ||
  fail "sysfs module version fallback offers a reboot"
pass "sysfs module version fallback offers a reboot"
rm -f "$tmp_dir/nvidia-sys"
export OMARCHY_NVIDIA_SYS_VERSION="$tmp_dir/no-sys-nvidia"

cat >"$tmp_dir/nvidia-proc" <<'EOF'
NVRM version: NVIDIA UNIX x86_64 Kernel Module  580.80.00  Mon Aug 10 12:00:00 UTC 2026
EOF
export OMARCHY_NVIDIA_PROC_VERSION="$tmp_dir/nvidia-proc"
export MOCK_NVIDIA_PKG="nvidia-580xx-utils" MOCK_NVIDIA_VER="580.82.07-1"
grep -Fxq "prompt:confirm --affirmative Yes --negative No NVIDIA driver has been updated. Reboot?" <<<"$(prompts 7.2.8-arch1-1)" ||
  fail "mismatched nvidia-580xx-utils offers a reboot"
pass "mismatched nvidia-580xx-utils offers a reboot"

export MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1"
[[ -z $(prompts 7.2.8-arch1-1 --services-only) ]] || fail "services-only mode prompts for reboot"
pass "services-only mode does not prompt for reboot even on driver mismatch"

cat >"$tmp_dir/nvidia-proc" <<'EOF'
NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  615.71.09  Release Build  (root@archlinux)  Wed Jan 28 17:15:20 UTC 2026
GCC version:  gcc version 15.2.1 20260207 (GCC)
EOF
export OMARCHY_NVIDIA_PROC_VERSION="$tmp_dir/nvidia-proc"
export MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1"
grep -Fxq "prompt:confirm --affirmative Yes --negative No NVIDIA driver has been updated. Reboot?" <<<"$(prompts 7.2.8-arch1-1)" ||
  fail "open kernel module format (nvidia-open-dkms) offers a reboot"
pass "open kernel module format (nvidia-open-dkms) offers a reboot"
