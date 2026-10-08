#!/bin/bash

# Package-backed deployment only. Never install a privileged service from a
# mutable user checkout or a /usr/bin symlink that resolves into one.
set -euo pipefail
export PATH=/usr/bin:/bin

trusted_path() {
  local path owner mode
  path=$1
  while [[ $path != "/" ]]; do
    [[ ! -L $path ]] || return 1
    read -r owner mode < <(stat -c '%u %a' -- "$path") || return 1
    [[ $owner == "0" ]] && (( (8#$mode & 0022) == 0 )) || return 1
    path=${path%/*}
    [[ -n $path ]] || path=/
  done
}

guard=/usr/bin/omarchy-battery-guard
helper=/usr/share/omarchy/default/battery-guard/close-windows
unit=/usr/share/omarchy/default/systemd/system/omarchy-battery-guard.service
# migrations/1790872998.sh skips the optional guard on this status rather than
# retrying, since package files that are not root-owned do not fix themselves.
untrusted=78
for source in "$guard" "$helper" "$unit"; do
  if [[ ! -e $source && ! -L $source ]]; then
    echo "Battery guard requires current Omarchy packages: $source is missing" >&2
    exit 1
  elif ! trusted_path "$source"; then
    echo "Battery guard requires root-owned Omarchy packages: $source" >&2
    exit "$untrusted"
  fi
done

if [[ ${1:-} == "--restart" ]] &&
  sha256sum --check --status /etc/systemd/system/omarchy-battery-guard.service.sha256 2>/dev/null &&
  cmp -s "$unit" /etc/systemd/system/omarchy-battery-guard.service &&
  systemctl is-enabled --quiet omarchy-battery-guard.service &&
  systemctl is-active --quiet omarchy-battery-guard.service; then
  exit 0
fi

# Executables remain package-owned. Only the enabled unit and a checksum record
# live under /etc; the record detects payload updates without copying binaries.
if ! trusted_path /etc/systemd/system; then
  echo "Battery guard requires a root-owned /etc/systemd/system" >&2
  exit "$untrusted"
fi
for target in /etc/systemd/system/omarchy-battery-guard.service.new /etc/systemd/system/omarchy-battery-guard.service.sha256.new; do
  if [[ -L $target ]]; then
    echo "Battery guard will not write through the symlink $target" >&2
    exit "$untrusted"
  fi
done
# Replace the original linked unit without writing through its symlink.
install -o root -g root -m 0644 "$unit" /etc/systemd/system/omarchy-battery-guard.service.new
mv -fT /etc/systemd/system/omarchy-battery-guard.service.new /etc/systemd/system/omarchy-battery-guard.service
if [[ ${1:-} == "--restart" ]]; then
  systemctl daemon-reload
  systemctl enable omarchy-battery-guard.service
  systemctl restart omarchy-battery-guard.service
  systemctl is-active --quiet omarchy-battery-guard.service
else
  systemctl enable omarchy-battery-guard.service
fi
sha256sum "$guard" "$helper" "$unit" > /etc/systemd/system/omarchy-battery-guard.service.sha256.new
chmod 0644 /etc/systemd/system/omarchy-battery-guard.service.sha256.new
mv -fT /etc/systemd/system/omarchy-battery-guard.service.sha256.new /etc/systemd/system/omarchy-battery-guard.service.sha256
