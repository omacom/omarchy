echo "Switch to Omarchy's power-profiles-daemon build with CPPC support for ARM laptops"

# Stock power-profiles-daemon has no driver for cppc_cpufreq, so ARM laptops
# only get placeholder profiles that change nothing. pacman -Q also answers for
# the provided name, so check for the Omarchy build itself.
if omarchy-pkg-present power-profiles-daemon && omarchy-pkg-missing omarchy-power-profiles-daemon; then
  # One transaction with --ask 4 so pacman accepts replacing the conflicting
  # power-profiles-daemon in place; dependents stay satisfied through the
  # provides.
  sudo pacman -S --noconfirm --ask 4 omarchy-power-profiles-daemon

  # The running daemon keeps the old binary until restarted, and only the new
  # one offers a performance profile, so reapply the AC/battery choice after.
  sudo systemctl try-restart power-profiles-daemon.service
  omarchy-powerprofiles-set autodetect
fi
