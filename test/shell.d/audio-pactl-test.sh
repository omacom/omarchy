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

cat >"$work/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
case ${1:-} in
  fronted-sink) exit 1 ;;
  *) exit 0 ;;
esac
SH

# Every call is logged with the locale it ran in. Listings the cases below
# vary come from $SOURCES, $SINKS and $OUTPUTS.
cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf '%s pactl %s\n' "${LC_ALL:-unset}" "$*" >>"$CALLS"
case "$*" in
  "list sink-inputs")
    cat <<'OUT'
Sink Input #42
	Sink: 10
	Properties:
		application.name = "Firefox"
		node.name = "Firefox"
OUT
    ;;
  "-f json list sinks")
    cat <<'OUT'
[
  {
    "index": 1,
    "name": "alsa_output.speakers",
    "description": "Speakers",
    "ports": [{"name": "analog-output-speakers", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "50%"}}
  },
  {
    "index": 2,
    "name": "alsa_output.headphones",
    "description": "Headphones",
    "ports": [{"name": "analog-output-headphones", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "70%"}}
  }
]
OUT
    ;;
  "get-default-sink")
    echo "alsa_output.speakers"
    ;;
  "get-sink-volume "*)
    echo "Volume: front-left: 32768 /  50% / -18.06 dB"
    ;;
  "get-sink-mute "*)
    echo "Mute: no"
    ;;
  "list sinks short")
    printf '1\talsa_output.speakers\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n'
    ;;
  "list sources") cat "$SOURCES" ;;
  "list sinks") cat "$SINKS" ;;
  "list source-outputs") cat "$OUTPUTS" ;;
esac
exit 0
SH
chmod +x "$work/bin"/*

export CALLS="$work/calls" SOURCES="$work/sources" SINKS="$work/sinks" OUTPUTS="$work/outputs"
export PATH="$work/bin:$ROOT/bin:$PATH"

calls() {
  cat "$CALLS"
}

# --- pactl output is parsed in the C locale, whatever the caller's ---

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-set-default 42 alsa_output.speakers 2>/dev/null || true
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-set-default reads sink-inputs in the C locale' "$(calls)"
grep -q 'pactl move-sink-input 42 alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-set-default moves streams' "$(calls)"
pass 'audio-output-set-default reads sink-inputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-sink "virtual_sink" >/dev/null 2>&1
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-sink reads sink-inputs in the C locale' "$(calls)"
pass 'audio-output-sink reads sink-inputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-switch 2>/dev/null || true
grep -qx 'C pactl -f json list sinks' "$CALLS" ||
  fail 'audio-output-switch reads sinks in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-volume alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink volume in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-mute alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink mute in the C locale' "$(calls)"
pass 'audio-output-switch reads pactl outputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-volume +5 2>/dev/null || true
grep -qx 'C pactl get-sink-volume alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink volume in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-mute alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink mute in the C locale' "$(calls)"
pass 'audio-output-volume reads pactl outputs in the C locale'

: >"$CALLS"
(
  eval "$(sed -n '/^app_streams() {/,/^}/p' "$ROOT/bin/omarchy-audio-tuning")"
  LC_ALL=en_US.UTF-8 app_streams 2>/dev/null >/dev/null
)
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-tuning app_streams reads sink-inputs in the C locale' "$(calls)"
pass 'audio-tuning app_streams reads sink-inputs in the C locale'

# --- omarchy-audio-sink-availability ---

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
actual=$(omarchy-audio-sink-availability sources)
[[ $actual == "$expected" ]] || fail 'source availability reports an empty jack input unavailable' "$actual"
grep -qx 'C pactl list sources' "$CALLS" || fail 'source availability reads pactl in the C locale' "$(calls)"
pass 'source availability reports an empty jack input unavailable'

: >"$CALLS"
actual=$(LC_ALL=de_DE.UTF-8 omarchy-audio-sink-availability)
[[ $actual == $'alsa_output.pci-0000_00_1f.3.analog-stereo\t0' ]] || fail 'sink availability reports an empty headphone jack unavailable' "$actual"
grep -qx 'C pactl list sinks' "$CALLS" || fail 'sink availability reads pactl in the C locale whatever the caller'"'"'s' "$(calls)"
pass 'sink availability reports an empty headphone jack unavailable, in the C locale'

# --- omarchy-audio-input-set-default ---

moved() {
  grep ' pactl move-source-output ' "$CALLS" | awk '{ print $4 }' | tr '\n' ' '
}

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
LC_ALL=en_US.UTF-8 omarchy-audio-input-set-default 113 virtual_mic
grep -qx 'wpctl set-default 113' "$CALLS" || fail 'input set-default selects the node' "$(calls)"
grep -q ' pactl set-default-source virtual_mic$' "$CALLS" || fail 'input set-default names the default source' "$(calls)"
grep -qx 'C pactl list source-outputs' "$CALLS" || fail 'input set-default reads the recordings in the C locale' "$(calls)"
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
omarchy-audio-input-set-default 43 alsa_input.pci-0000_00_1f.3.analog-stereo
[[ $(moved) == "12 13 14 " ]] || fail 'input set-default still moves every other recording' "$(moved)"
pass 'input set-default still moves every other recording'
