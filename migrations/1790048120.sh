echo "Ensure systemd-resolved is active when resolv.conf uses the stub resolver"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Quattro points /etc/resolv.conf at systemd-resolved's stub. If that unit is
# inactive (historical migration 1782002156 swallowed restart failures), DNS is
# broken until resolved is brought back up.
uses_stub_resolv() {
  [[ -L /etc/resolv.conf ]] || return 1
  local target
  # Quattro's upgrade writes a relative target; other hosts use absolute. Compare
  # the readlink text itself so we do not need the stub file to exist yet.
  target=$(readlink /etc/resolv.conf)
  [[ $target == /run/systemd/resolve/stub-resolv.conf ||
    $target == ../run/systemd/resolve/stub-resolv.conf ]]
}

if ! uses_stub_resolv; then
  exit 0
fi

if systemctl is-active --quiet systemd-resolved.service 2>/dev/null; then
  exit 0
fi

echo "systemd-resolved is inactive while /etc/resolv.conf points at the stub; enabling it"
as_root systemctl enable --now systemd-resolved.service

if ! systemctl is-active --quiet systemd-resolved.service; then
  echo "Failed to start systemd-resolved; DNS will stay broken until it is running." >&2
  exit 1
fi
