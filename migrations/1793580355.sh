echo "Restart the speaker tuning with WirePlumber so a resume cannot leave the speakers silent"

# The unit is only copied by `omarchy-audio-tuning on`, so update the installed
# copy here. Edit just the two directives, so any other local change survives.
unit_name=omarchy-speaker-tuning.service
units_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
unit="$units_dir/$unit_name"
unit_source="$OMARCHY_PATH/default/systemd/user/$unit_name"

[[ -f $unit && ! -L $unit ]] || exit 0
grep -qx 'Description=Omarchy speaker tuning filter-chain' "$unit" || exit 0

sed -i \
  -e 's/^PartOf=pipewire\.service$/PartOf=pipewire.service wireplumber.service/' \
  -e 's/^WantedBy=graphical-session\.target$/WantedBy=graphical-session.target wireplumber.service/' \
  "$unit"
# Where only comments now differ, take the shipped file, so that
# `omarchy-audio-tuning on` sees it as current.
if cmp -s <(grep -v '^#' "$unit") <(grep -v '^#' "$unit_source"); then
  install -m644 "$unit_source" "$unit"
fi
systemctl --user daemon-reload >/dev/null 2>&1 || true

# Only an enabled tuning gets the new link. Read enablement from the existing
# link rather than systemctl, which needs a live user manager; for the same
# reason, write the link by hand if `enable` cannot.
if [[ -L $units_dir/graphical-session.target.wants/$unit_name ]] &&
  grep -qx 'WantedBy=.*wireplumber\.service.*' "$unit" &&
  [[ ! -L $units_dir/wireplumber.service.wants/$unit_name ]]; then
  systemctl --user enable "$unit_name" >/dev/null 2>&1 || true
  if [[ ! -L $units_dir/wireplumber.service.wants/$unit_name ]]; then
    mkdir -p "$units_dir/wireplumber.service.wants"
    ln -sfn "$unit" "$units_dir/wireplumber.service.wants/$unit_name"
  fi
fi
