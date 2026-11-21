#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix_script="$ROOT/install/hardware/fix-bcm43xx.sh"

# Run the installer against a stubbed lspci. Grepping the script for a PCI ID
# stays green if that ID is only left behind in a comment.
run_fix() {
  local pci_line="$1"
  local tmp="$2"
  local calls="$tmp/calls.log"
  local stub="$tmp/bin"
  local script="$tmp/fix-bcm43xx.sh"

  mkdir -p "$stub"
  : >"$calls"

  cat >"$stub/lspci" <<SH
#!/bin/bash

echo '$pci_line'
SH

  cat >"$stub/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

  chmod +x "$stub"/*

  sed -e "s|/etc/modprobe.d|$tmp/etc/modprobe.d|g" "$fix_script" >"$script"

  PATH="$stub:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_INSTALL="$ROOT/install" \
    bash -euo pipefail "$script" >/dev/null
}

expect_wl() {
  local id="$1"
  local name="$2"
  local tmp
  tmp=$(mktemp -d)

  run_fix "02:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries $name [$id] (rev 01)" "$tmp"

  grep -qx $'omarchy-pkg-add\tbroadcom-wl-dkms' "$tmp/calls.log" || \
    fail "$name ($id) installs broadcom-wl-dkms"
  pass "$name ($id) installs broadcom-wl-dkms"

  [[ $(wc -l <"$tmp/calls.log") -eq 1 ]] || \
    fail "$name ($id) installs broadcom-wl-dkms and nothing else"
  pass "$name ($id) installs broadcom-wl-dkms and nothing else"

  [[ ! -d "$tmp/etc/modprobe.d" ]] || \
    fail "$name ($id) leaves blacklisting to broadcom-wl-dkms"
  pass "$name ($id) leaves blacklisting to broadcom-wl-dkms"

  rm -rf "$tmp"
}

expect_skip() {
  local pci_line="$1"
  local label="$2"
  local tmp
  tmp=$(mktemp -d)

  run_fix "$pci_line" "$tmp"

  [[ ! -s $tmp/calls.log ]] || fail "$label skips driver installation"
  pass "$label skips driver installation"

  [[ ! -d "$tmp/etc/modprobe.d" ]] || fail "$label writes no modprobe config"
  pass "$label writes no modprobe config"

  rm -rf "$tmp"
}

expect_wl "14e4:43a0" "BCM4360"
expect_wl "14e4:4331" "BCM4331"
expect_wl "14e4:4353" "BCM43224"

expect_skip "02:00.0 Network controller [0280]: Intel Corporation Wi-Fi 6 AX201 [8086:06f0] (rev 01)" \
  "non-Broadcom hardware"
