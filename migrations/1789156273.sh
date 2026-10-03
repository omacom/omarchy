echo "Prune the pacman package cache weekly to prevent unbounded disk growth"

# New installs get this from install/config/enable-services.sh. Existing ones
# retain every package version downloaded since installation in /var/cache/pacman/pkg.

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Machine-wide, so a second user on the same box finds it already done.
if ! systemctl is-enabled --quiet paccache.timer 2>/dev/null; then
  as_root systemctl enable --now paccache.timer >/dev/null 2>&1 ||
    echo "Could not enable paccache.timer; package cache will continue to grow unbounded."
fi
