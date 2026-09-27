#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
migration="$ROOT/migrations/1790366236.sh"

export CALL_LOG="$test_dir/calls"
export AUDIO="$test_dir/audio"
export FRAGMENT="$test_dir/config/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf"
export SPEAKERS="alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink"

# A small audio graph in files: the sinks by index, the default, and for each
# stream its sink and whether it follows the default. As in PipeWire, moving a
# stream onto the default makes it follow the default, and restarting the tuning
# gives its sink a new index.
cat >"$test_dir/bin/pactl" <<'SH'
#!/bin/bash
index_of() {
  awk -v s="$1" '$1 == s || $2 == s {print $1; exit}' "$AUDIO/sinks"
}
case $1 in
  get-default-sink) cat "$AUDIO/default" ;;
  set-default-sink)
    sink=$(index_of "$2")
    [[ -n $sink ]] || exit 1
    printf '%s\n' "$2" >"$AUDIO/default"
    awk -v d="$sink" '$3 == 1 {$2 = d} 1' "$AUDIO/streams" >"$AUDIO/streams.new"
    mv "$AUDIO/streams.new" "$AUDIO/streams"
    ;;
  list)
    if [[ $2 == "sinks" ]]; then
      awk '{printf "%s\t%s\tPipeWire\n", $1, $2}' "$AUDIO/sinks"
    else
      awk '{printf "%s\t%s\t-\tprotocol-native.c\n", $1, $2}' "$AUDIO/streams"
    fi
    ;;
  move-sink-input)
    sink=$(index_of "$3")
    [[ -n $sink ]] && grep -q "^$2 " "$AUDIO/streams" || exit 1
    follow=0
    [[ $sink == "$(index_of "$(cat "$AUDIO/default")")" ]] && follow=1
    sed -i "s/^$2 .*/$2 $sink $follow/" "$AUDIO/streams"
    ;;
esac
SH
# on stands in for the real helper's three outcomes: the new tuning is up (and,
# as the helper does, made the default with every stream moved onto it), it
# refused before touching anything, or it failed and removed what it installed.
cat >"$test_dir/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
printf 'tuning %s\n' "$*" >>"$CALL_LOG"
case $1 in
  match)
    [[ -n ${TUNING_MATCH:-} ]] || exit 1
    printf '%s\n' "$TUNING_MATCH"
    ;;
  on)
    case ${ON_RESULT:-ok} in
      ok)
        printf '# Dell XPS 16 (2026) speaker tuning.\n' >"$FRAGMENT"
        sed -i "s/^63 /70 /; /${ON_VANISH:-^$}/d" "$AUDIO/sinks"
        pactl set-default-sink omarchy_speaker_tuning
        for stream in $(awk '{print $1}' "$AUDIO/streams"); do
          pactl move-sink-input "$stream" omarchy_speaker_tuning
        done
        ;;
      refused) exit 1 ;;
      removed)
        rm -f "$FRAGMENT"
        exit 1
        ;;
    esac
    ;;
  fronted-sink) printf '%s\n' "$SPEAKERS" ;;
esac
SH
chmod +x "$test_dir/bin/"*

xps16="$ROOT/default/audio/tunings/dell-xps-16-2026"
xps14="$ROOT/default/audio/tunings/dell-xps-14-2026"

install_fragment() {
  mkdir -p "$(dirname "$FRAGMENT")"
  printf '%s\n' "$1" '#' 'context.modules = [ ]' >"$FRAGMENT"
}

# audio <default> [<stream>:<sink index> ...]: speakers 41, headphones 52, HDMI
# 60, the tuning 63. A stream on the default follows it; any other is pinned.
audio() {
  mkdir -p "$AUDIO"
  printf '%s\n' "41 $SPEAKERS" "52 bluez_output.headphones" "60 alsa_output.hdmi" "63 omarchy_speaker_tuning" >"$AUDIO/sinks"
  printf '%s\n' "$1" >"$AUDIO/default"
  local default stream
  default=$(awk -v s="$1" '$2 == s {print $1}' "$AUDIO/sinks")
  shift
  : >"$AUDIO/streams"
  for stream in "$@"; do
    printf '%s %s %s\n' "${stream%%:*}" "${stream##*:}" "$([[ ${stream##*:} == "$default" ]] && echo 1 || echo 0)" >>"$AUDIO/streams"
  done
}

shared_tuning() {
  install_fragment "# Dell XPS 14 / XPS 16 (2026) speaker tuning."
}

run_migration() {
  : >"$CALL_LOG"
  HOME="$test_dir/home" XDG_CONFIG_HOME="$test_dir/config" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration" >"$test_dir/output" 2>&1
}

replaced() {
  grep -qx 'tuning on' "$CALL_LOG"
}

audio_is() {
  local expected="$1"
  shift
  [[ $(cat "$AUDIO/default") == "$expected" ]] || return 1
  local stream
  for stream in "$@"; do
    grep -q "^${stream%%:*} ${stream##*:} " "$AUDIO/streams" || return 1
  done
}

[[ -d $xps16 && -d $xps14 ]] || fail "the XPS 14 and XPS 16 tunings ship under the names the migration matches"

shared_tuning
audio omarchy_speaker_tuning 101:63 102:60
TUNING_MATCH="$xps16" run_migration || fail "migration replaces the shared tuning" "$(cat "$test_dir/output")"
replaced || fail "an XPS 16 on the shared tuning gets its own" "$(cat "$CALL_LOG")"
[[ $(head -1 "$FRAGMENT") == "# Dell XPS 16 (2026) speaker tuning." ]] || fail "the XPS 16 tuning is installed"
audio_is omarchy_speaker_tuning 101:70 102:60 || fail "the speakers stay on the tuning and HDMI stays on HDMI" "$(cat "$AUDIO/default" "$AUDIO/streams")"
pass "an XPS 16 on the shared tuning gets its own"

TUNING_MATCH="$xps16" run_migration || fail "migration can be rerun"
! replaced || fail "a rerun leaves the XPS 16 tuning alone" "$(cat "$CALL_LOG")"
pass "migration is idempotent"

shared_tuning
audio bluez_output.headphones 101:52 102:60 103:63 104:41
TUNING_MATCH="$xps16" run_migration || fail "migration runs while headphones are selected" "$(cat "$test_dir/output")"
replaced || fail "the tuning is replaced while headphones are selected"
audio_is bluez_output.headphones 101:52 102:60 103:70 104:70 || fail "every stream plays where it did, the speakers through the new tuning" "$(cat "$AUDIO/default" "$AUDIO/streams")"
pass "an update does not move headphone or HDMI playback to the speakers"

shared_tuning
audio "$SPEAKERS" 101:41
TUNING_MATCH="$xps16" run_migration || fail "migration runs while the raw speakers are selected"
audio_is omarchy_speaker_tuning 101:70 || fail "speakers selected directly end up on the tuning" "$(cat "$AUDIO/default" "$AUDIO/streams")"
pass "speakers selected directly end up on the tuning"

shared_tuning
audio bluez_output.headphones 101:52
TUNING_MATCH="$xps16" ON_VANISH=headphones run_migration || fail "an output that went away does not fail the migration" "$(cat "$test_dir/output")"
audio_is omarchy_speaker_tuning 101:70 || fail "streams whose output went away stay on the tuning" "$(cat "$AUDIO/default" "$AUDIO/streams")"
pass "an output that went away meanwhile is left alone"

shared_tuning
audio omarchy_speaker_tuning 101:63
cp "$FRAGMENT" "$test_dir/before"
if TUNING_MATCH="$xps16" ON_RESULT=removed run_migration; then
  fail "a tuning that fails to come up stops the migration"
fi
cmp -s "$test_dir/before" "$FRAGMENT" || fail "the shared tuning is kept for the retry"
TUNING_MATCH="$xps16" run_migration || fail "the retry succeeds" "$(cat "$test_dir/output")"
replaced || fail "the retry replaces the shared tuning" "$(cat "$CALL_LOG")"
pass "a failed replacement is retried rather than skipped"

shared_tuning
audio omarchy_speaker_tuning 101:63
cp "$FRAGMENT" "$test_dir/before"
if TUNING_MATCH="$xps16" ON_RESULT=refused run_migration; then
  fail "a refused replacement stops the migration"
fi
cmp -s "$test_dir/before" "$FRAGMENT" || fail "a refused replacement leaves the shared tuning in place"
pass "a refused replacement stays pending"

install_fragment "# Generated by Omarchy Speaker Calibrator."
cp "$FRAGMENT" "$test_dir/before"
TUNING_MATCH="$xps16" run_migration || fail "migration skips a calibrator profile"
if replaced || ! cmp -s "$test_dir/before" "$FRAGMENT"; then
  fail "a calibrator profile is kept" "$(cat "$CALL_LOG")"
fi
pass "a calibrator profile is kept"

rm -f "$FRAGMENT"
TUNING_MATCH="$xps16" run_migration || fail "migration skips a tuning that was switched off"
if replaced || [[ -e $FRAGMENT ]]; then
  fail "a tuning switched off stays off" "$(cat "$CALL_LOG")"
fi
pass "a tuning switched off stays off"

shared_tuning
TUNING_MATCH="$xps14" run_migration || fail "migration skips an XPS 14"
! replaced || fail "an XPS 14 keeps its tuning" "$(cat "$CALL_LOG")"
TUNING_MATCH="" run_migration || fail "migration skips other hardware"
! replaced || fail "other hardware is untouched" "$(cat "$CALL_LOG")"
pass "only the XPS 16 is re-tuned"
