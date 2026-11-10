echo "Re-enroll the Limine config checksum after the boot menu migration"

# 1791898365.sh edited limine.conf without enrolling it again, so machines
# with ENABLE_ENROLL_LIMINE_CONFIG=yes stop on CHECKSUM MISMATCH at the next
# boot. That migration now enrolls the menu itself, but users who already
# completed it never run it again. limine-enroll-config writes the current
# checksum into the Limine binary, and does nothing to it when enrollment is
# off, so running it again changes nothing.

omarchy-cmd-present limine-enroll-config || exit 0

limine_conf="${OMARCHY_LIMINE_CONF:-}"
if [[ -z $limine_conf ]]; then
  esp=""
  if [[ -r /etc/default/limine ]]; then
    esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -n 1)
  fi
  limine_conf="${esp:-/boot}/limine.conf"
fi

if [[ ! -f $limine_conf ]]; then
  # The ESP is often mounted umask=0077, so an unreadable menu is not a
  # missing one; a denied prompt leaves this migration pending.
  sudo -v
  sudo test -f "$limine_conf" || exit 0
fi

sudo limine-enroll-config
