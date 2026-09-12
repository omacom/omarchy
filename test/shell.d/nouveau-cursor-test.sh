#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/hypr" "$test_tmp/omarchy/config/hypr"
# Packaged stub used when seeding a missing looknfeel.
printf '%s\n' '-- Packaged looknfeel stub' >"$test_tmp/omarchy/config/hypr/looknfeel.lua"

# Default fake lspci: -k is blind (install/chroot libkmod failure), plain lspci
# still reports an NVIDIA VGA device.
cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
if [[ ${1:-} == -k ]]; then
  # Simulate install-time libkmod failure: no "Kernel driver in use" lines.
  printf '%s\n' "03:00.0 VGA compatible controller: NVIDIA Corporation C79 [GeForce 9400M] (rev b1)" >&2
  echo "lspci: Unable to load libkmod resources: error -2" >&2
  exit 0
fi
printf '%s\n' "03:00.0 VGA compatible controller: NVIDIA Corporation C79 [GeForce 9400M] (rev b1)"
SH
chmod +x "$test_tmp/bin/lspci"

# Hide real module/sysfs signals so tests exercise the lspci fallback path.
cat >"$test_tmp/bin/lsmod" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin/lsmod"

looknfeel="$test_tmp/home/.config/hypr/looknfeel.lua"
printf '%s\n' '-- User look and feel' >"$looknfeel"

run_fix() {
  # Optionally shadow /sys/module/nouveau by not creating it under a fake root;
  # the script checks the real /sys/module/nouveau. Skip that path by relying on
  # machines/CI without nouveau loaded, and cover it separately if present.
  HOME="$test_tmp/home" \
    PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    OMARCHY_PATH="$test_tmp/omarchy" \
    OMARCHY_NVIDIA_MODPROBE_CONFIG="$test_tmp/nvidia.conf" \
    bash -euo pipefail -c 'source "$ROOT/install/user/hardware/fix-nouveau-cursor.sh"'
}

run_fix >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "nouveau hardware setup enables software cursors when lspci -k is blind"

run_fix >/dev/null
(( $(grep -c 'no_hardware_cursors = true' "$looknfeel") == 1 )) || fail "nouveau cursor setup is idempotent"
pass "nouveau cursor setup is idempotent"

# Missing looknfeel: seed packaged stub then append.
rm -f "$looknfeel"
run_fix >/dev/null
[[ -f $looknfeel ]] || fail "looknfeel is created when missing"
grep -F -- '-- Packaged looknfeel stub' "$looknfeel" >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "nouveau cursor setup seeds missing looknfeel.lua"

# Non-NVIDIA lspci output should not apply the fix.
printf '%s\n' '-- User look and feel' >"$looknfeel"
cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
if [[ ${1:-} == -k ]]; then
  printf '%s\n' "00:02.0 VGA compatible controller: Intel Corporation Device
Kernel driver in use: i915"
  exit 0
fi
printf '%s\n' "00:02.0 VGA compatible controller: Intel Corporation Device"
SH
chmod +x "$test_tmp/bin/lspci"
run_fix >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "nouveau cursor setup ignores other video drivers"
fi
pass "nouveau cursor setup ignores other video drivers"

# Proprietary NVIDIA path: nvidia.conf present even if lspci shows NVIDIA.
printf '%s\n' '-- User look and feel' >"$looknfeel"
cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "01:00.0 VGA compatible controller: NVIDIA Corporation Device"
SH
chmod +x "$test_tmp/bin/lspci"
touch "$test_tmp/nvidia.conf"
run_fix >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "nouveau cursor setup skips proprietary NVIDIA installs"
fi
pass "nouveau cursor setup skips proprietary NVIDIA installs"

# Classic happy path: lspci -k reports nouveau.
rm -f "$test_tmp/nvidia.conf"
printf '%s\n' '-- User look and feel' >"$looknfeel"
cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
if [[ ${1:-} == -k ]]; then
  printf '%s\n' "03:00.0 VGA compatible controller: NVIDIA Corporation Device
	Kernel driver in use: nouveau"
  exit 0
fi
printf '%s\n' "03:00.0 VGA compatible controller: NVIDIA Corporation Device"
SH
chmod +x "$test_tmp/bin/lspci"
run_fix >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "nouveau cursor setup still honors lspci -k when available"
