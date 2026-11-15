# Start the A16's DSPs before opening the root disk, including on USB installs.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree asus,zenbook-a16-ux3607oa; then
  omarchy-pkg-add asus-zenbook-a16-firmware

  for directory in install hooks; do
    install -Dm644 "$OMARCHY_PATH/default/initcpio/$directory/omarchy-a16-dsp" "/etc/initcpio/$directory/omarchy-a16-dsp"
  done
  mkdir -p /etc/mkinitcpio.conf.d
  cat >/etc/mkinitcpio.conf.d/zz-omarchy-a16-dsp.conf <<'CONF'
# Recheck the board when rebuilding a portable installation on another laptop.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree asus,zenbook-a16-ux3607oa; then
  if [[ " ${HOOKS[*]} " != *" udev "* || " ${HOOKS[*]} " == *" systemd "* ]]; then
    echo "A16 DSP startup requires the BusyBox udev initramfs" >&2
    return 1
  fi
  _omarchy_a16_hooks=()
  for _omarchy_a16_hook in "${HOOKS[@]}"; do
    [[ $_omarchy_a16_hook == "omarchy-a16-dsp" ]] && continue
    _omarchy_a16_hooks+=("$_omarchy_a16_hook")
    [[ $_omarchy_a16_hook != "udev" ]] || _omarchy_a16_hooks+=(omarchy-a16-dsp)
  done
  HOOKS=("${_omarchy_a16_hooks[@]}")
  unset _omarchy_a16_hooks _omarchy_a16_hook
fi
CONF
fi
