echo "Move OpenClaw to a self-updating install under ~/.openclaw"

# The openclaw package used to be OpenClaw itself, installed under /usr where `openclaw update` and the Control UI's Update button cannot write. It is now the seed for a copy under ~/.openclaw that updates itself, and omarchy-install-openclaw-cli sets that copy up, points the command on PATH at it and moves a gateway service the old package installed over to it. Only machines with the package have an OpenClaw of Omarchy's to move.
omarchy-pkg-present openclaw || exit 0

# This release and the seed package reach a channel together. A package that is still the runtime has nothing to set up from, and the OpenClaw it runs keeps working as it is.
if [[ ! -r /usr/share/openclaw/install-cli.sh || ! -r /usr/share/openclaw/openclaw.tgz ]]; then
  exit 0
fi

# An OpenClaw of the user's own in the way, a command, another one on PATH or a
# gateway running it, is theirs to move aside. Failing here would stop every
# update until they did, so the rest of the move is left to launching OpenClaw
# from Omarchy, which finishes it once the way is clear. A service the old
# package installed, which no longer starts from the seed package, is moved to
# the runtime first, unless a gateway running another OpenClaw keeps one from
# being set up at all. A setup that failed, the npm registry out of reach for
# one, stays pending as before.
status=0
omarchy-install-openclaw-cli --now || status=$?
if ((status == 79)); then
  echo "Leaving the OpenClaw above as it is; launching OpenClaw from Omarchy finishes the move once it is out of the way."
  exit 0
fi
exit "$status"
