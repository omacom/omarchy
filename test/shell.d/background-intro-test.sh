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
if [[ $2 == "themeIntroCoverStatus" ]]; then
  if [[ -n ${COVER_READY_FILE:-} && ! -f $COVER_READY_FILE ]]; then
    echo "loading"
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
started=$SECONDS
if ! PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_FAIL=unavailable OMARCHY_SESSION_ID=unavailable-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"; then
  fail "an unavailable OWE settles startup rather than requesting another launcher"
fi
(( SECONDS - started >= 4 && SECONDS - started <= 7 )) || fail "startup waits only through the five-second window" "$((SECONDS - started))"
[[ $(<"$marker") == "unavailable-boot" ]] || fail "an unavailable OWE still settles the session"
! grep -q '^owe: intro ' "$command_log" || fail "an unavailable OWE never starts an intro"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OMARCHY_SESSION_ID=unavailable-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"
! grep -q '^owe: intro ' "$command_log" || fail "starting OWE after the deadline does not play a late intro"

rm "$marker"
: >"$command_log"
ready="$test_tmp/owe-ready"
(sleep 1; touch "$ready") &
ready_pid=$!
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=delayed-boot "$ROOT/bin/omarchy-theme-bg-boot-intro"
wait "$ready_pid"
[[ $(<"$marker") == "delayed-boot" ]] || fail "waiting for OWE keeps the session consumed"
grep -Fxq "owe: intro --start first-frame $theme_intro_dir/road.mp4" "$command_log" || fail "a ready OWE starts on the video's first frame without revealing the still"

rm "$marker" "$ready"
: >"$command_log"
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=restart-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro" &
waiting_pid=$!
for attempt in {1..100}; do
  [[ -f $marker && $(<"$marker") == "restart-while-waiting" ]] && break
  sleep 0.01
done
if ! PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=restart-while-waiting timeout 1 "$ROOT/bin/omarchy-theme-bg-boot-intro"; then
  kill "$waiting_pid" 2>/dev/null || true
  wait "$waiting_pid" || true
  fail "a restarted shell reads the consumed session without waiting for the old launcher"
fi
touch "$ready"
wait "$waiting_pid"

rm "$marker" "$ready"
: >"$command_log"
(sleep 0.5; touch "$toggle" "$ready") &
ready_pid=$!
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=disabled-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro"
wait "$ready_pid"
! grep -q '^owe: intro ' "$command_log" || fail "disabling intros while waiting cancels startup playback"
rm "$toggle" "$ready" "$marker"
: >"$command_log"
(sleep 0.5; ln -nsf "$custom_background" "$intro_state/background"; touch "$ready") &
ready_pid=$!
PATH="$command_bin:$PATH" HOME="$intro_home" XDG_RUNTIME_DIR="$intro_runtime" COMMAND_LOG="$command_log" OWE_READY_FILE="$ready" OMARCHY_SESSION_ID=changed-while-waiting "$ROOT/bin/omarchy-theme-bg-boot-intro"
wait "$ready_pid"
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
(sleep 0.2; touch "$cover_ready") &
cover_pid=$!
PATH="$command_bin:$PATH" HOME="$intro_home" COMMAND_LOG="$command_log" COVER_READY_FILE="$cover_ready" "$ROOT/bin/omarchy-theme-bg-boot-intro" --theme-switch "$background" "$(stat -Lc '%d:%i' "$intro_state/theme")" true || fail "playback waits for the outgoing cover before starting"
wait "$cover_pid"
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

migration_home="$test_tmp/migration-home"
migration_bin="$test_tmp/migration-bin"
migration_calls="$test_tmp/migration-calls"
mkdir -p "$migration_home/.local/state/omarchy/current" "$migration_bin"
printf 'catppuccin\n' >"$migration_home/.local/state/omarchy/current/theme.name"
cat >"$migration_bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
printf 'refresh\n' >>"$MIGRATION_CALLS"
SH
chmod +x "$migration_bin/omarchy-theme-refresh"

HOME="$migration_home" PATH="$migration_bin:$PATH" MIGRATION_CALLS="$migration_calls" OMARCHY_PATH="$ROOT" OMARCHY_SESSION_ID=migration-boot bash -euo pipefail "$ROOT/migrations/1788281348.sh" >/dev/null
[[ $(<"$migration_calls") == "refresh" ]] || fail "the migration refreshes an active theme with packaged intros"
[[ $(<"$migration_home/.local/state/omarchy/background-intro.session-id") == "migration-boot" ]] || fail "the migration defers a newly installed intro until the next login"

mkdir -p "$intro_runtime/hypr/older-session" "$intro_runtime/hypr/current-session"
touch -d '2 minutes ago' "$intro_runtime/hypr/older-session"
HOME="$migration_home" PATH="$migration_bin:$PATH" MIGRATION_CALLS="$migration_calls" OMARCHY_PATH="$ROOT" \
  OMARCHY_SESSION_ID="" HYPRLAND_INSTANCE_SIGNATURE="" XDG_RUNTIME_DIR="$intro_runtime" \
  bash -euo pipefail "$ROOT/migrations/1788281348.sh" >/dev/null
[[ $(<"$migration_home/.local/state/omarchy/background-intro.session-id") == "current-session" ]] || fail "an update outside Hyprland consumes the session that shell restart will use"
HOME="$migration_home" PATH="$migration_bin:$PATH" MIGRATION_CALLS="$migration_calls" OMARCHY_PATH="$ROOT" \
  OMARCHY_SESSION_ID="" HYPRLAND_INSTANCE_SIGNATURE="" XDG_RUNTIME_DIR="$test_tmp/no-session" \
  bash -euo pipefail "$ROOT/migrations/1788281348.sh" >/dev/null
[[ $(<"$migration_home/.local/state/omarchy/background-intro.session-id") == "current-session" ]] || fail "a headless update leaves the previous session marker alone"

pass "the migration does not start a login intro during an update"

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
