echo "Restore t2fanrd fan control after suspend/resume"

# The SMC drops manual fan control across sleep and t2fanrd only enables it at
# startup. Fresh installs get the hook from install/hardware/apple/fix-t2.sh.
if ! lspci -nn 2>/dev/null | grep "106b:180[12]" >/dev/null; then
  exit 0
fi

source="$OMARCHY_PATH/default/systemd/system-sleep/t2fanrd"
dest="${OMARCHY_T2FANRD_HOOK:-/usr/lib/systemd/system-sleep/t2fanrd}"
if [[ ! -f $source ]]; then
  echo "Missing $source; rerun omarchy-migrate after updating." >&2
  exit 1
fi

# Another user on this machine may already have installed it. A copy made by
# hand from the 0644 source matches but never runs.
if [[ -x $dest ]] && cmp -s "$source" "$dest"; then
  exit 0
fi

sudo mkdir -p "${dest%/*}"
sudo install -m 0755 -o root -g root -T "$source" "$dest"
