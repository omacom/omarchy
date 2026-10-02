for svc in avahi-daemon cups cups-browsed; do
  sudo systemctl disable --now "$svc.service" 2>/dev/null || true
  sudo systemctl disable --now "$svc.socket" 2>/dev/null || true
done

sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Resolve]
LLMNR=no
MulticastDNS=no
EOF

