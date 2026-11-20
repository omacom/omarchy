#!/bin/bash

# Greet a new user with the welcome tour, once. It holds back the toasts that
# follow until it is closed, so the first screen is the tour and not a stack of
# notices over it. Closing it is an answer, whether or not anything was picked.
#
# A tour that could not be shown is left unmarked and is not a failed step:
# failing would run all of first run again at the next login, toasts included,
# for the sake of something the Setup menu still offers.

set -e

if ! omarchy-done check welcome-tour && picked=$(omarchy-launch-setup welcome --wait); then
  omarchy-done mark welcome-tour

  # The tour is also the invitation to pick an agent, so one picked there
  # answers first run's own. It is recorded here, before first run goes on to
  # send that toast: the install the tour started would get to it too late.
  if grep -qx "agent" <<<"$picked"; then
    omarchy-done mark agent-setup-invitation
  fi
fi
