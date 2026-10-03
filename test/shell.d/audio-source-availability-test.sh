#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

# One source per port, as SOF cards expose them: the combo-jack mic is not
# available while the jack is empty, the digital mic reports unknown.
cat >"$tmp/split.txt" <<'PACTL'
Source #50
	State: SUSPENDED
	Name: alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source
	Properties:
		device.class = "sound"
		api.alsa.path = "hw:0,0"
	Ports:
		[In] Mic2: Stereo Microphone (type: Mic, priority: 200, availability group: Mic, not available)
	Active Port: [In] Mic2
	Formats:
		pcm
Source #51
	State: SUSPENDED
	Name: alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source
	Properties:
		device.class = "sound"
	Ports:
		[In] Mic1: Digital Microphone (type: Mic, priority: 100, availability unknown)
	Active Port: [In] Mic1
	Formats:
		pcm
Source #52
	State: SUSPENDED
	Name: virtual_source
	Properties:
		device.class = "filter"
	Formats:
		pcm
PACTL

# One source with an internal mic and an empty jack, as HDA cards expose it.
cat >"$tmp/shared.txt" <<'PACTL'
Source #64
	State: SUSPENDED
	Name: alsa_input.pci-0000_00_1f.3.analog-stereo
	Properties:
		device.class = "sound"
	Ports:
		analog-input-internal-mic: Internal Microphone (type: Mic, priority: 8900, availability group: Legacy 1, availability unknown)
		analog-input-mic: Microphone (type: Mic, priority: 8700, availability group: Legacy 2, not available)
	Active Port: analog-input-internal-mic
	Formats:
		pcm
PACTL

printf '#!/bin/bash\ncat "$PACTL_FIXTURE"\n' >"$tmp/bin/pactl"
chmod +x "$tmp/bin/pactl"

output=$(PACTL_FIXTURE="$tmp/split.txt" PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-audio-source-availability")
expected=$'alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source\t0\nalsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source\t1\nvirtual_source\t1'
[[ $output == "$expected" ]] || fail "an input whose only port is unplugged is unavailable" "$output"
pass "an input whose only port is unplugged is unavailable"

output=$(PACTL_FIXTURE="$tmp/shared.txt" PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-audio-source-availability")
[[ $output == $'alsa_input.pci-0000_00_1f.3.analog-stereo\t1' ]] || fail "an input with any usable port stays available" "$output"
pass "an input with any usable port stays available"

# pactl translates its output, as in a German session. Only the C locale gives
# the English headings the parser reads.
cat >"$tmp/german.txt" <<'PACTL'
Quelle #50
	Status: SUSPENDED
	Name: alsa_input.unplugged
	Ports:
		[In] Mic2: Stereo-Mikrofon (Typ: Mic, Priorität: 200, Verfügbarkeitsgruppe: Mic, nicht verfügbar)
	Aktiver Port: [In] Mic2
PACTL
cat >"$tmp/german-c.txt" <<'PACTL'
Source #50
	State: SUSPENDED
	Name: alsa_input.unplugged
	Ports:
		[In] Mic2: Stereo Microphone (type: Mic, priority: 200, availability group: Mic, not available)
	Active Port: [In] Mic2
PACTL
mkdir -p "$tmp/localized"
cat >"$tmp/localized/pactl" <<'STUB'
#!/bin/bash
if [[ ${LC_ALL:-} == C ]]; then
  cat "$PACTL_FIXTURE_C"
else
  cat "$PACTL_FIXTURE"
fi
STUB
chmod +x "$tmp/localized/pactl"

output=$(LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 PACTL_FIXTURE="$tmp/german.txt" PACTL_FIXTURE_C="$tmp/german-c.txt" \
  PATH="$tmp/localized:$PATH" "$ROOT/bin/omarchy-audio-source-availability")
[[ $output == $'alsa_input.unplugged\t0' ]] || fail "an unplugged input is unavailable in a translated session" "$output"
pass "an unplugged input is unavailable in a translated session"

run_node_test <<'JS'
const fs = require('fs')
const panel = fs.readFileSync(root + '/shell/plugins/panels/audio/Panel.qml', 'utf8')
assert(/readonly property var rawAudioSources: \{\s*var list = \[\]\s*for \(var i = 0; i < candidateSources\.length; i\+\+\)\s*if \(sourceAvailable\(candidateSources\[i\]\)\) list\.push/.test(panel),
  'the audio panel leaves unplugged inputs out of its list')
assert(/if \(source && list\.indexOf\(source\) < 0\) list\.unshift\(source\)/.test(panel),
  'the audio panel keeps the current input listed even when unplugged')
assert(/readonly property var audioSources: rawAudioSources\.length > 0 \|\| candidateSources\.length > 0\s*\? rawAudioSources : cachedAudioSources/.test(panel),
  'the audio panel only falls back to cached inputs when PipeWire has no inputs at all')
assert(/onRawAudioSourcesChanged: if \(rawAudioSources\.length > 0 \|\| candidateSources\.length > 0\) cachedAudioSources = rawAudioSources/.test(panel),
  'the input cache follows the filtered list, including when every input is unplugged')
assert(panel.includes('command: ["omarchy-audio-source-availability"]') && /sourceAvailabilityProc\.running = true/.test(panel),
  'the audio panel refreshes input availability while open')
JS
