#!/bin/bash

# Lists this user's running gliff-server processes, one "<pid> [peer]" line
# each. The peer is the ssh client address when the server was spawned over
# ssh (the real path); a local --listen server has none. Another account's
# server captures its own desktop, not this one, so other users are skipped.

for pid in $(pgrep -x -u "$(id -u)" gliff-server); do
  peer=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | sed -n 's/^SSH_CONNECTION=\([^ ]*\).*/\1/p')
  printf '%s %s\n' "$pid" "$peer"
done
