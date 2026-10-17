# NetworkManager hook behind `omarchy network wired only`: when the toggle is
# on, the Wi-Fi radio goes off while Ethernet is connected and comes back when
# the cable goes. The hook is a stub that hands the event to the Omarchy
# command, so the behavior lives in bin/ where it is tested. It does nothing
# until a user turns the toggle on.
hook=/etc/NetworkManager/dispatcher.d/50-omarchy-wired-only

# -x rather than -f: a hook left behind without its mode is rewritten, not kept.
if [[ ! -x $hook ]]; then
  install -d -m 755 /etc/NetworkManager/dispatcher.d
  cat >"$hook" <<'EOF'
#!/bin/bash
# Omarchy: turn Wi-Fi off while Ethernet is connected when a user has
# `omarchy network wired only` on. Logic lives in omarchy-network-wired-only.
exec /usr/bin/omarchy-network-wired-only --dispatch "$1" "$2"
EOF
  # NetworkManager ignores hooks that are not root-owned, executable and
  # unwritable by anyone else.
  chmod 755 "$hook"
fi
