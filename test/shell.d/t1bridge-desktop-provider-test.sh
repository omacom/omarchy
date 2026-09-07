#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_root=$(mktemp -d)
stub_bin="$test_root/bin"
calls="$test_root/calls"
mkdir -p "$stub_bin"
trap 'rm -rf "$test_root"' EXIT

cat >"$stub_bin/omarchy-audio-output-sink" <<'STUB'
#!/bin/bash
[[ ${TEST_AUDIO:-1} == 1 ]] || exit 1
printf '%s\n' synthetic_sink
STUB

cat >"$stub_bin/pactl" <<'STUB'
#!/bin/bash
case $1 in
  get-sink-volume) printf '%s\n' 'Volume: front-left: 32768 / 42% / -20.00 dB' ;;
  get-sink-mute)
    [[ ${TEST_MUTE_QUERY:-1} == 1 ]] || exit 1
    printf '%s\n' 'Mute: no'
    ;;
  set-sink-mute|set-sink-volume) printf '%s\n' "pactl $*" >>"$CALLS" ;;
  *) exit 1 ;;
esac
STUB

cat >"$stub_bin/omarchy-shell" <<'STUB'
#!/bin/bash
if [[ $1 == media && $2 == status ]]; then
  if [[ ${TEST_MEDIA:-1} == 1 ]]; then
    printf '%s\n' '{"hasPlayer":true}'
  else
    printf '%s\n' '{"hasPlayer":false}'
  fi
else
  printf '%s\n' "shell $*" >>"$CALLS"
  printf '%s\n' ok
fi
STUB

cat >"$stub_bin/omarchy-audio-output-volume" <<'STUB'
#!/bin/bash
printf '%s\n' "audio $*" >>"$CALLS"
STUB

cat >"$stub_bin/omarchy-osd" <<'STUB'
#!/bin/bash
printf '%s\n' "osd $*" >>"$CALLS"
STUB

cat >"$stub_bin/omarchy-brightness-display" <<'STUB'
#!/bin/bash
printf '%s\n' 61
STUB

cat >"$stub_bin/omarchy-brightness-keyboard" <<'STUB'
#!/bin/bash
[[ $1 == status ]] || exit 1
printf '%s\n' 34
STUB

cat >"$stub_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' notification >>"$CALLS"
STUB

chmod +x "$stub_bin"/*
export CALLS="$calls"
provider="$ROOT/bin/omarchy-t1bridge-desktop-provider"

status=$(PATH="$stub_bin:$PATH" "$provider" v1 status)
[[ $status == "T1BRIDGE-DESKTOP 1 15 42 0" ]] || fail "provider reports available Omarchy capabilities" "$status"
pass "provider reports available Omarchy capabilities"

status=$(TEST_AUDIO=0 TEST_MEDIA=0 PATH="$stub_bin:$PATH" "$provider" v1 status)
[[ $status == "T1BRIDGE-DESKTOP 1 12 - -" ]] || fail "provider withdraws unavailable controls" "$status"
pass "provider withdraws unavailable controls"

status=$(TEST_MUTE_QUERY=0 PATH="$stub_bin:$PATH" "$provider" v1 status)
[[ $status == "T1BRIDGE-DESKTOP 1 14 - -" ]] || fail "provider withdraws audio when mute state is unavailable" "$status"
pass "provider withdraws audio when mute state is unavailable"

PATH="$stub_bin:$PATH" "$provider" v1 set-volume 73
grep -Fxq 'pactl set-sink-mute synthetic_sink 0' "$calls" || fail "provider unmutes the resolved sink"
grep -Fxq 'pactl set-sink-volume synthetic_sink 73%' "$calls" || fail "provider sets absolute volume directly"
grep -Fxq 'osd -i volume-high -p 73' "$calls" || fail "provider shows volume feedback"
pass "provider applies absolute volume and shows feedback"

PATH="$stub_bin:$PATH" "$provider" v1 show-display-brightness
grep -Fxq 'osd -i brightness -p 61' "$calls" || fail "provider shows display brightness feedback"
pass "provider shows display brightness feedback"

PATH="$stub_bin:$PATH" "$provider" v1 show-keyboard-backlight
grep -Fxq 'osd -i keyboard -p 34' "$calls" || fail "provider shows keyboard backlight feedback"
pass "provider shows keyboard backlight feedback"

PATH="$stub_bin:$PATH" "$provider" v1 toggle-mute
grep -Fxq 'audio mute-toggle' "$calls" || fail "provider uses Omarchy mute behavior"
pass "provider uses Omarchy mute behavior"

PATH="$stub_bin:$PATH" "$provider" v1 media-previous
PATH="$stub_bin:$PATH" "$provider" v1 media-play-pause
PATH="$stub_bin:$PATH" "$provider" v1 media-next
grep -Fxq 'shell media previous' "$calls" || fail "provider dispatches media previous"
grep -Fxq 'shell media playPause' "$calls" || fail "provider dispatches media play pause"
grep -Fxq 'shell media next' "$calls" || fail "provider dispatches media next"
pass "provider dispatches Omarchy media actions"

PATH="$stub_bin:$PATH" "$provider" v1 notify-renderer-fallback selection-exited
grep -Fxq notification "$calls" || fail "provider uses the Omarchy notification command"
pass "provider uses the Omarchy notification command"

if PATH="$stub_bin:$PATH" "$provider" v2 status >/dev/null 2>&1; then
  fail "provider rejects an unsupported contract version"
fi
if PATH="$stub_bin:$PATH" "$provider" v1 set-volume 101 >/dev/null 2>&1; then
  fail "provider rejects an out-of-range action value"
fi
pass "provider rejects unsupported versions and values"

drop_in="$ROOT/default/systemd/user/t1-touchbar.service.d/20-omarchy-desktop-provider.conf"
grep -Fxq 'Environment=T1BRIDGE_DESKTOP_PROVIDER=/usr/bin/omarchy-t1bridge-desktop-provider' "$drop_in" || fail "drop-in configures the installed provider path"
pass "drop-in configures the installed provider path"

autostart="$ROOT/default/hypr/autostart.lua"
restart_line=$(grep -F 'try-restart t1-touchbar.service' "$autostart")
[[ $restart_line == *"import-environment"* ]] || fail "renderer restart follows the session environment import"
pass "renderer restarts with the imported session environment"
