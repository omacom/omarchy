#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/config" "$work/v4l/video50" "$work/dt" "$work/dev/dma_heap"
touch "$work/dt/camera10" "$work/dev/video50" "$work/dev/dma_heap/system"
printf 'Front Camera\n' >"$work/v4l/video50/name"

CALLS="$work/calls"
WPCTL_HAS_CAMERA="$work/wpctl-has-camera"
export CALLS WPCTL_HAS_CAMERA

cat >"$work/bin/omarchy-hw-match-device-tree" <<'SH'
#!/bin/bash
[[ ${MOCK_DT_MATCH:-} == "$1" ]]
SH

cat >"$work/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$work/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALLS"
case "$*" in
  *"is-active --quiet wireplumber.service"*) exit 0 ;;
  *"is-active --quiet omarchy-camera-relay.service"*)
    [[ -f ${MOCK_ACTIVE_FILE:-/nonexistent} ]] && exit 0
    exit 3
    ;;
  *"is-enabled --quiet omarchy-camera-relay.service"*)
    [[ -f ${MOCK_ACTIVE_FILE:-/nonexistent} ]] && exit 0
    exit 1
    ;;
  *"try-restart wireplumber.service"*)
    touch "$WPCTL_HAS_CAMERA"
    exit 0
    ;;
esac
exit 0
SH

cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
if [[ -f $WPCTL_HAS_CAMERA ]]; then
  cat <<'OUT'
Video
 ├─ Devices:
 │      44. Front Camera                        [v4l2]
 ├─ Sources:
 │  *   48. Front Camera (V4L2)
Settings
OUT
else
  cat <<'OUT'
Video
 ├─ Devices:
 │      44. Front Camera                        [v4l2]
 ├─ Sources:
Settings
OUT
fi
SH

cat >"$work/bin/v4l2-ctl" <<'SH'
#!/bin/bash
printf 'v4l2-ctl %s\n' "$*" >>"$CALLS"
echo "	Device Caps      : 0x05200001"
echo "		Video Capture"
SH

cat >"$work/bin/mock-relayd" <<'SH'
#!/bin/bash
printf 'LIBCAMERA_IPA_CONFIG_PATH=%s\n' "${LIBCAMERA_IPA_CONFIG_PATH:-}" >"$MOCK_RELAY_OUT"
printf 'ARGS=%s\n' "$*" >>"$MOCK_RELAY_OUT"
SH

chmod +x "$work/bin/"*

# Copy the shipped tuning with a mock camera_dt_node path so tests work on any host.
mkdir -p "$work/omarchy/default/camera/tunings/anduril-bluechip/ipa/simple" \
  "$work/omarchy/default/systemd/user"
cp "$ROOT/default/camera/tunings/anduril-bluechip/ipa/simple/ov08x40.yaml" \
  "$work/omarchy/default/camera/tunings/anduril-bluechip/ipa/simple/"
sed "s|^camera_dt_node=.*|camera_dt_node=\"$work/dt/camera10\"|" \
  "$ROOT/default/camera/tunings/anduril-bluechip/tuning.conf" \
  >"$work/omarchy/default/camera/tunings/anduril-bluechip/tuning.conf"
cp "$ROOT/default/systemd/user/omarchy-camera-relay.service" \
  "$ROOT/default/systemd/user/omarchy-camera-guard.service" \
  "$work/omarchy/default/systemd/user/"

run_tuning() {
  PATH="$work/bin:$PATH" \
    OMARCHY_PATH="$work/omarchy" \
    XDG_CONFIG_HOME="$work/config" \
    MOCK_DT_MATCH="${MOCK_DT_MATCH:-anduril,bluechip}" \
    MOCK_ACTIVE_FILE="$work/relay-active" \
    "$ROOT/bin/omarchy-camera-tuning" "$@"
}

# 1. Syntax checks on all scripts
bash -n "$ROOT/bin/omarchy-camera-tuning" || fail "omarchy-camera-tuning has valid syntax"
bash -n "$ROOT/bin/omarchy-camera-relay" || fail "omarchy-camera-relay has valid syntax"
bash -n "$ROOT/bin/omarchy-camera-guard" || fail "omarchy-camera-guard has valid syntax"
bash -n "$ROOT/install/user/first-run/camera-tuning.sh" || fail "camera-tuning first-run has valid syntax"
bash -n "$ROOT/migrations/1795705800.sh" || fail "camera-tuning migration has valid syntax"

# 2. Non-matching laptop is a clean no-op
! MOCK_DT_MATCH="other,board" run_tuning match >/dev/null || fail "match fails on unrelated boards"
out="$(MOCK_DT_MATCH="other,board" run_tuning on)"
[[ $out == *"No camera tuning matches"* ]] || fail "on is a no-op on unrelated boards"

# 3. BlueChip matches and 'on' installs env + user units + restarts wireplumber once
matched="$(run_tuning match)"
[[ $matched == */anduril-bluechip ]] || fail "BlueChip matches its shipped tuning"

: >"$CALLS"
run_tuning on >/dev/null
[[ -r $work/config/omarchy/camera-relay.env ]] || fail "on writes camera-relay.env"
[[ -r $work/config/systemd/user/omarchy-camera-relay.service ]] || fail "on installs relay user unit"
[[ -r $work/config/systemd/user/omarchy-camera-guard.service ]] || fail "on installs guard user unit"
! grep -q '@' "$work/config/systemd/user/omarchy-camera-"*.service || fail "rendered user units have no unsubstituted placeholders"
grep -q "try-restart wireplumber.service" "$CALLS" || fail "on restarts wireplumber when Front Camera is not yet listed"
default_env="$(cat "$work/config/omarchy/camera-relay.env")"

# 4. User override via 'set' updates ~/.config/omarchy/camera.conf and re-renders env
: >"$CALLS"
run_tuning set gamma=1.65 contrast=1.1 saturation=1.3 >/dev/null
grep -qx "gamma=1.65" "$work/config/omarchy/camera.conf" || fail "set writes gamma override"
grep -qx "contrast=1.1" "$work/config/omarchy/camera.conf" || fail "set writes contrast override"
grep -qx "saturation=1.3" "$work/config/omarchy/camera.conf" || fail "set writes saturation override"
grep -q "GAMMA=1.65" "$work/config/omarchy/camera-relay.env" || fail "override gamma reaches camera-relay.env"
! grep -q "try-restart wireplumber.service" "$CALLS" || fail "set does not restart wireplumber when Front Camera is already listed"

# Invalid override is rejected cleanly
! run_tuning set gamma=bogus 2>/dev/null || fail "invalid gamma value is rejected"
! run_tuning set evil=1 2>/dev/null || fail "unknown override key is rejected"

# 5. Relay wrapper builds pipeline with overrides and user IPA precedence
mkdir -p "$work/config/omarchy/camera/ipa/simple"
MOCK_RELAY_OUT="$work/relay-out"
export MOCK_RELAY_OUT
PATH="$work/bin:$PATH" \
  XDG_CONFIG_HOME="$work/config" \
  OMARCHY_V4L_VIRTUAL_PATH="$work/v4l" \
  OMARCHY_DEV_PATH="$work/dev" \
  OMARCHY_V4L2_RELAYD_BIN="$work/bin/mock-relayd" \
  "$ROOT/bin/omarchy-camera-relay"
grep -q "LIBCAMERA_IPA_CONFIG_PATH=$work/config/omarchy/camera/ipa:$work/omarchy/default/camera/tunings/anduril-bluechip/ipa" "$MOCK_RELAY_OUT" ||
  fail "user IPA dir takes precedence over shipped tuning IPA dir"
grep -q "gamma=1.65 contrast=1.1 saturation=1.3" "$MOCK_RELAY_OUT" ||
  fail "relay passes tuned gamma, contrast, and saturation to libcamerasrc"
grep -q "device=$work/dev/video50" "$MOCK_RELAY_OUT" ||
  fail "relay resolves loopback device dynamically by card_label"

# --wait-ready succeeds when v4l2-ctl reports Video Capture
PATH="$work/bin:$PATH" \
  XDG_CONFIG_HOME="$work/config" \
  OMARCHY_V4L_VIRTUAL_PATH="$work/v4l" \
  OMARCHY_DEV_PATH="$work/dev" \
  "$ROOT/bin/omarchy-camera-relay" --wait-ready || fail "--wait-ready succeeds on Video Capture"

# 6. 'reset' restores shipped defaults, 'off' removes units and env
run_tuning reset >/dev/null
[[ ! -e $work/config/omarchy/camera.conf ]] || fail "reset removes user override file"
[[ $(cat "$work/config/omarchy/camera-relay.env") == "$default_env" ]] || fail "reset restores original rendered env"

run_tuning off >/dev/null
[[ ! -e $work/config/omarchy/camera-relay.env ]] || fail "off removes camera-relay.env"
[[ ! -e $work/config/systemd/user/omarchy-camera-relay.service ]] || fail "off removes relay unit"
[[ ! -e $work/config/systemd/user/omarchy-camera-guard.service ]] || fail "off removes guard unit"

echo "ok - omarchy-camera-tuning userland relay, overrides, IPA precedence, and lifecycle"
