#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d) || fail "test temp directory is available"
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/lspci" <<'STUB'
#!/bin/bash
printf '00:02.0 VGA compatible controller: %s\n' "$TEST_GPU"
STUB

cat >"$fake_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
echo "$*" >"$TEST_INSTALLED"
STUB

chmod +x "$fake_bin"/*

installed_for() {
  local script=$1 gpu=$2
  rm -f "$test_tmp/installed"
  TEST_GPU=$gpu TEST_INSTALLED="$test_tmp/installed" PATH="$fake_bin:$PATH" \
    bash -euo pipefail -c 'source "$ROOT/$1"' _ "$script" >/dev/null
  if [[ -f $test_tmp/installed ]]; then
    cat "$test_tmp/installed"
  fi
}

install_script=install/hardware/intel/video-acceleration.sh
migration=migrations/1791129708.sh
media_driver="intel-media-driver libvpl vpl-gpu-rt"

for gpu in \
  "Intel Corporation Arrow Lake-U [Intel Graphics] (rev 04)" \
  "Intel Corporation Wildcat Lake [Intel Graphics] (rev 01)" \
  "Intel Corporation Meteor Lake-P [Intel Graphics] (rev 08)" \
  "Intel Corporation Lunar Lake [Intel Graphics] (rev 04)" \
  "Intel Corporation Raptor Lake-P [Intel Graphics] (rev 04)" \
  "Intel Corporation Alder Lake-N [Intel Graphics]" \
  "Intel Corporation Battlemage G21 [Intel Graphics]"; do
  [[ $(installed_for "$install_script" "$gpu") == "$media_driver" ]] || fail "install adds intel-media-driver for $gpu"
  [[ $(installed_for "$migration" "$gpu") == "$media_driver" ]] || fail "migration adds intel-media-driver for $gpu"
done
pass "install and migration add intel-media-driver for GPUs named only [Intel Graphics]"

for gpu in \
  "Intel Corporation Alder Lake-P GT2 [Iris Xe Graphics] (rev 0c)" \
  "Intel Corporation CometLake-U GT2 [UHD Graphics] (rev 02)"; do
  [[ $(installed_for "$install_script" "$gpu") == "$media_driver" ]] || fail "install adds intel-media-driver for $gpu"
done
pass "install still adds intel-media-driver for branded Gen8+ GPUs"

gma="Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller (rev 07) [GMA 4500MHD]"
[[ $(installed_for "$install_script" "$gma") == "libva-intel-driver" ]] || fail "install adds libva-intel-driver for GMA"
[[ -z $(installed_for "$migration" "$gma") ]] || fail "migration leaves GMA alone"
pass "GMA GPUs keep libva-intel-driver"

amd="Advanced Micro Devices, Inc. [AMD/ATI] Phoenix1 (rev c1)"
[[ -z $(installed_for "$install_script" "$amd") ]] || fail "install adds nothing without an Intel GPU"
[[ -z $(installed_for "$migration" "$amd") ]] || fail "migration adds nothing without an Intel GPU"
pass "nothing is installed without an Intel GPU"
