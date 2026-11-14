echo "Clear SoundWire routes the retired N1x UCM profiles left in the saved mixer state"

# Omarchy's own MT8901 UCM profiles, replaced by NVIDIA's in 3a209895e4, routed
# PDI2 to DP3 (ASUS ProArt P14) and PDI7/PDI8 to codec ports (ProArt P14 and
# Dell XPS 16). alsactl saved those routes and restores them every boot, and
# NVIDIA's profiles only set the routes they use, so a host port ends up fed by
# two PDIs. The MT8901 SoundWire driver then rejects the 2-channel speaker and
# microphone streams with EINVAL, PipeWire drops the HiFi profile, and the
# internal speakers and microphones vanish. No current profile routes PDI7 or
# PDI8, or PDI2 to DP3, so those values can only be leftovers.
if ! omarchy-hw-aarch64-n1x; then
  exit 0
fi

card=mt8901soundwire
state_file="${OMARCHY_ALSA_STATE:-/var/lib/alsa/asound.state}"
card_path="${OMARCHY_PROC_ROOT:-/proc}/asound/$card"

# amixer can't find a card the user has no seat ACL for (an update over SSH),
# so ask the kernel whether it exists, and fail rather than complete unrepaired.
if [[ ! -e $card_path ]]; then
  exit 0
fi

amixer -c "$card" info >/dev/null

live_route() {
  amixer -c "$card" sget "$1" | sed -n "s/^  Item0: '\(.*\)'$/\1/p"
}

saved_route() {
  if [[ -e $state_file ]]; then
    awk -v card="state.$card" -v name="name '$1'" '
      /^state\./ { in_card = ($1 == card) }
      in_card && $0 ~ "^[ \t]*" name "$" { found = 1; next }
      found && $1 == "value" { print $2; exit }
    ' "$state_file"
  fi
}

stale_route() {
  if [[ $1 == "PDI2 Demux" ]]; then
    [[ $2 == "DP3" ]]
  else
    [[ -n $2 && $2 != "None" ]]
  fi
}

live_stale=()
saved_stale=0

for control in "PDI2 Demux" "PDI7 Mux" "PDI8 Mux"; do
  if stale_route "$control" "$(live_route "$control")"; then
    live_stale+=("$control")
  fi
  # A control this card lacks reads as not stale, but a state file that can't
  # be read fails the run rather than passing for clean.
  saved=$(saved_route "$control")
  if stale_route "$control" "$saved"; then
    saved_stale=1
  fi
done

if (( ${#live_stale[@]} == 0 && saved_stale == 0 )); then
  exit 0
fi

for control in "${live_stale[@]}"; do
  amixer -q -c "$card" cset name="$control" None
done

# Save even when only the saved state is stale: a run whose save failed has
# already cleared the live routes, and the next boot would restore the old ones.
sudo alsactl store "$card"

# PipeWire only probes the card's UCM profiles when WirePlumber opens it.
systemctl --user try-restart wireplumber.service 2>/dev/null || true
