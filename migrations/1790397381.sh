echo "Move OpenClaw to a self-updating install under ~/.openclaw"

# The openclaw package used to be OpenClaw itself, installed under /usr where `openclaw update` and the Control UI's Update button cannot write. It is now the seed for a copy under ~/.openclaw that updates itself, and omarchy-install-openclaw-cli sets that copy up, points the command on PATH at it and moves a gateway service the old package installed over to it. Only machines with the package have an OpenClaw of Omarchy's to move.
omarchy-pkg-present openclaw || exit 0

# Updates install packages before migrations. An older package is still the runtime and has no seed, so this stays pending until it is updated.
if [[ ! -r /usr/share/openclaw/install-cli.sh || ! -r /usr/share/openclaw/openclaw.tgz ]]; then
  echo "Update the openclaw package before rerunning this migration." >&2
  exit 1
fi

omarchy-install-openclaw-cli --now
