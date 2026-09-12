echo "Configure 5s shutdown timeout for user services"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root mkdir -p /etc/systemd/user.conf.d
cat << 'EOF' | as_root tee /etc/systemd/user.conf.d/10-faster-shutdown.conf >/dev/null
[Manager]
DefaultTimeoutStopSec=5s
EOF
