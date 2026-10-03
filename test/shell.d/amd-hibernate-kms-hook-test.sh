#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
# fix typo - use tmp_dir consistently
trap 'rm -rf "$tmp_dir"' EXIT

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
resume_conf="$tmp_dir/omarchy_resume.conf"

write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "${spec##*:}" >"$tmp_dir/devices/$slot/class"
    index=$((index + 1))
  done
}

resolved_hooks() {
  local resume_state=$1
  local modules_decl=""
  [[ ${2:-} == "unset" ]] || modules_decl="MODULES=(${2:-})"

  if [[ $resume_state == "yes" ]]; then
    printf 'HOOKS+=(resume)\n' >"$resume_conf"
  else
    rm -f "$resume_conf"
  fi

  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" \
    OMARCHY_RESUME_CONF="$resume_conf" bash -uc "
      FILES=()
      XKBLAYOUT=us
      $modules_decl
      source '$hooks_conf'
      echo \"\${HOOKS[*]}\"
    "
}

write_pci_devices
with_kms=$(resolved_hooks no)
without_kms=${with_kms/ kms / }

[[ $with_kms == *" kms "* ]] ||
  fail "baseline HOOKS contains the kms hook" "actual: $with_kms"
pass "baseline HOOKS contains the kms hook"

assert_hooks() {
  local description="$1" resume="$2" pci="$3" expected="$4"
  write_pci_devices $pci
  local actual
  actual=$(resolved_hooks "$resume")

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# AMD Navi 22 dGPU only, hibernation configured — drop kms (#13395).
assert_hooks "AMD-only hibernation drops kms" yes "0x1002:0x030000" "$without_kms"

# Same AMD GPU without hibernation keeps kms for early modeset.
assert_hooks "AMD-only without hibernation keeps kms" no "0x1002:0x030000" "$with_kms"

# Raphael iGPU + Navi dGPU are both AMD — still drop when hibernating.
assert_hooks "dual-AMD hibernation drops kms" yes "0x1002:0x030000 0x1002:0x030000" "$without_kms"

# AMD + Intel hybrid keeps kms for the iGPU LUKS prompt.
assert_hooks "AMD+Intel hibernation keeps kms" yes "0x1002:0x030000 0x8086:0x030000" "$with_kms"

# No resume drop-in means hibernation is not configured.
assert_hooks "AMD without resume conf keeps kms" no "0x1002:0x030000" "$with_kms"

# Resume conf present but wrong contents must not drop kms.
printf 'HOOKS+=(something-else)\n' >"$resume_conf"
write_pci_devices 0x1002:0x030000
actual=$(OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_RESUME_CONF="$resume_conf" bash -uc "
  FILES=()
  XKBLAYOUT=us
  MODULES=()
  source '$hooks_conf'
  echo \"\${HOOKS[*]}\"
")
[[ $actual == "$with_kms" ]] ||
  fail "non-resume HOOKS drop-in must not drop kms" "actual: $actual"
pass "non-resume HOOKS drop-in keeps kms"
