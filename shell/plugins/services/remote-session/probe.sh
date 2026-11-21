#!/bin/bash

# Lists this user's running gliff-server processes, one "<pid> [peer]" line
# each. The peer is the ssh client address when the server was spawned over
# ssh (the real path); a local --listen server has none. Another account's
# server captures its own desktop, not this one, so other users are skipped.

# A process name is not proof: anything running as this user can call itself
# gliff-server, and what this service reports decides whether the screen
# sharing protection stays on, so a name match alone must not carry that
# trust. Require the executable behind the pid to be the packaged server,
# which a process cannot choose for itself. Upgrades leave a running server
# pointing at a deleted file, so that marker is stripped rather than counted
# as a mismatch. Tests substitute their own stand-in server through this
# variable.
expected_exe="${OMARCHY_GLIFF_SERVER_EXE:-/usr/bin/gliff-server}"

for pid in $(pgrep -x -u "$(id -u)" gliff-server); do
  exe=$(readlink "/proc/$pid/exe" 2>/dev/null) || continue
  exe="${exe% (deleted)}"
  [[ "$exe" == "$expected_exe" ]] || continue
  peer=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | sed -n 's/^SSH_CONNECTION=\([^ ]*\).*/\1/p')
  printf '%s %s\n' "$pid" "$peer"
done
