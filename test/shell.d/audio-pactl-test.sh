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
  fronted-sink)
    [[ -s $TUNING_FRONTED ]] || exit 1
    cat "$TUNING_FRONTED"
    ;;
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
    cat "$SINKS_JSON"
    ;;
  "get-default-sink")
    cat "$DEFAULT_SINK"
    ;;
  "get-sink-volume "*)
    echo "Volume: front-left: 32768 /  50% / -18.06 dB"
    ;;
  "get-sink-mute "*)
    echo "Mute: no"
    ;;
  "set-default-sink "*)
    echo "${*:2}" >"$DEFAULT_SINK"
    ;;
  "list sinks short" | "list short sinks")
    cat "$SHORT_SINKS"
    ;;
  "list short modules")
    cat "$MODULES"
    ;;
  "load-module module-combine-sink "*)
    id=$((900 + $(wc -l <"$MODULES")))
    args=${*:3}
    printf '%s\tmodule-combine-sink\t%s\n' "$id" "$args" >>"$MODULES"
    name=$(sed -n 's/.*sink_name=\([^ ]*\).*/\1/p' <<<"$args")
    printf '%s\t%s\tPipeWire\tfloat32le 2ch 48000Hz\tSUSPENDED\n' "$id" "$name" >>"$SHORT_SINKS"
    echo "$id"
    ;;
  "unload-module "*)
    id=${*:2}
    awk -v id="$id" '$1 != id' "$MODULES" >"$MODULES.next" && mv "$MODULES.next" "$MODULES"
    awk -v id="$id" '$1 != id' "$SHORT_SINKS" >"$SHORT_SINKS.next" && mv "$SHORT_SINKS.next" "$SHORT_SINKS"
    ;;
  "list sources") cat "$SOURCES" ;;
  "list sinks") cat "$SINKS" ;;
  "list source-outputs") cat "$OUTPUTS" ;;
esac
exit 0
SH
chmod +x "$work/bin"/*

export CALLS="$work/calls" SOURCES="$work/sources" SINKS="$work/sinks" OUTPUTS="$work/outputs"
export SINKS_JSON="$work/sinks.json" SHORT_SINKS="$work/short-sinks"
export DEFAULT_SINK="$work/default-sink" MODULES="$work/modules"
export TUNING_FRONTED="$work/tuning-fronted"
export XDG_RUNTIME_DIR="$work/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
: >"$TUNING_FRONTED"
export PATH="$work/bin:$ROOT/bin:$PATH"

cat >"$SINKS_JSON" <<'OUT'
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
printf '1\talsa_output.speakers\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n' >"$SHORT_SINKS"
echo "alsa_output.speakers" >"$DEFAULT_SINK"
: >"$MODULES"

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

# The switcher above selected the headphones; this case only checks the locale.
echo "alsa_output.speakers" >"$DEFAULT_SINK"
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

# --- omarchy-audio-output-combine ---

# A USB speaker, a Bluetooth headset, an HDMI port nothing is plugged into, and
# a virtual EasyEffects sink. Only the first two are outputs a person can share
# to.
reset_combine() {
  : >"$MODULES"
  printf '1\talsa_output.speakers\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n2\tbluez_output.headset\tPipeWire\ts16le 2ch 48000Hz\tRUNNING\n3\talsa_output.hdmi\tPipeWire\ts32le 2ch 48000Hz\tSUSPENDED\n' >"$SHORT_SINKS"
  cat >"$SINKS_JSON" <<'OUT'
[
  {"index": 1, "name": "alsa_output.speakers", "description": "Speakers", "ports": [{"availability": "available"}]},
  {"index": 2, "name": "bluez_output.headset", "description": "Headset", "ports": []},
  {"index": 3, "name": "alsa_output.hdmi", "description": "HDMI", "ports": [{"availability": "not available"}]},
  {"index": 4, "name": "easyeffects_sink", "description": "EasyEffects", "ports": []}
]
OUT
  echo "bluez_output.headset" >"$DEFAULT_SINK"
  : >"$TUNING_FRONTED"
  rm -f "$XDG_RUNTIME_DIR/omarchy-audio-output-combine.previous"
}

reset_combine
: >"$CALLS"
omarchy-audio-output-combine on
grep -q 'pactl load-module module-combine-sink sink_name=omarchy_combined_output slaves=alsa_output.speakers,bluez_output.headset$' "$CALLS" ||
  fail 'combine shares to plugged-in physical outputs only' "$(calls)"
[[ $(cat "$DEFAULT_SINK") == "omarchy_combined_output" ]] ||
  fail 'combine selects the combined output' "$(cat "$DEFAULT_SINK")"
grep -q ' pactl set-sink-volume omarchy_combined_output 50%$' "$CALLS" ||
  fail 'combine keeps the volume of the output it replaces' "$(calls)"
[[ $(omarchy-audio-output-combine status) == "on" ]] || fail 'combine reports on'
pass 'combine shares to plugged-in physical outputs only'

: >"$CALLS"
omarchy-audio-output-combine on
[[ $(grep -c 'load-module module-combine-sink' "$CALLS") == 0 ]] ||
  fail 'combine on is idempotent' "$(calls)"
pass 'combine on is idempotent'

: >"$CALLS"
omarchy-audio-output-combine off
grep -q 'pactl unload-module 900$' "$CALLS" || fail 'combine off removes the module' "$(calls)"
[[ $(cat "$DEFAULT_SINK") == "bluez_output.headset" ]] ||
  fail 'combine off restores the output it replaced' "$(cat "$DEFAULT_SINK")"
[[ $(omarchy-audio-output-combine status) == "off" ]] || fail 'combine reports off'
pass 'combine off restores the output it replaced'

reset_combine
omarchy-audio-output-combine toggle
[[ $(omarchy-audio-output-combine status) == "on" ]] || fail 'combine toggle turns on'
omarchy-audio-output-combine toggle
[[ $(omarchy-audio-output-combine status) == "off" ]] || fail 'combine toggle turns off'
pass 'combine toggles both ways'

# One output is not a choice, so the command refuses before touching the graph.
reset_combine
cat >"$SINKS_JSON" <<'OUT'
[
  {"index": 1, "name": "alsa_output.speakers", "description": "Speakers", "ports": [{"availability": "available"}]},
  {"index": 2, "name": "easyeffects_sink", "description": "EasyEffects", "ports": []}
]
OUT
: >"$CALLS"
if omarchy-audio-output-combine on 2>/dev/null; then
  fail 'combine refuses a single output'
fi
grep -q 'load-module' "$CALLS" && fail 'a refused combine loads no module' "$(calls)"
[[ $(cat "$DEFAULT_SINK") == "bluez_output.headset" ]] ||
  fail 'a refused combine leaves the default alone' "$(cat "$DEFAULT_SINK")"
pass 'combine refuses a single output'

# The speakers a tuning fronts are skipped, as they are by the output switcher:
# the tuning sink is the output people see, and sharing onto the raw hardware
# would play around it. HDMI is plugged in here so a share still exists.
reset_combine
echo "alsa_output.speakers" >"$TUNING_FRONTED"
cat >"$SINKS_JSON" <<'OUT'
[
  {"index": 1, "name": "alsa_output.speakers", "description": "Speakers", "ports": [{"availability": "available"}]},
  {"index": 2, "name": "bluez_output.headset", "description": "Headset", "ports": []},
  {"index": 3, "name": "alsa_output.hdmi", "description": "HDMI", "ports": [{"availability": "available"}]}
]
OUT
: >"$CALLS"
omarchy-audio-output-combine on
grep -q 'slaves=bluez_output.headset,alsa_output.hdmi,omarchy_speaker_tuning$' "$CALLS" ||
  fail 'combine shares through the tuning instead of around it' "$(calls)"
pass 'combine shares through the tuning instead of around it'
