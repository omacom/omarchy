echo "Configure systemd-resolved name resolution hardening"

sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/99-omarchy-hardening.conf >/dev/null <<'EOF'
[Resolve]
LLMNR=no
MulticastDNS=no
EOF

if omarchy-cmd-present systemctl && systemctl is-active --quiet systemd-resolved; then
  sudo systemctl restart systemd-resolved
fi

