echo "Set transparent huge pages to madvise and cap systemd journal size"

thp_dropin=/etc/tmpfiles.d/omarchy-thp.conf
journal_dropin=/etc/systemd/journald.conf.d/10-omarchy.conf
journal_stamp=/var/lib/omarchy/migrations/1795784791-journald

# A dev checkout can run ahead of omarchy-settings: stay pending until both
# drop-ins land so the settings persist across reboots too.
if [[ ! -r $thp_dropin || ! -r $journal_dropin ]]; then
  echo "Waiting for omarchy-settings to ship THP and journald drop-ins"
  exit 75
fi

thp_sysfs=/sys/kernel/mm/transparent_hugepage/enabled
if [[ -r $thp_sysfs && $(<"$thp_sysfs") != *"[madvise]"* ]]; then
  sudo /usr/bin/systemd-tmpfiles --create --boot "$thp_dropin"
fi

# Track application with a machine-wide stamp so later users on the same
# machine do not restart systemd-journald again.
if [[ ! -e $journal_stamp ]]; then
  sudo /usr/bin/systemctl restart systemd-journald.service
  sudo /usr/bin/journalctl --vacuum-size=100M
  sudo /usr/bin/install -Dm644 /dev/null "$journal_stamp"
fi
