#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_home=$(mktemp -d)
test_bin=$(mktemp -d)

cleanup() {
  rm -rf "$test_home" "$test_bin"
}
trap cleanup EXIT

# Stub pactl for the JSON the resolver reads. The --active path only needs the
# default sink and the `-f json` listings; the results below are ALSA sinks, so
# the resolver short-circuits before its text-format DSP/EasyEffects walk.
cat >"$test_bin/pactl" <<'STUB'
#!/bin/bash
format=""
if [[ ${1:-} == "-f" ]]; then
  format="${2:-}"
  shift 2
fi
case "$format|$1|$2" in
  "|get-default-sink|") cat "$TEST_DATA/default-sink" ;;
  "json|list|sinks") cat "$TEST_DATA/sinks.json" ;;
  "json|list|sink-inputs") cat "$TEST_DATA/sink-inputs.json" ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$test_bin/pactl"

default=alsa_output.pci-0000_00_1f.3.analog-stereo
jabra=alsa_output.usb-Jabra_Link_380-00.analog-stereo
monitor=alsa_output.usb-Jabra_Link_380-00.analog-stereo.monitor
hdmi=alsa_output.pci-0000_00_1f.3.hdmi-stereo

resolve() {
  HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" TEST_DATA="$test_home/data" \
    PATH="$test_bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-sink" "$@"
}

reset_scenario() {
  rm -rf "$test_home/data"
  mkdir -p "$test_home/data"
  printf '%s\n' "$default" >"$test_home/data/default-sink"
  printf '[{"index":70,"name":"%s"},{"index":105,"name":"%s"},{"index":106,"name":"%s"},{"index":107,"name":"%s"}]\n' \
    "$default" "$jabra" "$monitor" "$hdmi" >"$test_home/data/sinks.json"
}

# With nothing playing, --active answers the default sink.
reset_scenario
printf '[]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$default" ]] || fail "an idle graph answers the default sink"
pass "--active answers the default sink when nothing is playing"

# An uncorked stream on another output wins over the default.
reset_scenario
printf '[{"index":12,"sink":105,"corked":false,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$jabra" ]] || fail "an active stream on another output answers that output"
pass "--active follows an uncorked stream onto its sink"

# A stream on the default sink keeps the default.
reset_scenario
printf '[{"index":12,"sink":70,"corked":false,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$default" ]] || fail "a stream on the default sink answers the default"
pass "--active keeps the default sink when only it is playing"

# A monitor sink is not an output.
reset_scenario
printf '[{"index":12,"sink":106,"corked":false,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$default" ]] || fail "a monitor sink is not followed"
pass "--active skips a monitor sink"

# A corked stream is not playing.
reset_scenario
printf '[{"index":12,"sink":105,"corked":true,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$default" ]] || fail "a corked stream is not followed"
pass "--active ignores a corked stream"

# A call (media.role phone) outranks background playback on another output.
reset_scenario
printf '[{"index":12,"sink":105,"corked":false,"properties":{}},{"index":13,"sink":107,"corked":false,"properties":{"media.role":"phone"}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$hdmi" ]] || fail "a communication stream outranks background playback"
pass "--active prefers a call over background playback"

# A call on the default sink still outranks music on another output: the call
# is not skipped just because it plays on the default speakers.
reset_scenario
printf '[{"index":12,"sink":70,"corked":false,"properties":{"media.role":"phone"}},{"index":13,"sink":105,"corked":false,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$default" ]] || fail "a call on the default sink outranks music elsewhere"
pass "--active keeps a call on the default sink over music on another output"

# With no call, an ordinary playback stream is still followed.
reset_scenario
printf '[{"index":12,"sink":105,"corked":false,"properties":{"media.role":"music"}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active) == "$jabra" ]] || fail "an uncorked non-call stream is followed when alone"
pass "--active follows ordinary playback when no call is playing"

# An explicit sink name still wins over --active.
reset_scenario
printf '[{"index":12,"sink":105,"corked":false,"properties":{}}]\n' >"$test_home/data/sink-inputs.json"
[[ $(resolve --active "$hdmi") == "$hdmi" ]] || fail "an explicit sink name wins over --active"
pass "--active with an explicit sink resolves that sink"
