#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

running_kernel=$(uname -r)
mkdir -p "$scratch/bin" "$scratch/modules/$running_kernel" "$scratch/home/.local/state/omarchy"
touch "$scratch/modules/$running_kernel/vmlinuz"

export PATH="$scratch/bin:$ROOT/bin:$PATH"
export HOME="$scratch/home"
export OMARCHY_MODULES_DIR="$scratch/modules"
export CALL_LOG="$scratch/calls"

cat > "$scratch/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Qo) exit 0 ;;
  -Q)
    shift
    for pkg in "$@"; do
      if [[ -n ${MOCK_NVIDIA_PKG:-} && $pkg == "$MOCK_NVIDIA_PKG" ]]; then
        echo "$pkg ${MOCK_NVIDIA_VER:-615.78.08-1}"
        exit 0
      fi
    done
    exit 1
    ;;
  *) exit 99 ;;
esac
SH

cat > "$scratch/bin/gum" <<'SH'
#!/bin/bash
printf 'prompt:%s\n' "$*" >> "$CALL_LOG"
exit 1
SH

cat > "$scratch/bin/omarchy-system-reboot" <<'SH'
#!/bin/bash
echo "reboot" >> "$CALL_LOG"
SH

cat > "$scratch/bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
exit 0
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$scratch/bin/"*

nvidia_proc="$scratch/nvidia-proc-version"
nvidia_sys="$scratch/nvidia-sys-version"
export OMARCHY_NVIDIA_PROC_VERSION="$nvidia_proc"
export OMARCHY_NVIDIA_SYS_VERSION="$nvidia_sys"

cat > "$nvidia_proc" <<'EOF'
NVRM version: NVIDIA UNIX x86_64 Kernel Module  615.71.09  Wed Jan 28 17:15:20 UTC 2026
GCC version:  gcc version 15.2.1 20260207 (GCC)
EOF

# 1. Version mismatch offers reboot
: > "$CALL_LOG"
MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
grep -Fxq 'prompt:confirm NVIDIA driver has been updated. Reboot?' "$CALL_LOG" || fail "driver mismatch offers reboot"
pass "mismatched nvidia-utils offers a reboot"

# 2. Unattended mode reports reboot requirement without gum prompt
: > "$CALL_LOG"
OMARCHY_UPDATE_UNATTENDED=1 MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
! grep -q '^prompt:' "$CALL_LOG" || fail "unattended mode must not prompt"
grep -q 'NVIDIA driver has been updated. Reboot? Run omarchy-system-reboot when ready.' "$scratch/output" || fail "unattended mode explains reboot"
pass "unattended mode reports the NVIDIA reboot requirement without prompting"

# 3. Matching version does not offer reboot
: > "$CALL_LOG"
MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.71.09-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
! grep -q 'prompt:' "$CALL_LOG" || fail "matching version must not offer reboot"
pass "matching nvidia-utils does not prompt for reboot"

# 4. No loaded NVIDIA module does not offer reboot
: > "$CALL_LOG"
rm -f "$nvidia_proc" "$nvidia_sys"
MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
! grep -q 'prompt:' "$CALL_LOG" || fail "missing driver version must not offer reboot"
pass "systems without a loaded NVIDIA driver do not prompt for reboot"

# 5. Sysfs module version fallback detects mismatch
echo "615.71.09" > "$nvidia_sys"
: > "$CALL_LOG"
MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
grep -Fxq 'prompt:confirm NVIDIA driver has been updated. Reboot?' "$CALL_LOG" || fail "sysfs driver mismatch offers reboot"
pass "sysfs module version fallback offers a reboot"
rm -f "$nvidia_sys"

# 6. Legacy 580xx utils mismatch offers reboot
cat > "$nvidia_proc" <<'EOF'
NVRM version: NVIDIA UNIX x86_64 Kernel Module  580.80.00  Mon Aug 10 12:00:00 UTC 2026
EOF
: > "$CALL_LOG"
MOCK_NVIDIA_PKG="nvidia-580xx-utils" MOCK_NVIDIA_VER="580.82.07-1" \
  omarchy-update-restart --reboot-only > "$scratch/output" 2>&1
grep -Fxq 'prompt:confirm NVIDIA driver has been updated. Reboot?' "$CALL_LOG" || fail "580xx driver mismatch offers reboot"
pass "mismatched nvidia-580xx-utils offers a reboot"

# 7. Services-only mode never prompts for reboot
: > "$CALL_LOG"
MOCK_NVIDIA_PKG="nvidia-utils" MOCK_NVIDIA_VER="615.78.08-1" \
  omarchy-update-restart --services-only > "$scratch/output" 2>&1
! grep -q 'prompt:' "$CALL_LOG" || fail "services-only mode must not prompt for reboot"
pass "services-only mode does not prompt for reboot even on driver mismatch"
