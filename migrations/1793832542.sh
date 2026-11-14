echo "Keep the last clipboard copy available after its source application closes"

omarchy-pkg-add omarchy-clipboard-keeper
systemctl --user daemon-reload
systemctl --user enable --now omarchy-clipboard-persist.service
