#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home" "$test_tmp/omarchy/default/audio/tunings/example"

cat >"$test_tmp/omarchy/default/audio/tunings/example/tuning.conf" <<'SH'
match_command=omarchy-test-tuning-match
sink_pattern=alsa_output.example
description="Example speakers"
SH

cat >"$test_tmp/bin/omarchy-test-tuning-match" <<'SH'
#!/bin/bash
exit "${OMARCHY_TEST_MATCH_STATUS:-1}"
SH

cat >"$test_tmp/bin/pactl" <<'SH'
#!/bin/bash
case "$*" in
  "list sinks short")
    if [[ -n ${OMARCHY_TEST_DSP_SINK:-} ]]; then
      printf '1\t%s\tPipeWire\tfloat32le 2ch 48000Hz\tIDLE\n' "$OMARCHY_TEST_DSP_SINK"
    fi
    ;;
  "get-default-sink")
    printf '%s\n' "${OMARCHY_TEST_DEFAULT_SINK:-${OMARCHY_TEST_DSP_SINK:-alsa_output.example}}"
    ;;
  *)
    printf 'pactl %s\n' "$*" >>"$OMARCHY_TEST_MUTATIONS"
    exit 1
    ;;
esac
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
case "$2" in
  is-active) echo inactive; exit 3 ;;
  is-enabled) echo disabled; exit 1 ;;
  *) printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_MUTATIONS"; exit 1 ;;
esac
SH

chmod +x "$test_tmp/bin"/*
export PATH="$test_tmp/bin:$PATH"
export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
export OMARCHY_PATH="$test_tmp/omarchy"
export OMARCHY_TEST_MUTATIONS="$test_tmp/mutations"

for model in j316 j314 j413 mini studio; do
  export OMARCHY_TEST_DSP_SINK="audio_effect.$model-convolver"
  output=$("$ROOT/bin/omarchy-audio-tuning" status)
  [[ $output == *"Asahi DSP:    present ($OMARCHY_TEST_DSP_SINK)"* ]] ||
    fail "status reports the existing Asahi speaker DSP" "$output"
  [[ $output == *"Matches:      no Omarchy tuning for this laptop"* ]] ||
    fail "status distinguishes supplemental Omarchy tuning from Asahi DSP" "$output"

  output=$("$ROOT/bin/omarchy-audio-tuning" on)
  [[ $output == "Speaker tuning is managed by Asahi ($OMARCHY_TEST_DSP_SINK)." ]] ||
    fail "first-run tuning acknowledges the existing Asahi DSP" "$output"
done
pass "status and first-run tuning acknowledge Asahi speaker DSP across models"

export OMARCHY_TEST_DEFAULT_SINK=alsa_output.headphones
output=$("$ROOT/bin/omarchy-audio-tuning" status)
[[ $output == *"Asahi DSP:    present ($OMARCHY_TEST_DSP_SINK)"* &&
  $output == *"Default sink: alsa_output.headphones"* ]] ||
  fail "Asahi DSP remains present when headphones are the default output" "$output"
unset OMARCHY_TEST_DEFAULT_SINK
pass "Asahi DSP status does not depend on the selected output"

for sink in "" audio_effect.custom-convolver audio_effect.j316-convolver-extra; do
  export OMARCHY_TEST_DSP_SINK="$sink"
  output=$("$ROOT/bin/omarchy-audio-tuning" status)
  [[ $output != *"Asahi DSP:"* ]] || fail "unrelated sinks are not reported as Asahi DSP" "$output"
  output=$("$ROOT/bin/omarchy-audio-tuning" on)
  [[ $output == "No Omarchy speaker tuning matches this laptop." ]] ||
    fail "unmatched hardware reports only the absence of Omarchy tuning" "$output"
done
pass "absent and unrelated DSP sinks do not imply Asahi tuning"

export OMARCHY_TEST_MATCH_STATUS=0
output=$("$ROOT/bin/omarchy-audio-tuning" status)
[[ $output == *"Matches:      Example speakers (example)"* ]] ||
  fail "status still describes matching Omarchy tunings" "$output"
pass "matching Omarchy tunings retain their status description"

[[ ! -e $OMARCHY_TEST_MUTATIONS && ! -e $XDG_CONFIG_HOME ]] ||
  fail "unmatched tuning never changes audio services, routing or configuration"
pass "status and unmatched first-run tuning do not mutate audio state"
