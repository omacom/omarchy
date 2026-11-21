#!/bin/bash

# Lists this user's running gliff-server processes, one "<pid> [peer]" line
# each. The peer is the ssh client address when the server was spawned over
# ssh (the real path); a local --listen server has none. Another account's
# server captures its own desktop, not this one, so other users are skipped.

# Keep pgrep's user/name filtering, but parse procfs with shell builtins:
# this probe also runs repeatedly while active, once per service (not monitor).
for pid in $(pgrep -x -u "$UID" gliff-server); do
  peer=""
  while IFS= read -r -d '' entry; do
    if [[ $entry == SSH_CONNECTION=* ]]; then
      peer=${entry#SSH_CONNECTION=}
      peer=${peer%% *}
      break
    fi
  done 2>/dev/null <"/proc/$pid/environ"
  printf '%s %s\n' "$pid" "$peer"
done
