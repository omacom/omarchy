# Hibernate on MacBookPro11,1 powers back on from ACPI S4 instead of staying off;
# shutdown mode powers it off the way a normal shutdown does.
if omarchy-hw-match "^MacBookPro11,1$"; then
  sudo mkdir -p /etc/systemd/sleep.conf.d
  sudo tee /etc/systemd/sleep.conf.d/hibernatemode.conf >/dev/null <<'EOF'
[Sleep]
HibernateMode=shutdown
EOF
fi
