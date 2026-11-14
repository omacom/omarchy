echo "Wake the MacBook Pro (Mid 2015) without a black screen when the lid opens"

# See install/hardware/apple/fix-resume-cpus.sh.
if ! omarchy-hw-match "MacBookPro11,4"; then
  exit 0
fi

# Another user on this machine may already have applied it.
if [[ -f /usr/lib/systemd/system-sleep/apple-fast-resume ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/apple/fix-resume-cpus.sh"
'
