#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')

const rows = audio.parseAudioProfiles(
  'alsa_card.pci-0000_00_1f.3\toutput:analog-stereo+input:analog-stereo\t1\t0\tAnalog Stereo Duplex\n' +
  'alsa_card.pci-0000_00_1f.3\toutput:hdmi-stereo+input:analog-stereo\t1\t1\tDigital Stereo (HDMI) Output + Analog Stereo Input\n' +
  'alsa_card.pci-0000_00_1f.3\toutput:hdmi-stereo-extra1\t0\t0\tDigital Stereo (HDMI 2) Output\n' +
  'bad-row-without-tabs\n'
)

assertEqual(rows.length, 3, 'audio parses profile rows and skips malformed lines')
assertEqual(rows[0].card, 'alsa_card.pci-0000_00_1f.3', 'audio keeps profile card name')
assertEqual(rows[0].profile, 'output:analog-stereo+input:analog-stereo', 'audio keeps profile name')
assert(rows[0].available, 'audio marks available profiles')
assert(!rows[0].active, 'audio marks inactive profiles')
assert(rows[1].active, 'audio marks the active profile')
assert(!rows[2].available, 'audio marks unavailable profiles')

assertEqual(audio.profileLabel(rows[1]), 'Digital Stereo (HDMI)', 'audio labels HDMI profiles')
assertEqual(audio.profileLabel(rows[0]), 'Analog Stereo Duplex', 'audio labels analog profiles')
assertEqual(audio.profileLabel(null), 'Unknown', 'audio labels missing profiles')
JS

profile_list="$ROOT/bin/omarchy-audio-profile-list"
[[ -x $profile_list ]] || fail "audio profile list command exists"

# Mocked backend: stub pactl so list/set behavior is checked from fixtures,
# not from whatever the live graph happens to expose.
mockdir=$(mktemp -d)
trap 'rm -rf "$mockdir"' EXIT
mkdir -p "$mockdir/out"

cat > "$mockdir/pactl" <<'SH'
#!/bin/bash
if [[ $1 == "-f" ]]; then
  shift 2
fi
if [[ $1 == "list" && $2 == "cards" ]]; then
  cat "$STUB_CARDS_JSON"
  exit 0
fi
if [[ $1 == "list" && $2 == "sinks" && ${3:-} == "short" ]]; then
  cat "$STUB_SINKS_SHORT"
  exit 0
fi
if [[ $1 == "list" && $2 == "sinks" ]]; then
  cat "$STUB_SINKS_JSON"
  exit 0
fi
if [[ $1 == "set-card-profile" ]]; then
  printf '%s %s\n' "$2" "$3" >> "$STUB_OUTDIR/set-profile.args"
  exit 0
fi
exit 1
SH
chmod +x "$mockdir/pactl"

cat > "$mockdir/omarchy-audio-output-set-default" <<'SH'
#!/bin/bash
printf '%s %s\n' "${1:-}" "${2:-}" >> "$STUB_OUTDIR/set-default.args"
exit 0
SH
chmod +x "$mockdir/omarchy-audio-output-set-default"

cat > "$mockdir/omarchy-osd" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mockdir/omarchy-osd"

cat > "$mockdir/omarchy-audio-tuning" <<'SH'
#!/bin/bash
if [[ ${1:-} == "fronted-sink" ]]; then
  if [[ -n ${STUB_FRONTED:-} ]]; then
    printf '%s\n' "$STUB_FRONTED"
    exit 0
  fi
  exit 1
fi
exit 1
SH
chmod +x "$mockdir/omarchy-audio-tuning"

export PATH="$mockdir:$ROOT/bin:$PATH"
export STUB_OUTDIR="$mockdir/out"

cat > "$mockdir/cards.json" <<'JSON'
[
  {
    "name": "alsa_card.pci-0000_00_1f.3",
    "active_profile": "output:analog-stereo+input:analog-stereo",
    "profiles": {
      "off": {"description": "Off", "sinks": 0, "sources": 0, "available": true},
      "output:analog-stereo+input:analog-stereo": {"description": "Analog Stereo Duplex", "sinks": 1, "sources": 1, "available": true},
      "output:hdmi-stereo+input:analog-stereo": {"description": "Digital Stereo (HDMI) Output + Analog Stereo Input", "sinks": 1, "sources": 1, "available": true},
      "output:hdmi-stereo-extra1": {"description": "Digital Stereo (HDMI 2) Output", "sinks": 1, "sources": 0, "available": false}
    }
  }
]
JSON
export STUB_CARDS_JSON="$mockdir/cards.json"

mock_output=$("$profile_list" 2>/dev/null)
[[ $(grep -c . <<<"$mock_output") == "3" ]] || fail "audio profile list filters to output profiles from fixtures"
grep -q '^alsa_card.pci-0000_00_1f.3	output:hdmi-stereo+input:analog-stereo	1	0	Digital Stereo (HDMI) Output + Analog Stereo Input$' <<<"$mock_output" || fail "audio profile list flags hdmi available inactive"
pass "audio profile list filters to output profiles from fixtures"
grep -q '^alsa_card.pci-0000_00_1f.3	output:analog-stereo+input:analog-stereo	1	1	Analog Stereo Duplex$' <<<"$mock_output" || fail "audio profile list flags active analog"
pass "audio profile list flags active analog"
grep -q '^alsa_card.pci-0000_00_1f.3	output:hdmi-stereo-extra1	0	0	' <<<"$mock_output" || fail "audio profile list keeps unavailable profiles as 0"
pass "audio profile list keeps unavailable profiles as 0"

cat > "$mockdir/sinks-hdmi.json" <<'JSON'
[{"index": 60, "name": "alsa_output.pci-0000_00_1f.3.hdmi-stereo", "description": "Built-in Audio Digital Stereo (HDMI)", "properties": {"device.name": "alsa_card.pci-0000_00_1f.3"}}]
JSON
printf '60\talsa_output.pci-0000_00_1f.3.hdmi-stereo\tPipeWire\n' > "$mockdir/sinks-short-hdmi"
export STUB_SINKS_JSON="$mockdir/sinks-hdmi.json"
export STUB_SINKS_SHORT="$mockdir/sinks-short-hdmi"
export STUB_FRONTED=""

rm -f "$mockdir/out/"*.args
"$ROOT/bin/omarchy-audio-profile-set" alsa_card.pci-0000_00_1f.3 output:hdmi-stereo+input:analog-stereo 2>/dev/null || fail "audio profile set succeeds when the new sink appears"
pass "audio profile set succeeds when the new sink appears"
grep -q '^alsa_card.pci-0000_00_1f.3 output:hdmi-stereo+input:analog-stereo$' "$mockdir/out/set-profile.args" || fail "audio profile set changes the card profile first"
pass "audio profile set changes the card profile first"
grep -q '^60 alsa_output.pci-0000_00_1f.3.hdmi-stereo$' "$mockdir/out/set-default.args" || fail "audio profile set defaults to the new sink"
pass "audio profile set defaults to the new sink"

cat > "$mockdir/sinks-analog.json" <<'JSON'
[{"index": 59, "name": "alsa_output.pci-0000_00_1f.3.analog-stereo", "description": "Built-in Audio Analog Stereo", "properties": {"device.name": "alsa_card.pci-0000_00_1f.3"}}]
JSON
printf '59\talsa_output.pci-0000_00_1f.3.analog-stereo\tPipeWire\n99\tomarchy_speaker_tuning\tPipeWire\n' > "$mockdir/sinks-short-tuning"
export STUB_SINKS_JSON="$mockdir/sinks-analog.json"
export STUB_SINKS_SHORT="$mockdir/sinks-short-tuning"
export STUB_FRONTED="alsa_output.pci-0000_00_1f.3.analog-stereo"

rm -f "$mockdir/out/"*.args
"$ROOT/bin/omarchy-audio-profile-set" alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo 2>/dev/null || fail "audio profile set succeeds with tuning present"
pass "audio profile set succeeds with tuning present"
grep -q '^99 omarchy_speaker_tuning$' "$mockdir/out/set-default.args" || fail "audio profile set routes through speaker tuning instead of bypassing it"
pass "audio profile set routes through speaker tuning instead of bypassing it"

cat > "$mockdir/sinks-empty.json" <<'JSON'
[]
JSON
printf '' > "$mockdir/sinks-short-empty"
export STUB_SINKS_JSON="$mockdir/sinks-empty.json"
export STUB_SINKS_SHORT="$mockdir/sinks-short-empty"
export STUB_FRONTED=""

if err=$("$ROOT/bin/omarchy-audio-profile-set" alsa_card.pci-0000_00_1f.3 output:hdmi-stereo+input:analog-stereo 2>&1); then
  fail "audio profile set fails when no sink appears"
else
  [[ $err == *"Timed out waiting for output"* ]] || fail "audio profile set reports a timeout"
  pass "audio profile set fails when no sink appears"
fi

trap - EXIT
rm -rf "$mockdir"

profile_output=$("$profile_list" 2>/dev/null || true)
if [[ -n $profile_output ]]; then
  head -n 1 <<<"$profile_output" | grep -qP '^[^\t]+\t[^\t]+\t[01]\t[01]\t.+' || fail "audio profile list emits card profile available active description rows"
  pass "audio profile list emits card profile rows"
else
  skip "audio profile list emits card profile rows (no PipeWire in sandbox)"
fi

"$ROOT/bin/omarchy-audio-profile-set" 2>/dev/null && fail "audio profile set requires args" || pass "audio profile set requires args"

output=$("$ROOT/bin/omarchy" commands 2>/dev/null || true)
[[ $output == *"omarchy audio profile list"* ]] || fail "audio profile list is routed"
pass "audio profile list is routed"
[[ $output == *"omarchy audio profile set"* ]] || fail "audio profile set is routed"
pass "audio profile set is routed"
