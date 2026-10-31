notify_update() {
  omarchy-notification-send -u critical -g  "$(omarchy-i18n firstRun.updateTitle)" "$(omarchy-i18n firstRun.updateBody)" \
    --exec omarchy-launch-update
}

# Something for omarchy-update to install: any repository package, Omarchy's
# own among them, or a development checkout behind its upstream. checkupdates
# exits 2 when every package is current and 1 when it could not tell, so only
# a definite "nothing" holds the prompt back. It syncs the package databases,
# so it runs once; omarchy-update-available would run it again, and is asked
# only about a checkout, which checkupdates cannot see.
update_pending() {
  local status=0
  checkupdates --nocolor >/dev/null 2>&1 || status=$?

  if (( status != 2 )); then
    return 0
  elif [[ $OMARCHY_PATH != "/usr/share/omarchy" ]]; then
    omarchy-update-available >/dev/null 2>&1
  else
    return 1
  fi
}

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
    # Nothing to update against until a link lands, so hold that prompt.
    nm-online -q -t 3600 || return
  fi

  # A fresh install from current media has nothing to update, and a toast
  # that leads nowhere teaches people to dismiss the next one.
  update_pending && notify_update
}

# Detached, so a slow or absent connection never holds up the rest of first run.
announce_network &
