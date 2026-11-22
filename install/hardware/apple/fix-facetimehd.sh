# Broadcom 720p FaceTime HD (PCI 14e4:1570) on Intel Macs. There is no in-tree driver, and Apple's license forbids
# redistributing the camera's firmware, so facetimehd-firmware-fetcher downloads it from Apple on the Mac itself.

if omarchy-hw-facetimehd; then
  echo "Detected FaceTime HD camera"

  # pacman -T resolves provides, so a Mac already running an AUR driver or firmware keeps it rather than conflicting.
  packages=()
  pacman -T facetimehd-dkms >/dev/null || pacman -T bcwc-pcie >/dev/null ||
    pacman -T bcwc-pcie-dkms >/dev/null || packages+=(facetimehd-dkms)
  pacman -T facetimehd-firmware >/dev/null || pacman -T bcwc-pcie-firmware >/dev/null ||
    packages+=(facetimehd-firmware-fetcher)
  (( ${#packages[@]} == 0 )) || omarchy-pkg-add "${packages[@]}"

  # An install with no network fetches on the first boot that has one.
  if pacman -Q facetimehd-firmware-fetcher &>/dev/null; then
    sudo systemctl enable facetimehd-firmware-fetcher.service

    # An image's first boot runs this after boot queued its units, so the fetch starts now rather than at the next boot.
    if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
      sudo systemctl start --no-block facetimehd-firmware-fetcher.service || true
    fi
  fi

  # Whichever package provides the driver, it hangs hibernation, so every hibernating sleep is guarded.
  for unit in systemd-hibernate systemd-hybrid-sleep systemd-suspend-then-hibernate; do
    sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-facetimehd-hibernate.conf" \
      "/etc/systemd/system/$unit.service.d/omarchy-facetimehd.conf"
  done
  sudo systemctl daemon-reload
fi
