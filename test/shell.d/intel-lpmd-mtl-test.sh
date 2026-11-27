#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

for cmd in omarchy-hw-intel omarchy-battery-present; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$cmd"
done
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_PKG_CALLS"
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_SUDO_CALLS"
SH
chmod +x "$stub_bin"/*

run_lpmd_leaf() {
  local model=$1 conf_dir=$2 unit_dir=$3
  shift 3
  local cpuinfo="$test_tmp/cpuinfo-$model"
  printf 'processor\t: 0\nmodel\t\t: %s\n' "$model" >"$cpuinfo"
  env "$@" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_CPUINFO_PATH="$cpuinfo" \
    OMARCHY_INTEL_LPMD_CONF_DIR="$conf_dir" \
    OMARCHY_INTEL_LPMD_UNIT_DIR="$unit_dir" \
    TEST_PKG_CALLS="$test_tmp/pkg-calls" \
    TEST_SUDO_CALLS="$test_tmp/sudo-calls" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/intel/lpmd.sh"
}

# Meteor Lake (model 170) installs the MTL config and systemd override even when
# package installation is deferred during hardware setup.
mtl_conf="$test_tmp/mtl-conf"
mtl_unit="$test_tmp/mtl-unit"
pkg_q="$test_tmp/pkg-queue"
svc_q="$test_tmp/svc-queue"
: >"$pkg_q"
: >"$svc_q"

run_lpmd_leaf 170 "$mtl_conf" "$mtl_unit" \
  OMARCHY_PKG_QUEUE_FILE="$pkg_q" OMARCHY_SERVICE_QUEUE_FILE="$svc_q"

[[ -s $mtl_conf/omarchy-mtl.xml ]] || fail "Meteor Lake writes omarchy-mtl.xml"
[[ -s $mtl_unit/10-omarchy-mtl.conf ]] || fail "Meteor Lake writes 10-omarchy-mtl.conf"
grep -qxF 'intel_lpmd.service' "$svc_q" || fail "Meteor Lake queues intel_lpmd.service when deferred"
pass "Meteor Lake (model 170) writes the MTL config and service override in deferred mode"

# Panther Lake (model 204) installs intel-lpmd without writing the MTL override.
ptl_conf="$test_tmp/ptl-conf"
ptl_unit="$test_tmp/ptl-unit"
rm -f "$test_tmp/pkg-calls" "$test_tmp/sudo-calls"

run_lpmd_leaf 204 "$ptl_conf" "$ptl_unit"
[[ ! -e $ptl_conf/omarchy-mtl.xml ]] || fail "Panther Lake must not write omarchy-mtl.xml"
[[ ! -e $ptl_unit/10-omarchy-mtl.conf ]] || fail "Panther Lake must not write MTL systemd drop-in"
grep -qxF 'intel-lpmd' "$test_tmp/pkg-calls" || fail "Panther Lake still installs intel-lpmd"
grep -qxF 'systemctl enable intel_lpmd.service' "$test_tmp/sudo-calls" || fail "Panther Lake enables intel_lpmd.service"
pass "non-Meteor Lake hybrid CPUs skip the MTL override"
