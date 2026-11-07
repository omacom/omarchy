# The wanted Before=sleep.target unit pauses users before systemd freezes
# them. Enabling it does not start it during setup or veto sleep on failure.

unit=omarchy-wireplumber-sleep.service
unit_src="$OMARCHY_PATH/default/systemd/system/$unit"
unit_dst="/etc/systemd/system/$unit"
legacy_hook=/usr/lib/systemd/system-sleep/wireplumber-bluetooth
legacy_archive=/etc/systemd/omarchy-retired-hooks/wireplumber-bluetooth

if [[ ! -f $unit_src ]]; then
  echo "Missing WirePlumber sleep unit source: $unit_src" >&2
  return 1
fi

# Classify before enabling anything: uncertain custom hooks must not run in
# parallel with the new unit. Unrelated administrator behavior stays active.
legacy_kind=none
if [[ -e $legacy_hook || -L $legacy_hook ]]; then
  legacy_hash=$(sha256sum -- "$legacy_hook" 2>/dev/null || true)
  if [[ ! -f $legacy_hook || ! -r $legacy_hook ]]; then
    legacy_kind=manual
  elif [[ ${legacy_hash%% *} == "ac33c9bb2754a7810fdf33d2a312c8562ceac2d0355cf81c2c6bdf5a75683af3" ]]; then
    legacy_kind=stock
  elif grep -Eq '^[[:space:]]*(exec[[:space:]]+)?(/usr/bin/)?omarchy-system-sleep-wireplumber([[:space:]]|$)' "$legacy_hook"; then
    legacy_kind=obsolete
  elif grep -Fq 'omarchy-system-sleep-wireplumber' "$legacy_hook"; then
    legacy_kind=manual
  else
    legacy_kind=unrelated
  fi
fi
if [[ $legacy_kind == "manual" ]]; then
  echo "Customized WirePlumber sleep hook needs manual review; preserved at $legacy_hook" >&2
  return 1
fi

if [[ ! -f $unit_dst ]] || ! cmp -s "$unit_src" "$unit_dst"; then
  install -Dm644 "$unit_src" "$unit_dst"
fi
systemctl enable "$unit"

# Stock bytes may be removed; customized direct invocations are archived
# without overwrite outside system-sleep, which ignores no executable suffix.
case $legacy_kind in
  stock) rm -- "$legacy_hook" ;;
  obsolete)
    mkdir -p -- "${legacy_archive%/*}"
    mv --backup=numbered -- "$legacy_hook" "$legacy_archive"
    echo "Preserved customized obsolete WirePlumber sleep hook under ${legacy_archive%/*}"
    ;;
esac
