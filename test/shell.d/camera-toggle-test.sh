#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

toggle="$ROOT/bin/omarchy-toggle-camera"
status="$ROOT/bin/omarchy-camera-status"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-toggle-camera"
udev_rule="$ROOT/etc/udev/rules.d/70-omarchy-camera-disabled.rules"
rule='%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-toggle-camera on, /usr/bin/omarchy-toggle-camera off'

# Exactly one rule, matched whole, because this grant skips the password. A
# second line, a wider group than wheel, or the same command without its
# arguments (which sudoers reads as "any arguments"), would widen it.
rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == "$rule" ]] ||
  fail "camera sudoers file carries exactly the wheel on/off rule and nothing else" "got: $rules"

if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "camera sudoers rule parses"
fi

grep -Fx 'PACKAGED_PATH=/usr/bin/omarchy-toggle-camera' "$toggle" >/dev/null ||
  fail "omarchy-toggle-camera elevates the path the sudoers rule names"

grep -E 'sudo -n -l -l' "$toggle" >/dev/null ||
  fail "omarchy-toggle-camera reads the grant from the long sudo listing"

gated=$(grep -A1 -E '^if \(\( EUID == 0 \)\); then$' "$toggle" || true)
[[ $gated == *"export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"* ]] ||
  fail "omarchy-toggle-camera pins PATH to trusted system directories when it holds root"

pass "camera sudoers rule is scoped to wheel, on, and off"

# The udev rule and the toggle have to agree on the flag, or a disabled camera
# comes back on the next replug or boot.
grep -F 'TEST=="/var/lib/omarchy/camera-disabled"' "$udev_rule" >/dev/null ||
  fail "camera udev rule keys on the flag omarchy-toggle-camera writes"
grep -Fx 'DISABLED_FLAG=/var/lib/omarchy/camera-disabled' "$toggle" >/dev/null ||
  fail "omarchy-toggle-camera writes the flag the udev rule tests"

if command -v udevadm >/dev/null && udevadm verify --help >/dev/null 2>&1; then
  udevadm verify --no-style "$udev_rule" >/dev/null || fail "camera udev rule parses"
fi

pass "camera udev rule keeps disabled cameras off on hotplug"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

flag="$test_tmp/state/camera-disabled"
mkdir -p "$test_tmp/state"

write_usb_interfaces() {
  rm -rf "$test_tmp/devices"
  mkdir -p "$test_tmp/devices"

  local class index=0
  for class in "$@"; do
    mkdir -p "$test_tmp/devices/1-1:1.$index"
    printf '%s\n' "$class" >"$test_tmp/devices/1-1:1.$index/bInterfaceClass"
    index=$((index + 1))
  done
}

camera_status() {
  OMARCHY_USB_DEVICES_PATH="$test_tmp/devices" \
  OMARCHY_CAMERA_DISABLED_FLAG="$flag" \
    "$status"
}

write_usb_interfaces 0e 0e 01
rm -f "$flag"
state=$(camera_status)
[[ $(jq -r '[.present, .disabled, (.inUse | type), (.apps | type)] | join(" ")' <<<"$state") == "true false boolean array" ]] ||
  fail "camera status reports a present, enabled camera" "got: $state"

: >"$flag"
state=$(camera_status)
[[ $(jq -r '[.present, .disabled] | join(" ")' <<<"$state") == "true true" ]] ||
  fail "camera status reports the machine-wide disable" "got: $state"

write_usb_interfaces 01 03
rm -f "$flag"
state=$(camera_status)
[[ $(jq -r '.present' <<<"$state") == "false" ]] ||
  fail "camera status ignores USB interfaces that are not video" "got: $state"

pass "camera status reports presence and the disable flag as JSON"

# The one find that scans /proc is stubbed: every call reports the lasting
# holders, and the brief ones only on the first call, like a browser opening
# each camera for a moment to list it. The fd paths it prints sit under a fake
# /proc, next to the comm file each real fd link has.
fake_proc="$test_tmp/proc"
holders_bin="$test_tmp/holders-bin"
mkdir -p "$fake_proc"/{101,102,103} "$holders_bin"
echo zoom >"$fake_proc/101/comm"
echo chromium >"$fake_proc/102/comm"
echo pipewire >"$fake_proc/103/comm"

cat >"$holders_bin/find" <<'SH'
#!/bin/bash
calls=$(( $(<"$FIND_CALLS") + 1 ))
echo "$calls" >"$FIND_CALLS"
for pid in $LASTING_HOLDERS; do echo "$FAKE_PROC/$pid/fd/5"; done
if (( calls == 1 )); then
  for pid in $BRIEF_HOLDERS; do echo "$FAKE_PROC/$pid/fd/5"; done
fi
SH
cat >"$holders_bin/pw-dump" <<'SH'
#!/bin/bash
cat "$PW_DUMP"
SH
chmod +x "$holders_bin/find" "$holders_bin/pw-dump"

holders_status() {
  echo 0 >"$test_tmp/find.calls"
  FIND_CALLS="$test_tmp/find.calls" \
  FAKE_PROC="$fake_proc" \
  LASTING_HOLDERS="$1" \
  BRIEF_HOLDERS="${2:-}" \
  PW_DUMP="$test_tmp/pw-dump.json" \
  PATH="$holders_bin:$PATH" \
  OMARCHY_USB_DEVICES_PATH="$test_tmp/devices" \
  OMARCHY_CAMERA_DISABLED_FLAG="$flag" \
    "$status"
}

write_usb_interfaces 0e 0e

state=$(holders_status 101 102)
[[ $(jq -c '[.inUse, .apps]' <<<"$state") == '[true,["zoom"]]' ]] ||
  fail "camera status names an app still holding a camera, not one that only listed it" "got: $state"

state=$(holders_status "" 102)
[[ $(jq -c '[.inUse, .apps]' <<<"$state") == '[false,[]]' ]] ||
  fail "camera status ignores an app that opened a camera only to list it" "got: $state"

pass "camera status counts an app only while it keeps a camera open"

# When PipeWire holds the camera, the app comes from pw-dump: Firefox captures
# through the camera portal, named on its client rather than on its stream.
# A second argument adds a screen share, which is a running video source too.
write_pw_dump() {
  jq -n --arg camera "$1" --arg share "${2:-}" '[
    {id: 40, type: "PipeWire:Interface:Client", info: {props: {"application.name": "Firefox"}}},
    {id: 60, type: "PipeWire:Interface:Node", info: {state: $camera, props: {"media.class": "Video/Source", "media.role": "Camera"}}},
    {id: 61, type: "PipeWire:Interface:Node", info: {state: $camera, props: {"media.class": "Stream/Input/Video", "client.id": 40}}}
  ] + if $share == "" then [] else [
    {id: 41, type: "PipeWire:Interface:Client", info: {props: {"application.name": "Chromium"}}},
    {id: 70, type: "PipeWire:Interface:Node", info: {state: "running", props: {"media.class": "Video/Source"}}},
    {id: 71, type: "PipeWire:Interface:Node", info: {state: "running", props: {"media.class": "Stream/Input/Video", "client.id": 41}}}
  ] end' >"$test_tmp/pw-dump.json"
}

write_pw_dump running
state=$(holders_status 103)
[[ $(jq -c '[.inUse, .apps]' <<<"$state") == '[true,["Firefox"]]' ]] ||
  fail "camera status names the app behind a PipeWire camera stream" "got: $state"

write_pw_dump suspended
state=$(holders_status 103)
[[ $(jq -c '[.inUse, .apps]' <<<"$state") == '[false,[]]' ]] ||
  fail "camera status ignores PipeWire opening a camera to enumerate it" "got: $state"

write_pw_dump suspended share
state=$(holders_status 103)
[[ $(jq -c '[.inUse, .apps]' <<<"$state") == '[false,[]]' ]] ||
  fail "camera status does not take a screen share for the camera" "got: $state"

pass "camera status counts a PipeWire hold only while a camera source runs"

# inotifywait fails like a watch that cannot be set up; udevadm stays up like
# the real monitor. Both log what they were asked to watch. The failure waits
# for the monitor to come up first, or wait -n could end the inner shell before
# the monitor logs anything or arms its pdeathsig.
watch_bin="$test_tmp/watch-bin"
mkdir -p "$watch_bin"
cat >"$watch_bin/inotifywait" <<'SH'
#!/bin/bash
printf 'inotifywait %s\n' "$*" >>"$WATCH_LOG"
for _ in {1..200}; do [[ -s $WATCH_PIDS ]] && break; sleep 0.01; done
exit 1
SH
cat >"$watch_bin/udevadm" <<'SH'
#!/bin/bash
printf 'udevadm %s\n' "$*" >>"$WATCH_LOG"
echo $$ >>"$WATCH_PIDS"
exec sleep 60
SH
chmod +x "$watch_bin/inotifywait" "$watch_bin/udevadm"

: >"$test_tmp/watch.log"
: >"$test_tmp/watch.pids"
WATCH_LOG="$test_tmp/watch.log" \
WATCH_PIDS="$test_tmp/watch.pids" \
PATH="$watch_bin:$PATH" \
OMARCHY_USB_DEVICES_PATH="$test_tmp/devices" \
  timeout 2 "$status" --watch >/dev/null &
watcher=$!

# The other waiter has to go down with the one that failed while the watcher
# is still running, or every retry would leave another monitor behind.
sleep 1
while read -r monitor_pid; do
  if kill -0 "$monitor_pid" 2>/dev/null; then
    kill "$monitor_pid"
    fail "camera watch takes the udev monitor down with a failed inotify waiter"
  fi
done <"$test_tmp/watch.pids"
wait "$watcher" || true

attempts=$(grep -c '^inotifywait ' "$test_tmp/watch.log" || true)
(( attempts == 1 )) ||
  fail "camera watch backs off when a waiter cannot start" "attempts in 2s: $attempts"

# /dev/null alone is opened several times a second, and every wake rescans
# every process's fds.
grep -Fx 'inotifywait -m -q -e open,close --include ^/dev/video[0-9]+$ /dev' "$test_tmp/watch.log" >/dev/null ||
  fail "camera watch wakes only for camera nodes opening and closing" "got: $(<"$test_tmp/watch.log")"

# A disabled camera being unplugged has no /dev node left to go away, so it
# only shows up on the USB bus.
grep -Fx 'udevadm monitor --udev --subsystem-match=usb/usb_interface' "$test_tmp/watch.log" >/dev/null ||
  fail "camera watch follows cameras on the USB bus" "got: $(<"$test_tmp/watch.log")"

pass "camera watch ignores unrelated /dev activity and backs off when a waiter fails"

# Root runs the privileged half directly, so the stubs below would not
# stand between the script and this machine's real cameras.
if (( EUID == 0 )); then
  skip "running as root; skipping the elevation checks, which would disable this machine's cameras"
  exit 0
fi

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/pkexec" <<'SH'
#!/bin/bash
printf 'pkexec %s\n' "$*" >>"$ELEVATION_LOG"
SH

# An empty STUB_GRANTED stands for an install whose omarchy-settings predates
# the grant.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
if [[ $1 == -n && $2 == -l ]]; then
  for granted in ${STUB_GRANTED-on off}; do
    [[ ${!#} == "$granted" ]] || continue
    echo "    Options: !authenticate"
    exit 0
  done
  echo "    Matched: ${!#}"
  exit 0
fi
printf 'sudo %s\n' "$*" >>"$ELEVATION_LOG"
SH

cat >"$stub_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'osd %s\n' "$*" >>"$ELEVATION_LOG"
SH
chmod +x "$stub_bin/pkexec" "$stub_bin/sudo" "$stub_bin/omarchy-osd"

toggle_log() {
  : >"$test_tmp/log"
  ELEVATION_LOG="$test_tmp/log" \
  OMARCHY_CAMERA_DISABLED_FLAG="$flag" \
  PATH="$stub_bin:$PATH" \
    bash "$toggle" "$@" </dev/null >/dev/null
  cat "$test_tmp/log"
}

rm -f "$flag"
log=$(toggle_log)
[[ $log == $'sudo /usr/bin/omarchy-toggle-camera off\nosd -i camera-off -m Camera disabled' ]] ||
  fail "toggle turns enabled cameras off through the passwordless grant" "got: $log"

: >"$flag"
log=$(toggle_log toggle)
[[ $log == $'sudo /usr/bin/omarchy-toggle-camera on\nosd -i camera -m Camera enabled' ]] ||
  fail "toggle turns disabled cameras back on through the passwordless grant" "got: $log"

log=$(OMARCHY_PATH="$test_tmp/checkout" toggle_log off)
[[ $log == "sudo /usr/bin/omarchy-toggle-camera off"* ]] ||
  fail "omarchy-toggle-camera elevates the system install wherever OMARCHY_PATH points" "got: $log"

pass "omarchy-toggle-camera elevates on and off through sudo, not polkit"

log=$(STUB_GRANTED="" toggle_log off)
[[ $log == "pkexec /usr/bin/omarchy-toggle-camera off"* ]] ||
  fail "omarchy-toggle-camera falls back to polkit where the sudoers grant is not installed" "got: $log"

if bash "$toggle" sideways </dev/null >/dev/null 2>&1; then
  fail "omarchy-toggle-camera rejects unknown actions"
fi

pass "omarchy-toggle-camera falls back to polkit and rejects unknown actions"
