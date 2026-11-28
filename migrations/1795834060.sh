echo "Replace Plymouth with the Omarchy boot splash, and SDDM with greetd's login screen"

# omarchy-settings ships the splash, and the login screen greetd runs from
# below, and can land after the omarchy package carrying this migration.
if [[ ! -e /etc/initcpio/install/omarchy-splash ]]; then
  echo "Waiting for omarchy-settings with the Omarchy boot splash and login screen"
  exit 75
fi

# The splash is untested with systemd-boot, whether the machine boots it or is
# switching to it (etc/initcpio/install/omarchy-splash): stop before changing
# anything.
if omarchy-boot-backend --managed | grep -qx systemd-boot; then
  echo "The Omarchy boot splash does not support systemd-boot yet" >&2
  exit 1
fi

# The boot splash's runtime and patched wlroots, beside Quickshell, and the
# login screen's daemon. These ship together in the Omarchy package update.
omarchy-pkg-add sway seatd wlroots0.20 greetd

# greetd takes over as the display manager, signing in whoever SDDM did and
# keeping its permanent autologin. Enable its alias before disabling SDDM:
# a failed enable leaves SDDM intact, and a retry after the switch is harmless.
# Neither daemon is stopped, so this session keeps working until the next boot.
if systemctl is-enabled --quiet sddm.service 2>/dev/null; then
  sudo omarchy-system-login --from-sddm
  sudo systemctl enable --force greetd.service
  sudo systemctl disable sddm.service
  omarchy-state set reboot-required
fi

# The login screen and the boot splash take their colors from the theme. A
# failure shouldn't stop the update: the next theme change tries again.
omarchy-theme-set-login || echo "Could not color the boot splash and login screen; the next theme change tries again" >&2

# An N1x lights its panel for the LUKS prompt with a hook placed after
# plymouth's; place it after the splash's too.
n1x_drop_in=/etc/mkinitcpio.conf.d/zz-omarchy-n1x-boot-brightness.conf
if [[ -f $n1x_drop_in ]] && grep -qF '[[ $_omarchy_n1x_hook == plymouth ]] &&' "$n1x_drop_in"; then
  sudo sed -i 's/\[\[ \$_omarchy_n1x_hook == plymouth \]\] &&/[[ $_omarchy_n1x_hook == omarchy-splash || $_omarchy_n1x_hook == plymouth ]] \&\&/' "$n1x_drop_in"
fi

# Nothing rebuilds the boot image when a drop-in changes, so build it now that
# the HOOKS baseline draws the prompt with omarchy-splash (where it does). The
# rebuild is machine-wide: another user's migration must not repeat it.
rebuild_marker=/var/lib/omarchy/migrations/1795834060
[[ ! -e $rebuild_marker ]] || exit 0

# Whether the HOOKS baseline draws the prompt with omarchy-splash.
hooks=$(bash -c 'source <(cat -- /etc/mkinitcpio.conf /etc/mkinitcpio.conf.d/*.conf 2>/dev/null) && echo " ${HOOKS[*]} "')

# Plymouth typed a KEYMAP-only layout through the console, and the splash types
# with vconsole.conf's XKB lines: give such a keymap the lines setup writes,
# before the image is built with them. Not where Plymouth keeps the prompt (a
# systemd initramfs, as on Apple Silicon), which would type with them too. The
# desktop, its lock screen and the login screen then type the keymap's layout,
# where they typed US before.
source "$OMARCHY_PATH/install/provisioning/setup-form.sh"
vconsole_keymap=$(unset KEYMAP XKBLAYOUT; . /etc/vconsole.conf 2>/dev/null || true; [[ -n ${XKBLAYOUT:-} ]] || printf %s "${KEYMAP:-}")
if [[ $hooks == *" omarchy-splash "* ]] && vconsole_xkb=$(omarchy_keymap_xkb_settings "$vconsole_keymap"); then
  echo "Giving console keymap $vconsole_keymap the XKB layout the boot splash types the disk password with"
  { [[ -z $(tail -c 1 /etc/vconsole.conf) ]] || echo; printf '%s\n' "$vconsole_xkb"; } | sudo tee -a /etc/vconsole.conf >/dev/null
fi

# The Zenbook A16 asked for the disk password on the console, as Plymouth left
# its panel black, and plymouth.enable=0 kept Plymouth's shutdown screens off
# too (install/hardware/asus/fix-asus-zenbook-a16-boot.sh). The splash draws
# the prompt there, and the parameter would now turn the splash off.
zenbook=" $(omarchy-boot-cmdline get zenbook-a16) "
if [[ $hooks == *" omarchy-splash "* && $zenbook == *" plymouth.enable=0 "* ]]; then
  zenbook=${zenbook// plymouth.enable=0 / }
  zenbook=${zenbook# }
  sudo omarchy-boot-cmdline set zenbook-a16 "${zenbook% }"
fi

if ! sudo omarchy-update-boot-splash; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
