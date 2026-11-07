#!/bin/bash

# Usage: refocus-run.sh <window-address> <command...>
#
# Give focus back to the window that was active when the clipboard manager
# opened, then run the paste command. With focus-follows-mouse, closing the
# panel leaves focus on whatever window is under the pointer, which after a
# click on the panel is often a different window from the one being typed in.

address=${1:-}
shift

if [[ $address == 0x* ]] && hyprctl clients -j | jq -e --arg a "$address" 'any(.[]; .address == $a and .mapped)' >/dev/null 2>&1; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null 2>&1 || true
  sleep 0.1
fi

exec "$@"
