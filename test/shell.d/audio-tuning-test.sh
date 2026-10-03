#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/default/audio/tunings"
export AUDIO_TEST_FIXTURES="$scratch"
export OMARCHY_PATH="$scratch"
export XDG_CONFIG_HOME="$scratch/config"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat >"$scratch/bin/pactl" <<'SH'
#!/bin/bash
case "$*" in
  "list sinks short") cat "$AUDIO_TEST_FIXTURES/sinks" ;;
  "list sink-inputs") cat "$AUDIO_TEST_FIXTURES/inputs" ;;
  *) exit 1 ;;
esac
SH
chmod +x "$scratch/bin/pactl"

cat >"$scratch/sinks" <<'EOF'
1 alsa_output.speakers PipeWire
2 omarchy_speaker_tuning PipeWire
3 alsa_output.headphones PipeWire
EOF
cat >"$scratch/inputs" <<'EOF'
Sink Input #42
  Sink: 1
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF

fronted_sink() {
  bash "$ROOT/bin/omarchy-audio-tuning" fronted-sink
}

actual="$(fronted_sink)" || fail "community tuning resolves without a shipped hardware profile"
[[ $actual == "alsa_output.speakers" ]] || fail "community tuning fronts its physical speakers" "$actual"
pass "community tuning fronts its physical speakers without a shipped profile"

# An unlinked community filter must not hide itself from the output picker.
: >"$scratch/inputs"
if actual="$(fronted_sink)"; then
  fail "unlinked community tuning reports no fronted sink" "$actual"
fi
[[ -z $actual ]] || fail "unlinked community tuning prints no sink" "$actual"
pass "unlinked community tuning reports no fronted sink"

mkdir -p "$scratch/default/audio/tunings/test"
cat >"$scratch/default/audio/tunings/test/tuning.conf" <<'EOF'
match_command=true
sink_pattern='^alsa_output.speakers$'
EOF
actual="$(fronted_sink)" || fail "unlinked shipped tuning retains its hardware fallback"
[[ $actual == "alsa_output.speakers" ]] || fail "shipped tuning falls back to its speakers" "$actual"
pass "unlinked shipped tuning retains its hardware fallback"

# A live route takes precedence over the profile's intended target.
cat >"$scratch/inputs" <<'EOF'
Sink Input #42
  Sink: 3
  Properties:
    node.name = "omarchy_speaker_tuning.output"
EOF
actual="$(fronted_sink)" || fail "linked tuning resolves its actual output"
[[ $actual == "alsa_output.headphones" ]] || fail "live route takes precedence over hardware profile" "$actual"
pass "live route takes precedence over hardware profile"

cat >"$scratch/sinks" <<'EOF'
1 alsa_output.speakers PipeWire
3 alsa_output.headphones PipeWire
EOF
if actual="$(fronted_sink)"; then
  fail "absent tuning reports no fronted sink" "$actual"
fi
[[ -z $actual ]] || fail "absent tuning prints no sink" "$actual"
pass "absent tuning leaves physical outputs available"
