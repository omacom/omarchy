echo "Lock root, hide kernel pointers and drop setuid from mount.cifs and ksu"

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true

for f in /usr/bin/mount.cifs /usr/bin/ksu; do
  if [[ -u $f || -g $f ]]; then
    sudo chmod ug-s "$f"
  fi
done

# Installs used to give root the same password as the first user. Machines
# set up for another owner hashed it separately, so the hashes can't be
# compared: ask whenever root still has a password, so one set on purpose
# stays when the user says so.
if [[ $(sudo getent shadow root | cut -d: -f2) == \$* ]] &&
  gum confirm "Omarchy used to give root your password. sudo covers everything it's needed for. Lock the root password?"; then
  sudo usermod -p '!' root
fi
