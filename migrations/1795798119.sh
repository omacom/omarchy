echo "Run Steam games with Proton when their Linux build isn't installed"

if omarchy-pkg-present steam; then
  if [[ ! -f /usr/lib/systemd/user/omarchy-steam-proton-fallback.service ]]; then
    echo "Waiting for omarchy-settings to ship omarchy-steam-proton-fallback.service"
    exit 75
  fi

  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-steam-proton-fallback.service
fi
