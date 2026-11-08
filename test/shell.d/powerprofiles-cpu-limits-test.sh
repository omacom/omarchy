#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

# Any SMU access goes through setpci; record it so the guard can be checked.
cat >"$tmp_dir/bin/setpci" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$SETPCI_LOG"
EOF
chmod +x "$tmp_dir/bin/setpci"

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export SETPCI_LOG="$tmp_dir/setpci.log"

cpuinfo() {
  printf 'processor\t: 0\nvendor_id\t: %s\ncpu family\t: %s\nmodel\t\t: %s\nmodel name\t: Test CPU\n' "$1" "$2" "$3" >"$tmp_dir/cpuinfo"
  # A second processor block with other values must not change the answer.
  printf 'processor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 24\n' >>"$tmp_dir/cpuinfo"
}

raven() {
  OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" "$ROOT/bin/omarchy-hw-amd-raven"
}

for model in 17 24 32; do
  cpuinfo AuthenticAMD 23 "$model"
  raven || fail "family 17h model $model is a Raven-family APU"
done
pass "Raven Ridge, Picasso and Dali are detected"

cpuinfo AuthenticAMD 23 96
raven && fail "Renoir (family 17h model 60h) uses another SMU layout"
cpuinfo AuthenticAMD 25 24
raven && fail "family 19h is not Raven-family"
cpuinfo GenuineIntel 23 24
raven && fail "an Intel CPU is not Raven-family"
pass "other CPUs are not detected as Raven-family"

cpuinfo AuthenticAMD 23 96
for action in apply status; do
  OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" "$ROOT/bin/omarchy-powerprofiles-cpu-limits" "$action" >/dev/null ||
    fail "cpu-limits $action exits cleanly on an unsupported CPU"
done
[[ ! -e $SETPCI_LOG ]] || fail "cpu-limits never touches PCI config space on an unsupported CPU"
pass "cpu-limits is a no-op on unsupported CPUs"
