#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

paths_dir="$ROOT/default/alsa-card-profile/mixer/paths"
leaf="$ROOT/install/user/hardware/asus/fix-audio-mixer.sh"

# Prints "<element> <key> <value>" for every switch/volume line in a path file.
element_settings() {
  awk '
    /^\[/ { section = $0 }
    section ~ /^\[Element / && /^(switch|volume) = / {
      name = section
      sub(/^\[Element /, "", name)
      sub(/\]$/, "", name)
      print name "\t" $1 "\t" $3
    }
  ' "$1"
}

setting_of() {
  element_settings "$1" | awk -F '\t' -v name="$2" -v key="$3" '$1 == name && $2 == key { print $3 }'
}

for path in analog-output-speaker analog-output-headphones; do
  file="$paths_dir/$path.conf"
  [[ -f $file ]] || fail "$path override is shipped"

  # The soft mixer never drives mute/merge elements, so any left on an output
  # stays wherever the other path last put it.
  undriven=$(element_settings "$file" | awk -F '\t' '
    $1 != "Master" && $1 != "Hardware Master" && (($2 == "switch" && $3 == "mute") || ($2 == "volume" && $3 == "merge"))
  ')
  [[ -z $undriven ]] || fail "$path leaves no output element for the soft mixer to drive" "$undriven"

  [[ $(setting_of "$file" Master switch) == "mute" && $(setting_of "$file" Master volume) == "merge" ]] ||
    fail "$path leaves Master to the install-time level"

  grep -qx '.include analog-output.conf.common' "$file" || fail "$path still includes the common path"
done
pass "override paths turn their own output on and leave Master alone"

speaker="$paths_dir/analog-output-speaker.conf"
headphones="$paths_dir/analog-output-headphones.conf"

[[ $(setting_of "$speaker" Speaker switch) == "on" && $(setting_of "$speaker" Speaker volume) == "zero" ]] ||
  fail "speaker path turns Speaker on at 0 dB"
[[ $(setting_of "$speaker" "Bass Speaker" switch) == "on" ]] || fail "speaker path turns Bass Speaker on"
[[ $(setting_of "$speaker" Headphone switch) == "off" ]] || fail "speaker path still turns Headphone off"
[[ $(setting_of "$headphones" Headphone switch) == "on" && $(setting_of "$headphones" Headphone volume) == "zero" ]] ||
  fail "headphones path turns Headphone on at 0 dB"
[[ $(setting_of "$headphones" Speaker switch) == "off" ]] || fail "headphones path still turns Speaker off"
pass "each path turns its output on and the other output off"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

cat >"$test_dir/bin/omarchy-hw-asus-rog" <<'STUB'
#!/bin/bash

[[ ${ROG:-1} == 1 ]]
STUB

cat >"$test_dir/bin/aplay" <<'STUB'
#!/bin/bash

echo "card 1: Generic [HD-Audio Generic], device 3: HDMI 0 [HDMI 0]"
echo "card 2: Generic_1 [HD-Audio Generic], device 0: ALC294 Analog [ALC294 Analog]"
STUB

cat >"$test_dir/bin/amixer" <<'STUB'
#!/bin/bash

printf 'amixer %s\n' "$*" >>"$CALLS"
exit "${AMIXER_EXIT:-0}"
STUB

chmod +x "$test_dir/bin/"*

# Runs the leaf the way run_logged does: sourced under bash -eE.
run_leaf() {
  local home="$1"
  shift

  mkdir -p "$home"
  env HOME="$home" OMARCHY_PATH="$ROOT" CALLS="$home/calls" PATH="$test_dir/bin:$PATH" "$@" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

home="$test_dir/rog"
run_leaf "$home" || fail "leaf succeeds on a ROG machine"

installed="$home/.config/alsa-card-profile/mixer/paths"
for path in analog-output-speaker analog-output-headphones; do
  cmp -s "$paths_dir/$path.conf" "$installed/$path.conf" || fail "leaf installs the $path override"
done
[[ $(readlink "$installed/analog-output.conf.common") == "/usr/share/alsa-card-profile/mixer/paths/analog-output.conf.common" ]] ||
  fail "leaf links the common path beside the overrides"
[[ -f $home/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf ]] || fail "leaf still installs the soft mixer"
grep -qx 'amixer -c 2 set Master 80% unmute' "$home/calls" || fail "leaf unmutes Master on the Realtek card" "$(cat "$home/calls")"
pass "leaf installs the soft mixer, the override paths, and unmutes Master"

run_leaf "$home" || fail "leaf can run again"
[[ -L $installed/analog-output.conf.common && ! -e $installed/analog-output.conf.common/analog-output.conf.common ]] ||
  fail "a second run replaces the common path link instead of nesting one"
pass "leaf is repeatable"

home="$test_dir/missing-master"
run_leaf "$home" AMIXER_EXIT=1 || fail "leaf succeeds when the codec has no Master control"
pass "a missing Master control does not fail the install"

home="$test_dir/other"
run_leaf "$home" ROG=0 || fail "leaf succeeds on other machines"
[[ ! -e $home/.config/alsa-card-profile && ! -e $home/.config/wireplumber && ! -e $home/calls ]] ||
  fail "leaf leaves other machines alone"
pass "leaf leaves other machines alone"
