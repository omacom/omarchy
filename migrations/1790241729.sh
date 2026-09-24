echo "Install VMware guest tools on existing VMware systems"

if [[ $(systemd-detect-virt --vm) == "vmware" ]]; then
  omarchy-pkg-add open-vm-tools
  sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service
fi
