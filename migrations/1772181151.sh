echo "Fix hybrid GPU sleep hook and disable nvidia sleep services in integrated mode"

# Only applies to systems with supergfxctl configured
if omarchy-cmd-present supergfxctl && [[ -f /etc/supergfxd.conf ]]; then
  current_mode=$(awk -F'"' '/"mode"/ { print $(NF-1) }' /etc/supergfxd.conf 2>/dev/null | head -n1)

  # Reinstall the force-igpu sleep hook root-owned and executable (cp -p left it user-owned and inert)
  if [[ -f /usr/lib/systemd/system-sleep/force-igpu ]]; then
    sudo install -m 0755 -o root -g root "$OMARCHY_PATH/default/systemd/system-sleep/force-igpu" /usr/lib/systemd/system-sleep/force-igpu
  fi

  if [[ $current_mode == "Integrated" ]]; then
    # Disable nvidia sleep/resume services
    sudo systemctl disable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service 2>/dev/null
  fi
fi
