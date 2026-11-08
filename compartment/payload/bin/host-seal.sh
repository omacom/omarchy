#!/bin/bash
# host-seal.sh — Wazuh active response ON THE HOST.
# On a high-severity agent alert for a compartment VM: destroy the VM,
# quarantine its whonix-int presence, log to the git ledger.
# Args (Wazuh AR convention): host-seal.sh - <vm-name>  or  host-seal.sh <vm-name>
set -u
VM="${2:-${1:-}}"
[ -n "$VM" ] || exit 2
# only ever act on our compartments
case "$VM" in
  hermes-*|Whonix-Crypto|Whonix-Workstation) ;;
  *) echo "host-seal: refusing non-compartment target '$VM'" >&2; exit 2 ;;
esac

LOG=/var/log/host-seal.log
echo "$(date -Is) sealing $VM" >> "$LOG"

virsh -c qemu:///system destroy "$VM" >> "$LOG" 2>&1 || true
nft add rule inet filter forward ip saddr 10.152.152.0/24 ip daddr 10.152.152.0/24 drop 2>>"$LOG" || true

# forensic delta (best-effort, non-blocking)
virt-diff -a "/var/lib/libvirt/images/whonix/$VM.qcow2" >> "$LOG" 2>&1 || true

cd "${COMPARTMENT_LEDGER:-/var/lib/omarchy-compartment/ledger}" 2>/dev/null && {
  echo "$(date -Is)	$VM	seal	host-ar" >> ledger.log
  git add ledger.log && git commit -qm "seal $VM" >/dev/null 2>&1
}
exit 0
