echo "Enable USB and Thunderbolt protection while locked, preserving explicit opt-outs and independent policies"

omarchy-pkg-add usbguard
systemctl --user daemon-reload
systemctl --user enable --now omarchy-usb-lock-watch.service omarchy-thunderbolt-lock-watch.path omarchy-thunderbolt-lock-notify.service
systemctl --user is-active --quiet omarchy-usb-lock-watch.service
sudo /usr/bin/omarchy-usb-lock-admin defaults
# An update can still be running the previous shell. The updater restarts it
# after migrations; a current shell can apply its actual state immediately.
omarchy-shell -q lock refreshUsbPolicy >/dev/null 2>&1 || true
