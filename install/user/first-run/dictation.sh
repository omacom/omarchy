#!/bin/bash

set -e

# The settings package seeds Superwhisper for fresh users. Preserve another
# backend selected before first-login setup or on an existing installation.
if [[ $(omarchy-default-dictation 2>/dev/null) == "superwhisper" ]]; then
  bash /usr/share/superwhisper/setup-user
  if ! omarchy-done check dictation-cloud-default; then
    superwhisper models select cloud >/dev/null
    omarchy-done mark dictation-cloud-default
  fi
  if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/superwhisper/omarchy-panel.pending ]]; then
    echo "Superwhisper panel setup is pending; first-login setup will retry." >&2
    exit 1
  fi
  hyprctl reload >/dev/null
fi
