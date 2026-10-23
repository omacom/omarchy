echo "Move OpenClaw services the first OpenClaw move left on the old package"

omarchy-pkg-present openclaw || exit 0
if [[ ! -r /usr/share/openclaw/install-cli.sh || ! -r /usr/share/openclaw/openclaw.tgz ]]; then
  exit 0
fi

# 4.5.0-rc1's 1792334754 refused the whole move when an OpenClaw of the user's
# own was in the way and still finished, so a gateway or node service the old
# package installed was left running from files the seed package no longer
# ships. That migration is done on those machines and never runs again. Only a
# service still on the old package's files, or one a failed run left stopped,
# has anything left to move.
units="$HOME/.config/systemd/user"
stopped_dir="$HOME/.local/state/omarchy/openclaw-stopped"
if ! grep -qsF /usr/lib/node_modules/openclaw/ "$units/openclaw-gateway.service" "$units/openclaw-node.service" &&
  [[ ! -e $stopped_dir/gateway && ! -e $stopped_dir/node ]]; then
  exit 0
fi

# The user's own OpenClaw is still theirs to move aside, as in 1792334754.
status=0
omarchy-install-openclaw-cli --now || status=$?
if ((status == 79)); then
  echo "Leaving the OpenClaw above as it is; launching OpenClaw from Omarchy finishes the move once it is out of the way."
  exit 0
fi
exit "$status"
