# Nautilus icons and Chromium policy: both are packages the server edition does
# not install, and gtk-update-icon-cache is not there to run.
if omarchy-edition-desktop; then
  run_logged "$OMARCHY_INSTALL/config/theme-system.sh"
  run_logged "$OMARCHY_INSTALL/config/browser-policy.sh"
fi
run_logged "$OMARCHY_INSTALL/config/increase-lockout-limit.sh"
# The lock screen is hyprlock, which the server edition does not install.
if omarchy-edition-desktop; then
  run_logged "$OMARCHY_INSTALL/config/lockscreen-pam.sh"
fi
run_logged "$OMARCHY_INSTALL/config/fix-powerprofilesctl-shebang.sh"
run_logged "$OMARCHY_INSTALL/config/ssh-command-path.sh"
run_logged "$OMARCHY_INSTALL/config/ssh-keepalive.sh"
run_logged "$OMARCHY_INSTALL/config/docker.sh"
run_logged "$OMARCHY_INSTALL/config/snapper.sh"
run_logged "$OMARCHY_INSTALL/config/enable-services.sh"
run_logged "$OMARCHY_INSTALL/config/firewall.sh"
