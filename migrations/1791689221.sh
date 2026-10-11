echo "Power off after hibernating on MacBookPro11,1"

conf="${OMARCHY_HIBERNATE_MODE_CONF:-/etc/systemd/sleep.conf.d/hibernatemode.conf}"

if omarchy-hw-match "^MacBookPro11,1$" && [[ $(cat "$conf" 2>/dev/null || true) != $'[Sleep]\nHibernateMode=shutdown' ]]; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-macbookpro11-1-hibernate.sh"
fi
