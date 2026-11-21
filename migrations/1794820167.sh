echo "Install Reach, for one keyboard and mouse across your Circle machines"

# Reach runs idle until it's given a row of machines (from its panel, or from
# another machine), and only machines on Circle can reach its port.
omarchy-pkg-add reach

# ufw skips a rule it already has, so this is safe to run for every user.
if omarchy-cmd-present ufw; then
  sudo ufw allow in on circle0 to any port 24850 proto tcp comment 'reach' >/dev/null
fi

systemctl --user enable --now reach.service

# Its bar icon stays hidden until Circle is up and another of your machines is
# close by, so it can sit in every bar.
omarchy-plugin-enable omarchy.reach --before omarchy.network >/dev/null 2>&1 || omarchy-plugin-enable omarchy.reach >/dev/null 2>&1 || true
