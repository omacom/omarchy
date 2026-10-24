#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf '%s %s\n' "${LC_ALL:-unset}" "$*" >>"$CALLS"
case $* in
  "list sources") cat "$SOURCES" ;;
  "list sinks") cat "$SINKS" ;;
esac
SH
cat >"$work/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$work/bin/pactl" "$work/bin/omarchy-audio-tuning"
export CALLS="$work/calls" SOURCES="$work/sources" SINKS="$work/sinks"

# A headset jack input with nothing plugged in, a virtual source (no ports)
# and a filter's source (one port of unknown availability).
cat >"$SOURCES" <<'OUT'
Source #1074
	Name: alsa_input.pci-0000_00_1f.3.analog-stereo
	Ports:
		[In] analog-input-headset-mic: Headset Microphone (type: Headset, priority: 300, availability group: Headset Mic, not available)
	Active Port: [In] analog-input-headset-mic
	Formats:
		pcm
Source #126
	Name: easyeffects_source
	Formats:
		pcm
Source #1102
	Name: effect_output.mic-filter
	Ports:
		[In] Mic: Microphone (type: Mic, priority: 100, availability unknown)
	Active Port: [In] Mic
OUT
cat >"$SINKS" <<'OUT'
Sink #57
	Name: alsa_output.pci-0000_00_1f.3.analog-stereo
	Ports:
		[Out] analog-output-headphones: Headphones (type: Headphones, priority: 300, availability group: Headphone, not available)
	Active Port: [Out] analog-output-headphones
OUT

: >"$CALLS"
expected=$'alsa_input.pci-0000_00_1f.3.analog-stereo\t0\neasyeffects_source\t1\neffect_output.mic-filter\t1'
actual=$(PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-sink-availability" sources)
[[ $actual == "$expected" ]] || fail 'source availability reports an empty jack input unavailable' "$actual"
grep -qx 'C list sources' "$CALLS" || fail 'source availability reads pactl in the C locale' "$(cat "$CALLS")"
pass 'source availability reports an empty jack input unavailable'

: >"$CALLS"
actual=$(LC_ALL=de_DE.UTF-8 PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-sink-availability")
[[ $actual == $'alsa_output.pci-0000_00_1f.3.analog-stereo\t0' ]] || fail 'sink availability reports an empty headphone jack unavailable' "$actual"
grep -qx 'C list sinks' "$CALLS" || fail 'sink availability reads pactl in the C locale whatever the caller'"'"'s' "$(cat "$CALLS")"
pass 'sink availability reports an empty headphone jack unavailable, in the C locale'
