#!/bin/bash

# With `omarchy theme bg intro select enable`, picking a still within the
# current theme plays its matching intro once. Off by default, behind the
# master intro switch and the animations toggle, and never for videos.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
commands="$test_tmp/bin"
log="$test_tmp/commands"
mkdir -p "$state/theme/backgrounds/intros" "$commands" "$home/.local/state/omarchy/toggles"
printf 'still\n' >"$state/theme/backgrounds/1-sky.webp"
printf 'still\n' >"$state/theme/backgrounds/2-road.webp"
printf 'still\n' >"$state/theme/backgrounds/3-dusk.webp"
printf 'video\n' >"$state/theme/backgrounds/4-loop.mp4"
printf 'intro\n' >"$state/theme/backgrounds/intros/2-road.mp4"
printf 'intro\n' >"$state/theme/backgrounds/intros/3-dusk.mp4"
printf 'intro\n' >"$state/theme/backgrounds/intros/4-loop.mp4"
printf 'alpha\n' >"$state/theme.name"
ln -s "$state/theme/backgrounds/1-sky.webp" "$state/background"
printf 'already-consumed\n' >"$home/.local/state/omarchy/background-intro.session-id"

cat >"$commands/noop" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$commands/noop"
for command in omarchy-notification-send omarchy-i18n; do
  ln -sf noop "$commands/$command"
done
cat >"$commands/hyprctl" <<'STUB'
#!/bin/bash
printf '{"bool":%s}\n' "${TEST_ANIMATIONS:-true}"
STUB
cat >"$commands/omarchy-shell" <<'STUB'
#!/bin/bash
printf 'shell: %s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$commands/owe" <<'STUB'
#!/bin/bash
# `status` can be slowed so a newer selection lands while the launcher waits.
if [[ $1 == status && -n ${TEST_SLOW_STATUS:-} ]]; then
  sleep "$TEST_SLOW_STATUS"
fi
printf 'owe: %s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$commands/hyprctl" "$commands/omarchy-shell" "$commands/owe"

run() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$commands:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" TEST_LOG="$log" "$@"
}
set_background() {
  run /bin/bash "$ROOT/bin/omarchy-theme-bg-set" "$state/theme/backgrounds/$1" </dev/null >"$test_tmp/stdout" 2>"$test_tmp/stderr" ||
    fail "background selection completes" "$(cat "$test_tmp/stderr")"
}
settle() {
  # The launcher is detached; give it time to run (or decide not to).
  for attempt in {1..100}; do
    pgrep -f "^/bin/bash $ROOT/bin/omarchy-theme-bg-boot-intro --on-select" >/dev/null || break
    sleep 0.02
  done
}
wait_command() {
  for attempt in {1..100}; do
    grep -q "$1" "$log" && return 0
    sleep 0.02
  done
  fail "background selection reaches $1" "$(cat "$log")"
}
intros() {
  grep -c '^owe: intro ' "$log" || true
}

: >"$log"
set_background 2-road.webp
settle
grep -q "^shell: -q background set $state/theme/backgrounds/2-road.webp\$" "$log" || fail "the shell receives the selected still"
[[ $(readlink "$state/background") == "$state/theme/backgrounds/2-road.webp" ]] || fail "the background link follows the selection"
(( $(intros) == 0 )) || fail "with the opt-in off, selecting a still with a clip plays nothing"
! run omarchy-theme-bg-intro select status || fail "the opt-in reports disabled by default"
pass "selecting a background plays no intro by default"

run omarchy-theme-bg-intro select enable
run omarchy-theme-bg-intro select status || fail "the opt-in reports enabled after enable"
: >"$log"
set_background 1-sky.webp
settle
(( $(intros) == 0 )) || fail "a still without a clip plays nothing"
: >"$log"
set_background 2-road.webp
wait_command '^owe: intro '
grep -Fxq "owe: intro --start first-frame $state/theme/backgrounds/intros/2-road.mp4" "$log" || fail "the selected still's matching clip plays in first-frame mode"
(( $(intros) == 1 )) || fail "the clip plays exactly once"
[[ $(<"$home/.local/state/omarchy/background-intro.session-id") == already-consumed ]] || fail "a selection leaves login consumption unchanged"
head -1 "$log" | grep -q "^shell: -q background set " || fail "the shell is handed the still before the clip"
pass "with the opt-in on, selecting a still plays its matching intro once"

: >"$log"
set_background 4-loop.mp4
settle
(( $(intros) == 0 )) || fail "a video wallpaper never gets an intro, even with a same-named clip"
pass "video wallpapers play no intro"

touch "$home/.local/state/omarchy/toggles/background-intros-off"
: >"$log"
set_background 2-road.webp
settle
(( $(intros) == 0 )) || fail "the master intro switch off wins over the opt-in"
rm "$home/.local/state/omarchy/toggles/background-intros-off"
: >"$log"
TEST_ANIMATIONS=false set_background 3-dusk.webp
settle
(( $(intros) == 0 )) || fail "disabled animations suppress the opt-in intro"
pass "the opt-in respects the master switch and disabled animations"

: >"$log"
TEST_SLOW_STATUS=0.3 set_background 2-road.webp
sleep 0.05
set_background 3-dusk.webp
wait_command 'intros/3-dusk.mp4$'
settle
(( $(intros) == 1 )) || fail "a rapid second selection supersedes the first clip" "$(cat "$log")"
! grep -q 'intros/2-road.mp4$' "$log" || fail "the superseded first clip never starts"
pass "rapid selections play only the newest clip"

run omarchy-theme-bg-intro select toggle
! run omarchy-theme-bg-intro select status || fail "toggle turns the opt-in off"
run omarchy-theme-bg-intro select toggle
run omarchy-theme-bg-intro select status || fail "toggle turns the opt-in back on"
run omarchy-theme-bg-intro select disable
! run omarchy-theme-bg-intro select status || fail "disable turns the opt-in off"
pass "the select sub-command toggles and reports the opt-in"

# Theme switches play their intro from omarchy-theme-set and the login launcher,
# neither of which routes through omarchy-theme-bg-set, so the opt-in cannot
# make a theme switch play twice.
! grep -q 'omarchy-theme-bg-set' "$ROOT/bin/omarchy-theme-set" || fail "theme switches do not pass through the on-select path"
grep -q 'omarchy-theme-bg-set' "$ROOT/bin/omarchy-theme-bg-next" || fail "background cycling passes through the on-select path"
pass "theme switches and background cycling take the intended intro paths"
