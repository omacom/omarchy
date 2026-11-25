echo "Enable USB and Thunderbolt protection while locked, preserving explicit opt-outs and independent policies"

for required_file in \
  /etc/systemd/user/omarchy-usb-lock-watch.service \
  /etc/systemd/user/omarchy-thunderbolt-lock-watch.path \
  /etc/systemd/user/omarchy-thunderbolt-lock-notify.service \
  /etc/systemd/system/omarchy-usb-lock.service \
  /etc/systemd/system/omarchy-thunderbolt-lock.service; do
  if [[ ! -f $required_file ]]; then
    echo "Waiting for the omarchy-settings package that ships $required_file" >&2
    exit 75
  fi
done
if [[ ! -x /usr/bin/omarchy-usb-lock-admin || ! -x /usr/bin/omarchy-thunderbolt-lock-admin ]]; then
  echo "Waiting for the Omarchy package that ships the USB and Thunderbolt lock helpers" >&2
  exit 75
fi

# The rules directory is private to root and polkitd.
sudo -v || exit 1
for rule in 40-omarchy-usb-lock.rules 40-omarchy-thunderbolt-lock.rules; do
  if ! sudo /usr/bin/test -f "/etc/polkit-1/rules.d/$rule"; then
    echo "Waiting for the omarchy-settings package that ships $rule" >&2
    exit 75
  fi
done

omarchy-pkg-add usbguard
systemctl --user daemon-reload
systemctl --user enable --now omarchy-usb-lock-watch.service omarchy-thunderbolt-lock-watch.path omarchy-thunderbolt-lock-notify.service
systemctl --user is-active --quiet omarchy-usb-lock-watch.service
sudo /usr/bin/omarchy-usb-lock-admin defaults
# An update can still be running the previous shell. The updater restarts it
# after migrations; a current shell can apply its actual state immediately.
omarchy-shell -q lock refreshUsbPolicy >/dev/null 2>&1 || true
