# Recover the touchpad after s2idle resume on ASUS Zenbook 14 UM3406.
#
# i2c_hid_acpi fails to resume the ASUP1206 touchpad (-121), leaving it present
# but dead until reboot. The system-sleep hook rebinds just that device on
# resume and checks for it at runtime, so it is inert anywhere else.
#
# omarchy-settings only ships the source as a plain file, so publish a root-owned
# executable copy through a hidden sibling and an atomic rename, the same way
# omarchy-hibernation-setup installs its system-sleep hook.

if omarchy-hw-match "UM3406"; then
  asus_touchpad_hook=/usr/lib/systemd/system-sleep/asus-touchpad-resume

  sudo mkdir -p "${asus_touchpad_hook%/*}"
  asus_touchpad_stage=$(sudo /usr/bin/mktemp -- "${asus_touchpad_hook%/*}/.${asus_touchpad_hook##*/}.omarchy.XXXXXX")

  if ! sudo /usr/bin/install -m 0755 -o root -g root -T \
    "$OMARCHY_PATH/default/systemd/system-sleep/asus-touchpad-resume" "$asus_touchpad_stage" ||
    ! sudo /usr/bin/mv -Tf -- "$asus_touchpad_stage" "$asus_touchpad_hook"; then
    sudo /usr/bin/rm -f -- "$asus_touchpad_stage"
    echo "Could not install the asus-touchpad-resume system-sleep hook" >&2
    return 1
  fi
fi
