#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
thunderbolt_conf="$ROOT/etc/mkinitcpio.conf.d/thunderbolt_module.conf"
late_conf="$ROOT/install/hardware/nvidia-no-early-load.conf"
migration="$ROOT/migrations/1791210803.sh"

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

# Concatenate the drop-ins in mkinitcpio's sort -V order and print HOOKS and
# MODULES. The late file must run after omarchy_hooks.conf has seen nvidia_drm.
resolved() {
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" bash -uc "
    MODULES=()
    HOOKS=()
    FILES=()
    XKBLAYOUT=us
    source '$tmp_dir/nvidia.conf'
    source '$hooks_conf'
    source '$thunderbolt_conf'
    source '$late_conf'
    echo \"HOOKS=\${HOOKS[*]}\"
    echo \"MODULES=\${MODULES[*]}\"
  "
}

printf '%s\n' 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' >"$tmp_dir/nvidia.conf"

write_pci_devices 0x10de:0x030000
nvidia_only=$(resolved)
[[ $nvidia_only == *"HOOKS="* && $nvidia_only != *" kms "* ]] ||
  fail "NVIDIA-only machine drops kms" "$nvidia_only"
[[ $nvidia_only == "MODULES=thunderbolt" || $nvidia_only == *$'\n'"MODULES=thunderbolt" ]] ||
  fail "NVIDIA-only machine does not keep NVIDIA modules" "$nvidia_only"
pass "NVIDIA-only machine drops kms and the NVIDIA modules"

write_pci_devices 0x8086:0x030000 0x10de:0x030000
hybrid=$(resolved)
[[ $hybrid == *" kms "* ]] ||
  fail "hybrid machine keeps kms" "$hybrid"
[[ $hybrid == *$'\n'"MODULES=thunderbolt" ]] ||
  fail "hybrid machine does not keep NVIDIA modules" "$hybrid"
pass "hybrid machine keeps kms and drops the NVIDIA modules"

bash -uc "
  source '$late_conf'
  [[ \${MODULES[*]:-} == '' ]]
" || fail "late drop-in survives unset MODULES under set -u"
pass "late drop-in survives unset MODULES under set -u"

# Migration: rebuild once when an NVIDIA install is present, and no-op after.
stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin" "$tmp_dir/etc" "$tmp_dir/marker-dir" "$tmp_dir/state"
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH
chmod 755 "$stub_bin/sudo" "$stub_bin/omarchy-cmd-present"
printf '%s\n' 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' >"$tmp_dir/etc/nvidia.conf"

run_migration() {
  PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_MKINITCPIO_NVIDIA_CONF="$tmp_dir/etc/nvidia.conf" \
    OMARCHY_NVIDIA_NO_EARLY_LOAD_CONF="$tmp_dir/etc/zz-nvidia-no-early-load.conf" \
    OMARCHY_NVIDIA_HIBERNATE_REBUILD_MARKER="$tmp_dir/marker-dir/1791210803" \
    bash -euo pipefail "$migration"
}

calls="$tmp_dir/calls"
cat >"$stub_bin/limine-mkinitcpio" <<SH
#!/bin/bash
printf '%s\n' limine-mkinitcpio >>'$calls'
SH
chmod 755 "$stub_bin/limine-mkinitcpio"

run_migration
[[ -f $tmp_dir/etc/zz-nvidia-no-early-load.conf ]] || fail "migration installs the late drop-in"
cmp -s "$late_conf" "$tmp_dir/etc/zz-nvidia-no-early-load.conf" ||
  fail "migration installs the packaged drop-in unchanged"
[[ -f $tmp_dir/marker-dir/1791210803 ]] || fail "migration records the rebuild"
[[ $(grep -c . "$calls") == 1 ]] || fail "migration rebuilds the boot image once" "$(cat "$calls")"
pass "migration installs the drop-in and rebuilds once"

: >"$calls"
run_migration
[[ ! -s $calls ]] || fail "migration does not rebuild again" "$(cat "$calls")"
pass "migration does not rebuild again"
