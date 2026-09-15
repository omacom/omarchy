echo "Configure USB device authorization"

rules_file="${OMARCHY_USB_AUTHORIZATION_RULES_FILE:-/etc/usbguard/rules.conf}"
daemon_config="${OMARCHY_USB_AUTHORIZATION_DAEMON_CONFIG:-/etc/usbguard/usbguard-daemon.conf}"

source "$OMARCHY_INSTALL/helpers/usb-authorization.sh"
usb_authorization_require_secure_settings "$daemon_config"

if [[ ! -s $rules_file ]]; then
  policy=$(mktemp "${TMPDIR:-/tmp}/omarchy-usb-policy.XXXXXXXXXX")
  chmod 600 "$policy"

  if usb_authorization_generate_policy "$policy"; then
    install -Dm600 -o root -g root "$policy" "$rules_file"
    rm -f "$policy"
  else
    rm -f "$policy"
    return 1
  fi
fi

if [[ -n ${OMARCHY_INSTALL_USER:-} ]]; then
  usb_authorization_add_user "$OMARCHY_INSTALL_USER"
fi

# Installs are followed by a reboot, so enable the daemon without starting it
# in the live ISO's chroot.
systemctl enable usbguard.service
