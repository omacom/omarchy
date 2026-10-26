#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
SH
cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf 'pactl %s\n' "$*" >>"$CALLS"
if [[ $* == "list source-outputs" ]]; then
  [[ ${LC_ALL:-} == C ]] || echo "pactl read outside the C locale" >>"$CALLS"
  cat "$OUTPUTS"
fi
exit 0
SH
chmod +x "$work/bin/wpctl" "$work/bin/pactl"

moved() {
  grep '^pactl move-source-output ' "$CALLS" | awk '{ print $3 }' | tr '\n' ' '
}

export CALLS="$work/calls" OUTPUTS="$work/outputs"

# A filter chain's capture half (joined to its source by node.link-group)
# records its device all the time. Choosing an input moves apps, never it.
cat >"$OUTPUTS" <<'OUT'
Source Output #67
	Driver: PipeWire
	Properties:
		node.name = "filter_capture.mic"
		node.group = "filter-chain-100-18"
		node.link-group = "filter-chain-100-18"
		media.name = "Microphone filter"
Source Output #90
	Driver: PipeWire
	Properties:
		application.name = "Firefox"
		node.name = "Firefox"
Source Output #91
	Properties:
		node.name = "native-recorder"
		media.name = "node.link-group = in a title"
OUT
: >"$CALLS"
PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-input-set-default" 113 virtual_mic
grep -qx 'wpctl set-default 113' "$CALLS" || fail 'input set-default selects the node'
grep -qx 'pactl set-default-source virtual_mic' "$CALLS" || fail 'input set-default names the default source'
! grep -q 'outside the C locale' "$CALLS" || fail 'input set-default reads the recordings in the C locale'
[[ $(moved) == "90 91 " ]] || fail 'input set-default moves apps but not a filter'"'"'s own capture' "$(moved)"
pass 'input set-default moves apps but not a filter'"'"'s own capture'

# Without filters every recording moves, as before, whatever its properties.
cat >"$OUTPUTS" <<'OUT'
Source Output #12
	Properties:
		application.name = "OBS"
Source Output #13
	Properties:
		node.name = "native-recorder"
Source Output #14
	Properties:
		node.name = "filter_capture.mic-copy"
		node.group = "pipewire.dummy"
OUT
: >"$CALLS"
PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-input-set-default" 43 alsa_input.pci-0000_00_1f.3.analog-stereo
[[ $(moved) == "12 13 14 " ]] || fail 'input set-default still moves every other recording' "$(moved)"
pass 'input set-default still moves every other recording'
