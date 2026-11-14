#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

launch_and_verify() {
  local name="$1" command="$2" class="$3" timeout="${4:-45}"

  # A pre-existing window makes the test ambiguous (and closing it would be
  # hostile on a dev machine) — acceptance runs expect a fresh session.
  if window_present "$class" >/dev/null 2>&1; then
    fail "$name starts with no pre-existing window" "a window matching $class is already open"
  fi

  launch_app "$command"
  wait_until "$name opens a window" "$timeout" window_present "$class"
  sleep 1
  screenshot "success-app-$name"

  local deadline=$((SECONDS + 30))
  while window_present "$class" >/dev/null 2>&1; do
    close_windows "$class"

    if ((SECONDS >= deadline)); then
      fail "$name window closes"
    fi

    sleep 2
  done
  pass "$name window closes"
}

# Keep launch coverage to the primary daily-use paths. The system acceptance
# test separately verifies the complete core package manifest.
# name|command|window class regex|launch timeout
apps='terminal|foot|^foot$
browser|chromium --new-window|(?i)chromium
neovim|xdg-terminal-exec --app-id=org.omarchy.nvim nvim|org.omarchy.nvim
writer|omawrite|(?i)omawrite'

status=0
while IFS='|' read -r name command class timeout; do
  if ! (launch_and_verify "$name" "$command" "$class" "$timeout"); then
    status=1
  fi
done <<<"$apps"

# Exercise real title changes: class-matched transparency used to overwrite the
# tag-matched opaque rule after Nautilus finished loading a folder.
verify_file_opacity() (
  if window_present '^org\.gnome\.Nautilus$' >/dev/null 2>&1; then
    fail "opacity check starts without existing Files windows"
  fi

  local original_mode scratch address="" mode folder expected inactive_expected
  local -a addresses=()
  original_mode=$(omarchy hyprland window transparency)
  scratch=$(mktemp -d)
  mkdir "$scratch/opacity-one" "$scratch/opacity-two"

  cleanup_opacity() {
    local result=$? address
    trap - EXIT
    if (( result != 0 )); then
      hyprctl -j clients >"$ARTIFACTS/opacity-failure-clients.json" 2>&1 || true
      hyprctl configerrors >"$ARTIFACTS/opacity-failure-configerrors.txt" 2>&1 || true
      screenshot "failure-file-opacity"
    fi
    # Include a window that opened just before a timeout, without closing
    # unrelated windows somebody might have opened during the check.
    mapfile -t addresses < <(hyprctl -j clients | jq -r \
      '.[] | select(.class == "org.gnome.Nautilus" and (.title == "opacity-one" or .title == "opacity-two")) | .address'; printf '%s\n' "${addresses[@]}")
    for address in "${addresses[@]}"; do
      [[ -n $address ]] || continue
      hyprctl dispatch "hl.dsp.window.close({ window = \"address:$address\" })" >/dev/null 2>&1 || true
    done
    if ! omarchy hyprland window transparency "$original_mode"; then
      printf 'not ok - restore original window opacity mode\n' >&2
      result=1
    fi
    rm -rf "$scratch"
    exit "$result"
  }
  trap cleanup_opacity EXIT

  file_title_is() {
    hyprctl -j clients | jq -e --arg address "$address" --arg title "$1" \
      'any(.[]; .address == $address and .title == $title)' >/dev/null
  }

  file_opacity_is() {
    local active inactive
    active=$(hyprctl getprop "address:$address" opacity)
    inactive=$(hyprctl getprop "address:$address" opacity_inactive)
    printf '%s %s active=%s inactive=%s expected=%s/%s\n' \
      "$mode" "$address" "$active" "$inactive" "$expected" "$inactive_expected" >>"$ARTIFACTS/files-opacity.txt"
    jq -en --argjson active "$active" --argjson inactive "$inactive" \
      --argjson expected "$expected" --argjson inactive_expected "$inactive_expected" \
      '$active == $expected and $inactive == $inactive_expected' >/dev/null
  }

  omarchy hyprland window transparency opaque
  # All six directed transitions, including changes on an already open window.
  for mode in opaque transparent glassy opaque glassy transparent opaque; do
    omarchy hyprland window transparency "$mode"
    if [[ -z $address ]]; then
      launch_app "nautilus --new-window '$scratch/opacity-one'"
      wait_until "Files opens for opacity check" 30 window_present '^org\.gnome\.Nautilus$'
      address=$(hyprctl -j clients | jq -r '.[] | select(.class == "org.gnome.Nautilus") | .address')
      addresses+=("$address")
      wait_until "new Files title finishes loading" 15 file_title_is opacity-one
    fi
    case "$mode" in
      opaque) expected=1; inactive_expected=1 ;;
      transparent) expected=0.985; inactive_expected=0.96 ;;
      glassy) expected=0.75; inactive_expected=0.75 ;;
    esac
    wait_until "Files opacity follows $mode before navigation" 10 file_opacity_is
    for folder in opacity-one opacity-two opacity-one; do
      hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null
      wtype -M ctrl l -m ctrl
      wtype "$scratch/$folder"
      wtype -k Return
      wait_until "Files title becomes $folder in $mode" 15 file_title_is "$folder"
      wait_until "Files opacity stays $mode after title change" 10 file_opacity_is
    done
    screenshot "success-files-opacity-$mode"
  done

  launch_app "nautilus --new-window '$scratch/opacity-two'"
  files_count_is_two() {
    local count
    count=$(hyprctl -j clients | jq '[.[] | select(.class == "org.gnome.Nautilus")] | length')
    (( count == 2 ))
  }
  wait_until "second Files window opens opaque" 30 files_count_is_two
  mapfile -t addresses < <(hyprctl -j clients | jq -r '.[] | select(.class == "org.gnome.Nautilus") | .address')
  for address in "${addresses[@]}"; do
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" >/dev/null
    wait_until "each Files window stays opaque across focus changes" 10 file_opacity_is
  done
  screenshot "success-files-opacity-two-windows"
  [[ -z $(hyprctl configerrors) ]] || fail "opacity modes leave no configuration errors"
)

if ! verify_file_opacity; then
  status=1
fi

exit $status
