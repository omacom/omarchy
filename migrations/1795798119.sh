echo "Run Steam games with Proton when their Linux build isn't installed"

if omarchy-pkg-present steam; then
  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-steam-proton-fallback.service
fi
