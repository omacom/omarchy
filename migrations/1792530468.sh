echo "Keep clipboard contents available after their source application closes"

omarchy-pkg-add wl-clip-persist
systemctl --user daemon-reload
systemctl --user enable --now omarchy-clipboard-persist.service
