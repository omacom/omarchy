#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-install-camera"
leaf="$ROOT/install/hardware/qualcomm/camera.sh"
test_tmp=$(mktemp -d)
grant_pid=""
trap '[[ -n $grant_pid ]] && kill "$grant_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

# The Snapdragon check answers from a file, so each case picks the platform.
# Package installs are recorded instead of run.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-hw-aarch64-qualcomm" <<'STUB'
#!/bin/bash
[[ -e $OMARCHY_TEST_QUALCOMM ]]
STUB
cat >"$test_tmp/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_PACKAGES"
STUB
chmod +x "$test_tmp/bin/omarchy-hw-aarch64-qualcomm" "$test_tmp/bin/omarchy-pkg-add"
export OMARCHY_TEST_QUALCOMM="$test_tmp/qualcomm"
export OMARCHY_TEST_PACKAGES="$test_tmp/packages"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

new_home() {
  local home="$test_tmp/home-$1"
  mkdir -p "$home/.config"
  echo "$home"
}

shipped="$ROOT/config/chromium-flags.conf"
features=$(grep -- '^--enable-features=' "$shipped")

touch "$OMARCHY_TEST_QUALCOMM"
home=$(new_home shipped)
cp "$shipped" "$home/.config/chromium-flags.conf"
HOME=$home bash "$helper"
HOME=$home bash "$helper"
conf="$home/.config/chromium-flags.conf"
grep -Fxq -- "$features,WebRtcPipeWireCamera" "$conf" || fail "Snapdragon Chromium keeps its features and adds WebRtcPipeWireCamera once" "$(cat "$conf")"
(( $(grep -c -- '^--enable-features=' "$conf") == 1 )) || fail "Snapdragon Chromium keeps one feature list" "$(cat "$conf")"
pass "a Snapdragon laptop gets Chromium's PipeWire camera once, even when the helper runs twice"

home=$(new_home both)
cp "$shipped" "$home/.config/chromium-flags.conf"
HOME=$home bash "$ROOT/bin/omarchy-install-video-decode"
HOME=$home bash "$helper"
grep -Fxq -- "$features,AcceleratedVideoDecoder,WebRtcPipeWireCamera" "$home/.config/chromium-flags.conf" ||
  fail "the video and camera features share Chromium's feature list" "$(cat "$home/.config/chromium-flags.conf")"
pass "the video and camera features share Chromium's feature list"

home=$(new_home user-set)
printf '%s\n' '--enable-features=WebRtcPipeWireCamera<Trial' >"$home/.config/chromium-flags.conf"
HOME=$home bash "$helper"
[[ $(cat "$home/.config/chromium-flags.conf") == '--enable-features=WebRtcPipeWireCamera<Trial' ]] ||
  fail "a camera feature the user set stays as it is" "$(cat "$home/.config/chromium-flags.conf")"
home=$(new_home missing)
HOME=$home bash "$helper"
[[ ! -e $home/.config/chromium-flags.conf ]] || fail "a missing Chromium flags file stays missing"
pass "a feature the user set and a missing flags file stay as they are"

if HOME=$home bash "$ROOT/bin/omarchy-chromium-add-feature" 'Foo/Bar' 2>/dev/null; then
  fail "the feature helper refuses a name that isn't a Chromium feature"
fi
pass "the feature helper refuses a name that isn't a Chromium feature"

rm "$OMARCHY_TEST_QUALCOMM"
home=$(new_home other)
cp "$shipped" "$home/.config/chromium-flags.conf"
HOME=$home bash "$helper"
cmp -s "$shipped" "$home/.config/chromium-flags.conf" || fail "other machines keep Chromium's flags" "$(cat "$home/.config/chromium-flags.conf")"
rm -f "$OMARCHY_TEST_PACKAGES"
bash -c "source '$leaf'"
[[ ! -e $OMARCHY_TEST_PACKAGES ]] || fail "other machines get no camera backend" "$(cat "$OMARCHY_TEST_PACKAGES")"
pass "other machines keep Chromium's flags and get no camera backend"

touch "$OMARCHY_TEST_QUALCOMM"
rm -f "$OMARCHY_TEST_PACKAGES"
bash -c "source '$leaf'"
[[ $(cat "$OMARCHY_TEST_PACKAGES") == "pipewire-libcamera" ]] || fail "a Snapdragon laptop gets the PipeWire camera backend" "$(cat "$OMARCHY_TEST_PACKAGES" 2>/dev/null)"
grep -Fxq 'pipewire-libcamera' "$ROOT/install/omarchy-aarch64-qualcomm.packages" || fail "new Snapdragon installs get the camera backend"
grep -Fxq 'pipewire-libcamera' "$ROOT/install/omarchy-other.packages" || fail "the ISO can supply the camera backend offline"
pass "Snapdragon installs get the PipeWire camera backend, new and existing"

# At login on Snapdragon, WirePlumber waits for the media devices the seat hands
# out, and only until this user can open them, so libcamera finds the camera.
media="$test_tmp/media"
mkdir -p "$media"
cat >"$test_tmp/bin/udevadm" <<'STUB'
#!/bin/bash
if [[ ${*: -1} == */media0 ]]; then
  echo ":uaccess:seat:"
else
  echo ":seat:"
fi
STUB
chmod +x "$test_tmp/bin/udevadm"
wait_for_camera() {
  local start=${EPOCHREALTIME/./}
  OMARCHY_MEDIA_DEVICES_PATH="$media" "$ROOT/bin/omarchy-hw-wait-camera-access"
  echo $(((${EPOCHREALTIME/./} - start) / 1000))
}

if ((EUID == 0)); then
  skip "the login camera wait needs a user that file modes apply to"
else
  : >"$media/media1"
  chmod 000 "$media/media1"
  (($(wait_for_camera) < 500)) || fail "WirePlumber does not wait for a media device the seat does not hand out"
  : >"$media/media0"
  chmod 000 "$media/media0"
  rm "$OMARCHY_TEST_QUALCOMM"
  (($(wait_for_camera) < 500)) || fail "other machines start WirePlumber without waiting"
  touch "$OMARCHY_TEST_QUALCOMM"
  (sleep 1 && chmod 600 "$media/media0") >/dev/null 2>&1 &
  grant_pid=$!
  elapsed=$(wait_for_camera)
  wait "$grant_pid"
  grant_pid=""
  ((elapsed >= 900 && elapsed < 4000)) || fail "WirePlumber waits until the seat's camera opens" "waited ${elapsed} ms"
  pass "WirePlumber waits for the seat's camera at login, only on Snapdragon and only for it"
fi
