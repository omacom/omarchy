echo "Enable the audio playback idle inhibitor on existing installs"

# omarchy-audio-inhibit.service is enabled by first-run setup only, so systems
# installed before the unit shipped never got it. Migrations run per-user after
# pacman finishes, so the unit file is already in place here; enable it for
# this user's session.
systemctl --user daemon-reload >/dev/null 2>&1 || true
systemctl --user enable --now omarchy-audio-inhibit.service >/dev/null 2>&1 || true
