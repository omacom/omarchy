#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
cards="$test_tmp/cards.json"
sinks="$test_tmp/sinks.json"
mkdir -p "$stub_bin"

cat >"$cards" <<'JSON'
[
  {
    "name": "alsa_card.gpu",
    "active_profile": "output:hdmi-stereo",
    "profiles": {
      "output:hdmi-stereo": { "description": "Digital Stereo (HDMI) Output", "sinks": 1, "priority": 5900, "available": true },
      "output:hdmi-stereo-extra1": { "description": "Digital Stereo (HDMI 2) Output", "sinks": 1, "priority": 5700, "available": true },
      "output:hdmi-surround-extra1": { "description": "Digital Surround 5.1 (HDMI 2) Output", "sinks": 1, "priority": 600, "available": true },
      "output:hdmi-stereo-extra2": { "description": "Digital Stereo (HDMI 3) Output", "sinks": 1, "priority": 5700, "available": false }
    },
    "ports": {
      "hdmi-output-0": {
        "description": "HDMI / DisplayPort",
        "priority": 5900,
        "availability": "available",
        "properties": { "device.product.name": "Left Monitor" },
        "profiles": ["output:hdmi-stereo"]
      },
      "hdmi-output-1": {
        "description": "HDMI / DisplayPort 2",
        "priority": 5800,
        "availability": "available",
        "properties": { "device.product.name": "Right Monitor" },
        "profiles": ["output:hdmi-stereo-extra1", "output:hdmi-surround-extra1"]
      },
      "hdmi-output-2": {
        "description": "HDMI / DisplayPort 3",
        "priority": 5700,
        "availability": "not available",
        "properties": {},
        "profiles": ["output:hdmi-stereo-extra2"]
      }
    }
  }
]
JSON

cat >"$sinks" <<'JSON'
[
  {
    "index": 731,
    "name": "alsa_output.gpu.hdmi-stereo-extra1",
    "properties": {
      "device.name": "alsa_card.gpu",
      "device.profile.name": "hdmi-stereo-extra1"
    }
  }
]
JSON

cat >"$stub_bin/pactl" <<'SH'
#!/bin/bash

if [[ $1 == "-f" && $2 == "json" && $3 == "list" && $4 == "cards" ]]; then
  cat "$CARDS_FIXTURE"
elif [[ $1 == "-f" && $2 == "json" && $3 == "list" && $4 == "sinks" ]]; then
  cat "$SINKS_FIXTURE"
elif [[ $1 == "set-card-profile" ]]; then
  printf 'set-card-profile\t%s\t%s\n' "$2" "$3" >>"$CALL_LOG"
else
  exit 1
fi
SH

cat >"$stub_bin/omarchy-audio-output-set-default" <<'SH'
#!/bin/bash

printf 'set-default\t%s\t%s\n' "$1" "$2" >>"$CALL_LOG"
SH

chmod +x "$stub_bin/pactl" "$stub_bin/omarchy-audio-output-set-default"

profiles=$(CARDS_FIXTURE="$cards" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-audio-output-profiles")
if jq -e '
  length == 2
  and any(.[]; .cardName == "alsa_card.gpu" and .profileName == "output:hdmi-stereo" and .label == "Left Monitor")
  and any(.[]; .cardName == "alsa_card.gpu" and .profileName == "output:hdmi-stereo-extra1" and .label == "Right Monitor")
' <<<"$profiles" >/dev/null; then
  pass "audio output profiles list the best profile for each available port"
else
  fail "audio output profiles list the best profile for each available port" "$profiles"
fi

CARDS_FIXTURE="$cards" SINKS_FIXTURE="$sinks" CALL_LOG="$calls" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-audio-output-set-profile" alsa_card.gpu output:hdmi-stereo-extra1

if rg -F $'set-card-profile\talsa_card.gpu\toutput:hdmi-stereo-extra1' "$calls" >/dev/null; then
  pass "audio output profile selection activates the requested card profile"
else
  fail "audio output profile selection activates the requested card profile"
fi

if rg -F $'set-default\t731\talsa_output.gpu.hdmi-stereo-extra1' "$calls" >/dev/null; then
  pass "audio output profile selection promotes the recreated sink"
else
  fail "audio output profile selection promotes the recreated sink"
fi

if CARDS_FIXTURE="$cards" SINKS_FIXTURE="$sinks" CALL_LOG="$calls" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-audio-output-set-profile" alsa_card.gpu output:missing 2>/dev/null; then
  fail "audio output profile selection rejects unavailable profiles"
else
  pass "audio output profile selection rejects unavailable profiles"
fi

# Intel HDA laptop (Realtek ALC256) with an HDMI monitor attached. The duplex
# profiles outrank the output-only ones, and the capture ports list them too.
laptop_cards="$test_tmp/laptop-cards.json"
laptop_sinks="$test_tmp/laptop-sinks.json"
laptop_calls="$test_tmp/laptop-calls"

cat >"$laptop_cards" <<'JSON'
[
  {
    "name": "alsa_card.pci-0000_00_1f.3",
    "active_profile": "output:hdmi-stereo+input:analog-stereo",
    "profiles": {
      "off": { "description": "Off", "sinks": 0, "sources": 0, "priority": 0, "available": true },
      "output:analog-stereo": { "description": "Analog Stereo Output", "sinks": 1, "sources": 0, "priority": 6500, "available": true },
      "output:analog-stereo+input:analog-stereo": { "description": "Analog Stereo Duplex", "sinks": 1, "sources": 1, "priority": 6565, "available": true },
      "output:hdmi-stereo": { "description": "Digital Stereo (HDMI) Output", "sinks": 1, "sources": 0, "priority": 5900, "available": true },
      "output:hdmi-stereo+input:analog-stereo": { "description": "Digital Stereo (HDMI) Output + Analog Stereo Input", "sinks": 1, "sources": 1, "priority": 5965, "available": true },
      "output:hdmi-stereo-extra1": { "description": "Digital Stereo (HDMI 2) Output", "sinks": 1, "sources": 0, "priority": 5700, "available": false },
      "output:hdmi-stereo-extra1+input:analog-stereo": { "description": "Digital Stereo (HDMI 2) Output + Analog Stereo Input", "sinks": 1, "sources": 1, "priority": 5765, "available": false },
      "input:analog-stereo": { "description": "Analog Stereo Input", "sinks": 0, "sources": 1, "priority": 65, "available": true }
    },
    "ports": {
      "analog-input-internal-mic": {
        "description": "Internal Microphone",
        "type": "Mic",
        "priority": 8900,
        "availability": "availability unknown",
        "properties": { "port.type": "mic", "device.icon_name": "audio-input-microphone" },
        "profiles": ["input:analog-stereo", "output:analog-stereo+input:analog-stereo", "output:hdmi-stereo+input:analog-stereo", "output:hdmi-stereo-extra1+input:analog-stereo"]
      },
      "analog-input-mic": {
        "description": "Microphone",
        "type": "Mic",
        "priority": 8700,
        "availability": "not available",
        "properties": { "port.type": "mic", "device.icon_name": "audio-input-microphone" },
        "profiles": ["input:analog-stereo", "output:analog-stereo+input:analog-stereo", "output:hdmi-stereo+input:analog-stereo", "output:hdmi-stereo-extra1+input:analog-stereo"]
      },
      "analog-output-speaker": {
        "description": "Speakers",
        "type": "Speaker",
        "priority": 10000,
        "availability": "availability unknown",
        "properties": { "port.type": "speaker", "device.icon_name": "audio-speakers" },
        "profiles": ["output:analog-stereo", "output:analog-stereo+input:analog-stereo"]
      },
      "analog-output-headphones": {
        "description": "Headphones",
        "type": "Headphones",
        "priority": 9900,
        "availability": "not available",
        "properties": { "port.type": "headphones", "device.icon_name": "audio-headphones" },
        "profiles": ["output:analog-stereo", "output:analog-stereo+input:analog-stereo"]
      },
      "hdmi-output-0": {
        "description": "HDMI / DisplayPort",
        "type": "HDMI",
        "priority": 5900,
        "availability": "available",
        "properties": { "port.type": "hdmi", "device.icon_name": "video-display", "device.product.name": "DELL U2720Q" },
        "profiles": ["output:hdmi-stereo", "output:hdmi-stereo+input:analog-stereo"]
      },
      "hdmi-output-1": {
        "description": "HDMI / DisplayPort 2",
        "type": "HDMI",
        "priority": 5800,
        "availability": "not available",
        "properties": { "port.type": "hdmi", "device.icon_name": "video-display" },
        "profiles": ["output:hdmi-stereo-extra1", "output:hdmi-stereo-extra1+input:analog-stereo"]
      }
    }
  }
]
JSON

cat >"$laptop_sinks" <<'JSON'
[
  {
    "index": 56,
    "name": "alsa_output.pci-0000_00_1f.3.hdmi-stereo",
    "properties": {
      "device.name": "alsa_card.pci-0000_00_1f.3",
      "device.profile.name": "hdmi-stereo"
    }
  }
]
JSON

profiles=$(CARDS_FIXTURE="$laptop_cards" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-audio-output-profiles")
if jq -e '
  length == 2
  and any(.[]; .profileName == "output:analog-stereo+input:analog-stereo" and .label == "Speakers")
  and any(.[]; .profileName == "output:hdmi-stereo+input:analog-stereo" and .label == "DELL U2720Q")
' <<<"$profiles" >/dev/null; then
  pass "audio output profiles keep duplex profiles so the microphone stays on"
else
  fail "audio output profiles keep duplex profiles so the microphone stays on" "$profiles"
fi

if jq -e 'all(.[]; .label != "Internal Microphone" and .label != "Microphone")' <<<"$profiles" >/dev/null; then
  pass "audio output profiles never take their label from a capture port"
else
  fail "audio output profiles never take their label from a capture port" "$profiles"
fi

# With the speaker unusable the internal microphone is the only port left on the
# analog duplex profile, and it must not pass itself off as an output.
laptop_muted_cards="$test_tmp/laptop-muted-cards.json"
jq '.[0].ports["analog-output-speaker"].availability = "not available"' "$laptop_cards" >"$laptop_muted_cards"
profiles=$(CARDS_FIXTURE="$laptop_muted_cards" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-audio-output-profiles")
if jq -e 'length == 1 and .[0].profileName == "output:hdmi-stereo+input:analog-stereo"' <<<"$profiles" >/dev/null; then
  pass "audio output profiles skip capture ports that list duplex profiles"
else
  fail "audio output profiles skip capture ports that list duplex profiles" "$profiles"
fi

if CARDS_FIXTURE="$laptop_cards" SINKS_FIXTURE="$laptop_sinks" CALL_LOG="$laptop_calls" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-audio-output-set-profile" alsa_card.pci-0000_00_1f.3 output:hdmi-stereo+input:analog-stereo; then
  pass "audio output profile selection finds the sink of a duplex profile"
else
  fail "audio output profile selection finds the sink of a duplex profile"
fi

if rg -F $'set-card-profile\talsa_card.pci-0000_00_1f.3\toutput:hdmi-stereo+input:analog-stereo' "$laptop_calls" >/dev/null; then
  pass "audio output profile selection activates the full duplex profile"
else
  fail "audio output profile selection activates the full duplex profile"
fi

if rg -F $'set-default\t56\talsa_output.pci-0000_00_1f.3.hdmi-stereo' "$laptop_calls" >/dev/null; then
  pass "audio output profile selection promotes the duplex profile sink"
else
  fail "audio output profile selection promotes the duplex profile sink"
fi
