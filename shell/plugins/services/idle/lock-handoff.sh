#!/bin/bash

# Wait until the idle lock is secure, then remove the screensaver without
# asking for a second lock. Give up after OMARCHY_IDLE_LOCK_WAIT_SECONDS
# (default 10) so a request with no real screen cannot poll forever. A
# give-up or a lock that disappears leaves the screensaver mapped.

omarchy-shell lock lockFromIdle >/dev/null 2>&1 || exit 1
deadline=$((SECONDS + ${OMARCHY_IDLE_LOCK_WAIT_SECONDS:-10}))
while [[ $(omarchy-shell lock isLocked 2>/dev/null) == true ]]; do
  [[ $(omarchy-shell lock status 2>/dev/null | jq -r '.secure // false') == true ]] && exec omarchy-system-lock cleanup
  (( SECONDS >= deadline )) && exit 1
  sleep 0.05
done
exit 1
