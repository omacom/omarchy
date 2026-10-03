#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home/.config"
export HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config"

cat >"$mock_bin/pactl" <<'SH'
#!/bin/bash

case "$*" in
"get-default-sink") printf '%s\n' "${TEST_DEFAULT_SINK:-easyeffects_sink}" ;;
"list sink-inputs") printf '%s' "${TEST_SINK_INPUTS:-}" ;;
"list sinks short") printf '%s' "${TEST_SINKS:-}" ;;
esac
SH

cat >"$mock_bin/pw-link" <<'SH'
#!/bin/bash
printf '%s' "${TEST_PIPEWIRE_LINKS:-}"
SH

chmod +x "$mock_bin/pactl" "$mock_bin/pw-link"

resolve_sink() {
  PATH="$mock_bin:$PATH" bash "$ROOT/bin/omarchy-audio-output-sink" "$@"
}

[[ $(resolve_sink alsa_output.pci-0000_00_1f.3.analog-stereo) == "alsa_output.pci-0000_00_1f.3.analog-stereo" ]] ||
  fail "a physical sink remains unchanged"
pass "a physical sink remains unchanged"

sink_inputs=$'Sink Input #42\n\tSink: 7\n\t\tnode.name = "easyeffects_sink.input"\n'
sinks=$'7\talsa_output.pci-0000_00_1f.3.analog-stereo\tmodule-alsa-card.c\n'
resolved=$(TEST_SINK_INPUTS="$sink_inputs" TEST_SINKS="$sinks" resolve_sink easyeffects_sink)
[[ $resolved == "alsa_output.pci-0000_00_1f.3.analog-stereo" ]] ||
  fail "the existing pactl route still resolves" "$resolved"
pass "the existing pactl route still resolves"

pipewire_links=$'easyeffects_sink:monitor_FL\n  |-> ee_soe_filter:input_FL\nee_soe_filter:output_FL\n  |-> ee_soe_equalizer:input_FL\nee_soe_equalizer:output_FL\n  |-> ee_soe_limiter:input_FL\nee_soe_limiter:output_FL\n  |-> alsa_output.pci-0000_00_1f.3.analog-stereo:playback_FL\n'
resolved=$(TEST_PIPEWIRE_LINKS="$pipewire_links" resolve_sink easyeffects_sink)
[[ $resolved == "alsa_output.pci-0000_00_1f.3.analog-stereo" ]] ||
  fail "a native EasyEffects graph resolves to its physical sink" "$resolved"
pass "a native EasyEffects graph resolves to its physical sink"

pipewire_links=$'easyeffects_sink:monitor_FL\n  |-> ee_soe_filter:input_FL\nee_soe_filter:output_FL\n  |-> ee_soe_limiter:input_FL\n'
resolved=$(TEST_PIPEWIRE_LINKS="$pipewire_links" resolve_sink easyeffects_sink)
[[ $resolved == "easyeffects_sink" ]] || fail "an idle graph falls back to the requested sink" "$resolved"
pass "an idle graph falls back to the requested sink"

bluetooth=bluez_output.00_11_22_33_44_55.1
pipewire_links=$'easyeffects_sink:monitor_FL\n  |-> ee_soe_filter:input_FL\nee_soe_filter:output_FL\n  |-> '"$bluetooth"$':playback_FL\n'
[[ $(TEST_PIPEWIRE_LINKS="$pipewire_links" resolve_sink) == "$bluetooth" ]] || fail "a Bluetooth output is resolved through its native links"
pass "native EasyEffects can target Bluetooth"

mkdir -p "$XDG_CONFIG_HOME/easyeffects/db"
printf '[StreamOutputs]\noutputDevice=%s\n' "$bluetooth" >"$XDG_CONFIG_HOME/easyeffects/db/easyeffectsrc"
sinks=$'9\t'"$bluetooth"$'\tPipeWire\n'
[[ $(TEST_SINKS="$sinks" resolve_sink) == "$bluetooth" ]] || fail "idle EasyEffects uses its configured sink"
[[ $(resolve_sink) == "easyeffects_sink" ]] || fail "a missing configured sink is not returned"
pass "idle EasyEffects uses an available configured output and ignores disconnected devices"

for order in forward reverse; do
  outputs=$'  |-> alsa_output.other:playback_FL\n  |-> '"$bluetooth"$':playback_FL\n'
  [[ $order != "reverse" ]] || outputs=$'  |-> '"$bluetooth"$':playback_FL\n  |-> alsa_output.other:playback_FL\n'
  graph=$'easyeffects_sink:monitor_FL\n  |-> ee_soe_filter:input_FL\nee_soe_filter:output_FL\n'"$outputs"
  [[ $(TEST_PIPEWIRE_LINKS="$graph" TEST_SINKS="$sinks" resolve_sink) == "$bluetooth" ]] || fail "the configured output wins regardless of graph order"
  mv "$XDG_CONFIG_HOME/easyeffects/db/easyeffectsrc" "$test_tmp/easyeffectsrc"
  [[ $(TEST_PIPEWIRE_LINKS="$graph" resolve_sink) == "easyeffects_sink" ]] || fail "ambiguous graph order is not guessed"
  mv "$test_tmp/easyeffectsrc" "$XDG_CONFIG_HOME/easyeffects/db/easyeffectsrc"
done
pass "multiple graph outputs use the selected device without depending on link order"
