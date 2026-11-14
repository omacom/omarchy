echo "Rebuild the boot image when Bolt's Thunderbolt approvals change"

# The omarchy-thunderbolt mkinitcpio hook copies the Thunderbolt devices Bolt
# authorizes on its own into the boot image, so a keyboard on a dock or display
# types at the disk unlock prompt. omarchy-thunderbolt-boot.path rebuilds the
# image when Bolt forgets or changes a device, so the prompt stops trusting it
# too. New installs enable it in install/config/enable-services.sh.

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Machine-wide, so a second user on the same box finds it already done.
systemctl is-enabled --quiet omarchy-thunderbolt-boot.path 2>/dev/null && exit 0

as_root systemctl daemon-reload
as_root systemctl enable --now omarchy-thunderbolt-boot.path
