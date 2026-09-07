# Sourced by t1.sh before any package or system changes. Existing installations
# need an explicit migration; unattended setup must not retire a working stack.
t1bridge_install_preflight() {
  local package path conflicts=()

  for package in libfprint libfprint-git fprintd apple-ib-drv-dkms apple-ib-drv-git apple-bce-dkms apple-bce-dkms-git; do
    if [[ $(pacman -Qq "$package" 2>/dev/null) == "$package" ]]; then
      conflicts+=("package: $package")
    fi
  done

  # Local installers often bypass pacman. Registered DKMS trees and installed
  # service/rule files also survive reboots, even if their service is idle now.
  # Backup files are deliberately excluded; they cannot activate a competitor.
  for path in \
    /var/lib/dkms/{apple-ib-drv,apple-bce,t1-touchbar-display,t1-uvc-h264} \
    /etc/udev/rules.d/{99-ibridge,99-touchbar-dfr}.rules \
    /etc/systemd/system/{dfrd,dfrd-cfgsel,touchbar-rs}.service \
    /usr/lib/systemd/system/{dfrd,dfrd-cfgsel,touchbar-rs}.service \
    /etc/systemd/user/{dfrd,touchbar-rs}.service \
    /usr/lib/systemd/user/{dfrd,touchbar-rs}.service; do
    if [[ -e $path && ! $path -ef /dev/null ]]; then
      conflicts+=("installed stack: $path")
    fi
  done

  if (( ${#conflicts[@]} > 0 )); then
    printf 'T1Bridge setup stopped before changes: an existing hardware or fingerprint stack needs migration.\n' >&2
    printf '  %s\n' "${conflicts[@]}" >&2
    printf 'Keep password authentication available. Retire the listed competing stack explicitly, reboot, then rerun hardware setup.\n' >&2
    return 1
  fi
}
