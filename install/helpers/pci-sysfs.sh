# Detect PCI devices from cached sysfs fields instead of lspci.
#
# lspci reads PCI config space, and the kernel resumes a runtime-suspended
# device to serve that read. On a hybrid laptop the discrete GPU idles in
# D3cold, so a bare lspci can take over a second waking it. The vendor, device,
# class, and subsystem IDs are served from cached sysfs fields that never touch
# config space, so nothing wakes.
#
# Each matcher walks /sys/bus/pci/devices once and returns 0 on the first match.
# Tests point OMARCHY_PCI_DEVICES_PATH at a fixture tree of the same layout.

# Point the helpers at a fixture tree instead of the real sysfs in tests.
: "${OMARCHY_PCI_DEVICES_PATH:=/sys/bus/pci/devices}"

# Each matcher walks the devices dir once and returns 0 on the first match.
shopt -s nullglob

# First argument is a vendor ID; the remaining arguments are device IDs for that
# vendor to accept. Returns 0 if any device carries both.
omarchy-pci-id() {
  local vendor="$1"
  shift
  local device id
  for device in "$OMARCHY_PCI_DEVICES_PATH"/*; do
    [[ $(<"$device/vendor") == "$vendor" ]] || continue
    for id in "$@"; do
      [[ $(<"$device/device") == "$id" ]] && return 0
    done
  done
  return 1
}

# First argument is a class prefix (e.g. 0x03 for a display controller); the
# second is a vendor ID. Returns 0 if any device's class begins with the prefix
# and its vendor matches.
omarchy-pci-class-vendor() {
  local class="$1" vendor="$2"
  local device
  for device in "$OMARCHY_PCI_DEVICES_PATH"/*; do
    [[ $(<"$device/class") == "${class}"* && $(<"$device/vendor") == "$vendor" ]] && return 0
  done
  return 1
}

# First argument is a class prefix. Prints how many devices have a class that
# begins with it, regardless of vendor; for aggregation and count checks where
# a boolean matcher is not enough.
omarchy-pci-class-count() {
  local class="$1"
  local device
  local count=0
  for device in "$OMARCHY_PCI_DEVICES_PATH"/*; do
    [[ $(<"$device/class") == "${class}"* ]] && count=$((count + 1))
  done
  printf '%s\n' "$count"
}

# Returns 0 if any device is bound to the named driver, read from the bound
# driver symlink.
omarchy-pci-driver() {
  local driver="$1"
  local device bound
  for device in "$OMARCHY_PCI_DEVICES_PATH"/*; do
    [[ -L $device/driver ]] || continue
    bound="$(readlink "$device/driver")"
    [[ ${bound##*/} == "$driver" ]] && return 0
  done
  return 1
}
