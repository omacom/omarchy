#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

cat >"$test_dir/bin/lspci" <<'EOF'
#!/bin/bash
printf '%s\n' "$LSPCI_OUTPUT"
EOF

cat >"$test_dir/bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$PACKAGE_LOG"
EOF

chmod +x "$test_dir/bin/lspci" "$test_dir/bin/omarchy-pkg-add"

run_installer() {
  local lspci_output=$1

  : >"$test_dir/packages"
  PATH="$test_dir/bin:$PATH" \
    LSPCI_OUTPUT="$lspci_output" \
    PACKAGE_LOG="$test_dir/packages" \
    bash "$ROOT/install/hardware/intel/video-acceleration.sh"
}

run_installer "00:02.0 VGA compatible controller: Intel Corporation Haswell-ULT Integrated Graphics Controller (rev 09)"
[[ $(<"$test_dir/packages") == "libva-intel-driver" ]] || fail "Haswell uses the legacy Intel VA-API driver"
pass "Haswell uses the legacy Intel VA-API driver"

run_installer "00:02.0 VGA compatible controller: Intel Corporation Ivy Bridge mobile GT2 [HD Graphics 4000] (rev 09)"
[[ $(<"$test_dir/packages") == "libva-intel-driver" ]] || fail "Ivy Bridge HD Graphics uses the legacy Intel VA-API driver"
pass "Ivy Bridge HD Graphics uses the legacy Intel VA-API driver"

run_installer "00:02.0 VGA compatible controller: Intel Corporation Broadwell-U GT2 [HD Graphics 5500] (rev 09)"
[[ $(<"$test_dir/packages") == "intel-media-driver libvpl vpl-gpu-rt" ]] || fail "Broadwell uses the current Intel media driver"
pass "Broadwell uses the current Intel media driver"

run_installer "00:02.0 VGA compatible controller: Intel Corporation Unknown Integrated Graphics Controller (rev 09)"
[[ ! -s $test_dir/packages ]] || fail "an unknown Intel GPU keeps the existing no-op behavior"
pass "an unknown Intel GPU keeps the existing no-op behavior"

run_installer "01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Device"
[[ ! -s $test_dir/packages ]] || fail "non-Intel graphics installs no Intel media driver"
pass "non-Intel graphics installs no Intel media driver"
