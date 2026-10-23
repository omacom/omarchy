#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

windows_vm_command="$ROOT/bin/omarchy-windows-vm"

rg -q '^    restart: "no"$' "$windows_vm_command" ||
  fail "Windows VM uses manual startup by default"
pass "Windows VM uses manual startup by default"

if rg -q '^    restart: unless-stopped$' "$windows_vm_command"; then
  fail "Windows VM does not restart automatically at boot"
fi
pass "Windows VM does not restart automatically at boot"

# Tolerate either shell quoting of the argument.
rg -q 'title:"?Windows VM - Omarchy"' "$windows_vm_command" ||
  fail "Windows VM launches FreeRDP with its expected title"
pass "Windows VM launches FreeRDP with its expected title"
rg -q 'while true; do' "$windows_vm_command" ||
  fail "Windows VM retries failed RDP credentials"
rg -q 'RDP login failed\. Enter the Windows credentials again\.' "$windows_vm_command" ||
  fail "Windows VM prompts again after an RDP login failure"
rg -q 'write_credentials "\$WIN_USER" "\$WIN_PASS"' "$windows_vm_command" ||
  fail "Windows VM saves re-entered RDP credentials"
pass "Windows VM retries failed RDP credentials"
