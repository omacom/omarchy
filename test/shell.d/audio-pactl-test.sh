#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

# The default source is a microphone muted or not as $MIC_STATE says, which
# set-mute toggles. With no file wpctl answers as the real one does with no
# microphone: an error on stderr, nothing on stdout, exit 0.
cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
state=$(cat "$MIC_STATE" 2>/dev/null)
case "$*" in
  "get-volume @DEFAULT_AUDIO_SOURCE@")
    if [[ -z $state ]]; then
      echo "Translate ID error: '-1' is not a valid ID (returned by default-nodes-api)" >&2
    elif [[ $state == "muted" ]]; then
      echo "Volume: 1.00 [MUTED]"
    else
      echo "Volume: 1.00"
    fi
    ;;
  "set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    if [[ $state == "muted" ]]; then echo on >"$MIC_STATE"; else echo muted >"$MIC_STATE"; fi
    ;;
esac
SH

cat >"$work/bin/omarchy-brightness-keyboard-mute" <<'SH'
#!/bin/bash
printf 'omarchy-brightness-keyboard-mute %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
case ${1:-} in
  fronted-sink) exit 1 ;;
  *) exit 0 ;;
esac
SH

# Every call is logged with the locale it ran in. Listings the cases below
# vary come from $SOURCES, $SINKS and $OUTPUTS.
cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf '%s pactl %s\n' "${LC_ALL:-unset}" "$*" >>"$CALLS"
case "$*" in
  "list sink-inputs")
    cat <<'OUT'
Sink Input #42
	Sink: 10
	Properties:
		application.name = "Firefox"
		node.name = "Firefox"
OUT
    ;;
  "-f json list sinks")
    cat <<'OUT'
[
  {
    "index": 1,
    "name": "alsa_output.speakers",
    "description": "Speakers",
    "ports": [{"name": "analog-output-speakers", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "50%"}}
  },
  {
    "index": 2,
    "name": "alsa_output.headphones",
    "description": "Headphones",
    "ports": [{"name": "analog-output-headphones", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "70%"}}
  }
]
OUT
    ;;
  "get-default-sink")
    echo "alsa_output.speakers"
    ;;
  "get-sink-volume "*)
    echo "Volume: front-left: 32768 /  50% / -18.06 dB"
    ;;
  "get-sink-mute "*)
    echo "Mute: no"
    ;;
  "list sinks short")
    printf '1\talsa_output.speakers\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n'
    ;;
  "list sources") cat "$SOURCES" ;;
  "list sinks") cat "$SINKS" ;;
  "list source-outputs") cat "$OUTPUTS" ;;
esac
exit 0
SH
chmod +x "$work/bin"/*

export MIC_STATE="$work/mic" CALLS="$work/calls" SOURCES="$work/sources" SINKS="$work/sinks" OUTPUTS="$work/outputs"
export PATH="$work/bin:$ROOT/bin:$PATH"

calls() {
  cat "$CALLS"
}

# --- pactl output is parsed in the C locale, whatever the caller's ---

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-set-default 42 alsa_output.speakers 2>/dev/null || true
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-set-default reads sink-inputs in the C locale' "$(calls)"
grep -q 'pactl move-sink-input 42 alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-set-default moves streams' "$(calls)"
pass 'audio-output-set-default reads sink-inputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-sink "virtual_sink" >/dev/null 2>&1
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-sink reads sink-inputs in the C locale' "$(calls)"
pass 'audio-output-sink reads sink-inputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-switch 2>/dev/null || true
grep -qx 'C pactl -f json list sinks' "$CALLS" ||
  fail 'audio-output-switch reads sinks in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-volume alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink volume in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-mute alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink mute in the C locale' "$(calls)"
pass 'audio-output-switch reads pactl outputs in the C locale'

: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-output-volume +5 2>/dev/null || true
grep -qx 'C pactl get-sink-volume alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink volume in the C locale' "$(calls)"
grep -qx 'C pactl get-sink-mute alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink mute in the C locale' "$(calls)"
pass 'audio-output-volume reads pactl outputs in the C locale'

: >"$CALLS"
(
  eval "$(sed -n '/^app_streams() {/,/^}/p' "$ROOT/bin/omarchy-audio-tuning")"
  LC_ALL=en_US.UTF-8 app_streams 2>/dev/null >/dev/null
)
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-tuning app_streams reads sink-inputs in the C locale' "$(calls)"
pass 'audio-tuning app_streams reads sink-inputs in the C locale'

# --- omarchy-audio-input-mute ---

rm -f "$MIC_STATE"
: >"$CALLS"
if omarchy-audio-input-mute 2>"$work/err"; then
  fail 'input mute with no microphone fails' "$(calls)"
fi
grep -qx 'No microphone found.' "$work/err" || fail 'input mute with no microphone says so' "$(cat "$work/err")"
grep -qx 'omarchy-osd -i microphone-off -m No microphone found' "$CALLS" ||
  fail 'input mute with no microphone shows it' "$(calls)"
! grep -qE 'set-mute|keyboard-mute' "$CALLS" ||
  fail 'input mute with no microphone toggles nothing' "$(calls)"
pass 'input mute says there is no microphone, and toggles nothing'

echo on >"$MIC_STATE"
: >"$CALLS"
omarchy-audio-input-mute || fail 'input mute with a microphone succeeds' "$(calls)"
[[ $(cat "$MIC_STATE") == "muted" ]] || fail 'input mute toggles the microphone' "$(calls)"
grep -qx 'omarchy-brightness-keyboard-mute on' "$CALLS" &&
  grep -qx 'omarchy-osd -i microphone-muted -m Microphone muted' "$CALLS" ||
  fail 'input mute shows the microphone muted after muting it' "$(calls)"
: >"$CALLS"
omarchy-audio-input-mute || fail 'input mute with a muted microphone succeeds' "$(calls)"
[[ $(cat "$MIC_STATE") == "on" ]] || fail 'input mute unmutes a muted microphone' "$(calls)"
grep -qx 'omarchy-brightness-keyboard-mute off' "$CALLS" &&
  grep -qx 'omarchy-osd -i microphone -m Microphone on' "$CALLS" ||
  fail 'input mute shows the microphone on after unmuting it' "$(calls)"
pass 'input mute still toggles a microphone and shows what it became'

# --- omarchy-audio-sink-availability ---

# A headset jack input with nothing plugged in, a virtual source (no ports)
# and a filter's source (one port of unknown availability).
cat >"$SOURCES" <<'OUT'
Source #1074
	Name: alsa_input.pci-0000_00_1f.3.analog-stereo
	Ports:
		[In] analog-input-headset-mic: Headset Microphone (type: Headset, priority: 300, availability group: Headset Mic, not available)
	Active Port: [In] analog-input-headset-mic
	Formats:
		pcm
Source #126
	Name: easyeffects_source
	Formats:
		pcm
Source #1102
	Name: effect_output.mic-filter
	Ports:
		[In] Mic: Microphone (type: Mic, priority: 100, availability unknown)
	Active Port: [In] Mic
OUT
cat >"$SINKS" <<'OUT'
Sink #57
	Name: alsa_output.pci-0000_00_1f.3.analog-stereo
	Ports:
		[Out] analog-output-headphones: Headphones (type: Headphones, priority: 300, availability group: Headphone, not available)
	Active Port: [Out] analog-output-headphones
OUT

: >"$CALLS"
expected=$'alsa_input.pci-0000_00_1f.3.analog-stereo\t0\neasyeffects_source\t1\neffect_output.mic-filter\t1'
actual=$(omarchy-audio-sink-availability sources)
[[ $actual == "$expected" ]] || fail 'source availability reports an empty jack input unavailable' "$actual"
grep -qx 'C pactl list sources' "$CALLS" || fail 'source availability reads pactl in the C locale' "$(calls)"
pass 'source availability reports an empty jack input unavailable'

: >"$CALLS"
actual=$(LC_ALL=de_DE.UTF-8 omarchy-audio-sink-availability)
[[ $actual == $'alsa_output.pci-0000_00_1f.3.analog-stereo\t0' ]] || fail 'sink availability reports an empty headphone jack unavailable' "$actual"
grep -qx 'C pactl list sinks' "$CALLS" || fail 'sink availability reads pactl in the C locale whatever the caller'"'"'s' "$(calls)"
pass 'sink availability reports an empty headphone jack unavailable, in the C locale'

# --- omarchy-audio-input-set-default ---

moved() {
  grep ' pactl move-source-output ' "$CALLS" | awk '{ print $4 }' | tr '\n' ' '
}

# A filter chain's capture half (joined to its source by node.link-group)
# records its device all the time. Choosing an input moves apps, never it.
cat >"$OUTPUTS" <<'OUT'
Source Output #67
	Driver: PipeWire
	Properties:
		node.name = "filter_capture.mic"
		node.group = "filter-chain-100-18"
		node.link-group = "filter-chain-100-18"
		media.name = "Microphone filter"
Source Output #90
	Driver: PipeWire
	Properties:
		application.name = "Firefox"
		node.name = "Firefox"
Source Output #91
	Properties:
		node.name = "native-recorder"
		media.name = "node.link-group = in a title"
OUT
: >"$CALLS"
LC_ALL=en_US.UTF-8 omarchy-audio-input-set-default 113 virtual_mic
grep -qx 'wpctl set-default 113' "$CALLS" || fail 'input set-default selects the node' "$(calls)"
grep -q ' pactl set-default-source virtual_mic$' "$CALLS" || fail 'input set-default names the default source' "$(calls)"
grep -qx 'C pactl list source-outputs' "$CALLS" || fail 'input set-default reads the recordings in the C locale' "$(calls)"
[[ $(moved) == "90 91 " ]] || fail 'input set-default moves apps but not a filter'"'"'s own capture' "$(moved)"
pass 'input set-default moves apps but not a filter'"'"'s own capture'

# Without filters every recording moves, as before, whatever its properties.
cat >"$OUTPUTS" <<'OUT'
Source Output #12
	Properties:
		application.name = "OBS"
Source Output #13
	Properties:
		node.name = "native-recorder"
Source Output #14
	Properties:
		node.name = "filter_capture.mic-copy"
		node.group = "pipewire.dummy"
OUT
: >"$CALLS"
omarchy-audio-input-set-default 43 alsa_input.pci-0000_00_1f.3.analog-stereo
[[ $(moved) == "12 13 14 " ]] || fail 'input set-default still moves every other recording' "$(moved)"
pass 'input set-default still moves every other recording'

# Framework gain initialization must leave UCM's headphone routes alone and
# must not raise hardware gain before software volume and all controls exist.
(
  framework_tmp="$work/framework16"
  stub_bin="$framework_tmp/bin"
  calls="$framework_tmp/calls"
  mkdir -p "$stub_bin" "$framework_tmp/dmi"
  export PATH="$stub_bin:$ROOT/bin:$PATH" CALLS="$calls" FRAMEWORK_DMI="$framework_tmp/dmi"
  export XDG_CONFIG_HOME="$framework_tmp/config"
  export FRAMEWORK_AUDIO="$framework_tmp/audio.json" FRAMEWORK_MIXER="$framework_tmp/mixer"
  # Run the real predicates against temporary DMI attributes, never host sysfs.
  for predicate in omarchy-hw-framework16 omarchy-hw-match; do
    sed 's|/sys/class/dmi/id|"$FRAMEWORK_DMI"|g' "$ROOT/bin/$predicate" >"$stub_bin/$predicate"
    chmod +x "$stub_bin/$predicate"
  done
  framework_machine() {
    local vendor=Framework model="Laptop 16 (AMD Ryzen AI 300 Series)"
    case $1 in
      plain) vendor=Other model="Other laptop" ;;
      framework16-7040) model="Laptop 16 (AMD Ryzen 7040 Series)" ;;
      framework16-other-vendor) vendor=Other ;;
    esac
    printf '%s\n' "$vendor" >"$FRAMEWORK_DMI/sys_vendor"
    printf '%s\n' "$model" >"$FRAMEWORK_DMI/product_name"
    : >"$FRAMEWORK_DMI/product_family"
  }
  setup_framework() {
    bash -euo pipefail "$ROOT/install/user/hardware/framework/fix-f16-ai300-speaker-volume.sh" >/dev/null
  }
  mixer="$XDG_CONFIG_HOME/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
  unit="$XDG_CONFIG_HOME/systemd/user/omarchy-framework16-speaker-levels.service"
  link="$XDG_CONFIG_HOME/systemd/user/wireplumber.service.wants/${unit##*/}"
  source_mixer="$ROOT/default/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
  for machine_name in plain framework16-7040 framework16-other-vendor; do
    framework_machine "$machine_name"
    setup_framework
    [[ ! -e $XDG_CONFIG_HOME ]] || fail "Framework setup leaves unsupported hardware alone"
  done
  framework_machine framework16-ai300
  for command in cp ln; do
    cat >"$stub_bin/$command" <<'SH'
#!/bin/bash
if [[ ${FRAMEWORK_INTERRUPT:-} == "${0##*/}" ]]; then
  [[ ${0##*/} != "cp" ]] || printf '# partial copy\n' >"${@: -1}"
  exit 99
else
  "/usr/bin/${0##*/}" "$@"
fi
SH
    chmod +x "$stub_bin/$command"
  done
  for interrupted in cp ln; do
    rm -f "$mixer" "$link"
    if FRAMEWORK_INTERRUPT=$interrupted setup_framework; then
      fail "interrupted Framework setup reports failure"
    fi
    setup_framework
    cmp -s "$source_mixer" "$mixer" || fail "Framework setup recovers the complete mixer rule"
    [[ ! -e $unit && ! -L $unit && $(readlink "$link") == "/usr/lib/systemd/user/${unit##*/}" ]] ||
      fail "Framework setup recovers offline enablement without shadowing the packaged unit"
  done
  pass "Framework setup recovers interrupted copying and enablement"

  for override in mask custom; do
    rm -f "$unit"
    if [[ $override == "mask" ]]; then
      ln -s /dev/null "$unit"
    else
      printf '# custom unit\n' >"$unit"
    fi
    setup_framework
    if [[ $override == "mask" ]]; then
      [[ $(readlink "$unit") == "/dev/null" ]] || fail "Framework setup preserves a service mask"
    else
      [[ $(<"$unit") == "# custom unit" ]] || fail "Framework setup preserves a service override"
    fi
  done
  rm -f "$mixer" "$link"
  cp "$source_mixer" "$framework_tmp/external-mixer"
  ln -s "$framework_tmp/external-mixer" "$mixer"
  setup_framework
  [[ $(readlink "$mixer") == "$framework_tmp/external-mixer" && -L $link ]] ||
    fail "Framework setup uses a compatible mixer symlink without replacing it"
  for custom in regular symlink dangling; do
    rm -f "$mixer" "$link"
    if [[ $custom == "regular" ]]; then
      printf '# custom mixer\n' >"$mixer"
    else
      printf '# custom mixer\n' >"$framework_tmp/external-mixer"
      ln -s "$framework_tmp/external-mixer" "$mixer"
      [[ $custom != "dangling" ]] || rm "$framework_tmp/external-mixer"
    fi
    setup_framework
    [[ ! -L $link ]] || fail "Framework setup does not enable initialization for a custom mixer"
    if [[ $custom == "dangling" ]]; then
      [[ ! -e $mixer ]] || fail "Framework setup preserves a dangling mixer symlink"
    else
      [[ $(<"$mixer") == "# custom mixer" ]] || fail "Framework setup preserves custom mixer contents"
    fi
    [[ $custom == "regular" || $(readlink "$mixer") == "$framework_tmp/external-mixer" ]] ||
      fail "Framework setup preserves mixer symlinks"
  done
  pass "Framework setup preserves custom mixer configuration, overrides and masks"

  cat >"$stub_bin/pw-dump" <<'SH'
#!/bin/bash
if [[ ${FRAMEWORK_DELAY:-0} == "1" && ! -e $FRAMEWORK_AUDIO.ready ]]; then
  touch "$FRAMEWORK_AUDIO.ready"
  printf '[]\n'
else
  cat "$FRAMEWORK_AUDIO"
fi
SH
  cat >"$stub_bin/amixer" <<'SH'
#!/bin/bash
set -euo pipefail
control="$FRAMEWORK_MIXER/$2/$4"
if [[ $3 == "sget" ]]; then
  [[ -f $control ]]
else
  [[ $3 == "sset" ]]
  read -r gain switch <"$control"
  for value in "${@:5}"; do
    case $value in
      *dB) gain=$value ;;
      unmute|on) switch=on ;;
      mute|off) switch=off ;;
      *) exit 1 ;;
    esac
  done
  printf '%s %s\n' "$gain" "$switch" >"$control"
  printf '%s\n' "$*" >>"$CALLS"
fi
SH
  printf '#!/bin/bash\ntrue\n' >"$stub_bin/sleep"
  chmod +x "$stub_bin/pw-dump" "$stub_bin/amixer" "$stub_bin/sleep"
  framework_audio() {
    printf '[{"type":"PipeWire:Interface:Device","info":{"props":{"alsa.components":"HDA:1002aa01,00aa0100,00100900","api.alsa.card":2,"api.alsa.soft-mixer":true}}},
      {"type":"PipeWire:Interface:Device","info":{"props":{"alsa.components":"%s","api.alsa.card":9,"api.alsa.soft-mixer":%s}}}]\n' "$1" "$2" >"$FRAMEWORK_AUDIO"
  }
  initialize_framework() {
    : >"$calls"
    bash "$ROOT/bin/omarchy-apply-framework16-speaker-levels"
  }
  framework_audio 'HDA:10ec0285,f111000d,00100002' true
  mkdir -p "$FRAMEWORK_MIXER/2" "$FRAMEWORK_MIXER/9"
  for route in off on; do
    for card in 2 9; do
      for control in Master Speaker 'Bass Speaker'; do
        printf -- '-20dB %s\n' "$route" >"$FRAMEWORK_MIXER/$card/$control"
      done
    done
    rm -f "$FRAMEWORK_AUDIO.ready"
    FRAMEWORK_DELAY=1 initialize_framework
    [[ $(<"$FRAMEWORK_MIXER/9/Master") == "0dB on" ]] || fail "Framework initialization sets and unmutes Master"
    for control in Speaker 'Bass Speaker'; do
      [[ $(<"$FRAMEWORK_MIXER/9/$control") == "0dB $route" ]] || fail "Framework initialization preserves $route speaker routes"
    done
    for control in Master Speaker 'Bass Speaker'; do
      [[ $(<"$FRAMEWORK_MIXER/2/$control") == "-20dB $route" ]] || fail "Framework initialization leaves other cards alone"
    done
  done
  pass "Framework initialization waits for discovery, sets gains and preserves speaker routes"
  for machine_name in plain framework16-7040 framework16-other-vendor; do
    framework_machine "$machine_name"
    initialize_framework
    [[ ! -s $calls ]] || fail "Framework initialization leaves unsupported hardware alone"
  done
  framework_machine framework16-ai300
  for gate in software-volume codec controls; do
    framework_audio 'HDA:10ec0285,f111000d,00100002' true
    case $gate in
      software-volume) framework_audio 'HDA:10ec0285,f111000d,00100002' false ;;
      codec) framework_audio 'HDA:10ec0285,12345678,00100002' true ;;
      controls) rm "$FRAMEWORK_MIXER/9/Bass Speaker" ;;
    esac
    status=0
    initialize_framework 2>/dev/null || status=$?
    if [[ $gate == "controls" ]]; then
      (( status != 0 && status != 75 )) || fail "missing Framework controls fail without discovery retry"
    else
      (( status == 75 )) || fail "undiscovered Framework software mixer requests a retry"
    fi
    [[ ! -s $calls ]] || fail "Framework $gate gate prevents partial mixer changes"
  done
  pass "Framework initialization requires matching hardware, software volume and every control"
)
