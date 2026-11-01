echo "Restart Voxtype with WirePlumber so suspend resume cannot spin its audio"

# The intel-ipu7 camera resume hook restarts wireplumber.service on every
# resume. Voxtype keeps a playback stream open, and when WirePlumber disappears
# under it, its audio output thread can spin at 100% CPU and flood the journal.
# Tie voxtype.service to WirePlumber so it stops and starts with it instead; the
# installer writes the same drop-in for new installs.
omarchy-cmd-present voxtype || exit 0

user_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
drop_in_dir="$user_config_home/systemd/user/voxtype.service.d"
mkdir -p "$drop_in_dir"
cat >"$drop_in_dir/omarchy-restart-with-wireplumber.conf" <<'EOF'
# Omarchy: restart Voxtype with WirePlumber. The intel-ipu7 camera resume hook
# restarts wireplumber.service on every resume, and Voxtype's open playback
# stream can spin at 100% CPU once WirePlumber disappears under it.
[Unit]
PartOf=wireplumber.service
After=wireplumber.service
EOF

# A fresh user manager reads unit files itself, so only a live one needs the
# reload; without one the drop-in simply takes effect at the next login.
systemctl --user daemon-reload >/dev/null 2>&1 || true
