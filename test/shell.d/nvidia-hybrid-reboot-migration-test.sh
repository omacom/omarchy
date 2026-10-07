#!/bin/bash

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790282866.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/omarchy-state" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$STATE_LOG"
SH
chmod +x "$tmp_dir/bin/omarchy-state"

# Each argument is a PCI device as "vendor:class:boot_vga", in sysfs's own format.
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "$(cut -d: -f1 <<<"$spec")" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$tmp_dir/devices/$slot/class"
    printf '%s\n' "$(cut -d: -f3 <<<"$spec")" >"$tmp_dir/devices/$slot/boot_vga"
    index=$((index + 1))
  done
}

assert_reboot() {
  local description="$1" expected="$2"

  : >"$tmp_dir/state.log"
  PATH="$tmp_dir/bin:$ROOT/bin:$PATH" STATE_LOG="$tmp_dir/state.log" \
    OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" bash "$migration" >/dev/null ||
    fail "$description" "migration exited non-zero"

  local actual=no
  [[ $(< "$tmp_dir/state.log") == "set reboot-required" ]] && actual=yes

  [[ $actual == "$expected" ]] ||
    fail "$description" "reboot requested: expected $expected, got $actual"

  pass "$description"
}

write_pci_devices 0x1002:0x030000:1 0x10de:0x030000:0
assert_reboot "a hybrid laptop with an iGPU display asks for a reboot" yes

write_pci_devices 0x10de:0x030000:1
assert_reboot "an NVIDIA-only machine is left alone" no

write_pci_devices 0x1002:0x030000:1
assert_reboot "a machine without NVIDIA is left alone" no
