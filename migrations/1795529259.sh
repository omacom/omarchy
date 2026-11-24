echo "Expose the internal microphone on the Lenovo IdeaPad Slim 5 14AGP11"

if omarchy-hw-match '^83S1$'; then
  if [[ ! -e /etc/wireplumber/wireplumber.conf.d/51-ideapad-slim5-internal-mic.conf ]]; then
    source "$OMARCHY_PATH/install/hardware/lenovo/fix-ideapad-slim5-mic.sh"
  fi
  # Without a user bus, the persistent rule takes effect at the next login.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
