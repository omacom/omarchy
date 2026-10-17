echo "Install the NetworkManager hook behind the wired-only Wi-Fi toggle"

# Same stub install/config/network-wired-only.sh writes on fresh installs.
# Idempotent: a second user running this after the first finds the hook and
# does nothing. -x rather than -f: a hook left behind without its mode is
# rewritten, not kept.
hook=/etc/NetworkManager/dispatcher.d/50-omarchy-wired-only

if [[ ! -x $hook ]]; then
  sudo install -d -m 755 /etc/NetworkManager/dispatcher.d
  sudo tee "$hook" >/dev/null <<'EOF'
#!/bin/bash
# Omarchy: turn Wi-Fi off while Ethernet is connected when a user has
# `omarchy network wired only` on. Logic lives in omarchy-network-wired-only.
exec /usr/bin/omarchy-network-wired-only --dispatch "$1" "$2"
EOF
  # NetworkManager ignores hooks that are not root-owned, executable and
  # unwritable by anyone else.
  sudo chmod 755 "$hook"
fi
