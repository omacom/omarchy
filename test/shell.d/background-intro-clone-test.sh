#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "cloned background intro cover test"
require_command quickshell
require_command grim
require_command magick

stage=$(mktemp -d)
qs_pid=""
cleanup() {
  [[ -z $qs_pid ]] || { kill "$qs_pid" 2>/dev/null || true; wait "$qs_pid" 2>/dev/null || true; }
  rm -rf "$stage"
}
trap cleanup EXIT
mkdir -p "$stage/bin" "$stage/home/.local/state/omarchy/current"
cat >"$stage/bin/noop" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stage/bin/noop"
for command in omarchy-shell omarchy-plugin-enable omarchy-notification-send; do
  ln -s noop "$stage/bin/$command"
done
cat >"$stage/bin/omarchy-plugin-list" <<'SH'
#!/bin/bash
printf '[{"id":"intro-test.background"}]\n'
SH
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
sleep 5
SH
chmod +x "$stage/bin/omarchy-plugin-list" "$stage/bin/omarchy-theme-bg-boot-intro"
HOME="$stage/home" USER=intro-test OMARCHY_PATH="$ROOT" PATH="$stage/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-plugin-clone" omarchy.background >/dev/null
ln -s "$stage/home/.config/omarchy/plugins/intro-test.background" "$stage/clone"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/services" "$stage/services"
cp "$SHELL_TEST_DIR/fixtures/background-intro-clone/shell.qml" "$stage/shell.qml"
magick -size 128x128 xc:magenta "$stage/still.png"
ln -s "$stage/still.png" "$stage/home/.local/state/omarchy/current/background"

wait_phase() {
  for attempt in {1..100}; do
    [[ -s $stage/result.json ]] && [[ $(jq -r .phase "$stage/result.json") == "$1" ]] && return 0
    sleep 0.03
  done
  fail "cloned background reaches the $1 phase" "$(cat "$stage/quickshell.log")"
}
capture_pixel() {
  hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' >/dev/null
  local output
  output=$(hyprctl -j monitors | jq -r '.[0].name')
  timeout -k 1 3 grim -o "$output" "$stage/$1.png"
  magick "$stage/$1.png" -format '%[hex:p{32,256}]' info:
}
for consumed in false true; do
  if [[ $consumed == true ]]; then
    printf '%s\n' "$(</proc/sys/kernel/random/boot_id)" >"$stage/home/.local/state/omarchy/background-intro.boot-id"
  fi
  rm -f "$stage/result.json"
  HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" INTRO_TEST_RESULT="$stage/result.json" \
    quickshell -p "$stage" --no-color >"$stage/quickshell.log" 2>&1 &
  qs_pid=$!
  wait_phase cover
  jq -e --argjson consumed "$consumed" '.scoped and .privateCoordinator and .selected and (.covered == ($consumed | not))' "$stage/result.json" >/dev/null || \
    fail "the clone is scoped and a consumed boot never maps the cover" "$(cat "$stage/result.json")"
  if [[ $consumed == false ]]; then
    [[ $(capture_pixel cover) == "000000" ]] || fail "the shared startup cover hides the cloned background"
  else
    [[ $(capture_pixel cover) == "FF00FF" ]] || fail "a consumed boot does not flash a cover over the cloned background"
  fi
  wait_phase still
  [[ $(capture_pixel still) == "FF00FF" ]] || fail "releasing the shared cover reveals the cloned background"
  wait "$qs_pid" || fail "the cloned background fixture exits cleanly" "$(cat "$stage/quickshell.log")"
  qs_pid=""
  if rg -q 'ReferenceError|TypeError|Unable to assign|Binding loop' "$stage/quickshell.log"; then
    fail "the cloned background fixture has no QML errors" "$(cat "$stage/quickshell.log")"
  fi
done
pass "a real clone is covered only for startup, with its scoped facade and consumed-boot behavior intact"
