#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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
    [[ -z ${COVER_READY_FILE:-} || -f $COVER_READY_FILE ]] || exit 1
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
cat >"$command_bin/omarchy-shell" <<'SH'
#!/bin/bash
# The outgoing cover finishes loading on poll COVER_READY_AFTER.
if [[ $2 == "themeIntroCoverStatus" ]]; then
  if [[ -n ${COVER_READY_FILE:-} && ! -f $COVER_READY_FILE ]]; then
    polls=$(( $(cat "$COVER_READY_FILE.polls" 2>/dev/null || echo 0) + 1 ))
    echo "$polls" >"$COVER_READY_FILE.polls"
    if (( polls < ${COVER_READY_AFTER:-1} )); then
      echo "loading"
    else
      touch "$COVER_READY_FILE"
      echo "${COVER_STATUS:-ready}"
    fi
  else
    echo "${COVER_STATUS:-ready}"
  fi
fi
SH
chmod +x "$command_bin/omarchy-shell"

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

: >"$command_log"
before_marker=$(<"$marker")
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$(stat -Lc '%d:%i' "$intro_state/theme")"
grep -Fxq 'owe: refresh' "$command_log" || fail "unprepared theme switching synchronizes OWE with the selected image"
grep -Fxq "owe: intro --start first-frame $theme_intro_dir/road.mp4" "$command_log" || fail "theme switching plays its matching intro even after boot was consumed"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$(stat -Lc '%d:%i' "$intro_state/theme")" true
grep -Fxq "owe: intro --start first-frame --refresh $theme_intro_dir/road.mp4" "$command_log" || fail "prepared theme switching synchronizes and starts in one call"
! grep -Fxq 'owe: refresh' "$command_log" || fail "prepared playback avoids an extra refresh call"
cover_ready="$test_tmp/cover-ready"
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" COVER_READY_FILE="$cover_ready" COVER_READY_AFTER=3 "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$(stat -Lc '%d:%i' "$intro_state/theme")" true || fail "playback waits for the outgoing cover before starting"
: >"$command_log"
if PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" COVER_STATUS=error "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$(stat -Lc '%d:%i' "$intro_state/theme")" true; then
  fail "a failed cover requests the still fallback"
fi
! grep -q '^owe: intro ' "$command_log" || fail "a failed outgoing cover cannot expose an intro"
[[ $(<"$marker") == "$before_marker" ]] || fail "theme switching does not reopen the session marker"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$custom_background" "$(stat -Lc '%d:%i' "$intro_state/theme")"
! grep -q '^owe: intro ' "$command_log" || fail "a superseded theme switch does not play an old intro"
theme_id=$(stat -Lc '%d:%i' "$intro_state/theme")
: >"$command_log"
if PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" ANIMATIONS=off "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$theme_id"; then
  fail "a current theme launch requests its still fallback when animations were disabled"
fi
! grep -q '^owe: intro ' "$command_log" || fail "a canceled theme intro does not play"
mv "$intro_state/theme" "$intro_state/previous-theme"
cp -r "$intro_state/previous-theme" "$intro_state/theme"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$theme_id"
! grep -q '^owe: intro ' "$command_log" || fail "reused filenames do not let a superseded theme launch play"
pass "theme switches can play their selected intro without resetting login startup"

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
