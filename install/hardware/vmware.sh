# Install the VMware guest tools on VMware guests: display resizing, host time
# sync, host-driven power operations, and shared folders. The live ISO carries
# them through Arch's releng profile, but nothing installs them on the target
# system.

if omarchy-hw-vmware; then
  omarchy-pkg-add open-vm-tools
  # Arch ships no vgauthd unit; vmtoolsd starts VGAuthService itself.
  sudo systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
fi
