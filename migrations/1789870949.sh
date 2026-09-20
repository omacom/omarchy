echo "Restore t2fanrd fan control after suspend/resume"

# t2fanrd holds applesmc fan FDs open across suspend; after resume the sysfs
# nodes are recreated and the running daemon never reasserts manual control,
# leaving the SMC in failsafe full speed (fan1_manual=0).
# Fresh installs are covered by install/hardware/apple/fix-t2.sh; this repairs
# existing T2 machines. See https://github.com/omacom/omarchy/issues/12393
if ! lspci -nn 2>/dev/null | grep -q "106b:180[12]"; then
  exit 0
fi

source="$OMARCHY_PATH/default/systemd/system-sleep/t2fanrd"
dest=/usr/lib/systemd/system-sleep/t2fanrd
if [[ ! -f $source ]]; then
  echo "Missing $source; rerun omarchy-migrate after updating." >&2
  exit 1
fi

sudo mkdir -p "${dest%/*}"
sudo install -m 0755 -o root -g root -T "$source" "$dest"
