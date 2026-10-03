if omarchy-hw-dell-xps13-dx13260-ptl; then
  cirrus_package=$(pacman -Q linux-firmware-cirrus 2>/dev/null || true)

  # Keep newer Arch firmware when stable's snapshot supersedes the shim.
  if [[ -z $cirrus_package ]] || (( $(vercmp "${cirrus_package#* }" "20260810-3") < 0 )); then
    firmware_pending="/run/omarchy/xps13-ptl-speaker-firmware"
    sudo install -Dm644 /dev/null "$firmware_pending"

    # omarchy-pkg-add skips installed packages and cannot verify repo-qualified targets.
    # Select [omarchy] explicitly because [core] carries the older firmware.
    sudo pacman -S --noconfirm --needed omarchy/linux-firmware-cirrus
  fi
fi
