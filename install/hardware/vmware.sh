# The live ISO's guest tools do not carry over to the installed system.
if [[ $(systemd-detect-virt --vm) == "vmware" ]]; then
  omarchy-pkg-add open-vm-tools
  sudo systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
fi
