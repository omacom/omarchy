#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for package in cups cups-filters system-config-printer cups-pk-helper; do
  pacman -Q "$package" >/dev/null 2>&1 || fail "printing packages are installed" "$package is missing"
done
pass "printing packages are installed"

! pacman -Q cups-pdf >/dev/null 2>&1 || fail "the root CUPS-PDF backend is absent"
pass "the root CUPS-PDF backend is absent"

! pacman -Q cups-browsed >/dev/null 2>&1 || fail "automatic printer discovery is absent"
! systemctl is-enabled --quiet cups-browsed.service 2>/dev/null ||
  fail "automatic printer discovery is not enabled"
! systemctl is-active --quiet cups-browsed.service 2>/dev/null ||
  fail "automatic printer discovery is not running"
! pgrep -x cups-browsed >/dev/null 2>&1 || fail "no cups-browsed process exists"
pass "automatic printer discovery is not installed or running"

for path in \
  /etc/cups/cups-browsed.conf \
  /etc/cups/cups-browsed.conf.pacsave \
  /etc/cups/cups-browsed.conf.pacnew \
  /usr/bin/cups-browsed \
  /usr/lib/cups/backend/implicitclass \
  /usr/lib/systemd/system/cups-browsed.service \
  /etc/systemd/system/multi-user.target.wants/cups-browsed.service; do
  [[ ! -e $path && ! -L $path ]] ||
    fail "automatic printer discovery leaves no package files" "$path still exists"
done
pass "automatic printer discovery leaves no package files"

! systemctl is-enabled --quiet cups.service 2>/dev/null ||
  fail "CUPS service is not eagerly enabled at boot"
systemctl is-enabled --quiet cups.socket || fail "CUPS socket is enabled"
systemctl is-enabled --quiet cups.path || fail "CUPS path is enabled"
systemctl is-active --quiet cups.socket || fail "CUPS socket is listening"
if systemctl is-active --quiet cups.service 2>/dev/null && sudo -n true 2>/dev/null; then
  sudo -n systemctl stop cups.service
  sudo -n systemctl start cups.socket
  ! systemctl is-active --quiet cups.service 2>/dev/null ||
    fail "CUPS stays inactive until a client connects"
fi
[[ $(LC_ALL=C timeout 10 lpstat -r 2>&1) == "scheduler is running" ]] ||
  fail "the CUPS scheduler answers on demand"
systemctl is-active --quiet cups.service || fail "CUPS activates on demand"
pass "CUPS is socket-activated and answers on demand"

policy_metadata=$(stat -c '%U:%G %a' /etc/cups/cups-files.conf)
[[ $policy_metadata == "root:cups 640" ]] ||
  fail "the CUPS authorization policy is protected" "$policy_metadata"
pass "the CUPS authorization policy is protected"

if lpinfo_output=$(LC_ALL=C timeout 10 lpinfo -v </dev/null 2>&1); then
  fail "the desktop user cannot administer CUPS without authentication"
elif [[ $lpinfo_output != *"Forbidden"* ]]; then
  fail "CUPS explicitly denies unauthenticated desktop administration" "$lpinfo_output"
fi
pass "CUPS denies unauthenticated desktop administration"
