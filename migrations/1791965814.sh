echo "Ignore the companion Mouse node on Samsung 950QED clickpads"

if grep -Fxq "SAMSUNG ELECTRONICS CO., LTD." /sys/class/dmi/id/sys_vendor 2>/dev/null &&
  omarchy-hw-match "^950QED$" &&
  ! cmp -s "$OMARCHY_PATH/default/udev/samsung-950qed-clickpad.rules" /etc/udev/rules.d/61-znt-clickpad-mouse.rules; then
  source "$OMARCHY_PATH/install/hardware/samsung/fix-950qed-clickpad.sh"
  # Do not rebind a live input device in the user's session.
  omarchy-state set reboot-required
fi
