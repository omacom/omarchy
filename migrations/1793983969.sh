echo "Install and start VirtualBox guest utilities on x86 VirtualBox guests"

if omarchy-hw-x86 && omarchy-hw-virtualbox; then
  if ! omarchy-pkg-present virtualbox-guest-utils-nox; then
    omarchy-pkg-add virtualbox-guest-utils
  fi
  sudo systemctl enable --now vboxservice.service
fi
