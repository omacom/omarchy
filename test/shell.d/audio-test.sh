#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const audio = requireFromRoot('shell/plugins/panels/audio/Model.js')

assert(audio.isPlaybackStream({ isStream: true, isSink: true }), 'audio detects sink-backed playback streams')
assert(audio.isPlaybackStream({ isStream: true, type: 'Stream/Output/Audio' }), 'audio detects typed playback streams')
assert(!audio.isPlaybackStream({ isStream: false, isSink: true }), 'audio rejects non-stream playback nodes')
assert(audio.isAudioSource({ audio: {} }), 'audio detects nodes with audio as sources')
assert(audio.isAudioSource({ type: 'Audio/Source' }), 'audio detects typed source nodes')

const AUX = 4096
assert(!audio.needsProcessMeter([3, 4], AUX), 'audio meters positioned channels natively')
assert(!audio.needsProcessMeter([], AUX), 'audio meters unbound nodes natively until channels are known')
assert(!audio.needsProcessMeter(null, AUX), 'audio meters nodes without a channel list natively')
assert(audio.needsProcessMeter([AUX, AUX + 1], AUX), 'audio meters AUX channels through the process')
assert(audio.needsProcessMeter([3, 0], AUX), 'audio meters unknown channels through the process')

assertEqual(audio.outputVolumeName(0, false), 'Silenced', 'audio labels silent output')
assertEqual(audio.outputVolumeName(0.9, false), 'Party mode', 'audio labels loud output')
assertEqual(audio.outputVolumeName(0.5, true), 'Muted', 'audio labels muted output')

assertDeepEqual(audio.parseSinkAvailability('alsa_output\t1\nhdmi_output\t0\n'), { alsa_output: true, hdmi_output: false }, 'audio parses sink availability')
assertEqual(audio.friendlyDeviceLabel('Built-in Audio Speakers Output'), 'Speakers', 'audio cleans device labels')
assertEqual(
  audio.nodeLabel({ ready: true, properties: { 'node.nick': 'Built-in Audio Microphones Input' }, name: 'alsa_input' }),
  'Microphone',
  'audio chooses friendly node labels'
)

const headphones = { ready: true, name: 'bluez_output.airpods', properties: { 'device.product.name': 'AirPods Headphones' } }
assert(audio.isHeadphones(headphones), 'audio detects headphone devices')
assertEqual(audio.sinkGlyph(headphones), '󰋋', 'audio uses headphone sink glyph')
assert(audio.sourceGlyph({ ready: true, properties: { 'device.icon-name': 'camera-webcam' } }).length > 0, 'audio maps webcam source glyph')

assertEqual(audio.friendlyStreamLabel('spotify'), 'Spotify', 'audio normalizes known stream labels')
assert(audio.streamRepresentsMprisPlayer('Chromium', 'Chromium Browser'), 'audio matches related stream and MPRIS labels')

const players = [
  { identity: 'Spotify', canPlay: true, isPlaying: true, dbusName: 'org.mpris.MediaPlayer2.spotify' },
  { identity: 'Chromium', canPlay: true, isPlaying: false, dbusName: 'org.mpris.MediaPlayer2.chromium' }
]
const streams = [
  { ready: true, properties: { 'application.name': 'Chromium' } },
  { ready: true, properties: { 'application.name': 'audio-src' } }
]

assertEqual(audio.matchingMprisStreamLabel('Chromium', players), 'Chromium', 'audio finds matching MPRIS labels')
assertEqual(audio.unmatchedMprisStreamLabel('audio-src', players, streams), 'Spotify', 'audio uses unmatched MPRIS player for generic streams')
assertEqual(audio.streamLabel(streams[1], players, streams), 'Spotify', 'audio labels generic streams from MPRIS')
assert(audio.streamRepresentsPlayer(streams[1], players[0], players, streams), 'audio links generic streams to active player')
JS

# input-peak's arithmetic, with a stub pw-record on PATH standing in for the
# device: three 40 ms windows of stereo f32 samples, peaking at 0.5, 0.25 and a
# quiet 0.000001, which the panel still shows once the source volume is divided out.
# It emits nothing unless asked for the node, for headerless samples (without
# --raw pw-record writes an AU header) and for a latency pw-record can parse.
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
cat > "$stub_dir/pw-record" <<'STUB'
#!/bin/bash
[[ " $* " == *" --target stub-node "* && " $* " == *" --raw "* && " $* " =~ \ --latency\ [0-9]+(ns|us|ms|s)?\  ]] || exit 1
node -e '
  const frames = 640, channels = 2
  const out = new Float32Array(frames * channels * 3)
  out[0] = -0.5
  out[frames * channels + 1] = 0.25
  out[frames * channels * 2] = 0.000001
  process.stdout.write(Buffer.from(out.buffer))
'
STUB
chmod +x "$stub_dir/pw-record"

peaks=$(PATH="$stub_dir:$PATH" bash "$ROOT/shell/plugins/panels/audio/input-peak" stub-node 2 | tr '\n' ' ')
if [[ $peaks == "0.5 0.25 1e-06 " ]]; then
  pass "input-peak reports the largest magnitude per window across channels"
else
  fail "input-peak reports the largest magnitude per window across channels" "got: $peaks"
fi

peaks=$(PATH="$stub_dir:$PATH" bash "$ROOT/shell/plugins/panels/audio/input-peak" stub-node 0 | tr '\n' ' ')
if [[ $peaks == "0.5 0 0.25 0 1e-06 0 " ]]; then
  pass "input-peak treats a channel count below one as mono"
else
  fail "input-peak treats a channel count below one as mono" "got: $peaks"
fi

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping InputMeter process lifecycle"
  exit 0
fi

# InputMeter itself, offscreen, against a stand-in AUX node and a stub
# pw-record that streams a constant 0.5 for about ten seconds and logs each start.
work=$(mktemp -d)
trap 'rm -rf "$stub_dir" "$work"' EXIT
mkdir -p "$work/bin" "$work/config" "$work/runtime" "$work/home"
chmod 700 "$work/runtime"
node -e 'process.stdout.write(Buffer.from(new Float32Array(1280).fill(0.5).buffer))' > "$work/bin/chunk"
cat > "$work/bin/pw-record" <<'STUB'
#!/bin/bash
echo "$$" >> "${0%/*}/starts"
for _ in {1..250}; do
  cat "${0%/*}/chunk"
  sleep 0.04
done
STUB
chmod +x "$work/bin/pw-record"
cp "$SHELL_TEST_DIR/fixtures/input-meter/shell.qml" "$work/config/shell.qml"
ln -s "$ROOT/shell/plugins/panels/audio" "$work/config/audio"

PATH="$work/bin:$PATH" HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 15 quickshell -p "$work/config" --no-color >"$work/log" 2>&1 || true
starts=$(wc -l < "$work/bin/starts" 2>/dev/null || echo 0)
if grep -q 'INPUT_METER_TEST_PASS' "$work/log" && (( starts == 2 )); then
  pass "InputMeter restarts its capture after a stop and start in one turn"
else
  fail "InputMeter restarts its capture after a stop and start in one turn" "captures started: $starts; $(grep -E 'INPUT_METER|ERROR|WARN' "$work/log")"
fi
