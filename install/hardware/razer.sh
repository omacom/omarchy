# Install OpenRazer on Razer laptops so the keyboard lighting follows the theme.

if omarchy-hw-razer; then
  # linux-omarchy ships the modules prebuilt and signed with the kernel's own
  # key. Any other installed kernel has them built through DKMS.
  if omarchy-pkg-present linux-omarchy && omarchy-pkg-missing openrazer-driver-dkms &&
    [[ $(cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u) == "linux-omarchy" ]]; then
    omarchy-pkg-add linux-omarchy-openrazer openrazer-driver
  else
    omarchy-pkg-add openrazer-driver-dkms
  fi

  # Only the openrazer group may write the lighting controls.
  if [[ -n ${OMARCHY_INSTALL_USER:-} ]]; then
    usermod -aG openrazer "$OMARCHY_INSTALL_USER"
  else
    mkdir -p /var/lib/omarchy/provisioning
    grep -qxF openrazer /var/lib/omarchy/provisioning/groups 2>/dev/null || echo openrazer >>/var/lib/omarchy/provisioning/groups
  fi
fi
