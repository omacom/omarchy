#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export PATH="$ROOT/bin:$PATH"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

intro_home="$test_tmp/home"
intro_runtime="$test_tmp/runtime"
intro_state="$intro_home/.local/state/omarchy/current"
theme_intro_dir="$intro_state/theme/backgrounds/intros"
background="$intro_state/theme/backgrounds/road.webp"
mkdir -p "$(dirname "$background")" "$theme_intro_dir" "$intro_runtime"
printf 'matching still\n' >"$background"
printf 'theme video\n' >"$theme_intro_dir/road.mp4"
printf 'tokyo-night\n' >"$intro_state/theme.name"
ln -s "$background" "$intro_state/background"

resolved=$(HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-only)
[[ $resolved == "$theme_intro_dir/road.mp4" ]] || fail "a sibling intro matches the current image by filename" "$resolved"
rm "$theme_intro_dir/road.mp4"
resolved=$(HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-only)
[[ -z $resolved ]] || fail "a background without a matching video has no intro" "$resolved"
printf 'theme video\n' >"$theme_intro_dir/road.mp4"

custom_background="$intro_home/.config/omarchy/backgrounds/tokyo-night/road.webp"
mkdir -p "${custom_background%/*}"
printf 'different still with the same name\n' >"$custom_background"
ln -nsf "$custom_background" "$intro_state/background"
resolved=$(HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-only)
[[ -z $resolved ]] || fail "a different image directory does not inherit the theme intro" "$resolved"
ln -nsf "$background" "$intro_state/background"

toggle="$intro_home/.local/state/omarchy/toggles/background-intros-off"
marker="$intro_home/.local/state/omarchy/background-intro.session-id"
command_bin="$test_tmp/bin"
command_log="$test_tmp/command-log"
mkdir -p "$command_bin"
cat >"$command_bin/owe" <<'SH'
#!/bin/bash
printf 'owe: %s\n' "$*" >>"$COMMAND_LOG"
case ${1:-} in
  intro)
    [[ ${OWE_FAIL:-} != "interrupted" && ${OWE_FAIL:-} != "unavailable" ]] || exit 1
    [[ -z ${OWE_READY_FILE:-} || -f $OWE_READY_FILE ]] || exit 1
    ;;
  status)
    [[ ${OWE_FAIL:-} != "unavailable" ]] || exit 1
    # OWE comes up on probe OWE_READY_AFTER, first running OWE_WHILE_STARTING:
    # a change made while the launcher is already waiting.
    if [[ -n ${OWE_READY_AFTER:-} && ! -f $OWE_READY_FILE ]]; then
      probes=$(( $(cat "$OWE_READY_FILE.probes" 2>/dev/null || echo 0) + 1 ))
      echo "$probes" >"$OWE_READY_FILE.probes"
      if (( probes >= OWE_READY_AFTER )); then
        [[ -z ${OWE_WHILE_STARTING:-} ]] || bash -c "$OWE_WHILE_STARTING"
        touch "$OWE_READY_FILE"
      fi
    fi
    [[ -z ${OWE_READY_FILE:-} || -f $OWE_READY_FILE ]] || exit 1
    printf '{"status":"ok"}\n'
    ;;
esac
SH
chmod +x "$command_bin/owe"
cat >"$command_bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"option":"animations:enabled","int":%s,"bool":%s}\n' \
  "$([[ ${ANIMATIONS:-on} == on ]] && echo 1 || echo 0)" "$([[ ${ANIMATIONS:-on} == on ]] && echo true || echo false)"
SH
chmod +x "$command_bin/hyprctl"

mkdir -p "$(dirname "$toggle")"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-startup)
[[ $resolved == "$theme_intro_dir/road.mp4" ]] || fail "OWE can prepare the selected intro while the shell starts" "$resolved"
[[ ! -e $marker && ! -s $command_log ]] || fail "startup preparation does not consume the login or start playback"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" ANIMATIONS=off "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-startup)
[[ -z $resolved ]] || fail "disabled animations skip startup preparation"
touch "$toggle"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-startup)
[[ -z $resolved ]] || fail "disabled intros skip startup preparation"
pass "speculative login preparation respects settings and leaves playback to the shell"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OMARCHY_SESSION_ID=disabled-boot "$ROOT/bin/omarchy-theme-bg-boot-intro")
[[ -z $resolved && $(<"$marker") == "disabled-boot" ]] || fail "the global toggle consumes the current login without playing"
rm "$toggle"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OMARCHY_SESSION_ID=disabled-boot "$ROOT/bin/omarchy-theme-bg-boot-intro")
[[ -z $resolved ]] || fail "enabling midway through a login does not start a delayed intro" "$resolved"

: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" ANIMATIONS=off OMARCHY_SESSION_ID=still-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"
[[ $(<"$marker") == "still-boot" ]] || fail "with animations off the session is consumed"
! grep -q '^owe: intro ' "$command_log" || fail "with animations off no intro plays"

rm "$marker"
: >"$command_log"
# This case runs a scratch copy with the five-second OWE window shortened
# to two seconds; it proves the wait retries and then gives up, not the
# window's real length. SECONDS is whole seconds, so a one-second window could
# close straight after the first probe.
boot_intro_fast="$test_tmp/boot-intro-fast"
sed 's/SECONDS + 5/SECONDS + 2/' "$ROOT/bin/omarchy-theme-bg-boot-intro" >"$boot_intro_fast"
! cmp -s "$ROOT/bin/omarchy-theme-bg-boot-intro" "$boot_intro_fast" || fail "the scratch copy shortens the OWE window"
chmod +x "$boot_intro_fast"
if ! PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_FAIL=unavailable OMARCHY_SESSION_ID=unavailable-boot timeout 15 "$boot_intro_fast"; then
  fail "an unavailable OWE settles startup rather than requesting another launcher"
fi
probes=$(grep -c '^owe: status' "$command_log" || true)
(( probes >= 2 )) || fail "startup keeps probing OWE through its window" "$probes"
[[ $(<"$marker") == "unavailable-boot" ]] || fail "an unavailable OWE still settles the session"
! grep -q '^owe: intro ' "$command_log" || fail "an unavailable OWE never starts an intro"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OMARCHY_SESSION_ID=unavailable-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"
! grep -q '^owe: intro ' "$command_log" || fail "starting OWE after the deadline does not play a late intro"

rm "$marker"
: >"$command_log"
ready="$test_tmp/owe-ready"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OWE_READY_AFTER=3 OMARCHY_SESSION_ID=delayed-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"
[[ $(<"$marker") == "delayed-boot" ]] || fail "waiting for OWE keeps the session consumed"
grep -Fxq "owe: intro --start first-frame $theme_intro_dir/road.mp4" "$command_log" || fail "a ready OWE starts on the video's first frame without revealing the still"

rm -f "$marker" "$ready"*
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=restart-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro" &
waiting_pid=$!
for attempt in {1..500}; do
  [[ -f $marker && $(<"$marker") == "restart-while-waiting" ]] && break
  sleep 0.01
done
[[ -f $marker && $(<"$marker") == "restart-while-waiting" ]] || fail "the waiting launcher consumes the session before it waits for OWE"
# The waiting launcher holds out for OWE for five seconds; returning well
# inside that shows the restart did not queue behind it.
if ! PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=restart-while-waiting timeout 3 "$ROOT/bin/omarchy-theme-bg-boot-intro"; then
  kill "$waiting_pid" 2>/dev/null || true
  wait "$waiting_pid" || true
  fail "a restarted shell reads the consumed session without waiting for the old launcher"
fi
touch "$ready"
wait "$waiting_pid"

rm -f "$marker" "$ready"*
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OWE_READY_AFTER=2 \
  OWE_WHILE_STARTING="touch '$toggle'" OMARCHY_SESSION_ID=disabled-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro"
[[ -f $toggle ]] || fail "intros are disabled while the launcher waits for OWE"
! grep -q '^owe: intro ' "$command_log" || fail "disabling intros while waiting cancels startup playback"
rm -f "$toggle" "$ready"* "$marker"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OWE_READY_AFTER=2 \
  OWE_WHILE_STARTING="ln -nsf '$custom_background' '$intro_state/background'" OMARCHY_SESSION_ID=changed-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro"
[[ $(readlink "$intro_state/background") == "$custom_background" ]] || fail "the background changes while the launcher waits for OWE"
! grep -q '^owe: intro ' "$command_log" || fail "changing the background while waiting cancels its old intro"
ln -nsf "$background" "$intro_state/background"

rm "$marker"
if PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_FAIL=interrupted OMARCHY_SESSION_ID=interrupted-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"; then
  fail "an interrupted intro reports a failure"
else
  status=$?
  (( status == 1 )) || fail "an interrupted intro does not request a retry" "$status"
fi
[[ $(<"$marker") == "interrupted-boot" ]] || fail "an intro interrupted after OWE accepted it still consumes the session"

rm "$marker"
: >"$command_log"
for index in {1..32}; do
  PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OMARCHY_SESSION_ID=concurrent-boot "$ROOT/bin/omarchy-theme-bg-boot-intro" >"$test_tmp/output.$index" &
  intro_pids[$index]=$!
done
for intro_pid in "${intro_pids[@]}"; do
  wait "$intro_pid"
done
intro_count=$(grep -c '^owe: intro ' "$command_log")
(( intro_count == 1 )) || fail "concurrent launchers start exactly one intro" "$intro_count"

pass "login intros settle the session once, wait briefly for OWE, and start on the first frame"

: >"$command_log"
for session in first-login first-login second-login; do
  PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" \
    OMARCHY_SESSION_ID="" HYPRLAND_INSTANCE_SIGNATURE="$session" "$ROOT/bin/omarchy-theme-bg-boot-intro"
done
intro_count=$(grep -c '^owe: intro ' "$command_log")
(( intro_count == 2 )) || fail "a new login replays the intro while a shell restart in the same session does not" "$intro_count"
[[ $(<"$marker") == "second-login" ]] || fail "the marker identifies the latest compositor session"
pass "logging out and back in replays the intro without requiring a reboot"

ln -s "$ROOT/bin/omarchy-theme-bg-boot-intro" "$command_bin/omarchy-theme-bg-boot-intro"

cat >"$command_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notification: %s\n' "$*" >>"$COMMAND_LOG"
SH
cat >"$command_bin/omarchy-theme-bg-current" <<'SH'
#!/bin/bash
printf 'Road\n'
SH
chmod +x "$command_bin"/omarchy-*

PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-intro" disable
if PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-intro" status; then
  fail "disabled background intros report a disabled status"
fi
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-intro" enable
PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-intro" status || fail "enabled background intros report an enabled status"
pass "background intros have one global on/off control"

# The shell asks which clip a background change would play.
: >"$command_log"
before_marker=$(<"$marker")
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-enabled "$background")
[[ $resolved == "$theme_intro_dir/road.mp4" ]] || fail "a background's clip resolves while intros are on" "$resolved"
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" ANIMATIONS=off "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-enabled "$background")
[[ -z $resolved ]] || fail "no clip resolves while animations are off"
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-intro" disable
resolved=$(PATH="$command_bin:$PATH" HOME="$intro_home" "$ROOT/bin/omarchy-theme-bg-boot-intro" --resolve-enabled "$background")
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-intro" enable
[[ -z $resolved ]] || fail "no clip resolves while intros are off"
! grep -q '^owe: ' "$command_log" || fail "resolving a clip plays nothing"
[[ $(<"$marker") == "$before_marker" ]] || fail "resolving a clip leaves login startup alone"
pass "a background's clip resolves only while intros and animations are on"

packaged_pairs=0
for intro in "$ROOT"/themes/*/backgrounds/intros/*.mp4; do
  [[ -f $intro ]] || continue
  backgrounds=${intro%/intros/*}
  stem=${intro##*/}
  stem=${stem%.mp4}
  matches=0
  for extension in jpg jpeg png bmp webp; do
    [[ ! -f $backgrounds/$stem.$extension ]] || ((++matches))
  done
  (( matches == 1 )) || fail "$intro has exactly one matching still image" "$matches"
  ((++packaged_pairs))
done
(( packaged_pairs > 0 )) || fail "no packaged theme intros were found"
pass "theme intro filenames match their sibling background images"

# Picker preparation is speculative and must not consume login startup or play.
prepare_root="$test_tmp/prepare-repo"
prepare_backgrounds="$prepare_root/themes/demo/backgrounds"
mkdir -p "$prepare_backgrounds/intros" "$intro_home/.local/state/omarchy/theme-backgrounds"
printf 'first still\n' >"$prepare_backgrounds/1-first.webp"
printf 'remembered still\n' >"$prepare_backgrounds/2-remembered.webp"
printf 'remembered video\n' >"$prepare_backgrounds/intros/2-remembered.mp4"
printf '%s\n' "$intro_state/theme/backgrounds/2-remembered.webp" >"$intro_home/.local/state/omarchy/theme-backgrounds/demo"
rm -f "$toggle"
: >"$command_log"
marker_before=$(<"$marker")
PATH="$command_bin:$PATH" HOME="$intro_home" OMARCHY_PATH="$prepare_root" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --prepare-theme demo
grep -Fxq "owe: intro-prepare $prepare_backgrounds/intros/2-remembered.mp4" "$command_log" || fail "picker preparation follows the theme's remembered background"
! grep -q '^owe: intro ' "$command_log" || fail "preparation does not play an intro"
[[ $(<"$marker") == "$marker_before" ]] || fail "preparation leaves login startup alone"
touch "$toggle"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" OMARCHY_PATH="$prepare_root" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --prepare-theme demo
[[ ! -s $command_log ]] || fail "disabled intros do not warm the renderer"
pass "picker preparation respects the remembered background, login startup, and intro toggle"

# Theme loops, which take over from a still or from its intro.
loop_home="$test_tmp/loop-home"
loop_state="$loop_home/.local/state/omarchy/current"
backgrounds="$loop_state/theme/backgrounds"
loop="$backgrounds/loops/1-totoro.mp4"
background="$backgrounds/1-totoro.webp"
other="$backgrounds/2-waves.webp"
link="$loop_state/background"
mkdir -p "${loop%/*}"
printf 'still\n' >"$background"
printf 'other still\n' >"$other"
printf 'loop video\n' >"$loop"
ln -s "$background" "$link"

resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only)
[[ $resolved == "$loop" ]] || fail "a loop matches the current still by filename" "$resolved"
pass "a loop matches the current still by filename"

resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only "$other")
[[ -z $resolved ]] || fail "a still without a matching loop has none" "$resolved"
pass "a still without a matching loop has none"

printf 'video background\n' >"$backgrounds/3-video.mp4"
printf 'loop video\n' >"$backgrounds/loops/3-video.mp4"
resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only "$backgrounds/3-video.mp4")
[[ -z $resolved ]] || fail "a video background never takes a loop" "$resolved"
pass "a video background never takes a loop"

still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$loop")
[[ $still == "$background" ]] || fail "a loop maps back to its still" "$still"
still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$other")
[[ $still == "$other" ]] || fail "a still maps to itself" "$still"
pass "a loop maps back to its still"

user_loop="$loop_home/Videos/loops/rain.mp4"
mkdir -p "${user_loop%/*}"
printf 'user video\n' >"$user_loop"
printf 'user still\n' >"$loop_home/Videos/rain.jpg"
still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$user_loop")
[[ $still == "$user_loop" ]] || fail "a user video in a loops folder stays a video background" "$still"
pass "a user video in a loops folder stays a video background"

# Every loop a still starts maps back to that still, so turning loops off and
# cycling can always find it.
printf 'upper still\n' >"$backgrounds/4-moon.JPG"
printf 'upper loop\n' >"$backgrounds/loops/4-moon.mp4"
resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only "$backgrounds/4-moon.JPG")
still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$backgrounds/loops/4-moon.mp4")
[[ $resolved == "$backgrounds/loops/4-moon.mp4" && $still == "$backgrounds/4-moon.JPG" ]] || fail "an uppercase still and its loop map both ways" "$resolved / $still"
pass "an uppercase still and its loop map both ways"

printf 'longer still\n' >"$backgrounds/4-moon.old.png"
still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$backgrounds/loops/4-moon.mp4")
[[ $still == "$backgrounds/4-moon.JPG" ]] || fail "a loop maps back only to the still of its own name" "$still"
rm "$backgrounds/4-moon.JPG"
still=$("$ROOT/bin/omarchy-theme-bg-loop-apply" --still "$backgrounds/loops/4-moon.mp4")
[[ $still == "$backgrounds/loops/4-moon.mp4" ]] || fail "a loop maps back only to the still of its own name" "$still"
pass "a loop maps back only to the still of its own name"

resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only "$loop_home/Videos/rain.jpg")
[[ -z $resolved ]] || fail "a still outside a backgrounds folder takes no loop" "$resolved"
user_backgrounds="$loop_home/.config/omarchy/backgrounds/test"
mkdir -p "$user_backgrounds/loops"
printf 'user still\n' >"$user_backgrounds/photo.jpg"
printf 'user loop\n' >"$user_backgrounds/loops/photo.mp4"
resolved=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --resolve-only "$user_backgrounds/photo.jpg")
[[ -z $resolved ]] || fail "a still outside a backgrounds folder takes no loop" "$resolved"
pass "a still outside a backgrounds folder takes no loop"

command_bin="$test_tmp/loop-bin"
command_log="$test_tmp/loop-command-log"
mkdir -p "$command_bin"
# A shell started with SELECTED answers what it shows, and takes the changes
# it is handed itself.
cat >"$command_bin/omarchy-shell" <<'SH'
#!/bin/bash
if [[ $* == "shell selectedBackground" ]]; then
  : >"$COMMAND_LOG.asked"
  printf '%s' "${SELECTED:-}"
  exit 0
fi
printf 'shell: %s\n' "$*" >>"$COMMAND_LOG"
[[ -z ${SELECTED:-} || $1 != "shell" ]] || echo ok
SH
cat >"$command_bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"option":"animations:enabled","bool":%s}\n' "$([[ ${ANIMATIONS:-on} == on ]] && echo true || echo false)"
SH
chmod +x "$command_bin/omarchy-shell" "$command_bin/hyprctl"

apply() {
  : >"$command_log"
  HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$@" "$ROOT/bin/omarchy-theme-bg-loop-apply"
}

apply env
[[ $(readlink "$link") == "$background" && -z $(<"$command_log") ]] || fail "a still stays until live backgrounds are turned on" "$(readlink "$link")"
[[ ! -e $command_log.asked ]] || fail "with live backgrounds off the shell is not asked"
pass "a still stays until live backgrounds are turned on"

mkdir -p "$loop_home/.local/state/omarchy/toggles"
touch "$loop_home/.local/state/omarchy/toggles/background-loops-on"
apply env
[[ $(readlink "$link") == "$loop" ]] || fail "the still's loop takes over the background" "$(readlink "$link")"
[[ $(<"$command_log") == "shell: -q background set $loop" ]] || fail "the shell learns of the loop" "$(<"$command_log")"
pass "the still's loop takes over the background"

apply env
[[ -z $(<"$command_log") ]] || fail "applying again changes nothing" "$(<"$command_log")"
pass "applying again changes nothing"

apply env ANIMATIONS=off
[[ $(readlink "$link") == "$background" ]] || fail "disabled animations return to the still" "$(readlink "$link")"
pass "disabled animations return to the still"

rm "$loop_home/.local/state/omarchy/toggles/background-loops-on"
ln -nsf "$loop" "$link"
apply env
[[ $(readlink "$link") == "$background" ]] || fail "the loop toggle returns to the still" "$(readlink "$link")"
pass "the loop toggle returns to the still"
touch "$loop_home/.local/state/omarchy/toggles/background-loops-on"

ln -nsf "$other" "$link"
apply env
[[ $(readlink "$link") == "$other" && -z $(<"$command_log") ]] || fail "a still without a loop stays" "$(readlink "$link")"
pass "a still without a loop stays"

# A running shell is asked for what it shows, and makes the swap itself.
ln -nsf "$background" "$link"
apply env SELECTED="$background"
[[ $(<"$command_log") == "shell: shell replaceBackground $background $loop" ]] || fail "a running shell swaps its still for the loop" "$(<"$command_log")"
[[ $(readlink "$link") == "$background" ]] || fail "a running shell moves the link itself" "$(readlink "$link")"
apply env SELECTED="$loop" ANIMATIONS=off
[[ $(<"$command_log") == "shell: shell replaceBackground $loop $background" ]] || fail "a running shell swaps the loop back for its still" "$(<"$command_log")"
pass "a running shell makes the swap itself"

# Toggling animations stops a playing loop, and starts it again.
for command in omarchy-hyprland-toggle omarchy-hyprland-toggle-enabled omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$command_bin/$command"
  chmod +x "$command_bin/$command"
done
ln -nsf "$loop" "$link"
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" ANIMATIONS=off "$ROOT/bin/omarchy-toggle-animations" off
[[ $(readlink "$link") == "$background" && $(<"$command_log") == "shell: -q background set $background" ]] ||
  fail "turning animations off returns a playing loop to its still" "$(readlink "$link")"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" ANIMATIONS=on "$ROOT/bin/omarchy-toggle-animations" on
[[ $(readlink "$link") == "$loop" ]] || fail "turning animations on starts the loop again" "$(readlink "$link")"
pass "toggling animations stops a playing loop, and starts it again"

# A shell starting up begins from the still, with nothing to tell yet.
ln -nsf "$loop" "$link"
: >"$command_log"
startup=$(HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-loop-apply" --still-only)
[[ $startup == "$background" && $(readlink "$link") == "$background" ]] || fail "a shell starting up begins from the loop's still" "$startup"
[[ -z $(<"$command_log") ]] || fail "a shell starting up isn't told of the still" "$(<"$command_log")"
startup=$(HOME="$loop_home" "$ROOT/bin/omarchy-theme-bg-loop-apply" --still-only)
[[ $startup == "$background" ]] || fail "a shell starting up on a still keeps it" "$startup"
pass "a shell starting up begins from the loop's still"

# Picking the still of the loop that plays changes nothing.
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" SELECTED="$loop" "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ -z $(<"$command_log") ]] || fail "picking the still of the playing loop changes nothing" "$(<"$command_log")"
pass "picking the still of the playing loop changes nothing"

# Picking a still hands the shell the still, which it may queue, and the loop
# follows only under the settings of that moment.
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" SELECTED="$background" "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ $(<"$command_log") == "shell: shell switchBackground $background "$'\n'"shell: shell replaceBackground $background $loop" ]] ||
  fail "picking a still with a loop starts it after the shell has the still" "$(<"$command_log")"
pass "picking a still with a loop starts it after the shell has the still"

: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" SELECTED="$background" ANIMATIONS=off "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ $(<"$command_log") == "shell: shell switchBackground $background " ]] || fail "a queued still stays a still with animations off" "$(<"$command_log")"
pass "a queued still stays a still with animations off"

ln -nsf "$other" "$link"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ $(readlink "$link") == "$loop" ]] || fail "without a shell, picking a still with a loop links the loop" "$(readlink "$link")"
pass "without a shell, picking a still with a loop links the loop"

# The first shell start of a session plays the intro, then starts the loop.
mkdir -p "$backgrounds/intros"
printf 'intro video\n' >"$backgrounds/intros/1-totoro.mp4"
cat >"$command_bin/owe" <<'SH'
#!/bin/bash
printf 'owe: %s\n' "$*" >>"$COMMAND_LOG"
[[ $1 != "status" ]] || printf '{"status":"ok"}\n'
SH
chmod +x "$command_bin/owe"
ln -nsf "$other" "$link"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ $(readlink "$link") == "$loop" ]] || fail "without a shell, a still with an intro still starts its loop" "$(readlink "$link")"
pass "without a shell, a still with an intro still starts its loop"

rm -f "$loop_home/.local/state/omarchy/background-intro.session-id"
ln -nsf "$background" "$link"
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" HYPRLAND_INSTANCE_SIGNATURE=first-session OMARCHY_SESSION_ID="" \
  "$ROOT/bin/omarchy-theme-bg-boot-intro"
grep -qx "owe: intro --start first-frame $backgrounds/intros/1-totoro.mp4" "$command_log" || fail "the first start plays the intro" "$(<"$command_log")"
[[ $(readlink "$link") == "$loop" ]] || fail "the first start hands the intro over to the loop" "$(readlink "$link")"
pass "the first start hands the intro over to the loop"

# A later shell restart in the same session skips the intro and keeps the loop.
ln -nsf "$background" "$link"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" HYPRLAND_INSTANCE_SIGNATURE=first-session OMARCHY_SESSION_ID="" \
  "$ROOT/bin/omarchy-theme-bg-boot-intro"
[[ $(readlink "$link") == "$loop" ]] || fail "a shell restart brings the loop back" "$(readlink "$link")"
pass "a shell restart brings the loop back"

# Cycling from a playing loop moves on from its still, not back to the first.
cat >"$command_bin/omarchy-theme-bg-set" <<'SH'
#!/bin/bash
printf 'set: %s\n' "$1" >>"$COMMAND_LOG"
SH
chmod +x "$command_bin/omarchy-theme-bg-set"
printf 'test\n' >"$loop_state/theme.name"
ln -nsf "$loop" "$link"
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-next"
[[ $(<"$command_log") == "set: $other" ]] || fail "bg next from a loop moves past its still" "$(<"$command_log")"
pass "bg next from a loop moves past its still"
