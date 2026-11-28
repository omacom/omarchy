notify_wifi() {
  omarchy-notification-send -u critical -g 󰖩 "$(omarchy-i18n firstRun.wifiTitle)" "$(omarchy-i18n firstRun.wifiBody)" \
    --exec omarchy-shell shell toggle omarchy.network
}

announce_network() {
  # Ethernet is still negotiating DHCP when the session starts, so probing
  # right away calls a working machine offline. NetworkManager reports startup
  # complete once it has tried every connection it could auto-activate, which
  # is the first moment the answer means anything.
  nm-online -q -s -t 30

  # -x takes that answer as it stands rather than waiting out the timeout, so
  # a laptop with nothing to connect to gets prompted immediately.
  if ! nm-online -q -x -t 30; then
    notify_wifi
    # Nothing to install until a link lands, so hold those prompts
    # for however long that takes. nm-online has no "forever", so wait out its
    # timeout as often as needed, backing off if it returns immediately (e.g.
    # when NetworkManager is stopped).
    local started=$SECONDS
    until nm-online -q -t 86400; do
      (( SECONDS - started < 5 )) && sleep 5
      started=$SECONDS
    done
  fi

  # Both setups install packages, so they wait for the link. Each invites only
  # once, and only when there is something to set up.
  bash "$OMARCHY_PATH/install/user/first-run/setup-agent.hook"
  bash "$OMARCHY_PATH/install/user/first-run/setup-fingerprint.hook"
}

# Detached, so a slow or absent connection never holds up the rest of first run.
announce_network &
