#!/bin/bash

# Turn a Raspberry Pi 5 running Raspberry Pi OS Lite (64-bit) into a fabric node.
# Run from a checkout of omarchy-fabric on the Pi:
#
#   sudo deploy/pi5/bootstrap.sh            # the fabric node only
#   sudo deploy/pi5/bootstrap.sh --stack    # also start Home Assistant + Matter Server (needs Docker)
#
# Safe to re-run: existing config, keys and tokens are kept.

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)
STACK=0
if [[ ${1:-} == "--stack" ]]; then
  STACK=1
fi

if (( EUID != 0 )); then
  echo "Run with sudo." >&2
  exit 1
fi
if ! command -v apt-get >/dev/null; then
  echo "This script targets Raspberry Pi OS (Debian). See docs/05-pi5-runbook.md for other systems." >&2
  exit 1
fi

echo -e "\n== Packages (gpiozero and lgpio from Raspberry Pi OS, they match the Pi 5's RP1 chip)"
apt-get update
apt-get install -y python3 python3-venv python3-gpiozero python3-lgpio git openssl

echo -e "\n== The fabric user"
if ! id fabric >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash fabric
fi
usermod -aG gpio fabric
install -d -m 0700 -o fabric -g fabric /home/fabric/.ssh

echo -e "\n== ofab, in a root-owned venv the fabric user cannot modify"
python3 -m venv --system-site-packages /opt/omarchy-fabric/venv
/opt/omarchy-fabric/venv/bin/pip install --quiet --upgrade "$REPO_ROOT"
ln -sf /opt/omarchy-fabric/venv/bin/ofab /usr/local/bin/ofab

echo -e "\n== Config, audit key, HA token slot"
install -d -m 0750 -o root -g fabric /etc/omarchy-fabric
if [[ ! -f /etc/omarchy-fabric/node.toml ]]; then
  install -m 0640 -o root -g fabric "$REPO_ROOT/deploy/pi5/node.toml" /etc/omarchy-fabric/node.toml
fi
if [[ ! -f /etc/omarchy-fabric/audit.key ]]; then
  (umask 027 && openssl rand -hex 32 >/etc/omarchy-fabric/audit.key)
  chown root:fabric /etc/omarchy-fabric/audit.key
fi
if [[ ! -f /home/fabric/.ssh/authorized_keys ]]; then
  install -m 0600 -o fabric -g fabric /dev/null /home/fabric/.ssh/authorized_keys
fi

echo -e "\n== Service"
install -m 0644 "$REPO_ROOT/deploy/pi5/omarchy-fabric-node.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now omarchy-fabric-node.service

if (( STACK )); then
  echo -e "\n== Home Assistant + Matter Server"
  if docker compose version >/dev/null 2>&1; then
    install -d /opt/fabric-stack
    cp "$REPO_ROOT/deploy/pi5/compose.yaml" "$REPO_ROOT/deploy/pi5/mosquitto.conf" /opt/fabric-stack/
    (cd /opt/fabric-stack && docker compose up -d)
  else
    echo "Docker with the compose plugin is not installed. Install Docker Engine for Debian (docs.docker.com/engine/install/debian/), then re-run with --stack."
  fi
fi

cat <<EOF

The fabric node is running:  sudo -u fabric ofab -c /etc/omarchy-fabric/node.toml status

Next:
  1. Home Assistant: open http://$(hostname).local:8123, onboard, create a user "omarchy-fabric",
     make a long-lived token for it, and save it:  sudo tee /etc/omarchy-fabric/ha.token
     then: sudo chown root:fabric /etc/omarchy-fabric/ha.token && sudo chmod 0640 /etc/omarchy-fabric/ha.token
  2. Matter: in HA add the Matter integration with ws://localhost:5580/ws.
  3. Wire the approve button (GPIO17), kill switch (GPIO27) and status LED (GPIO22): docs/03-hardware-list.md.
  4. Add your desktop's keys to /home/fabric/.ssh/authorized_keys: deploy/pi5/authorized_keys.example.
  5. sudo systemctl restart omarchy-fabric-node && sudo journalctl -u omarchy-fabric-node -f
EOF
