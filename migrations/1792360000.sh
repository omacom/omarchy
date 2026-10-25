# shellcheck shell=bash
# Deploy the boot-time resume-offset consistency check on installs that already
# use swapfile hibernation (issue #14379).

# A stale resume_offset= makes resume silently cold-boot: the initramfs reads
# the hibernation image at the literal physical offset from the boot parameters,
# and btrfs can move the swapfile between setup runs. The check unit ships with
# this update; existing installs that already hibernate need it published and
# enabled, which pacman cannot own by itself.

resume_offset=$(sed -n 's/.*\bresume_offset=\([^ ]*\).*/\1/p' /proc/cmdline)
[[ -n $resume_offset ]] || exit 0

# System-side verify unit: ships under default/systemd/system/ in the package
# and is only meaningful where hibernation is actually configured.
if [[ -f $OMARCHY_PATH/default/systemd/system/omarchy-hibernation-verify-resume.service ]]; then
  sudo install -Dm644 \
    "$OMARCHY_PATH/default/systemd/system/omarchy-hibernation-verify-resume.service" \
    /etc/systemd/system/omarchy-hibernation-verify-resume.service
  sudo systemctl daemon-reload
  sudo systemctl enable --quiet omarchy-hibernation-verify-resume.service 2>/dev/null || true
fi

# User-side notify unit: ships in /usr/lib/systemd/user/ with the package. The
# ConditionPathExists on the /run flag keeps it inert unless this boot really
# found a stale offset.
systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written (crash
# watch migration precedent).
if ! systemctl --user enable omarchy-hibernation-resume-notify.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-hibernation-resume-notify.service \
    "$wants_dir/omarchy-hibernation-resume-notify.service"
fi

# Nothing to start into over SSH; the next graphical login handles it. Starting
# it when the session is live also surfaces an already-stale offset right away.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-hibernation-resume-notify.service >/dev/null 2>&1 || true
fi
