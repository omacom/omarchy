# The guest utilities are available from Arch's x86_64 repositories. Detect
# the hypervisor, not the SVGA adapter that VMware and VirtualBox can share.
if omarchy-hw-x86 && omarchy-hw-virtualbox; then
  omarchy-pkg-add virtualbox-guest-utils || return 1
  sudo systemctl enable vboxservice.service

  # Image hardware setup runs on the guest's first boot, after systemd has
  # already queued its targets. Enabling alone would miss that first session.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sudo systemctl start --no-block vboxservice.service
  fi
fi
