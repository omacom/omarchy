#!/bin/bash

set -euo pipefail

# The shell runs in a user service, so /session/self may name the service's
# background session rather than the user's graphical session. logind's auto
# lookup resolves the user's display session in that case.
read -r type path < <(busctl call --allow-interactive-authorization=no \
  org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager GetSession s auto)
[[ $type == "o" && $path == \"/org/freedesktop/login1/session/*\" ]]
path=${path#\"}
path=${path%\"}

# gdbus subscribes as an ordinary client, without the privileged BecomeMonitor
# call used by dbus-monitor. Filter both the sender and this session's path.
exec gdbus monitor --system --dest org.freedesktop.login1 --object-path "$path"
