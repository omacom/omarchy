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
assertEqual(audio.profileLabel(null), 'Unknown', 'audio labels missing profiles')
JS

profile_list="$ROOT/bin/omarchy-audio-profile-list"
[[ -x $profile_list ]] || fail "audio profile list command exists"

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
