#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
TASK_TMP=$(mktemp -d)
trap 'rm -rf "$TASK_TMP"' EXIT
mkdir -p "$TASK_TMP/bin" "$TASK_TMP/shots" "$TASK_TMP/runtime"
export CAPTURE_TEST_LOG="$TASK_TMP/calls"
export OMARCHY_SCREENSHOT_DIR="$TASK_TMP/shots"
export XDG_RUNTIME_DIR="$TASK_TMP/runtime"
export PATH="$TASK_TMP/bin:$ROOT/bin:$PATH"

cat >"$TASK_TMP/bin/stub" <<'SH'
#!/bin/bash
case "${0##*/}" in
  pkill) exit 1 ;;
  hyprctl)
    case $1 in
      getoption) printf '{"int":%s}\n' "$TEST_CURSOR" ;;
      monitors)
        jq -nc --argjson transform "$TEST_TRANSFORM" '
          [{name:"eDP-1", x:0, y:0, width:1920, height:1080, scale:1.5,
            transform:0, focused:false, activeWorkspace:{id:1}},
           {name:"HDMI-A-1", x:1280, y:0, width:1920, height:1080, scale:1.25,
            transform:$transform, focused:true, activeWorkspace:{id:2}}]'
        ;;
      clients) echo '[]' ;;
      eval|keyword) printf 'cursor %s\n' "$*" >>"$CAPTURE_TEST_LOG" ;;
      *) exit 1 ;;
    esac
    ;;
  hyprpicker)
    echo freeze >>"$CAPTURE_TEST_LOG"
    exec sleep 30
    ;;
  slurp)
    echo pick >>"$CAPTURE_TEST_LOG"
    [[ ${TEST_CANCEL:-0} == 1 ]] && exit 1
    echo '1580,0 300x32'
    ;;
  grim)
    printf 'capture %s\n' "$*" >>"$CAPTURE_TEST_LOG"
    [[ ${TEST_FAIL:-0} == 1 ]] && exit 1
    if [[ ${*: -1} == "-" ]]; then
      printf 'image'
    else
      printf 'image' >"${@: -1}"
    fi
    ;;
  wl-copy) cat >/dev/null ;;
  omarchy-notification-send) exit 0 ;;
esac
SH
chmod +x "$TASK_TMP/bin/stub"
for cmd in pkill hyprctl hyprpicker slurp grim wl-copy omarchy-notification-send; do
  ln -s stub "$TASK_TMP/bin/$cmd"
done

export TEST_CANCEL=0 TEST_FAIL=0
for TEST_CURSOR in 1 2; do
  export TEST_CURSOR
  for TEST_TRANSFORM in 1 2 3 4 5 6 7; do
    export TEST_TRANSFORM
    for mode in region smart windows fullscreen; do
      : >"$CAPTURE_TEST_LOG"
      "$ROOT/bin/omarchy-capture-screenshot" "$mode" save >/dev/null
      if grep -Eq '^(cursor|freeze)' "$CAPTURE_TEST_LOG"; then
        fail "transformed output preserves cursor=$TEST_CURSOR, transform=$TEST_TRANSFORM, mode=$mode"
      fi
      grep -q '^capture -g ' "$CAPTURE_TEST_LOG" || fail "capture still runs"
    done
  done
  pass "all transformed outputs preserve cursor mode $TEST_CURSOR across capture modes"
done

export TEST_CURSOR=1 TEST_TRANSFORM=1
for processing in copy slurp; do
  : >"$CAPTURE_TEST_LOG"
  "$ROOT/bin/omarchy-capture-screenshot" region "$processing" >/dev/null
  grep -q '^capture -g 1580,0 300x32 ' "$CAPTURE_TEST_LOG" || fail "geometry reaches $processing capture unchanged"
  if grep -Eq '^(cursor|freeze)' "$CAPTURE_TEST_LOG"; then fail "safe $processing path"; fi
done
pass "copy and notification flows retain the selected geometry"

: >"$CAPTURE_TEST_LOG"
TEST_CANCEL=1 "$ROOT/bin/omarchy-capture-screenshot" region save >/dev/null
if grep -Eq '^(cursor|freeze|capture)' "$CAPTURE_TEST_LOG"; then fail "cancel has no capture or cursor side effects"; fi
pass "cancel leaves cursor and capture untouched"

: >"$CAPTURE_TEST_LOG"
if TEST_FAIL=1 "$ROOT/bin/omarchy-capture-screenshot" region save >/dev/null; then fail "capture failure propagates"; fi
if grep -Eq '^(cursor|freeze)' "$CAPTURE_TEST_LOG"; then fail "failed capture leaves cursor untouched"; fi
pass "capture failure leaves configured cursor untouched"

selection=$("$ROOT/bin/omarchy-capture-region" region --no-freeze --keep-freeze)
[[ $selection == $'\n1580,0 300x32' ]] || fail "no-freeze retains empty PID line in keep-freeze protocol" "$selection"
pass "no-freeze retains the keep-freeze protocol"

for settings in '1 0' '0 1'; do
  read -r TEST_CURSOR TEST_TRANSFORM <<<"$settings"
  export TEST_CURSOR TEST_TRANSFORM
  : >"$CAPTURE_TEST_LOG"
  "$ROOT/bin/omarchy-capture-screenshot" region save >/dev/null
  grep -q '^freeze$' "$CAPTURE_TEST_LOG" || fail "normal capture still freezes"
  [[ $(grep -c '^cursor ' "$CAPTURE_TEST_LOG") == 2 ]] || fail "normal capture still overrides and restores cursor"
  grep -q "no_hardware_cursors = $TEST_CURSOR" "$CAPTURE_TEST_LOG" || fail "original cursor mode restored"
done
pass "untransformed and explicit hardware-cursor setups retain existing behavior"
