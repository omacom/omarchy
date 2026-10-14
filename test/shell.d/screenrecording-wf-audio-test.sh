#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# wf-recorder takes one audio device, so desktop and microphone audio together
# go through a throwaway null sink. A source whose loopback won't load is left
# out with a notification naming it, never recorded as silence.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

awk '
  /^(wf_audio_device|wf_audio_unavailable|wf_audio_cleanup)\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-capture-screenrecording" >"$tmp/functions"

mkdir -p "$tmp/bin"
# Modules number from 10 up; a load fails when its arguments name a source
# listed in $tmp/refuse.
cat >"$tmp/bin/pactl" <<'SH'
#!/bin/bash
echo "pactl $*" >>"$TMP/calls"
case $1 in
  get-default-sink) [[ -e $TMP/no-sink ]] || echo speakers ;;
  get-default-source) [[ -e $TMP/no-source ]] || echo mic ;;
  load-module)
    for refused in $(cat "$TMP/refuse" 2>/dev/null); do
      [[ " $* " != *" $refused "* ]] || exit 1
    done
    n=$(( $(cat "$TMP/next" 2>/dev/null || echo 10) ))
    echo $(( n + 1 )) >"$TMP/next"
    echo "$n"
    ;;
esac
SH
cat >"$tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
echo "notify $*" >>"$TMP/notes"
echo "noise on stdout"
SH
chmod +x "$tmp/bin"/*

device() {
  rm -f "$tmp/calls" "$tmp/notes" "$tmp/next" "$tmp/modules"
  TMP=$tmp PATH="$tmp/bin:$PATH" DESKTOP_AUDIO=$1 MICROPHONE_AUDIO=$2 PA_MODULES_FILE=$tmp/modules \
    bash -c 'source "$TMP/functions"; wf_audio_device' >"$tmp/out"
}

loaded() {
  grep -c 'load-module' "$tmp/calls" || true
}

unloaded() {
  grep 'unload-module' "$tmp/calls" | awk '{ print $3 }' | tr '\n' ' '
}

: >"$tmp/refuse"
device true true
[[ $(cat "$tmp/out") == omarchy_screenrec.monitor ]] || fail "both sources record through the null sink" "$(cat "$tmp/out")"
[[ $(cat "$tmp/modules") == $'10\n11\n12' ]] || fail "all three module ids are kept for stop" "$(cat "$tmp/modules")"
[[ ! -e $tmp/notes ]] || fail "a full mix notifies nothing" "$(cat "$tmp/notes")"
pass "desktop and microphone audio record together through the null sink"

echo "source=mic" >"$tmp/refuse"
device true true
[[ $(cat "$tmp/out") == speakers.monitor ]] || fail "a microphone that won't mix leaves desktop audio" "$(cat "$tmp/out")"
[[ $(unloaded) == "11 10 " && ! -e $tmp/modules ]] || fail "the modules that loaded are unloaded" "$(cat "$tmp/calls")"
grep -q 'notify .*microphone audio' "$tmp/notes" && ! grep -q 'desktop' "$tmp/notes" ||
  fail "the dropped microphone is named" "$(cat "$tmp/notes" 2>/dev/null)"
pass "a microphone that won't mix is dropped, named, and desktop audio records alone"

echo "source=speakers.monitor" >"$tmp/refuse"
device true true
[[ $(cat "$tmp/out") == mic ]] || fail "desktop audio that won't mix leaves the microphone" "$(cat "$tmp/out")"
[[ $(unloaded) == "11 10 " ]] || fail "the modules that loaded are unloaded" "$(cat "$tmp/calls")"
grep -q 'notify .*desktop audio' "$tmp/notes" && ! grep -q 'microphone' "$tmp/notes" ||
  fail "the dropped desktop audio is named" "$(cat "$tmp/notes" 2>/dev/null)"
pass "desktop audio that won't mix is dropped, named, and the microphone records alone"

echo "source=speakers.monitor source=mic" >"$tmp/refuse"
device true true
[[ ! -s $tmp/out ]] || fail "with neither source there is no audio device" "$(cat "$tmp/out")"
[[ $(grep -c '^notify' "$tmp/notes") == 2 ]] || fail "both dropped sources are named" "$(cat "$tmp/notes")"
pass "with neither loopback the recording has no audio track rather than a silent one, and says so"

echo "module-null-sink" >"$tmp/refuse"
device true true
[[ $(cat "$tmp/out") == speakers.monitor && $(loaded) == 1 ]] || fail "without the null sink desktop audio records alone" "$(cat "$tmp/out")"
grep -q 'notify .*microphone audio' "$tmp/notes" || fail "without the null sink the microphone is named" "$(cat "$tmp/notes" 2>/dev/null)"
pass "without the null sink, desktop audio records alone and the microphone is named"

: >"$tmp/refuse"
touch "$tmp/no-source"
device true true
[[ $(cat "$tmp/out") == speakers.monitor && $(loaded) == 0 ]] || fail "without a default source desktop audio records alone" "$(cat "$tmp/out")"
grep -q 'notify .*microphone audio' "$tmp/notes" || fail "a missing default source is named" "$(cat "$tmp/notes" 2>/dev/null)"
device false true
[[ ! -s $tmp/out ]] && grep -q 'notify .*microphone audio' "$tmp/notes" || fail "a microphone-only recording without a source says so" "$(cat "$tmp/out")"
rm "$tmp/no-source"
pass "a requested source with no default device is named"

device true false
[[ $(cat "$tmp/out") == speakers.monitor && ! -e $tmp/notes ]] || fail "desktop audio alone records the sink monitor" "$(cat "$tmp/out")"
device false true
[[ $(cat "$tmp/out") == mic && ! -e $tmp/notes ]] || fail "microphone audio alone records the source" "$(cat "$tmp/out")"
device false false
[[ ! -s $tmp/out && ! -e $tmp/calls ]] || fail "no audio asks pactl nothing" "$(cat "$tmp/calls")"
pass "a single source records directly and no audio asks for nothing"
