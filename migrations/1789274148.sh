echo "Remove the MacBook NVMe suspend fix from 15-inch MacBook Pros, where it disabled D3cold on the GPU"

# install/hardware/apple/fix-suspend-nvme.sh used to match MacBookPro13,3 and 14,3 too. Those
# models put the AMD GPU at 0000:01:00.0 and the NVMe drive at 02:00.0, so the service turned
# off D3cold for the GPU and never touched the drive. The leaf now only applies the fix where
# Apple's NVMe controller sits at 01:00.0; this removes the service everywhere it does not.
unit="${OMARCHY_NVME_SUSPEND_UNIT:-/etc/systemd/system/omarchy-nvme-suspend-fix.service}"
pci_vendor="${OMARCHY_NVME_SUSPEND_PCI_VENDOR:-/sys/bus/pci/devices/0000:01:00.0/vendor}"

[[ -e $unit || -L $unit ]] || exit 0
vendor=$(cat "$pci_vendor" 2>/dev/null || true)
if [[ ! $vendor =~ ^0x[0-9a-fA-F]{4}$ ]]; then
  echo "Cannot read the PCI vendor; preserving $unit and leaving this migration pending." >&2
  exit 1
fi
[[ $vendor != "0x106b" ]] || exit 0

if [[ -e $unit || -L $unit ]]; then
  if [[ -L $unit || ! -f $unit ]] ||
    [[ $(sha256sum "$unit" | cut -d ' ' -f1) != 7dcd24e421986f79b6f9c51b3165443752953364e4355af8e76baa1329b0d61c &&
       $(sha256sum "$unit" | cut -d ' ' -f1) != 9c4a9bd9cb1d296af737deaedca110ac1d009d226f623b07432a7793929a1dab ]]; then
    echo "Preserving customized NVMe suspend unit: $unit; reconcile it manually before retrying." >&2
    exit 1
  fi
fi

sudo systemctl disable omarchy-nvme-suspend-fix.service
sudo rm -f "$unit"
sudo systemctl daemon-reload
