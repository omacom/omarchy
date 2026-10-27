#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)

cleanup() {
  rm -rf "$test_home" "$test_bin"
}
trap cleanup EXIT

# Stub PipeWire's clients: the default sink, the sink list, the sink inputs and
# the port links are all data files the test writes per scenario.
cat >"$test_bin/pactl" <<'STUB'
#!/bin/bash
case "$1 $2" in
  "get-default-sink ") cat "$TEST_DATA/default-sink" ;;
  "list sinks") cat "$TEST_DATA/sinks" ;;
  "list sink-inputs") cat "$TEST_DATA/sink-inputs" 2>/dev/null ;;
  *) exit 1 ;;
esac
STUB
cat >"$test_bin/pw-link" <<'STUB'
#!/bin/bash
cat "$TEST_DATA/links" 2>/dev/null
STUB
chmod +x "$test_bin/pactl" "$test_bin/pw-link"

physical=alsa_output.pci-0000_00_1f.3.analog-surround-40

resolve() {
  HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" TEST_DATA="$test_home/data" \
    PATH="$test_bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-sink" "$@"
}

reset_scenario() {
  rm -rf "$test_home/data" "$test_home/.config"
  mkdir -p "$test_home/data"
  printf '%s\n' easyeffects_sink >"$test_home/data/default-sink"
  printf '267\t%s\tPipeWire\ts32le 4ch 44100Hz\tRUNNING\n870\teasyeffects_sink\tPipeWire\tfloat32le 2ch 48000Hz\tRUNNING\n' \
    "$physical" >"$test_home/data/sinks"
}

# A physical default is returned as is.
reset_scenario
printf '%s\n' "$physical" >"$test_home/data/default-sink"
[[ $(resolve) == "$physical" ]] || fail "a physical default sink resolves to itself"
pass "physical default sink resolves to itself"

# EasyEffects 8 playing: its output ports are linked straight to the card.
reset_scenario
cat >"$test_home/data/links" <<LINKS
ee_soe_output_level:output_FL
  |-> $physical:playback_FL
ee_soe_output_level:output_FR
  |-> $physical:playback_FR
ee_soe_output_level:input_FL
  |<- ee_soe_limiter:output_FL
LINKS
[[ $(resolve) == "$physical" ]] || fail "easyeffects_sink resolves through the port links to the card"
pass "easyeffects_sink resolves through its port links"

# EasyEffects 8 playing into Bluetooth headphones: the live links win over a
# settings file that still names the speakers.
headphones=bluez_output.00_11_22_33_44_55.1
reset_scenario
printf '301\t%s\tPipeWire\ts16le 2ch 48000Hz\tRUNNING\n' "$headphones" >>"$test_home/data/sinks"
cat >"$test_home/data/links" <<LINKS
ee_soe_output_level:output_FL
  |-> $headphones:playback_FL
ee_soe_output_level:output_FR
  |-> $headphones:playback_FR
LINKS
mkdir -p "$test_home/.config/easyeffects/db"
printf '[StreamOutputs]\noutputDevice=%s\n' "$physical" >"$test_home/.config/easyeffects/db/easyeffectsrc"
[[ $(resolve) == "$headphones" ]] || fail "easyeffects_sink resolves through its port links to Bluetooth headphones"
pass "easyeffects_sink resolves through its port links to Bluetooth headphones"

# EasyEffects 8 idle: no links, but its settings name the output device.
reset_scenario
mkdir -p "$test_home/.config/easyeffects/db"
printf '[StreamOutputs]\noutputDevice=%s\n' "$physical" >"$test_home/.config/easyeffects/db/easyeffectsrc"
[[ $(resolve) == "$physical" ]] || fail "idle easyeffects_sink resolves through the configured output device"
pass "idle easyeffects_sink resolves through the configured output device"

# A configured device that is gone (headphones unplugged) is not returned.
reset_scenario
mkdir -p "$test_home/.config/easyeffects/db"
printf '[StreamOutputs]\noutputDevice=alsa_output.usb-gone.analog-stereo\n' >"$test_home/.config/easyeffects/db/easyeffectsrc"
[[ $(resolve) == "easyeffects_sink" ]] || fail "a configured device that no longer exists falls back to the DSP sink"
pass "missing configured device falls back to the DSP sink"

# The stream-based resolution (filter-chain tunings) still comes first.
reset_scenario
printf '%s\n' omarchy_speaker_tuning >"$test_home/data/default-sink"
cat >"$test_home/data/sink-inputs" <<INPUTS
Sink Input #42
	Sink: 267
	Properties:
		node.name = "omarchy_speaker_tuning.stream"
INPUTS
[[ $(resolve) == "$physical" ]] || fail "a filter-chain tuning still resolves through its stream"
pass "filter-chain tuning resolves through its stream"

# The shipped tuning uses an underscore before its output stream suffix.
reset_scenario
printf '%s\n' omarchy_speaker_tuning >"$test_home/data/default-sink"
printf 'Sink Input #42\n  Sink: 267\n  node.name = "omarchy_speaker_tuning_output"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "the shipped tuning output still resolves through its stream"
pass "shipped tuning output resolves through its stream"

# Keep custom stream suffixes that the existing prefix rule already handles.
printf 'Sink Input #42\n  Sink: 267\n  node.name = "omarchy_speaker_tuning-playback"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "custom legacy tuning suffixes still resolve"
pass "custom legacy tuning suffixes still resolve"

# Reproduce the reported input/output naming pair and downstream sink ID.
reset_scenario
filter=effect_input.Dolby_Balanced
printf '%s\n' "$filter" >"$test_home/data/default-sink"
printf '68\t%s\tPipeWire\ts32le 4ch 44100Hz\tRUNNING\n' "$physical" >"$test_home/data/sinks"
printf 'Sink Input #42\n  Sink: 68\n  node.name = "effect_output.Dolby_Balanced"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "the reported effect_input/effect_output pair resolves downstream"
pass "reported effect_input/effect_output pair resolves downstream"

# An explicitly requested filter resolves even when another output is default.
printf '%s\n' "$headphones" >"$test_home/data/default-sink"
[[ $(resolve "$filter") == "$physical" ]] || fail "an explicit filter resolves independently of the default"
pass "explicit filter resolves independently of the default"
printf '%s\n' "$filter" >"$test_home/data/default-sink"

# An effect_input sink can also use a legacy prefix-compatible output name.
printf 'Sink Input #42\n  Sink: 68\n  node.name = "effect_input.Dolby_Balanced.playback"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "effect_input sinks preserve prefix-compatible outputs"
pass "effect_input sinks preserve prefix-compatible outputs"

# A similarly named output must not win just because it appears first.
printf '301\t%s\tPipeWire\ts16le 2ch 48000Hz\tRUNNING\n' "$headphones" >>"$test_home/data/sinks"
printf 'Sink Input #41\n  Sink: 301\n  node.name = "effect_output.Dolby_Balanced2"\nSink Input #42\n  Sink: 68\n  node.name = "effect_output.Dolby_Balanced"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "a filter output matches the complete suffix"
pass "filter output matches the complete suffix"

# The exact paired output wins over an earlier competing legacy prefix.
printf 'Sink Input #41\n  Sink: 301\n  node.name = "effect_input.Dolby_Balanced2.playback"\nSink Input #42\n  Sink: 68\n  node.name = "effect_output.Dolby_Balanced"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "the exact output wins over a competing legacy prefix"
pass "exact output wins over a competing legacy prefix"

printf 'Sink Input #41\n  Sink: 301\n  node.name = "effect_input.Dolby_Balanced.playback"\nSink Input #42\n  Sink: 68\n  node.name = "effect_output.Dolby_Balanced"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$physical" ]] || fail "the exact output wins over a valid legacy fallback"
pass "exact output wins over a valid legacy fallback"

printf 'Sink Input #41\n  Sink: 301\n  node.name = "effect_output.Dolby_Balanced2"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$filter" ]] || fail "a filter with no exact output falls back to itself"
pass "filter with no exact output falls back to itself"

# A stale sink ID must not turn into a different output.
printf 'Sink Input #42\n  Sink: 999\n  node.name = "effect_output.Dolby_Balanced"\n' >"$test_home/data/sink-inputs"
[[ $(resolve) == "$filter" ]] || fail "a missing downstream sink falls back to the filter"
pass "missing downstream sink falls back to the filter"
