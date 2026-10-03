#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

source <(awk '
  /^(is_video_path|snapshot_background_path|set_theme_background)\(\) \{/ { copying=1 }
  copying { print }
  copying && /^}$/ { copying=0 }
' "$ROOT/bin/omarchy-theme-set")

transitions=()
shell_ipc() {
  if [[ $1 == background && $2 == themeTransition ]]; then
    transitions+=("$(readlink -f "$CURRENT_BACKGROUND_LINK")")
  fi
  return 0
}

CURRENT_BACKGROUND_LINK="$test_tmp/background"
BACKGROUND_TRANSITION_CACHE="$test_tmp/cache"
PREPARED_BACKGROUND=""
PREPARED_BACKGROUND_SNAPSHOT=""
colors_payload=""
shell_payload=""
CHOSEN_THEME_BACKGROUND="$test_tmp/next.png"
printf 'next\n' >"$CHOSEN_THEME_BACKGROUND"

for variant in "an old and a new snapshot" "a new snapshot only" "no snapshots"; do
  rm -rf "$BACKGROUND_TRANSITION_CACHE"
  rm -f "$CURRENT_BACKGROUND_LINK"
  transitions=()
  OLD_BACKGROUND_SNAPSHOT=""
  BACKGROUND_TRANSITION_SNAPSHOTS=true
  case $variant in
    "an old and a new snapshot")
      OLD_BACKGROUND_SNAPSHOT="$test_tmp/old-snapshot.png"
      printf 'old\n' >"$OLD_BACKGROUND_SNAPSHOT"
      ;;
    "no snapshots") BACKGROUND_TRANSITION_SNAPSHOTS=false ;;
  esac

  set_theme_background

  [[ ${#transitions[@]} == 1 && ${transitions[0]} == "$CHOSEN_THEME_BACKGROUND" ]] ||
    fail "the shell is told to transition only once the link names the new wallpaper, with $variant" \
      "link when the shell was told: ${transitions[*]:-never told}"
  pass "the shell is told to transition only once the link names the new wallpaper, with $variant"
done
