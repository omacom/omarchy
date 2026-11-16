#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

# The default source is a microphone muted or not as $MIC_STATE says, which
# set-mute toggles. With no file wpctl answers as the real one does with no
# microphone: an error on stderr, nothing on stdout, exit 0.
cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
state=$(cat "$MIC_STATE" 2>/dev/null)
case "$*" in
  "get-volume @DEFAULT_AUDIO_SOURCE@")
    if [[ -z $state ]]; then
      echo "Translate ID error: '-1' is not a valid ID (returned by default-nodes-api)" >&2
    elif [[ $state == "muted" ]]; then
      echo "Volume: 1.00 [MUTED]"
    else
      echo "Volume: 1.00"
    fi
    ;;
  "set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    if [[ $state == "muted" ]]; then echo on >"$MIC_STATE"; else echo muted >"$MIC_STATE"; fi
    ;;
esac
SH

cat >"$work/bin/omarchy-brightness-keyboard-mute" <<'SH'
#!/bin/bash
printf 'omarchy-brightness-keyboard-mute %s\n' "$*" >>"$CALLS"
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
    # SINKS_HOLD parks this call mid-read until the test releases it.
    if [[ -n ${SINKS_HOLD:-} ]]; then
      touch "$SINKS_HOLD.reached"
      for _ in {1..100}; do
        [[ -e $SINKS_HOLD.release ]] && break
        sleep 0.05
      done
    fi
    if [[ -n ${SINKS_JSON:-} ]]; then
      cat "$SINKS_JSON"
      exit 0
    fi
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

export MIC_STATE="$work/mic" CALLS="$work/calls" SOURCES="$work/sources" SINKS="$work/sinks" OUTPUTS="$work/outputs"
export XDG_RUNTIME_DIR="$work/run"
mkdir -p "$XDG_RUNTIME_DIR"
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

# --- omarchy-audio-output-set-default keeps the default following hotplug ---

# Speakers behind a DSP sink (850), a headphone jack (1000) and DisplayPort.
sinks_json() {
  local headphones=$1 display_priority=$2
  cat >"$work/sinks.json" <<OUT
[
  {"index": 1, "name": "speakers", "ports": [], "properties": {"priority.session": "850"}},
  {"index": 2, "name": "headphones",
   "ports": [{"name": "Headphones", "availability": "$headphones"}],
   "properties": {"priority.session": "1000"}},
  {"index": 3, "name": "display",
   "ports": [{"name": "HDMI1", "availability": "available"}],
   "properties": {"priority.session": "$display_priority"}}
]
OUT
}
cleared() {
  grep -qx 'wpctl clear-default 0' "$CALLS"
}
export SINKS_JSON="$work/sinks.json"

sinks_json available 500
: >"$CALLS"
omarchy-audio-output-set-default 2 headphones
cleared || fail 'choosing the output WirePlumber would pick forgets the saved choice' "$(calls)"
grep -q '^wpctl set-default 2$' "$CALLS" || fail 'the chosen output still becomes the default at once' "$(calls)"
pass 'choosing the output WirePlumber would pick forgets the saved choice'

: >"$CALLS"
omarchy-audio-output-set-default 1 speakers
! cleared || fail 'choosing the speakers while headphones are in stays saved' "$(calls)"
pass 'choosing the speakers while headphones are in stays saved'

sinks_json "not available" 500
: >"$CALLS"
omarchy-audio-output-set-default 1 speakers
cleared || fail 'choosing the speakers with the jack empty forgets the saved choice' "$(calls)"
pass 'choosing the speakers with the jack empty forgets the saved choice'

sinks_json available 1000
: >"$CALLS"
omarchy-audio-output-set-default 2 headphones
! cleared || fail 'a choice between outputs of equal priority stays saved' "$(calls)"
pass 'a choice between outputs of equal priority stays saved'

# Picks made while an earlier pick is still working. The headphones call is
# parked reading the sinks; the display and then the speakers are picked behind
# it. The speakers are the last pick, so they must end up saved: the headphones
# call's clear-default may not land after them, and the display call, which a
# newer pick overtook, does nothing.
latest_request() {
  cat "$XDG_RUNTIME_DIR/omarchy-audio-output-default-$UID.latest" 2>/dev/null || true
}
wait_for() {
  local _
  for _ in {1..100}; do
    eval "$1" && return 0
    sleep 0.05
  done
  fail "$2" "$(calls)"
}
sinks_json available 500
: >"$CALLS"
rm -f "$work/hold".*
SINKS_HOLD="$work/hold" omarchy-audio-output-set-default 2 headphones &
first=$!
wait_for '[[ -e $work/hold.reached ]]' 'the first pick reaches the sink listing'
before=$(latest_request)
omarchy-audio-output-set-default 3 display &
second=$!
wait_for '[[ $(latest_request) != "$before" ]] || grep -qx "wpctl set-default 3" "$CALLS"' 'the second pick queues or runs'
before=$(latest_request)
omarchy-audio-output-set-default 1 speakers &
third=$!
wait_for '[[ $(latest_request) != "$before" ]] || grep -qx "wpctl set-default 1" "$CALLS"' 'the third pick queues or runs'
touch "$work/hold.release"
wait "$first" "$second" "$third"
[[ $(grep '^wpctl ' "$CALLS" | tail -n 1) == "wpctl set-default 1" ]] ||
  fail 'the last of several quick picks stays the default' "$(calls)"
! grep -qx 'wpctl set-default 3' "$CALLS" ||
  fail 'a pick overtaken by a newer one leaves it alone' "$(calls)"
pass 'the last of several quick picks stays the default'
unset SINKS_JSON

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

# --- omarchy-audio-input-mute ---

rm -f "$MIC_STATE"
: >"$CALLS"
if omarchy-audio-input-mute 2>"$work/err"; then
  fail 'input mute with no microphone fails' "$(calls)"
fi
grep -qx 'No microphone found.' "$work/err" || fail 'input mute with no microphone says so' "$(cat "$work/err")"
grep -qx 'omarchy-osd -i microphone-off -m No microphone found' "$CALLS" ||
  fail 'input mute with no microphone shows it' "$(calls)"
! grep -qE 'set-mute|keyboard-mute' "$CALLS" ||
  fail 'input mute with no microphone toggles nothing' "$(calls)"
pass 'input mute says there is no microphone, and toggles nothing'

echo on >"$MIC_STATE"
: >"$CALLS"
omarchy-audio-input-mute || fail 'input mute with a microphone succeeds' "$(calls)"
[[ $(cat "$MIC_STATE") == "muted" ]] || fail 'input mute toggles the microphone' "$(calls)"
grep -qx 'omarchy-brightness-keyboard-mute on' "$CALLS" &&
  grep -qx 'omarchy-osd -i microphone-muted -m Microphone muted' "$CALLS" ||
  fail 'input mute shows the microphone muted after muting it' "$(calls)"
: >"$CALLS"
omarchy-audio-input-mute || fail 'input mute with a muted microphone succeeds' "$(calls)"
[[ $(cat "$MIC_STATE") == "on" ]] || fail 'input mute unmutes a muted microphone' "$(calls)"
grep -qx 'omarchy-brightness-keyboard-mute off' "$CALLS" &&
  grep -qx 'omarchy-osd -i microphone -m Microphone on' "$CALLS" ||
  fail 'input mute shows the microphone on after unmuting it' "$(calls)"
pass 'input mute still toggles a microphone and shows what it became'

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
