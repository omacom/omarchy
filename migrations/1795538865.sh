echo "Protect desktop session slice from swap-out and CPU starvation"

drop_in=/etc/systemd/user/session.slice.d/10-omarchy.conf
if [[ ! -f $drop_in ]]; then
  echo "Waiting for the omarchy-settings package that ships $drop_in" >&2
  exit 75
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user daemon-reload
fi
