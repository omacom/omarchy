#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
export HOME="$stage/home" XDG_RUNTIME_DIR="$stage/runtime" COMMAND_LOG="$stage/log"
mkdir -p "$HOME/.local/state/omarchy/current" "$stage/media/intros" "$stage/bin" "$XDG_RUNTIME_DIR"
export PATH="$stage/bin:$ROOT/bin:$PATH"
current="$HOME/.local/state/omarchy/current/background"
marker="$HOME/.local/state/omarchy/background-intro.session-id"
toggle="$HOME/.local/state/omarchy/toggles/background-intros-off"
printf 'already-consumed\n' >"$marker"
for name in old road beach plain; do touch "$stage/media/$name.webp"; done
touch "$stage/media/intros/road.mp4" "$stage/media/intros/beach.mp4" "$stage/media/movie.mp4"
ln -s "$stage/media/old.webp" "$current"
cat >"$stage/bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"bool":%s}\n' "${ANIMATIONS:-true}"
SH
cat >"$stage/bin/owe" <<'SH'
#!/bin/bash
printf 'owe %s\n' "$*" >>"$COMMAND_LOG"
case $1 in
  status) [[ ${OWE_FAIL:-} != "status" ]] ;;
  render)
    [[ ${OWE_FAIL:-} != "snapshot" ]] || exit 1
    printf 'P6\n1 1\n255\n\377\377\377' >"$(jq -r .path <<<"$2")"
    ;;
  raw)
    [[ ${OWE_FAIL:-} != "intro" ]] || exit 1
    selected=$(readlink -f "$HOME/.local/state/omarchy/current/background")
    video=$(jq -r .path <<<"$2")
    [[ ${selected##*/} == "$(basename "${video%.*}").webp" ]] || exit 2
    if [[ -n ${START_GATE:-} ]]; then
      touch "$START_GATE.entered"
      while [[ ! -f $START_GATE ]]; do sleep 0.01; done
    fi
    ;;
esac
SH
cat >"$stage/bin/omarchy-shell" <<'SH'
#!/bin/bash
[[ $1 != "-q" ]] || shift
printf 'shell %s\n' "$*" >>"$COMMAND_LOG"
case $2 in
  prepareBackgroundIntro)
    [[ ${COVER_STATUS:-} != "unsupported" ]] || exit 1
    # The old background stays canonical until the outgoing cover is painted.
    [[ $(readlink -f "$HOME/.local/state/omarchy/current/background") != "${EXPECTED_BACKGROUND:-}" ]] || exit 2
    ;;
  themeIntroCoverStatus)
    if [[ -n ${COVER_GATE:-} && ! -f $COVER_GATE ]]; then
      touch "$COVER_GATE.entered"
      echo loading
      exit 0
    fi
    if [[ ${DISABLE_WHILE_WAITING:-false} == "true" ]]; then
      mkdir -p "$HOME/.local/state/omarchy/toggles"
      touch "$HOME/.local/state/omarchy/toggles/background-intros-off"
    fi
    echo "${COVER_STATUS:-ready}"
    ;;
esac
SH
cat >"$stage/bin/mktemp" <<'SH'
#!/bin/bash
[[ ${FAIL_SNAPSHOT_DIR:-false} != true ]] || exit 1
exec /usr/bin/mktemp "$@"
SH
cat >"$stage/bin/ln" <<'SH'
#!/bin/bash
[[ ${FAIL_BACKGROUND_LINK:-false} != true ]] || exit 1
exec /usr/bin/ln "$@"
SH
chmod +x "$stage/bin/"*

choose() { "$ROOT/bin/omarchy-theme-bg-set" "$stage/media/$1"; }
reset_selection() {
  ln -nsf "$stage/media/old.webp" "$current"
  : >"$COMMAND_LOG"
}
assert_still() {
  [[ $(readlink -f "$current") == "$stage/media/$1" ]] || fail "the selected media stays canonical"
  [[ $(<"$marker") == "already-consumed" ]] || fail "selection does not change the login marker"
  [[ -z $(find "$HOME/.cache/omarchy" -name 'background-selection.*' -print 2>/dev/null) ]] || fail "outgoing snapshots are cleaned up"
}

reset_selection
EXPECTED_BACKGROUND="$stage/media/road.webp" choose road.webp
assert_still road.webp
grep -q '^owe raw .*"cmd":"intro".*"start":"first-frame".*"refresh":true' "$COMMAND_LOG" || fail "confirmation starts one nonblocking one-shot intro"
grep -q '^shell background setInstant ' "$COMMAND_LOG" || fail "the retained background is ready for EOF"
grep -q '^shell shell startBackgroundIntro ' "$COMMAND_LOG" || fail "first-frame tracking is armed"
: >"$COMMAND_LOG"
choose road.webp
[[ ! -s $COMMAND_LOG ]] || fail "confirming the same image leaves playback alone"
pass "a different confirmed still plays its intro without replacing the persisted image or login marker"

for media in plain.webp movie.mp4; do
  reset_selection
  choose "$media"
  assert_still "$media"
  ! grep -q '^owe ' "$COMMAND_LOG" || fail "unmatched stills and videos use the ordinary path"
  grep -q '^shell shell cancelBackgroundIntro$' "$COMMAND_LOG" || fail "ordinary selection releases an older cover"
done
mkdir -p "${toggle%/*}"
for setting in toggle animations; do
  reset_selection
  if [[ $setting == "toggle" ]]; then touch "$toggle"; fi
  ANIMATIONS=$([[ $setting == "animations" ]] && echo false || echo true) choose road.webp
  assert_still road.webp
  ! grep -q '^owe raw ' "$COMMAND_LOG" || fail "disabled intros or animations skip playback"
  rm -f "$toggle"
done
pass "ordinary videos, missing intros and disabled animation settings keep their existing behavior"

for failure in status intro snapshot; do
  reset_selection
  OWE_FAIL="$failure" choose road.webp
  assert_still road.webp
  if [[ $failure == "snapshot" ]]; then
    grep -q '^owe raw ' "$COMMAND_LOG" || fail "a still snapshot substitutes for an unavailable renderer snapshot"
  else
    grep -q '^shell background set ' "$COMMAND_LOG" || fail "an unavailable OWE or rejected intro uses the ordinary still path"
  fi
done
for status in error unsupported superseded; do
  reset_selection
  COVER_STATUS="$status" choose road.webp
  assert_still road.webp
  ! grep -q '^owe raw ' "$COMMAND_LOG" || fail "an unavailable cover cannot expose an intro"
done
reset_selection
DISABLE_WHILE_WAITING=true choose road.webp
assert_still road.webp
! grep -q '^owe raw ' "$COMMAND_LOG" || fail "settings are checked again after cover preparation"
rm "$toggle"
pass "failed playback, unavailable covers and settings changed during preparation fall back to the still"

reset_selection
FAIL_SNAPSHOT_DIR=true choose road.webp
assert_still road.webp
! grep -q '^owe render\|^owe raw ' "$COMMAND_LOG" || fail "a failed temporary directory cannot produce an invalid snapshot path or start playback"
reset_selection
if FAIL_BACKGROUND_LINK=true choose road.webp; then
  fail "an unwritable canonical link reports failure"
fi
assert_still old.webp
! grep -q '^owe raw ' "$COMMAND_LOG" || fail "playback cannot start against an image that was not persisted"
grep -q '^shell shell finishThemeIntro ' "$COMMAND_LOG" || fail "a failed canonical link releases its outgoing cover"
pass "temporary-directory and canonical-link failures cannot start an intro for the wrong image"

reset_selection
COVER_GATE="$stage/cover-gate" choose road.webp &
preparing=$!
for attempt in {1..200}; do
  [[ -f $stage/cover-gate.entered ]] && break
  sleep 0.01
done
[[ -f $stage/cover-gate.entered ]] || fail "selection waits for its outgoing cover"
[[ $(readlink -f "$current") == "$stage/media/old.webp" ]] || fail "the link stays unchanged while the cover loads"
! grep -q '^owe raw ' "$COMMAND_LOG" || fail "playback waits for the presented cover"
touch "$stage/cover-gate"
wait "$preparing"
assert_still road.webp
pass "the outgoing cover is presented before the canonical still changes or playback starts"

reset_selection
START_GATE="$stage/gate" choose road.webp &
first=$!
for attempt in {1..200}; do
  [[ -f $stage/gate.entered ]] && break
  sleep 0.01
done
[[ -f $stage/gate.entered ]] || fail "the first selection reaches OWE"
choose beach.webp &
second=$!
sleep 0.1
[[ $(readlink -f "$current") == "$stage/media/road.webp" ]] || fail "a later selection waits for intro acceptance"
touch "$stage/gate"
wait "$first" "$second"
assert_still beach.webp
[[ $(grep -c '^owe raw ' "$COMMAND_LOG") == 2 ]] || fail "each serialized selection starts exactly once"
pass "rapid selections publish and start in order, with no delayed playback worker to restore an old image"
