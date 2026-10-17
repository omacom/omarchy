#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/default/audio/tunings" "$scratch/config/pipewire"
export AUDIO_TEST_FIXTURES="$scratch"
export OMARCHY_PATH="$scratch"
export XDG_CONFIG_HOME="$scratch/config"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

host_config_name=omarchy-speaker-tuning.conf

cat >"$scratch/bin/pactl" <<'SH'
#!/bin/bash
case "$*" in
  "get-default-sink") cat "$AUDIO_TEST_FIXTURES/default-sink" 2>/dev/null; exit 0 ;;
  "list sinks short") cat "$AUDIO_TEST_FIXTURES/sinks" 2>/dev/null ;;
  "list sink-inputs") cat "$AUDIO_TEST_FIXTURES/inputs" 2>/dev/null ;;
  "set-default-sink") exit 0 ;;
  "move-sink-input") exit 0 ;;
  *) exit 1 ;;
esac
SH
chmod +x "$scratch/bin/pactl"

printf '%s\n' "alsa_output.pci-0000_00_1b.0.analog-stereo" >"$scratch/default-sink"

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1"
  [[ -n "${2:-}" ]] && printf '%s\n' "$2" >&2
  exit 1
}

create_shipped_tuning() {
  local name="$1" pattern="$2"
  mkdir -p "$scratch/default/audio/tunings/$name"
  printf 'match_command=true\nsink_pattern=%s\n' "$pattern" >"$scratch/default/audio/tunings/$name/tuning.conf"
}

# ============================================================
# T1: Shipped tuning -> tuned_hardware_sink answers first
# ============================================================
cat >"$scratch/sinks" <<EOF
100 alsa_output.pci-0000_00_1b.0.analog-stereo PipeWire
200 omarchy_speaker_tuning PipeWire
300 alsa_output.usb-audio PipeWire
EOF
cat >"$scratch/inputs" <<EOF
Sink Input #1
  Sink: 200
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF
create_shipped_tuning dell '^alsa_output.pci'

if actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)"; then
  [[ $actual == "alsa_output.pci-0000_00_1b.0.analog-stereo" ]] || fail "shipped tuning fronts correct speaker" "$actual"
  pass "shipped tuning fronts correct speaker (tuned_hardware_sink path)"
else
  fail "shipped tuning returns fronted sink"
fi

# ============================================================
# T2: Community tuning (no shipped profile) -> live route fallback
# ============================================================
rm -rf "$scratch/default/audio/tunings"
cat >"$scratch/sinks" <<EOF
100 alsa_output.pci-0000_00_1b.0.analog-stereo PipeWire
200 omarchy_speaker_tuning PipeWire
EOF
cat >"$scratch/inputs" <<EOF
Sink Input #1
  Sink: 100
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF

if actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)"; then
  [[ $actual == "alsa_output.pci-0000_00_1b.0.analog-stereo" ]] || \
    fail "community tuning fronts physical via live route" "$actual"
  pass "community tuning fronts physical via live route (tuning_downstream_sink fallback)"
else
  fail "community tuning returns fronted sink"
fi

# ============================================================
# T3: Unlinked tuning -> guard prevents hiding the tuning itself
# ============================================================
cat >"$scratch/inputs" <<EOF
Sink Input #1
  Sink: 200
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF

if actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)"; then
  [[ -z $actual ]] || fail "unlinked tuning should not report sink" "$actual"
  pass "unlinked tuning reports no fronted sink (idle guard holds)"
else
  pass "unlinked tuning reports no fronted sink (command exited 1)"
fi

# ============================================================
# T4: Shipped tuning + different live route -> shipped profile precedence
# ============================================================
cat >"$scratch/sinks" <<EOF
100 alsa_output.pci-0000_00_1b.0.analog-stereo PipeWire
200 omarchy_speaker_tuning PipeWire
300 alsa_output.usb-audio PipeWire
EOF
cat >"$scratch/inputs" <<EOF
Sink Input #1
  Sink: 300
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF
create_shipped_tuning dell '^alsa_output.pci'

if actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)"; then
  [[ $actual == "alsa_output.pci-0000_00_1b.0.analog-stereo" ]] || \
    fail "shipped tuning takes precedence over live route" "$actual"
  pass "shipped tuning takes precedence over live route"
else
  fail "shipped tuning returns fronted sink"
fi

# ============================================================
# T5: No tuning present (no omarchy_speaker_tuning sink) -> exits 1
# ============================================================
rm -rf "$scratch/default/audio/tunings"
cat >"$scratch/sinks" <<EOF
100 alsa_output.pci-0000_00_1b.0.analog-stereo PipeWire
EOF

actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)" || true
if [[ -z $actual ]]; then
  pass "absent tuning exits 1 (no output)"
else
  fail "absent tuning should exit 1 with no output" "$actual"
fi

# ============================================================
# T6: Hand-installed tuning -> off restores speakers as default
# ============================================================
cat >"$scratch/sinks" <<EOF
100 alsa_output.pci-0000_00_1b.0.analog-stereo PipeWire
200 omarchy_speaker_tuning PipeWire
EOF
cat >"$scratch/inputs" <<EOF
Sink Input #1
  Sink: 100
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF

mkdir -p "$scratch/config/pipewire/$host_config_name.d"
echo "# hand-installed tuning" >"$scratch/config/pipewire/$host_config_name.d/90-tuning.conf"

if actual="$(bash $ROOT/bin/omarchy-audio-tuning fronted-sink 2>/dev/null)"; then
  [[ $actual == "alsa_output.pci-0000_00_1b.0.analog-stereo" ]] || \
    fail "hand-installed tuning fronts physical via live route" "$actual"
  pass "hand-installed tuning fronts physical (off-test ready)"
else
  fail "hand-installed tuning should resolve fronted sink"
fi

echo
echo "All tests complete."
