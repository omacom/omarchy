#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export SPEAKERS_LOG="$test_tmp/calls" XDG_RUNTIME_DIR="$test_tmp" XDG_CONFIG_HOME="$test_tmp/config"
export PW_EVENTS="" VOXTYPE_LINKED=""
state_dir="$test_tmp/omarchy-voxtype-speakers"
mkdir -p "$test_tmp/bin" "$state_dir" "$XDG_CONFIG_HOME/omarchy/defaults"
echo voxtype > "$XDG_CONFIG_HOME/omarchy/defaults/dictation"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat > "$test_tmp/bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >> "$SPEAKERS_LOG"
if [[ $1 == "status" ]]; then echo recording; fi
# Stands in for the watcher linking the speakers once the recording starts.
if [[ $* == "record start" && -n $VOXTYPE_LINKED ]]; then
  read -r pid _ < "$XDG_RUNTIME_DIR/omarchy-voxtype-speakers/active"
  kill -USR1 "$pid"
fi
SH
cat > "$test_tmp/bin/pw-metadata" <<'SH'
#!/bin/bash
[[ $1 == "-m" ]] || echo "update: id:0 key:'default.audio.sink' value:'{\"name\":\"speakers\"}' type:'Spa:String:JSON'"
SH
# The monitor prints $PW_EVENTS, then holds while $PW_HOLD exists, like a watcher that keeps running.
cat > "$test_tmp/bin/pw-link" <<'SH'
#!/bin/bash
echo watcher >> "$XDG_RUNTIME_DIR/watchers"
[[ -z $PW_EVENTS ]] || printf '%s\n' "$PW_EVENTS"
while [[ -n ${PW_HOLD:-} && -e $PW_HOLD ]]; do sleep 0.05; done
SH
cat > "$test_tmp/bin/pw-cli" <<'SH'
#!/bin/bash
while read -r command; do
  printf 'pw-cli %s\n' "$command" >> "$SPEAKERS_LOG"
done
SH
cat > "$test_tmp/bin/dbus-monitor" <<'SH'
#!/bin/bash
SH
cat > "$test_tmp/bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl %s\n' "$*" >> "$SPEAKERS_LOG"
SH
cat > "$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >> "$SPEAKERS_LOG"
SH
chmod +x "$test_tmp/bin/"*

# Runs the watcher over $PW_EVENTS while a speaker recording by this shell is active.
watch_recording() {
  : > "$SPEAKERS_LOG"
  : > "$test_tmp/signals"
  echo "$$ ${EPOCHREALTIME/./}" > "$state_dir/active"
  omarchy-voxtype-speakers watch
}
trap 'echo linked >> "$test_tmp/signals"' USR1

ports="+   10 mic:capture_FL
+   11 mic:capture_FR
+   20 speakers:monitor_FL
+   21 speakers:monitor_FR
+   30 headset:monitor_FL
+   31 headset:monitor_FR"

swapped="*   10 mic:capture_FL
+   80   |->   50 alsa_capture.voxtype-avx512:input_FL
*   11 mic:capture_FR
+   81   |->   51 alsa_capture.voxtype-avx512:input_FR
*   10 mic:capture_FL
    80   |->   50 alsa_capture.voxtype-avx512:input_FL
*   10 mic:capture_FL
-   80   |->   50 alsa_capture.voxtype-avx512:input_FL
*   20 speakers:monitor_FL
+   90   |->   50 alsa_capture.voxtype-avx512:input_FL
*   11 mic:capture_FR
-   81   |->   51 alsa_capture.voxtype-avx512:input_FR
*   21 speakers:monitor_FR
+   91   |->   51 alsa_capture.voxtype-avx512:input_FR"

PW_EVENTS="$ports
$swapped" watch_recording
expected="pw-cli destroy 80
pw-cli create-link - 20 - 50 { object.linger = true }
pw-cli destroy 81
pw-cli create-link - 21 - 51 { object.linger = true }"
[[ $(cat "$SPEAKERS_LOG") == "$expected" ]] || fail "the microphone links are swapped for the matching speaker channels, once each" "$(cat "$SPEAKERS_LOG")"
[[ $(cat "$test_tmp/signals") == linked ]] || fail "the waiting start is told once the speakers are linked"
pass "speaker dictation swaps the microphone link for the speaker monitor as WirePlumber makes it"

PW_EVENTS="$ports
*   10 mic:capture_FL
+   80   |->   50 alsa_capture.voxtype-avx512:input_FL
*   20 speakers:monitor_FL
+   90   |->   50 alsa_capture.voxtype-avx512:input_FL" watch_recording
[[ ! -s $test_tmp/signals ]] || fail "the start isn't told the speakers are linked while the microphone still is"
pass "speaker dictation only reports success once the microphone is unlinked"

PW_EVENTS="$ports
*   10 mic:capture_FL
+   80   |->   52 Voxtype-cpal:input_MONO
*   11 mic:capture_FR
+   81   |->   52 Voxtype-cpal:input_MONO" watch_recording
expected="pw-cli destroy 80
pw-cli create-link - 20 - 52 { object.linger = true }
pw-cli create-link - 21 - 52 { object.linger = true }
pw-cli destroy 81"
[[ $(sort "$SPEAKERS_LOG") == "$(sort <<< "$expected")" ]] || fail "a mono stream not named by ALSA gets every speaker channel" "$(cat "$SPEAKERS_LOG")"
pass "speaker dictation handles mono streams and finds Voxtype by any node name"

PW_EVENTS="$ports
update: id:0 key:'default.audio.sink' value:'{\"name\":\"headset\"}' type:'Spa:String:JSON'
-   30 headset:monitor_FL
-   31 headset:monitor_FR
+   32 headset:monitor_MONO
*   10 mic:capture_FL
+   80   |->   50 alsa_capture.voxtype-avx512:input_FL" watch_recording
expected="pw-cli destroy 80
pw-cli create-link - 32 - 50 { object.linger = true }"
[[ $(cat "$SPEAKERS_LOG") == "$expected" ]] || fail "a new default output and its new channels are used without a lookup" "$(cat "$SPEAKERS_LOG")"
pass "speaker dictation follows output and channel changes as they happen"

PW_EVENTS="$ports
$swapped"
: > "$SPEAKERS_LOG"
rm -f "$state_dir/active"
omarchy-voxtype-speakers watch
PW_EVENTS=""
[[ ! -s $SPEAKERS_LOG ]] || fail "microphone dictation is left alone" "$(cat "$SPEAKERS_LOG")"
pass "speaker dictation leaves microphone dictation alone"

PW_EVENTS="+   10 mic:capture_FL
*   10 mic:capture_FL
+   80   |->   50 alsa_capture.voxtype-avx512:input_FL" watch_recording
[[ $(head -1 "$SPEAKERS_LOG") == "voxtype record cancel" ]] || fail "no speaker output keeps the microphone linked and cancels" "$(cat "$SPEAKERS_LOG")"
grep -q '^notify ' "$SPEAKERS_LOG" || fail "no speaker output is reported"
[[ ! -e $state_dir/active ]] || fail "a failed recording is no longer active"
pass "speaker dictation cancels when there is no speaker output"

PW_EVENTS="signal time=1.5 sender=:1.40 -> destination=(null destination) serial=2 path=/org/mpris/MediaPlayer2; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged
   string \"org.mpris.MediaPlayer2.Player\"
   array [
      dict entry(
         string \"PlaybackStatus\"
         variant             string \"Paused\"
      )
   ]" watch_recording
wait
[[ $(cat "$SPEAKERS_LOG") == "busctl --user call :1.40 /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player Play" ]] || fail "a player Voxtype pauses is resumed" "$(cat "$SPEAKERS_LOG")"
: > "$SPEAKERS_LOG"
rm -f "$state_dir/active"
omarchy-voxtype-speakers watch
PW_EVENTS=""
[[ ! -s $SPEAKERS_LOG ]] || fail "players paused during microphone dictation stay paused" "$(cat "$SPEAKERS_LOG")"
pass "speaker dictation keeps the media it transcribes playing"

: > "$SPEAKERS_LOG"
: > "$test_tmp/watchers"
touch "$test_tmp/hold"
PW_HOLD="$test_tmp/hold" VOXTYPE_LINKED=1 omarchy-voxtype-speakers start
for ((attempt = 0; attempt < 40; attempt++)); do
  [[ ! -s $test_tmp/watchers ]] || break
  sleep 0.05
done
PW_HOLD="$test_tmp/hold" VOXTYPE_LINKED=1 omarchy-voxtype-speakers start
rm "$test_tmp/hold"
[[ $(cat "$SPEAKERS_LOG") == $'voxtype record start\nvoxtype record start' ]] || fail "a linked start keeps recording" "$(cat "$SPEAKERS_LOG")"
[[ $(wc -l < "$test_tmp/watchers") == 1 ]] || fail "the first press starts the watcher and later presses reuse it" "$(cat "$test_tmp/watchers")"
pass "speaker dictation starts its watcher on the first press only"

: > "$SPEAKERS_LOG"
if omarchy-voxtype-speakers start; then fail "a recording that never links must fail"; fi
grep -q '^voxtype record cancel$' "$SPEAKERS_LOG" || fail "a recording that never links is cancelled"
grep -q '^notify ' "$SPEAKERS_LOG" || fail "a recording that never links is reported"
pass "speaker dictation cancels instead of recording the microphone"

: > "$SPEAKERS_LOG"
echo superwhisper > "$XDG_CONFIG_HOME/omarchy/defaults/dictation"
if omarchy-voxtype-speakers start 2> /dev/null; then fail "another dictation backend must fail"; fi
echo voxtype > "$XDG_CONFIG_HOME/omarchy/defaults/dictation"
exec 7> "$XDG_CONFIG_HOME/omarchy/defaults/dictation.lock"
flock 7
started=$EPOCHREALTIME
(sleep 0.3; flock -u 7) &
VOXTYPE_LINKED=1 omarchy-voxtype-speakers start
exec 7>&-
[[ $(cat "$SPEAKERS_LOG") == "voxtype record start" ]] || fail "only the Voxtype backend is recorded" "$(cat "$SPEAKERS_LOG")"
(( ${EPOCHREALTIME/./} - ${started/./} >= 300000 )) || fail "start waits for a backend switch to finish"
pass "speaker dictation takes the dictation lock and checks the backend"

: > "$SPEAKERS_LOG"
echo 1 > "$state_dir/active"
omarchy-voxtype-speakers stop
[[ ! -e $state_dir/active ]] || fail "stop ends the speaker recording"
[[ $(cat "$SPEAKERS_LOG") == $'voxtype status\nvoxtype record stop' ]] || fail "stop finishes the Voxtype recording"
if omarchy-voxtype-speakers 2> /dev/null; then fail "missing action must fail"; fi
pass "speaker dictation stops through the Voxtype adapter"
