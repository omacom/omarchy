#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export PATH="$ROOT/bin:$PATH"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

loop_home="$test_tmp/home"
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

command_bin="$test_tmp/bin"
command_log="$test_tmp/command-log"
mkdir -p "$command_bin"
cat >"$command_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf 'shell: %s\n' "$*" >>"$COMMAND_LOG"
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
[[ $(readlink "$link") == "$loop" ]] || fail "the still's loop takes over the background" "$(readlink "$link")"
[[ $(<"$command_log") == "shell: -q background set $loop" ]] || fail "the shell learns of the loop" "$(<"$command_log")"
pass "the still's loop takes over the background"

apply env
[[ -z $(<"$command_log") ]] || fail "applying again changes nothing" "$(<"$command_log")"
pass "applying again changes nothing"

apply env ANIMATIONS=off
[[ $(readlink "$link") == "$background" ]] || fail "disabled animations return to the still" "$(readlink "$link")"
pass "disabled animations return to the still"

mkdir -p "$loop_home/.local/state/omarchy/toggles"
touch "$loop_home/.local/state/omarchy/toggles/background-loops-off"
ln -nsf "$loop" "$link"
apply env
[[ $(readlink "$link") == "$background" ]] || fail "the loop toggle returns to the still" "$(readlink "$link")"
pass "the loop toggle returns to the still"
rm "$loop_home/.local/state/omarchy/toggles/background-loops-off"

ln -nsf "$other" "$link"
apply env
[[ $(readlink "$link") == "$other" && -z $(<"$command_log") ]] || fail "a still without a loop stays" "$(readlink "$link")"
pass "a still without a loop stays"

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

# Picking a still with a loop tells the shell once, with the loop.
: >"$command_log"
HOME="$loop_home" PATH="$command_bin:$PATH" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-set" "$background"
[[ $(readlink "$link") == "$loop" ]] || fail "picking a still with a loop starts the loop" "$(readlink "$link")"
[[ $(<"$command_log") == "shell: -q background set $loop" ]] || fail "picking a still with a loop tells the shell once" "$(<"$command_log")"
pass "picking a still with a loop tells the shell once"

# The first shell start of a session plays the intro, then starts the loop.
mkdir -p "$backgrounds/intros"
printf 'intro video\n' >"$backgrounds/intros/1-totoro.mp4"
cat >"$command_bin/owe" <<'SH'
#!/bin/bash
printf 'owe: %s\n' "$*" >>"$COMMAND_LOG"
[[ $1 != "status" ]] || printf '{"status":"ok"}\n'
SH
chmod +x "$command_bin/owe"
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
