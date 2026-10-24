# Unattended installs and upgrades can carry a git identity already.
if [[ -z $(git config --global user.name) || -z $(git config --global user.email) ]]; then
  omarchy-notification-send -u critical -g  "Setup Git" "Identification for code commits" \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-setup-git
fi
