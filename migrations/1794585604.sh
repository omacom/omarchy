echo "Hide kernel pointers and drop setuid from mount.cifs and ksu"

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true

for f in /usr/bin/mount.cifs /usr/bin/ksu; do
  if [[ -u $f || -g $f ]]; then
    sudo chmod ug-s "$f"
  fi
done
