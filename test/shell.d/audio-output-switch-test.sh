#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf 'pactl %s\n' "$*" >>"$CALLS"
case "$*" in
  "-f json list sinks")
    cat "$SINKS_JSON"
    ;;
  "get-default-sink")
    cat "$DEFAULT_SINK"
    ;;
  "get-sink-volume "*)
    cat "$VOLUME_STUB" 2>/dev/null || echo "Volume: front-left: 65536 / 100% / 0.00 dB"
    ;;
  "get-sink-mute "*)
    echo "Mute: no"
    ;;
  *)
    exit 0
    ;;
esac
SH

cat >"$work/bin/pw-dump" <<'SH'
#!/bin/bash
printf 'pw-dump %s\n' "$*" >>"$CALLS"
if [[ -n ${PW_DUMP_FAIL:-} ]]; then
  exit 1
fi
if [[ -f ${PW_DUMP_JSON:-} ]]; then
  cat "$PW_DUMP_JSON"
else
  echo "[]"
fi
SH

cat >"$work/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$work/bin/omarchy-audio-output-sink" <<'SH'
#!/bin/bash
echo "$1"
SH

cat >"$work/bin/omarchy-audio-output-set-default" <<'SH'
#!/bin/bash
printf 'omarchy-audio-output-set-default %s\n' "$*" >>"$CALLS"
SH

chmod +x "$work/bin"/*

export CALLS="$work/calls"
export SINKS_JSON="$work/sinks.json"
export DEFAULT_SINK="$work/default_sink"
export PW_DUMP_JSON="$work/pw_dump.json"
export VOLUME_STUB="$work/volume_stub"

# Scenario 1: Non-ASCII description corrupted to (null) in pactl JSON, recovered via pw-dump
cat >"$SINKS_JSON" <<'JSON'
[
  {
    "index": 1,
    "name": "bluez_output.bose",
    "description": "(null)",
    "properties": {
      "device.description": "(null)"
    },
    "volume": { "front-left": { "value_percent": "75%" } },
    "mute": false,
    "ports": []
  }
]
JSON

cat >"$PW_DUMP_JSON" <<'JSON'
[
  {
    "type": "PipeWire:Interface:Node",
    "info": {
      "props": {
        "media.class": "Audio/Sink",
        "node.name": "bluez_output.bose",
        "node.description": "🕺🏽Bose"
      }
    }
  }
]
JSON

echo "other_sink" >"$DEFAULT_SINK"
: >"$CALLS"

PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-output-switch"

grep -qx 'omarchy-osd -i volume-high -m 🕺🏽Bose' "$CALLS" ||
  fail "recovers non-ASCII sink description from pw-dump when pactl gives (null)"
pass "recovers non-ASCII sink description from pw-dump"

# Scenario 2: pw-dump has no matching description, falls back to sink name instead of literal (null)
echo "[]" >"$PW_DUMP_JSON"
: >"$CALLS"

PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-output-switch"

grep -qx 'omarchy-osd -i volume-high -m bluez_output.bose' "$CALLS" ||
  fail "falls back to sink name when pw-dump has no description"
pass "falls back to sink name instead of (null)"

# Scenario 3: pw-dump command fails completely, still switches and shows sink name
: >"$CALLS"

PW_DUMP_FAIL=1 PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-output-switch"

grep -qx 'omarchy-osd -i volume-high -m bluez_output.bose' "$CALLS" ||
  fail "falls back to sink name when pw-dump command fails"
pass "falls back to sink name when pw-dump command fails"

# Scenario 4: Valid description from pactl is preserved directly without pw-dump
echo "Volume: front-left: 32768 / 50% / 0.00 dB" >"$VOLUME_STUB"
cat >"$SINKS_JSON" <<'JSON'
[
  {
    "index": 2,
    "name": "alsa_output.pci",
    "description": "Built-in Audio",
    "volume": { "front-left": { "value_percent": "50%" } },
    "mute": false,
    "ports": []
  }
]
JSON
: >"$CALLS"

PATH="$work/bin:$PATH" "$ROOT/bin/omarchy-audio-output-switch"

grep -qx 'omarchy-osd -i volume-medium -m Built-in Audio' "$CALLS" ||
  fail "uses valid pactl description"
! grep -q '^pw-dump' "$CALLS" || fail "skips pw-dump when pactl description is valid"
pass "uses valid pactl description and avoids unnecessary pw-dump"
