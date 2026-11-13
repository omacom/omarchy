echo "Lock root, hide kernel pointers and drop setuid from mount.cifs and ksu"

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true

for f in /usr/bin/mount.cifs /usr/bin/ksu; do
  if [[ -u $f || -g $f ]]; then
    sudo chmod ug-s "$f"
  fi
done

# Installs used to give root the same password as the first user. The ISO
# copied the user's hash, which is safe to lock unasked. Machines set up for
# another owner hashed it separately, so ask there, and leave root alone when
# no one can answer: a password someone chose stays until they say otherwise.
root_hash=$(sudo getent shadow root | cut -d: -f2)
user_hash=$(sudo getent shadow "$USER" | cut -d: -f2)
if [[ $root_hash == \$* ]]; then
  if [[ $root_hash == "$user_hash" ]]; then
    sudo usermod -p '!' root
  elif [[ ${OMARCHY_UPDATE_UNATTENDED:-} != 1 && -t 0 && -t 2 ]] &&
    gum confirm "Omarchy used to give root your password. sudo covers everything it's needed for. Lock the root password?"; then
    sudo usermod -p '!' root
  fi
fi
