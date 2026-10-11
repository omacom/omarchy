echo "Move OpenClaw to a self-updating install under ~/.openclaw"

# The openclaw package used to be OpenClaw itself, installed under /usr where `openclaw update` and the Control UI's Update button cannot write. It is now the seed for a copy under ~/.openclaw that updates itself, and omarchy-install-openclaw-cli sets that copy up, points the command on PATH at it and moves a gateway service the old package installed over to it. Only machines with the package have an OpenClaw of Omarchy's to move.
omarchy-pkg-present openclaw || exit 0

# The package can turn into the seed after this release reaches a machine. Until it does it is still the runtime, and the OpenClaw it runs keeps working, so this waits for it rather than stopping the update.
if [[ ! -r /usr/share/openclaw/install-cli.sh || ! -r /usr/share/openclaw/openclaw.tgz ]]; then
  waiting="OpenClaw moves to ~/.openclaw once the openclaw package that sets it up arrives."
  echo "$waiting"
  echo "$waiting" >"${OMARCHY_MIGRATION_DEFER:-/dev/null}"
  exit 75
fi

omarchy-install-openclaw-cli --now
