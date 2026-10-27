#!/bin/bash

# A tuning whose speakers share a sink with the headphone jack names the speaker
# port. Headphones switch that sink's port rather than adding a sink, so the
# tuning must step aside while they are in: hidden from the output list, and the
# default output moved off it.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/omarchy/default/audio/tunings/test-laptop" "$work/state"

speakers=alsa_output.pci-0000_00_1f.3.analog-stereo
export OMARCHY_PATH="$work/omarchy" STATE="$work/state" CALLS="$work/calls" SPEAKERS="$speakers"
export XDG_CONFIG_HOME="$work/config" PATH="$work/bin:$PATH"

tuning_conf="$OMARCHY_PATH/default/audio/tunings/test-laptop/tuning.conf"
write_tuning() {
  cat >"$tuning_conf" <<'CONF'
description="Test laptop speakers"
test_laptop() { true; }
match_command=test_laptop
sink_pattern='^alsa_output.*analog-stereo$'
CONF
  [[ -z ${1:-} ]] || printf 'speaker_port="%s"\n' "$1" >>"$tuning_conf"
}

# pactl over a tiny state: the speaker sink's active port and the default sink.
# $STATE/tuning-absent holds how many more sink listings leave the tuning sink
# out, standing in for a tuning host that is still starting.
# subscribe replays $STATE/events, one "port|default|event" step per line, and
# waits for the follower to read the port before applying the next step, so the
# follower sees every step rather than only the last.
cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf '%s pactl %s\n' "${LC_ALL:-unset}" "$*" >>"$CALLS"
reads() { grep -c 'pactl list sinks$' "$CALLS" || true; }
case "$*" in
  "list sinks short")
    printf '57\t%s\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n' "$SPEAKERS"
    absent=$(cat "$STATE/tuning-absent" 2>/dev/null || echo 0)
    if (( absent > 0 )); then
      echo $((absent - 1)) >"$STATE/tuning-absent"
    else
      printf '90\tomarchy_speaker_tuning\tPipeWire\tfloat32le 2ch 48000Hz\tRUNNING\n'
    fi
    ;;
  "list sinks")
    printf 'Sink #57\n\tName: %s\n\tPorts:\n' "$SPEAKERS"
    printf '\t\tanalog-output-speaker: Speakers (type: Speaker, priority: 10000, availability unknown)\n'
    printf '\t\tanalog-output-headphones: Headphones (type: Headphones, priority: 9900, available)\n'
    printf '\tActive Port: %s\n' "$(cat "$STATE/port")"
    ;;
  "get-default-sink") cat "$STATE/default" ;;
  "set-default-sink "*) printf '%s\n' "$2" >"$STATE/default" ;;
  "list sink-inputs")
    printf 'Sink Input #42\n\tSink: 90\n\tProperties:\n\t\tapplication.name = "Spotify"\n'
    printf 'Sink Input #43\n\tSink: 57\n\tProperties:\n\t\tnode.name = "omarchy_speaker_tuning_output"\n'
    ;;
  "subscribe")
    while IFS='|' read -r port default event; do
      seen=$(reads)
      [[ -z $port ]] || printf '%s\n' "$port" >"$STATE/port"
      [[ -z $default ]] || printf '%s\n' "$default" >"$STATE/default"
      printf "Event '%s'\n" "$event"
      # The follower only reacts to sink events.
      [[ $event == *" on sink #"* ]] || continue
      for _ in {1..100}; do
        (( $(reads) > seen )) && break
        sleep 0.05
      done
    done <"$STATE/events"
    ;;
esac
exit 0
SH
cat >"$work/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALLS"
SH
chmod +x "$work/bin"/*

tuning() {
  "$ROOT/bin/omarchy-audio-tuning" "$@"
}

# hidden-sink

write_tuning analog-output-speaker
echo analog-output-speaker >"$STATE/port"
[[ $(tuning hidden-sink) == "$speakers" ]] ||
  fail 'on the speaker port the physical sink is hidden'
pass 'on the speaker port the physical sink is hidden'

echo analog-output-headphones >"$STATE/port"
[[ $(tuning hidden-sink) == omarchy_speaker_tuning ]] ||
  fail 'with headphones in a shared jack the tuning sink is hidden'
pass 'with headphones in a shared jack the tuning sink is hidden'

write_tuning
[[ $(tuning hidden-sink) == "$speakers" ]] ||
  fail 'a tuning without speaker_port always hides the physical sink'
pass 'a tuning without speaker_port always hides the physical sink'

echo 1 >"$STATE/tuning-absent"
if tuning hidden-sink >/dev/null; then
  fail 'nothing is hidden while no tuning sink exists'
fi
pass 'nothing is hidden while no tuning sink exists'

# follow-port

: >"$CALLS"
if tuning follow-port; then :; else
  fail 'follow-port exits cleanly for a tuning without speaker_port'
fi
if grep -q subscribe "$CALLS"; then
  fail 'follow-port does not watch for a tuning without speaker_port' "$(cat "$CALLS")"
fi
pass 'follow-port does nothing for a tuning without speaker_port'

write_tuning analog-output-speaker
: >"$CALLS"
# Starts with headphones in and the tuning still the default output.
echo analog-output-headphones >"$STATE/port"
echo omarchy_speaker_tuning >"$STATE/default"
cat >"$STATE/events" <<'EVENTS'
analog-output-speaker||change' on sink #57
||change' on sink #57
analog-output-headphones|bluez_output.headset|change' on sink #57
analog-output-speaker||change' on card #48
EVENTS
if tuning follow-port; then
  fail 'follow-port fails when the audio server goes away, so systemd restarts it'
fi
pass 'follow-port fails when the audio server goes away, so systemd restarts it'

moves=$(grep -E 'pactl (set-default-sink|move-sink-input) ' "$CALLS" | sed 's/^C //; s/^unset //')
expected="pactl set-default-sink $speakers
pactl move-sink-input 42 $speakers
pactl set-default-sink omarchy_speaker_tuning
pactl move-sink-input 42 omarchy_speaker_tuning"
[[ $moves == "$expected" ]] ||
  fail 'follow-port moves the default and app streams with the port, and only those' "$moves"
pass 'follow-port moves the default and app streams with the port, and only those'
[[ $(cat "$STATE/default") == bluez_output.headset ]] ||
  fail 'follow-port leaves an output picked by hand alone' "$(cat "$STATE/default")"
pass 'follow-port leaves an output picked by hand alone'
if grep -q 'move-sink-input 43' "$CALLS"; then
  fail 'follow-port never moves the tuning output stream'
fi
pass 'follow-port never moves the tuning output stream'

# The tuning host can still be bringing its sink up when the speaker port
# returns; the follower must retry on the next sink event rather than give up.
# The tuning sink is missing from the follower's first two sink listings: the
# one finding the speakers at startup, and the one on the port change.
: >"$CALLS"
echo analog-output-headphones >"$STATE/port"
echo "$speakers" >"$STATE/default"
echo 2 >"$STATE/tuning-absent"
cat >"$STATE/events" <<'EVENTS'
analog-output-speaker||change' on sink #57
||new' on sink #90
EVENTS
tuning follow-port || true
[[ $(cat "$STATE/default") == omarchy_speaker_tuning ]] ||
  fail 'follow-port retries once the tuning sink appears' "$(cat "$CALLS")"
pass 'follow-port retries once the tuning sink appears'
