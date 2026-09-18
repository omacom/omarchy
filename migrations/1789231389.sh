echo "Keep lid-close awake while coding agents are working"

systemctl --user daemon-reload >/dev/null 2>&1 || true

# Report what systemctl actually said; "could not enable" on its own gives
# nothing to act on.
if ! error=$(systemctl --user enable --now omarchy-lid-guard.service 2>&1); then
  echo "Could not enable omarchy-lid-guard.service: $error"
fi
