echo "Prompt about unauthorized Thunderbolt devices instead of leaving them silently disabled"

# A dock or SSD connecting unauthorized kept its USB/DisplayPort ports dead
# until the user thought to run boltctl themselves. The notify service now
# shows one actionable toast per waiting device, with a backstop path/timer
# pair to catch connections at any time.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# Enable without --now, and start by hand further down only when there is a
# session to start into. `systemctl enable` needs a live user manager, which an
# `omarchy update` from a TTY does not have, so fall back to writing exactly the
# symlink it would have written rather than silently leaving this unenabled.
enable_unit() {
  local unit=$1
  local wants_dir=$2

  if ! systemctl --user enable "$unit" >/dev/null 2>&1; then
    mkdir -p "$wants_dir"
    ln -sfn "/usr/lib/systemd/user/$unit" "$wants_dir/$unit"
  fi
}

graphical_wants="$HOME/.config/systemd/user/graphical-session.target.wants"
enable_unit omarchy-thunderbolt-notify.service "$graphical_wants"
enable_unit omarchy-thunderbolt-notify.path "$graphical_wants"
enable_unit omarchy-thunderbolt-notify.timer "$HOME/.config/systemd/user/timers.target.wants"

# Outside a graphical session -- an update over SSH -- there is nothing to hand
# over: no shell to show the toast, and the unit's own ConditionEnvironment
# would skip the start anyway. The enablement above is the whole job; the next
# graphical login starts it.
if systemctl --user is-active --quiet graphical-session.target; then
  # Report what systemctl actually said. A start failure here would leave USB
  # ports silently disabled all session, so it has to be loud instead of
  # leaving the session without the prompt and a migration marked complete.
  if ! error=$(systemctl --user start omarchy-thunderbolt-notify.service 2>&1); then
    echo "Could not start omarchy-thunderbolt-notify.service: $error"
    echo "Thunderbolt prompts will not appear until the next login."
  fi
fi
