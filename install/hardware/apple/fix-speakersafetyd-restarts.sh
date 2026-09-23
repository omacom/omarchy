# Keep speakersafetyd retrying after a 96 kHz capture panics it. No-op when
# the daemon isn't installed (non-Asahi). The drop-in is copied rather than
# packaged under /usr/lib so x86 images do not grow a speakersafetyd unit
# directory they will never load.

if [[ -f /usr/lib/systemd/system/speakersafetyd.service ]]; then
  echo "Installing speakersafetyd restart drop-in..."
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/speakersafetyd.service.d/10-omarchy.conf" \
    /etc/systemd/system/speakersafetyd.service.d/10-omarchy.conf
  sudo systemctl daemon-reload
fi
