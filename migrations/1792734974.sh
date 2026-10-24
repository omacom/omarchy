echo "Create the machine-wide update lock, so two administrators' updates never run at once"

# systemd-tmpfiles creates it at every boot; this creates it now rather than at
# the next one.
if [[ -f /etc/tmpfiles.d/omarchy-update-lock.conf ]]; then
  sudo systemd-tmpfiles --create /etc/tmpfiles.d/omarchy-update-lock.conf
fi
