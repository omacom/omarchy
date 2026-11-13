echo "Lock root, hide kernel pointers and drop setuid from mount.cifs and ksu"

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true

for f in /usr/bin/mount.cifs /usr/bin/ksu; do
  if [[ -u $f || -g $f ]]; then
    sudo chmod ug-s "$f"
  fi
done

# The installer gave root the same password hash as the first user. Lock root
# only when that copy is still there, so a root password someone set on
# purpose is left alone.
user_hash=$(sudo getent shadow "$USER" | cut -d: -f2)
root_hash=$(sudo getent shadow root | cut -d: -f2)
if [[ $user_hash == \$* && $root_hash == "$user_hash" ]]; then
  sudo usermod -p '!' root
fi
