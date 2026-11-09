#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$scratch/runtime"
export TEST_LOG="$scratch/log"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
state="$HOME/.local/state/omarchy/current"
mkdir -p "$state/theme/backgrounds/intros" "$scratch/bin" "$XDG_RUNTIME_DIR"
printf still >"$state/theme/backgrounds/road.webp"
printf still >"$state/theme/backgrounds/sky.webp"
printf video >"$state/theme/backgrounds/loop.mp4"
printf intro >"$state/theme/backgrounds/intros/road.mp4"
printf intro >"$state/theme/backgrounds/intros/loop.mp4"
printf already-consumed >"$HOME/.local/state/omarchy/background-intro.session-id"
cat >"$scratch/bin/omarchy-shell" <<'SH'
#!/bin/bash
# Only capture the actual handoff. Sequencing belongs to BackgroundSwitch.
printf '%s\n' "$*" >>"$TEST_LOG"
printf 'ok\n'
SH
cat >"$scratch/bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"bool":%s}\n' "${TEST_ANIMATIONS:-true}"
SH
for cmd in omarchy-notification-send omarchy-i18n; do
  printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/$cmd"
done
chmod +x "$scratch/bin/"*

select_background() {
  : >"$TEST_LOG"
  bash "$ROOT/bin/omarchy-theme-bg-set" "$state/theme/backgrounds/$1"
}
expect_handoff() {
  local expected="shell switchBackground $state/theme/backgrounds/$1 $2"
  [[ $(<"$TEST_LOG") == "$expected" ]] || fail "$3" "$(<"$TEST_LOG")"
  [[ $(<"$HOME/.local/state/omarchy/background-intro.session-id") == already-consumed ]] || fail "selection preserves the login marker"
  pass "$3"
}

select_background road.webp
expect_handoff road.webp "" "selection sends no intro without the opt-in"
! omarchy-theme-bg-intro select status || fail "selection defaults off"
omarchy-theme-bg-intro select enable
omarchy-theme-bg-intro select status || fail "enable persists the opt-in"
select_background road.webp
expect_handoff road.webp "$state/theme/backgrounds/intros/road.mp4" "opt-in hands the matching intro to the shell once"
select_background sky.webp
expect_handoff sky.webp "" "a background without a clip uses the ordinary transition"
select_background loop.mp4
expect_handoff loop.mp4 "" "a video wallpaper never gets an intro"
omarchy-theme-bg-intro disable
select_background road.webp
expect_handoff road.webp "" "the master intro switch overrides the opt-in"
omarchy-theme-bg-intro enable
TEST_ANIMATIONS=false select_background road.webp
expect_handoff road.webp "" "disabled animations suppress selection intros"
omarchy-theme-bg-intro select toggle
! omarchy-theme-bg-intro select status || fail "toggle disables the opt-in"
omarchy-theme-bg-intro select toggle
omarchy-theme-bg-intro select status || fail "toggle enables the opt-in"
omarchy-theme-bg-intro select disable
select_background road.webp
expect_handoff road.webp "" "disable restores the ordinary handoff"
