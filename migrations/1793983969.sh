echo "Install and start VirtualBox guest utilities on x86 VirtualBox guests"

if omarchy-hw-x86 && omarchy-hw-virtualbox; then
  omarchy-pkg-add virtualbox-guest-utils
  sudo systemctl enable --now vboxservice.service
fi
