#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
export PATH="$stub_dir:$PATH"
export AUDIO_TEST_DIR="$stub_dir"

cat >"$stub_dir/omarchy-audio-output-sink" <<'STUB'
#!/bin/bash
echo test_sink
STUB

cat >"$stub_dir/pactl" <<'STUB'
#!/bin/bash
case "$1" in
  get-sink-mute)
    [[ $2 == "test_sink" ]] || exit 1
    printf 'Mute: %s\n' "$(cat "$AUDIO_TEST_DIR/muted")"
    ;;
  get-sink-volume)
    [[ $2 == "test_sink" ]] || exit 1
    echo 'Volume: front-left: 32768 / 50% / -18.06 dB'
    ;;
  set-sink-mute)
    [[ $2 == "test_sink" ]] || exit 1
    case "$3" in
      1) echo yes >"$AUDIO_TEST_DIR/muted" ;;
      0) echo no >"$AUDIO_TEST_DIR/muted" ;;
      *) exit 1 ;;
    esac
    printf '%s\n' "$3" >"$AUDIO_TEST_DIR/last-action"
    ;;
  *) exit 1 ;;
esac
STUB

cat >"$stub_dir/omarchy-osd" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$AUDIO_TEST_DIR/osd"
STUB

chmod +x "$stub_dir/omarchy-audio-output-sink" "$stub_dir/pactl" "$stub_dir/omarchy-osd"
echo no >"$stub_dir/muted"

bash "$ROOT/bin/omarchy-audio-output-volume" mute
[[ $(cat "$stub_dir/muted") == "yes" && $(cat "$stub_dir/last-action") == "1" && $(cat "$stub_dir/osd") == "-i volume-muted -p 50" ]] || fail "mute sets output to muted and shows the OSD"
pass "mute sets output to muted and shows the OSD"

bash "$ROOT/bin/omarchy-audio-output-volume" mute
[[ $(cat "$stub_dir/muted") == "yes" ]] || fail "mute does not unmute an already muted output"
pass "mute does not unmute an already muted output"

bash "$ROOT/bin/omarchy-audio-output-volume" unmute
[[ $(cat "$stub_dir/muted") == "no" && $(cat "$stub_dir/last-action") == "0" && $(cat "$stub_dir/osd") == "-i volume-high -p 50" ]] || fail "unmute sets output to unmuted and shows the OSD"
pass "unmute sets output to unmuted and shows the OSD"

bash "$ROOT/bin/omarchy-audio-output-volume" unmute
[[ $(cat "$stub_dir/muted") == "no" ]] || fail "unmute does not mute an already unmuted output"
pass "unmute does not mute an already unmuted output"
