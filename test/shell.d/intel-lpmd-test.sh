#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-hw-intel" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$mock_bin/omarchy-battery-present" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$mock_bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG/pkg-add"
EOF

cat >"$mock_bin/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG/sudo"
EOF

cat >"$mock_bin/systemctl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG/systemctl"
EOF

chmod +x "$mock_bin"/*

setup_topology() {
  local dir=$1
  local model=$2
  local tdp_uw=$3
  local present=$4
  local atom=$5
  local total_cpus=$6
  local l3_max=$7

  mkdir -p "$dir/powercap/intel-rapl:0" "$dir/cpu_atom" "$dir/cpu" "$dir/lpmd" "$dir/log"
  printf 'model\t\t: %s\n' "$model" >"$dir/cpuinfo"
  printf 'package-0\n' >"$dir/powercap/intel-rapl:0/name"
  printf '%s\n' "$tdp_uw" >"$dir/powercap/intel-rapl:0/constraint_0_max_power_uw"
  printf '%s\n' "$present" >"$dir/cpu/present"
  printf '%s\n' "$atom" >"$dir/cpu_atom/cpus"

  local i
  for ((i = 0; i < total_cpus; i++)); do
    mkdir -p "$dir/cpu/cpu$i/cache"
    if ((i <= l3_max)); then
      mkdir -p "$dir/cpu/cpu$i/cache/index3"
    fi
  done
}

# 1. Panther Lake 4P8E4L-25W (16 CPUs 0-15, Atom 4-15, LP-E 12-15 without L3)
case1="$test_tmp/ptl-4p8e4l"
setup_topology "$case1" 204 25000000 "0-15" "4-15" 16 11

PATH="$mock_bin:$PATH" \
  TEST_LOG="$case1/log" \
  OMARCHY_CPUINFO_PATH="$case1/cpuinfo" \
  OMARCHY_POWERCAP_PATH="$case1/powercap" \
  OMARCHY_CPU_ATOM_PATH="$case1/cpu_atom/cpus" \
  OMARCHY_CPU_SYSFS_PATH="$case1/cpu" \
  OMARCHY_LPMD_CONF_DIR="$case1/lpmd" \
  bash -e "$ROOT/install/hardware/intel/lpmd.sh"

conf1="$case1/lpmd/intel_lpmd_config_F6_M204_T25.xml"
[[ -f $conf1 ]] || fail "Panther Lake 25W must generate intel_lpmd_config_F6_M204_T25.xml"
grep -q '<Mode>0</Mode>' "$conf1" || fail "Mode=0 must be enabled"
grep -q '<BalancedDef>0</BalancedDef>' "$conf1" || fail "BalancedDef=0 must be enabled"
grep -q '<PowersaverDef>0</PowersaverDef>' "$conf1" || fail "PowersaverDef=0 must be enabled"
grep -q '<CPUConfig> \* </CPUConfig>' "$conf1" || fail "CPUConfig wildcard must be set"
grep -q '<ActiveCPUs>12-15</ActiveCPUs>' "$conf1" || fail "4P8E4L UTIL_IDLE ActiveCPUs must be 12-15"
grep -q '<ActiveCPUs>0-15</ActiveCPUs>' "$conf1" || fail "4P8E4L non-idle ActiveCPUs must be 0-15"
if ((EUID == 0)); then
  enable_log="$case1/log/systemctl"
  enable_call="enable intel_lpmd.service"
else
  enable_log="$case1/log/sudo"
  enable_call="systemctl enable intel_lpmd.service"
fi
grep -qxF "$enable_call" "$enable_log" || fail "Install must enable intel_lpmd.service"
pass "Panther Lake 4P8E4L-25W writes T25 override with LP-E CPUs 12-15"

# 2. Panther Lake 4P4E4L-15W (12 CPUs 0-11, Atom 4-11, LP-E 8-11 without L3)
case2="$test_tmp/ptl-4p4e4l"
setup_topology "$case2" 204 15000000 "0-11" "4-11" 12 7

PATH="$mock_bin:$PATH" \
  TEST_LOG="$case2/log" \
  OMARCHY_CPUINFO_PATH="$case2/cpuinfo" \
  OMARCHY_POWERCAP_PATH="$case2/powercap" \
  OMARCHY_CPU_ATOM_PATH="$case2/cpu_atom/cpus" \
  OMARCHY_CPU_SYSFS_PATH="$case2/cpu" \
  OMARCHY_LPMD_CONF_DIR="$case2/lpmd" \
  bash -e "$ROOT/install/hardware/intel/lpmd.sh"

conf2="$case2/lpmd/intel_lpmd_config_F6_M204_T15.xml"
[[ -f $conf2 ]] || fail "Panther Lake 15W must generate intel_lpmd_config_F6_M204_T15.xml"
grep -q '<ActiveCPUs>8-11</ActiveCPUs>' "$conf2" || fail "4P4E4L UTIL_IDLE ActiveCPUs must be 8-11"
grep -q '<ActiveCPUs>0-11</ActiveCPUs>' "$conf2" || fail "4P4E4L non-idle ActiveCPUs must be 0-11"
pass "Panther Lake 4P4E4L-15W writes T15 override with LP-E CPUs 8-11"

# 3. Preserve a custom admin-authored _T25.xml without Omarchy's marker
printf '<Configuration><!-- custom --></Configuration>\n' >"$conf1"
PATH="$mock_bin:$PATH" \
  TEST_LOG="$case1/log" \
  OMARCHY_CPUINFO_PATH="$case1/cpuinfo" \
  OMARCHY_POWERCAP_PATH="$case1/powercap" \
  OMARCHY_CPU_ATOM_PATH="$case1/cpu_atom/cpus" \
  OMARCHY_CPU_SYSFS_PATH="$case1/cpu" \
  OMARCHY_LPMD_CONF_DIR="$case1/lpmd" \
  bash -e "$ROOT/install/hardware/intel/lpmd.sh"

grep -q '<!-- custom -->' "$conf1" || fail "Custom _T25.xml without Omarchy marker must be preserved"
pass "Custom admin-authored _T25.xml is preserved"

# 4. Non-Panther Lake (Meteor Lake 170) installs intel-lpmd without writing a PTL override
case4="$test_tmp/mtl"
setup_topology "$case4" 170 28000000 "0-15" "4-15" 16 11

PATH="$mock_bin:$PATH" \
  TEST_LOG="$case4/log" \
  OMARCHY_CPUINFO_PATH="$case4/cpuinfo" \
  OMARCHY_POWERCAP_PATH="$case4/powercap" \
  OMARCHY_CPU_ATOM_PATH="$case4/cpu_atom/cpus" \
  OMARCHY_CPU_SYSFS_PATH="$case4/cpu" \
  OMARCHY_LPMD_CONF_DIR="$case4/lpmd" \
  bash -e "$ROOT/install/hardware/intel/lpmd.sh"

[[ ! -e $case4/lpmd/intel_lpmd_config_F6_M204_T28.xml ]] || fail "Meteor Lake must not write a Panther Lake override"
grep -qx 'intel-lpmd' "$case4/log/pkg-add" || fail "Meteor Lake must still install intel-lpmd"
pass "Non-Panther Lake skips Panther Lake override"

# 5. Deferred queue mode on Panther Lake queues package/service and still writes override
case5="$test_tmp/ptl-defer"
setup_topology "$case5" 204 25000000 "0-15" "4-15" 16 11
pkg_queue="$case5/pkg.queue"
svc_queue="$case5/svc.queue"
: >"$pkg_queue"
: >"$svc_queue"

PATH="$mock_bin:$PATH" \
  TEST_LOG="$case5/log" \
  OMARCHY_PKG_QUEUE_FILE="$pkg_queue" \
  OMARCHY_SERVICE_QUEUE_FILE="$svc_queue" \
  OMARCHY_CPUINFO_PATH="$case5/cpuinfo" \
  OMARCHY_POWERCAP_PATH="$case5/powercap" \
  OMARCHY_CPU_ATOM_PATH="$case5/cpu_atom/cpus" \
  OMARCHY_CPU_SYSFS_PATH="$case5/cpu" \
  OMARCHY_LPMD_CONF_DIR="$case5/lpmd" \
  bash -e "$ROOT/install/hardware/intel/lpmd.sh"

grep -qx 'intel_lpmd.service' "$svc_queue" || fail "Deferred mode must queue intel_lpmd.service"
[[ -f $case5/lpmd/intel_lpmd_config_F6_M204_T25.xml ]] || fail "Deferred mode must still write Panther Lake config"
pass "Deferred install queue mode writes Panther Lake override cleanly"
