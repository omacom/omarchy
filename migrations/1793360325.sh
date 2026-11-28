echo "Restart Voxtype with WirePlumber so suspend resume cannot spin its audio"

# The intel-ipu7 camera resume hook restarts wireplumber.service on every
# resume. Voxtype keeps a playback stream open, and when WirePlumber disappears
# under it, its audio output thread can spin at 100% CPU and flood the journal.
# Tie voxtype.service to WirePlumber: stop and restart with it, and have a
# WirePlumber start pull Voxtype back in; the installer writes the same
# drop-in for new installs.
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

[Install]
WantedBy=wireplumber.service
EOF

# A fresh user manager reads unit files itself, so only a live one needs the
# reload; without one the drop-in simply takes effect at the next login.
systemctl --user daemon-reload >/dev/null 2>&1 || true

# Re-enable the service to pick up the new WantedBy link, but only when it is
# already enabled so a user who disabled Voxtype stays disabled. Without a live
# user manager, fall back to writing the symlink it would have written, keeping
# the target of the link that showed the service was enabled.
enabled_link=""
for target in default.target.wants multi-user.target.wants wireplumber.service.wants; do
  link="$user_config_home/systemd/user/$target/voxtype.service"
  if [[ -L $link || -e $link ]]; then
    enabled_link=$link
    break
  fi
done
if [[ -n $enabled_link ]] || systemctl --user is-enabled --quiet voxtype.service 2>/dev/null; then
  if ! systemctl --user enable voxtype.service >/dev/null 2>&1; then
    wants_dir="$user_config_home/systemd/user/wireplumber.service.wants"
    mkdir -p "$wants_dir"
    if [[ -n $enabled_link ]]; then
      ln -sfn "$(readlink -f -- "$enabled_link")" "$wants_dir/voxtype.service"
    else
      ln -sfn /usr/lib/systemd/user/voxtype.service "$wants_dir/voxtype.service"
    fi
  fi
fi
