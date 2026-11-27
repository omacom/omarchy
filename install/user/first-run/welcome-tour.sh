#!/bin/bash

# Greet a new user with the welcome tour, once. It holds back the toasts that
# follow until it is closed, so the first screen is the tour and not a stack of
# notices over it. Closing it is an answer, whether or not anything was picked.
#
# A tour that could not be shown is left unmarked and is not a failed step:
# failing would run all of first run again at the next login, toasts included,
# for the sake of something the Setup menu still offers.

set -e

wait_for_active_welcome() {
  local state silent=0
  while true; do
    state=$(OMARCHY_SHELL_IPC_TIMEOUT=1s omarchy-shell shell call omarchy.setup state "" 2>/dev/null || true)
    if [[ $state == "opening" || $state == "shown" ]]; then
      silent=0
    elif [[ $state == "other" || $state == "unknown" ]] || (( ++silent >= 15 )); then
      break
    fi
    sleep 0.2
  done
}

if ! omarchy-done check welcome-tour; then
  if reply=$(omarchy-launch-setup --wait); then
    # If a second Welcome opening replaced the first-run request, hold off until
    # the replacement Welcome closes so first-run toasts do not land over it.
    if grep -qx 'replaced' <<<"$reply"; then
      wait_for_active_welcome
    fi

    omarchy-done mark welcome-tour

    # Once the user actually saw the Agent step (whether they enabled it or left
    # it off), first run's fallback agent invitation is already answered.
    # Skipping on Splash leaves that invitation eligible.
    if grep -Eqx 'agent|seen-agent' <<<"$reply"; then
      omarchy-done mark agent-setup-invitation
    fi

    # Reaching the Ready screen already presented the core keybinding shortcuts,
    # so suppress the duplicate welcome keybindings toast.
    if grep -qx 'seen-ready' <<<"$reply"; then
      omarchy-done mark welcome-keybindings
    fi
  else
    # A pre-reveal replacement leaves another Welcome active even though this
    # wait failed; wait for it to close before releasing first-run toasts.
    wait_for_active_welcome
  fi
fi
