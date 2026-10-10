notify_update() {
  omarchy-notification-send -u critical -g  "Update System" "Click to update the system." \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-update
}

# Backgrounded: the launcher hands off through uwsm-app and does not
# necessarily return until the terminal closes, and the update prompt below
# must not wait on the user reading this.
show_network_onboarding() {
  omarchy-launch-floating-terminal-with-presentation omarchy-network-onboard &
}

notify_network() {
  omarchy-notification-send -u critical -g 󰖩 "Set Up Network" "Click for this machine's MAC address and the terminal instructions." \
    --exec omarchy-launch-floating-terminal-with-presentation omarchy-network-onboard
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
    # Open the guide rather than the network panel. A network that gates on a
    # registered MAC cannot be joined from the picker at all: the address has
    # to be handed over and cleared first, and the picker has nowhere to show
    # it. The toast stays as the way back in once the terminal is closed.
    show_network_onboarding
    notify_network
    # Nothing to update against until a link lands, so hold that prompt.
    nm-online -q -t 3600 || return
  fi

  notify_update
}

# Detached, so a slow or absent connection never holds up the rest of first run.
announce_network &
