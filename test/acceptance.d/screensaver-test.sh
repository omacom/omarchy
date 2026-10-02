#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Play a text collection in a live screensaver window, then dismiss it twice:
# once by moving focus to an empty workspace, once with a key. The renderer
# runs with a throwaway HOME, so the session's own shell.json and branding are
# never read or written.
#
# The class is passed to jq through the environment, never as an argument:
# the launcher treats any process whose command line contains it as a running
# screensaver.
export SCREENSAVER_CLASS="org.omarchy.screensaver"

workdir=$(mktemp -d)
start_workspace=$(hyprctl -j activeworkspace | jq -r '.id')

focus_workspace() {
  hyprctl dispatch "hl.dsp.focus({ workspace = \"$1\" })" >/dev/null 2>&1 || hyprctl dispatch workspace "$1" >/dev/null
}

screensaver_addresses() {
  hyprctl -j clients | jq -r '.[] | select(.class == env.SCREENSAVER_CLASS) | .address'
}

screensaver_present() {
  [[ -n $(screensaver_addresses) ]]
}

screensaver_absent() {
  ! screensaver_present
}

screensaver_focused() {
  hyprctl -j activewindow | jq -e '.class == env.SCREENSAVER_CLASS'
}

effect_running() {
  pgrep -x ttfx
}

effect_stopped() {
  ! effect_running
}

effect_args_contain() {
  pgrep -a -x ttfx | grep -F -- "$1"
}

cleanup() {
  local address
  while read -r address; do
    [[ $address =~ ^0x[[:xdigit:]]+$ ]] || continue
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$address\" })" >/dev/null 2>&1 ||
      hyprctl dispatch closewindow "address:$address" >/dev/null 2>&1 || true
  done < <(screensaver_addresses 2>/dev/null)
  [[ -z $start_workspace ]] || focus_workspace "$start_workspace" || true
  rm -rf -- "$workdir"
}
trap cleanup EXIT

if pgrep -x ttfx >/dev/null || screensaver_present; then
  fail "no screensaver is already running before the test"
fi

home="$workdir/home"
collection="$workdir/collection"
playback="$workdir/playback"
mkdir -p "$home/.config/omarchy/branding" "$collection" "$playback"
printf 'FALLBACK\n' >"$home/.config/omarchy/branding/screensaver.txt"
printf 'OMARCHY ACCEPTANCE PLAIN\n' >"$collection/01-plain.txt"
printf '\e[38;2;255;64;64mOMARCHY ACCEPTANCE COLOUR\e[0m\n' >"$collection/02-colour.txt"
jq -n --arg source "$collection" '{screensaver: {source: $source}}' >"$home/.config/omarchy/shell.json"

launch_screensaver() {
  local renderer=(env HOME="$home" TMPDIR="$playback" OMARCHY_PATH="$OMARCHY_PATH" PATH="$OMARCHY_PATH/bin:$PATH"
    "$OMARCHY_PATH/bin/omarchy-screensaver")
  local command line

  case $(xdg-terminal-exec --print-id) in
  *Alacritty*) command=(alacritty --class="$SCREENSAVER_CLASS" --config-file "$OMARCHY_PATH/default/alacritty/screensaver.toml" -e "${renderer[@]}") ;;
  *ghostty*) command=(ghostty --class="$SCREENSAVER_CLASS" --config-file="$OMARCHY_PATH/default/ghostty/screensaver" --font-size=18 -e "${renderer[@]}") ;;
  *foot*) command=(foot --app-id="$SCREENSAVER_CLASS" --config="$OMARCHY_PATH/default/foot/screensaver.ini" -e "${renderer[@]}") ;;
  *kitty*) command=(kitty --class="$SCREENSAVER_CLASS" --override font_size=18 --override window_padding_width=0 -e "${renderer[@]}") ;;
  *) fail "default terminal is one the screensaver supports" "$(xdg-terminal-exec --print-id)" ;;
  esac

  printf -v line '%q ' "${command[@]}"
  hyprctl dispatch "hl.dsp.exec_cmd([[$line]])" >/dev/null 2>&1 || hyprctl dispatch exec -- bash -lc "$line" >/dev/null
}

launch_screensaver
wait_until "screensaver window opens" 15 screensaver_present
wait_until "screensaver window takes focus" 10 screensaver_focused
wait_until "screensaver window is fullscreen" 10 bash -c 'hyprctl -j activewindow | jq -e ".fullscreen != 0 and .fullscreen != false"'
wait_until "screensaver plays plain artwork with the effect's own colours" 15 effect_args_contain "--existing-color-handling ignore"
screenshot "success-screensaver-plain"
wait_until "screensaver advances to colour artwork that keeps its colours" 120 effect_args_contain "--existing-color-handling dynamic"
screenshot "success-screensaver-colour"

# Hyprland reports {} as the active window on an empty workspace.
focus_workspace empty
wait_until "focus on an empty workspace dismisses the screensaver" 10 screensaver_absent
wait_until "dismissal stops the effect" 10 effect_stopped
focus_workspace "$start_workspace"

launch_screensaver
wait_until "screensaver reopens" 15 screensaver_present
wait_until "reopened screensaver takes focus" 10 screensaver_focused
wait_until "reopened screensaver starts an effect" 15 effect_running
# Send the key only once the screensaver, not another window, has focus.
screensaver_focused >/dev/null || fail "screensaver still has focus before the key press"
wtype x
wait_until "a key press dismisses the screensaver" 10 screensaver_absent
wait_until "key dismissal stops the effect" 10 effect_stopped
wait_until "dismissal removes the playback copy" 10 bash -c '[[ -z $(ls -A -- "$1") ]]' _ "$playback"
